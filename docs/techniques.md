# Techniques

This page explains how mojo-json encodes and decodes, why those choices exist,
and which ideas were measured and dropped. It is a description of the shipped
code, not a list of goals.

The library is written in Mojo. It does not call simdjson, yyjson, glaze, or
any other C, C++, or Rust JSON library. The algorithms below are ports of
ideas from those libraries into Mojo `SIMD` types, word loads, and generated
structs.

The timed path in
[seriailizer-benchmark](https://github.com/leo-gan/GLD.SerializerBenchmark) is
generated-style `JsonDatum` encode and a hand-rolled expected-order decode on
the same wire helpers. `JsonValue` (the dynamic tree) is not that path.

## Two paths

A generated struct implements `encoded_len`, `encode_to`, and `decode_from`.
Object keys are baked as byte literals in schema property order. The decoder
expects that order. Extra keys are skipped. Missing required keys are an
error.

The official bench client (`gldjson_ser.mojo`) is the same idea written by
hand: it compares keys as little-endian `UInt64` / `UInt32` words instead of
parsing a string, then calls `read_int_here`, `read_float_here`, and
`read_string_here`.

`JsonValue` is an arena of nodes. It can hold any well-formed RFC 8259 value.
It allocates more and is not the speed target.

## Encode

### Pre-sized buffer

`WireWriter` allocates a `List[Byte]` whose **length** is the planned size, not
only its capacity. Each `write_byte` then stores at a cursor. If the
constructor only reserved capacity, every store resized from length 0.

`encode` of a generated type walks `encoded_len` first, then writes into that
buffer. `encoded_float_len` returns 24 for a non-integer float instead of
building `String(v)` on the size pass. The estimate can be slightly high. The
writer trims to the cursor in `finish`.

The official client does not call `encoded_len`. It starts a writer at 1024
bytes for `n=1` and 65536 for `n=100`. Those sizes fit the suite records
without a mid-encode resize. A 512-byte `n=1` buffer plus a list
`ensure(2 + 32 * 24)` resized during `strings` and `telemetry` encode.

### Baked keys and memcpy strings

A generated object writes `"f_bool":` as one byte span, not a quoted string
walk. A string field with no `"`, `\`, or control byte is a memcpy of the
UTF-8 payload between two quote bytes.

`needs_escape` scans with the host SIMD width (`simd_width_of[DType.uint8]()`,
32 on the AVX2 machine used for official runs). Compact suite strings are
3–16 bytes, so that scan often falls through to a scalar tail. That is
accepted: the memcpy path still wins when the string is clean.

### Integer write

`write_int_known` writes two digits per division from a 200-byte `"00"`…`"99"`
table (yyjson / EmberJson `DIGIT_PAIRS`). Digit count is taken from
`encoded_int_len` so the writer does not scan the magnitude twice.

### Float write

Suite telemetry is 32 values in `[0, 100)`. Message floats are
`rng.next_f64() * 1000`. Official fidelity is absolute difference `< 1e-8`.

Integer-valued finite floats write as `N.0`. Other values in `(-1e9, 1e9)`
use a 9-decimal rounded write, then strip trailing zeros. Two-digit pairs
fill the 9-digit fraction.

A short-dtoa loop that scaled by 10 until the value was an exact integer was
removed from the hot path. Random suite floats almost never hit that exact
case, so the loop paid seven failed probes and then did the 9-decimal write
anyway.

EmberJson’s Teju Jagua shortest-roundtrip writer was not ported. It is a
large table-driven algorithm. The 9-decimal path meets the suite fidelity
rule with much less code. Official telemetry encode is the cell that
benefited most from dropping the exact-search loop.

Reusing one destination buffer across official encode calls (`finish_keep`
plus a prefix memcpy out of a 2048-byte scratch) compiled and passed
fidelity. It was slower than `finish()` of a fresh writer. Mojo ownership
makes in-place `resize` of `self.dest` awkward. That path stays unused.

## Decode

### Expected order

Generated `decode_from` and the official client assume schema property order.
They do not build a hash map of keys. The official client checks eight or
four key bytes as one integer, then advances `pos`.

That is glaze’s typed skip-DOM idea: the schema is known, so a tape or a
`JsonValue` object is extra work.

### Whitespace and lists

Compact JSON has no spaces. `skip_ws` returns after one byte check on that
input. Pretty JSON still uses a SIMD scan over space, tab, LF, and CR.

After a compact `","` or before `"]"`, list helpers read the next value
without calling `skip_ws` again. Pretty lists still go through `peek`, which
skips whitespace.

`eat_here` requires the next byte to be the expected delimiter. `eat` skips
whitespace first. Official compact decode uses `eat_here` after a key match.

### SIMD string scan

`scan_plain_string` loads `SCAN_W` bytes and looks for `"`, `\`, or a byte
below 32. It also records whether any byte is `>= 128`. The first set bit
uses `count_trailing_zeros` (simdjson / EmberJson), not a 16-step scalar
walk.

An unescaped ASCII span becomes `String(unsafe_from_utf8=…)`. The scan
already proved the bytes are ASCII, so a second UTF-8 walk is skipped.
Non-ASCII goes through `string_from_utf8`.

A “scalar first 16 bytes, SIMD only after that” policy was slower on the
official `strings` suite. Suite strings sit in the middle of a few-hundred-byte
object, so 16 or 32 readable bytes are almost always available. SIMD-first
is the kept policy.

Padding the input with NULs so SIMD can load past the end was not added.
The suite payloads already have `remaining >= 8` in the middle of an object.
Copying every input to add 64 zero bytes costs more than it saves here.

### Integers: 8-digit then 4-digit SWAR

SWAR means doing several digit checks or accumulations in one integer
register.

`_is_eight_digits` tests eight bytes with the simdjson / EmberJson mask
`0xF0F0F0F0F0F0F0F0` plus a `+0x06` carry test. `_parse_eight_digits` is the
classic `*2561 >> 8`, `*6553601 >> 16`, `*42949672960001 >> 32` fold.

If eight digits are not left, a 4-digit pair uses the same idea in `UInt64`.
A `UInt32` multiply overflows on `9999` (`0x09090909 * 2561` does not fit
32 bits). An earlier attempt that zero-extended four bytes into the
**8-digit** formula decoded `"1234"` as `222823634`. That version is gone.
Tests cover `1234`, `1000`, `9999`, `123456`, and `12345678`.

### Floats: one pass

`parse_number` used to scan the token to find its end, then `_try_fast_float`
scanned it again to build the value. EmberJson’s `compute_float_fast` does
one pass.

The shipped parser accumulates integer and fraction digits while it walks,
counts the fraction length, parses a small exponent, then does
`acc * 10^(exp - frac)` from a 0…22 power-of-ten table. Values outside that
range fall back to `atof`.

A Mojo `InlineArray` of those 23 powers needs `materialize` at runtime, which
copies the table on every call. The if-chain stays.

This one-pass change is what cut official telemetry decode from about 1678 ns
to about 1230 ns on the 2026-09-09 all-single runs (median, skip warmup).

## What was measured and dropped

Each row was implemented, compiled, and timed on the official harness or a
local microbench. Only measured wins stayed.

| Idea | Source | Outcome |
| --- | --- | --- |
| Pre-size writer **length** | yyjson, glaze | Kept. Reserve-only resized on every byte. |
| Two-digit itoa + pair table | yyjson, EmberJson | Kept. |
| 8-digit SWAR parse | simdjson, EmberJson, sonic | Kept. |
| Correct 4-digit SWAR in `UInt64` | same family | Kept after the 32-bit bug. |
| `count_trailing_zeros` | simdjson, EmberJson | Kept. |
| One-pass float | EmberJson `compute_float_fast` | Kept. Largest telemetry decode win. |
| 9-decimal float write, no exact-search | suite fidelity `1e-8` | Kept. Exact-search never hit random floats. |
| Native SIMD width (32 on AVX2) | EmberJson `simd_width_of` | Kept. Net win vs hardcoded 16. |
| ASCII folded into the string scan | sonic copy-and-find family | Kept. Avoids a second pass. |
| Scalar-first 16 on strings | guessed for 3–16 byte words | Official `strings` decode about 13% slower. Reverted. |
| Dest-reuse (`finish_keep` + memcpy) | glaze reused dest | Official encode slower than `finish()`. Unused. |
| `n=1` cap 256 or 512 | smaller alloc | Resize storms on 411–491 byte records. 1024 kept. |
| Word-store of short encode keys | hand-rolled | Slower than one `write_bytes` memcpy. Reverted. |
| Teju shortest float | EmberJson teju | Not ported. Too much code for the suite. |
| Input NUL padding | simdjson padded input | Copy cost, little remaining-length win. Not added. |
| `InlineArray` pow10 | EmberJson `POWER_OF_TEN` | `materialize` copies the table. If-chain kept. |
| `@always_inline` on `parse_number` | EmberJson helpers | Local microbench slower. Only tiny SWAR helpers stay inlined. |
| 16-wide `needs_escape` for 3–16 byte strings | fix for 32-wide scalar tail | Official: one cell up, ten down. Discarded. |

## What is still expensive

Official `strings` decode is about half of EmberJson (median skip warmup,
2026-09-09-161131). That suite is 32 owned `String` values of length 3–16.
The scan is not the bound. Each `String` is a heap allocation. EmberJson also
builds `String`s; it does so from a reflection path that is tighter on this
shape.

A tape (simdjson / EmberJson `Document`) would classify the whole buffer in
one SIMD pass, then copy strings. The generated path already knows the
schema, so a tape is extra work for `message` and `document`. It might help
`strings`. It is not shipped.

Zero-copy `StringSlice` views into the input are a later goal in
[DESIGN.md](https://github.com/leo-gan/gld-json/blob/main/DESIGN.md). The
public field type is still owned `String`.

Event decode sits near EmberJson, not 1.5× above it. The record is several
short strings plus a small object list. Same allocation shape as `strings`,
fewer of them.

## How to read official numbers

The merge bar for speed work is a side-by-side official
`all-single json` run against EmberJson 0.3.4 on the same host. Analysis
takes the median of repetitions after dropping warmup index 0.

A single local `benches/microbench.mojo` number is useful for a compile-test
loop. It is not the official bar. The generated `Message` decode there is
expected-order codegen. The official `message` decode is the hand-rolled
word-compare client.

Fidelity 1.0 means the round-trip check passed at absolute float error
`< 1e-8`. Size is the compact UTF-8 length. A faster encode that writes
longer numbers can make decode slower. The 9-decimal writer is kept only
because official telemetry size stayed 491 bytes and decode still improved.

# Why JSON

[JSON](https://en.wikipedia.org/wiki/JSON) (JavaScript Object Notation) is a
self-describing text format defined by
[RFC 8259](https://www.rfc-editor.org/rfc/rfc8259.html). A decoder does not need
a schema to walk a value. Every value starts with `{`, `[`, `"`, a digit, `-`,
`t`, `f`, or `n`.

A schema language, [JSON Schema](https://json-schema.org/), is optional. This
library uses a JSON Schema subset to generate Mojo structs. Schema-free work
uses `JsonValue`.

This library implements that format in Mojo. It does not call simdjson. Python
`json` is used only as a test oracle.

The rest of this page is the subset of RFC 8259 that the library implements,
written for a reader who has not used JSON as a wire format before.
[Instructions](instructions.md) shows how to install and generate code.
[Examples](examples.md) shows the matching Mojo calls.

## Values

A JSON document is one value. Surrounding whitespace is space, tab, LF, and CR
only.

| Token | Meaning |
| --- | --- |
| `null` | no value |
| `true` / `false` | boolean |
| number | integer or floating-point |
| `"…"` | UTF-8 string |
| `[…]` | array |
| `{…}` | object (string keys) |

This library rejects comments, trailing commas, unquoted keys, single-quoted
strings, `NaN` / `Infinity` tokens, and a leading UTF-8 BOM.

## Numbers

A number is an optional minus, an integer, an optional fraction, and an optional
exponent. Leading zeros such as `01` are rejected.

Integers that fit in `Int64` stay `Int64`. Other finite values become
`Float64`. Overflow past a finite double is an error.

`-0` without a fraction is a floating-point negative zero. `0` is integer
zero. That differs from CPython `json.loads("-0")`, which is integer zero.

## Strings

A string is UTF-8 between quotes. Escapes are `\"`, `\\`, `\/`, `\b`, `\f`,
`\n`, `\r`, `\t`, and `\uXXXX`. A high surrogate must be followed by a low
surrogate. Unescaped control bytes are rejected.

Encode of a string with no bytes that need escaping is a copy of the UTF-8
payload between two quote bytes. Encode of `/` does not write `\/`.

## Objects and arrays

An object is an ordered list of string-keyed pairs. Duplicate keys are
well-formed. The last pair wins when a generated struct or `JsonValue.get`
looks up a key. Optional strict decode rejects duplicates.

Generated structs write properties in schema order. A `None` optional omits
the pair. There is never a trailing comma.

## Pretty-print and JSON Lines

Default encode is compact: no extra spaces. Pretty-print uses two-space indent
and a space after `:`.

[JSON Lines](https://jsonlines.org/) is zero or more compact values separated
by newlines. An empty buffer is a valid empty sequence. This is not RFC 7464
(no RS prefix).

## Pointer, Patch, and Merge Patch

[RFC 6901](https://www.rfc-editor.org/rfc/rfc6901.html) JSON Pointer names a
value inside a document (`/foo/0`). `~1` is `/`. `~0` is `~`.

[RFC 6902](https://www.rfc-editor.org/rfc/rfc6902.html) JSON Patch is an array
of `add` / `remove` / `replace` / `move` / `copy` / `test` operations.

[RFC 7396](https://www.rfc-editor.org/rfc/rfc7396.html) Merge Patch replaces
keys; a `null` value deletes a key.

These three operate on `JsonValue`. They copy, then apply, so a failure leaves
the original document unchanged.

## Limits

| Cap | Value |
| --- | --- |
| Nesting depth | 100 |
| Single string | 64_194_304 bytes |
| Array length or object pair count | 1_048_576 |
| JSON Lines record count | 1_048_576 |

# Instructions

If you have not used JSON as a wire format before, start with
[Why JSON](why-json.md). That page explains objects, arrays, numbers, strings,
pretty-print, JSON Lines, Pointer, and Patch.

## Install Mojo 1.0.0

```bash
git clone https://github.com/leo-gan/gld-json.git
cd gld-json
pixi install
pixi run test
```

If `pixi install` fails with 401 on `conda.modular.com`, set `PREFIX_API_KEY`
in a local `.env` (never commit that file) and run `scripts/ci-setup.sh`.

After a conda install from prefix.dev:

```bash
pixi add --channel https://prefix.dev/leo-gan/leo-gan mojo-json
```

That installs `json.mojoc` (plus `wire` / `runtime` / `schema`) and
`gld-jsongen-mojo`.

## Generate Mojo from JSON Schema

Write a JSON Schema document that uses the v1 subset (`type`, `properties`,
`required`, `items`, local `$ref`, `$defs`, `enum`, `const`, two-branch null
unions, named-object `oneOf` / `anyOf`). Then run the generator. After a conda
install the command is `gld-jsongen-mojo`. In a checkout:

```bash
pixi run mojo run -I src src/codegen/cli.mojo -- \
  --schema testdata/schema/benchmark_v2.json --out tests/generated
```

`pixi run generate` rebuilds the in-tree types from every file under
`testdata/schema/`.

A property that is not in `required` becomes `Optional[T]`. A two-branch type
array `{T, null}` also becomes `Optional[T]`.

## Encode and decode

```mojo
from json import encode, decode
from Message import Message

var m = Message()
m.f_int64 = Int64(150)
var buf = encode(m)
var m2 = decode[Message](buf)
```

`from json import …` resolves with `mojo run -I src` in a checkout, or from
`json.mojoc` after the package is installed.

Schema-free values use `JsonValue`:

```mojo
from json import decode_value, encode_value, EncodeOptions

var v = decode_value(buf)
var again = encode_value(v, EncodeOptions.pretty)
```

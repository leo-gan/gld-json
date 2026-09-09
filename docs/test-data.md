# Test data

Files under `testdata/` are ordinary unit and interop material. They are not a
shared external suite and they are not a product schema.

| Tree | Why it exists |
| --- | --- |
| `testdata/schema/` | JSON Schema documents the generator and parser tests read |
| `testdata/golden/` | Oracle text vectors plus `.hex` sidecars |
| `testdata/jsonl/` | JSON Lines samples |
| `testdata/pointer/` | RFC 6901 examples |
| `testdata/patch/` | RFC 6902 / 7396 examples |
| `testdata/suite/` | Small local accepted (`y_`) and rejected (`n_`) documents |

## Schemas

| File | Why |
| --- | --- |
| `benchmark_v2.json` | `Message`, `Document`, `Telemetry`, and the other v2 shapes |
| `longlist.json` | Recursive optional record |
| `keywords.json` | Mojo keyword identifiers |
| `union.json` | Tagged union of named objects (`Cat` / `Dog`) |

## Golden vectors

Atom and object goldens come from Python `json` via `scripts/gen_golden.py`.
Do not hand-edit `.json` files that the script owns.

## Derived files

`tests/generated/` is the output of `gld-jsongen-mojo`.
`scripts/check-generated.sh` fails if those files drift.

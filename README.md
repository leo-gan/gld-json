# mojo-json

A from-scratch [JSON](https://en.wikipedia.org/wiki/JSON) implementation for
[Mojo](https://mojolang.org/). The runtime and the code generator are written
in Mojo. They do not wrap, link, or vendor simdjson, yyjson, or any other C,
C++, or Rust JSON library.

Python `json` is a **test oracle** for golden text. It is not required to
encode or decode at runtime.

This repository is a standalone library. It is not part of any other project.

Documentation: [leo-gan.github.io/gld-json](https://leo-gan.github.io/gld-json/).
That site has a JSON format overview for new readers, the install steps, JSON
Schema walkthrough, examples, encode/decode techniques, and test-data notes.

## Install

Published package (linux-64) on [prefix.dev/leo-gan/leo-gan](https://prefix.dev/leo-gan/leo-gan):

```bash
pixi add --channel https://prefix.dev/leo-gan/leo-gan mojo-json
```

## Develop

```bash
git clone https://github.com/leo-gan/gld-json.git
cd gld-json
pixi install
pixi run test
```

If `pixi install` fails with 401 on `conda.modular.com`, set `PREFIX_API_KEY`
in a local `.env` (never commit that file) and run `scripts/ci-setup.sh`.

## License

MIT. Copyright (c) 2026 Leonid Ganeline.

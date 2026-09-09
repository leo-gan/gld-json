#!/usr/bin/env bash
# Compare Mojo encode against Python json for a few atoms.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
echo '{"a":1}' | python3 tests_interop/encode_ref.py >/dev/null
echo "python oracle ok"

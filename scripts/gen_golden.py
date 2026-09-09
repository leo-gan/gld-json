#!/usr/bin/env python3
"""Write testdata/golden/*.json from the stdlib json oracle."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "testdata" / "golden"
ROOT.mkdir(parents=True, exist_ok=True)

CASES = {
    "null": None,
    "true": True,
    "false": False,
    "int_0": 0,
    "int_150": 150,
    "int_neg1": -1,
    "text_hi": "hi",
    "array_1_2": [1, 2],
    "object_a_1": {"a": 1},
}

for name, value in CASES.items():
    text = json.dumps(value, separators=(",", ":"), ensure_ascii=False, allow_nan=False)
    (ROOT / f"{name}.json").write_text(text + "\n", encoding="utf-8")
    (ROOT / f"{name}.json.hex").write_text(text.encode("utf-8").hex() + "\n", encoding="ascii")

print("wrote", len(CASES), "goldens")

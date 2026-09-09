#!/usr/bin/env python3
import json
import sys

obj = json.loads(sys.stdin.read())
json.dump(obj, sys.stdout, separators=(",", ":"), ensure_ascii=False, allow_nan=False)

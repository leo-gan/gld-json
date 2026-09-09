#!/usr/bin/env python3
import json
import sys

obj = json.loads(sys.stdin.read())
sys.stdout.write(json.dumps(obj, separators=(",", ":"), ensure_ascii=False, allow_nan=False))

# Examples

## Generated struct

```mojo
from json import encode, decode
from Message import Message

var m = Message()
m.f_bool = True
m.f_int64 = Int64(150)
m.f_string = String("hi")
var buf = encode(m)
var m2 = decode[Message](buf)
```

## JsonValue

```mojo
from json import decode_value, encode_value, EncodeOptions

var v = decode_value(buf)
var compact = encode_value(v)
var pretty = encode_value(v, EncodeOptions.pretty)
```

## JSON Lines

```mojo
from json import decode_jsonl_values, encode_jsonl_values

var items = decode_jsonl_values(buf)
var again = encode_jsonl_values(items)
```

An empty buffer is a valid empty sequence. Single-item `decode` still rejects
trailing bytes.

## Pointer and Patch

```mojo
from json import pointer_get, pointer_set, apply_patch, merge_patch

var item = pointer_get(doc, "/foo/0")
var next = pointer_set(doc, "/foo/0", item)
var patched = apply_patch(doc, patch)
var merged = merge_patch(doc, patch)
```

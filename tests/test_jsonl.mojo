from std.testing import TestSuite, assert_equal

from json import decode_jsonl_values, encode_jsonl_values


def test_jsonl_roundtrip() raises:
    var buf = String("1\n2\n").as_bytes()
    var vs = decode_jsonl_values(buf)
    assert_equal(len(vs), 2)
    assert_equal(vs[0].as_int(), Int64(1))
    var again = encode_jsonl_values(vs)
    var vs2 = decode_jsonl_values(again)
    assert_equal(len(vs2), 2)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()

from std.testing import TestSuite, assert_equal

from json import apply_patch, decode_value, merge_patch


def test_add() raises:
    var doc = decode_value("{\"foo\":\"bar\"}".as_bytes())
    var patch = decode_value("[{\"op\":\"add\",\"path\":\"/baz\",\"value\":\"qux\"}]".as_bytes())
    var out = apply_patch(doc, patch)
    assert_equal(out.get("baz").as_str(), String("qux"))
    assert_equal(doc.get("foo").as_str(), String("bar"))


def test_merge() raises:
    var doc = decode_value("{\"a\":1,\"b\":2}".as_bytes())
    var patch = decode_value("{\"b\":null,\"c\":3}".as_bytes())
    var out = merge_patch(doc, patch)
    assert_equal(out.get("a").as_int(), Int64(1))
    assert_equal(out.get("c").as_int(), Int64(3))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()

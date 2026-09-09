from std.testing import TestSuite, assert_equal

from json import decode_value, json_int, pointer_get, pointer_set


def test_get() raises:
    var doc = decode_value("{\"foo\":[\"bar\",\"baz\"]}".as_bytes())
    var v = pointer_get(doc, "/foo/0")
    assert_equal(v.as_str(), String("bar"))


def test_set_root() raises:
    var doc = decode_value("1".as_bytes())
    var out = pointer_set(doc, "", json_int(Int64(2)))
    assert_equal(out.as_int(), Int64(2))
    assert_equal(doc.as_int(), Int64(1))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()

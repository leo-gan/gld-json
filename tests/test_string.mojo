from std.testing import TestSuite, assert_equal, assert_true

from json import decode_value, encode_value, json_string


def test_plain() raises:
    var v = decode_value("\"hi\"".as_bytes())
    assert_equal(v.as_str(), String("hi"))


def test_escape() raises:
    var v = decode_value("\"a\\nb\"".as_bytes())
    assert_equal(v.as_str(), String("a\nb"))


def test_roundtrip() raises:
    var v = json_string(String("quote\"slash\\"))
    var b = encode_value(v)
    var v2 = decode_value(b)
    assert_equal(v2.as_str(), String("quote\"slash\\"))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()

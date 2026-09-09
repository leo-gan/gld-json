from std.testing import TestSuite, assert_true

from json import EncodeOptions, decode_value, encode_value


def test_pretty_has_newlines() raises:
    var v = decode_value("{\"a\":1}".as_bytes())
    var b = encode_value(v, EncodeOptions.pretty)
    var s = String(from_utf8=b)
    assert_true(s.find("\n") >= 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()

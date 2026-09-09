from std.testing import TestSuite, assert_equal, assert_true

from json import decode_value, encode_value


def test_array() raises:
    var v = decode_value("[1,2,3]".as_bytes())
    assert_true(v.is_array())
    assert_equal(v.count(), 3)
    assert_equal(v.at(1).as_int(), Int64(2))


def test_object() raises:
    var v = decode_value("{\"a\":1,\"b\":true}".as_bytes())
    assert_true(v.is_object())
    assert_equal(v.get("a").as_int(), Int64(1))
    assert_true(v.get("b").as_bool())


def test_last_key_wins() raises:
    var v = decode_value("{\"a\":1,\"a\":2}".as_bytes())
    assert_equal(v.get("a").as_int(), Int64(2))


def test_trailing_comma() raises:
    var raised = False
    try:
        _ = decode_value("[1,]".as_bytes())
    except _:
        raised = True
    assert_true(raised)


def test_roundtrip_object() raises:
    var v = decode_value("{\"x\":\"y\"}".as_bytes())
    var b = encode_value(v)
    var v2 = decode_value(b)
    assert_equal(v2.get("x").as_str(), String("y"))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()

from std.testing import TestSuite, assert_equal, assert_true

from json import DecodeError, decode_value, encode_value, json_bool, json_int, json_null


def test_null() raises:
    var v = decode_value("null".as_bytes())
    assert_true(v.is_null())
    var b = encode_value(v)
    assert_equal(len(b), 4)


def test_bools() raises:
    var t = decode_value("true".as_bytes())
    assert_true(t.as_bool())
    var f = decode_value("false".as_bytes())
    assert_true(not f.as_bool())


def test_int() raises:
    var v = decode_value("150".as_bytes())
    assert_equal(v.as_int(), Int64(150))
    var n = decode_value("-1".as_bytes())
    assert_equal(n.as_int(), Int64(-1))


def test_trailing() raises:
    var raised = False
    try:
        _ = decode_value("1 2".as_bytes())
    except e:
        raised = e.kind == DecodeError.KIND_TRAILING
    assert_true(raised)


def test_constructors() raises:
    assert_true(json_null().is_null())
    assert_true(json_bool(True).as_bool())
    assert_equal(json_int(Int64(3)).as_int(), Int64(3))


def test_int_valued_float() raises:
    var v = decode_value("1.0".as_bytes())
    var b = encode_value(v)
    var s = String(from_utf8=b)
    assert_true(s == String("1.0") or s == String("1"))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()

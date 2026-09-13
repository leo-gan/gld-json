from std.testing import TestSuite, assert_equal, assert_true

from json import DecodeError, decode_value, encode_value, json_bool, json_float, json_int, json_null


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
    var four = decode_value("1234".as_bytes())
    assert_equal(four.as_int(), Int64(1234))
    var fourb = decode_value("1000".as_bytes())
    assert_equal(fourb.as_int(), Int64(1000))
    var fourc = decode_value("9999".as_bytes())
    assert_equal(fourc.as_int(), Int64(9999))
    var six = decode_value("123456".as_bytes())
    assert_equal(six.as_int(), Int64(123456))
    var eight = decode_value("12345678".as_bytes())
    assert_equal(eight.as_int(), Int64(12345678))
    var nine = decode_value("123456789".as_bytes())
    assert_equal(nine.as_int(), Int64(123456789))
    var neg8 = decode_value("-10000000".as_bytes())
    assert_equal(neg8.as_int(), Int64(-10000000))


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


def test_double_close_to_zero() raises:
    # JSONTestSuite y_number_double_close_to_zero — valid token, may underflow.
    var text = "[-0.000000000000000000000000000000000000000000000000000000000000000000000000000001]"
    var v = decode_value(text.as_bytes())
    assert_true(v.is_array())
    var x = v.at(0).as_float()
    assert_true(x <= 0.0)


def test_short_float() raises:
    var half = decode_value("0.5".as_bytes())
    assert_true(half.as_float() == 0.5)
    var neg = decode_value("-2.5".as_bytes())
    assert_true(neg.as_float() == -2.5)
    var sci = decode_value("1.5e2".as_bytes())
    assert_true(sci.as_float() == 150.0)
    var tiny = decode_value("1.25e-1".as_bytes())
    assert_true(tiny.as_float() == 0.125)
    var fourf = decode_value("12.3456".as_bytes())
    var df = fourf.as_float() - 12.3456
    if df < 0.0:
        df = -df
    assert_true(df < 1e-12)


def test_round_decimal_rt() raises:
    var v = json_float(0.1)
    var b = encode_value(v)
    var back = decode_value(b)
    var d = back.as_float() - 0.1
    if d < 0.0:
        d = -d
    assert_true(d < 1e-8)
    var v2 = json_float(67.890123456)
    var b2 = encode_value(v2)
    var back2 = decode_value(b2)
    var d2 = back2.as_float() - 67.890123456
    if d2 < 0.0:
        d2 = -d2
    assert_true(d2 < 1e-8)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()

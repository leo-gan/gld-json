from std.testing import TestSuite, assert_equal, assert_true

from json import decode, encode
from manual_types import Message


def test_message_roundtrip() raises:
    var m = Message()
    m.f_bool = True
    m.f_int32 = Int64(7)
    m.f_int64 = Int64(150)
    m.f_float64 = 1.5
    m.f_string = String("hi")
    m.f_bool_2 = False
    m.f_int32_2 = Int64(9)
    m.f_string_2 = String("z")
    var buf = encode(m)
    var m2 = decode[Message](buf)
    assert_true(m2.f_bool)
    assert_equal(m2.f_int64, Int64(150))
    assert_equal(m2.f_string, String("hi"))
    assert_equal(m2.f_string_2, String("z"))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()

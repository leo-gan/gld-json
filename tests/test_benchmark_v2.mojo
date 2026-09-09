from std.testing import TestSuite, assert_equal, assert_true

from json import EncodeOptions, decode, encode
from Message import Message


def test_generated_message() raises:
    var m = Message()
    m.f_bool = True
    m.f_int64 = Int64(150)
    m.f_float64 = 0.5
    m.f_string = String("hi")
    var buf = encode(m)
    var m2 = decode[Message](buf)
    assert_true(m2.f_bool)
    assert_equal(m2.f_int64, Int64(150))
    assert_true(m2.f_float64 == 0.5)
    assert_equal(m2.f_string, String("hi"))


def test_generated_message_pretty_and_ws() raises:
    var m = Message()
    m.f_int32 = Int64(3)
    m.f_float64 = 1.25
    m.f_string = String("ab")
    var pretty = encode(m, EncodeOptions.pretty)
    var m2 = decode[Message](pretty)
    assert_equal(m2.f_int32, Int64(3))
    assert_true(m2.f_float64 == 1.25)
    var padded = List[Byte]()
    padded.append(Byte(32))
    padded.append(Byte(10))
    var compact = encode(m)
    var i = 0
    while i < len(compact):
        padded.append(compact[i])
        i += 1
    var m3 = decode[Message](padded)
    assert_equal(m3.f_int32, Int64(3))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()

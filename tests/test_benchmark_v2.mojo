from std.testing import TestSuite, assert_equal, assert_true

from json import decode, encode
from Message import Message


def test_generated_message() raises:
    var m = Message()
    m.f_bool = True
    m.f_int64 = Int64(150)
    m.f_string = String("hi")
    var buf = encode(m)
    var m2 = decode[Message](buf)
    assert_true(m2.f_bool)
    assert_equal(m2.f_int64, Int64(150))
    assert_equal(m2.f_string, String("hi"))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()

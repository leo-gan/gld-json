from std.testing import TestSuite, assert_equal, assert_true

from schema.model import ST_OBJECT
from schema.parse import parse_schema_file


def test_benchmark_schema() raises:
    var doc = parse_schema_file("testdata/schema/benchmark_v2.json")
    assert_true(len(doc.types) > 0)
    assert_equal(doc.types[doc.root].kind, ST_OBJECT)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()

from json import decode_value, encode_value


def main() raises:
    var v = decode_value("{\"n\":150}".as_bytes())
    var buf = encode_value(v)
    print(String(from_utf8=buf))

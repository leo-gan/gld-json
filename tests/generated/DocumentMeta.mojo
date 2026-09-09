from std.collections import List, Optional, Span

from json import (
    Box,
    DecodeError,
    EncodeOptions,
    JsonDatum,
    WireReader,
    WireWriter,
    encoded_float_len,
    encoded_int_len,
    encoded_string_len,
    read_bool,
    read_float,
    read_float_list,
    read_int_list,
    read_string_list,
    write_float_list,
    write_int_list,
    write_string_list,
)

struct DocumentMeta(Copyable, Movable, Defaultable, Deinitable, JsonDatum):
    var region: String
    var version: Int64

    def __init__(out self):
        self.region = String()
        self.version = Int64(0)

    def __init__(out self, var region: String, var version: Int64):
        self.region = region^
        self.version = version^

    def encoded_len(self, options: EncodeOptions) -> Int:
        return self.encoded_len_at(options, 0)

    def encoded_len_at(self, options: EncodeOptions, depth: Int) -> Int:
        var pretty = options.mode == EncodeOptions.PRETTY
        var n = 1
        var first = True
        if pretty:
            n += 1 + (depth + 1) * options.indent
            if not first:
                n += 1
        elif not first:
            n += 1
        first = False
        n += 10
        if pretty:
            n += 1
        n += encoded_string_len(self.region)
        if pretty:
            n += 1 + (depth + 1) * options.indent
            if not first:
                n += 1
        elif not first:
            n += 1
        first = False
        n += 11
        if pretty:
            n += 1
        n += encoded_int_len(self.version)
        if pretty:
            n += 1 + depth * options.indent
        n += 1
        return n

    def encode_to(self, mut w: WireWriter, options: EncodeOptions):
        var pretty = options.mode == EncodeOptions.PRETTY
        w.write_byte(Byte(123))
        if pretty:
            w.pretty_depth += 1
        var first = True
        w.write_member_sep(options, first)
        first = False
        w.write_bytes("\"region\":".as_bytes())
        if pretty:
            w.write_byte(Byte(32))
        w.write_string(self.region)
        w.write_member_sep(options, first)
        first = False
        w.write_bytes("\"version\":".as_bytes())
        if pretty:
            w.write_byte(Byte(32))
        w.write_int(self.version)
        if pretty:
            w.pretty_depth -= 1
            w.write_byte(Byte(10))
            w.write_indent(options)
        w.write_byte(Byte(125))

    def _decode_expected[origin: ImmOrigin](mut self, mut r: WireReader[origin]) raises DecodeError -> Bool:
        if not r.try_eat_bytes("\"region\":".as_bytes()):
            return False
        self.region = r.read_string()
        if not r.try_eat_bytes(",\"version\":".as_bytes()):
            return False
        self.version = r.read_number().i
        if not r.try_eat_bytes("}".as_bytes()):
            return False
        return True

    def decode_from[origin: ImmOrigin](mut self, mut r: WireReader[origin]) raises DecodeError:
        r.eat(123)
        var saved = r.pos
        if self._decode_expected(r):
            return
        r.pos = saved
        if r.peek() == 125:
            r.eat(125)
            return
        while True:
            var key = r.read_string()
            r.eat(58)
            if key == "region":
                self.region = r.read_string()
            elif key == "version":
                self.version = r.read_number().i
            else:
                r.skip_value()
            var s = r.peek()
            if s == 125:
                r.eat(125)
                return
            if s != 44:
                raise DecodeError(DecodeError.KIND_SYNTAX, r.position())
            r.eat(44)
            if r.peek() == 125:
                raise DecodeError(DecodeError.KIND_SYNTAX, r.position())

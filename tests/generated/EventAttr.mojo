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
    read_bool_here,
    read_float,
    read_float_here,
    read_float_list,
    read_int_list,
    read_string_list,
    write_float_list,
    write_int_list,
    write_string_list,
)

struct EventAttr(Copyable, Movable, Defaultable, Deinitable, JsonDatum):
    var key: String
    var value: String

    def __init__(out self):
        self.key = String()
        self.value = String()

    def __init__(out self, var key: String, var value: String):
        self.key = key^
        self.value = value^

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
        n += 7
        if pretty:
            n += 1
        n += encoded_string_len(self.key)
        if pretty:
            n += 1 + (depth + 1) * options.indent
            if not first:
                n += 1
        elif not first:
            n += 1
        first = False
        n += 9
        if pretty:
            n += 1
        n += encoded_string_len(self.value)
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
        w.write_bytes("\"key\":".as_bytes())
        if pretty:
            w.write_byte(Byte(32))
        w.write_string(self.key)
        w.write_member_sep(options, first)
        first = False
        w.write_bytes("\"value\":".as_bytes())
        if pretty:
            w.write_byte(Byte(32))
        w.write_string(self.value)
        if pretty:
            w.pretty_depth -= 1
            w.write_byte(Byte(10))
            w.write_indent(options)
        w.write_byte(Byte(125))

    def _decode_expected[origin: ImmOrigin](mut self, mut r: WireReader[origin]) raises DecodeError -> Bool:
        if r.pos + 6 > len(r.data):
            return False
        if r.load_u32_at(0) != UInt32(2036689698):
            return False
        if Int(r.data[r.pos + 4]) != 34:
            return False
        if Int(r.data[r.pos + 5]) != 58:
            return False
        r.pos += 6
        self.key = r.read_string_here()
        if r.pos + 9 > len(r.data):
            return False
        if r.load_u64() != UInt64(2478516278289375788):
            return False
        if Int(r.data[r.pos + 8]) != 58:
            return False
        r.pos += 9
        self.value = r.read_string_here()
        if r.pos + 1 > len(r.data):
            return False
        if Int(r.data[r.pos + 0]) != 125:
            return False
        r.pos += 1
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
            if key == "key":
                self.key = r.read_string()
            elif key == "value":
                self.value = r.read_string()
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

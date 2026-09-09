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

struct LongList(Copyable, Movable, Defaultable, Deinitable, JsonDatum):
    var value: Int64
    var next: Optional[Int64]

    def __init__(out self):
        self.value = Int64(0)
        self.next = Optional[Int64]()

    def __init__(out self, var value: Int64, var next: Optional[Int64]):
        self.value = value^
        self.next = next^

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
        n += 9
        if pretty:
            n += 1
        n += encoded_int_len(self.value)
        if self.next:
            if pretty:
                n += 1 + (depth + 1) * options.indent
                if not first:
                    n += 1
            elif not first:
                n += 1
            first = False
            n += 8
            if pretty:
                n += 1
            n += encoded_int_len(self.next.value())
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
        w.write_bytes("\"value\":".as_bytes())
        if pretty:
            w.write_byte(Byte(32))
        w.write_int(self.value)
        if self.next:
            w.write_member_sep(options, first)
            first = False
            w.write_bytes("\"next\":".as_bytes())
            if pretty:
                w.write_byte(Byte(32))
            w.write_int(self.next.value())
        if pretty:
            w.pretty_depth -= 1
            w.write_byte(Byte(10))
            w.write_indent(options)
        w.write_byte(Byte(125))

    def _decode_expected[origin: ImmOrigin](mut self, mut r: WireReader[origin]) raises DecodeError -> Bool:
        if r.pos + 8 > len(r.data) or Int(r.data[r.pos + 0]) != 34 or Int(r.data[r.pos + 1]) != 118 or Int(r.data[r.pos + 2]) != 97 or Int(r.data[r.pos + 3]) != 108 or Int(r.data[r.pos + 4]) != 117 or Int(r.data[r.pos + 5]) != 101 or Int(r.data[r.pos + 6]) != 34 or Int(r.data[r.pos + 7]) != 58:
            return False
        r.pos += 8
        self.value = r.read_number_here().i
        if r.pos + 8 > len(r.data) or Int(r.data[r.pos + 0]) != 44 or Int(r.data[r.pos + 1]) != 34 or Int(r.data[r.pos + 2]) != 110 or Int(r.data[r.pos + 3]) != 101 or Int(r.data[r.pos + 4]) != 120 or Int(r.data[r.pos + 5]) != 116 or Int(r.data[r.pos + 6]) != 34 or Int(r.data[r.pos + 7]) != 58:
            return False
        r.pos += 8
        if r.peek() == 110:
            r.read_null()
            self.next = Optional[Int64]()
        else:
            var _o = Int64()
            _o.decode_from(r)
            self.next = Optional[Int64](_o^)
        if r.pos + 1 > len(r.data) or Int(r.data[r.pos + 0]) != 125:
            return False
        r.pos += 1
        return True

    def decode_from[origin: ImmOrigin](mut self, mut r: WireReader[origin]) raises DecodeError:
        r.eat(123)
        var saved = r.pos
        if self._decode_expected(r):
            return
        r.pos = saved
        self.next = Optional[Int64]()
        if r.peek() == 125:
            r.eat(125)
            return
        while True:
            var key = r.read_string()
            r.eat(58)
            if key == "value":
                self.value = r.read_number().i
            elif key == "next":
                if r.peek() == 110:
                    r.read_null()
                    self.next = Optional[Int64]()
                else:
                    var _o = Int64()
                    _o.decode_from(r)
                    self.next = Optional[Int64](_o^)
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

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

struct Document(Copyable, Movable, Defaultable, Deinitable, JsonDatum):
    var id: String
    var status: Int64
    var meta: DocumentMeta
    var items: List[DocumentItem]

    def __init__(out self):
        self.id = String()
        self.status = Int64(0)
        self.meta = DocumentMeta()
        self.items = List[DocumentItem]()

    def __init__(out self, var id: String, var status: Int64, var meta: DocumentMeta, var items: List[DocumentItem]):
        self.id = id^
        self.status = status^
        self.meta = meta^
        self.items = items^

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
        n += 6
        if pretty:
            n += 1
        n += encoded_string_len(self.id)
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
        n += encoded_int_len(self.status)
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
        n += self.meta.encoded_len_at(options, depth + 1)
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
        n += 2 + len(self.items) * 8
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
        w.write_bytes("\"id\":".as_bytes())
        if pretty:
            w.write_byte(Byte(32))
        w.write_string(self.id)
        w.write_member_sep(options, first)
        first = False
        w.write_bytes("\"status\":".as_bytes())
        if pretty:
            w.write_byte(Byte(32))
        w.write_int(self.status)
        w.write_member_sep(options, first)
        first = False
        w.write_bytes("\"meta\":".as_bytes())
        if pretty:
            w.write_byte(Byte(32))
        self.meta.encode_to(w, options)
        w.write_member_sep(options, first)
        first = False
        w.write_bytes("\"items\":".as_bytes())
        if pretty:
            w.write_byte(Byte(32))
        w.write_byte(Byte(91))
        var _i = 0
        while _i < len(self.items):
            w.write_member_sep(options, _i == 0)
            self.items[_i].encode_to(w, options)
            _i += 1
        if options.mode == EncodeOptions.PRETTY and len(self.items) > 0:
            w.write_byte(Byte(10))
            w.write_indent(options)
        w.write_byte(Byte(93))
        if pretty:
            w.pretty_depth -= 1
            w.write_byte(Byte(10))
            w.write_indent(options)
        w.write_byte(Byte(125))

    def _decode_expected[origin: ImmOrigin](mut self, mut r: WireReader[origin]) raises DecodeError -> Bool:
        if r.pos + 5 > len(r.data) or Int(r.data[r.pos + 0]) != 34 or Int(r.data[r.pos + 1]) != 105 or Int(r.data[r.pos + 2]) != 100 or Int(r.data[r.pos + 3]) != 34 or Int(r.data[r.pos + 4]) != 58:
            return False
        r.pos += 5
        self.id = r.read_string_here()
        if r.pos + 10 > len(r.data) or Int(r.data[r.pos + 0]) != 44 or Int(r.data[r.pos + 1]) != 34 or Int(r.data[r.pos + 2]) != 115 or Int(r.data[r.pos + 3]) != 116 or Int(r.data[r.pos + 4]) != 97 or Int(r.data[r.pos + 5]) != 116 or Int(r.data[r.pos + 6]) != 117 or Int(r.data[r.pos + 7]) != 115 or Int(r.data[r.pos + 8]) != 34 or Int(r.data[r.pos + 9]) != 58:
            return False
        r.pos += 10
        self.status = r.read_number_here().i
        if r.pos + 8 > len(r.data) or Int(r.data[r.pos + 0]) != 44 or Int(r.data[r.pos + 1]) != 34 or Int(r.data[r.pos + 2]) != 109 or Int(r.data[r.pos + 3]) != 101 or Int(r.data[r.pos + 4]) != 116 or Int(r.data[r.pos + 5]) != 97 or Int(r.data[r.pos + 6]) != 34 or Int(r.data[r.pos + 7]) != 58:
            return False
        r.pos += 8
        var _c = DocumentMeta()
        _c.decode_from(r)
        self.meta = _c^
        if r.pos + 9 > len(r.data) or Int(r.data[r.pos + 0]) != 44 or Int(r.data[r.pos + 1]) != 34 or Int(r.data[r.pos + 2]) != 105 or Int(r.data[r.pos + 3]) != 116 or Int(r.data[r.pos + 4]) != 101 or Int(r.data[r.pos + 5]) != 109 or Int(r.data[r.pos + 6]) != 115 or Int(r.data[r.pos + 7]) != 34 or Int(r.data[r.pos + 8]) != 58:
            return False
        r.pos += 9
        self.items = List[DocumentItem]()
        r.eat(91)
        if r.peek() != 93:
            while True:
                var _el = DocumentItem()
                _el.decode_from(r)
                self.items.append(_el^)
                var _s = r.peek()
                if _s == 93:
                    r.eat(93)
                    break
                if _s != 44:
                    raise DecodeError(DecodeError.KIND_SYNTAX, r.position())
                r.eat(44)
        else:
            r.eat(93)
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
        if r.peek() == 125:
            r.eat(125)
            return
        while True:
            var key = r.read_string()
            r.eat(58)
            if key == "id":
                self.id = r.read_string()
            elif key == "status":
                self.status = r.read_number().i
            elif key == "meta":
                var _c = DocumentMeta()
                _c.decode_from(r)
                self.meta = _c^
            elif key == "items":
                self.items = List[DocumentItem]()
                r.eat(91)
                if r.peek() != 93:
                    while True:
                        var _el = DocumentItem()
                        _el.decode_from(r)
                        self.items.append(_el^)
                        var _s = r.peek()
                        if _s == 93:
                            r.eat(93)
                            break
                        if _s != 44:
                            raise DecodeError(DecodeError.KIND_SYNTAX, r.position())
                        r.eat(44)
                else:
                    r.eat(93)
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

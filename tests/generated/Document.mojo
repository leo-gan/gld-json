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
        w.write_bytes(String("\"id\":").as_bytes())
        if pretty:
            w.write_byte(Byte(32))
        w.write_string(self.id)
        w.write_member_sep(options, first)
        first = False
        w.write_bytes(String("\"status\":").as_bytes())
        if pretty:
            w.write_byte(Byte(32))
        w.write_int(self.status)
        w.write_member_sep(options, first)
        first = False
        w.write_bytes(String("\"meta\":").as_bytes())
        if pretty:
            w.write_byte(Byte(32))
        self.meta.encode_to(w, options)
        w.write_member_sep(options, first)
        first = False
        w.write_bytes(String("\"items\":").as_bytes())
        if pretty:
            w.write_byte(Byte(32))
        w.write_byte(Byte(91))
        w.write_byte(Byte(93))
        if pretty:
            w.pretty_depth -= 1
            w.write_byte(Byte(10))
            w.write_indent(options)
        w.write_byte(Byte(125))

    def decode_from[origin: ImmOrigin](mut self, mut r: WireReader[origin]) raises DecodeError:
        r.eat(123)
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
                r.skip_value()
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

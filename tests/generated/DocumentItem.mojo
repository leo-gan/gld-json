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

struct DocumentItem(Copyable, Movable, Defaultable, Deinitable, JsonDatum):
    var sku: String
    var qty: Int64
    var price_minor: Int64

    def __init__(out self):
        self.sku = String()
        self.qty = Int64(0)
        self.price_minor = Int64(0)

    def __init__(out self, var sku: String, var qty: Int64, var price_minor: Int64):
        self.sku = sku^
        self.qty = qty^
        self.price_minor = price_minor^

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
        n += encoded_string_len(self.sku)
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
        n += encoded_int_len(self.qty)
        if pretty:
            n += 1 + (depth + 1) * options.indent
            if not first:
                n += 1
        elif not first:
            n += 1
        first = False
        n += 15
        if pretty:
            n += 1
        n += encoded_int_len(self.price_minor)
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
        w.write_bytes(String("\"sku\":").as_bytes())
        if pretty:
            w.write_byte(Byte(32))
        w.write_string(self.sku)
        w.write_member_sep(options, first)
        first = False
        w.write_bytes(String("\"qty\":").as_bytes())
        if pretty:
            w.write_byte(Byte(32))
        w.write_int(self.qty)
        w.write_member_sep(options, first)
        first = False
        w.write_bytes(String("\"price_minor\":").as_bytes())
        if pretty:
            w.write_byte(Byte(32))
        w.write_int(self.price_minor)
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
            if key == "sku":
                self.sku = r.read_string()
            elif key == "qty":
                self.qty = r.read_number().i
            elif key == "price_minor":
                self.price_minor = r.read_number().i
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

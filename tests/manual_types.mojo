from std.collections import List, Optional, Span

from json import (
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


struct Message(Copyable, Movable, Defaultable, Deinitable, JsonDatum):
    var f_bool: Bool
    var f_int32: Int64
    var f_int64: Int64
    var f_float64: Float64
    var f_string: String
    var f_bool_2: Bool
    var f_int32_2: Int64
    var f_string_2: String

    def __init__(out self):
        self.f_bool = False
        self.f_int32 = Int64(0)
        self.f_int64 = Int64(0)
        self.f_float64 = 0.0
        self.f_string = String()
        self.f_bool_2 = False
        self.f_int32_2 = Int64(0)
        self.f_string_2 = String()

    def encoded_len(self, options: EncodeOptions) -> Int:
        return self.encoded_len_at(options, 0)

    def encoded_len_at(self, options: EncodeOptions, depth: Int) -> Int:
        var n = 1
        n += encoded_string_len(String("f_bool")) + 1 + 5
        n += 1 + encoded_string_len(String("f_int32")) + 1 + encoded_int_len(self.f_int32)
        n += 1 + encoded_string_len(String("f_int64")) + 1 + encoded_int_len(self.f_int64)
        n += 1 + encoded_string_len(String("f_float64")) + 1 + encoded_float_len(self.f_float64)
        n += 1 + encoded_string_len(String("f_string")) + 1 + encoded_string_len(self.f_string)
        n += 1 + encoded_string_len(String("f_bool_2")) + 1 + 5
        n += 1 + encoded_string_len(String("f_int32_2")) + 1 + encoded_int_len(self.f_int32_2)
        n += 1 + encoded_string_len(String("f_string_2")) + 1 + encoded_string_len(self.f_string_2)
        n += 1
        _ = options
        _ = depth
        return n

    def encode_to(self, mut w: WireWriter, options: EncodeOptions):
        w.write_byte(Byte(123))
        var first = True
        w.write_member_sep(options, first)
        first = False
        w.write_bytes(String("\"f_bool\":").as_bytes())
        if options.mode == EncodeOptions.PRETTY:
            w.write_byte(Byte(32))
        w.write_bool(self.f_bool)
        w.write_member_sep(options, first)
        w.write_bytes(String("\"f_int32\":").as_bytes())
        if options.mode == EncodeOptions.PRETTY:
            w.write_byte(Byte(32))
        w.write_int(self.f_int32)
        w.write_member_sep(options, first)
        w.write_bytes(String("\"f_int64\":").as_bytes())
        if options.mode == EncodeOptions.PRETTY:
            w.write_byte(Byte(32))
        w.write_int(self.f_int64)
        w.write_member_sep(options, first)
        w.write_bytes(String("\"f_float64\":").as_bytes())
        if options.mode == EncodeOptions.PRETTY:
            w.write_byte(Byte(32))
        w.write_float(self.f_float64)
        w.write_member_sep(options, first)
        w.write_bytes(String("\"f_string\":").as_bytes())
        if options.mode == EncodeOptions.PRETTY:
            w.write_byte(Byte(32))
        w.write_string(self.f_string)
        w.write_member_sep(options, first)
        w.write_bytes(String("\"f_bool_2\":").as_bytes())
        if options.mode == EncodeOptions.PRETTY:
            w.write_byte(Byte(32))
        w.write_bool(self.f_bool_2)
        w.write_member_sep(options, first)
        w.write_bytes(String("\"f_int32_2\":").as_bytes())
        if options.mode == EncodeOptions.PRETTY:
            w.write_byte(Byte(32))
        w.write_int(self.f_int32_2)
        w.write_member_sep(options, first)
        w.write_bytes(String("\"f_string_2\":").as_bytes())
        if options.mode == EncodeOptions.PRETTY:
            w.write_byte(Byte(32))
        w.write_string(self.f_string_2)
        if options.mode == EncodeOptions.PRETTY:
            w.write_byte(Byte(10))
        w.write_byte(Byte(125))

    def decode_from[origin: ImmOrigin](mut self, mut r: WireReader[origin]) raises DecodeError:
        r.eat(123)
        if r.peek() == 125:
            r.eat(125)
            return
        while True:
            var key = r.read_string()
            r.eat(58)
            if key == "f_bool":
                self.f_bool = read_bool(r)
            elif key == "f_int32":
                self.f_int32 = r.read_number().i
            elif key == "f_int64":
                self.f_int64 = r.read_number().i
            elif key == "f_float64":
                self.f_float64 = read_float(r)
            elif key == "f_string":
                self.f_string = r.read_string()
            elif key == "f_bool_2":
                self.f_bool_2 = read_bool(r)
            elif key == "f_int32_2":
                self.f_int32_2 = r.read_number().i
            elif key == "f_string_2":
                self.f_string_2 = r.read_string()
            else:
                r.skip_value()
            var s = r.peek()
            if s == 125:
                r.eat(125)
                return
            if s != 44:
                raise DecodeError(DecodeError.KIND_SYNTAX, r.position())
            r.eat(44)

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

struct Pet(Copyable, Movable, Defaultable, Deinitable, JsonDatum):
    var tag: Int
    var v0: Pet0
    var v1: Pet1

    def __init__(out self):
        self.tag = 0
        self.v0 = Pet0()
        self.v1 = Pet1()

    def encoded_len(self, options: EncodeOptions) -> Int:
        if self.tag == 0:
            return self.v0.encoded_len(options)
        if self.tag == 1:
            return self.v1.encoded_len(options)
        return 2

    def encode_to(self, mut w: WireWriter, options: EncodeOptions):
        if self.tag == 0:
            self.v0.encode_to(w, options)
            return
        if self.tag == 1:
            self.v1.encode_to(w, options)
            return

    def decode_from[origin: ImmOrigin](mut self, mut r: WireReader[origin]) raises DecodeError:
        r.skip_value()

from std.collections import List, Span

from runtime.error import DecodeError
from runtime.options import DecodeOptions, EncodeOptions
from runtime.value import JsonValue, decode_value, encode_value
from wire.number import encoded_float_len, encoded_int_len
from wire.reader import WireReader
from wire.string import encoded_string_len
from wire.writer import WireWriter


trait JsonDatum(Copyable, Movable, Defaultable, Deinitable):
    def encoded_len(self, options: EncodeOptions) -> Int:
        ...

    def encode_to(self, mut w: WireWriter, options: EncodeOptions):
        ...

    def decode_from[
        origin: ImmOrigin
    ](mut self, mut r: WireReader[origin]) raises DecodeError:
        ...


def encode[
    T: JsonDatum
](value: T, options: EncodeOptions = EncodeOptions.compact) -> List[Byte]:
    var cap = value.encoded_len(options)
    if cap < 1:
        cap = 1
    var w = WireWriter(capacity=cap, exact=True)
    value.encode_to(w, options)
    return w^.finish()


def encode_into[
    T: JsonDatum
](
    value: T, mut dest: List[Byte], options: EncodeOptions = EncodeOptions.compact
) -> Int:
    """Write into `dest`, reusing its allocation. Returns the byte count."""
    var cap = value.encoded_len(options)
    if cap < 1:
        cap = 1
    dest.resize(unsafe_uninit_length=cap)
    var w = WireWriter(dest^, pos=0)
    value.encode_to(w, options)
    var n = w.pos
    dest = w^.finish()
    return n


def decode[
    T: JsonDatum, origin: ImmOrigin
](
    buf: Span[Byte, origin], options: DecodeOptions = DecodeOptions.default
) raises DecodeError -> T:
    var msg = T()
    var r = WireReader[origin](buf, options)
    msg.decode_from(r)
    r.skip_ws()
    if r.remaining() > 0:
        raise DecodeError(DecodeError.KIND_TRAILING, r.position())
    return msg^


def to_value[T: JsonDatum](value: T) raises DecodeError -> JsonValue:
    return decode_value(encode(value))


def from_value[T: JsonDatum](v: JsonValue) raises DecodeError -> T:
    return decode[T](encode_value(v))


def read_bool[origin: ImmOrigin](mut r: WireReader[origin]) raises DecodeError -> Bool:
    var c = r.peek()
    if c == 116:
        r.read_true()
        return True
    if c == 102:
        r.read_false()
        return False
    raise DecodeError(DecodeError.KIND_TYPE, r.position())


def read_float[origin: ImmOrigin](mut r: WireReader[origin]) raises DecodeError -> Float64:
    var tok = r.read_number()
    if tok.is_int:
        return Float64(tok.i)
    return tok.f

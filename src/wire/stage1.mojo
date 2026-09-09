from std.collections import List, Span

from runtime.error import DecodeError
from runtime.options import DecodeOptions


def ensure_index[
    origin: ImmOrigin
](data: Span[Byte, origin], mut positions: List[UInt32]) raises DecodeError:
    """Structural index. Empty until the speed pass fills it."""
    _ = data
    _ = positions
    _ = DecodeOptions.default

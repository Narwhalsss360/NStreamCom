const sizing = @import("sizing.zig");
const nsize_int = sizing.nsize_int;

pub const DecoderError = error {
    NoBuffer,
    BufferFull,
    InvalidDecoderState
};

pub const Decoder = struct {
    buffer: ?[]u8 = null,
    position: u32 = 0,
    right_shift: u3 = 0,

    pub fn use(self: *Decoder, buffer: []u8) void {
        self.buffer = buffer;
    }

    pub fn reset(self: *Decoder) void {
        self.position = 0;
        self.rigt_shift = 0;
    }

    pub fn next(self: *Decoder, byte: u8, is_last: bool) DecoderError!void {
        if (self.buffer == null) {
            return DecoderError.NoBuffer;
        }

        if (!is_last) {
            if (self.position == self.buffer.?.len) {
                return DecoderError.BufferFull;
            }
            self.buffer.?[self.position] = byte >> self.right_shift;
        }

        if (self.right_shift != 0) {
            if (self.position == 0) {
                return DecoderError.InvalidDecoderState;
            }

            self.buffer.?[self.position - 1] |= byte << @intCast((8 - @as(u4, self.right_shift)));
        }

        if (self.right_shift == 7) {
            self.right_shift = 0;
        } else {
            self.right_shift += 1;
            self.position += 1;
        }
    }
};


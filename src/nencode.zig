pub fn encode(data: []const u8, encoded: []u8) void {
    var di: u32 = 0;
    var ei: u32 = 0;
    var left_shift: u8 = 7;
    var previous_stuffed: u8 = undefined;

    while (di < data.len and ei < encoded.len) : (ei += 1) {
        left_shift = if (left_shift == 7) 0 else left_shift + 1;
        previous_stuffed = 8 - left_shift;

        if (left_shift == 0) {
            encoded[ei] = data[di];
        } else {
            encoded[ei] = data[di] >> @intCast(previous_stuffed);
            di += 1;

            if (di < data.len) {
                encoded[ei] |= data[di] << @intCast(left_shift);
            }
        }

        encoded[ei] &= ~(@as(u8, 0xFF) << 7);
    }
}

pub fn decode(encoded: []const u8, decoded: []u8) void {
    var ei: u32 = 0;
    var di: u32 = 0;
    var right_shift: u8 = 6;
    var left_next: u8 = undefined;

    while (ei < encoded.len and di < decoded.len) : (di += 1) {
        right_shift = if (right_shift == 6) 0 else right_shift + 1;
        left_next = 7 - right_shift;

        if (di != 0 and right_shift == 0) {
            ei += 1;
        }

        decoded[di] = (encoded[ei] & ~(@as(u8, 0xFF) << 7)) >> @intCast(right_shift);
        ei += 1;
        if (ei < encoded.len) {
            decoded[di] |= (encoded[ei] & ~(@as(u8, 0xFF) << 7)) << @intCast(left_next);
        }
    }
}

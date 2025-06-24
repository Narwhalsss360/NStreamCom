const asBytes = @import("std").mem.asBytes;
const sizing = @import("sizing.zig");
const nsize_int = sizing.nsize_int;
const encoded_nsize_int = sizing.encoded_nsize_int;
const nsize_int_byte_count = sizing.nsize_int_byte_count;
const encoded_nsize_int_byte_count = sizing.encoded_nsize_int_byte_count;

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
            if (ei == encoded.len) {
                break;
            }
        }

        decoded[di] = (encoded[ei] & ~(@as(u8, 0xFF) << 7)) >> @intCast(right_shift);
        ei += 1;
        if (ei < encoded.len) {
            decoded[di] |= (encoded[ei] & ~(@as(u8, 0xFF) << 7)) << @intCast(left_next);
        }
    }
}

pub fn encodeSize(size: nsize_int) encoded_nsize_int {
    var encoded_size: encoded_nsize_int = undefined;
    var encoded_size_as_bytes: []u8 = asBytes(&encoded_size);
    encode(asBytes(&size)[0..nsize_int_byte_count], encoded_size_as_bytes[0..encoded_nsize_int_byte_count]);
    for (0..encoded_nsize_int_byte_count) |i| {
        encoded_size_as_bytes[i] |= 1 << 7;
    }
    return encoded_size;
}

pub fn decodeSize(size: encoded_nsize_int) nsize_int {
    var mutsize = size;
    var encoded_size_as_bytes: []u8 = asBytes(&mutsize);
    for (0..encoded_nsize_int_byte_count) |i| {
        encoded_size_as_bytes[i] &= ~(@as(u8, 1) << 7);
    }
    var decoded_size: nsize_int = undefined;
    decode(encoded_size_as_bytes[0..encoded_nsize_int_byte_count], asBytes(&decoded_size)[0..nsize_int_byte_count]);
    return decoded_size;
}

pub fn encodeWithSize(data: []const u8, encoded: []u8) void {
    encode(data, encoded[encoded_nsize_int_byte_count..]);
    const encoded_size: encoded_nsize_int = encodeSize(@intCast(data.len));
    const encoded_size_as_bytes: []const u8 = asBytes(&encoded_size);

    for (0..encoded_nsize_int_byte_count) |i| {
        encoded[i] = encoded_size_as_bytes[i];
    }
}

pub const nsize_int = u32;

pub const nsize_int_byte_count = @bitSizeOf(nsize_int) / 8;

pub const encoded_nsize_int = u40;

pub const encoded_nsize_int_byte_count = @bitSizeOf(encoded_nsize_int) / 8;

pub const nsize_int_max = (32 + 7 - 1) / 7;

pub fn asTransmissionSize(size: nsize_int) nsize_int {
    return (size * 8 + 7 - 1) / 7;
}

pub fn asDataSize(size: nsize_int) nsize_int {
    return size * 7 / 8;
}


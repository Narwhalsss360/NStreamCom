const nsize_int = u32;

const nsize_int_bit_size = 32;

const nsize_int_max = (32 + 7 - 1) / 7;

pub fn asTransmissionSize(size: nsize_int) nsize_int {
    return (size * 8 + 7 - 1) / 7;
}

pub fn asDataSize(size: nsize_int) nsize_int {
    return size * 7 / 8;
}


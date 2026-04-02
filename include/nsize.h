#pragma once

#include <stdint.h>

namespace nstreamcom {
    using nsize_int = uint32_t;

    constexpr const nsize_int STUFFED_BITS = 1;

    constexpr const nsize_int DATA_BITS = 8 - STUFFED_BITS;

    constexpr const nsize_int ENCODED_NSIZE_SIZE = ((sizeof(nsize_int) * 8) + DATA_BITS - 1) / DATA_BITS;

    constexpr const nsize_int MAX_DATA_SIZE = UINT32_MAX * DATA_BITS / 8;

    constexpr nsize_int as_transmission_size(const nsize_int& data_size) {
        return ((data_size * 8) + DATA_BITS - 1) / DATA_BITS;
    }

    constexpr nsize_int as_collected_size(const nsize_int& data_size) {
        return as_transmission_size(data_size) + ENCODED_NSIZE_SIZE;
    }

    constexpr nsize_int as_data_size(const nsize_int& transmission_size) {
        return transmission_size * DATA_BITS / 8;
    }

    struct nsize {
        using nsize_int_bytes = uint8_t[ENCODED_NSIZE_SIZE];

        union {
            nsize_int as_int;
            nsize_int_bytes bytes;
        };

        nsize(const nsize_int& size = 0);

        nsize(const nsize_int_bytes& bytes);

        operator nsize_int&();

        operator const nsize_int&() const;

        nsize& operator=(const nsize_int& other);

        nsize_int_bytes& operator=(const nsize_int_bytes& bytes);

        bool encoded() const;

        nsize_int_bytes& encode();

        nsize_int& decode();

    protected:
        bool _is_encoded;

        void fill_trail();
    };
}

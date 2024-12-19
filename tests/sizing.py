from nstreamcom import encode_size, decode_size, DATA_BITS


def main() -> None:
    sizes: list[int] = [
        0,
        1,
        4 * 8,
        9 * DATA_BITS,
    ]
    
    for size in sizes:
        assert decode_size(encode_size(size)) == size, f'{size=}'

    print('Success')


if __name__ == '__main__':
    main()


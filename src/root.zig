const std = @import("std");

pub const sizing = @import("sizing.zig");
pub const nsize_int = sizing.nsize_int;
pub const encoded_nsize_int = sizing.encoded_nsize_int;
pub const asTransmissionSize = sizing.asTransmissionSize;
pub const asCollectedSize = sizing.asCollectedSize;
pub const asDataSize = sizing.asDataSize;

pub const nencode = @import("nencode.zig");
pub const encode = nencode.encode;
pub const decode = nencode.decode;
pub const encodeWithSize = nencode.encodeWithSize;

pub const buffered_decoder = @import("buffered_decoder.zig");
pub const DecoderError = buffered_decoder.DecoderError;
pub const Decoder = buffered_decoder.Decoder;

pub const collector = @import("collector.zig");
pub const CollectorState = collector.CollectorState;
pub const CollectorError = collector.CollectorError;
pub const Collector = collector.Collector;

test "sizing" {
    const print = std.debug.print;
    print("Test: sizing\n", .{});

    const data_sizes = [_]u8 {0, 1, 2, 8, 10, 11};
    const expected_encoded_sizes = [_]u8{0, 2, 3, 10, 12, 13};
    try std.testing.expect(data_sizes.len == expected_encoded_sizes.len);

    for (data_sizes, expected_encoded_sizes) |data_size, expected_encoded_size| {
        try std.testing.expect(sizing.asTransmissionSize(data_size) == expected_encoded_size);
        try std.testing.expect(sizing.asDataSize(expected_encoded_size) == data_size);
    }
}

test "nencode" {
    const print = std.debug.print;
    print("Test: nencode\n", .{});

    {
        const data = [_]u8 {};
        var encoded: [sizing.asTransmissionSize(data.len)]u8 = undefined;
        const expected_encoded = [_]u8 {};
        var decoded: [data.len]u8 = undefined;

        nencode.encode(&data, &encoded);
        nencode.decode(&encoded, &decoded);

        printSlice(u8, "{d}", &data);
        printSlice(u8, "{d}", &encoded);
        print("\n", .{});
        printSlice(u8, "{d}", &decoded);
        print("\n", .{});

        try std.testing.expect(std.mem.eql(u8, &encoded, &expected_encoded));
        try std.testing.expect(std.mem.eql(u8, &decoded, &data));
    }
    {
        const data = [_]u8 {1, 2, 3};
        var encoded: [sizing.asTransmissionSize(data.len)]u8 = undefined;
        const expected_encoded = [_]u8 {1, 4, 12, 0};
        var decoded: [data.len]u8 = undefined;

        nencode.encode(&data, &encoded);
        nencode.decode(&encoded, &decoded);

        printSlice(u8, "{d}", &data);
        printSlice(u8, "{d}", &encoded);
        print("\n", .{});
        printSlice(u8, "{d}", &decoded);
        print("\n", .{});

        try std.testing.expect(std.mem.eql(u8, &encoded, &expected_encoded));
        try std.testing.expect(std.mem.eql(u8, &decoded, &data));
    }
    {
        const data = [_]u8 {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
        var encoded: [sizing.asTransmissionSize(data.len)]u8 = undefined;
        const expected_encoded = [_]u8 {1, 4, 12, 32, 80, 64, 65, 3, 8, 18, 40, 0};
        var decoded: [data.len]u8 = undefined;

        nencode.encode(&data, &encoded);
        nencode.decode(&encoded, &decoded);

        printSlice(u8, "{d}", &data);
        printSlice(u8, "{d}", &encoded);
        print("\n", .{});
        printSlice(u8, "{d}", &decoded);
        print("\n", .{});

        try std.testing.expect(std.mem.eql(u8, &encoded, &expected_encoded));
        try std.testing.expect(std.mem.eql(u8, &decoded, &data));
    }
    {
        const data = [_]u8 {200, 101, 155, 80, 23, 95, 33, 57, 59};
        var encoded: [sizing.asTransmissionSize(data.len)]u8 = undefined;
        const expected_encoded = [_]u8 {72, 75, 109, 4, 117, 98, 87, 16, 57, 118, 0};
        var decoded: [data.len]u8 = undefined;

        nencode.encode(&data, &encoded);
        nencode.decode(&encoded, &decoded);

        printSlice(u8, "{d}", &data);
        printSlice(u8, "{d}", &encoded);
        print("\n", .{});
        printSlice(u8, "{d}", &decoded);
        print("\n", .{});

        try std.testing.expect(std.mem.eql(u8, &encoded, &expected_encoded));
        try std.testing.expect(std.mem.eql(u8, &decoded, &data));
    }
}

test "sizing encoding" {
    const print = std.debug.print;
    print("Test: sizing encoding\n", .{});

    const data_sizes = [_]sizing.nsize_int {0, 1, 2, 8, 9, 128, 129};
    const expected_encoded_sizes = [_]sizing.encoded_nsize_int {551911719040, 551911719041, 551911719042, 551911719048, 551911719049, 551911719296, 551911719297};
    for (data_sizes, expected_encoded_sizes) |data_size, expected_encoded_size| {
        //try printSlice(u8, "{d}", std.mem.asBytes(&nencode.encodeSize(data_size)));
        //_ = try std.io.getStdOut().write("\n");
        const encoded_size = nencode.encodeSize(data_size);
        const decoded_size = nencode.decodeSize(expected_encoded_size);
        print("{d}, {d}\n>{d}\n", .{data_size, expected_encoded_size, decoded_size});
        try std.testing.expect(encoded_size == expected_encoded_size);
        try std.testing.expect(decoded_size == data_size);
    }
}

test "decoder" {
    const print = std.debug.print;
    print("Test: decoder\n", .{});

    {
        const data = [_]u8 {};
        var encoded: [sizing.asTransmissionSize(data.len)]u8 = undefined;
        const expected_encoded = [_]u8 {};
        var decoded: [data.len]u8 = undefined;

        nencode.encode(&data, &encoded);
        var decoder = buffered_decoder.Decoder { .buffer = &decoded };
        for (encoded, 0..) |byte, i| {
            decoder.next(byte, i == encoded.len - 1) catch try std.testing.expect(false);
        }

        printSlice(u8, "{d}", &data);
        printSlice(u8, "{d}", &encoded);
        print("\n", .{});
        printSlice(u8, "{d}", &decoded);
        print("\n", .{});

        try std.testing.expect(std.mem.eql(u8, &encoded, &expected_encoded));
        try std.testing.expect(std.mem.eql(u8, &decoded, &data));
    }
    {
        const data = [_]u8 {1, 2, 3};
        var encoded: [sizing.asTransmissionSize(data.len)]u8 = undefined;
        const expected_encoded = [_]u8 {1, 4, 12, 0};
        var decoded: [data.len]u8 = undefined;

        nencode.encode(&data, &encoded);
        var decoder = buffered_decoder.Decoder { .buffer = &decoded };
        for (encoded, 0..) |byte, i| {
            decoder.next(byte, i == encoded.len - 1) catch try std.testing.expect(false);
        }

        printSlice(u8, "{d}", &data);
        printSlice(u8, "{d}", &encoded);
        print("\n", .{});
        printSlice(u8, "{d}", &decoded);
        print("\n", .{});

        try std.testing.expect(std.mem.eql(u8, &encoded, &expected_encoded));
        try std.testing.expect(std.mem.eql(u8, &decoded, &data));
    }
    {
        const data = [_]u8 {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
        var encoded: [sizing.asTransmissionSize(data.len)]u8 = undefined;
        const expected_encoded = [_]u8 {1, 4, 12, 32, 80, 64, 65, 3, 8, 18, 40, 0};
        var decoded: [data.len]u8 = undefined;

        nencode.encode(&data, &encoded);
        var decoder = buffered_decoder.Decoder { .buffer = &decoded };
        for (encoded, 0..) |byte, i| {
            decoder.next(byte, i == encoded.len - 1) catch try std.testing.expect(false);
        }

        printSlice(u8, "{d}", &data);
        printSlice(u8, "{d}", &encoded);
        print("\n", .{});
        printSlice(u8, "{d}", &decoded);
        print("\n", .{});

        try std.testing.expect(std.mem.eql(u8, &encoded, &expected_encoded));
        try std.testing.expect(std.mem.eql(u8, &decoded, &data));
    }
    {
        const data = [_]u8 {200, 101, 155, 80, 23, 95, 33, 57, 59};
        var encoded: [sizing.asTransmissionSize(data.len)]u8 = undefined;
        const expected_encoded = [_]u8 {72, 75, 109, 4, 117, 98, 87, 16, 57, 118, 0};
        var decoded: [data.len]u8 = undefined;

        nencode.encode(&data, &encoded);
        var decoder = buffered_decoder.Decoder { .buffer = &decoded };
        for (encoded, 0..) |byte, i| {
            decoder.next(byte, i == encoded.len - 1) catch try std.testing.expect(false);
        }

        printSlice(u8, "{d}", &data);
        printSlice(u8, "{d}", &encoded);
        print("\n", .{});
        printSlice(u8, "{d}", &decoded);
        print("\n", .{});

        try std.testing.expect(std.mem.eql(u8, &encoded, &expected_encoded));
        try std.testing.expect(std.mem.eql(u8, &decoded, &data));
    }
}

test "collector" {
    const print = std.debug.print;
    print("Test: collector\n", .{});

    {
        const data = [_]u8 {};
        var encoded: [sizing.asCollectedSize(data.len)]u8 = undefined;
        const expected_encoded = [_]u8 {128, 128, 128, 128, 128};
        var decoded: [sizing.asCollectedSize(data.len)]u8 = undefined;

        nencode.encodeWithSize(&data, &encoded);

        var decoder = buffered_decoder.Decoder { .buffer = &decoded };
        var _collector = collector.Collector { .decoder = &decoder };
        for (encoded) |byte| {
            _collector.collect(byte) catch try std.testing.expect(false);
            try std.testing.expect(!_collector.errorState());
        }
        try std.testing.expect(_collector.state == collector.CollectorState.Collected);

        printSlice(u8, "{d}", &data);
        printSlice(u8, "{d}", &encoded);
        print("\n", .{});
        printSlice(u8, "{d}", decoded[0.._collector.next_size]);
        print("\n", .{});

        try std.testing.expect(std.mem.eql(u8, &encoded, &expected_encoded));
        try std.testing.expect(std.mem.eql(u8, decoded[0.._collector.next_size], &data));
    }
    {
        const data = [_]u8 {1, 2, 3};
        var encoded: [sizing.asCollectedSize(data.len)]u8 = undefined;
        const expected_encoded = [_]u8 {131, 128, 128, 128, 128, 1, 4, 12, 0};
        var decoded: [sizing.asCollectedSize(data.len)]u8 = undefined;

        nencode.encodeWithSize(&data, &encoded);

        var decoder = buffered_decoder.Decoder { .buffer = &decoded };
        var _collector = collector.Collector { .decoder = &decoder };
        for (encoded) |byte| {
            _collector.collect(byte) catch try std.testing.expect(false);
            try std.testing.expect(!_collector.errorState());
        }
        try std.testing.expect(_collector.state == collector.CollectorState.Collected);

        printSlice(u8, "{d}", &data);
        printSlice(u8, "{d}", &encoded);
        print("\n", .{});
        printSlice(u8, "{d}", decoded[0.._collector.next_size]);
        print("\n", .{});

        try std.testing.expect(std.mem.eql(u8, &encoded, &expected_encoded));
        try std.testing.expect(std.mem.eql(u8, decoded[0.._collector.next_size], &data));
    }
    {
        const data = [_]u8 {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
        var encoded: [sizing.asCollectedSize(data.len)]u8 = undefined;
        const expected_encoded = [_]u8 {138, 128, 128, 128, 128, 1, 4, 12, 32, 80, 64, 65, 3, 8, 18, 40, 0};
        var decoded: [sizing.asCollectedSize(data.len)]u8 = undefined;

        nencode.encodeWithSize(&data, &encoded);

        var decoder = buffered_decoder.Decoder { .buffer = &decoded };
        var _collector = collector.Collector { .decoder = &decoder };
        for (encoded) |byte| {
            _collector.collect(byte) catch try std.testing.expect(false);
            try std.testing.expect(!_collector.errorState());
        }
        try std.testing.expect(_collector.state == collector.CollectorState.Collected);

        printSlice(u8, "{d}", &data);
        printSlice(u8, "{d}", &encoded);
        print("\n", .{});
        printSlice(u8, "{d}", decoded[0.._collector.next_size]);
        print("\n", .{});

        try std.testing.expect(std.mem.eql(u8, &encoded, &expected_encoded));
        try std.testing.expect(std.mem.eql(u8, decoded[0.._collector.next_size], &data));
    }
}

pub fn printSlice(comptime T: type, comptime fmt: []const u8, slice: []const T) void {
    const print = std.debug.print;

    print("[", .{});
    defer print("]", .{});

    for (slice, 0..) |element, i| {
        print(fmt, .{element});
        if (i != slice.len - 1) {
            print(", ", .{});
        }
    }
}

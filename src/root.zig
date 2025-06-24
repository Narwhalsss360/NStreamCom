const std = @import("std");
const sizing = @import("sizing.zig");
const nencode = @import("nencode.zig");

test "sizing" {
    const data_sizes = [_]u8 {0, 1, 2, 8, 10, 11};
    const expected_encoded_sizes = [_]u8{0, 2, 3, 10, 12, 13};
    try std.testing.expect(data_sizes.len == expected_encoded_sizes.len);

    for (data_sizes, expected_encoded_sizes) |data_size, expected_encoded_size| {
        try std.testing.expect(sizing.asTransmissionSize(data_size) == expected_encoded_size);
        try std.testing.expect(sizing.asDataSize(expected_encoded_size) == data_size);
    }
}

test "nencode" {
    {
        const data = [_]u8 {};
        var encoded: [sizing.asTransmissionSize(data.len)]u8 = undefined;
        const expected_encoded = [_]u8 {};
        var decoded: [data.len]u8 = undefined;

        nencode.encode(&data, &encoded);
        nencode.decode(&encoded, &decoded);
        try printSlice(u8, "{d}", &data);
        try printSlice(u8, "{d}", &encoded);
        _ = try std.io.getStdOut().write("\n");
        try printSlice(u8, "{d}", &decoded);
        _ = try std.io.getStdOut().write("\n");
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
        try printSlice(u8, "{d}", &data);
        try printSlice(u8, "{d}", &encoded);
        _ = try std.io.getStdOut().write("\n");
        try printSlice(u8, "{d}", &decoded);
        _ = try std.io.getStdOut().write("\n");
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
        try printSlice(u8, "{d}", &data);
        try printSlice(u8, "{d}", &encoded);
        _ = try std.io.getStdOut().write("\n");
        try printSlice(u8, "{d}", &decoded);
        _ = try std.io.getStdOut().write("\n");
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
        try printSlice(u8, "{d}", &data);
        try printSlice(u8, "{d}", &encoded);
        _ = try std.io.getStdOut().write("\n");
        try printSlice(u8, "{d}", &decoded);
        _ = try std.io.getStdOut().write("\n");
        try std.testing.expect(std.mem.eql(u8, &encoded, &expected_encoded));
        try std.testing.expect(std.mem.eql(u8, &decoded, &data));
    }
}

test "sizing encoding" {
    const data_sizes = [_]sizing.nsize_int {0, 1, 2, 8, 9, 128, 129};
    const expected_encoded_sizes = [_]sizing.encoded_nsize_int {551911719040, 551911719041, 551911719042, 551911719048, 551911719049, 551911719296, 551911719297};
    for (data_sizes, expected_encoded_sizes) |data_size, expected_encoded_size| {
        //try printSlice(u8, "{d}", std.mem.asBytes(&nencode.encodeSize(data_size)));
        //_ = try std.io.getStdOut().write("\n");
        const encoded_size = nencode.encodeSize(data_size);
        const decoded_size = nencode.decodeSize(expected_encoded_size);
        try std.io.getStdOut().writer().print("{d}, {d}\n>{d}\n", .{data_size, expected_encoded_size, decoded_size});
        try std.testing.expect(encoded_size == expected_encoded_size);
        try std.testing.expect(decoded_size == data_size);
    }
}

pub fn printSlice(comptime T: type, comptime fmt: []const u8, slice: []const T) !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("[", .{});
    for (slice, 0..) |element, i| {
        try stdout.print(fmt, .{element});
        if (i != slice.len - 1) {
            try stdout.print(", ", .{});
        }
    }
    try stdout.print("]", .{});
}

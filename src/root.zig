const std = @import("std");
const sizing = @import("sizing.zig");
const nencode = @import("nencode.zig");

test "sizing" {
    try std.testing.expect(sizing.asTransmissionSize(0) == 0);
    try std.testing.expect(sizing.asTransmissionSize(1) == 2);
    try std.testing.expect(sizing.asTransmissionSize(2) == 3);
    try std.testing.expect(sizing.asTransmissionSize(8) == 10);
    try std.testing.expect(sizing.asTransmissionSize(10) == 12);
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

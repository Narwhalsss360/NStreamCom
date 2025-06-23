const std = @import("std");
const sizing = @import("sizing.zig");

test "sizing" {
    try std.testing.expect(sizing.asTransmissionSize(1) == 2);
    try std.testing.expect(sizing.asTransmissionSize(2) == 3);
    try std.testing.expect(sizing.asTransmissionSize(8) == 10);
    try std.testing.expect(sizing.asTransmissionSize(10) == 12);
}

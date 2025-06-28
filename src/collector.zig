const std = @import("std");
const sizing = @import("sizing.zig");
const buffered_decoder = @import("buffered_decoder.zig");

pub const CollectorState = enum {
    Collected,
    WaitingSize,
    WaitingData,
    MissingSize,
    MissingData,
    BufferFull
};

pub const CollectorError = error {
    MissingSize,
    MissingData
};

pub const Error = CollectorError || buffered_decoder.DecoderError;

pub const Collector = struct {
    state: CollectorState = CollectorState.WaitingSize,
    next_size: sizing.nsize_int = 0,
    decoder: *buffered_decoder.Decoder,

    pub fn sizeReady(self: *const Collector) bool {
        return self.state == CollectorState.Collected or self.state == Collector.WaitingData;
    }

    pub fn errorState(self: *const Collector) bool {
        return
            self.state == CollectorState.MissingSize or
            self.state == CollectorState.MissingData or
            self.state == CollectorState.BufferFull;
    }

    pub fn reset(self: *Collector) void {
        self.state = CollectorState.WaitingSize;
        self.next_size = 0;
        self.decoder.reset();
    }

    pub fn collect(self: *Collector, byte: u8) Error!void {
        switch (self.state) {
            CollectorState.MissingSize, CollectorState.MissingData => {
                self.reset();
                return self.collectSizeByte(byte);
            },
            CollectorState.Collected, CollectorState.WaitingSize => return self.collectSizeByte(byte),
            CollectorState.WaitingData => return self.collectDataByte(byte),
            else => unreachable,
        }
    }

    fn collectSizeByte(self: *Collector, byte: u8) Error!void {
        if ((byte & 1 << 7) == 0) {
            self.state = CollectorState.MissingSize;
            return Error.MissingSize;
        }

        const is_last = self.decoder.position == sizing.nsize_int_byte_count;
        try self.decoder.next(byte & ~(@as(u8, 0xFF) << 7), is_last);

        if (!is_last) {
            return;
        }

        self.next_size = std.mem.bytesAsValue(sizing.nsize_int, self.decoder.buffer.?).*;
        self.decoder.reset();
        self.state = if (self.next_size == 0) CollectorState.Collected else CollectorState.WaitingData;
    }

    fn collectDataByte(self: *Collector, byte: u8) Error!void {
        if ((byte & 1 << 7) > 0) {
            self.state = CollectorState.MissingData;
            return;
        }

        const last= self.decoder.position == self.next_size;
        try self.decoder.next(byte, last);

        if (!last) {
            return;
        }

        self.state = CollectorState.Collected;
    }
};


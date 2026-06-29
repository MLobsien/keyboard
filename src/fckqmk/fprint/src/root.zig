const std = @import("std");

const qmk = @cImport({
    @cInclude("qmk_config.h");
    @cInclude("drivers/uart.h");
    @cInclude("logging/print.h");
});

const result = enum(u8) { SUCCESS, FAIL, FULL, NOUSER, USER_OCCUPIED, FINGER_OCCUPIED, TIMEOUT };

const CMD = struct {
    buf: [8]u8,

    // creates a correctly formatted instance of a command
    fn new(cmd: u8, p1: u8, p2: u8, p3: u8) CMD {
        var self = CMD{ .buf = [8]u8{ 0xF5, cmd, p1, p2, p3, 0x0, 0x0, 0xF5 } };
        self.checksum();
        return self;
    }

    pub fn checksum(self: *CMD) void {
        for (2..6) |i| {
            self.*.buf[6] ^= self.buf[i];
        }
    }
};

pub export fn init() void {
    qmk.uart_init(@as(c_ulong, 19200));
    const model_sn_cmd = CMD.new(0x2A, 0, 0, 0);
    qmk.uart_transmit(@ptrCast(&model_sn_cmd), @as(c_ushort, 8));

    var buf: [8]u8 = undefined;
    qmk.uart_receive(@ptrCast(&buf), 8);
    const sn = std.mem.readIntBig(u24, buf[2..6]);

    _ = qmk.uprintf("%d", sn);
}

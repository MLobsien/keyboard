const std = @import("std");

extern fn uart_init(baud: c_ulong) callconv(.c) void;
// extern fn qmk_uart_receive(data: *u8, length: c_ushort) callconv(.c) void;
// extern fn qmk_uart_transmit(data: *const u8, length: c_ushort) callconv(.c) void;
// extern fn qmk_uprintf(format: [*:0]const u8, ...) callconv(.c) c_int;
extern fn printf(str: [*:0]const u8, ...) callconv(.c) void;

const result = enum(u8) { SUCCESS, FAIL, FULL, NOUSER, USER_OCCUPIED, FINGER_OCCUPIED, TIMEOUT };

const CMD = struct {
    buf: [8]u8,

    /// creates a correctly formatted instance of a command
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

pub export fn keyboard_post_init_user() callconv(.c) void {
    uart_init(@as(c_ulong, 19200));
}

pub export fn housekeeping_task_user() callconv(.c) void {
    // const model_sn_cmd = CMD.new(0x2A, 0, 0, 0);
    // qmk_uart_transmit(@ptrCast(&model_sn_cmd), @as(c_ushort, 8));
    //
    // var buf: [8]u8 = undefined;
    // qmk_uart_receive(@ptrCast(&buf), 8);
    // const sn = std.mem.readInt(u24, buf[3..6], .little);
    //
    // _ = qmk_uprintf("%d", @as(u32, sn));
    _ = printf("Hello from Zig");
}

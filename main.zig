const std = @import("std");
const cpu = @import("cpu.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    _ = stdout;

    // Program
    var opCyclesRemaining: u8 = 0;
    _ = opCyclesRemaining;
    var c: cpu.CPU = cpu.initCPU();

    // Print
    inline for (std.meta.fields(@TypeOf(c))) |f| {
        std.log.debug(f.name ++ " {any}", .{@as(f.type, @field(c, f.name))});
    }
}

const std = @import("std");
const cpu = @import("cpu.zig");
const insts = @import("inst.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    _ = stdout;

    // Program
    var opCyclesRemaining: u8 = 0;
    _ = opCyclesRemaining;
    var c: cpu.CPU = cpu.initCPU();

    _ = insts.OpCodeFunc;

    print_struct(c);
}

fn print_struct(obj: anytype) void {
    inline for (std.meta.fields(@TypeOf(obj))) |f| {
        std.log.debug(f.name ++ " {any}", .{@as(f.type, @field(obj, f.name))});
    }
}

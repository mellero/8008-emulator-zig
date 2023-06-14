const std = @import("std");
const cpu = @import("cpu.zig");
const mem = @import("mem.zig");
const constants = @import("const.zig");
const insts = @import("inst.zig");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    _ = stdout;

    // Program
    var opCyclesRemaining: u8 = 0;
    const states: cpu.STATES = .{
        .S0 = 0,
        .S1 = 0,
        .S2 = 0,
    };
    mem.LOAD_MEM();

    setFlags(cpu.FLAGS, constants.FLAG_BITS_NONE);
    setStates(states, constants.T1);
    var c: cpu.CPU = cpu.initCPU();

    var testSz: i32 = 2;
    while (testSz > 0) {
        c.fetch();
        opCyclesRemaining = c.decode();
        while (opCyclesRemaining > 0) {
            opCyclesRemaining = c.execute();
        }
        testSz -= 1;
    }

    _ = insts.OpCodeFunc;

    print_struct(c);
}

fn setStates(states: *cpu.STATES, currentState: u8) void {
    states.S2 = (currentState) & 1;
    states.S1 = (currentState >> 1) & 1;
    states.S0 = (currentState >> 2) & 2;

    // printf("STATE:\n");
    // printf("s0: %d, s1: %d, s2: %d\n", states.S0, states.S1, states.S2);
}

fn setFlags(flags: *cpu.FLAGS, bitsToSet: u8) void {
    // Shift bits right, by correct number based on bit position, then check if bit set
    flags.C = bitsToSet & constants.FLAG_BIT_C;
    flags.P = (bitsToSet >> 1) & 1;
    flags.Z = (bitsToSet >> 2) & 1;
    flags.S = (bitsToSet >> 3) & 1;

    // printf("FLAGS:\n");
    // printf("C: %d, P: %d, Z: %d, S: %d\n", flags.C, flags.P, flags.Z, flags.S);
}

fn print_struct(obj: anytype) void {
    inline for (std.meta.fields(@TypeOf(obj))) |f| {
        std.log.debug(f.name ++ " {any}", .{@as(f.type, @field(obj, f.name))});
    }
}

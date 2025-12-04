const std = @import("std");
const cpu = @import("cpu.zig");
const mem = @import("mem.zig");
const constants = @import("const.zig");
const insts = @import("inst.zig");

pub fn main() !void {
    try @import("assembler").readInputFile();
    
    // Program
    var states: cpu.STATES = .{
        .S0 = 0,
        .S1 = 0,
        .S2 = 0,
    };
    try mem.LOAD_MEM();

    var c: cpu.CPU = cpu.initCPU();
    setFlags(&c.flags, constants.FLAG_BITS_NONE);
    setStates(&states, constants.T1);

    var opCyclesRemaining: u8 = 1;
    while (opCyclesRemaining > 0) {
        c.fetch();
        opCyclesRemaining = c.decode();
        while (opCyclesRemaining > 0) {
            opCyclesRemaining = c.execute();
        }
    }

    _ = insts.OpCodeFunc;

    print_struct(c);
    print_struct(states);

}

fn setStates(states: *cpu.STATES, currentState: u8) void {
    states.S2 = @intCast((currentState) & 1);
    states.S1 = @intCast((currentState >> 1) & 1);
    states.S0 = @intCast((currentState >> 2) & 2);

    // printf("STATE:\n");
    // printf("s0: %d, s1: %d, s2: %d\n", states.S0, states.S1, states.S2);
}

fn setFlags(flags: *cpu.FLAGS, bitsToSet: u8) void {
    // Shift bits right, by correct number based on bit position, then check if bit set
    flags.C = @intCast(bitsToSet & constants.FLAG_BIT_C);
    flags.P = @intCast((bitsToSet >> 1) & 1);
    flags.Z = @intCast((bitsToSet >> 2) & 1);
    flags.S = @intCast((bitsToSet >> 3) & 1);

    // printf("FLAGS:\n");
    // printf("C: %d, P: %d, Z: %d, S: %d\n", flags.C, flags.P, flags.Z, flags.S);
}

fn print_struct(obj: anytype) void {
    inline for (std.meta.fields(@TypeOf(obj))) |f| {
        std.debug.print(f.name ++ " {any}\n", .{@as(f.type, @field(obj, f.name))});
    }
}

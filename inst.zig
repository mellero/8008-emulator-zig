const std = @import("std");

const cpu = @import("cpu.zig");
const mem = @import("mem.zig");
const constants = @import("const.zig");

pub const OpCodeFunc = fn (*cpu.CPU) u8;

pub const opCodes = [_]OpCodeFunc{};

// zig fmt: off
const parityTable =  [_]u8{
    0x0, 0x1, 0x1, 0x0, 0x1, 0x0, 0x0, 0x1, 0x1, 0x0, 0x0, 0x1, 0x0, 0x1, 0x1, 0x0,
    0x1, 0x0, 0x0, 0x1, 0x0, 0x1, 0x1, 0x0, 0x0, 0x1, 0x1, 0x0, 0x1, 0x0, 0x0, 0x1,
    0x1, 0x0, 0x0, 0x1, 0x0, 0x1, 0x1, 0x0, 0x0, 0x1, 0x1, 0x0, 0x1, 0x0, 0x0, 0x1,
    0x0, 0x1, 0x1, 0x0, 0x1, 0x0, 0x0, 0x1, 0x1, 0x0, 0x0, 0x1, 0x0, 0x1, 0x1, 0x0,
    0x1, 0x0, 0x0, 0x1, 0x0, 0x1, 0x1, 0x0, 0x0, 0x1, 0x1, 0x0, 0x1, 0x0, 0x0, 0x1,
    0x0, 0x1, 0x1, 0x0, 0x1, 0x0, 0x0, 0x1, 0x1, 0x0, 0x0, 0x1, 0x0, 0x1, 0x1, 0x0,
    0x0, 0x1, 0x1, 0x0, 0x1, 0x0, 0x0, 0x1, 0x1, 0x0, 0x0, 0x1, 0x0, 0x1, 0x1, 0x0,
    0x1, 0x0, 0x0, 0x1, 0x0, 0x1, 0x1, 0x0, 0x0, 0x1, 0x1, 0x0, 0x1, 0x0, 0x0, 0x1,
    0x1, 0x0, 0x0, 0x1, 0x0, 0x1, 0x1, 0x0, 0x0, 0x1, 0x1, 0x0, 0x1, 0x0, 0x0, 0x1,
    0x0, 0x1, 0x1, 0x0, 0x1, 0x0, 0x0, 0x1, 0x1, 0x0, 0x0, 0x1, 0x0, 0x1, 0x1, 0x0,
    0x0, 0x1, 0x1, 0x0, 0x1, 0x0, 0x0, 0x1, 0x1, 0x0, 0x0, 0x1, 0x0, 0x1, 0x1, 0x0,
    0x1, 0x0, 0x0, 0x1, 0x0, 0x1, 0x1, 0x0, 0x0, 0x1, 0x1, 0x0, 0x1, 0x0, 0x0, 0x1,
    0x0, 0x1, 0x1, 0x0, 0x1, 0x0, 0x0, 0x1, 0x1, 0x0, 0x0, 0x1, 0x0, 0x1, 0x1, 0x0,
    0x1, 0x0, 0x0, 0x1, 0x0, 0x1, 0x1, 0x0, 0x0, 0x1, 0x1, 0x0, 0x1, 0x0, 0x0, 0x1,
    0x1, 0x0, 0x0, 0x1, 0x0, 0x1, 0x1, 0x0, 0x0, 0x1, 0x1, 0x0, 0x1, 0x0, 0x0, 0x1,
    0x0, 0x1, 0x1, 0x0, 0x1, 0x0, 0x0, 0x1, 0x1, 0x0, 0x0, 0x1, 0x0, 0x1, 0x1, 0x0
};
// zig fmt: on

/// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
/// *                                                     Static Helper Functions                                                     *
/// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
///
/// TODO: Fix logic in this function. Decide how to use.
/// Multiple flag functions to set individual flags? Single function?
/// C P Z S
///
fn setFlags(flags: *cpu.FLAGS, bitsToSet: u8) void {
    // Shift bits right, by correct number based on bit position, then check if bit set
    flags.C = bitsToSet & constants.FLAG_BIT_C;
    flags.P = bitsToSet & constants.FLAG_BIT_P;
    flags.Z = bitsToSet & constants.FLAG_BIT_Z;
    flags.S = bitsToSet & constants.FLAG_BIT_S;

    std.debug.print("FLAGS:\n", .{});
    std.debug.print("C: {d}, P: {d}, Z: {d}, S: {d}\n", .{ flags.C, flags.P, flags.Z, flags.S });
}

fn calculateFlags(flags: *cpu.FLAGS, bitsToCalc: u8, reg: *u8) void {
    var cFlag: i32 = 0;
    var zFlag: i32 = 0;
    var sFlag: i32 = 0;
    var pFlag: i32 = 0;

    if (bitsToCalc & constants.FLAG_BIT_C) {}
    if (bitsToCalc & constants.FLAG_BIT_P) zFlag = (reg.* == 0) & constants.FLAG_BIT_Z;
    if (bitsToCalc & constants.FLAG_BIT_Z) sFlag = (reg.* & 0b10000000) & constants.FLAG_BIT_S;
    if (bitsToCalc & constants.FLAG_BIT_S) pFlag = parityTable[reg.*] & constants.FLAG_BIT_P;

    setFlags(flags, (cFlag | pFlag | zFlag | sFlag));
}

///
/// Gets the index register (A - E, H, L) associated with the address rAdrs
///
fn GET_REG(c: *cpu.CPU, rAdrs: u8) *u8 {
    // Start at register A and increment until rAdrs == 0
    var r: *u8 = &c.reg.A;
    while (rAdrs) {
        r += 1;
        rAdrs -= 1;
    }
    return r;
}

fn HLT(c: *cpu.CPU) u8 {
    _ = c;
    return 0;
}

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *                                                      Index Register Insts.                                                      *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

///
/// Load value from Source index register to Destination index register
/// 11 DDD SSS
///
fn LRR(c: *cpu.CPU) u8 {
    const mask: u8 = 0b00000111;
    const src: u8 = (c.inst) & mask;
    const dest: u8 = (cpu.inst >> 3) & mask;

    const srcR: *const u8 = GET_REG(c, src);
    const destR: *const u8 = GET_REG(c, dest);

    destR.* = srcR.*;
    return 0;
}

///
/// Load Register R with value from M (HL)
///
fn LRM(c: *cpu.CPU) u8 {
    _ = c;
    const mask: u8 = 0b00000111;
    const dest: u8 = (cpu.inst >> 3) & mask;

    const destR: *u8 = GET_REG(cpu, dest);
    const m: u16 = (cpu.reg.H << 8) | (cpu.reg.L);

    destR.* = mem.READ_MEM(m);

    return 0;
}

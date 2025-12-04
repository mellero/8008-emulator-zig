const std = @import("std");

const cpu = @import("cpu.zig");
const mem = @import("mem.zig");
const constants = @import("const.zig");

pub const OpCodeFunc = ?fn (*cpu.CPU) u8;

// zig fmt: off
pub const opCodes = [_]OpCodeFunc{
    //        x0   x1    x2     x3    x4    x5    x6    x7    x8    x9    xA    xB    xC    xD    xE    xF
    // 0x  
             HLT,  HLT,  NOOP,  null, NOOP,  null, LRI,  null, INR,  DCR,  NOOP,  null, NOOP, null,  LRI,  null,
//     // 1x  
             INR,  DCR,  NOOP,  null, NOOP,  null, LRI,  null, INR,  DCR,  NOOP,  null, NOOP, null,  LRI,  null,
//     // 2x  
             INR,  DCR,  null, null, NOOP,  null, LRI,  null, INR,  DCR,  null, null, NOOP, null,  LRI,  null,
//     // 3x  
             INR,  DCR,  null, null, NOOP,  null, LRI,  null, null, null, null, null, NOOP, null, LMI,  null,
//     // 4x  
             null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
//     // 5x  
             null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
//     // 6x  
             null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
//     // 7x  
             null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
//     // 8x  
             NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,
//     // 9x  
             NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,
//     // Ax  
             NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,
//     // Bx  
             NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,  NOOP,
    // Cx  
             null, LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRM,  LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRM,
    // Dx  
             LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRM,  LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRM,
    // Ex  
             LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRM,  LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRM,
    // Fx  
             LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRM,  LMR,  LMR,  LMR,  LMR,  LMR,  LMR,  LMR,  HLT
};

// pub const opCodes = [_]OpCodeFunc{
    //        x0   x1    x2    x3    x4    x5    x6    x7    x8    x9    xA    xB    xC    xD    xE    xF
    // 0x  
//              HLT,  HLT,  RLC,  NULL, ADI,  NULL, LRI,  NULL, INR,  DCR,  RRC,  NULL, ACI, NULL,  LRI,  NULL,
//     // 1x  
//              INR,  DCR,  RAL,  NULL, SUI,  NULL, LRI,  NULL, INR,  DCR,  RAR,  NULL, SBI, NULL,  LRI,  NULL,
//     // 2x  
//              INR,  DCR,  NULL, NULL, NDI,  NULL, LRI,  NULL, INR,  DCR,  NULL, NULL, XRI, NULL,  LRI,  NULL,
//     // 3x  
//              INR,  DCR,  NULL, NULL, ORI,  NULL, LRI,  NULL, NULL, NULL, NULL, NULL, CPI, NULL, LMI,  NULL,
//     // 4x  
//              NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
//     // 5x  
//              NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
//     // 6x  
//              NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
//     // 7x  
//              NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
//     // 8x  
//              ADR,  ADR,  ADR,  ADR,  ADR,  ADR,  ADR,  ADM,  ACR,  ACR,  ACR,  ACR,  ACR,  ACR,  ACR,  ACM,
//     // 9x  
//              SUR,  SUR,  SUR,  SUR,  SUR,  SUR,  SUR,  SUM,  SBR,  SBR,  SBR,  SBR,  SBR,  SBR,  SBR,  SBM,
//     // Ax  
//              NDR,  NDR,  NDR,  NDR,  NDR,  NDR,  NDR,  NDM,  XRR,  XRR,  XRR,  XRR,  XRR,  XRR,  XRR,  XRM,
//     // Bx  
//              ORR,  ORR,  ORR,  ORR,  ORR,  ORR,  ORR,  ORM,  CPR,  CPR,  CPR,  CPR,  CPR,  CPR,  CPR,  CPM,
//     // Cx  
//              null, LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRM,  LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRM,
//     // Dx  
//              LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRM,  LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRM,
//     // Ex  
//              LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRM,  LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRM,
//     // Fx  
//              LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRM,  LMR,  LMR,  LMR,  LMR,  LMR,  LMR,  LMR,  HLT
// };
// zig fmt: on

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
    flags.C = @intFromBool((bitsToSet & constants.FLAG_BIT_C) != 0);
    flags.P = @intFromBool((bitsToSet & constants.FLAG_BIT_P) != 0);
    flags.Z = @intFromBool((bitsToSet & constants.FLAG_BIT_Z) != 0);
    flags.S = @intFromBool((bitsToSet & constants.FLAG_BIT_S) != 0);

    std.debug.print("FLAGS:\n", .{});
    std.debug.print("C: {d}, P: {d}, Z: {d}, S: {d}\n", .{ flags.C, flags.P, flags.Z, flags.S });
}

fn testHelperFlagCPUInit() cpu.CPU {
    var c: cpu.CPU = cpu.initCPU();
    setFlags(&c.flags, constants.FLAG_BITS_NONE);
    return c;
}

test "Set flags sets correctly on NONE" {
    const c: cpu.CPU =  testHelperFlagCPUInit();
    try std.testing.expectEqual(0, c.flags.S);
    try std.testing.expectEqual(0, c.flags.C);
    try std.testing.expectEqual(0, c.flags.P);
    try std.testing.expectEqual(0, c.flags.Z);
}

test "Set flags sets correctly on ALL" {
    var c: cpu.CPU =  testHelperFlagCPUInit();
    setFlags(&c.flags, constants.FLAG_BITS_ALL);
    try std.testing.expectEqual(1, c.flags.S);
    try std.testing.expectEqual(1, c.flags.C);
    try std.testing.expectEqual(1, c.flags.P);
    try std.testing.expectEqual(1, c.flags.Z);
}

test "Set flags sets flags properly" {
    var c: cpu.CPU =  testHelperFlagCPUInit();
    var flag_to_set: u8 = 0;
    const one: u8 = 1;
    for (0..4) |f| {
        flag_to_set = one << @intCast(f);

        setFlags(&c.flags, (flag_to_set));
        try std.testing.expectEqual(if (f == 0) @as(u1, 1) else 0, c.flags.C);
        try std.testing.expectEqual(if (f == 1) @as(u1, 1) else 0, c.flags.P);
        try std.testing.expectEqual(if (f == 2) @as(u1, 1) else 0, c.flags.Z);
        try std.testing.expectEqual(if (f == 3) @as(u1, 1) else 0, c.flags.S);
    }

    for (0..4) |_| {
        flag_to_set = 0;

        setFlags(&c.flags, (flag_to_set));
        try std.testing.expectEqual(0, c.flags.C);
        try std.testing.expectEqual(0, c.flags.P);
        try std.testing.expectEqual(0, c.flags.Z);
        try std.testing.expectEqual(0, c.flags.S);
    }
}


fn calculateFlags(flags: *cpu.FLAGS, bitsToCalc: u8, reg: *u8) void {
    const cFlag: u8 = 0;
    var zFlag: u8 = 0;
    var sFlag: u8 = 0;
    var pFlag: u8 = 0;

    if (bitsToCalc & constants.FLAG_BIT_C > 0) {}
    if (bitsToCalc & constants.FLAG_BIT_P > 0) {
        const emptyRegVal: u8 = if (reg.* == 0) 1 else 0;
        zFlag = emptyRegVal & constants.FLAG_BIT_Z;
    }
    if (bitsToCalc & constants.FLAG_BIT_Z > 0) {
        sFlag = (reg.* & 0b10000000) & constants.FLAG_BIT_S;
    }
    if (bitsToCalc & constants.FLAG_BIT_S > 0) {
        pFlag = parityTable[reg.*] & constants.FLAG_BIT_P;
    }

    setFlags(flags, (cFlag | pFlag | zFlag | sFlag));
}

fn HLT(c: *cpu.CPU) u8 {
    _ = c;
    return 0;
}

fn NOOP(c: *cpu.CPU) u8 {
    std.log.debug("No op for inst {b}", .{c.inst});
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
    const src: u3 = @intCast(c.inst & mask);
    const dest: u3 = @intCast((c.inst >> 3) & mask);

    const srcR: *u8 = c.getReg(src);
    const destR: *u8 = c.getReg(dest);

    destR.* = srcR.*;
    return 0;
}

test "LRR load A (000) from B (001)" {
    var c: cpu.CPU = testHelperFlagCPUInit();
    // 11 DDD SSS
    c.inst = @intCast(0b11000001);

    const expected: u8 = 15;
    c.reg.B = expected;
    _ = LRR(&c);
    try std.testing.expectEqual(expected, c.reg.A);
}

///
/// Load Register R with value from M (HL)
/// 11 DDD 111
///
fn LRM(c: *cpu.CPU) u8 {
    const mask: u8 = 0b00000111;
    const dest: u3 = @intCast((c.inst >> 3) & mask);

    const destR: *u8 = c.getReg(dest);

    const h16: u16 = @intCast(c.reg.H);
    const l16: u16 = @intCast(c.reg.L);
    const m: u16 = (h16 << 8) | (l16);

    destR.* = mem.READ_MEM(m);

    return 0;
}

test "LRM load B (001) from M (H + L)" {
    mem.CLEAR_MEM();
    var c: cpu.CPU = testHelperFlagCPUInit();
    // 11 DDD 111
    c.inst = @intCast(0b11001111);

    const expected_val: u8 = 15;
    const low: u8 = 0b00001111;
    const high: u8 = 0b00110000;
    const full_addr: u16 = 0b00110000_00001111;
    c.reg.L = low;
    c.reg.H = high;
    const m: u16 = full_addr;

    mem.RAM[m] = expected_val;

    _ = LRM(&c);
    try std.testing.expectEqual(expected_val, c.reg.B);
}

///
/// Load memory register M with context of index register r
/// 11 111 SSS
///
fn LMR(c: *cpu.CPU) u8 {
    const mask: u8 = 0b00000111;
    const src: u3 = @intCast(c.inst & mask);

    const srcR: *u8 = c.getReg(src);
    const h16: u16 = @intCast(c.reg.H);
    const l16: u16 = @intCast(c.reg.L);
    const m: u16 = (h16 << 8) | (l16);

    mem.WRITE_MEM(m, srcR.*);

    return 0;
}

test "LMR load M (H + L) from C (010)" {
    mem.CLEAR_MEM();
    var c: cpu.CPU = testHelperFlagCPUInit();
    // 11 111 SSS
    c.inst = @intCast(0b11111010);

    const expected_val: u8 = 15;
    c.reg.C = expected_val;
    
    const low: u8 = 0b00001111;
    const high: u8 = 0b00110000;
    const full_addr: u16 = 0b00110000_00001111;
    c.reg.L = low;
    c.reg.H = high;
    const m: u16 = full_addr;

    _ = LMR(&c);
    try std.testing.expectEqual(expected_val, mem.RAM[m]);
}

///
/// Load source register with immediate value (next byte)
/// 00 DDD 110
///
fn LRI(c: *cpu.CPU) u8 {
    // Container variable to hold register value over multiple calls
    const cont = struct {
        var destR: ?*u8 = null;
    };

    if (cont.destR) |destR| {
        const imm: u8 = c.inst;
        destR.* = imm;
        // LOG?

        // reset container for next use
        cont.destR = null;

        return 0;
    } else {
        // No register set yet
        const mask: u8 = 0b00000111;
        const dest: u3 = @intCast((c.inst >> 3) & mask);

        cont.destR = c.getReg(dest);

        // LOG?
        return 1;
    }
}

test "LRI load L (110) with immediate value" {
    var c: cpu.CPU = testHelperFlagCPUInit();
    // 00 DDD 110
    c.inst = @intCast(0b00110110);
    _ = LRI(&c);

    const expected_imm: u8 = 0b00111001;
    c.inst = @intCast(expected_imm);
    _ = LRI(&c);

    try std.testing.expectEqual(expected_imm, c.reg.L);
}

///
/// Load memory register M with immediate value (next byte)
/// 00 111 110
///
fn LMI(c: *cpu.CPU) u8 {
    // Container variable to hold register value over multiple calls
    const cont = struct {
        var destM: ?*u16 = null;
    };

    if (cont.destM) |destM| {
        const imm: u8 = c.inst;
        mem.WRITE_MEM(destM.*, imm);

        // reset container for next use
        cont.destM = null;

        return 0;
    } else {
        // No register set yet
        const h16: u16 = @intCast(c.reg.H);
        const l16: u16 = @intCast(c.reg.L);
        var m: u16 = (h16 << 8) | (l16);
        cont.destM = &m;

        return 1;
    }
}

test "LMI load M (H + L) with immediate value" {
    mem.CLEAR_MEM();
    var c: cpu.CPU = testHelperFlagCPUInit();
    // 00 111 110
    c.inst = @intCast(0b00111110);

    const low: u8 = 0b00001110;
    const high: u8 = 0b00110001;
    const full_addr: u16 = 0b00110001_00001110;
    c.reg.L = low;
    c.reg.H = high;
    const m: u16 = full_addr;
    _ = LMI(&c);

    const expected_imm: u8 = 0b00111001;
    c.inst = @intCast(expected_imm);
    _ = LMI(&c);

    try std.testing.expectEqual(expected_imm, mem.RAM[m]);
}

///
/// Increment content of index register R (R != A)
/// 00 DDD 000
///
fn INR(c: *cpu.CPU) u8 {
    const mask: u8 = 0b00000111;
    const dest: u3 = @intCast((c.inst >> 3) & mask);
    const reg: *u8 = c.getReg(dest);
    if (reg.* == constants.IDX_A) {
        return 0;
    }

    reg.* += 1;

    calculateFlags(&c.flags, (constants.FLAG_BIT_P | constants.FLAG_BIT_Z | constants.FLAG_BIT_S), reg);

    return 0;
}

test "INR increments register D (011)" {
    var c: cpu.CPU = testHelperFlagCPUInit();
    // 00 DDD 000
    c.inst = @intCast(0b00011000);

    const initial: u8 = 15;
    const expected: u8 = initial + 1;
    c.reg.D = initial;
    _ = INR(&c);

    try std.testing.expectEqual(expected, c.reg.D);
}

///
/// Decrement content of index register R (R != A)
/// 00 DDD 001
///
fn DCR(c: *cpu.CPU) u8 {
    const mask: u8 = 0b00000111;
    const dest: u3 = @intCast((c.inst >> 3) & mask);
    const reg: *u8 = c.getReg(dest);
    if (reg.* == constants.IDX_A) {
        return 0;
    }

    reg.* -= 1;

    calculateFlags(&c.flags, (constants.FLAG_BIT_P | constants.FLAG_BIT_Z | constants.FLAG_BIT_S), reg);

    return 0;
}

test "DCR decrements register E (100)" {
    var c: cpu.CPU = testHelperFlagCPUInit();
    // 00 DDD 000
    c.inst = @intCast(0b00100001);

    const initial: u8 = 15;
    const expected: u8 = initial - 1;
    c.reg.E = initial;
    _ = DCR(&c);

    try std.testing.expectEqual(expected, c.reg.E);
}

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *                                                   Accumulator Group Insts.                                                      *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// *                                            Program Counter and Stack Control Inst                                               *
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


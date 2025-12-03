const std = @import("std");

const cpu = @import("cpu.zig");
const mem = @import("mem.zig");
const constants = @import("const.zig");

pub const OpCodeFunc = fn (*cpu.CPU) u8;

// zig fmt: off
pub const opCodes = [_]OpCodeFunc{};
//     //        x0   x1    x2    x3    x4    x5    x6    x7    x8    x9    xA    xB    xC    xD    xE    xF
//     // 0x  
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
//              NULL, LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRM,  LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRR,  LRM,
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
    flags.C = bitsToSet & constants.FLAG_BIT_C;
    flags.P = bitsToSet & constants.FLAG_BIT_P;
    flags.Z = bitsToSet & constants.FLAG_BIT_Z;
    flags.S = bitsToSet & constants.FLAG_BIT_S;

    std.debug.print("FLAGS:\n", .{});
    std.debug.print("C: {d}, P: {d}, Z: {d}, S: {d}\n", .{ flags.C, flags.P, flags.Z, flags.S });
}

fn calculateFlags(flags: *cpu.FLAGS, bitsToCalc: u8, reg: *u8) void {
    const cFlag: i32 = 0;
    const zFlag: i32 = 0;
    const sFlag: i32 = 0;
    const pFlag: i32 = 0;

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
    const dest: u8 = (c.inst >> 3) & mask;

    const srcR: *const u8 = GET_REG(c, src);
    const destR: *const u8 = GET_REG(c, dest);

    destR.* = srcR.*;
    return 0;
}

///
/// Load Register R with value from M (HL)
///
fn LRM(c: *cpu.CPU) u8 {
    const mask: u8 = 0b00000111;
    const dest: u8 = (c.inst >> 3) & mask;

    const destR: *u8 = GET_REG(c, dest);
    const m: u16 = (c.reg.H << 8) | (c.reg.L);

    destR.* = mem.READ_MEM(m);

    return 0;
}

///
/// Load memory register M with context of index register r
///
fn LMR(c: *cpu.CPU) u8 {
    const mask: u8 = 0b00000111;
    const src: u8 = (c.inst) & mask;

    const srcR: *u8 = GET_REG(c, src);
    const m: u16 = (c.reg.H << 8) | (c.reg.L);

    mem.WRITE_MEM(m, srcR);

    return 0;
}

///
/// Load source register with immediate value (next byte)
///
fn LRI(c: *cpu.CPU) u8 {
    // Container variable to hold register value over multiple calls
    const cont = struct {
        var destR: *u8 = null;
    };

    if (cont.destR) |destR| {
        const imm: u8 = cpu.inst;
        destR.* = imm;
        // LOG?

        // reset container for next use
        cont.destR = null;

        return 0;
    } else {
        // No register set yet
        const mask: u8 = 0b00000111;
        const dest: u8 = (c.inst >> 3) & mask;

        cont.destR = GET_REG(c, dest);

        // LOG?
        return 1;
    }
}

///
/// Load memory register M with immediate value (next byte)
///
fn LMI(c: *cpu.CPU) u8 {
    // Container variable to hold register value over multiple calls
    const cont = struct {
        var destM: *u16 = null;
    };

    if (cont.destM) |destM| {
        const imm: u8 = cpu.inst;
        mem.WRITE_MEM(*destM, imm);

        // reset container for next use
        cont.destR = null;

        return 0;
    } else {
        // No register set yet
        var m: u16 = (c.reg.H << 8) | (c.reg.L);
        cont.destM = &m;

        return 1;
    }
}

///
/// Increment content of index register R
///
fn INR(c: *cpu.CPU) u8 {
    const mask: u8 = 0b00000111;
    const dest: u8 = (c.inst >> 3) & mask;
    const reg: *u8 = GET_REG(c, dest);
    if (reg == constants.IDX_A) {
        return -1;
    }

    reg.* += 1;

    calculateFlags(&c.flags, (constants.FLAG_BIT_P | constants.FLAG_BIT_Z | constants.FLAG_BIT_S), reg);

    return 0;
}

///
/// Decrement content of index register R
///
fn DCR(c: *cpu.CPU) u8 {
    const mask: u8 = 0b00000111;
    const dest: u8 = (c.inst >> 3) & mask;
    const reg: *u8 = GET_REG(c, dest);
    if (reg == constants.IDX_A) {
        return -1;
    }

    reg.* -= 1;

    calculateFlags(&c.flags, (constants.FLAG_BIT_P | constants.FLAG_BIT_Z | constants.FLAG_BIT_S), reg);

    return 0;
}

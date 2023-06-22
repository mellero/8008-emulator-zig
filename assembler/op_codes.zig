const std = @import("std");

///
/// Register Addresses:
/// 000 A
/// 001 B
/// 010 C
/// 011 D
/// 100 E
/// 101 H
/// 110 L
///
pub const op_code_to_hex_map = std.ComptimeStringMap(*const [4:0]u8, .{
    .{ "HLT", "0x00" },
    //  HLT    0x01
    .{ "RLC", "0x02" },
    .{ "RFC", "0x03" },
    .{ "ADI", "0x04" },
    .{ "LAI", "0x06" },

    .{ "RRC", "0x0A" },
    .{ "RFZ", "0x0B" },

    .{ "LBI", "0x0E" },

    .{ "RAL", "0x12" },

    .{ "LCI", "0x16" },

    .{ "RAR", "0x1A" },

    .{ "LDI", "0x1E" },
    .{ "LEI", "0x26" },
    // .{ "LHI", "0x2E" },
    // .{ "LLI", "0x36" },

    .{ "ADA", "0x80" },
    .{ "ADB", "0x81" },
    .{ "ADC", "0x82" },
    .{ "ADD", "0x83" },
    .{ "ADE", "0x84" },
    .{ "ADH", "0x85" },
    .{ "ADL", "0x86" },
    .{ "ADM", "0x87" },

    // LRR - Load Dst Src
    .{ "LAA", "0xC0" },
    .{ "LAB", "0xC1" },
    .{ "LAC", "0xC2" },
    .{ "LAD", "0xC3" },
    .{ "LAE", "0xC4" },
    .{ "LAH", "0xC5" },
    .{ "LAL", "0xC6" },
    .{ "LAM", "0xC7" },
    .{ "LBA", "0xC8" },
    .{ "LBB", "0xC9" },
    .{ "LBC", "0xCA" },
    .{ "LBD", "0xCB" },
    .{ "LBE", "0xCC" },
    .{ "LBH", "0xCD" },
    .{ "LBL", "0xCE" },
    .{ "LBM", "0xCF" },
    .{ "LCA", "0xD0" },
    .{ "LCB", "0xD1" },
    .{ "LCC", "0xD2" },
    .{ "LCD", "0xD3" },
    .{ "LCE", "0xD4" },
    .{ "LCH", "0xD5" },
    .{ "LCL", "0xD6" },
    .{ "LCM", "0xD7" },
    .{ "LDA", "0xD8" },
    .{ "LDB", "0xD9" },
    .{ "LDC", "0xDA" },
    .{ "LDD", "0xDB" },
    .{ "LDE", "0xDC" },
    .{ "LDH", "0xDD" },
    .{ "LDL", "0xDE" },
    .{ "LDM", "0xDF" },
    .{ "LEA", "0xE0" },
    .{ "LEB", "0xE1" },
    .{ "LEC", "0xE2" },
    .{ "LED", "0xE3" },
    .{ "LEE", "0xE4" },
    .{ "LEH", "0xE5" },
    .{ "LEL", "0xE6" },
    .{ "LEM", "0xE7" },

    .{ "JMP", "0xCE" },
});

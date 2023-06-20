const std = @import("std");

pub const op_code_to_hex_map = std.ComptimeStringMap(*const [4:0]u8, .{
    .{ "ADI", "0x04" },
    .{ "LAI", "0x06" },
    .{ "ADA", "0x80" },
    .{ "ADB", "0x81" },
    .{ "ADC", "0x82" },
    .{ "ADD", "0x83" },
    .{ "ADE", "0x84" },
    .{ "ADH", "0x85" },
    .{ "ADL", "0x86" },
    .{ "LBA", "0xC8" },
    .{ "LBB", "0xC9" },
    .{ "LBC", "0xCA" },
    .{ "LBD", "0xCB" },
    .{ "LBE", "0xCC" },
    .{ "LBH", "0xCD" },
    .{ "LBL", "0xCE" },
    .{ "JMP", "0xCE" },
});

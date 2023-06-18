const std = @import("std");

///
/// Read in from assembly input file
/// Output binary
///
pub fn readInputFile() !void {
    const file_name = "assembler/program.txt";
    const file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (lineValue(line)) |value| {
            if (value.op) |op| {
                var opBin = try convertNumTypeToBinary(op);

                if (value.imm.len > 0) {
                    var immTrimmed = std.mem.trim(u8, value.imm, " ");
                    if (immTrimmed.len > 0) {
                        var immBin = try convertNumTypeToBinary(immTrimmed);
                        var ptr: [:0]u8 = immBin[0.. :0];
                        try logLineConversion(line, opBin, ptr);
                    }
                } else {
                    const empty = "";
                    const null_term: [:0]u8 = @constCast(empty ++ [_]u8{0});
                    try logLineConversion(line, opBin, null_term);
                }
            } else {
                std.log.debug("Found bad opcode {s}", .{line});
            }
        }
    }
}

fn logLineConversion(line: []u8, opBin: [8:0]u8, immBin: [:0]u8) !void {
    var outputBuf: [1024]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&outputBuf);
    var writer = fbs.writer();
    try std.fmt.format(writer, "{s} => {s}", .{ line, opBin });

    if (immBin.len > 1) {
        try std.fmt.format(writer, " | {s}", .{immBin});
    }

    std.log.debug("{s}", .{fbs.getWritten()});
}

const Line = struct { op: ?*const [4:0]u8, imm: []const u8 };
fn lineValue(line: []u8) ?Line {
    if (line.len >= 3) {
        const op = line[0..3];
        const imm = line[3..line.len];
        return .{ .op = map.get(op), .imm = imm };
    }

    return null;
}

const map = std.ComptimeStringMap(*const [4:0]u8, .{
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
});

const NumType = enum { decimal, hex, binary };

const RadixError = error{InvalidNumType};

fn convertNumTypeToBinary(input: []const u8) ![8:0]u8 {
    var outputBuf: [9]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&outputBuf);
    var writer = fbs.writer();

    const result = try std.fmt.parseInt(u8, input, 0);
    try std.fmt.format(writer, "{b:0>8}", .{result});
    try writer.writeByte('\x00');
    const ptr: *[8:0]u8 = fbs.getWritten()[0..8 :0];

    // fbs.reset();
    return ptr.*;
}

test "convertNumTypeToBinary should return proper results on proper input" {
    const expected = "00010001";

    var inputHex = "0x11".*;
    const result = try convertNumTypeToBinary(&inputHex);
    try std.testing.expect(std.mem.eql(u8, expected, result));

    var inputDecimal = "17".*;
    const resultDecimal = try convertNumTypeToBinary(&inputDecimal);
    try std.testing.expect(std.mem.eql(u8, expected, resultDecimal));

    var inputBinary = "0b10001".*;
    const resultBinary = try convertNumTypeToBinary(&inputBinary);
    try std.testing.expect(std.mem.eql(u8, expected, resultBinary));
}

fn convertConstToMutable(allocator: *std.mem.Allocator, constData: []const u8) ![]u8 {
    var mutableData: []u8 = try allocator.alloc(u8, constData.len);
    @memcpy(mutableData.ptr, constData);
    return mutableData;
}

fn printBytes(title: []const u8, str: [8:0]u8) !void {
    std.log.debug("{s}: |{s}|", .{ title, str });

    var out_buf: [64]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&out_buf);
    const writer = fbs.writer();

    for (str) |byte| {
        const byteValue: u8 = byte;
        try std.fmt.format(writer, "|{x}|", .{byteValue});
    }
    std.log.debug("{s}", .{fbs.getWritten()});
    std.log.debug("=====", .{});
}

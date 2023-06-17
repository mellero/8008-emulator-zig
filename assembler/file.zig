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
                var outputBuf: [64]u8 = undefined;
                var fbs = std.io.fixedBufferStream(&outputBuf);
                var writer = fbs.writer();

                try std.fmt.format(writer, "{s} => {s}", .{ line, op });
                const imm = value.imm orelse "";
                if (imm.len > 0) {
                    // std.log.debug("\n\n imm = |{s}|\n", .{imm});
                    try std.fmt.format(writer, " | {s}", .{imm});
                }
                std.log.debug("{s}", .{fbs.getWritten()});
                // std.log.debug("OP HEX: {s} | {s}\n", .{ op, output });
            } else {
                std.log.debug("Found bad opcode {s}", .{line});
            }
        }
    }
}

const Line = struct { op: ?*const [2:0]u8, imm: ?[]u8 };
fn lineValue(line: []u8) ?Line {
    if (line.len >= 3) {
        const op = line[0..3];
        const imm = line[3..line.len];
        return .{ .op = map.get(op), .imm = imm };
    }

    return null;
}

const map = std.ComptimeStringMap(*const [2:0]u8, .{
    .{ "ADI", "04" },
    .{ "LAI", "06" },
    .{ "ADA", "80" },
    .{ "ADB", "81" },
    .{ "ADC", "82" },
    .{ "ADD", "83" },
    .{ "ADE", "84" },
    .{ "ADH", "85" },
    .{ "ADL", "86" },
    .{ "LBA", "C8" },
    .{ "LBB", "C9" },
    .{ "LBC", "CA" },
    .{ "LBD", "CB" },
    .{ "LBE", "CC" },
    .{ "LBH", "CD" },
    .{ "LBL", "CE" },
});

const NumType = enum { decimal, hex, binary };

const RadixError = error{InvalidNumType};

fn convertNumTypeToBinary(input: []u8) ![]u8 {
    var outputBuf: [64]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&outputBuf);
    var writer = fbs.writer();
    const result = try std.fmt.parseInt(u8, input, 0);
    try std.fmt.format(writer, "{b:0>8}", .{result});
    return fbs.getWritten();
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

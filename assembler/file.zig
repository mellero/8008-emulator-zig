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
        if (split_line(line)) |splitLine| {
            if (try split_line_to_binary(splitLine)) |binary_rep| {
                // switch (binary_rep) {
                //     BinInst.single => |value| std.log.debug("Single Bin: {s}", .{value.opCode}),
                //     BinInst.double => |value| std.log.debug("Double Bin: {s} | {s}", .{ value.opCode, value.immVal }),
                //     BinInst.triple => |_| std.log.debug("Triple Bin: {s}", .{"NA"}),
                // }

                try log_line_conversion(line, binary_rep);
            } else {
                std.log.debug("Bad input line {s}", .{line});
            }
        }
    }
}

const BinaryByte = [8:0]u8;
const SingleInst = struct { opCode: BinaryByte };
const DoubleInst = struct { opCode: BinaryByte, immVal: BinaryByte };
const TripleInst = struct { opCode: BinaryByte, memLow: BinaryByte, memHigh: BinaryByte };
const InstTag = enum { single, double, triple };
const BinInst = union(InstTag) { single: SingleInst, double: DoubleInst, triple: TripleInst };

fn split_line_to_binary(splitLine: SplitLine) !?BinInst {
    const opCodeHex = opCodeToHexMap.get(splitLine.op) orelse return null;
    const opBin = try convertNumTypeToBinary(opCodeHex);
    const rest = std.mem.trim(u8, splitLine.rest, " ");
    if (rest.len == 0) {
        return BinInst{ .single = .{ .opCode = opBin } };
    }
    // TODO: handle triple
    const immBin = try convertNumTypeToBinary(rest);
    return BinInst{ .double = .{ .opCode = opBin, .immVal = immBin } };
}

const SplitLine = struct { op: []u8, rest: []u8 };
fn split_line(line: []u8) ?SplitLine {
    if (line.len >= 3) {
        const op = line[0..3];
        const rest = line[3..line.len];
        return .{ .op = op, .rest = rest };
    }

    return null;
}

fn log_line_conversion(line: []u8, inst: BinInst) !void {
    var outputBuf: [1024]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&outputBuf);
    var writer = fbs.writer();

    switch (inst) {
        BinInst.single => |value| try std.fmt.format(writer, "{s} => {s}", .{ line, value.opCode }),
        BinInst.double => |value| try std.fmt.format(writer, "{s} => {s} | {s}", .{ line, value.opCode, value.immVal }),
        BinInst.triple => |_| try std.fmt.format(writer, "N/A", .{}),
    }

    std.log.debug("{s}", .{fbs.getWritten()});
}

const opCodeToHexMap = std.ComptimeStringMap(*const [4:0]u8, .{
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

fn convertNumTypeToBinary(input: []const u8) ![8:0]u8 {
    var outputBuf: [9]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&outputBuf);
    var writer = fbs.writer();

    const result = try std.fmt.parseInt(u8, input, 0);
    try std.fmt.format(writer, "{b:0>8}", .{result});
    try writer.writeByte('\x00');
    const ptr: *[8:0]u8 = fbs.getWritten()[0..8 :0];

    return ptr.*;
}

test "convertNumTypeToBinary should return proper results on proper input" {
    const expected = "00010001";

    var inputHex = "0x11".*;
    const result = try convertNumTypeToBinary(&inputHex);
    try std.testing.expect(std.mem.eql(u8, expected, result[0..]));

    var inputDecimal = "17".*;
    const resultDecimal = try convertNumTypeToBinary(&inputDecimal);
    try std.testing.expect(std.mem.eql(u8, expected, resultDecimal[0..]));

    var inputBinary = "0b10001".*;
    const resultBinary = try convertNumTypeToBinary(&inputBinary);
    try std.testing.expect(std.mem.eql(u8, expected, resultBinary[0..]));
}

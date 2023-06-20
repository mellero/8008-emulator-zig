const std = @import("std");
const File = std.fs.File;
const OpenMode = File.OpenMode;

///
/// Read in from assembly input file
/// Output binary
///
pub fn readInputFile() !void {
    const inputFileName = "assembler/program.txt";
    const inputFile = try std.fs.cwd().openFile(inputFileName, .{});
    defer inputFile.close();

    const outputFileName = "assembler/output.txt";
    const outputFile = try std.fs.cwd().createFile(outputFileName, .{});
    defer outputFile.close();

    var buf_reader = std.io.bufferedReader(inputFile.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (split_line(line)) |splitLine| {
            if (splitLine.len == 0) {
                // blank line
                continue;
            }
            if (try line_to_binary(splitLine)) |binary_rep| {
                try write_to_output(outputFile, binary_rep);
                try log_line_binary(line, binary_rep);
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

fn line_to_binary(splitLine: [][]u8) !?BinInst {
    const opCodeHex = opCodeToHexMap.get(splitLine[0]) orelse return null;
    const opBin = try convert_num_to_bin(opCodeHex);

    switch (splitLine.len) {
        1 => return BinInst{ .single = .{ .opCode = opBin } },
        2 => {
            var imm = splitLine[1];
            const immBin = try convert_num_to_bin(imm);
            return BinInst{ .double = .{ .opCode = opBin, .immVal = immBin } };
        },
        3 => {
            var low = splitLine[1];
            var high = splitLine[2];
            const lowBits = try convert_num_to_bin(low);
            const highBits = try convert_num_to_bin(high);
            return BinInst{ .triple = .{ .opCode = opBin, .memLow = lowBits, .memHigh = highBits } };
        },
        else => return null,
    }
}

fn split_line(line: []u8) ?[][]u8 {
    var arr: [3][]u8 = undefined;
    const lineTrimmed = std.mem.trim(u8, line, " ");
    var spliterator = std.mem.splitSequence(u8, lineTrimmed, " ");

    var i: u8 = 0;
    while (spliterator.next()) |splitValue| {
        if (i > 2) {
            // Invalid - TODO: handle case better
            return null;
        }

        var trimmed = std.mem.trim(u8, splitValue, " ");

        if (trimmed.len > 0) {
            arr[i] = @constCast(trimmed);
            i += 1;
        }
    }

    if (i == 0) {
        // Empty line
        return null;
    }

    return arr[0..i];
}

test "split_line should return null on empty string" {
    const blankInput = "";
    const blankResult = split_line(blankInput);
    try std.testing.expect(blankResult == null);

    const manySpaceInput = "            "[0..];
    const manySpaceResult = split_line(@constCast(manySpaceInput));
    try std.testing.expect(manySpaceResult == null);
}

test "split_line should return proper split on valid string" {
    // Not a great test, just to keep API honest for now
    const input = "ABA 123123"[0..];
    if (split_line(@constCast(input))) |result| {
        const op = result[0];
        const rest = result[1];
        try std.testing.expect(std.mem.eql(u8, op, input[0..3]));
        try std.testing.expect(std.mem.eql(u8, rest, input[4..]));
    }
}

fn write_to_output(file: File, inst: BinInst) !void {
    const writer = file.writer();
    switch (inst) {
        BinInst.single => |value| try std.fmt.format(writer, "|{s}|", .{value.opCode}),
        BinInst.double => |value| try std.fmt.format(writer, "|{s} {s}|", .{ value.opCode, value.immVal }),
        BinInst.triple => |value| try std.fmt.format(writer, "|{s} {s} {s}|", .{ value.opCode, value.memLow, value.memHigh }),
    }
}

fn log_line_binary(line: []u8, inst: BinInst) !void {
    var outputBuf: [1024]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&outputBuf);
    var writer = fbs.writer();

    switch (inst) {
        BinInst.single => |value| try std.fmt.format(writer, "{s} => {s}", .{ line, value.opCode }),
        BinInst.double => |value| try std.fmt.format(writer, "{s} => {s} | {s}", .{ line, value.opCode, value.immVal }),
        BinInst.triple => |value| try std.fmt.format(writer, "{s} => {s} | lo: {s} hi: {s}", .{ line, value.opCode, value.memLow, value.memHigh }),
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
    .{ "JMP", "0xCE" },
});

fn convert_num_to_bin(input: []const u8) ![8:0]u8 {
    var outputBuf: [9]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&outputBuf);
    var writer = fbs.writer();

    const result = try std.fmt.parseInt(u8, input, 0);
    try std.fmt.format(writer, "{b:0>8}", .{result});
    try writer.writeByte('\x00');
    const ptr: *[8:0]u8 = fbs.getWritten()[0..8 :0];

    return ptr.*;
}

test "convert_num_to_bin should return proper results on proper input" {
    const expected = "00010001";

    var inputHex = "0x11".*;
    const result = try convert_num_to_bin(&inputHex);
    try std.testing.expect(std.mem.eql(u8, expected, result[0..]));

    var inputDecimal = "17".*;
    const resultDecimal = try convert_num_to_bin(&inputDecimal);
    try std.testing.expect(std.mem.eql(u8, expected, resultDecimal[0..]));

    var inputBinary = "0b10001".*;
    const resultBinary = try convert_num_to_bin(&inputBinary);
    try std.testing.expect(std.mem.eql(u8, expected, resultBinary[0..]));
}

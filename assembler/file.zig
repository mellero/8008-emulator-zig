const std = @import("std");
const File = std.fs.File;
const OpenMode = File.OpenMode;

const op_codes_to_hex_map = @import("op_codes.zig").op_code_to_hex_map;

///
/// Read in from assembly input file
/// Output binary
///
pub fn readInputFile() !void {
    std.log.debug("============ Running Assembler ===========", .{});
    const input_file_name = "assembler/program.txt";
    const input_file = try std.fs.cwd().openFile(input_file_name, .{});
    defer input_file.close();

    const output_file_name = "assembler/output.txt";
    const output_file = try std.fs.cwd().createFile(output_file_name, .{});
    defer output_file.close();

    var buf: [1024]u8 = undefined;
    var out_writer = output_file.writer(&buf);
    const writer = &out_writer.interface;

    var in_buf: [1024]u8 = undefined;
    var in_f_reader = std.fs.File.Reader.init(input_file, &in_buf);
    var in_reader = &in_f_reader.interface;

    while (in_reader.takeDelimiter('\n')) |maybe_line| {
        if (maybe_line) |line| {
            if (splitLine(line)) |split_line| {
                if (split_line.len == 0) {
                    // blank line
                    continue;
                }
                if (try lineToBinary(split_line)) |binary_rep| {
                    try writeToOutput(writer, binary_rep);
                    try logLineToBinary(line, binary_rep);
                } else {
                    std.log.debug(">> Bad input line {s}", .{line});
                }
            }
        } else {
            // EOF
            break;
        }

    } else |err| switch(err) {
        error.ReadFailed,
        error.StreamTooLong,
        => |e| return e,
    }
    std.log.debug("======= Finished Running Assembler ======", .{});
}

const BinaryByte = [8:0]u8;
const SingleInst = struct { opCode: BinaryByte };
const DoubleInst = struct { opCode: BinaryByte, immVal: BinaryByte };
const TripleInst = struct { opCode: BinaryByte, memLow: BinaryByte, memHigh: BinaryByte };
const InstTag = enum { single, double, triple };
const BinInst = union(InstTag) { single: SingleInst, double: DoubleInst, triple: TripleInst };

fn lineToBinary(split_line: [][]u8) !?BinInst {
    const op_code_hex = op_codes_to_hex_map.get(split_line[0]) orelse return null;
    const op_bin = try convertToBin(op_code_hex);

    switch (split_line.len) {
        1 => return BinInst{ .single = .{ .opCode = op_bin } },
        2 => {
            const imm = split_line[1];
            const imm_bin = try convertToBin(imm);
            return BinInst{ .double = .{ .opCode = op_bin, .immVal = imm_bin } };
        },
        3 => {
            const low = split_line[1];
            const high = split_line[2];
            const low_bits = try convertToBin(low);
            const high_bits = try convertToBin(high);
            return BinInst{ .triple = .{ .opCode = op_bin, .memLow = low_bits, .memHigh = high_bits } };
        },
        else => return null,
    }
}

fn splitLine(line: []u8) ?[][]u8 {
    var arr: [3][]u8 = undefined;
    const line_trimmed = std.mem.trim(u8, line, " ");
    var spliterator = std.mem.splitSequence(u8, line_trimmed, " ");

    var i: u8 = 0;
    while (spliterator.next()) |split_val| {
        if (i > 2) {
            // Invalid - TODO: handle case better
            return null;
        }

        const trimmed = std.mem.trim(u8, split_val, " ");

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

test "splitLine should return null on empty string" {
    const blank_input = "";
    const blank_result = splitLine(blank_input);
    try std.testing.expect(blank_result == null);

    const many_space_input = "            "[0..];
    const many_space_result = splitLine(@constCast(many_space_input));
    try std.testing.expect(many_space_result == null);
}


test "splitLine should return proper split on valid string" {
    // Not a great test, just to keep API honest for now
    const input = "ABA 123123"[0..];
    if (splitLine(@constCast(input))) |result| {
        const op = result[0];
        const imm = result[1];
        try std.testing.expect(std.mem.eql(u8, op, input[0..3]));
        try std.testing.expect(std.mem.eql(u8, imm, input[4..]));
    }
}

fn writeToOutput(writer: *std.io.Writer, inst: BinInst) !void {
    _ = switch (inst) {
        BinInst.single => |value| try writer.print("{s}", .{value.opCode}),
        BinInst.double => |value| try writer.print("{s}{s}", .{ value.opCode, value.immVal }),
        BinInst.triple => |value| try writer.print("{s}{s}{s}", .{ value.opCode, value.memLow, value.memHigh }),
    };
    try writer.flush();
}

fn logLineToBinary(line: []u8, inst: BinInst) !void {
    var output_buf: [1024]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&output_buf);
    const writer = fbs.writer();

    switch (inst) {
        BinInst.single => |value| try std.fmt.format(writer, "{s} => {s}", .{ line, value.opCode }),
        BinInst.double => |value| try std.fmt.format(writer, "{s} => {s} | {s}", .{ line, value.opCode, value.immVal }),
        BinInst.triple => |value| try std.fmt.format(writer, "{s} => {s} | lo: {s} hi: {s}", .{ line, value.opCode, value.memLow, value.memHigh }),
    }

    std.log.debug("{s}", .{fbs.getWritten()});
}

fn convertToBin(input: []const u8) ![8:0]u8 {
    var output_buf: [9]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&output_buf);
    var writer = fbs.writer();

    const result = try std.fmt.parseInt(u8, input, 0);
    try std.fmt.format(writer, "{b:0>8}", .{result});
    try writer.writeByte('\x00');
    const ptr: *[8:0]u8 = fbs.getWritten()[0..8 :0];

    return ptr.*;
}

test "convertToBin should return proper results on proper input" {
    const expected = "00010001";

    var input_hex = "0x11".*;
    const result = try convertToBin(&input_hex);
    try std.testing.expect(std.mem.eql(u8, expected, result[0..]));

    var input_decimal = "17".*;
    const result_decimal = try convertToBin(&input_decimal);
    try std.testing.expect(std.mem.eql(u8, expected, result_decimal[0..]));

    var input_bin = "0b10001".*;
    const result_bin = try convertToBin(&input_bin);
    try std.testing.expect(std.mem.eql(u8, expected, result_bin[0..]));
}

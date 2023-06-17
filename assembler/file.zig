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
        std.log.debug("{s}", .{line});
        if (opCode(line)) |op| {
            std.log.debug("OP HEX: {s}\n", .{op});
        } else {
            std.log.debug("Found bad opcode {s}\n", .{line});
        }
    }
}

fn opCode(line: []u8) ?*const [2:0]u8 {
    const op = line[0..3];
    return map.get(op);
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

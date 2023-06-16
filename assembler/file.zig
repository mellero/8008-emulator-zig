const std = @import("std");

///
/// Read in from assembly input file
/// Output binary
///
fn read() !void {
    const file_name = "program.txt";
    var file = try std.fs.cwd().openFile(file_name, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        std.log.debug("{s}", .{line});
    }
}

// test "expect" {
// 	const program =
// 		\\LAI 15
// 		\\LBA
// 		\\ADB
// 		\\ADI 15
// 	;
// 	_ = program;
// }

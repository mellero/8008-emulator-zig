const std = @import("std");

pub const MAX_MEM = 16384;
pub var RAM: [MAX_MEM]u8 = std.mem.zeroes([MAX_MEM]u8);

pub fn LOAD_MEM() !void {
    std.log.debug("============== Loading RAM ==============", .{});
    const input_file_name = "assembler/output.txt";
    const input_file = try std.fs.cwd().openFile(input_file_name, .{ .mode = .read_only });
    defer input_file.close();

    var in_buf: [8]u8 = undefined;
    var in_f_reader = std.fs.File.Reader.init(input_file, &in_buf);
    var in_reader = &in_f_reader.interface;
    
    var idx: usize = 0;
    while (true) {
        const read_len = in_reader.readSliceShort(&in_buf) catch |err| switch (err) {
            error.ReadFailed => break,
        };

        if (read_len == 0) {
            break;
        }

        if (read_len < in_buf.len) {
            std.log.debug("Could not read byte {s}", .{in_buf});
            return error.ShortStream;
        }

        if (idx > MAX_MEM) {
            std.log.debug("File too large", .{});
            return error.FileTooLarge;
        }

        const intVal: u8 = binStrToInt(@constCast(&in_buf));
        std.log.debug("read {s} => val {}", .{in_buf, intVal});

        RAM[idx] = intVal;
        
        idx += 1;

        std.log.debug("Read from input: '{s}'", .{in_buf});
    }

    std.log.debug("========= Finished Loading RAM =========", .{});
    std.log.debug("Loaded RAM: '{x}'", .{RAM[0..idx]});
}

pub fn READ_MEM(adrs: u16) u8 {
    return RAM[adrs];
}

pub fn WRITE_MEM(adrs: u16, value: u8) void {
    RAM[adrs] = value;
}

fn binStrToInt(str: *const [8]u8) u8 {
    const byteInt = std.fmt.parseInt(u8, str, 2) catch |err| {
        switch (err) {
            error.InvalidCharacter, error.Overflow => return 127,
        }
        return 127;
    };
    return byteInt;
}

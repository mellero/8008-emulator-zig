const std = @import("std");

pub const MAX_MEM = 16384;
pub const RAM = std.mem.zeroes([MAX_MEM]u8);

pub fn LOAD_MEM() void {
    const ASMFILE = "./output.txt";
    _ = ASMFILE;
    // FILE* memfile;
    // char valueRead[8];
    // char* endptr;
    // long val;

    // memfile = fopen(ASMFILE, "r");
    // fseek(memfile, 0L, SEEK_END);
    // long sizeOfFile = ftell(memfile) / 8;
    // rewind(memfile);

    // printf("file %s is %ld bytes\n", ASMFILE, sizeOfFile);

    // int idx = 0;
    // while (fread(&valueRead, sizeof (char), 8, memfile) == 8) {

    //     val = strtol((char *)(&valueRead), &endptr, 2);

    //     if (idx >= MAX_MEM) { break; }

    //     RAM[idx++] = (uint8_t) val;

    //     printf("%ld\n", val);
    // }
}

pub fn READ_MEM(adrs: u16) u8 {
    return RAM[adrs];
}

pub fn WRITE_MEM(adrs: u16, value: u8) void {
    RAM[adrs] = value;
}

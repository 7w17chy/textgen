const std = @import("std");
const File = std.fs.File;
const fs = std.fs;
const os = std.os;
const reader = @import("./reader.zig");
const syntax = @import("./syntax.zig");

pub fn main() anyerror!void {
    var global_allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer global_allocator.deinit();

    // open and read file
    var reader_file: reader.Reader = blk: {
        // TODO: find a better solution
        var direct = try fs.openDirAbsolute("/home/thulis/devel/zig/textgen/res/", .{ .access_sub_paths = true });
        const file = try direct.openFile("test.txt", .{ .read = true });
        defer direct.close();
        defer file.close();

        var rdr = try reader.Reader.initFile(file);
        break :blk rdr;
    };

    // collect metainfo from file
    const metainfo = blk: {
        var lns = std.ArrayList(reader.Line).init(&global_allocator.allocator);
        while (reader_file.line()) |line| {
            const contents = reader.LineContents.determine(&line);
            switch (contents) {
                .Text => if (line.contents[0] == '#') try lns.append(line),
                else => continue,
            }
        }

        break :blk lns.toOwnedSlice();
    };

    for (metainfo) |line| {
        std.debug.warn("Contents: {}\n", .{line});
    }
}

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
    // TODO: newlines in between will break the loop, file also shouldn't start with newlines or spaces
    const metainfo = blk: {
        var lns = std.ArrayList(reader.Line).init(&global_allocator.allocator);
        while (reader_file.filterLine(struct {
            pub fn filter(src: []const u8) bool {
                if (src[0] == '#') return true;
                return false;
            }
        }.filter)) |line| {
            try lns.append(line);
        }

        break :blk lns.toOwnedSlice();
    };

    for (metainfo) |line| {
        std.debug.warn("Contents: {}\n", .{line});
    }
}

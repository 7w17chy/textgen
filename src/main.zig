const std = @import("std");
const File = std.fs.File;
const fs = std.fs;
const os = std.os;
const reader = @import("./reader.zig");
const syntax = @import("./syntax.zig");

pub fn main() anyerror!void {
    var reader_file: reader.Reader = blk: {
        // TODO: find a better solution
        var direct = try fs.openDirAbsolute("/home/thulis/devel/zig/textgen/res/", .{ .access_sub_paths = true });
        const file = try direct.openFile("test.txt", .{ .read = true });
        defer direct.close();
        defer file.close();

        var rdr = try reader.Reader.initFile(file);
        break :blk rdr;
    };

    while (reader_file.filterLine(struct {
        pub fn filter(src: []const u8) bool {
            if (src[0] == '#') return true;
            std.debug.warn("Contents: {}, beginning: {}", .{ src, src[0] });
            return false;
        }
    }.filter)) |line| {
        std.debug.warn("{}\n", .{line});
    }
}

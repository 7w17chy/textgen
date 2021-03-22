const std = @import("std");
const reader = @import("./reader.zig");
const syntax = @import("./syntax.zig");

pub fn main() anyerror!void {
    const annot: syntax.Annotation = syntax.Annotation{ .floskel = syntax.Floskel() };
    const r: reader.Reader = undefined;
}

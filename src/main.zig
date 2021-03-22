const reader = @import("./reader.zig");

pub fn main() anyerror!void {
    const annot: Annotation = Annotation{ .floskel = Floskel() };
    const r: reader.Reader = undefined;
}

const Annotation = union(enum) {
    pronomen: Pronomen,
    floskel: comptime type,
    artikel: Artikel,
    anrede: comptime type,
};

pub fn Anrede() type {
    return struct {
        formal: bool = undefined,
        gender: Gender = undefined,
        titel: ?[]const u8 = undefined,
        custom: ?[]const u8 = undefined,
    };
}

const Gender = enum {
    Female,
    Male,
    Diverse,
};

const Artikel = enum {
    der,
    die,
    das,
};

const PSingular = enum(u8) {
    du = 2,
    ich = 3,
    ersiees,

    pub fn getStringSize(self: PSingular) usize {
        return switch (self) {
            .ich => @enumToInt(.ich),
            .du => @enumToInt(.du),
            .ersiees => 7,
        };
    }
};

const PPlural = enum {
    wir,
    ihr,
    sie,

    pub fn getStringSize(self: PPlural) usize {
        return 3;
    }
};

const Pronomen = union(enum) {
    singular: PSingular,
    plural: PPlural,
};

//pub fn Floskel(comptime tags: type) type {
pub fn Floskel() type {
    // TODO: check that `tags` is an arraylist of tags
    return struct {
        tags: std.ArrayList([]const u8) = undefined,
        string: []const u8 = undefined,
    };
}

const Expandable = struct {
    annot: Annotation,
    index: usize,

    pub fn updateIndex(self: *Expandable, new_index: usize) void {
        self.index = new_index;
    }
};

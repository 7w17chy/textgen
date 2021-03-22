const std = @import("std");
const File = std.fs.File;
const Arena = std.heap.ArenaAllocator;
const eql = std.mem.eql;
const expect = std.testing.expect;
const debug = std.debug;

pub fn main() anyerror!void {
    const annot: Annotation = Annotation{ .floskel = Floskel() };

    var allocator = Arena.init(std.heap.page_allocator);
    defer allocator.deinit();

    var line: Line = Line.init(null, "  A     very    long    line          indeed  ");
    const words: []Word = try line.words(&allocator);

    debug.warn("Len of words: {}\n", .{words.len});
    for (words) |word, index| {
        debug.warn("{}: {}\n", .{ index, word.contents });
    }
    // expect(eql(u8, words[0].contents, "A"));
    // expect(eql(u8, words[1].contents, "very"));
    // expect(eql(u8, words.*[2].contents, "long"));
    // expect(eql(u8, words.*[3].contents, "line"));
    // expect(eql(u8, words.*[4].contents, "indeed"));
}
/// Longest Lifetime: Responsible for (de-)allocating file + resources,
/// all other actions happen on slices into `resource`
// TODO: implement iterator
const Reader = struct {
    resource: []const u8,
    jmp_pts: []usize, // stored indexes into `resource`. should be a hashmap
    cursor: usize,
    last_newline: ?usize, // for `line`: even if the cursor is in the middle of the line, it should be able to return an entire line (last newline to next)
    allocator: Arena,

    // TODO: initializing from file, stdin, a buffer, ...
    pub fn initBuffer(buff: []const u8) error{ OutOfMemory, EmptyBuffer }!Reader {
        if (buff.len == 0) return error.EmptyBuffer;
        var self: Reader = init();
        errdefer self.deinit();
        self.resource = buff;
        self.jmp_pts = try self.allocator.allocator.alloc(usize, 10);
        return self;
    }

    fn init() Reader {
        return .{
            .resource = undefined,
            .jmp_pts = undefined,
            .cursor = 0,
            .last_newline = null,
            .allocator = Arena.init(std.heap.page_allocator),
        };
    }

    pub fn deinit(self: *Reader) void {
        self.allocator.deinit();
    }

    pub fn initFile(file: File) !Reader {
        var self = init();
        errdefer self.deinit();
        const filesize = try file.stat();
        self.jmp_pts = try self.allocator.create([10]usize);
        self.resource = try file.readToEndAlloc(&self.allocator, filesize);
    }

    pub fn saveCursorPos(self: *Reader) void {
        self.jmp_pts.add(self.cursor);
    }

    pub fn line(self: *Reader) ?[]const u8 {
        const lnl = if (self.last_newline) |ln| ln + 1 else 0;
        if (lnl == self.resource.len) return null;
        var i: usize = lnl + 1;
        while (i < self.resource.len and self.resource[i] != '\n') : (i += 1) {}
        self.last_newline = i; // update index of last newline found
        //std.debug.warn("Returning from line: ind. {} to {}, `{}`\n", .{ lnl, i, self.resource[lnl..i] });
        return self.resource[lnl..i];
    }
};

const Word = struct {
    contents: []const u8,

    pub fn init(string: []const u8) Word {
        return .{
            .contents = string,
        };
    }
};

// TODO: implement iterator
const Line = struct {
    /// line number
    number: ?usize,
    cursor: usize,
    contents: []const u8,

    pub fn init(num: ?usize, data: []const u8) Line {
        return .{
            .number = num,
            .cursor = 0,
            .contents = data,
        };
    }

    /// Returns a copy of its contents with unneccessary tabs, newlines, spaces, ... stripped
    pub fn tidy(self: *Line, allocator: *std.heap.Allocator) *[]u8 {}

    fn isNoise(charact: u8) bool {
        return (charact == '\t' or charact == '\n' or charact == ' ');
    }

    // only sublices may be given and the return value added to the start
    // index of the sublice!
    fn skipNoise(string: []const u8) error{EndOfSliceWithoutResult}!usize {
        var i: usize = 0;
        return while (i < string.len) : (i += 1) {
            if (!isNoise(string[i])) break i;
        } else error.EndOfSliceWithoutResult;
    }

    // only sublices may be given and the return value added to the start
    // index of the sublice!
    fn skipNotNoise(string: []const u8) error{EndOfSliceWithoutResult}!usize {
        var i: usize = 0;
        return while (i < string.len) : (i += 1) {
            if (isNoise(string[i])) break i;
        } else error.EndOfSliceWithoutResult;
    }

    pub fn words(self: *Line, allocator: *Arena) ![]Word {
        var wrds = std.ArrayList(Word).init(&allocator.allocator);

        var i: usize = 0; // TODO: we can probably get rid of `i` -> use `wb` instead, more readable
        var wb: usize = 0;
        var we: usize = 0;
        var count: usize = 0;

        // "  A     very    long    line          indeed  "
        i = try skipNoise(self.contents[0..]);
        while (i <= self.contents.len) {
            wb = i;
            we = i + (skipNotNoise(self.contents[wb..]) catch self.contents.len);
            if ((we - wb) > 0) try wrds.append(Word.init(self.contents[wb..we]));
            i += skipNoise(self.contents[we..]) catch self.contents.len;
        }

        return wrds.toOwnedSlice();
    }
};

test "isNoise" {
    expect(Line.isNoise('\n') == true);
    expect(Line.isNoise('\t') == true);
    expect(Line.isNoise(' ') == true);
    expect(Line.isNoise('a') == false);
}

test "skip noise" {
    //              012345
    const string = "     henlo";
    const first_non_noise = try Line.skipNoise(string[0..]);
    expect(first_non_noise == 5);
}

test "skip not-noise" {
    //              012345678
    const string = "einsdrei    ";
    const first_noise_index = try Line.skipNotNoise(string[0..]);
    expect(first_noise_index == 8);
}

test "Line.words" {
    var allocator = Arena.init(std.heap.page_allocator);
    defer allocator.deinit();

    var line: Line = Line.init(null, "  A     very    long    line          indeed  ");
    const words: []Word = try line.words(&allocator);

    expect(eql(u8, words[0].contents, "A"));
    expect(eql(u8, words[1].contents, "very"));
    expect(eql(u8, words[2].contents, "long"));
    expect(eql(u8, words[3].contents, "line"));
    expect(eql(u8, words[4].contents, "indeed"));
}

test "Reader: read lines" {
    const txt =
        \\ Some text
        \\ hopefully with
        \\ newlines!
    ;

    var reader = Reader.initBuffer(txt) catch unreachable;

    expect(eql(u8, reader.line().?, " Some text"));
    expect(eql(u8, reader.line().?, " hopefully with"));
    expect(eql(u8, reader.line().?, " newlines!"));
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

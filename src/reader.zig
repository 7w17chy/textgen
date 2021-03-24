const std = @import("std");
const File = std.fs.File;
const Arena = std.heap.ArenaAllocator;
const eql = std.mem.eql;
const expect = std.testing.expect;
const debug = std.debug;
const io = std.io;
/// Longest Lifetime: Responsible for (de-)allocating file + resources,
/// all other actions happen on slices into `resource`
// TODO: implement iterator
pub const Reader = struct {
    resource: []const u8,
    jmp_pts: []usize, // stored indexes into `resource`. should be a hashmap. or indexing could be done via an enum
    cursor: usize,
    last_newline: ?usize, // for `line`: even if the cursor is in the middle of the line, it should be able to return an entire line (last newline to next)
    allocator: Arena,

    /// Indices into `Reader.jmp_pts`: Saves important indices into `Reader.resources`, namely where meta
    /// information is stored or where the actual text begins/ends.
    const FixedIndices = enum {
        META_BEGIN,
        META_END,
    };

    /// Set the cursor to the specified position in the buffer. `last_newline` also gets reset.
    pub fn setCursorPos(new_pos: usize) error{IndexOutOfBounds}!void {
        if (new_pos < self.resource.len or new_pos > self.resource.len) return error.IndexOutOfBounds;
        self.cursor = new_pos;

        // search backwards for a newline character
        var i: usize = self.cursor;
        while (self.resource[i] != '\n' and i > self.resource.len) : (i -= 1) {}
        self.last_newline = i;
    }

    // TODO: initializing from file, stdin, a buffer, ...
    pub fn initBuffer(buff: []const u8) error{ OutOfMemory, EmptyBuffer }!Reader {
        if (buff.len == 0) return error.EmptyBuffer;
        var self: Reader = init();
        errdefer self.deinit();
        self.resource = buff;
        self.jmp_pts = try self.allocator.allocator.alloc(usize, 10);
        return self;
    }

    /// Constructor
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
        self.jmp_pts = try self.allocator.allocator.alloc(usize, 10);
        self.resource = try file.readToEndAlloc(&self.allocator.allocator, filesize.size);

        return self;
    }

    pub fn saveCursorPos(self: *Reader) void {
        self.jmp_pts.add(self.cursor);
    }

    pub fn line(self: *Reader) ?Line {
        const lnl = if (self.last_newline) |ln| ln + 1 else 0;
        if (lnl == self.resource.len) return null;
        var i: usize = lnl + 1;
        while (i < self.resource.len and self.resource[i] != '\n') : (i += 1) {}
        self.last_newline = i; // update index of last newline found
        //std.debug.warn("Returning from line: ind. {} to {}, `{}`\n", .{ lnl, i, self.resource[lnl..i] });
        return Line.init(null, self.resource[lnl..i]);
    }

    /// only return Line if filterFn returns true. It's argument is the contents of the line.
    pub fn filterLine(self: *Reader, filterFn: fn (src: []const u8) bool) ?Line {
        const ln: Line = self.line() orelse return null;
        if (filterFn(ln.contents)) {
            return ln;
        }
        return null;
    }
};

pub const Word = struct {
    contents: []const u8,

    pub fn init(string: []const u8) Word {
        return .{
            .contents = string,
        };
    }
};

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

// TODO: implement iterator
pub const Line = struct {
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

    pub fn words(self: *Line, allocator: *Arena) ![]Word {
        // var wrds = std.ArrayList(Word).init(&allocator.allocator);

        // var wb: usize = 0;
        // var we: usize = 0;
        // var count: usize = 0;

        // wb = try skipNoise(self.contents[0..]);
        // while (wb <= self.contents.len) {
        //     we = wb + (skipNotNoise(self.contents[wb..]) catch self.contents.len);
        //     if ((we - wb) > 0) try wrds.append(Word.init(self.contents[wb..we]));
        //     wb += skipNoise(self.contents[we..]) catch self.contents.len;
        // }

        // return wrds.toOwnedSlice();

        // reduce code duplication
        return self.filterWords(allocator, struct {
            pub fn filter(src: []const u8) bool {
                return true;
            }
        }.filter);
    }

    pub fn filterWords(self: *Line, allocator: *Arena, filterFn: fn (src: []const u8) bool) ![]Word {
        var wrds = std.ArrayList(Word).init(&allocator.allocator);

        var wb: usize = 0;
        var we: usize = 0;
        var count: usize = 0;

        wb = try skipNoise(self.contents[0..]);
        while (wb <= self.contents.len) {
            we = wb + (skipNotNoise(self.contents[wb..]) catch self.contents.len);
            if ((we - wb) > 0 and filterFn(self.contents[wb..we])) {
                try wrds.append(Word.init(self.contents[wb..we]));
            }
            wb += skipNoise(self.contents[we..]) catch self.contents.len;
        }

        return wrds.toOwnedSlice();
    }
};

test "isNoise" {
    expect(isNoise('\n') == true);
    expect(isNoise('\t') == true);
    expect(isNoise(' ') == true);
    expect(isNoise('a') == false);
}

test "skip noise" {
    //              012345
    const string = "     henlo";
    const first_non_noise = try skipNoise(string[0..]);
    expect(first_non_noise == 5);
}

test "skip not-noise" {
    //              012345678
    const string = "einsdrei    ";
    const first_noise_index = try skipNotNoise(string[0..]);
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

    expect(eql(u8, reader.line().?.contents, " Some text"));
    expect(eql(u8, reader.line().?.contents, " hopefully with"));
    expect(eql(u8, reader.line().?.contents, " newlines!"));
}

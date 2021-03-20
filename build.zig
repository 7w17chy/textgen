const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("textgen", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.linkLibC();

    exe.addIncludeDir("/usr/include/gtk-3.0");

    // inlcudes/links: https://github.com/donpdonp/zootdeck/blob/master/build.zig
    exe.addIncludeDir("/usr/include");
    exe.addIncludeDir("/usr/include/x86_64-linux-gnu");
    exe.addLibPath("/usr/lib");
    exe.addLibPath("/usr/lib/x86_64-linux-gnu");

    exe.linkSystemLibrary("c");

    // gtk3
    exe.linkSystemLibrary("glib-2.0");
    exe.linkSystemLibrary("gdk-3.0");
    exe.linkSystemLibrary("gdk_pixbuf-2.0");
    exe.linkSystemLibrary("gtk-3");
    exe.linkSystemLibrary("gobject-2.0");
    exe.linkSystemLibrary("gmodule-2.0");
    exe.linkSystemLibrary("pango-1.0");
    exe.linkSystemLibrary("atk-1.0");

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

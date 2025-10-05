const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const osdialog_dep = b.dependency("osdialog", .{});

    const lib_mod = b.addModule("osdialog", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Now, we will create a static library based on the module we created above.
    // This creates a `std.Build.Step.Compile`, which is the build step responsible
    // for actually invoking the compiler.
    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "osdialog",
        .root_module = lib_mod,
    });

    lib.linkLibC();

    lib.addIncludePath(osdialog_dep.path("osdialog.h"));

    lib.addCSourceFile(.{ .file = osdialog_dep.path("osdialog.c") });

    if (builtin.os.tag == .linux) {
        lib.linkSystemLibrary("gtk+-3.0");
        lib.addCSourceFile(.{ .file = osdialog_dep.path("osdialog_gtk3.c") });
    } else if (builtin.os.tag == .windows) {
        lib.linkSystemLibrary("comdlg32");
        lib.addCSourceFile(.{ .file = osdialog_dep.path("osdialog_win.c") });
    } else if (builtin.os.tag.isDarwin()) {
        lib.linkFramework("AppKit");
        lib.addCSourceFile(.{ .file = osdialog_dep.path("osdialog_mac.m") });
    }

    b.installArtifact(lib);

    const module = b.addModule("osdialog", .{
        .root_source_file = b.path("src/lib.zig"),
        .target = target,
        .optimize = optimize,
    });

    module.linkLibrary(lib);
}

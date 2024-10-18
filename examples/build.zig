const std = @import("std");

pub fn build(b: *std.Build) void {
	const target = b.standardTargetOptions(.{});
	const optimize = b.standardOptimizeOption(.{});

	const dep = b.dependency("os_open", .{
		.target = target,
		.optimize = optimize,
	});

	const exe = b.addExecutable(.{
		.name = "os_open-examples",
		.root_source_file = b.path("src/main.zig"),
		.target = target,
		.optimize = optimize,
	});
	exe.root_module.addImport("os_open", dep.module("os_open"));
	b.installArtifact(exe);

	const run_cmd = b.addRunArtifact(exe);
	run_cmd.step.dependOn(b.getInstallStep());
	if (b.args) |args| {
		run_cmd.addArgs(args);
	}

	const run_step = b.step("run", "Run the app");
	run_step.dependOn(&run_cmd.step);
}

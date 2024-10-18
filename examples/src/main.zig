const std = @import("std");
const open = @import("os_open");

pub fn main() void {
	_ = open.message("Hello, World!", .{});
	if (!open.message("Do you want to continue?", .{ .buttons = .yes_no })) {
		std.process.exit(0);
	}
	if (open.prompt("Give me some input", .{})) |input| {
		std.debug.print("Input: {s}\n", .{input});
	}
	if (open.colorPicker(.{ .color = .{ .r = 247, .g = 163, .b = 29, .a = 255 } })) |selected| {
		std.debug.print("Color RRR,GGG,BBB,AAA: {d},{d},{d},{d}\n", .{ selected.r, selected.g, selected.b, selected.a });
	}
	if (open.filePath(.{})) |path| {
		std.debug.print("Selected File: {s}\n", .{path});
	}
	if (open.savePath(.{ .path = ".", .filename = "myfile.txt" })) |path| {
		std.debug.print("Save location: {s}\n", .{path});
	}
	_ = open.dirPath(.{});
}

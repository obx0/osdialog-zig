const std = @import("std");

pub const osdialog_color = extern struct { r: u8, g: u8, b: u8, a: u8 };
pub const osdialog_filters = extern struct {};

pub extern fn osdialog_message(level: c_int, buttons: c_int, message: [*c]const u8) c_int;
pub extern fn osdialog_prompt(level: c_int, message: [*c]const u8, text: [*c]const u8) [*c]u8;
pub extern fn osdialog_color_picker(color: *osdialog_color, opacity: c_int) c_int;
pub extern fn osdialog_file(action: c_int, path: [*c]const u8, filename: [*c]const u8, filters: ?*osdialog_filters) [*c]u8;

pub fn toZString(allocator: std.mem.Allocator, c_str_opt: ?[*c]u8) ?[:0]u8 {
	const c_string = c_str_opt orelse return null;
	defer std.c.free(c_string);
	const z_string: [:0]u8 = std.mem.span(c_string);
	return allocator.dupeZ(u8, z_string) catch return null;
}

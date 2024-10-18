const std = @import("std");

const osdialog_color = extern struct { r: u8, g: u8, b: u8, a: u8 };
const osdialog_filters = extern struct {};

extern fn osdialog_message(level: c_int, buttons: c_int, message: [*c]const u8) c_int;
extern fn osdialog_prompt(level: c_int, message: [*c]const u8, text: [*c]const u8) [*c]u8;
extern fn osdialog_color_picker(color: *osdialog_color, opacity: c_int) c_int;
extern fn osdialog_file(action: c_int, path: [*c]const u8, filename: [*c]const u8, filters: ?*osdialog_filters) [*c]u8;

fn toZString(allocator: std.mem.Allocator, c_str_opt: ?[*c]u8) ?[:0]u8 {
	const c_string = c_str_opt orelse return null;
	defer std.c.free(c_string);
	const z_string: [:0]u8 = std.mem.span(c_string);
	return allocator.dupeZ(u8, z_string) catch return null;
}

pub const Buttons = enum {
	ok,
	ok_cancel,
	yes_no,
};

pub const Level = enum {
	info,
	warning,
	err,
};

pub const MessageOptions = struct {
	level: Level = .info,
	buttons: Buttons = .ok,
};

pub const PromptOptions = struct {
	level: Level = .info,
	/// The text that pre-fills the input field.
	text: [*:0]const u8 = "",
};

pub const Color = osdialog_color;

pub const ColorPickerOptions = struct {
	/// The initial color in the color picker.
	color: Color = Color{ .r = 255, .g = 255, .b = 255, .a = 255 },
	/// On linux color dialogs support to disable the opacity slider.
	/// It has no effect on other platforms.
	opacity: bool = true,
};

pub const PathOptions = struct {
	/// The initial path the dialog will attempt to open in.
	path: [*:0]const u8 = "",
	/// The initial filename in the input field.
	filename: [*:0]const u8 = "",
	// TODO:
	filters: ?*osdialog_filters = null,
};

/// Opens a message box and returns `true` if `OK` or `Yes` was pressed.
pub fn message(text: [*:0]const u8, opts: MessageOptions) bool {
	return osdialog_message(@intFromEnum(opts.level), @intFromEnum(opts.buttons), text) == 1;
}

/// Opens an input prompt with an "OK" and "Cancel" button.
pub fn prompt(allocator: std.mem.Allocator, text: [*:0]const u8, opts: PromptOptions) ?[:0]u8 {
	return toZString(allocator, osdialog_prompt(@intFromEnum(opts.level), text, opts.text));
}

/// Opens an RGBA color picker dialog and returns the selected `Color` or `null`
/// if the selection was canceled. The argument takes optional fields that allow
/// to set the inital `color` and to disable the `opacity` on unix-like systems.
pub fn color(options: ColorPickerOptions) ?Color {
	var col = options.color;
	return if (osdialog_color_picker(&col, @intFromBool(options.opacity)) == 1) col else null;
}

/// Opens a file dialog and returns the selected path or `null` if the selection was canceled.
pub fn path(allocator: std.mem.Allocator, action: enum { open, open_dir, save }, options: PathOptions) ?[:0]u8 {
	return toZString(allocator, osdialog_file(@intFromEnum(action), options.path, options.filename, null));
}

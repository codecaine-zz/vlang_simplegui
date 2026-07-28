module simplegui

pub fn (win &SimpleWindow) add_heading(title string) &SimpleWindow {
	heading_name := 'heading_${win.controls.len}'
	win.add_label(heading_name, title)
	win.add_separator()
	return win
}

// Value setters and getters calling the generic name-based C bridge

pub fn (win &SimpleWindow) get_spacing() int {
	return win.spacing
}

// add_group_box adds a group box control to the window layout.

pub fn (win &SimpleWindow) add_group_box(name string, title string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('groupbox')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'groupbox', title, '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_group_box_control(win.window_info, real_name.str, title.str)
	}
	return win
}

// add_tabs adds a tabs control to the window layout.

pub fn (win &SimpleWindow) add_tabs(name string, titles []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('tabs')
	}
	mut joined := ''
	for i, title in titles {
		if i > 0 {
			joined += ','
		}
		joined += title
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'tabs', joined, '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		mut c_titles := []&u8{}
		for title in titles {
			c_titles << title.str
		}
		C.window_add_tabs_control(win.window_info, real_name.str, c_titles.data, titles.len)
	}
	return win
}

// add_scroll_view adds a scroll view control to the window layout.

pub fn (win &SimpleWindow) add_scroll_view(name string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('scrollview')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'scrollview', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_scroll_view_control(win.window_info, real_name.str, height)
	}
	return win
}

// set_focus sets the focus of the window or target control.

pub fn (win &SimpleWindow) begin_row(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_begin_row(win.window_info, name.str)
	}
	return win
}

// end_row ends the current row container layout.

pub fn (win &SimpleWindow) end_row() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_end_row(win.window_info)
	}
	return win
}

// begin_grid begins a multi-column grid layout container with specified column count and item spacing.

pub fn (win &SimpleWindow) begin_grid(name string, columns int, spacing int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_begin_grid(win.window_info, name.str, columns, spacing)
	}
	return win
}

// end_grid ends the current grid layout container.

pub fn (win &SimpleWindow) end_grid() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_end_grid(win.window_info)
	}
	return win
}

// begin_flex_box begins a flexbox container with direction ('row'|'column'), main-axis justification ('start'|'center'|'end'|'space_between'|'space_around'|'fill'), and cross-axis alignment ('start'|'center'|'end'|'stretch').

pub fn (win &SimpleWindow) begin_flex_box(name string, direction string, justify string, align string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_begin_flex_box(win.window_info, name.str, direction.str, justify.str,
			align.str)
	}
	return win
}

// end_flex_box ends the current flexbox container.

pub fn (win &SimpleWindow) end_flex_box() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_end_flex_box(win.window_info)
	}
	return win
}

// Dialogs & Popups

pub fn (win &SimpleWindow) add_vertical_spacer(height int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_add_vertical_spacer(win.window_info, height)
	}
	return win
}

// add_horizontal_spacer adds a horizontal spacer control to the window layout.

pub fn (win &SimpleWindow) add_horizontal_spacer(width int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_add_horizontal_spacer(win.window_info, width)
	}
	return win
}

// add_separator adds a separator control to the window layout.

pub fn (win &SimpleWindow) add_separator() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_add_separator(win.window_info)
	}
	return win
}

pub fn (win &SimpleWindow) add_action_row(actions map[string]VoidEventCallback) &SimpleWindow {
	row_name := win.auto_name('action_row')
	win.begin_row(row_name)
	for title, cb in actions {
		btn_name := win.auto_name('btn')
		win.add_action(btn_name, title, cb)
	}
	win.end_row()
	return win
}

// add_fields_row adds a fields row control to the window layout.

pub fn (win &SimpleWindow) add_fields_row(fields map[string]string) &SimpleWindow {
	row_name := win.auto_name('fields_row')
	win.begin_row(row_name)
	for label, name in fields {
		win.add_form_field(label, name, '')
	}
	win.end_row()
	return win
}

// add_form_from_struct dynamically generates a form in the window layout using the fields of struct T.

pub fn (win &SimpleWindow) row(name string, callback VoidEventCallback) &SimpleWindow {
	win.begin_row(name)
	unsafe {
		mut w := &SimpleWindow(win)
		callback(mut w)
	}
	win.end_row()
	return win
}

// Closure-based grid layout container

pub fn (win &SimpleWindow) grid(name string, columns int, spacing int, callback VoidEventCallback) &SimpleWindow {
	win.begin_grid(name, columns, spacing)
	unsafe {
		mut w := &SimpleWindow(win)
		callback(mut w)
	}
	win.end_grid()
	return win
}

// Closure-based flexbox layout container

pub fn (win &SimpleWindow) flex_box(name string, direction string, justify string, align string, callback VoidEventCallback) &SimpleWindow {
	win.begin_flex_box(name, direction, justify, align)
	unsafe {
		mut w := &SimpleWindow(win)
		callback(mut w)
	}
	win.end_flex_box()
	return win
}

// Theme represents a complete color scheme for SimpleWindow interface styling.

pub fn (win &SimpleWindow) set_control_alignment(name string, alignment string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_control_alignment_by_name(win.window_info, name.str, alignment.str)
	}
	for i in 0 .. win.controls.len {
		if win.controls[i].name == name {
			unsafe {
				win.controls[i].alignment = alignment
			}
			break
		}
	}
	return win
}

// get_control_alignment returns the alignment of a named control.

pub fn (win &SimpleWindow) set_control_expand_fill(name string, expand bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_control_expand_fill_by_name(win.window_info, name.str, if expand {
			1
		} else {
			0
		})
	}
	for i in 0 .. win.controls.len {
		if win.controls[i].name == name {
			unsafe {
				win.controls[i].expand_fill = expand
			}
			break
		}
	}
	return win
}

// get_control_expand_fill returns true if fill expansion is enabled for a named control.

pub fn (win &SimpleWindow) align_left() &SimpleWindow {
	if win.last_control != '' {
		win.set_control_alignment(win.last_control, 'left')
	}
	return win
}

// align_center aligns the last created control to the center.

pub fn (win &SimpleWindow) align_center() &SimpleWindow {
	if win.last_control != '' {
		win.set_control_alignment(win.last_control, 'center')
	}
	return win
}

// align_right aligns the last created control to the right.

pub fn (win &SimpleWindow) align_right() &SimpleWindow {
	if win.last_control != '' {
		win.set_control_alignment(win.last_control, 'right')
	}
	return win
}

// align_top aligns the last created control to the top.

pub fn (win &SimpleWindow) align_top() &SimpleWindow {
	if win.last_control != '' {
		win.set_control_alignment(win.last_control, 'top')
	}
	return win
}

// align_bottom aligns the last created control to the bottom.

pub fn (win &SimpleWindow) align_bottom() &SimpleWindow {
	if win.last_control != '' {
		win.set_control_alignment(win.last_control, 'bottom')
	}
	return win
}

// expand_fill configures the last created control to expand and fill available container space.

pub fn (win &SimpleWindow) expand_fill() &SimpleWindow {
	if win.last_control != '' {
		win.set_control_expand_fill(win.last_control, true)
	}
	return win
}

// Fluent event chaining modifiers (attaching to the last created control)

pub fn (win &SimpleWindow) group(name string, title string, callback VoidEventCallback) &SimpleWindow {
	win.add_group_box(name, title)
	unsafe {
		mut w := &SimpleWindow(win)
		callback(mut w)
	}
	return win
}

// Validation error clearing

pub fn play_sound(sound_name string) {
	C.window_play_system_sound(sound_name.str)
}

// begin_split_view begins a split view container in the layout.

pub fn (win &SimpleWindow) begin_split_view(name string, vertical bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		vert := if vertical { 1 } else { 0 }
		C.window_begin_split_view(win.window_info, name.str, vert)
	}
	return win
}

// split_view_next_pane performs split view next pane.

pub fn (win &SimpleWindow) end_split_view() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_end_split_view(win.window_info)
	}
	return win
}

// add_collection_view adds a collection view control to the window layout.

pub fn (win &SimpleWindow) begin_glass_box(name string, material string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_begin_glass_box(win.window_info, name.str, material.str)
	}
	return win
}

// end_glass_box ends the current glass box container layout.

pub fn (win &SimpleWindow) end_glass_box() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_end_glass_box(win.window_info)
	}
	return win
}

// add_badge adds a badge control to the window layout.

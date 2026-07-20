module main

import simplegui

struct AppState {
mut:
	action_col_enabled bool
}

fn main() {
	mut state := &AppState{
		action_col_enabled: true
	}

	mut win := simplegui.new_simple_window('Editable Grid Showcase', 980, 780)
	win.configure(fn (mut cfg simplegui.WindowConfig) {
		cfg.padding = 16
		cfg.spacing = 10
	})

	win.add_heading('Editable Grid Showcase')
	win.add_label('intro', 'This demo exercises the editable grid with text cells, checkbox cells, button cells, row/column actions, event callbacks, column sorting, and visible cell selection.')

	win.begin_row('toolbar')
		win.add_button('btn_add_row', 'Add Row')
		win.add_button('btn_delete_row', 'Delete Selected Row')
		win.add_button('btn_add_col', 'Add Column')
		win.add_button('btn_delete_col', 'Delete Last Column')
		win.add_button('btn_autosize', 'Auto-size')
		win.add_button('btn_clear', 'Clear Grid')
		win.add_button('btn_sort_grid', 'Sort ID')
		win.add_button('btn_toggle_actions', 'Toggle Action Column')
	win.end_row()

	win.begin_row('filters')
		win.add_input('filter_input', '')
		win.add_button('btn_apply_filter', 'Filter')
		win.add_button('btn_clear_filter', 'Clear Filter')
		win.add_number_field('row_height', 26)
		win.add_button('btn_apply_row_height', 'Apply Row Height')
		win.add_number_field('col_width', 140)
		win.add_button('btn_apply_col_width', 'Apply Col Width')
	win.end_row()

	win.add_grid('demo_grid', ['ID', 'Task', 'Done', 'Action'], [
		['1', 'Draft spec', 'true', 'Run'],
		['2', 'Wire events', 'false', 'View'],
		['3', 'Ship demo', 'true', 'Open']
	])

	win.grid_set_column_type('demo_grid', 2, 'checkbox')
	win.grid_set_column_type('demo_grid', 3, 'button')
	win.grid_set_column_editable('demo_grid', 0, false)
	win.grid_set_row_enabled('demo_grid', 1, false)
	win.grid_set_cell_enabled('demo_grid', 0, 3, false)
	win.grid_set_selected_row('demo_grid', 0)

	win.on_change('demo_grid', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Grid changed: ${value}')
	})

	win.on_change('filter_input', fn (mut w simplegui.SimpleWindow, value string) {
		w.grid_set_filter('demo_grid', value)
		w.set_status('Filtering rows for: ${value}')
	})

	win.on_column_click('demo_grid', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Header clicked: ${value}')
	})

	win.on_cell_button_click('demo_grid', fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Button clicked: ${value}')
	})

	win.on_click('btn_add_row', fn (mut w simplegui.SimpleWindow) {
		w.grid_add_row('demo_grid', ['4', 'New task', 'false', 'Launch'])
		w.grid_autosize_columns('demo_grid')
		w.set_status('Added a new row to the grid.')
	})

	win.on_click('btn_delete_row', fn (mut w simplegui.SimpleWindow) {
		selected_idx := w.grid_get_selected_row('demo_grid')
		if selected_idx >= 0 {
			w.grid_delete_row('demo_grid', selected_idx)
			w.set_status('Deleted selected row ${selected_idx}.')
		} else {
			w.set_status('Select a row first before deleting it.')
		}
	})

	win.on_click('btn_add_col', fn (mut w simplegui.SimpleWindow) {
		w.grid_add_column('demo_grid', 'Notes')
		w.grid_autosize_columns('demo_grid')
		w.set_status('Added a new Notes column.')
	})

	win.on_click('btn_delete_col', fn (mut w simplegui.SimpleWindow) {
		w.grid_delete_column('demo_grid', 3)
		w.set_status('Deleted the last column.')
	})

	win.on_click('btn_autosize', fn (mut w simplegui.SimpleWindow) {
		w.grid_autosize_columns('demo_grid')
		w.set_status('Auto-sized the grid columns.')
	})

	win.on_click('btn_clear', fn (mut w simplegui.SimpleWindow) {
		w.grid_clear('demo_grid')
		w.set_status('Cleared the grid contents.')
	})

	win.on_click('btn_sort_grid', fn (mut w simplegui.SimpleWindow) {
		w.grid_sort_by_column('demo_grid', 0, true)
		w.set_status('Sorted the grid by ID.')
	})

	win.on_click('btn_toggle_actions', fn [mut state] (mut w simplegui.SimpleWindow) {
		state.action_col_enabled = !state.action_col_enabled
		w.grid_set_column_enabled('demo_grid', 3, state.action_col_enabled)
		w.set_status('Action column enabled: ${state.action_col_enabled}')
	})

	win.on_click('btn_apply_filter', fn (mut w simplegui.SimpleWindow) {
		w.grid_set_filter('demo_grid', w.get_text('filter_input'))
		w.set_status('Applied filter to the grid.')
	})

	win.on_click('btn_clear_filter', fn (mut w simplegui.SimpleWindow) {
		w.grid_clear_filter('demo_grid')
		w.set_status('Cleared the grid filter.')
	})

	win.on_click('btn_apply_row_height', fn (mut w simplegui.SimpleWindow) {
		w.grid_set_row_height('demo_grid', w.get_value_int('row_height'))
		w.set_status('Updated the row height.')
	})

	win.on_click('btn_apply_col_width', fn (mut w simplegui.SimpleWindow) {
		w.grid_set_column_width('demo_grid', 0, w.get_value_int('col_width'))
		w.set_status('Updated the first column width.')
	})

	win.set_status('Try editing text cells, toggling checkboxes, clicking action buttons, resizing columns by dragging headers, and filtering rows like Excel or Google Sheets.')
	win.run()
}

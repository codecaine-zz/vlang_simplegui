module main

import simplegui

struct Employee {
	id     int
	name   string
	role   string
	active bool
}

fn main() {
	mut win := simplegui.new_simple_window('Multi-Column Table & Data Grid Demo', 700,
		750)

	// SECTION 1: Multi-Column Table
	win.add_heading('1. Multi-Column Table')
	win.add_table('emp_table', ['ID', 'Name', 'Role', 'Active'])

	win.begin_row('table_btn_row')
	win.add_button('btn_load_structs', 'Load Structs into Table')
	win.add_button('btn_clear_table', 'Clear Table')
	win.end_row()

	win.add_separator()

	// SECTION 2: Editable Data Grid (Spreadsheet Style)
	win.add_heading('2. Editable Data Grid')
	win.add_grid('sheet_grid', ['Product', 'Price', 'In Stock', 'Action'], [
		['Keyboard', '49.99', 'true', 'Order'],
		['Mouse', '25.50', 'true', 'Order'],
		['Monitor', '199.99', 'false', 'Restock'],
	])

	// Configure column types and sizing
	win.grid_set_column_type('sheet_grid', 2, 'checkbox')
	win.grid_set_column_type('sheet_grid', 3, 'button')
	win.grid_set_column_width('sheet_grid', 0, 150)
	win.grid_autosize_columns('sheet_grid')

	win.begin_row('grid_btn_row1')
	win.add_button('btn_grid_add', 'Add Row')
	win.add_button('btn_grid_sort', 'Sort by Price')
	win.add_button('btn_get_cell', 'Read Selected Cell')
	win.end_row()

	win.begin_row('grid_btn_row2')
	win.add_input('grid_search', '')
	win.set_placeholder('grid_search', 'Filter products...')
	win.add_button('btn_filter', 'Apply Filter')
	win.add_button('btn_clear_filter', 'Clear Filter')
	win.end_row()

	// --- Event Handlers: Table ---

	win.on_click('btn_load_structs', fn (mut win simplegui.SimpleWindow) {
		staff := [
			Employee{ id: 101, name: 'Alice Smith', role: 'Developer', active: true },
			Employee{
				id:     102
				name:   'Bob Jones'
				role:   'Designer'
				active: false
			},
			Employee{
				id:     103
				name:   'Charlie Day'
				role:   'Manager'
				active: true
			},
		]
		win.load_table_from_structs('emp_table', staff)
		win.set_status('Loaded ${staff.len} employee structs into table.')
	})

	win.on_click('btn_clear_table', fn (mut win simplegui.SimpleWindow) {
		win.set_table_rows('emp_table', [[]string{}])
		win.set_status('Cleared table rows.')
	})

	// --- Event Handlers: Data Grid ---

	win.on_click('btn_grid_add', fn (mut win simplegui.SimpleWindow) {
		win.grid_add_row('sheet_grid', ['Headphones', '79.00', 'true', 'Order'])
		win.set_status('Appended row to data grid.')
	})

	win.on_click('btn_grid_sort', fn (mut win simplegui.SimpleWindow) {
		win.grid_sort_by_column('sheet_grid', 1, true)
		win.set_status('Sorted grid by Price (Column 1).')
	})

	win.on_click('btn_get_cell', fn (mut win simplegui.SimpleWindow) {
		row, col := win.grid_get_selected_cell('sheet_grid')
		if row >= 0 && col >= 0 {
			val := win.grid_get_cell('sheet_grid', row, col)
			win.set_status('Selected Cell [${row}, ${col}] = "${val}"')
		} else {
			win.set_status('No grid cell selected.')
		}
	})

	win.on_click('btn_filter', fn (mut win simplegui.SimpleWindow) {
		query := win.get_text('grid_search')
		win.grid_set_filter('sheet_grid', query)
		win.set_status('Applied grid filter: "${query}"')
	})

	win.on_click('btn_clear_filter', fn (mut win simplegui.SimpleWindow) {
		win.set_text('grid_search', '')
		win.grid_clear_filter('sheet_grid')
		win.set_status('Cleared grid filter.')
	})

	// --- Grid Event Hooks ---

	win.on_change('sheet_grid', fn (mut win simplegui.SimpleWindow, details string) {
		win.set_status('Grid modified/selected: ${details}')
	})

	win.on_cell_button_click('sheet_grid', fn (mut win simplegui.SimpleWindow, _ string) {
		row, _ := win.grid_get_selected_cell('sheet_grid')
		product := win.grid_get_cell('sheet_grid', row, 0)
		win.info('Action Triggered', 'Button clicked for product "${product}" at row ${row}')
	})

	win.run()
}

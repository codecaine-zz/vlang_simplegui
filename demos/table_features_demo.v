module main

import simplegui

fn main() {
	simplegui.new_simple_window('Table Sorting & Import/Export Demo', 650, 700)
		// 1. Setup Table
		.add_table('data_table', ['ID', 'Name', 'Score'])
		.add_table_rows('data_table', [
			['103', 'Charlie', '88.5'],
			['101', 'Alice', '95.0'],
			['102', 'Bob', '72.0']
		])

		.add_separator()

		// 2. Sorting & Reordering Controls
		.begin_row('row_sort')
			.add_button('btn_sort_num', 'Sort by ID (Asc)')
			.add_button('btn_sort_text', 'Sort by Name (Asc)')
			.add_button('btn_move_up', 'Move Row Up')
			.add_button('btn_move_down', 'Move Row Down')
		.end_row()

		// 3. File Import / Export Controls
		.begin_row('row_io')
			.add_button('btn_save_csv', 'Save CSV')
			.add_button('btn_load_csv', 'Load CSV')
			.add_button('btn_save_json', 'Save JSON')
			.add_button('btn_load_json', 'Load JSON')
		.end_row()

		// --- Event Handlers ---

		// win.sort_table_by_column(name, column, ascending bool)
		// Automatically detects numbers (Sorts numerically) vs strings (Sorts alphabetically)
		.on_click('btn_sort_num', fn (mut win simplegui.SimpleWindow) {
			win.sort_table_by_column('data_table', 0, true)
			win.set_status('Sorted table by ID column numerically.')
		})

		.on_click('btn_sort_text', fn (mut win simplegui.SimpleWindow) {
			win.sort_table_by_column('data_table', 1, true)
			win.set_status('Sorted table by Name column alphabetically.')
		})

		// Shift selected row up/down by 1 slot
		.on_click('btn_move_up', fn (mut win simplegui.SimpleWindow) {
			win.move_selected_table_row_up('data_table')
			win.set_status('Moved selected table row up.')
		})

		.on_click('btn_move_down', fn (mut win simplegui.SimpleWindow) {
			win.move_selected_table_row_down('data_table')
			win.set_status('Moved selected table row down.')
		})

		// Save/Load CSV
		.on_click('btn_save_csv', fn (mut win simplegui.SimpleWindow) {
			win.save_table_to_csv('data_table', 'table_data.csv') or {
				win.set_status('CSV Save failed: ${err}')
				return
			}
			win.set_status('Exported table rows to table_data.csv')
		})

		.on_click('btn_load_csv', fn (mut win simplegui.SimpleWindow) {
			win.load_table_from_csv('data_table', 'table_data.csv') or {
				win.set_status('CSV Load failed: ${err}')
				return
			}
			win.set_status('Loaded table rows from table_data.csv')
		})

		// Save/Load JSON
		.on_click('btn_save_json', fn (mut win simplegui.SimpleWindow) {
			win.save_table_to_json('data_table', 'table_data.json') or {
				win.set_status('JSON Save failed: ${err}')
				return
			}
			win.set_status('Exported table rows to table_data.json')
		})

		.on_click('btn_load_json', fn (mut win simplegui.SimpleWindow) {
			win.load_table_from_json('data_table', 'table_data.json') or {
				win.set_status('JSON Load failed: ${err}')
				return
			}
			win.set_status('Loaded table rows from table_data.json')
		})
		.run()
}
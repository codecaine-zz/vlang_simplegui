module main

// Table Manager Demo - showcases the table row-management helpers:
// add_table_row, insert_table_row, update_table_row, remove_table_row,
// set_table_cell / get_table_cell, find_table_row, clear_table,
// selection (get_table_selected_row, set_table_multi_select,
// remove_selected_table_rows) plus on_table_select / on_table_double_click.
import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Inventory Manager', 560, 560)
	win.set_theme('dark')
	win.set_padding(16)
	win.set_spacing(10)

	win.add_heading('Inventory Manager')

	win.row('entry_row', fn (mut w simplegui.SimpleWindow) {
		w.add_input('item_name', '').placeholder('Item name').width(180)
		w.add_input('item_qty', '').placeholder('Qty').width(70)
		w.add_button('add', 'Add').onclick(add_item)
	})
	win.set_default_button('add')
	win.on_enter('item_name', add_item)
	win.on_enter('item_qty', add_item)

	win.add_table('inventory', ['ID', 'Name', 'Qty'])
	win.set_table_rows('inventory', [
		['1', 'Bolt', '40'],
		['2', 'Nut', '75'],
		['3', 'Washer', '120'],
	])

	// Cmd/Shift-click to select several rows at once
	win.set_table_multi_select('inventory', true)

	// Live selection feedback in the status bar
	win.on_table_select('inventory', fn (mut w simplegui.SimpleWindow, _ string) {
		selected := w.get_table_selected_rows('inventory')
		if selected.len > 1 {
			w.status('${selected.len} rows selected (Cmd/Shift-click works!)')
		} else if selected.len == 1 {
			w.status('Selected: ${selected[0][1]} (qty ${selected[0][2]})')
		}
	})

	// Double-click a row to bump its quantity by one
	win.on_table_double_click('inventory', fn (mut w simplegui.SimpleWindow, row string) {
		idx := row.int()
		qty := w.get_table_cell('inventory', idx, 2).int() + 1
		w.set_table_cell('inventory', idx, 2, qty.str())
		w.status('Double-click: ${w.get_table_cell('inventory', idx, 1)} is now ${qty}')
	})

	win.add_action_row({
		'Remove Selected': fn (mut w simplegui.SimpleWindow) {
			removed := w.remove_selected_table_rows('inventory')
			if removed.len == 0 {
				w.warn('Nothing Selected', 'Pick one or more rows first (Cmd/Shift-click for multiple).')
				return
			}
			w.status('Removed ${removed.len} row(s) - ${w.get_table_row_count('inventory')} left')
		}
		'Find Item':       fn (mut w simplegui.SimpleWindow) {
			name := w.prompt('Find Item', 'Item name to look up:', '')
			if name == '' {
				return
			}
			idx := w.find_table_row('inventory', 1, name)
			if idx < 0 {
				w.error_dialog('Not Found', 'No item named "${name}".')
				return
			}
			w.set_table_selected('inventory', idx)
			w.status('Found "${name}" at row ${idx + 1}.')
		}
		'Clear All':       fn (mut w simplegui.SimpleWindow) {
			count := w.get_table_row_count('inventory')
			if count == 0 {
				return
			}
			if w.ask('Clear All', 'Remove all ${count} rows?') {
				w.clear_table('inventory')
				w.status('Table cleared.')
			}
		}
		'Show Summary':    fn (mut w simplegui.SimpleWindow) {
			rows := w.get_table_rows('inventory')
			mut total := 0
			for row in rows {
				total += row[2].int()
			}
			w.info('${rows.len} Item(s)', 'Total quantity on hand: ${total}')
		}
	})

	win.set_status('${win.get_table_row_count('inventory')} items loaded. Double-click a row to +1 its quantity.')
	win.run()
}

fn add_item(mut win simplegui.SimpleWindow) {
	if !win.require_fields(['item_name', 'item_qty']) {
		return
	}
	name := win.get_value('item_name').trim_space()
	qty := win.get_value('item_qty').trim_space()
	if win.find_table_row('inventory', 1, name) >= 0 {
		win.warn('Duplicate', '"${name}" is already in the inventory.')
		return
	}
	next_id := win.get_table_row_count('inventory') + 1
	win.add_table_row('inventory', [next_id.str(), name, qty])
	win.clear('item_name')
	win.clear('item_qty')
	win.focus('item_name')
	win.status('Added ${name} - ${win.get_table_row_count('inventory')} items total.')
}

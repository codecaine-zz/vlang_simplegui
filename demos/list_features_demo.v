module main

import simplegui

fn main() {
	simplegui.new_simple_window('List Sorting, Reordering & Live Search Demo', 600, 650)
		// 1. Search Bar Control
		.add_search_field('search_box', 'Type to filter tasks...')
		
		.add_vertical_spacer(10)

		// 2. List Box Setup
		.add_list_box('task_list', [
			'Buy groceries',
			'Review pull requests',
			'Write unit tests',
			'Clean workspace',
			'Deploy application'
		])

		// 3. Bind Live Search
		// Wires search_box to filter task_list in real-time (case-insensitive substring match)
		.bind_search_to_list('search_box', 'task_list')

		.add_separator()

		// 4. Reordering & Sorting Control Buttons
		.begin_row('row_move')
			.add_button('btn_up', 'Move Up')
			.add_button('btn_down', 'Move Down')
			.add_button('btn_sort_asc', 'Sort A-Z')
			.add_button('btn_sort_desc', 'Sort Z-A')
		.end_row()

		// 5. Item Manipulation Control Buttons
		.begin_row('row_edit')
			.add_button('btn_insert', 'Insert Task')
			.add_button('btn_update', 'Update Selected')
			.add_button('btn_get_selected', 'Read Selection')
		.end_row()

		// 6. Persistence Buttons
		.begin_row('row_file')
			.add_button('btn_save', 'Save to JSON')
			.add_button('btn_load', 'Load from JSON')
		.end_row()

		// --- Event Handlers ---

		// Move selected item UP by 1 slot
		.on_click('btn_up', fn (mut win simplegui.SimpleWindow) {
			win.move_selected_list_item_up('task_list')
			// Re-bind search after modifying/reordering the item set
			win.bind_search_to_list('search_box', 'task_list')
			win.set_status('Moved selected item up.')
		})

		// Move selected item DOWN by 1 slot
		.on_click('btn_down', fn (mut win simplegui.SimpleWindow) {
			win.move_selected_list_item_down('task_list')
			win.bind_search_to_list('search_box', 'task_list')
			win.set_status('Moved selected item down.')
		})

		// Sort items alphabetically (Ascending)
		.on_click('btn_sort_asc', fn (mut win simplegui.SimpleWindow) {
			win.sort_list_items('task_list', true)
			win.bind_search_to_list('search_box', 'task_list')
			win.set_status('Sorted list A-Z.')
		})

		// Sort items alphabetically (Descending)
		.on_click('btn_sort_desc', fn (mut win simplegui.SimpleWindow) {
			win.sort_list_items('task_list', false)
			win.bind_search_to_list('search_box', 'task_list')
			win.set_status('Sorted list Z-A.')
		})

		// Insert a single item at index 0
		.on_click('btn_insert', fn (mut win simplegui.SimpleWindow) {
			win.insert_list_item('task_list', 0, '⚡ High Priority Item')
			win.bind_search_to_list('search_box', 'task_list')
			win.set_status('Inserted new item at index 0.')
		})

		// Update currently selected item
		.on_click('btn_update', fn (mut win simplegui.SimpleWindow) {
			idx := win.get_list_selected('task_list')
			if idx != -1 {
				win.update_list_item('task_list', idx, 'Updated Task Name')
				win.bind_search_to_list('search_box', 'task_list')
				win.set_status('Updated item at index ${idx}.')
			} else {
				win.set_status('No item selected to update.')
			}
		})

		// Read selected row text with fallback
		.on_click('btn_get_selected', fn (mut win simplegui.SimpleWindow) {
			selected_text := win.get_list_selected_text_or('task_list', 'None Selected')
			win.set_status('Selected: ${selected_text}')
		})

		// Save list to JSON file
		.on_click('btn_save', fn (mut win simplegui.SimpleWindow) {
			win.save_list_to_json('task_list', 'tasks.json') or {
				win.set_status('Failed to save list to JSON: ${err}')
				return
			}
			win.set_status('Successfully saved list items to tasks.json')
		})

		// Load list from JSON file
		.on_click('btn_load', fn (mut win simplegui.SimpleWindow) {
			win.load_list_from_json('task_list', 'tasks.json') or {
				win.set_status('Failed to load list from JSON: ${err}')
				return
			}
			win.bind_search_to_list('search_box', 'task_list')
			win.set_status('Successfully loaded list items from tasks.json')
		})
		.run()
}
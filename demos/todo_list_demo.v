module main

// Todo List Demo - showcases the list box item-management helpers:
// add_list_item, multi-select (set_list_multi_select, get_list_selected_texts,
// remove_selected_list_items, select_all_list_items), double-click events,
// clear_list_items, get_list_items, and get_list_count.
import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Todo List', 460, 520)
	win.set_theme('nord')
	win.set_padding(16)
	win.set_spacing(10)

	win.add_heading('My Todo List')

	win.row('entry_row', fn (mut w simplegui.SimpleWindow) {
		w.add_input('new_task', '')
			.placeholder('What needs to be done?')
			.width(280)
		w.add_button('add', 'Add').onclick(add_task)
	})
	win.set_default_button('add')
	win.on_enter('new_task', add_task)

	win.add_list_box('tasks', ['Buy groceries', 'Walk the dog', 'Pay bills', 'Water plants'])
		.height(220)
		.onchange(fn (mut w simplegui.SimpleWindow, _ string) {
			selected := w.get_list_selected_texts('tasks')
			if selected.len > 1 {
				w.status('${selected.len} tasks selected (Cmd/Shift-click works!)')
			} else if selected.len == 1 {
				w.status('Selected: ${selected[0]}')
			}
		})

	// Allow Cmd/Shift-click multiple row selection
	win.set_list_multi_select('tasks', true)

	// Double-click a row to complete it instantly
	win.on_list_double_click('tasks', fn (mut w simplegui.SimpleWindow, row string) {
		task := w.get_list_items('tasks')[row.int()] or { return }
		w.remove_list_item('tasks', row.int())
		w.status('Completed by double-click: ${task}')
	})

	win.add_action_row({
		'Complete Selected': fn (mut w simplegui.SimpleWindow) {
			removed := w.remove_selected_list_items('tasks')
			if removed.len == 0 {
				w.warn('Nothing Selected', 'Pick one or more tasks first (Cmd/Shift-click for multiple).')
				return
			}
			w.status('Completed ${removed.len} task(s) - ${w.get_list_count('tasks')} left')
		}
		'Select All':        fn (mut w simplegui.SimpleWindow) {
			w.select_all_list_items('tasks')
			w.status('All ${w.get_list_count('tasks')} tasks selected.')
		}
		'Clear All':         fn (mut w simplegui.SimpleWindow) {
			if w.get_list_count('tasks') == 0 {
				return
			}
			if w.ask('Clear All', 'Remove all ${w.get_list_count('tasks')} tasks?') {
				w.clear_list_items('tasks')
				w.status('All tasks cleared.')
			}
		}
		'Show Summary':      fn (mut w simplegui.SimpleWindow) {
			items := w.get_list_items('tasks')
			summary := if items.len == 0 { '(empty)' } else { items.join('\n') }
			w.info('${items.len} Task(s)', summary)
		}
	})

	win.set_status('${win.get_list_count('tasks')} tasks loaded.')
	win.run()
}

fn add_task(mut win simplegui.SimpleWindow) {
	task := win.get('new_task').trim_space()
	if task == '' {
		win.set_error('new_task', 'Type a task first')
		return
	}
	win.clear_error('new_task')
	win.add_list_item('tasks', task)
	win.set('new_task', '')
	win.focus('new_task')
	win.status('Added "${task}" (${win.get_list_count('tasks')} total)')
}

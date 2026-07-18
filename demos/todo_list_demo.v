module main

// Todo List Demo - showcases the list box item-management helpers:
// add_list_item, remove_selected_list_item, clear_list_items,
// get_list_items, get_list_count, and get_list_selected_text.
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

	win.add_list_box('tasks', ['Buy groceries', 'Walk the dog'])
		.height(220)
		.onchange(fn (mut w simplegui.SimpleWindow, _ string) {
			selected := w.get_list_selected_text('tasks')
			if selected != '' {
				w.status('Selected: ${selected}')
			}
		})

	win.add_action_row({
		'Complete Selected': fn (mut w simplegui.SimpleWindow) {
			selected := w.get_list_selected_text('tasks')
			if selected == '' {
				w.warn('Nothing Selected', 'Pick a task in the list first.')
				return
			}
			w.remove_selected_list_item('tasks')
			w.status('Completed: ${selected} (${w.get_list_count('tasks')} left)')
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

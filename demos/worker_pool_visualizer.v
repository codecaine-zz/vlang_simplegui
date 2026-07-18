module main

import simplegui
import time
import rand

struct Task {
	id       int
	duration int // milliseconds
}

struct ProgressEvent {
	task_id   int
	worker_id int
	progress  int    // percentage (0-100)
	status    string // "Queued", "Running", "Finished"
}

struct AppState {
mut:
	running       bool
	workers_count int = 4
	tasks_count   int = 10
	tasks_done    int
	tasks_total   int
	tasks_list    []Task
	task_statuses map[int]ProgressEvent
	task_chan     chan Task
	progress_chan chan ProgressEvent
}

fn worker(worker_id int, task_chan chan Task, progress_chan chan ProgressEvent) {
	for {
		task := <-task_chan or { break }

		// 1. Mark Running
		progress_chan <- ProgressEvent{
			task_id:   task.id
			worker_id: worker_id
			progress:  0
			status:    'Running'
		}

		// 2. Perform step-by-step processing to show progress bar updates
		steps := 10
		step_dur := task.duration / steps
		for step := 1; step <= steps; step++ {
			time.sleep(step_dur * time.millisecond)
			progress_chan <- ProgressEvent{
				task_id:   task.id
				worker_id: worker_id
				progress:  step * (100 / steps)
				status:    'Running'
			}
		}

		// 3. Mark Finished
		progress_chan <- ProgressEvent{
			task_id:   task.id
			worker_id: worker_id
			progress:  100
			status:    'Finished'
		}
	}
}

fn main() {
	mut state := AppState{}

	mut win := simplegui.new_simple_window('Worker Pool Concurrency Visualizer', 620,
		820)
	win.set_theme('dracula')
	win.set_padding(18)
	win.set_spacing(12)

	win.add_label('header', '⚙️ Concurrency Worker Pool Visualizer')
		.bold(true)
		.font_size(20)
		.font_color('#8be9fd') // Dracula Cyan

	win.add_label('intro', 'Configure worker count and task quantity. Click Start Pool to dispatch tasks to parallel V-routines and watch live execution.')
		.font_size(11)
		.font_color('#6272a4')

	win.add_separator()

	// Settings Row
	win.begin_row('settings_row')
	win.add_label('lbl_workers', 'Workers:').width(70)
	win.add_slider('slider_workers', state.workers_count).width(120)
	win.add_label('lbl_tasks', 'Tasks:').width(50)
	win.add_number('num_tasks', state.tasks_count).width(80)
	win.add_spinner('spinner_running', false)
	win.end_row()

	win.add_label('status_info', 'Configure and click Start Pool below.')
		.bold(true)
		.font_color('#ffb86c') // Dracula Orange

	// Progress section
	win.begin_row('progress_row')
	win.add_label('lbl_prog', 'Total Progress:').width(100)
	win.add_progress_indicator('prog_overall', 0)
	win.end_row()

	win.add_separator()

	// Live Task Status Table
	win.add_label('lbl_table', 'Live Task Execution Log:')
	win.add_table('tasks_table', ['Task ID', 'Worker ID', 'Duration (ms)', 'Execution Status',
		'Task Progress'])
	win.set_control_height('tasks_table', 220)

	// Buttons
	win.begin_row('actions')
	win.add_button('btn_start', 'Start Pool')
	win.end_row()

	// Sync Slider
	win.on_change('slider_workers', fn [mut state] (mut w simplegui.SimpleWindow, val string) {
		workers := val.int()
		if workers > 0 && workers <= 8 {
			state.workers_count = workers
			w.set_status('Set worker pool size to ${workers}.')
		}
	})

	// Start Button
	win.on_click('btn_start', fn [mut state] (mut w simplegui.SimpleWindow) {
		if state.running {
			return
		}

		workers := w.get_value_int('slider_workers')
		tasks := w.get_value_int('num_tasks')
		if workers < 1 || workers > 8 {
			w.alert('Invalid Settings', 'Please select 1 to 8 workers.')
			return
		}
		if tasks < 1 || tasks > 30 {
			w.alert('Invalid Settings', 'Please select 1 to 30 tasks.')
			return
		}

		state.running = true
		state.workers_count = workers
		state.tasks_count = tasks
		state.tasks_done = 0
		state.tasks_total = tasks
		state.tasks_list.clear()
		state.task_statuses.clear()

		// Generate random tasks
		for i := 1; i <= tasks; i++ {
			duration := rand.int_in_range(800, 3000) or { 1500 }
			state.tasks_list << Task{
				id:       i
				duration: duration
			}
			state.task_statuses[i] = ProgressEvent{
				task_id:   i
				worker_id: 0
				progress:  0
				status:    'Queued'
			}
		}

		// Disable Configuration UI
		w.set_control_enabled('btn_start', false)
		w.set_control_enabled('slider_workers', false)
		w.set_control_enabled('num_tasks', false)
		w.set_value_int('spinner_running', 1) // Start spinner
		w.set_value_int('prog_overall', 0)
		w.set_text('status_info', 'Starting worker pool with ${workers} workers...')

		// Initialize channels
		state.task_chan = chan Task{cap: tasks}
		state.progress_chan = chan ProgressEvent{cap: tasks * 12}

		// Populate task channel
		for t in state.tasks_list {
			state.task_chan <- t
		}
		state.task_chan.close()

		// Spawn workers
		for idx := 1; idx <= workers; idx++ {
			spawn worker(idx, state.task_chan, state.progress_chan)
		}

		update_table(mut w, state)

		// Set interval timer to poll progress updates safely on GUI thread
		w.set_interval('poll_channel', 50, fn [mut state] (mut w_inner simplegui.SimpleWindow) {
			mut updated := false
			for {
				select {
					event := <-state.progress_chan {
						state.task_statuses[event.task_id] = event
						updated = true

						if event.status == 'Finished' {
							state.tasks_done++
							progress_pct := int(100.0 * f64(state.tasks_done) / f64(state.tasks_total))
							w_inner.set_value_int('prog_overall', progress_pct)
							w_inner.set_text('status_info', 'Tasks Completed: ${state.tasks_done} / ${state.tasks_total}')

							if state.tasks_done >= state.tasks_total {
								// Pool Finished!
								w_inner.stop_interval('poll_channel')
								w_inner.set_text('status_info', 'All tasks completed!')
								w_inner.set_control_enabled('btn_start', true)
								w_inner.set_control_enabled('slider_workers', true)
								w_inner.set_control_enabled('num_tasks', true)
								w_inner.set_value_int('spinner_running', 0) // Stop spinner
								w_inner.alert('Success', 'Worker Pool successfully processed all ${state.tasks_total} tasks!')
								state.running = false
							}
						}
					}
					else {
						break
					}
				}
			}

			if updated {
				update_table(mut w_inner, state)
			}
		})
	})

	win.run()
}

fn update_table(mut w simplegui.SimpleWindow, state AppState) {
	mut rows := [][]string{}
	for i := 1; i <= state.tasks_total; i++ {
		status := state.task_statuses[i]
		worker_str := if status.worker_id == 0 { 'Pending' } else { 'Worker #${status.worker_id}' }
		dur_str := if i <= state.tasks_list.len {
			state.tasks_list[i - 1].duration.str()
		} else {
			'-'
		}
		progress_bar := if status.status == 'Queued' {
			'░░░░░░░░░░ 0%'
		} else if status.status == 'Finished' {
			'██████████ 100%'
		} else {
			filled := status.progress / 10
			empty := 10 - filled
			'█'.repeat(filled) + '░'.repeat(empty) + ' ${status.progress}%'
		}
		rows << [
			'Task #${i}',
			worker_str,
			dur_str,
			status.status,
			progress_bar,
		]
	}
	w.set_table_rows('tasks_table', rows)
}

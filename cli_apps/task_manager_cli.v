module main

import simplecli

fn main() {
	mut app := simplecli.new_app('taskmanager-cli', '1.0.0')
	app.set_description('Real-Time Process Monitor & System Telemetry CLI')

	app.add_flag_string('search', 's', '', 'Search active processes by name')
	app.add_flag_int('top', 't', 15, 'Number of top processes to display')
	app.add_flag_string('sort', 'o', 'cpu', 'Sort metric: cpu, mem, pid')
	app.add_flag_string('kill', 'k', '', 'Kill process by name or PID')
	app.add_flag_bool('interactive', 'x', false, 'Launch interactive task manager')

	app.parse_cli() or { return }

	app.banner('Task Manager Pro CLI', 'v1.0.0 - Real-Time Process Monitor')

	kill_target := app.get_flag_string('kill')
	if kill_target.len > 0 {
		pid_val := kill_target.int()
		if pid_val > 0 {
			if app.kill_process_by_pid(pid_val) {
				app.success('Terminated process PID ${pid_val}')
			} else {
				app.error('Failed to kill PID ${pid_val}')
			}
		} else {
			if app.kill_process(kill_target) {
				app.success('Terminated processes matching "${kill_target}"')
			} else {
				app.error('Failed to kill processes matching "${kill_target}"')
			}
		}
		return
	}

	if app.get_flag_bool('interactive') {
		run_interactive(mut app)
		return
	}

	display_process_table(mut app)
}

fn display_process_table(mut app simplecli.SimpleCli) {
	search_term := app.get_flag_string('search').to_lower()
	top_count := app.get_flag_int('top')
	sort_col := app.get_flag_string('sort').to_lower()

	mut ps_args := ['-eo', 'pid,pcpu,pmem,comm']
	if sort_col == 'mem' {
		ps_args << '-m'
	} else if sort_col != 'pid' {
		ps_args << '-r'
	}
	out, _ := app.exec_safe('ps', ps_args)
	lines := out.split_into_lines().filter(it.len > 0)

	mut rows := [][]string{}
	for i in 1 .. lines.len {
		line := lines[i].trim_space()
		tokens := line.split(' ').filter(it.len > 0)
		if tokens.len >= 4 {
			pid := tokens[0]
			cpu := tokens[1] + '%'
			mem := tokens[2] + '%'
			cmd := tokens[3..].join(' ')

			if search_term.len == 0 || cmd.to_lower().contains(search_term) {
				rows << [pid, cpu, mem, cmd]
			}
		}
	}

	if sort_col == 'pid' {
		rows.sort_with_compare(fn (a &[]string, b &[]string) int {
			pa := (*a)[0].int()
			pb := (*b)[0].int()
			if pa < pb {
				return -1
			}
			if pa > pb {
				return 1
			}
			return 0
		})
	}

	if top_count > 0 && rows.len > top_count {
		rows = rows[..top_count].clone()
	}

	app.table(['PID', 'CPU %', 'Memory %', 'Command'], rows)

	// Summary telemetry
	total_procs := app.get_running_process_count()
	cpu_pct := app.get_cpu_usage_percent()
	l1, l5, l15 := app.get_load_average()

	app.print_kv({
		'Total Processes': '${total_procs}'
		'CPU Utilization': '${cpu_pct:.1f} %'
		'Load Average':    '${l1:.2f}, ${l5:.2f}, ${l15:.2f}'
		'Active Memory':   app.get_memory_info()
	})
}

fn run_interactive(mut app simplecli.SimpleCli) {
	app.panel('Task Manager Interactive Console',
		'Inspect system telemetry and terminate runaway processes.')
	for {
		display_process_table(mut app)
		choice := app.select('Action:', [
			'Refresh Process Table',
			'Search Process by Name',
			'Kill Process by PID',
			'Exit',
		])

		match choice {
			'Search Process by Name' {
				q := app.prompt('Process search keyword', 'node')
				app.flags_val['search'] = q
			}
			'Kill Process by PID' {
				pid_str := app.prompt('Enter PID to terminate', '')
				pid_num := pid_str.int()
				if pid_num > 0 {
					app.kill_process_by_pid(pid_num)
				}
			}
			'Exit' {
				break
			}
			else {}
		}
	}
}

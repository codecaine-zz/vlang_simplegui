#!/usr/bin/env -S v run

import os

fn main() {
	script_path := os.join_path(os.dir(@FILE), 'scripts', 'install_deps.vsh')
	if !os.exists(script_path) {
		eprintln('Could not find ${script_path}')
		exit(1)
	}
	mut args := os.args[1..].clone()
	exit_code := os.system('v run ${os.quoted_path(script_path)} ${args.join(' ')}')
	exit(exit_code)
}

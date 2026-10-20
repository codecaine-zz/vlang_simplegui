#!/usr/bin/env -S v run

import os

fn main() {
	script_path := os.join_path(os.dir(@FILE), 'install_dependencies.vsh')
	if !os.exists(script_path) {
		eprintln('Could not find ${script_path}')
		exit(1)
	}
	quoted_args := os.args[1..].map(os.quoted_path(it)).join(' ')
	exit_code := os.system('v run ${os.quoted_path(script_path)} ${quoted_args}')
	exit(exit_code)
}

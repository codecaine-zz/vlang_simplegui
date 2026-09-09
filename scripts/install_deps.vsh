#!/usr/bin/env -S v run

import os

fn main() {
	root_script := os.join_path(os.dir(os.dir(@FILE)), 'install_dependencies.vsh')
	if os.exists(root_script) {
		mut args := os.args[1..].clone()
		exit_code := os.system('v run ${os.quoted_path(root_script)} ${args.join(' ')}')
		exit(exit_code)
	} else {
		eprintln('Could not find ${root_script}')
		exit(1)
	}
}

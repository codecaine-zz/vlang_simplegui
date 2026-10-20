#!/usr/bin/env -S v run

import os

fn main() {
	root_script := os.join_path(os.dir(os.dir(@FILE)), 'install_dependencies.vsh')
	if os.exists(root_script) {
		quoted_args := os.args[1..].map(os.quoted_path(it)).join(' ')
		exit_code := os.system('v run ${os.quoted_path(root_script)} ${quoted_args}')
		exit(exit_code)
	} else {
		eprintln('Could not find ${root_script}')
		exit(1)
	}
}

module main

import os

fn source_cli_files(dir string) []string {
	mut files := os.ls(dir) or { panic(err) }
	files = files.filter(it.ends_with('.v') && !it.ends_with('_test.v'))
	files.sort()
	return files
}

fn test_cli_apps_standard_conformance() {
	repo_root := os.dir(os.dir(@FILE))
	cli_dir := os.join_path(repo_root, 'cli_apps')
	files := source_cli_files(cli_dir)

	assert files.len == 49, 'Expected 49 CLI applications in cli_apps/'

	for file in files {
		path := os.join_path(cli_dir, file)
		content := os.read_file(path) or { panic(err) }

		// 1. Must import simplecli
		assert content.contains('import simplecli'), '${file} must import simplecli'

		// 2. Must initialize SimpleCli app
		assert content.contains('simplecli.new_app('), '${file} must call simplecli.new_app'

		// 3. Must parse command line arguments
		assert content.contains('.parse_cli()'), '${file} must invoke app.parse_cli()'
	}
}

fn test_representative_cli_help_smoke() {
	repo_root := os.dir(os.dir(@FILE))
	cli_dir := os.join_path(repo_root, 'cli_apps')
	vexe := os.getenv_opt('VEXE') or { @VEXE }

	smoke_targets := [
		'calc_cli.v',
		'api_studio_cli.v',
	]

	for target in smoke_targets {
		full_path := os.join_path(cli_dir, target)
		assert os.exists(full_path), 'Target ${target} must exist'

		cmd := '${os.quoted_path(vexe)} run ${os.quoted_path(full_path)} --help'
		res := os.execute(cmd)
		assert res.exit_code == 0, 'Failed running --help for ${target}: ${res.output}'
		assert res.output.to_lower().contains('usage:'), 'Help output for ${target} must contain "usage:"'
		assert res.output.contains('--help'), 'Help output for ${target} must document --help'
	}
}

fn test_representative_cli_version_smoke() {
	repo_root := os.dir(os.dir(@FILE))
	full_path := os.join_path(repo_root, 'cli_apps', 'calc_cli.v')
	vexe := os.getenv_opt('VEXE') or { @VEXE }

	cmd := '${os.quoted_path(vexe)} run ${os.quoted_path(full_path)} --version'
	res := os.execute(cmd)
	assert res.exit_code == 0, 'Failed running --version: ${res.output}'
	assert res.output.contains('calc-cli v'), 'Expected version output to contain "calc-cli v"'
}

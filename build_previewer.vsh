#!/usr/bin/env v
import os

fn main() {
	println('🚀 Building standalone macOS .app bundle for SimpleGUI RAD Code Explorer & Live Previewer...')

	// Check required entry point
	target_file := 'vlang_simple_gui_previewer.v'

	icon_file := if os.exists('resources/developer.png') {
		'resources/developer.png'
	} else if os.exists('resources/dom_explorer.png') {
		'resources/dom_explorer.png'
	} else {
		'resources/icon.png'
	}

	app_name := 'V Code Previewer'

	println('  Target file: ${target_file}')
	println('  App Name:    ${app_name}')
	println('  Icon:        ${icon_file}')
	println('--------------------------------------------------')

	cmd := 'v run build.vsh ${os.quoted_path(target_file)} --name ${os.quoted_path(app_name)} --icon ${os.quoted_path(icon_file)} --out dist'
	println('Executing: ${cmd}')
	res := os.execute(cmd)
	println(res.output)

	if res.exit_code == 0 {
		println('🎉 Build complete! Created standalone app bundle at: dist/${app_name}.app')
	} else {
		eprintln('❌ Build failed with exit code ${res.exit_code}')
		exit(res.exit_code)
	}
}

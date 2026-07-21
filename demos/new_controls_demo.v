module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('New Controls Demo', 760, 560)

	win.set_background_color('#0f172a')
		.set_font_color('white')
		.set_padding(16)
		.set_spacing(10)
		.set_title('Native Controls Showcase')

	win.add_heading('Native macOS Controls')

	win.add_input('name', 'Ada Lovelace')
		.placeholder('Your name')
		.tooltip('Type a name for the demo')

	win.add_dropdown('priority', ['Low', 'Normal', 'High'], 'Normal')
		.onchange(fn (mut w simplegui.SimpleWindow, value string) {
			w.set_status('Priority changed to ${value}')
		})

	win.add_segmented_control('mode', ['Simple', 'Advanced', 'Expert'], 'Advanced')
		.onchange(fn (mut w simplegui.SimpleWindow, value string) {
			w.set_status('Mode changed to ${value}')
		})

	win.add_radio_group('role', ['Viewer', 'Editor', 'Admin'], 'Editor')
		.onchange(fn (mut w simplegui.SimpleWindow, value string) {
			w.set_status('Role changed to ${value}')
		})

	win.add_switch('alerts', 'Enable alerts', true)
		.onchange(fn (mut w simplegui.SimpleWindow, value string) {
			w.set_status('Alerts ${value}')
		})

	win.add_search_field('query', 'Search items')
		.onchange(fn (mut w simplegui.SimpleWindow, value string) {
			w.set_status('Search: ${value}')
		})

	win.add_separator()
	win.add_heading('Extra Native Controls')

	// Standalone up/down stepper (NSStepper)
	win.row('stepper_row', fn (mut w simplegui.SimpleWindow) {
		w.add_label('stepper_label', 'Quantity:')
		w.add_stepper('quantity', 0, 100, 5, 25).onchange(fn (mut w simplegui.SimpleWindow, value string) {
			w.set_status('Quantity: ${value}')
		})
		// Round native "?" help button (NSBezelStyleHelpButton)
		w.add_help_button('qty_help').onclick(fn (mut w simplegui.SimpleWindow) {
			w.info('Help', 'Use the stepper arrows to adjust the quantity in steps of 5.')
		})
	})

	// Circular rotary knob slider (NSSliderTypeCircular)
	win.add_label('knob_label', 'Gain knob (0-200):')
	win.add_knob('gain', 75).range(0.0, 200.0).onchange(fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Gain: ${value}')
	})

	// Pull-down action menu button (NSPopUpButton pullsDown:YES)
	win.add_pull_down('actions', 'Actions', ['Duplicate', 'Rename', 'Delete']).onchange(fn (mut w simplegui.SimpleWindow, value string) {
		w.set_status('Action chosen: ${value}')
	})

	// SF Symbol image buttons (macOS 11+)
	win.row('icon_buttons', fn (mut w simplegui.SimpleWindow) {
		w.add_image_button('share', 'square.and.arrow.up', 'Share').onclick(fn (mut w simplegui.SimpleWindow) {
			w.set_status('Share clicked')
		})
		w.add_image_button('trash', 'trash', '').onclick(fn (mut w simplegui.SimpleWindow) {
			w.set_status('Trash clicked')
		})
	})

	win.add_separator()
	win.add_heading('Modern High-Utility Controls')

	// Dismissible Alert Banner
	win.add_alert_banner('demo_banner', 'System Status Normal', 'All services and bridge components are running smoothly.',
		'success')
	win.on_change('demo_banner', fn (mut w simplegui.SimpleWindow, val string) {
		w.set_status('Alert Banner closed')
	})

	// Process Step Tracker
	win.add_label('lbl_steps', 'Deployment Progress:')
	win.add_step_tracker('deploy_steps', ['Build', 'Test', 'Package', 'Deploy'], 1)
	win.on_change('deploy_steps', fn (mut w simplegui.SimpleWindow, step string) {
		w.set_status('Selected step: ${step}')
	})

	// Native File Picker Field with NSOpenPanel
	win.add_label('lbl_file', 'Export Destination:')
	win.add_file_picker_field('export_path', '/Users/codecaine/Documents', 'Choose Folder...',
		true)
	win.on_change('export_path', fn (mut w simplegui.SimpleWindow, path string) {
		w.set_status('Export path: ${path}')
	})

	// Interactive Filter Chips
	win.add_label('lbl_tags', 'Filter Tags:')
	win.add_filter_chips('tag_chips', ['vlang', 'macOS', 'cocoa', 'gui', 'native'], [
		'vlang',
		'native',
	], true)
	win.on_change('tag_chips', fn (mut w simplegui.SimpleWindow, tags string) {
		w.set_status('Active tags: ${tags}')
	})

	win.add_action_row({
		'Lock Resize':  fn (mut w simplegui.SimpleWindow) {
			w.set_resizable(false)
			w.set_status('Window resizing locked')
		}
		'Apply Limits': fn (mut w simplegui.SimpleWindow) {
			w.set_min_size(480, 320)
			w.set_max_size(980, 720)
			w.set_status('Size constraints applied')
		}
	})

	win.on_click('lock_resize', fn (mut w simplegui.SimpleWindow) {
		w.set_resizable(false)
		w.set_status('Window resizing locked')
	})
	win.on_click('apply_limits', fn (mut w simplegui.SimpleWindow) {
		w.set_min_size(480, 320)
		w.set_max_size(980, 720)
		w.set_status('Size constraints applied')
	})

	win.run()
}

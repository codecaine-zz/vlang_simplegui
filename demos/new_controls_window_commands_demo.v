module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Advanced Controls & Window Commands', 700, 640)

	// Window commands demonstration
	win.set_subtitle('SimpleGUI Native macOS Features Demo')
	win.set_movable(true)
	win.set_window_level('normal')

	win.add_section_header('sec_stepper', '1. Process Wizard Stepper', 'Step-by-step workflow navigation indicator')
	win.add_wizard_stepper('setup_wizard', ['Account', 'Preferences', 'Integrations', 'Confirm'], 1)

	win.add_vertical_spacer(10)
	win.add_section_header('sec_rating', '2. Star Rating Widget', 'Interactive star rating selector')
	win.add_star_rating('feedback_rating', 4, 5)

	win.add_vertical_spacer(10)
	win.add_section_header('sec_range', '3. Dual-Thumb Range Slider', 'Select minimum and maximum range thresholds')
	win.add_range_slider('budget_range', 0, 5000, 500, 2500)

	win.add_vertical_spacer(10)
	win.add_section_header('sec_split', '4. Split Button with Menu', 'Primary action button paired with sub-action dropdown')
	win.add_split_button('deploy_btn', 'Deploy Application', ['Deploy to Staging', 'Deploy to Production', 'Rollback Last Release'])

	win.add_vertical_spacer(10)
	win.add_section_header('sec_tags', '5. Interactive Tag Cloud', 'Dynamic tag chips list')
	win.add_tag_cloud('tech_stack', ['vlang', 'simplegui', 'macos', 'cocoa', 'native'])

	win.add_vertical_spacer(15)
	win.add_separator()
	win.add_label('status_lbl', 'Interact with any control above to trigger events.')

	// Register event handlers
	win.on_change('feedback_rating', fn (mut w simplegui.SimpleWindow, val string) {
		w.set_text('status_lbl', 'Rating changed to: ${val} stars')
	})

	win.on_change('budget_range', fn (mut w simplegui.SimpleWindow, val string) {
		w.set_text('status_lbl', 'Budget range changed to: $${val}')
	})

	win.on_click('deploy_btn', fn (mut w simplegui.SimpleWindow) {
		w.set_text('status_lbl', 'Primary deploy action triggered!')
	})

	win.on_select_item('deploy_btn', fn (mut w simplegui.SimpleWindow, item string) {
		w.set_text('status_lbl', 'Split button menu item selected: "${item}"')
	})

	win.on_change_step('setup_wizard', fn (mut w simplegui.SimpleWindow, step string) {
		w.set_text('status_lbl', 'Wizard step switched to step index: ${step}')
	})

	win.on_click_tag('tech_stack', fn (mut w simplegui.SimpleWindow, tag string) {
		w.set_text('status_lbl', 'Clicked tag: ${tag}')
	})

	win.run()
}

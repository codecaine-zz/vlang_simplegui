module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Advanced Layout, Grid & Flexbox Studio', 640,
		620)
		.configure(fn (mut cfg simplegui.WindowConfig) {
			cfg.padding = 20
			cfg.spacing = 10
			cfg.background_color = '#1e1e2e' // Catppuccin Mocha dark background
			cfg.font_color = '#cdd6f4'
		})

	win.add_heading('Advanced Layout & Auto-Sizing Studio')
	win.add_label('desc', 'Explore multi-column Grids, Flexbox alignment & distribution, explicit anchoring, and nested container structures.')
	win.set_control_font_size('desc', 11)

	win.add_vertical_spacer(8)

	// 1. Native Tab Navigation for full capability exploration
	win.add_tabs('layout_tabs', ['Form Grid (2 & 3 Col)', 'Flexbox Distributions',
		'Alignment & Anchoring', 'Nested Layout Containers'])

	win.add_vertical_spacer(8)

	// ==========================================
	// PANE 1: Multi-Column Form & Metrics Grid
	// ==========================================
	win.group('pane_grid', 'Multi-Column Grid Containers', fn (mut w simplegui.SimpleWindow) {
		w.add_label('grid_intro', 'Grid layout containers (begin_grid/end_grid) automatically wrap controls across columns without manual row nesting.')
		w.set_control_font_size('grid_intro', 11)

		w.add_vertical_spacer(6)

		// 2-Column Responsive Form Grid
		w.add_section_header('sec_2col', '2-Column Personal Profile Grid (spacing: 12px)',
			'')
		w.grid('form_grid_2col', 2, 12, fn (mut g simplegui.SimpleWindow) {
			g.add_label('lbl_fname', 'First Name:')

			g.add_input('first_name', 'Ada')
				.align_left()
				.expand_fill()

			g.add_label('lbl_lname', 'Last Name:')

			g.add_input('last_name', 'Lovelace')
				.align_left()
				.expand_fill()

			g.add_label('lbl_email', 'Email Address:')

			g.add_input('email', 'ada.lovelace@example.com')
				.align_left()
				.expand_fill()

			g.add_label('lbl_role', 'Security Role:')

			g.add_dropdown('user_role', ['System Administrator', 'Lead Engineer', 'Security Auditor'],
				'Lead Engineer')
				.expand_fill()
		})

		w.add_vertical_spacer(10)

		// 3-Column Metrics Dashboard Grid
		w.add_section_header('sec_3col', '3-Column System Health Grid (spacing: 10px)',
			'')
		w.grid('metrics_grid_3col', 3, 10, fn (mut g simplegui.SimpleWindow) {
			g.add_stat_card('stat_cpu', 'CPU Load', '24%', '+2% nominal', 'positive')
			g.add_stat_card('stat_mem', 'RAM Usage', '14.2 GB', 'Stable', 'neutral')
			g.add_stat_card('stat_net', 'Network In', '1.2 Gbps', '-5% peak', 'positive')
		})

		w.add_vertical_spacer(8)

		w.row('grid_actions', fn (mut r simplegui.SimpleWindow) {
			r.add_button('btn_clear_grid', 'Clear Grid Inputs')
				.onclick(on_clear_grid)

			r.add_button('btn_grid_info', 'Inspect Grid Fields')
				.onclick(on_inspect_grid)
		})
	})

	// ==========================================
	// PANE 2: Flexbox Directions & Distributions
	// ==========================================
	win.group('pane_flex', 'Flexbox Containers (Row & Column)', fn (mut w simplegui.SimpleWindow) {
		w.add_label('flex_intro', 'Flexbox containers (begin_flex_box/end_flex_box) support row/column directions, justify main-axis distribution, and cross-axis alignment.')
		w.set_control_font_size('flex_intro', 11)

		w.add_vertical_spacer(6)

		// Flex Row: Space-Between Action Bar
		w.add_section_header('sec_flex_sb', 'Flex Row: justify="space_between" align="center"',
			'')
		w.flex_box('flex_sb', 'row', 'space_between', 'center', fn (mut f simplegui.SimpleWindow) {
			f.add_button('btn_flex_left', '← Back')
				.align_left()
				.onclick(on_flex_btn_click)

			f.add_button('btn_flex_mid', '⚙ Settings')
				.align_center()
				.onclick(on_flex_btn_click)

			f.add_button('btn_flex_right', 'Next →')
				.align_right()
				.onclick(on_flex_btn_click)
		})

		w.add_vertical_spacer(10)

		// Flex Row: Center Distribution with Badges & Chip Group
		w.add_section_header('sec_flex_center', 'Flex Row: justify="center" align="center"',
			'')
		w.flex_box('flex_center', 'row', 'center', 'center', fn (mut f simplegui.SimpleWindow) {
			f.add_badge('badge_status', 'STATUS: ACTIVE', 'success')
			f.add_badge('badge_env', 'ENV: PRODUCTION', 'warning')
			f.add_chip_group('chip_tags', ['macOS', 'VLang', 'GUI', 'Flexbox'], 'VLang')
		})

		w.add_vertical_spacer(10)

		// Flex Column: Vertical Stack Container
		w.add_section_header('sec_flex_col', 'Flex Column: direction="column" align="stretch"',
			'')
		w.flex_box('flex_col', 'column', 'start', 'stretch', fn (mut f simplegui.SimpleWindow) {
			f.add_banner('banner_flex_info', 'Flexbox column arranges elements vertically with stretch cross-axis alignment.',
				'info')

			f.add_search_field('search_flex', '')
				.placeholder('Search flex components...')
		})
	})

	// ==========================================
	// PANE 3: Alignment & Anchoring Modifiers
	// ==========================================
	win.group('pane_align', 'Explicit Alignment & Expansion Modifiers', fn (mut w simplegui.SimpleWindow) {
		w.add_label('align_intro', 'Use explicit modifiers like .align_left(), .align_center(), .align_right(), and .expand_fill() to anchor controls inside containers.')
		w.set_control_font_size('align_intro', 11)

		w.add_vertical_spacer(6)

		// Targeted Control Demonstration

		w.add_input('target_input', 'Sample Aligned Text Field')
			.align_center()
			.expand_fill()

		w.add_vertical_spacer(8)

		w.add_section_header('sec_live_align', 'Live Alignment Modifier Switcher', 'Click buttons to dynamically re-align the target input field above')
		w.row('align_controls', fn (mut r simplegui.SimpleWindow) {
			r.add_button('btn_align_left', 'Align Left')
				.onclick(on_set_left)

			r.add_button('btn_align_center', 'Align Center')
				.onclick(on_set_center)

			r.add_button('btn_align_right', 'Align Right')
				.onclick(on_set_right)

			r.add_button('btn_toggle_expand', 'Toggle Expand Fill')
				.onclick(on_toggle_expand)
		})

		w.add_vertical_spacer(10)

		w.add_label('lbl_align_meta', 'Active Alignment: center | Expand Fill: true')
		w.set_control_font_size('lbl_align_meta', 11)
	})

	// ==========================================
	// PANE 4: Deeply Nested Layout Containers
	// ==========================================
	win.group('pane_nested', 'Nested Layout Containers', fn (mut w simplegui.SimpleWindow) {
		w.add_label('nest_intro', 'The native Cocoa containerStack supports arbitrary layout nesting (Grid inside Flexbox inside Cards/Groups).')
		w.set_control_font_size('nest_intro', 11)

		w.add_vertical_spacer(6)

		// Outer Flexbox Container
		w.flex_box('outer_flex', 'column', 'start', 'stretch', fn (mut flex_outer simplegui.SimpleWindow) {
			flex_outer.add_banner('banner_nest', 'Outer Flex Container -> Inner Grid Container',
				'success')
			flex_outer.add_vertical_spacer(6)

			// Inner Grid Container inside Outer Flexbox
			flex_outer.grid('inner_grid', 2, 10, fn (mut grid_inner simplegui.SimpleWindow) {
				grid_inner.add_label('lbl_n1', 'Server Node:')

				grid_inner.add_input('node_name', 'us-east-cluster-01')
					.expand_fill()

				grid_inner.add_label('lbl_n2', 'IP Address:')

				grid_inner.add_input('node_ip', '192.168.1.100')
					.expand_fill()
			})

			flex_outer.add_vertical_spacer(8)

			// Imperative nesting demonstration (begin_flex_box / begin_grid)
			flex_outer.begin_flex_box('nested_imperative_flex', 'row', 'space_between',
				'center')
			flex_outer.add_label('lbl_imp_nest', 'Imperative Grid & Flex Containers:')

			flex_outer.add_button('btn_nest_save', 'Commit Nested Config')
				.onclick(on_save_nested)
			flex_outer.end_flex_box()
		})
	})

	// Initially show Pane 1, hide Panes 2, 3, and 4
	win.set_control_visible('pane_flex', false)
	win.set_control_visible('pane_align', false)
	win.set_control_visible('pane_nested', false)

	// Event handling for tab switches
	win.on_change('layout_tabs', on_tab_changed)

	win.add_vertical_spacer(8)

	// Universal Footer Status Bar
	win.add_label('footer_status', 'Ready. Select tabs above to explore Grid, Flexbox, Alignment, and Nesting capabilities.')
	win.set_control_font_size('footer_status', 11)

	win.run()
}

// Handler for switching visible tab panes
fn on_tab_changed(mut win simplegui.SimpleWindow, selected_tab string) {
	if selected_tab == 'Form Grid (2 & 3 Col)' {
		win.set_control_visible('pane_grid', true)
		win.set_control_visible('pane_flex', false)
		win.set_control_visible('pane_align', false)
		win.set_control_visible('pane_nested', false)
		win.set_text('footer_status', 'Active Tab: Multi-Column Form & Metrics Grid')
	} else if selected_tab == 'Flexbox Distributions' {
		win.set_control_visible('pane_grid', false)
		win.set_control_visible('pane_flex', true)
		win.set_control_visible('pane_align', false)
		win.set_control_visible('pane_nested', false)
		win.set_text('footer_status', 'Active Tab: Flexbox Directions (Row/Col) & Distributions')
	} else if selected_tab == 'Alignment & Anchoring' {
		win.set_control_visible('pane_grid', false)
		win.set_control_visible('pane_flex', false)
		win.set_control_visible('pane_align', true)
		win.set_control_visible('pane_nested', false)
		win.set_text('footer_status', 'Active Tab: Explicit Alignment & Fill Expansion Modifiers')
	} else if selected_tab == 'Nested Layout Containers' {
		win.set_control_visible('pane_grid', false)
		win.set_control_visible('pane_flex', false)
		win.set_control_visible('pane_align', false)
		win.set_control_visible('pane_nested', true)
		win.set_text('footer_status', 'Active Tab: Deeply Nested Grid & Flexbox Containers')
	}
}

// Grid tab actions
fn on_clear_grid(mut win simplegui.SimpleWindow) {
	win.set_text('first_name', '')
	win.set_text('last_name', '')
	win.set_text('email', '')
	win.toast('Grid form inputs cleared')
}

fn on_inspect_grid(mut win simplegui.SimpleWindow) {
	fname := win.get_text('first_name')
	lname := win.get_text('last_name')
	email := win.get_text('email')
	role := win.get_text('user_role')

	fname_align := win.get_control_alignment('first_name')
	fname_fill := win.get_control_expand_fill('first_name')

	win.alert('Grid Control Inspection', 'Current Values:\n' + 'Name: ${fname} ${lname}\n' +
		'Email: ${email}\n' + 'Role: ${role}\n\n' + 'Layout Attributes:\n' +
		'First Name Alignment: ${fname_align}\n' + 'First Name Expand Fill: ${fname_fill}')
}

// Flexbox tab action
fn on_flex_btn_click(mut win simplegui.SimpleWindow) {
	win.toast('Flexbox action button clicked')
}

// Alignment switcher tab actions
fn on_set_left(mut win simplegui.SimpleWindow) {
	win.set_control_alignment('target_input', 'left')
	update_align_label(mut win)
	win.toast('Set alignment to left')
}

fn on_set_center(mut win simplegui.SimpleWindow) {
	win.set_control_alignment('target_input', 'center')
	update_align_label(mut win)
	win.toast('Set alignment to center')
}

fn on_set_right(mut win simplegui.SimpleWindow) {
	win.set_control_alignment('target_input', 'right')
	update_align_label(mut win)
	win.toast('Set alignment to right')
}

fn on_toggle_expand(mut win simplegui.SimpleWindow) {
	current_fill := win.get_control_expand_fill('target_input')
	new_fill := !current_fill
	win.set_control_expand_fill('target_input', new_fill)
	update_align_label(mut win)
	win.toast('Set expand fill to ${new_fill}')
}

fn update_align_label(mut win simplegui.SimpleWindow) {
	align_state := win.get_control_alignment('target_input')
	fill_state := win.get_control_expand_fill('target_input')
	win.set_text('lbl_align_meta', 'Active Alignment: ${align_state} | Expand Fill: ${fill_state}')
}

// Nested tab action
fn on_save_nested(mut win simplegui.SimpleWindow) {
	node := win.get_text('node_name')
	ip := win.get_text('node_ip')
	win.alert('Nested Configuration Saved', 'Node Name: ${node}\nIP Address: ${ip}')
}

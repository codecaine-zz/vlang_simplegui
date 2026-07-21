module main

import simplegui

@[heap]
struct AppState {
mut:
	nodes []simplegui.TreeNode
}

fn (mut state AppState) refresh(mut win simplegui.SimpleWindow) {
	win.set_tree_nodes('my_tree', state.nodes)
}

fn main() {
	mut state := &AppState{
		nodes: [
			simplegui.tree_root('root', 'Enterprise Services'),
			simplegui.tree_child('dept_engineering', 'root', 'Engineering Division'),
			simplegui.tree_child('team_frontend', 'dept_engineering', 'Frontend Team'),
			simplegui.tree_child('team_backend', 'dept_engineering', 'Backend Systems Team'),
			simplegui.tree_child('team_devops', 'dept_engineering', 'DevOps & Infra'),
			simplegui.tree_child('dept_design', 'root', 'Product Design Division'),
			simplegui.tree_child('team_ux', 'dept_design', 'UX Research'),
			simplegui.tree_child('team_ui', 'dept_design', 'UI / Design Systems'),
			simplegui.tree_child('dept_hr', 'root', 'Human Resources'),
		]
	}

	mut win := simplegui.new_simple_window('Native TreeView & Hierarchy Demo', 720, 520)

	win.set_debug_mode(true)
	win.set_padding(20)
	win.set_spacing(10)
	win.set_theme('dracula')

	win.add_heading('Hierarchical Tree View Control')

	win.add_label('description', 'This demo showcases the implementation of a recursive native TreeView (NSOutlineView) control in V SimpleGUI.')
		.font_size(12)

	win.begin_row('main_row')
	// Left: The Tree View container

	win.add_tree_view('my_tree', 200)
		.width(340)

	// Right: Tree Actions
	win.add_group_box('actions_box', 'Manage Tree Nodes')
	win.group('actions_group', '', fn [mut state] (mut w simplegui.SimpleWindow) {
		w.add_label('lbl_info', 'Fill fields below to add child nodes:')
		w.add_form_field('Node Name:', 'new_node_text', 'New Sub-Team')
		w.add_form_field('Parent ID:', 'new_node_parent', '')
		w.add_form_field('Node ID:', 'new_node_id', 'dynamic_node')

		w.add_button('btn_add', 'Add Node')
			.onclick(fn [mut state] (mut w simplegui.SimpleWindow) {
				id := w.get('new_node_id').trim_space()
				parent := w.get('new_node_parent').trim_space()
				text := w.get('new_node_text').trim_space()

				if id == '' || text == '' {
					w.alert('Verification Error', 'Both ID and text of the node must have a value.')
					return
				}

				// Check for duplicates
				for node in state.nodes {
					if node.id == id {
						w.alert('Duplication Error', 'A node with ID "${id}" already exists.')
						return
					}
				}

				w.add_tree_node('my_tree', simplegui.tree_child(id, parent, text))
				state.nodes = w.get_tree_nodes('my_tree')
				w.toast('Node Added Successfully')
			})
	})
	win.end_row()

	// Selection and showing controls

	win.add_label('selection_lbl', 'Selected Node ID: None')
		.bold(true)

	win.begin_row('actions_row')

	win.add_button('expand_custom', 'Select Front-End')
		.onclick(fn (mut w simplegui.SimpleWindow) {
			w.set_tree_selected('my_tree', 'team_frontend')
		})

	win.add_button('expand_devops', 'Select DevOps')
		.onclick(fn (mut w simplegui.SimpleWindow) {
			w.set_tree_selected('my_tree', 'team_devops')
		})

	win.add_button('btn_clear', 'Clear Selection')
		.onclick(fn (mut w simplegui.SimpleWindow) {
			w.clear_tree_selection('my_tree')
			w.set_text('selection_lbl', 'Selected Node ID: None')
			w.set_text('new_node_parent', '')
		})
	win.end_row()

	win.begin_row('expand_collapse_row')

	win.add_button('btn_open_all', 'Open All')
		.onclick(fn (mut w simplegui.SimpleWindow) {
			w.open_tree('my_tree')
		})

	win.add_button('btn_collapse_all', 'Collapse All')
		.onclick(fn (mut w simplegui.SimpleWindow) {
			w.collapse_tree('my_tree')
		})

	win.add_button('btn_expand_engineering', 'Expand Engineering')
		.onclick(fn (mut w simplegui.SimpleWindow) {
			w.expand_tree_node('my_tree', 'dept_engineering', true)
		})

	win.add_button('btn_collapse_engineering', 'Collapse Engineering')
		.onclick(fn (mut w simplegui.SimpleWindow) {
			w.collapse_tree_node('my_tree', 'dept_engineering', true)
		})
	win.end_row()

	// Sync tree nodes selection event
	win.on_change('my_tree', fn (mut w simplegui.SimpleWindow, selected_id string) {
		if selected_id == '' {
			w.set_text('selection_lbl', 'Selected Node ID: None')
			w.set_text('new_node_parent', '')
		} else {
			w.set_text('selection_lbl', 'Selected Node ID: ${selected_id}')
			w.set_text('new_node_parent', selected_id)
		}
	})

	// Initial tree data display
	state.refresh(mut win)

	win.run()
}

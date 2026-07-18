module main

import simplegui
import rand

// 2D Grid Beginner Demo
// This demo teaches beginners how to build a 2D layout grid by stacking
// multiple horizontal row layout elements vertically.
//
// Concepts covered:
// 1. Grid creation using a vertical stack of horizontal rows.
// 2. Dynamic styling: updating background and values of controls at runtime.
// 3. User Interaction: handling events on a grid of cells.
// 4. Custom and Preset Colors: using preset buttons and the native color well.

const grid_size = 6
const default_cell_color = '#44475a'
const preset_colors = [
	'#ff5555', // Dracula Red
	'#ffb86c', // Dracula Orange
	'#f1fa8c', // Dracula Yellow
	'#50fa7b', // Dracula Green
	'#8be9fd', // Dracula Cyan
	'#bd93f9', // Dracula Purple
	'#f8f8f2', // Dracula White
	'#6272a4', // Dracula Comment / Gray
]

// AppState manages the reactive data for the application.
// We capture a reference to it in simplegui event handlers.
struct AppState {
mut:
	active_color string = '#ff5555' // Dracula Red default
	cell_colors  map[string]string // Key: "cell_r_c", Value: Hex color
}

fn main() {
	mut state := &AppState{}

	// 1. Initialize Window with a Dracula dark theme, custom padding and spacing
	mut win := simplegui.new_simple_window('Beginner 2D Grid Painter', 560, 750)
		.set_theme('dracula')
		.set_padding(20)
		.set_spacing(10)

	// Heading and description

	win.add_heading('🎨 2D Grid Painter')
		.font_color('#bd93f9')

	win.add_label('lbl_info', 'Learn 2D layouts by creating visual grids. Click cells to paint!')
		.font_size(11)
		.font_color('#6272a4')

	win.add_vertical_spacer(5)

	// 2. Build the interactive painting canvas
	// We wrap the grid inside a group box to organize the user interface.
	win.group('canvas_group', 'Painting Canvas (6x6 Grid)', fn (mut w simplegui.SimpleWindow) {
		for r in 0 .. grid_size {
			// begin_row starts a new horizontal row. Inside, all controls align side-by-side.
			w.begin_row('grid_row_${r}')
			for c in 0 .. grid_size {
				cell_name := 'cell_${r}_${c}'
				// Add button cell with default color

				w.add_button(cell_name, ' ')
					.width(55)
					.height(55)
					.color(default_cell_color)
			}
			// end_row terminates the row so subsequent elements stack vertically.
			w.end_row()
		}
	})

	// 3. Register click events for all cells in the 6x6 grid.
	// We use closure capturing [r, c, mut state] to know which cell was clicked.
	for r in 0 .. grid_size {
		for c in 0 .. grid_size {
			cell_name := 'cell_${r}_${c}'
			win.on_click(cell_name, fn [r, c, mut state] (mut w simplegui.SimpleWindow) {
				cell_key := 'cell_${r}_${c}'
				state.cell_colors[cell_key] = state.active_color
				// Dynamic background color change at runtime
				w.set_control_background_color(cell_key, state.active_color)
				w.set_status('Painted cell at Row ${r + 1}, Col ${c + 1} with ${state.active_color}')
			})
		}
	}

	win.add_vertical_spacer(5)

	// 4. Color selection controllers (Native color picker & quick presets)
	win.group('color_box', 'Color Selection', fn [mut state] (mut w simplegui.SimpleWindow) {
		// Native color well row
		w.begin_row('well_row')
		w.add_label('lbl_active', 'Active Color:').width(100).bold(true)

		w.add_color_well('custom_color_well', '#ff5555')
			.onchange(fn [mut state] (mut w2 simplegui.SimpleWindow, hex_color string) {
				state.active_color = hex_color
				w2.set_text('lbl_color_hex', 'Color: ${hex_color}')
				w2.set_status('Active color changed to ${hex_color} via picker')
			})
		w.add_label('lbl_color_hex', 'Color: #ff5555').width(150)
		w.end_row()

		w.add_vertical_spacer(5)

		// Preset color palette row
		w.begin_row('presets_row')
		w.add_label('lbl_presets', 'Presets:').width(80).bold(true)
		for idx, color_hex in preset_colors {
			preset_btn := 'preset_${idx}'

			w.add_button(preset_btn, ' ')
				.width(32)
				.height(32)
				.color(color_hex)
				.onclick(fn [color_hex, mut state] (mut w2 simplegui.SimpleWindow) {
					state.active_color = color_hex
					w2.set_text('lbl_color_hex', 'Color: ${color_hex}')
					// Sync the native color well to show the active preset color
					w2.set_text('custom_color_well', color_hex)
					w2.set_status('Active color changed to ${color_hex}')
				})
		}
		w.end_row()
	})

	win.add_vertical_spacer(5)

	// 5. Utility operations (Clear, Fill, Random, Export)
	win.group('actions_group', 'Canvas Actions', fn [mut state] (mut w simplegui.SimpleWindow) {
		w.begin_row('actions_row')

		w.add_button('btn_clear', 'Clear Canvas')
			.onclick(fn [mut state] (mut w2 simplegui.SimpleWindow) {
				for r in 0 .. grid_size {
					for c in 0 .. grid_size {
						cell_key := 'cell_${r}_${c}'
						state.cell_colors.delete(cell_key)
						w2.set_control_background_color(cell_key, default_cell_color)
					}
				}
				w2.set_text('txt_output', 'Canvas cleared!\n')
				w2.set_status('Canvas cleared')
			})

		w.add_button('btn_fill', 'Fill Canvas')
			.onclick(fn [mut state] (mut w2 simplegui.SimpleWindow) {
				for r in 0 .. grid_size {
					for c in 0 .. grid_size {
						cell_key := 'cell_${r}_${c}'
						state.cell_colors[cell_key] = state.active_color
						w2.set_control_background_color(cell_key, state.active_color)
					}
				}
				w2.set_text('txt_output', 'Canvas filled with ${state.active_color}!\n')
				w2.set_status('Canvas filled')
			})

		w.add_button('btn_random', 'Randomize')
			.onclick(fn [mut state] (mut w2 simplegui.SimpleWindow) {
				w2.set_text('txt_output', 'Generated random pattern:\n')
				for r in 0 .. grid_size {
					for c in 0 .. grid_size {
						cell_key := 'cell_${r}_${c}'
						random_idx := rand.intn(preset_colors.len) or { 0 }
						color_hex := preset_colors[random_idx]
						state.cell_colors[cell_key] = color_hex
						w2.set_control_background_color(cell_key, color_hex)
					}
				}
				w2.set_status('Generated random pattern')
			})

		w.add_button('btn_export', 'Export Design')
			.onclick(fn [state] (mut w2 simplegui.SimpleWindow) {
				mut log := '=== DESIGN EXPORT ===\n'
				log += 'Active Color: ${state.active_color}\n'
				log += 'Painted Cells:\n'
				mut painted_count := 0
				for r in 0 .. grid_size {
					for c in 0 .. grid_size {
						cell_key := 'cell_${r}_${c}'
						color_val := state.cell_colors[cell_key] or { '' }
						if color_val != '' {
							log += '- Cell [Row ${r + 1}, Col ${c + 1}]: ${color_val}\n'
							painted_count++
						}
					}
				}
				if painted_count == 0 {
					log += '(no painted cells found)\n'
				}
				w2.set_text('txt_output', log)
				w2.set_status('Design exported with ${painted_count} painted cells')
			})

		w.end_row()
	})

	win.add_vertical_spacer(5)

	// 6. Output textarea for logs and exports
	win.add_label('lbl_output', 'Export Output & Event Logs:')

	win.add_textarea('txt_output', 'Welcome to the 2D Grid Painter!\nSelect a color and paint your design on the grid.\n')
		.height(100)

	win.set_status('Ready to paint! Default color: Red.')

	// Start the application loop
	win.run()
}

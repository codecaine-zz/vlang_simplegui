module main

import simplegui

// Struct used for compile-time reflection binding
struct UserProfile {
mut:
	username string
	age      int
	is_admin bool
}

fn main() {
	simplegui.new_simple_window('Bulk Data Binding Demo', 550, 600)
		// 1. Setup Form Controls
		.add_form_field('Username', 'username', 'alex_dev')
		.add_form_number('Age', 'age', 28)
		.add_form_switch('Admin Status', 'is_admin', 'Is Administrator', true)

		.add_separator()

		// 2. Control Buttons for Map Operations
		.begin_row('row_maps')
			.add_button('btn_get_values', '1. Get Values Map')
			.add_button('btn_set_values', '2. Set Values Map')
			.add_button('btn_inspect', '3. Inspect Controls')
		.end_row()

		// 3. Control Buttons for Struct Operations
		.begin_row('row_structs')
			.add_button('btn_bind_struct', '4. Bind to Struct')
			.add_button('btn_load_struct', '5. Load from Struct')
		.end_row()

		// --- Event Handlers ---

		// 1. win.get_values() / win.dump_values()
		// Serializes input controls into a map[string]string
		.on_click('btn_get_values', fn (mut win simplegui.SimpleWindow) {
			values_map := win.get_values()
			println('Current Values Map: ${values_map}')
			win.set_status('Read map values: ${values_map}')
		})

		// 2. win.set_values(values map[string]string)
		// Sets multiple control values from a string map at once
		.on_click('btn_set_values', fn (mut win simplegui.SimpleWindow) {
			win.set_values({
				'username': 'john_doe'
				'age':      '35'
			})
			win.set_status('Set username and age via map.')
		})

		// 3. win.inspect_controls()
		// Returns a comma-separated list of all registered control names
		.on_click('btn_inspect', fn (mut win simplegui.SimpleWindow) {
			controls_list := win.inspect_controls()
			win.set_status('Registered controls: ${controls_list}')
		})

		// 4. win.bind_to_struct[T](mut data T)
		// Populates matching fields on a V struct using compile-time reflection
		.on_click('btn_bind_struct', fn (mut win simplegui.SimpleWindow) {
			mut profile := UserProfile{}
			win.bind_to_struct(mut profile)

			println('Extracted Struct: username="${profile.username}", age=${profile.age}, is_admin=${profile.is_admin}')
			win.set_status('Bound controls to struct: username=${profile.username}, age=${profile.age}')
		})

		// 5. win.load_from_struct[T](data T)
		// Populates GUI controls using values from a V struct
		.on_click('btn_load_struct', fn (mut win simplegui.SimpleWindow) {
			profile := UserProfile{
				username: 'sarah_connor'
				age:      29
				is_admin: false
			}

			win.load_from_struct(profile)
			win.set_status('Loaded controls from profile struct.')
		})
		.run()
}
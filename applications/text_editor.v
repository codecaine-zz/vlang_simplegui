module main

import simplegui
import os
import encoding.base64

struct EditorState {
mut:
	current_file_path string
	is_dirty          bool
	font_size         int
	font_family       string
}

fn count_words(text string) int {
	clean := text.replace('\n', ' ').replace('\r', ' ').replace('\t', ' ')
	tokens := clean.split(' ').filter(it.trim_space() != '')
	return tokens.len
}

fn main() {
	println('Starting SimpleGUI - Text Editor Pro (macOS Native Code & Document Studio)...')

	mut win := simplegui.new_simple_window('📝 Text Editor Pro — Native macOS Code & Document Studio', 1140, 920)
	win.restore_saved_theme()
	win.set_spacing(8)
	win.set_padding(16)

	mut state := &EditorState{
		current_file_path: ''
		is_dirty: false
		font_size: 14
		font_family: 'Menlo'
	}

	// -------------------------------------------------------------
	// Header & Theme Selector
	// -------------------------------------------------------------
	win.begin_row('row_header')
	win.add_heading('📝 Text Editor Pro — Code & Document Studio')

	saved_theme := simplegui.get_saved_theme()
	win.add_dropdown('dd_theme_selector', simplegui.list_themes(), saved_theme)
	win.set_control_width('dd_theme_selector', 180)
	win.end_row()

	// -------------------------------------------------------------
	// File Operations Toolbar
	// -------------------------------------------------------------
	win.begin_group_box('grp_file_bar', '📁 File Operations & Active Document')
	win.begin_row('row_file_ops')
	win.add_button('btn_new', '📄 New Document')
	win.add_button('btn_open', '📂 Open File...')
	win.add_button('btn_save', '💾 Save')
	win.add_button('btn_save_as', '💾 Save As...')
	win.add_button('btn_reveal', '👁️ Reveal in Finder')
	win.add_button('btn_copy_all', '📋 Copy All')

	win.add_label('lbl_active_file', '  Active File: Untitled.txt (Unsaved)')
	win.end_row()
	win.end_group_box()

	// -------------------------------------------------------------
	// Search, Replace & Quick Transformations
	// -------------------------------------------------------------
	win.begin_group_box('grp_search_tools', '🔍 Search, Replace & Text Transformations')
	win.begin_row('row_search')
	win.add_label('lbl_find', 'Find:')
	win.add_input('txt_find', '')
	win.set_control_width('txt_find', 180)

	win.add_label('lbl_replace', 'Replace:')
	win.add_input('txt_replace', '')
	win.set_control_width('txt_replace', 180)

	win.add_button('btn_replace_all', '🔄 Replace All')
	win.add_checkbox('chk_match_case', 'Match Case', false)

	win.add_label('lbl_font_size', '  Font Size:')
	win.add_button('btn_font_dec', '➖ A-')
	win.add_button('btn_font_inc', '➕ A+')

	win.add_label('lbl_font_fam', '  Font:')
	win.add_dropdown('dd_font_family', [
		'Menlo',
		'SF Mono',
		'Monaco',
		'Courier New',
		'Helvetica',
		'System'
	], 'Menlo')
	win.set_control_width('dd_font_family', 130)
	win.end_row()

	win.begin_row('row_transforms')
	win.add_button('btn_upper', '🔠 UPPERCASE')
	win.add_button('btn_lower', '🔡 lowercase')
	win.add_button('btn_title', '🔤 Title Case')
	win.add_button('btn_trim', '🧹 Trim Whitespace')
	win.add_button('btn_sort_lines', '🔢 Sort Lines (A-Z)')
	win.add_button('btn_dedup', '🗑️ Deduplicate Lines')
	win.add_button('btn_prettify_json', '📑 Prettify JSON')
	win.add_button('btn_b64_enc', '🔒 Base64 Enc')
	win.add_button('btn_b64_dec', '🔓 Base64 Dec')
	win.end_row()
	win.end_group_box()

	// -------------------------------------------------------------
	// Main Text Editor Canvas
	// -------------------------------------------------------------
	default_content := '// Welcome to SimpleGUI Text Editor Pro\n// A native macOS developer editor & document workspace.\n\nfn main() {\n    println("Hello, World!")\n}\n'
	win.add_textarea('txt_editor', default_content)
	win.set_control_height('txt_editor', 440)
	win.set_control_font_name('txt_editor', state.font_family)
	win.set_control_font_size('txt_editor', state.font_size)

	// -------------------------------------------------------------
	// Document Stats & Status Bar
	// -------------------------------------------------------------
	win.begin_row('row_status_bar')
	win.add_label('lbl_stats', '📊 Lines: 6  |  Words: 15  |  Characters: 125  |  Size: 125 B  |  Encoding: UTF-8')
	win.end_row()

	// Helper to update telemetry
	update_stats := fn (mut win simplegui.SimpleWindow, state &EditorState) {
		text := win.get('txt_editor')
		lines := text.split_into_lines().len
		words := count_words(text)
		chars := text.len
		
		file_display := if state.current_file_path != '' {
			name := os.file_name(state.current_file_path)
			if state.is_dirty { '* ' + name + ' (Modified)' } else { name }
		} else {
			if state.is_dirty { '* Untitled.txt (Unsaved)' } else { 'Untitled.txt' }
		}

		win.set('lbl_active_file', '  Active File: ' + file_display)
		win.set('lbl_stats', '📊 Lines: ${lines}  |  Words: ${words}  |  Characters: ${chars}  |  Size: ${chars} B  |  Encoding: UTF-8')
	}

	// -------------------------------------------------------------
	// Event Handlers
	// -------------------------------------------------------------

	// Theme Switching
	win.on_change('dd_theme_selector', fn (mut w simplegui.SimpleWindow, selected string) {
		w.set_theme(selected)
		w.toast('Theme changed to ${selected}')
	})

	// Text Modified in Editor
	win.on_change('txt_editor', fn [mut state, update_stats] (mut w simplegui.SimpleWindow, _ string) {
		state.is_dirty = true
		update_stats(mut w, state)
	})

	// New Document
	win.on_click('btn_new', fn [mut state, update_stats] (mut w simplegui.SimpleWindow) {
		if state.is_dirty {
			if !w.confirm('Discard Changes?', 'You have unsaved changes. Create a new document anyway?') {
				return
			}
		}
		state.current_file_path = ''
		state.is_dirty = false
		w.set('txt_editor', '')
		update_stats(mut w, state)
		w.toast('Created new document.')
	})

	// Open File
	win.on_click('btn_open', fn [mut state, update_stats] (mut w simplegui.SimpleWindow) {
		chosen := w.select_file()
		if chosen != '' && os.exists(chosen) {
			content := os.read_file(chosen) or {
				w.alert('Read Error', 'Failed to read file: ' + chosen)
				return
			}
			state.current_file_path = chosen
			state.is_dirty = false
			w.set('txt_editor', content)
			update_stats(mut w, state)
			w.toast('Opened ' + os.file_name(chosen))
		}
	})

	// Save File Helper
	save_doc := fn (mut w simplegui.SimpleWindow, mut state EditorState, update_stats_fn fn (mut simplegui.SimpleWindow, &EditorState)) {
		mut target_path := state.current_file_path
		if target_path == '' {
			target_path = w.save_file_picker()
			if target_path == '' { return }
		}

		content := w.get('txt_editor')
		os.write_file(target_path, content) or {
			w.alert('Save Error', 'Failed to write to file: ' + target_path)
			return
		}

		state.current_file_path = target_path
		state.is_dirty = false
		update_stats_fn(mut w, &state)
		w.toast('Saved ' + os.file_name(target_path))
	}

	// Save Button
	win.on_click('btn_save', fn [mut state, save_doc, update_stats] (mut w simplegui.SimpleWindow) {
		save_doc(mut w, mut state, update_stats)
	})

	// Save As Button
	win.on_click('btn_save_as', fn [mut state, update_stats] (mut w simplegui.SimpleWindow) {
		target_path := w.save_file_picker()
		if target_path != '' {
			content := w.get('txt_editor')
			os.write_file(target_path, content) or {
				w.alert('Save Error', 'Failed to write to file: ' + target_path)
				return
			}
			state.current_file_path = target_path
			state.is_dirty = false
			update_stats(mut w, state)
			w.toast('Saved as ' + os.file_name(target_path))
		}
	})

	// Reveal in Finder
	win.on_click('btn_reveal', fn [state] (mut w simplegui.SimpleWindow) {
		if state.current_file_path != '' && os.exists(state.current_file_path) {
			simplegui.reveal_in_finder(state.current_file_path)
			w.toast('Revealed in Finder.')
		} else {
			w.toast('Current document has not been saved to disk.')
		}
	})

	// Copy All Text
	win.on_click('btn_copy_all', fn (mut w simplegui.SimpleWindow) {
		text := w.get('txt_editor')
		w.copy_to_clipboard(text)
		w.toast('Copied document text to clipboard!')
	})

	// Replace All
	win.on_click('btn_replace_all', fn [mut state, update_stats] (mut w simplegui.SimpleWindow) {
		find_str := w.get('txt_find')
		replace_str := w.get('txt_replace')
		match_case := w.get_bool('chk_match_case')

		if find_str == '' {
			w.alert('Empty Search', 'Please enter a search query in the Find field.')
			return
		}

		text := w.get('txt_editor')
		mut new_text := ''
		if match_case {
			new_text = text.replace(find_str, replace_str)
		} else {
			// Case-insensitive replace
			lower_text := text.to_lower()
			lower_find := find_str.to_lower()
			mut start := 0
			mut res_builder := []string{}
			for {
				if idx := lower_text.index_after(lower_find, start) {
					res_builder << text[start..idx]
					res_builder << replace_str
					start = idx + find_str.len
				} else {
					res_builder << text[start..]
					break
				}
			}
			new_text = res_builder.join('')
		}

		w.set('txt_editor', new_text)
		state.is_dirty = true
		update_stats(mut w, state)
		w.toast('Replaced occurrences of "${find_str}".')
	})

	// Font Size Decrease
	win.on_click('btn_font_dec', fn [mut state] (mut w simplegui.SimpleWindow) {
		if state.font_size > 9 {
			state.font_size -= 1
			w.set_control_font_size('txt_editor', state.font_size)
			w.toast('Font Size: ${state.font_size}pt')
		}
	})

	// Font Size Increase
	win.on_click('btn_font_inc', fn [mut state] (mut w simplegui.SimpleWindow) {
		if state.font_size < 36 {
			state.font_size += 1
			w.set_control_font_size('txt_editor', state.font_size)
			w.toast('Font Size: ${state.font_size}pt')
		}
	})

	// Font Family Change
	win.on_change('dd_font_family', fn [mut state] (mut w simplegui.SimpleWindow, selected string) {
		state.font_family = selected
		w.set_control_font_name('txt_editor', selected)
		w.toast('Font Family: ${selected}')
	})

	// -------------------------------------------------------------
	// Text Transformations
	// -------------------------------------------------------------

	// UPPERCASE
	win.on_click('btn_upper', fn [mut state, update_stats] (mut w simplegui.SimpleWindow) {
		text := w.get('txt_editor')
		w.set('txt_editor', text.to_upper())
		state.is_dirty = true
		update_stats(mut w, state)
		w.toast('Converted to UPPERCASE.')
	})

	// lowercase
	win.on_click('btn_lower', fn [mut state, update_stats] (mut w simplegui.SimpleWindow) {
		text := w.get('txt_editor')
		w.set('txt_editor', text.to_lower())
		state.is_dirty = true
		update_stats(mut w, state)
		w.toast('Converted to lowercase.')
	})

	// Title Case
	win.on_click('btn_title', fn [mut state, update_stats] (mut w simplegui.SimpleWindow) {
		text := w.get('txt_editor')
		lines := text.split_into_lines()
		mut res := []string{cap: lines.len}
		for line in lines {
			words := line.split(' ')
			mut title_words := []string{cap: words.len}
			for word in words {
				if word.len > 0 {
					first := word[..1].to_upper()
					rest := if word.len > 1 { word[1..].to_lower() } else { '' }
					title_words << first + rest
				} else {
					title_words << ''
				}
			}
			res << title_words.join(' ')
		}
		w.set('txt_editor', res.join('\n'))
		state.is_dirty = true
		update_stats(mut w, state)
		w.toast('Converted to Title Case.')
	})

	// Trim Whitespace
	win.on_click('btn_trim', fn [mut state, update_stats] (mut w simplegui.SimpleWindow) {
		text := w.get('txt_editor')
		lines := text.split_into_lines()
		mut res := []string{cap: lines.len}
		for line in lines {
			res << line.trim_space()
		}
		w.set('txt_editor', res.join('\n'))
		state.is_dirty = true
		update_stats(mut w, state)
		w.toast('Trimmed whitespace from all lines.')
	})

	// Sort Lines (A-Z)
	win.on_click('btn_sort_lines', fn [mut state, update_stats] (mut w simplegui.SimpleWindow) {
		text := w.get('txt_editor')
		mut lines := text.split_into_lines()
		lines.sort()
		w.set('txt_editor', lines.join('\n'))
		state.is_dirty = true
		update_stats(mut w, state)
		w.toast('Sorted lines alphabetically.')
	})

	// Deduplicate Lines
	win.on_click('btn_dedup', fn [mut state, update_stats] (mut w simplegui.SimpleWindow) {
		text := w.get('txt_editor')
		lines := text.split_into_lines()
		mut seen := map[string]bool{}
		mut res := []string{}
		for line in lines {
			if !seen[line] {
				seen[line] = true
				res << line
			}
		}
		w.set('txt_editor', res.join('\n'))
		state.is_dirty = true
		update_stats(mut w, state)
		w.toast('Deduplicated lines (kept ${res.len} unique lines).')
	})

	// Prettify JSON
	win.on_click('btn_prettify_json', fn [mut state, update_stats] (mut w simplegui.SimpleWindow) {
		text := w.get('txt_editor').trim_space()
		if text == '' { return }

		// Use python3 -m json.tool or jq for robust formatted JSON indentation
		res := simplegui.exec_safe_stdin('python3', ['-m', 'json.tool'], text)
		if res.exit_code == 0 && res.output.trim_space() != '' {
			w.set('txt_editor', res.output)
			state.is_dirty = true
			update_stats(mut w, state)
			w.toast('Prettified JSON structure!')
		} else {
			w.alert('JSON Parse Error', 'Document is not valid JSON:\n' + res.output)
		}
	})

	// Base64 Encode
	win.on_click('btn_b64_enc', fn [mut state, update_stats] (mut w simplegui.SimpleWindow) {
		text := w.get('txt_editor')
		enc := base64.encode_str(text)
		w.set('txt_editor', enc)
		state.is_dirty = true
		update_stats(mut w, state)
		w.toast('Base64 Encoded.')
	})

	// Base64 Decode
	win.on_click('btn_b64_dec', fn [mut state, update_stats] (mut w simplegui.SimpleWindow) {
		text := w.get('txt_editor').trim_space()
		dec := base64.decode_str(text)
		w.set('txt_editor', dec)
		state.is_dirty = true
		update_stats(mut w, state)
		w.toast('Base64 Decoded.')
	})

	// Initial Stats Update
	update_stats(mut win, state)

	println('Text Editor Pro configured. Starting event loop...')
	win.run()
}

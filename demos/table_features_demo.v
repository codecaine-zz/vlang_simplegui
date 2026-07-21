module main

import simplegui
import strconv

fn main() {
	mut win := simplegui.new_simple_window('Table Features Pro Demo', 880, 760)
	win.set_theme('GitHub Light')
	win.set_padding(16)
	win.set_spacing(10)

	win.add_heading('Table Features Pro Demo')
	win.add_label('hint', 'Select rows, edit values, sort both directions, and import/export using file pickers.')

	win.row('editor_row', fn (mut w simplegui.SimpleWindow) {
		w.add_input('in_id', '').placeholder('ID').width(100)
		w.add_input('in_name', '').placeholder('Name').width(200)
		w.add_input('in_score', '').placeholder('Score').width(120)
	})

	win.add_action_row({
		'Add Row':          add_or_update_row
		'Add Row (Strict)': add_row_strict
		'Update Selected':  update_selected_row
		'Update (Strict)':  update_selected_row_strict
		'Delete Selected':  delete_selected_rows
		'Clear Editor':     clear_editor
		'Show Summary':     show_summary
	})

	win.add_table('data_table', ['ID', 'Name', 'Score'])
	win.set_table_rows('data_table', [
		['103', 'Charlie', '88.5'],
		['101', 'Alice', '95.0'],
		['102', 'Bob', '72.0'],
		['104', 'Diana', '90.5'],
	])
	win.set_table_column_selection('data_table', true)
	win.set_table_multi_select('data_table', true)

	win.add_action_row({
		'Sort ID Asc':     fn (mut w simplegui.SimpleWindow) {
			sort_table(mut w, 0, true, 'ID ascending')
		}
		'Sort ID Desc':    fn (mut w simplegui.SimpleWindow) {
			sort_table(mut w, 0, false, 'ID descending')
		}
		'Sort Name Asc':   fn (mut w simplegui.SimpleWindow) {
			sort_table(mut w, 1, true, 'Name ascending')
		}
		'Sort Name Desc':  fn (mut w simplegui.SimpleWindow) {
			sort_table(mut w, 1, false, 'Name descending')
		}
		'Sort Score Asc':  fn (mut w simplegui.SimpleWindow) {
			sort_table(mut w, 2, true, 'Score ascending')
		}
		'Sort Score Desc': fn (mut w simplegui.SimpleWindow) {
			sort_table(mut w, 2, false, 'Score descending')
		}
	})

	win.add_action_row({
		'Move Up':          move_selected_up
		'Move Down':        move_selected_down
		'Select Score Col': select_score_column
		'Clear Col Sel':    clear_column_selection
		'Delete Sel Col':   delete_selected_column
		'Copy Sel Column':  copy_selected_column
		'Strict Normalize': strict_normalize_demo
		'Find ID (Strict)': find_id_strict
		'Export CSV':       export_csv
		'Import CSV':       import_csv
		'Export JSON':      export_json
		'Import JSON':      import_json
	})

	win.on_table_select('data_table', fn (mut w simplegui.SimpleWindow, _ string) {
		fill_editor_from_selected(mut w)
		set_selection_status(mut w)
	})

	win.on_table_column_select('data_table', fn (mut w simplegui.SimpleWindow, value string) {
		idx := value.int()
		if idx < 0 {
			w.status('Column selection cleared.')
			return
		}
		w.status('Column selected: ${column_label(idx)}')
	})

	win.on_table_double_click('data_table', fn (mut w simplegui.SimpleWindow, row string) {
		idx := row.int()
		if idx < 0 {
			return
		}
		selected := w.get_table_row('data_table', idx)
		if selected.len < 3 {
			return
		}
		score := strconv.atof64(selected[2]) or { 0.0 }
		boosted := score + 1.0
		w.set_table_cell('data_table', idx, 2, format_score(boosted))
		w.set_table_selected('data_table', idx)
		fill_editor_from_selected(mut w)
		w.status('Boosted ${selected[1]} to ${format_score(boosted)} by double-click.')
	})

	win.set_status('${win.get_table_row_count('data_table')} rows loaded. Cmd or Shift-click for multi-select.')
	win.run()
}

fn select_score_column(mut win simplegui.SimpleWindow) {
	win.set_table_selected_column('data_table', 2)
	idx := win.get_table_selected_column('data_table')
	if idx < 0 {
		win.status('Column selection is unavailable.')
		return
	}
	win.status('Selected entire column ${idx + 1} (${column_label(idx)}).')
}

fn clear_column_selection(mut win simplegui.SimpleWindow) {
	win.set_table_selected_column('data_table', -1)
	win.status('Cleared table column selection.')
}

fn delete_selected_column(mut win simplegui.SimpleWindow) {
	col, removed := win.remove_selected_table_column_strict('data_table') or {
		win.warn('No Column Selected', 'Select a column first (or use Select Score Col).')
		win.status('Delete skipped: no selected column.')
		return
	}
	win.status('Deleted column ${col + 1} (${column_label(col)}), removed ${removed.len} value(s).')
}

fn copy_selected_column(mut win simplegui.SimpleWindow) {
	idx := win.get_table_selected_column('data_table')
	if idx < 0 {
		win.warn('No Column Selected', 'Select a column first.')
		win.status('Copy skipped: no selected column.')
		return
	}
	values := win.get_table_selected_column_values('data_table')
	if values.len == 0 {
		win.status('Copy skipped: selected column has no rows.')
		return
	}
	win.copy_to_clipboard(values.join('\n'))
	win.status('Copied ${values.len} value(s) from ${column_label(idx)} column to clipboard.')
}

fn add_or_update_row(mut win simplegui.SimpleWindow) {
	row := gather_editor_row(mut win) or {
		win.status(err.msg())
		return
	}
	if win.find_table_row('data_table', 0, row[0]) >= 0 {
		win.warn('Duplicate ID', 'A row with ID ${row[0]} already exists.')
		win.status('Add cancelled due to duplicate ID ${row[0]}.')
		return
	}
	win.add_table_row('data_table', row)
	win.clear_table_selection('data_table')
	clear_editor(mut win)
	win.status('Added row ${row[0]}: ${row[1]} (${row[2]}). Total rows: ${win.get_table_row_count('data_table')}')
}

fn add_row_strict(mut win simplegui.SimpleWindow) {
	row := gather_editor_row(mut win) or {
		win.status(err.msg())
		return
	}
	if win.find_table_row('data_table', 0, row[0]) >= 0 {
		win.warn('Duplicate ID', 'A row with ID ${row[0]} already exists.')
		win.status('Strict add cancelled due to duplicate ID ${row[0]}.')
		return
	}
	win.add_table_row_strict('data_table', row) or {
		win.error_dialog('Strict Add Failed', err.msg())
		win.status('Strict add failed: ${err.msg()}')
		return
	}
	win.clear_table_selection('data_table')
	clear_editor(mut win)
	win.status('Strict add OK. Columns: ${win.get_table_column_count('data_table')}, rows: ${win.get_table_row_count('data_table')}.')
}

fn update_selected_row(mut win simplegui.SimpleWindow) {
	idx := win.get_table_selected('data_table')
	if idx < 0 {
		win.warn('No Selection', 'Select a table row to update.')
		win.status('Update skipped: no row selected.')
		return
	}
	row := gather_editor_row(mut win) or {
		win.status(err.msg())
		return
	}
	for i, existing in win.get_table_rows('data_table') {
		if i != idx && existing.len > 0 && existing[0] == row[0] {
			win.warn('Duplicate ID', 'Another row already uses ID ${row[0]}.')
			win.status('Update cancelled due to duplicate ID ${row[0]}.')
			return
		}
	}
	win.update_table_row('data_table', idx, row)
	win.set_table_selected('data_table', idx)
	win.status('Updated row ${idx + 1} to ${row[1]} (${row[2]}).')
}

fn update_selected_row_strict(mut win simplegui.SimpleWindow) {
	idx := win.get_table_selected('data_table')
	if idx < 0 {
		win.warn('No Selection', 'Select a table row to update.')
		win.status('Strict update skipped: no row selected.')
		return
	}
	row := gather_editor_row(mut win) or {
		win.status(err.msg())
		return
	}
	for i, existing in win.get_table_rows('data_table') {
		if i != idx && existing.len > 0 && existing[0] == row[0] {
			win.warn('Duplicate ID', 'Another row already uses ID ${row[0]}.')
			win.status('Strict update cancelled due to duplicate ID ${row[0]}.')
			return
		}
	}
	win.update_table_row_strict('data_table', idx, row) or {
		win.error_dialog('Strict Update Failed', err.msg())
		win.status('Strict update failed: ${err.msg()}')
		return
	}
	win.set_table_selected('data_table', idx)
	win.status('Strict update OK at row ${idx + 1}.')
}

fn delete_selected_rows(mut win simplegui.SimpleWindow) {
	selected := win.get_table_selected_indexes('data_table')
	if selected.len == 0 {
		win.warn('No Selection', 'Select one or more rows to delete.')
		win.status('Delete skipped: no rows selected.')
		return
	}
	if !win.ask('Delete Rows', 'Remove ${selected.len} selected row(s)?') {
		win.status('Delete cancelled.')
		return
	}
	removed := win.remove_selected_table_rows('data_table')
	clear_editor(mut win)
	win.status('Deleted ${removed.len} row(s). ${win.get_table_row_count('data_table')} row(s) remain.')
}

fn clear_editor(mut win simplegui.SimpleWindow) {
	win.clear_many(['in_id', 'in_name', 'in_score'])
	win.clear_errors_for(['in_id', 'in_name', 'in_score'])
	win.focus('in_id')
}

fn show_summary(mut win simplegui.SimpleWindow) {
	rows := win.get_table_rows('data_table')
	if rows.len == 0 {
		win.info('Table Summary', 'No rows to summarize.')
		return
	}
	total := win.get_table_column_sum('data_table', 2)
	avg := win.get_table_column_average('data_table', 2)
	avg_numeric := win.get_table_column_average_numeric('data_table', 2)
	win.info('Table Summary', 'Rows: ${rows.len}\nColumns: ${win.get_table_column_count('data_table')}\nTotal score: ${format_score(total)}\nAverage score (legacy): ${format_score(avg)}\nAverage score (numeric-only): ${format_score(avg_numeric)}')
	win.status('Summary calculated for ${rows.len} row(s).')
}

fn column_label(index int) string {
	if index == 0 {
		return 'ID'
	}
	if index == 1 {
		return 'Name'
	}
	if index == 2 {
		return 'Score'
	}
	return 'Column ${index + 1}'
}

fn strict_normalize_demo(mut win simplegui.SimpleWindow) {
	rows := win.get_table_rows('data_table')
	if rows.len == 0 {
		win.status('Strict normalize skipped: table is empty.')
		return
	}
	mut ragged := rows.map(it.clone())
	ragged << ['999', 'Ragged only ID']
	ragged << ['1000', 'Extra', '42.0', 'ignored-col']
	win.set_table_rows_strict('data_table', ragged) or {
		win.error_dialog('Strict Normalize Failed', err.msg())
		win.status('Strict normalize failed: ${err.msg()}')
		return
	}
	win.status('Strict normalize applied. Rows: ${win.get_table_row_count('data_table')}, columns: ${win.get_table_column_count('data_table')}.')
}

fn find_id_strict(mut win simplegui.SimpleWindow) {
	id := win.prompt('Find ID (Strict)', 'Enter an ID from column 0:', '').trim_space()
	if id == '' {
		win.status('Strict find cancelled.')
		return
	}
	idx := win.find_table_row_strict('data_table', 0, id) or {
		win.warn('Not Found', err.msg())
		win.status('Strict find failed: ${err.msg()}')
		return
	}
	win.set_table_selected('data_table', idx)
	fill_editor_from_selected(mut win)
	win.status('Strict find OK: ID ${id} at row ${idx + 1}.')
}

fn sort_table(mut win simplegui.SimpleWindow, column int, ascending bool, label string) {
	count := win.get_table_row_count('data_table')
	if count < 2 {
		win.status('Sort skipped: need at least 2 rows.')
		return
	}
	win.sort_table_by_column('data_table', column, ascending)
	win.status('Sorted by ${label}.')
}

fn move_selected_up(mut win simplegui.SimpleWindow) {
	idx := win.get_table_selected('data_table')
	if idx < 0 {
		win.warn('No Selection', 'Select a row first.')
		win.status('Move up skipped: no row selected.')
		return
	}
	if idx == 0 {
		win.status('Move up skipped: already at top.')
		return
	}
	win.move_selected_table_row_up('data_table')
	win.status('Moved row up to position ${idx}.')
}

fn move_selected_down(mut win simplegui.SimpleWindow) {
	idx := win.get_table_selected('data_table')
	count := win.get_table_row_count('data_table')
	if idx < 0 {
		win.warn('No Selection', 'Select a row first.')
		win.status('Move down skipped: no row selected.')
		return
	}
	if idx >= count - 1 {
		win.status('Move down skipped: already at bottom.')
		return
	}
	win.move_selected_table_row_down('data_table')
	win.status('Moved row down to position ${idx + 2}.')
}

fn export_csv(mut win simplegui.SimpleWindow) {
	path := win.choose_save_file()
	if path == '' {
		win.status('CSV export cancelled.')
		return
	}
	win.save_table_to_csv('data_table', path) or {
		win.error_dialog('CSV Export Failed', err.msg())
		win.status('CSV export failed: ${err}')
		return
	}
	win.status('Exported CSV to ${path}.')
}

fn import_csv(mut win simplegui.SimpleWindow) {
	path := win.choose_file_ext('csv')
	if path == '' {
		win.status('CSV import cancelled.')
		return
	}
	win.load_table_from_csv('data_table', path) or {
		win.error_dialog('CSV Import Failed', err.msg())
		win.status('CSV import failed: ${err}')
		return
	}
	clean := normalize_rows(win.get_table_rows('data_table'))
	if clean.len == 0 {
		win.warn('Import Empty', 'No valid rows were found in the CSV file.')
		win.status('CSV import produced no valid rows.')
		return
	}
	win.set_table_rows('data_table', clean)
	win.clear_table_selection('data_table')
	clear_editor(mut win)
	win.status('Imported ${clean.len} row(s) from CSV.')
}

fn export_json(mut win simplegui.SimpleWindow) {
	path := win.choose_save_file()
	if path == '' {
		win.status('JSON export cancelled.')
		return
	}
	win.save_table_to_json('data_table', path) or {
		win.error_dialog('JSON Export Failed', err.msg())
		win.status('JSON export failed: ${err}')
		return
	}
	win.status('Exported JSON to ${path}.')
}

fn import_json(mut win simplegui.SimpleWindow) {
	path := win.choose_file_ext('json')
	if path == '' {
		win.status('JSON import cancelled.')
		return
	}
	win.load_table_from_json('data_table', path) or {
		win.error_dialog('JSON Import Failed', err.msg())
		win.status('JSON import failed: ${err}')
		return
	}
	clean := normalize_rows(win.get_table_rows('data_table'))
	if clean.len == 0 {
		win.warn('Import Empty', 'No valid rows were found in the JSON file.')
		win.status('JSON import produced no valid rows.')
		return
	}
	win.set_table_rows('data_table', clean)
	win.clear_table_selection('data_table')
	clear_editor(mut win)
	win.status('Imported ${clean.len} row(s) from JSON.')
}

fn fill_editor_from_selected(mut win simplegui.SimpleWindow) {
	row := win.get_table_selected_row('data_table')
	if row.len < 3 {
		return
	}
	win.set_value('in_id', row[0])
	win.set_value('in_name', row[1])
	win.set_value('in_score', row[2])
	win.clear_errors_for(['in_id', 'in_name', 'in_score'])
}

fn set_selection_status(mut win simplegui.SimpleWindow) {
	selected := win.get_table_selected_rows('data_table')
	if selected.len == 0 {
		win.status('Selection cleared.')
		return
	}
	if selected.len == 1 {
		row := selected[0]
		if row.len >= 3 {
			win.status('Selected ${row[1]} with score ${row[2]}.')
		}
		return
	}
	win.status('${selected.len} rows selected.')
}

fn gather_editor_row(mut win simplegui.SimpleWindow) ![]string {
	id := win.get_value('in_id').trim_space()
	name := win.get_value('in_name').trim_space()
	score_raw := win.get_value('in_score').trim_space()
	win.clear_errors_for(['in_id', 'in_name', 'in_score'])
	mut has_error := false
	if id == '' {
		win.set_error('in_id', 'Required')
		has_error = true
	} else if id.int() <= 0 {
		win.set_error('in_id', 'Use a positive integer')
		has_error = true
	}
	if name == '' {
		win.set_error('in_name', 'Required')
		has_error = true
	}
	score := strconv.atof64(score_raw) or {
		win.set_error('in_score', 'Use a numeric score')
		has_error = true
		0.0
	}
	if has_error {
		win.status('Validation failed. Fix highlighted fields.')
		return error('Validation failed.')
	}
	return [id.int().str(), name, format_score(score)]
}

fn normalize_rows(rows [][]string) [][]string {
	mut clean := [][]string{}
	for row in rows {
		if row.len < 3 {
			continue
		}
		id := row[0].trim_space()
		name := row[1].trim_space()
		score_raw := row[2].trim_space()
		if id == '' || name == '' {
			continue
		}
		id_num := id.int()
		if id_num <= 0 {
			continue
		}
		score := strconv.atof64(score_raw) or { continue }
		clean << [id_num.str(), name, format_score(score)]
	}
	return clean
}

fn format_score(score f64) string {
	return '${score:.2f}'
}

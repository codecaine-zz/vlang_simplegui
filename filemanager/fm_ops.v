module filemanager

import json2
import os

$if macos {
	#include <sys/clonefile.h>
	#include <copyfile.h>
}

fn C.clonefile(&char, &char, u32) int
fn C.copyfile(&char, &char, voidptr, u32) int

// copy_entry_recursive recursively copies a file, symlink, or directory tree from `src` to `dst`.
// On macOS APFS volumes, uses kernel-level Copy-on-Write `clonefile(2)` / `copyfile(3)` first for zero-copy speed and xattr preservation.
pub fn copy_entry_recursive(src string, dst string) ! {
	$if macos {
		if !os.exists(dst) && !os.is_link(dst) {
			if C.clonefile(&char(src.str), &char(dst.str), u32(0x0001)) == 0 {
				return
			}
		}
	}
	if os.is_link(src) {
		target := os.readlink(src)!
		os.symlink(target, dst)!
		return
	}
	if os.is_dir(src) {
		os.mkdir_all(dst)!
		names := os.ls(src)!
		for n in names {
			copy_entry_recursive(os.join_path(src, n), os.join_path(dst, n))!
		}
		return
	}
	$if macos {
		// COPYFILE_ALL (15) | COPYFILE_CLONE (1 << 24)
		if C.copyfile(&char(src.str), &char(dst.str), unsafe { nil }, u32(15 | (1 << 24))) == 0 {
			return
		}
	}
	os.cp(src, dst)!
}

// move_entry_safe moves `src` to `dst`, falling back to recursive copy-and-delete across filesystems.
pub fn move_entry_safe(src string, dst string) ! {
	os.mv(src, dst) or {
		copy_entry_recursive(src, dst)!
		if os.is_dir(src) && !os.is_link(src) {
			os.rmdir_all(src)!
		} else {
			os.rm(src)!
		}
	}
}

// remove_entry_safe deletes a file, symlink, or directory tree at `target`.
pub fn remove_entry_safe(target string) ! {
	if os.is_link(target) || !os.is_dir(target) {
		os.rm(target)!
	} else {
		os.rmdir_all(target)!
	}
}

// handle_create_folder creates a new directory inside the specified parent path.
pub fn handle_create_folder(ctx &FmContext, b map[string]json2.Any) !string {
	dir_raw := map_str(b, 'parent', map_str(b, 'dir', ''))
	name_raw := map_str(b, 'name', '').trim_space()
	parent := resolve_existing(ctx, dir_raw, true)!
	target := if name_raw == '' {
		unique_sibling(parent, 'New folder', true, '')!
	} else {
		resolve_new_target(ctx, parent, name_raw)!
	}
	if os.exists(target) || os.is_link(target) {
		return error('EXISTS: "${os.base(target)}" already exists here. Choose a different name.')
	}
	os.mkdir(target)!
	entry := build_entry(target, os.base(target)) or {
		return error('NOT_FOUND: Created folder could not be read.')
	}
	return '{"path":${json_str(target)},"name":${json_str(os.base(target))},"entry":${entry_to_json(entry)}}'
}

// handle_create_file creates a new file with optional initial content inside the specified parent path.
pub fn handle_create_file(ctx &FmContext, b map[string]json2.Any) !string {
	dir_raw := map_str(b, 'parent', map_str(b, 'dir', ''))
	name_raw := map_str(b, 'name', '').trim_space()
	content := map_str(b, 'content', '')
	parent := resolve_existing(ctx, dir_raw, true)!
	target := if name_raw == '' {
		unique_sibling(parent, 'New file.txt', false, '')!
	} else {
		resolve_new_target(ctx, parent, name_raw)!
	}
	if os.exists(target) || os.is_link(target) {
		return error('EXISTS: "${os.base(target)}" already exists here. Choose a different name.')
	}
	os.write_file(target, content)!
	entry := build_entry(target, os.base(target)) or {
		return error('NOT_FOUND: Created file could not be read.')
	}
	return '{"path":${json_str(target)},"name":${json_str(os.base(target))},"entry":${entry_to_json(entry)}}'
}

// handle_create_sqlite creates and initializes a new SQLite database file with optional starter tables.
pub fn handle_create_sqlite(ctx &FmContext, b map[string]json2.Any) !string {
	dir_raw := map_str(b, 'parent', map_str(b, 'dir', ''))
	raw_name := map_str(b, 'name', '').trim_space()
	if raw_name == '' {
		return error('INVALID_NAME: Enter a name for the database file.')
	}
	lower := raw_name.to_lower()
	has_ext := lower.ends_with('.sqlite') || lower.ends_with('.sqlite3') || lower.ends_with('.db')
	final_name := if has_ext { raw_name } else { '${raw_name}.sqlite' }
	target := resolve_new_target(ctx, dir_raw, final_name)!
	if os.exists(target) || os.is_link(target) {
		return error('EXISTS: "${os.base(target)}" already exists in this folder.')
	}
	tmpl := map_str(b, 'template', 'empty')
	sql := match tmpl {
		'notes' {
			"CREATE TABLE notes (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, body TEXT NOT NULL DEFAULT '', created_at TEXT NOT NULL DEFAULT (datetime('now'))); INSERT INTO notes (title, body) VALUES ('Welcome', 'This SQLite database was created in Codecaine File Manager.');"
		}
		'tasks' {
			"CREATE TABLE tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, done INTEGER NOT NULL DEFAULT 0 CHECK (done IN (0, 1)), priority TEXT NOT NULL DEFAULT 'normal', due_date TEXT, created_at TEXT NOT NULL DEFAULT (datetime('now'))); INSERT INTO tasks (title, done, priority) VALUES ('Open this database in SQLite Studio', 0, 'high');"
		}
		else {
			'PRAGMA user_version = 1; VACUUM;'
		}
	}
	res := os.execute('sqlite3 ${os.quoted_path(target)} ${os.quoted_path(sql)}')
	if res.exit_code != 0 || !os.exists(target) {
		// Write minimal valid 4096-byte SQLite 3 header if sqlite3 CLI is unavailable
		mut page := []u8{len: 4096}
		magic := 'SQLite format 3\0'.bytes()
		for i, ch in magic {
			page[i] = ch
		}
		page[16] = 0x10 // page size 4096
		page[17] = 0x00
		page[18] = 1
		page[19] = 1
		page[21] = 64
		page[22] = 32
		page[23] = 32
		page[28] = 0
		page[29] = 0
		page[30] = 0
		page[31] = 1
		page[56] = 0
		page[57] = 0
		page[58] = 0
		page[59] = 1 // UTF-8
		page[96] = 0x00
		page[97] = 0x2e
		page[98] = 0x63
		page[99] = 0x50
		page[100] = 0x0d // leaf table b-tree page
		page[105] = 0x10
		page[106] = 0x00
		os.write_file_array(target, page)!
	}
	entry := build_entry(target, os.base(target)) or {
		return error('NOT_FOUND: Created database could not be read.')
	}
	return '{"path":${json_str(target)},"name":${json_str(os.base(target))},"entry":${entry_to_json(entry)},"template":${json_str(if tmpl in [
		'notes',
		'tasks',
	] {
		tmpl
	} else {
		'empty'
	})}}'
}

// handle_rename_item renames a file or folder within its parent directory.
pub fn handle_rename_item(ctx &FmContext, b map[string]json2.Any) !string {
	raw_path := map_str(b, 'path', '')
	new_name := map_str(b, 'name', map_str(b, 'newName', ''))
	src := resolve_existing(ctx, raw_path, false)!
	check_not_protected(ctx, src, 'rename')!
	clean_name := valid_name(new_name)!
	parent := os.dir(src)
	dst := os.join_path(parent, clean_name)
	if dst == src {
		entry := build_entry(src, os.base(src)) or { return error('NOT_FOUND: Item missing') }
		return '{"from":${json_str(src)},"to":${json_str(src)},"entry":${entry_to_json(entry)},"oldPath":${json_str(src)},"newPath":${json_str(src)}}'
	}
	if os.exists(dst) || os.is_link(dst) {
		if src.to_lower() != dst.to_lower() {
			return error('EXISTS: "${clean_name}" already exists in this folder.')
		}
	}
	os.mv(src, dst)!
	entry := build_entry(dst, clean_name) or { return error('NOT_FOUND: Renamed item missing') }
	return '{"from":${json_str(src)},"to":${json_str(dst)},"entry":${entry_to_json(entry)},"oldPath":${json_str(src)},"newPath":${json_str(dst)}}'
}

// handle_relocate moves an item to a new parent directory.
pub fn handle_relocate(ctx &FmContext, b map[string]json2.Any) !string {
	mut outcomes := []string{}
	if pairs_any := b['pairs'] {
		if pairs_any is []json2.Any {
			for p in pairs_any {
				if p is map[string]json2.Any {
					from_raw := map_str(p, 'from', '')
					to_raw := map_str(p, 'to', '')
					src := resolve_existing(ctx, from_raw, false) or {
						outcomes << '{"ok":false,"code":"NOT_FOUND","message":${json_str(err.msg())}}'
						continue
					}
					dst := resolve_new_target(ctx, os.dir(to_raw), os.base(to_raw)) or {
						outcomes << '{"ok":false,"code":"BAD_NAME","message":${json_str(err.msg())}}'
						continue
					}
					os.mkdir_all(os.dir(dst)) or {}
					move_entry_safe(src, dst) or {
						outcomes << '{"ok":false,"code":"ERROR","message":${json_str(err.msg())}}'
						continue
					}
					outcomes << '{"ok":true,"value":{"from":${json_str(src)},"to":${json_str(dst)}}}'
				}
			}
		}
	}
	return '{"results":[${outcomes.join(',')}]}'
}

// handle_conflicts checks which source paths would collide with existing entries in the destination directory.
pub fn handle_conflicts(ctx &FmContext, b map[string]json2.Any) !string {
	sources := map_str_array(b, 'sources')
	dest_raw := map_str(b, 'dest', map_str(b, 'destination', ''))
	dest_dir := resolve_existing(ctx, dest_raw, true)!
	mut conflicts := []string{}
	for s in sources {
		if src := resolve_existing(ctx, s, false) {
			if os.dir(src) == dest_dir {
				continue
			}
			target := os.join_path(dest_dir, os.base(src))
			if os.exists(target) || os.is_link(target) {
				ex_dir := os.is_dir(target) && !os.is_link(target)
				src_dir := os.is_dir(src) && !os.is_link(src)
				conflicts << '{"source":${json_str(src)},"name":${json_str(os.base(src))},"existingIsDir":${json_bool(ex_dir)},"sourceIsDir":${json_bool(src_dir)}}'
			}
		}
	}
	return '{"conflicts":[${conflicts.join(',')}]}'
}

// handle_bulk_rename previews or applies batch rename rules (find/replace, prefix/suffix, numbering, case) to multiple items.
pub fn handle_bulk_rename(ctx &FmContext, b map[string]json2.Any) !string {
	// Support `bulkrename` ({ folder, names, spec, apply }) as well as `{ items: [{ path, newName }] }`
	if 'folder' in b && 'names' in b {
		folder_raw := map_str(b, 'folder', '')
		folder := resolve_existing(ctx, folder_raw, true)!
		names := map_str_array(b, 'names')
		apply := map_bool(b, 'apply', false)
		mut spec_mode := 'replace'
		mut find_s := ''
		mut repl_s := ''
		mut prefix_s := ''
		mut suffix_s := ''
		mut style_s := 'lower'
		mut start_n := 1
		mut pad_n := 1
		mut pat_s := '{name} {n}'
		if spec_any := b['spec'] {
			if spec_any is map[string]json2.Any {
				spec_mode = map_str(spec_any, 'mode', 'replace')
				find_s = map_str(spec_any, 'find', '')
				repl_s = map_str(spec_any, 'replace', '')
				prefix_s = map_str(spec_any, 'prefix', '')
				suffix_s = map_str(spec_any, 'suffix', '')
				style_s = map_str(spec_any, 'style', 'lower')
				start_n = map_int(spec_any, 'start', 1)
				pad_n = map_int(spec_any, 'padding', 1)
				pat_s = map_str(spec_any, 'pattern', '{name} {n}')
			}
		}
		mut rows := []string{}
		for idx, from_name in names {
			clean_from := valid_name(from_name)!
			stem, ext_dot := split_stem_ext(clean_from, false)
			next_stem := match spec_mode {
				'replace' {
					if find_s != '' { stem.replace(find_s, repl_s) } else { stem }
				}
				'affix' {
					'${prefix_s}${stem}${suffix_s}'
				}
				'case' {
					match style_s {
						'upper' { stem.to_upper() }
						'title' { stem.title() }
						else { stem.to_lower() }
					}
				}
				'number' {
					pad_width := if pad_n < 1 {
						1
					} else if pad_n > 32 {
						32
					} else {
						pad_n
					}
					mut num_str := (start_n + idx).str()
					for num_str.len < pad_width {
						num_str = '0' + num_str
					}
					pat_s.replace('{name}', stem).replace('{n}', num_str)
				}
				else {
					stem
				}
			}
			to_name := valid_name('${next_stem}${ext_dot}')!
			changed := to_name != clean_from
			if apply && changed {
				src := os.join_path(folder, clean_from)
				dst := os.join_path(folder, to_name)
				check_not_protected(ctx, src, 'rename')!
				check_not_protected(ctx, dst, 'rename')!
				if os.exists(src) && !os.exists(dst) {
					os.mv(src, dst) or {}
				}
			}
			rows << '{"from":${json_str(clean_from)},"to":${json_str(to_name)},"changed":${json_bool(changed)},"error":null}'
		}
		return '{"rows":[${rows.join(',')}],"applied":${json_bool(apply)}}'
	}

	mut pairs := []map[string]string{}
	if raw_items := b['items'] {
		if raw_items is []json2.Any {
			for it in raw_items {
				if it is map[string]json2.Any {
					p := map_str(it, 'path', '')
					nn := map_str(it, 'newName', '')
					if p != '' && nn != '' {
						pairs << {
							'path':    p
							'newName': nn
						}
					}
				}
			}
		}
	}
	if pairs.len == 0 {
		return error('EMPTY_BATCH: No items provided for bulk rename.')
	}
	mut renamed := []string{}
	for pair in pairs {
		src := resolve_existing(ctx, pair['path'], false)!
		check_not_protected(ctx, src, 'rename')!
		clean_name := valid_name(pair['newName'])!
		dst := os.join_path(os.dir(src), clean_name)
		if dst != src {
			os.mv(src, dst)!
		}
		renamed << '{"oldPath":${json_str(src)},"newPath":${json_str(dst)}}'
	}
	return '{"renamed":[${renamed.join(',')}]}'
}

// handle_duplicate_items creates sibling copies (`name copy`) of one or more selected paths.
pub fn handle_duplicate_items(ctx &FmContext, b map[string]json2.Any) !string {
	paths := map_str_array(b, 'paths')
	if paths.len == 0 {
		return error('EMPTY_SELECTION: Select at least one item to duplicate.')
	}
	mut created := []FmEntry{}
	for raw in paths {
		src := resolve_existing(ctx, raw, false)!
		is_dir := os.is_dir(src) && !os.is_link(src)
		dst := unique_sibling(os.dir(src), os.base(src), is_dir, 'copy')!
		copy_entry_recursive(src, dst)!
		if entry := build_entry(dst, os.base(dst)) {
			created << entry
		}
	}
	return '{"entries":${entries_to_json(created)}}'
}

// handle_copy_or_move_sync synchronously copies or moves items into a destination directory with conflict handling.
pub fn handle_copy_or_move_sync(ctx &FmContext, b map[string]json2.Any, mode string) !string {
	sources := map_str_array(b, 'sources')
	dest_raw := map_str(b, 'dest', map_str(b, 'destination', ''))
	policy := map_str(b, 'policy', map_str(b, 'conflictPolicy', 'rename'))
	if sources.len == 0 {
		return error('EMPTY_SELECTION: No source items specified.')
	}
	dest_dir := resolve_existing(ctx, dest_raw, true)!
	if !os.is_dir(dest_dir) {
		return error('NOT_A_DIRECTORY: Destination is not a directory.')
	}
	mut results := []FmEntry{}
	mut outcomes := []string{}
	mut skipped := []string{}
	for raw_src in sources {
		src := resolve_existing(ctx, raw_src, false)!
		if mode == 'move' {
			check_not_protected(ctx, src, 'move')!
		}
		is_dir := os.is_dir(src) && !os.is_link(src)
		base := os.base(src)
		mut target := os.join_path(dest_dir, base)
		if is_dir && is_subpath(dest_dir, src) {
			return error('SELF_SUBFOLDER: Cannot ${mode} folder "${base}" into itself.')
		}
		if src == target {
			if mode == 'copy' {
				target = unique_sibling(dest_dir, base, is_dir, 'copy')!
			} else {
				skipped << src
				outcomes << '{"ok":true,"value":{"source":${json_str(src)},"destination":null,"status":"skipped"}}'
				continue
			}
		} else if os.exists(target) || os.is_link(target) {
			if policy == 'skip' {
				skipped << src
				outcomes << '{"ok":true,"value":{"source":${json_str(src)},"destination":null,"status":"skipped"}}'
				continue
			} else if policy == 'overwrite' || policy == 'replace' {
				check_not_protected(ctx, target, 'overwrite')!
				remove_entry_safe(target)!
			} else {
				target = unique_sibling(dest_dir, base, is_dir, '')!
			}
		}
		if mode == 'copy' {
			copy_entry_recursive(src, target)!
		} else {
			move_entry_safe(src, target)!
		}
		outcomes << '{"ok":true,"value":{"source":${json_str(src)},"destination":${json_str(target)},"status":"done"}}'
		if entry := build_entry(target, os.base(target)) {
			results << entry
		}
	}
	return '{"results":[${outcomes.join(',')}],"entries":${entries_to_json(results)},"skipped":${json_str_array(skipped)}}'
}

// handle_create_symlink creates a symbolic link pointing to a target path.
pub fn handle_create_symlink(ctx &FmContext, b map[string]json2.Any) !string {
	target_raw := map_str(b, 'targetPath', '')
	link_dir := map_str(b, 'linkDir', '')
	link_name := map_str(b, 'linkName', '')
	src := resolve_existing(ctx, target_raw, false)!
	desired := if link_name.trim_space() != '' {
		link_name.trim_space()
	} else {
		'${os.base(src)} alias'
	}
	dest := resolve_new_target(ctx, link_dir, desired)!
	final_path := if os.exists(dest) || os.is_link(dest) {
		unique_sibling(os.dir(dest), os.base(dest), false, '')!
	} else {
		dest
	}
	os.symlink(src, final_path)!
	entry := build_entry(final_path, os.base(final_path)) or {
		return error('NOT_FOUND: Created symlink could not be read.')
	}
	return '{"entry":${entry_to_json(entry)}}'
}

// open_url_or_path_in_os opens a file path or URL using the operating system's default handler (`open`, `xdg-open`, `start`).
pub fn open_url_or_path_in_os(target string) {
	if target.trim_space() == '' || target.starts_with('-') {
		return
	}
	$if macos {
		spawn fn [target] () {
			os.execute('open -- ${os.quoted_path(target)}')
		}()
	} $else $if linux {
		spawn fn [target] () {
			os.execute('xdg-open -- ${os.quoted_path(target)}')
		}()
	} $else $if windows {
		spawn fn [target] () {
			os.execute('cmd /c start "" ${os.quoted_path(target)}')
		}()
	}
}

// handle_open_item opens the requested file or folder in the OS default application.
pub fn handle_open_item(ctx &FmContext, b map[string]json2.Any) !string {
	raw_path := map_str(b, 'path', '')
	resolved := resolve_existing(ctx, raw_path, false)!
	open_url_or_path_in_os(resolved)
	return '{"opened":${json_str(resolved)},"program":false}'
}

// handle_reveal_item reveals and selects the requested path in the native OS file manager (Finder/Explorer).
pub fn handle_reveal_item(ctx &FmContext, b map[string]json2.Any) !string {
	raw_path := map_str(b, 'path', '')
	resolved := resolve_existing(ctx, raw_path, false)!
	$if macos {
		spawn fn [resolved] () {
			os.execute('open -R -- ${os.quoted_path(resolved)}')
		}()
	} $else $if linux {
		dir := if os.is_dir(resolved) { resolved } else { os.dir(resolved) }
		open_url_or_path_in_os(dir)
	} $else $if windows {
		spawn fn [resolved] () {
			os.execute('explorer.exe /select,${os.quoted_path(resolved)}')
		}()
	}
	return '{"revealed":${json_str(resolved)},"selected":true,"with":"Finder"}'
}

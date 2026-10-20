module filemanager

import json2
import os
import time

fn trash_files_dir(ctx &FmContext) string {
	return os.join_path(ctx.trash_dir, 'files')
}

// read_trash_index loads the list of trashed items from the File Manager trash `index.json`.
pub fn read_trash_index(ctx &FmContext) []FmTrashEntry {
	raw := os.read_file(ctx.trash_index) or { return []FmTrashEntry{} }
	parsed := json2.decode[json2.Any](raw) or { return []FmTrashEntry{} }
	if parsed is []json2.Any {
		mut out := []FmTrashEntry{}
		for item in parsed {
			if item is map[string]json2.Any {
				id := map_str(item, 'id', '')
				name := map_str(item, 'name', '')
				orig := map_str(item, 'originalPath', '')
				stored := map_str(item, 'storedName', '')
				if id != '' && name != '' && orig != '' && stored != '' {
					out << FmTrashEntry{
						id:            id
						name:          name
						original_path: orig
						stored_name:   stored
						deleted_at:    map_str(item, 'deletedAt', '')
						is_dir:        map_bool(item, 'isDir', false)
						size:          map_i64(item, 'size', 0)
					}
				}
			}
		}
		return out
	}
	return []FmTrashEntry{}
}

// trash_entry_to_json serializes a single `FmTrashEntry` to a JSON object string.
pub fn trash_entry_to_json(e FmTrashEntry) string {
	return '{"id":${json_str(e.id)},"name":${json_str(e.name)},"originalPath":${json_str(e.original_path)},"storedName":${json_str(e.stored_name)},"deletedAt":${json_str(e.deleted_at)},"isDir":${json_bool(e.is_dir)},"size":${e.size}}'
}

// trash_entries_to_json serializes a slice of `FmTrashEntry` items to a JSON array string.
pub fn trash_entries_to_json(entries []FmTrashEntry) string {
	mut parts := []string{cap: entries.len}
	for e in entries {
		parts << trash_entry_to_json(e)
	}
	return '[${parts.join(',')}]'
}

// write_trash_index atomically writes the updated trash index entries to `index.json`.
pub fn write_trash_index(ctx &FmContext, entries []FmTrashEntry) {
	os.mkdir_all(trash_files_dir(ctx)) or {}
	tmp := '${ctx.trash_index}.tmp-${random_hex(4)}'
	content := trash_entries_to_json(entries)
	os.write_file(tmp, content) or { return }
	os.mv(tmp, ctx.trash_index) or {
		os.write_file(ctx.trash_index, content) or {}
		os.rm(tmp) or {}
	}
}

// handle_trash_items moves the specified files or directories into the managed trash directory.
pub fn handle_trash_items(ctx &FmContext, b map[string]json2.Any) !string {
	paths := map_str_array(b, 'paths')
	if paths.len == 0 {
		return error('EMPTY_SELECTION: Select at least one item to move to Trash.')
	}
	os.mkdir_all(trash_files_dir(ctx))!
	mut index := read_trash_index(ctx)
	mut trashed := []FmTrashEntry{}
	mut outcomes := []string{}

	for raw in paths {
		src := resolve_existing(ctx, raw, false)!
		check_not_protected(ctx, src, 'trash')!
		if is_subpath(src, ctx.trash_dir) {
			return error('ALREADY_IN_TRASH: Item is already inside the Recycle Bin.')
		}
		is_dir := os.is_dir(src) && !os.is_link(src)
		st := os.lstat(src) or { os.stat(src)! }
		id := '${time.now().unix_milli()}_${random_hex(5)}'
		base_name := os.base(src)
		stored_name := '${id}__${base_name}'
		stored_path := os.join_path(trash_files_dir(ctx), stored_name)

		move_entry_safe(src, stored_path)!
		entry := FmTrashEntry{
			id:            id
			name:          base_name
			original_path: src
			stored_name:   stored_name
			deleted_at:    time.now().format_rfc3339()
			is_dir:        is_dir
			size:          if is_dir { i64(0) } else { i64(st.size) }
		}
		index.prepend(entry)
		trashed << entry
		outcomes << '{"ok":true,"value":{"path":${json_str(src)},"id":${json_str(id)},"name":${json_str(base_name)}}}'
	}
	write_trash_index(ctx, index)
	return '{"results":[${outcomes.join(',')}],"trashed":${trash_entries_to_json(trashed)},"trashCount":${index.len}}'
}

// handle_list_trash returns the JSON list of all items currently in the File Manager trash.
pub fn handle_list_trash(ctx &FmContext) !string {
	index := read_trash_index(ctx)
	mut valid := []FmTrashEntry{}
	mut dirty := false
	for item in index {
		stored := os.join_path(trash_files_dir(ctx), item.stored_name)
		if os.exists(stored) || os.is_link(stored) {
			valid << item
		} else {
			dirty = true
		}
	}
	if dirty {
		write_trash_index(ctx, valid)
	}
	return '{"items":${trash_entries_to_json(valid)},"count":${valid.len},"totalCount":${valid.len}}'
}

// handle_restore_trash restores selected trash items back to their original paths (or a non-colliding sibling).
pub fn handle_restore_trash(ctx &FmContext, b map[string]json2.Any) !string {
	ids := map_str_array(b, 'ids')
	if ids.len == 0 {
		return error('EMPTY_SELECTION: Select at least one item to restore.')
	}
	mut index := read_trash_index(ctx)
	mut id_set := map[string]bool{}
	for id in ids {
		id_set[id] = true
	}
	mut remaining := []FmTrashEntry{}
	mut restored := []string{}
	mut outcomes := []string{}

	for item in index {
		if !id_set[item.id] {
			remaining << item
			continue
		}
		stored := os.join_path(trash_files_dir(ctx), item.stored_name)
		if !os.exists(stored) && !os.is_link(stored) {
			continue
		}
		mut orig_dir := os.dir(item.original_path)
		if !inside_roots(ctx, orig_dir) {
			orig_dir = if ctx.roots.len > 0 { ctx.roots[0] } else { ctx.home }
		}
		os.mkdir_all(orig_dir) or {}
		mut target := os.join_path(orig_dir, item.name)
		if os.exists(target) || os.is_link(target) {
			target = unique_sibling(orig_dir, item.name, item.is_dir, 'restored')!
		}
		move_entry_safe(stored, target)!
		restored << '{"id":${json_str(item.id)},"restoredPath":${json_str(target)}}'
		outcomes << '{"ok":true,"value":{"id":${json_str(item.id)},"restoredTo":${json_str(target)}}}'
	}
	write_trash_index(ctx, remaining)
	return '{"results":[${outcomes.join(',')}],"restored":[${restored.join(',')}],"trashCount":${remaining.len}}'
}

// handle_empty_trash permanently deletes all (or selected) items from the managed trash directory.
pub fn handle_empty_trash(ctx &FmContext, b map[string]json2.Any) !string {
	ids := map_str_array(b, 'ids')
	mut index := read_trash_index(ctx)
	mut filter_set := map[string]bool{}
	has_filter := ids.len > 0
	for id in ids {
		filter_set[id] = true
	}
	mut remaining := []FmTrashEntry{}
	mut deleted_count := 0

	for item in index {
		if has_filter && !filter_set[item.id] {
			remaining << item
			continue
		}
		stored := os.join_path(trash_files_dir(ctx), item.stored_name)
		remove_entry_safe(stored) or {}
		deleted_count++
	}
	write_trash_index(ctx, remaining)
	return '{"deleted":${deleted_count},"deletedCount":${deleted_count},"trashCount":${remaining.len}}'
}

// handle_delete_permanent permanently deletes the specified paths from disk without moving them to trash.
pub fn handle_delete_permanent(ctx &FmContext, b map[string]json2.Any) !string {
	paths := map_str_array(b, 'paths')
	if paths.len == 0 {
		return error('EMPTY_SELECTION: Select at least one item to permanently delete.')
	}
	mut deleted := []string{}
	mut outcomes := []string{}
	for raw in paths {
		target := resolve_existing(ctx, raw, false)!
		check_not_protected(ctx, target, 'permanently delete')!
		remove_entry_safe(target)!
		deleted << target
		outcomes << '{"ok":true,"value":{"path":${json_str(target)}}}'
	}
	return '{"results":[${outcomes.join(',')}],"deleted":${json_str_array(deleted)}}'
}

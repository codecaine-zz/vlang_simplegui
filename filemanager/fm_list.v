module filemanager

import json2
import os
import time

$if macos || linux {
	#include <sys/statvfs.h>
}

struct C.statvfs {
	f_bsize  u64
	f_frsize u64
	f_blocks u64
	f_bfree  u64
	f_bavail u64
}

fn C.statvfs(&char, &C.statvfs) int

// FmEntry represents a single file, folder, or symlink entry returned when listing a directory.
pub struct FmEntry {
pub mut:
	name           string
	path           string
	is_dir         bool
	is_symlink     bool
	broken         bool
	symlink_target string
	size           i64
	mtime_ms       i64
	ctime_ms       i64
	mode           u32
	ext            string
	kind           string
	icon           string
	label          string
	hidden         bool
	program        bool
	preview        string // 'image', 'text', or ''
	readable       bool
	writable       bool
	folder         string
}

fn entry_meta_for(name string, ext string, kind string, is_dir bool, is_link bool, broken bool, has_exec bool) (string, string, bool, string) {
	if is_dir {
		if name.to_lower().ends_with('.app') {
			return '⚙️', 'Application', true, ''
		}
		return '📁', 'Folder', false, ''
	}
	mut icon := '📃'
	mut noun := if ext != '' { '${ext.to_upper()} file' } else { 'File' }
	mut prog := has_exec
	mut prev := ''
	match kind {
		'image' {
			icon = '🖼️'
			noun = if ext != '' { '${ext.to_upper()} image' } else { 'image' }
			prev = 'image'
		}
		'video' {
			icon = '🎞️'
			noun = if ext != '' { '${ext.to_upper()} video' } else { 'video' }
		}
		'audio' {
			icon = '🎵'
			noun = 'audio file'
		}
		'pdf' {
			icon = '📕'
			noun = 'PDF document'
		}
		'document' {
			icon = '📄'
			if ext in ['xls', 'xlsx', 'xlsm', 'ods', 'csv', 'tsv', 'numbers'] {
				icon = '📊'
				noun = 'spreadsheet'
			} else if ext in ['ppt', 'pptx', 'ppsx', 'odp', 'key'] {
				icon = '📽️'
				noun = 'presentation'
			} else if ext in ['txt', 'md', 'markdown', 'log', 'ini', 'cfg', 'conf', 'env', 'gitignore',
				'rst', 'tex', 'nfo'] {
				icon = '📝'
				noun = if ext != '' { '${ext.to_upper()} text file' } else { 'text file' }
				prev = 'text'
			} else {
				noun = 'document'
			}
		}
		'archive' {
			icon = '🗜️'
			noun = 'archive'
		}
		'code' {
			icon = '💻'
			noun = match ext {
				'v', 'vsh', 'vv' { 'V source file' }
				'zig' { 'Zig source file' }
				'rs' { 'RS source file' }
				'ts', 'tsx' { '${ext.to_upper()} source file' }
				'js', 'mjs', 'cjs', 'jsx' { '${ext.to_upper()} source file' }
				'py' { 'PY source file' }
				'go' { 'GO source file' }
				else {
					if ext != '' { '${ext.to_upper()} source file' } else { 'source file' }
				}
			}
			prev = 'text'
		}
		'data' {
			icon = '💻'
			noun = if ext != '' { '${ext.to_upper()} source file' } else { 'data file' }
			prev = 'text'
		}
		'database' {
			icon = '🗄️'
			noun = 'SQLite database'
		}
		'executable' {
			icon = '⚙️'
			noun = 'program'
			prog = true
		}
		'font' {
			icon = '🔤'
			noun = 'font'
		}
		else {}
	}
	if broken {
		icon = '⛓️‍💥'
		noun = 'Broken link'
	} else if is_link && !is_dir {
		icon = '🔗'
		noun = 'Link to ${noun.to_lower()}'
	}
	return icon, noun, prog, prev
}

// entry_to_json serializes a single `FmEntry` to a JSON object string.
pub fn entry_to_json(e FmEntry) string {
	target_str := if e.symlink_target != '' { json_str(e.symlink_target) } else { 'null' }
	prev_str := if e.preview != '' { json_str(e.preview) } else { 'null' }
	mode_str := if e.is_symlink { 'null' } else { '${e.mode & 0o7777}' }
	folder_part := if e.folder != '' { ',"folder":${json_str(e.folder)}' } else { '' }
	return '{"name":${json_str(e.name)},"path":${json_str(e.path)},"isDir":${json_bool(e.is_dir)},"isSymlink":${json_bool(e.is_symlink)},"broken":${json_bool(e.broken)},"symlinkTarget":${target_str},"size":${e.size},"mtimeMs":${e.mtime_ms},"ctimeMs":${e.ctime_ms},"mode":${mode_str},"ext":${json_str(e.ext)},"kind":${json_str(e.kind)},"icon":${json_str(e.icon)},"label":${json_str(e.label)},"hidden":${json_bool(e.hidden)},"program":${json_bool(e.program)},"preview":${prev_str},"readOnly":${json_bool(!e.writable)},"readable":${json_bool(e.readable)},"writable":${json_bool(e.writable)}${folder_part}}'
}

// entries_to_json serializes a slice of `FmEntry` items to a JSON array string.
pub fn entries_to_json(entries []FmEntry) string {
	mut parts := []string{cap: entries.len}
	for e in entries {
		parts << entry_to_json(e)
	}
	return '[${parts.join(',')}]'
}

// build_entry stats `full_path` and constructs an `FmEntry` with size, timestamps, permissions, and kind classification.
pub fn build_entry(full_path string, name string) ?FmEntry {
	is_link := os.is_link(full_path)
	mut is_dir := os.is_dir(full_path)
	mut broken := false
	mut symlink_target := ''
	if is_link {
		if link_dst := os.readlink(full_path) {
			symlink_target = link_dst
		}
		if st_target := os.stat(full_path) {
			is_dir = st_target.get_filetype() == .directory
		} else {
			broken = true
		}
	}
	st := os.lstat(full_path) or { os.stat(full_path) or { return none } }
	size := if is_dir { i64(0) } else { i64(st.size) }
	mtime_ms := st.mtime * 1000
	ctime_ms := st.ctime * 1000
	mode := u32(st.get_mode().bitmask())
	ext := ext_of(name, is_dir)
	kind := classify_kind(name, is_dir, is_link)
	has_exec := !is_dir && (mode & 0o111) != 0
	icon, label, prog, prev := entry_meta_for(name, ext, kind, is_dir, is_link, broken,
		has_exec)
	hidden := is_hidden_name(name)
	readable := os.is_readable(full_path)
	writable := os.is_writable(full_path)

	return FmEntry{
		name:           name
		path:           full_path
		is_dir:         is_dir
		is_symlink:     is_link
		broken:         broken
		symlink_target: symlink_target
		size:           size
		mtime_ms:       mtime_ms
		ctime_ms:       ctime_ms
		mode:           mode
		ext:            ext
		kind:           kind
		icon:           icon
		label:          label
		hidden:         hidden
		program:        prog
		preview:        prev
		readable:       readable
		writable:       writable
	}
}

// CrumbItem represents a single clickable path segment in a directory breadcrumb trail.
pub struct CrumbItem {
pub:
	name string
	path string
}

// breadcrumbs_for builds the breadcrumb trail from the matching root directory down to `p`.
pub fn breadcrumbs_for(ctx &FmContext, p string) []CrumbItem {
	real := os.real_path(p)
	if ctx.roots.len > 0 {
		for r in ctx.roots {
			if is_subpath(real, r) {
				mut crumbs := [
					CrumbItem{
						name: if os.base(r) != '' { os.base(r) } else { r }
						path: r
					},
				]
				rel := real[r.len..].trim('/')
				if rel != '' {
					mut acc := r
					for seg in rel.split('/') {
						if seg != '' {
							acc = os.join_path(acc, seg)
							crumbs << CrumbItem{
								name: seg
								path: acc
							}
						}
					}
				}
				return crumbs
			}
		}
	}
	mut crumbs := [CrumbItem{
		name: '/'
		path: '/'
	}]
	trimmed := real.trim('/')
	if trimmed != '' {
		mut acc := ''
		for seg in trimmed.split('/') {
			if seg != '' {
				acc = '${acc}/${seg}'
				crumbs << CrumbItem{
					name: seg
					path: acc
				}
			}
		}
	}
	return crumbs
}

// crumbs_to_json serializes a slice of `CrumbItem` structs to a JSON array string.
pub fn crumbs_to_json(crumbs []CrumbItem) string {
	mut parts := []string{cap: crumbs.len}
	for c in crumbs {
		parts << '{"name":${json_str(c.name)},"path":${json_str(c.path)}}'
	}
	return '[${parts.join(',')}]'
}

// handle_list_directory lists, filters, and sorts the entries of a requested directory and returns a JSON payload.
pub fn handle_list_directory(ctx &FmContext, b map[string]json2.Any) !string {
	raw_path := map_str(b, 'path', ctx.initial_path)
	dir_path := resolve_existing(ctx, if raw_path != '' { raw_path } else { ctx.initial_path },
		true)!
	if !os.is_dir(dir_path) {
		return error('NOT_A_DIRECTORY: Path is not a directory: ${dir_path}')
	}
	show_hidden := map_bool(b, 'showHidden', false)
	sort_by := map_str(b, 'sortBy', 'name')
	sort_dir := map_str(b, 'sortDir', 'asc')
	folders_first := map_bool(b, 'foldersFirst', true)
	filter := map_str(b, 'filter', '').trim_space().to_lower()

	names := os.ls(dir_path) or {
		return error('PERMISSION_DENIED: Cannot read directory: ${dir_path}')
	}

	mut items := []FmEntry{}
	mut hidden_count := 0
	mut total_bytes := i64(0)
	mut dir_count := 0
	mut file_count := 0

	for name in names {
		is_hid := is_hidden_name(name)
		if is_hid && !show_hidden {
			hidden_count++
			continue
		}
		if filter != '' && !name.to_lower().contains(filter) {
			continue
		}
		full := os.join_path(dir_path, name)
		if entry := build_entry(full, name) {
			if entry.is_dir {
				dir_count++
			} else {
				file_count++
				total_bytes += entry.size
			}
			items << entry
		}
	}

	mult := if sort_dir == 'desc' { -1 } else { 1 }
	items.sort_with_compare(fn [folders_first, sort_by, mult] (a &FmEntry, b &FmEntry) int {
		if folders_first && a.is_dir != b.is_dir {
			return if a.is_dir { -1 } else { 1 }
		}
		cmp := match sort_by {
			'size' {
				if a.size < b.size {
					-1
				} else if a.size > b.size {
					1
				} else {
					a.name.to_lower().compare(b.name.to_lower())
				}
			}
			'mtime' {
				if a.mtime_ms < b.mtime_ms {
					-1
				} else if a.mtime_ms > b.mtime_ms {
					1
				} else {
					a.name.to_lower().compare(b.name.to_lower())
				}
			}
			'kind', 'ext' {
				k := a.kind.compare(b.kind)
				if k != 0 {
					k
				} else {
					e := a.ext.compare(b.ext)
					if e != 0 {
						e
					} else {
						a.name.to_lower().compare(b.name.to_lower())
					}
				}
			}
			else {
				a.name.to_lower().compare(b.name.to_lower())
			}
		}
		return cmp * mult
	})

	parent := parent_or_null(ctx, dir_path)
	parent_json := if parent != '' { json_str(parent) } else { 'null' }
	crumbs := breadcrumbs_for(ctx, dir_path)
	writable := os.is_writable(dir_path)

	return '{"path":${json_str(dir_path)},"parent":${parent_json},"breadcrumbs":${crumbs_to_json(crumbs)},"entries":${entries_to_json(items)},"total":${items.len},"truncated":false,"totalCount":${items.len},"dirCount":${dir_count},"fileCount":${file_count},"hiddenCount":${hidden_count},"totalBytes":${total_bytes},"writable":${json_bool(writable)}}'
}

// handle_stat returns the JSON metadata for a single file or directory path.
pub fn handle_stat(ctx &FmContext, b map[string]json2.Any) !string {
	raw_path := map_str(b, 'path', '')
	resolved := resolve_existing(ctx, raw_path, false)!
	name := if os.base(resolved) != '' { os.base(resolved) } else { resolved }
	entry := build_entry(resolved, name) or { return error('NOT_FOUND: Cannot stat ${raw_path}') }
	return '{"entry":${entry_to_json(entry)}}'
}

// handle_breadcrumbs returns the JSON breadcrumb trail for a given directory path.
pub fn handle_breadcrumbs(ctx &FmContext, b map[string]json2.Any) !string {
	raw_path := map_str(b, 'path', ctx.initial_path)
	resolved := resolve_existing(ctx, if raw_path != '' { raw_path } else { ctx.initial_path },
		true)!
	crumbs := breadcrumbs_for(ctx, resolved)
	return '{"path":${json_str(resolved)},"breadcrumbs":${crumbs_to_json(crumbs)}}'
}

// handle_siblings returns the sibling directories of a given path for quick tree/breadcrumb navigation.
pub fn handle_siblings(ctx &FmContext, b map[string]json2.Any) !string {
	raw_path := map_str(b, 'path', '')
	target := resolve_existing(ctx, raw_path, true)!
	show_hidden := map_bool(b, 'showHidden', false)
	names := os.ls(target) or { return '{"folders":[]}' }
	mut folders := []string{}
	for name in names {
		if !show_hidden && is_hidden_name(name) {
			continue
		}
		full := os.join_path(target, name)
		if os.is_dir(full) && inside_roots(ctx, full) {
			folders << '{"name":${json_str(name)},"path":${json_str(full)}}'
			if folders.len >= 200 {
				break
			}
		}
	}
	folders.sort()
	return '{"folders":[${folders.join(',')}]}'
}

struct DiskUsageInfo {
	total_bytes i64
	free_bytes  i64
	used_bytes  i64
}

fn stat_disk_usage(p string) ?DiskUsageInfo {
	$if macos || linux {
		mut vfs := C.statvfs{}
		if C.statvfs(&char(p.str), &vfs) == 0 {
			frsize := if vfs.f_frsize > 0 { i64(vfs.f_frsize) } else { i64(vfs.f_bsize) }
			total_b := i64(vfs.f_blocks) * frsize
			free_b := i64(vfs.f_bavail) * frsize
			if total_b > 0 {
				used_b := if total_b >= free_b { total_b - free_b } else { i64(0) }
				return DiskUsageInfo{
					total_bytes: total_b
					free_bytes:  free_b
					used_bytes:  used_b
				}
			}
		}
	}
	res := os.execute('df -k ${os.quoted_path(p)} 2>/dev/null')
	if res.exit_code != 0 {
		return none
	}
	lines := res.output.trim_space().split_into_lines()
	if lines.len < 2 {
		return none
	}
	last := lines[lines.len - 1]
	fields := last.fields()
	if fields.len < 4 {
		return none
	}
	total_kb := fields[1].i64()
	used_kb := fields[2].i64()
	avail_kb := fields[3].i64()
	if total_kb <= 0 {
		return none
	}
	total_b := total_kb * 1024
	free_b := avail_kb * 1024
	used_b := if used_kb > 0 { used_kb * 1024 } else { total_b - free_b }
	return DiskUsageInfo{
		total_bytes: total_b
		free_bytes:  free_b
		used_bytes:  used_b
	}
}

// handle_drives enumerates mounted volumes/drives and their capacity statistics as JSON.
pub fn handle_drives(ctx &FmContext) !string {
	mut drives := []string{}
	mut seen := map[string]bool{}

	add_drive := fn [ctx, mut drives, mut seen] (name string, raw_path string, kind string) {
		if !os.exists(raw_path) || !os.is_dir(raw_path) {
			return
		}
		real := os.real_path(raw_path)
		if seen[real] || !inside_roots(ctx, real) {
			return
		}
		seen[real] = true
		if du := stat_disk_usage(real) {
			drives << '{"name":${json_str(name)},"path":${json_str(real)},"kind":${json_str(kind)},"totalBytes":${du.total_bytes},"freeBytes":${du.free_bytes},"usedBytes":${du.used_bytes}}'
		} else {
			drives << '{"name":${json_str(name)},"path":${json_str(real)},"kind":${json_str(kind)}}'
		}
	}

	add_drive('Home', ctx.home, 'home')
	for cand in [
		['Desktop', 'Desktop', 'Pinned'],
		['Documents', 'Documents', 'Pinned'],
		['Downloads', 'Downloads', 'Pinned'],
		['Pictures', 'Pictures', 'Media'],
		['Music', 'Music', 'Media'],
		['Movies', 'Movies', 'Media'],
		['Videos', 'Videos', 'Media'],
	] {
		add_drive(cand[0], os.join_path(ctx.home, cand[1]), cand[2])
	}

	if ctx.roots.len == 0 {
		$if macos {
			add_drive('Macintosh HD', '/', 'System')
			if vols := os.ls('/Volumes') {
				for v in vols {
					if !v.starts_with('.') {
						add_drive(v, os.join_path('/Volumes', v), 'Removable')
					}
				}
			}
		} $else $if linux {
			add_drive('Root (/)', '/', 'System')
			for mount_root in ['/media', '/mnt', '/run/media'] {
				if entries := os.ls(mount_root) {
					for e in entries {
						if !e.starts_with('.') {
							add_drive(e, os.join_path(mount_root, e), 'Removable')
						}
					}
				}
			}
		}
	} else {
		for i, r in ctx.roots {
			label := if os.base(r) != '' { os.base(r) } else { 'Root ${i + 1}' }
			add_drive(label, r, 'Workspace')
		}
	}

	return '{"drives":[${drives.join(',')}]}'
}

// handle_home_overview returns the user's home directory overview, quick places, and drive summary as JSON.
pub fn handle_home_overview(ctx &FmContext) !string {
	primary := if ctx.roots.len > 0 { ctx.roots[0] } else { ctx.home }
	hostname := os.hostname() or { 'localhost' }
	username := os.loginname() or { os.getenv('USER') }
	os_label := $if macos {
		'macOS'
	} $else $if linux {
		'Linux'
	} $else $if windows {
		'Windows'
	} $else {
		'POSIX'
	}
	arch_label := $if arm64 {
		'arm64'
	} $else $if amd64 {
		'x64'
	} $else {
		'native'
	}

	mut quick_folders := []string{}
	quick_specs := [
		['Home', '', 'home'],
		['Desktop', 'Desktop', 'desktop'],
		['Documents', 'Documents', 'documents'],
		['Downloads', 'Downloads', 'downloads'],
		['Pictures', 'Pictures', 'pictures'],
		['Music', 'Music', 'music'],
		['Movies', 'Movies', 'videos'],
		['Videos', 'Videos', 'videos'],
	]
	for spec in quick_specs {
		target := if spec[1] == '' { primary } else { os.join_path(primary, spec[1]) }
		if os.exists(target) && os.is_dir(target) && inside_roots(ctx, target) {
			items := os.ls(target) or { []string{} }
			mut visible := 0
			for n in items {
				if !is_hidden_name(n) {
					visible++
				}
			}
			quick_folders << '{"name":${json_str(spec[0])},"path":${json_str(target)},"icon":${json_str(spec[2])},"itemCount":${visible}}'
		}
	}

	mut recent_candidates := []FmEntry{}
	mut scan_dirs := [primary]
	for sub in ['Desktop', 'Documents', 'Downloads'] {
		p := os.join_path(primary, sub)
		if os.is_dir(p) && inside_roots(ctx, p) {
			scan_dirs << p
		}
	}
	mut seen_files := map[string]bool{}
	for d in scan_dirs {
		names := os.ls(d) or { continue }
		for n in names {
			if is_hidden_name(n) {
				continue
			}
			full := os.join_path(d, n)
			if seen_files[full] {
				continue
			}
			if entry := build_entry(full, n) {
				if !entry.is_dir {
					seen_files[full] = true
					recent_candidates << entry
				}
			}
		}
	}
	recent_candidates.sort(a.mtime_ms > b.mtime_ms)
	if recent_candidates.len > 12 {
		recent_candidates = recent_candidates[..12]
	}

	drives_resp := handle_drives(ctx)!
	// Extract inner array from `{"drives":[...]}`
	drives_arr := if drives_resp.starts_with('{"drives":') && drives_resp.ends_with('}') {
		drives_resp['{"drives":'.len..drives_resp.len - 1]
	} else {
		'[]'
	}

	return '{"user":{"username":${json_str(username)},"hostname":${json_str(hostname)},"home":${json_str(primary)},"platform":${json_str(os_label)},"arch":${json_str(arch_label)}},"quickFolders":[${quick_folders.join(',')}],"drives":${drives_arr},"recentFiles":${entries_to_json(recent_candidates)}}'
}

// handle_folder_size recursively computes the total byte size and item counts of a folder.
pub fn handle_folder_size(ctx &FmContext, b map[string]json2.Any) !string {
	raw_path := map_str(b, 'path', '')
	target := resolve_existing(ctx, raw_path, true)!
	max_items := if map_int(b, 'maxItems', 25000) > 0 {
		map_int(b, 'maxItems', 25000)
	} else {
		25000
	}
	max_ms := if map_int(b, 'maxMs', 2500) > 0 { map_int(b, 'maxMs', 2500) } else { 2500 }

	mut bytes := i64(0)
	mut files := 0
	mut dirs := 0
	mut truncated := false
	deadline := time.now().unix_milli() + max_ms

	mut stack := [target]
	for stack.len > 0 {
		if files + dirs >= max_items || time.now().unix_milli() > deadline {
			truncated = true
			break
		}
		cur := stack.pop()
		names := os.ls(cur) or { continue }
		for n in names {
			if files + dirs >= max_items {
				truncated = true
				break
			}
			full := os.join_path(cur, n)
			if os.is_link(full) {
				files++
				continue
			}
			if os.is_dir(full) {
				dirs++
				stack << full
			} else if st := os.stat(full) {
				files++
				bytes += i64(st.size)
			}
		}
	}
	return '{"path":${json_str(target)},"bytes":${bytes},"files":${files},"dirs":${dirs},"truncated":${json_bool(truncated)}}'
}

// handle_places returns bookmarked and standard user directories (Home, Desktop, Documents, Downloads, Trash).
pub fn handle_places(ctx &FmContext) !string {
	plat := $if macos {
		'darwin'
	} $else $if linux {
		'linux'
	} $else {
		'win32'
	}
	fm_name := $if macos {
		'Finder'
	} $else $if windows {
		'File Explorer'
	} $else {
		'your file manager'
	}
	mut places := []string{}
	places << '{"id":"home","name":"Home","path":${json_str(ctx.home)},"icon":"🏠"}'
	place_specs := [
		['desktop', 'Desktop', 'Desktop', '🖥️'],
		['documents', 'Documents', 'Documents', '📄'],
		['downloads', 'Downloads', 'Downloads', '⬇️'],
		['pictures', 'Pictures', 'Pictures', '🖼️'],
		['music', 'Music', 'Music', '🎵'],
		['videos', if plat == 'darwin' { 'Movies' } else { 'Videos' }, if plat == 'darwin' {
			'Movies'
		} else {
			'Videos'
		}, '🎞️'],
	]
	for spec in place_specs {
		full := os.join_path(ctx.home, spec[2])
		if os.is_dir(full) && inside_roots(ctx, full) {
			places << '{"id":${json_str(spec[0])},"name":${json_str(spec[1])},"path":${json_str(full)},"icon":${json_str(spec[3])}}'
		}
	}

	mut drives := []string{}
	root_path := if ctx.roots.len > 0 { ctx.roots[0] } else { '/' }
	if du := stat_disk_usage(root_path) {
		drives << '{"id":"drive-root","name":"Computer","path":${json_str(root_path)},"icon":"💻","freeBytes":${du.free_bytes},"totalBytes":${du.total_bytes}}'
	} else {
		drives << '{"id":"drive-root","name":"Computer","path":${json_str(root_path)},"icon":"💻"}'
	}
	$if macos {
		if ctx.roots.len == 0 {
			if vols := os.ls('/Volumes') {
				for v in vols {
					if v.starts_with('.') || v in ['Recovery', 'Preboot', 'VM', 'Update', 'xarts',
						'iSCPreboot', 'Hardware'] {
						continue
					}
					vpath := os.join_path('/Volumes', v)
					if os.is_link(vpath) && os.real_path(vpath) == '/' {
						continue
					}
					if os.is_dir(vpath) {
						if du := stat_disk_usage(vpath) {
							drives << '{"id":${json_str('drive-${vpath}')},"name":${json_str(v)},"path":${json_str(vpath)},"icon":"💾","freeBytes":${du.free_bytes},"totalBytes":${du.total_bytes}}'
						} else {
							drives << '{"id":${json_str('drive-${vpath}')},"name":${json_str(v)},"path":${json_str(vpath)},"icon":"💾"}'
						}
					}
				}
			}
		}
	}

	trash := read_trash_index(ctx)
	settings := load_settings_map(ctx)
	settings_json := json2.encode[map[string]json2.Any](settings)
	cli_utils := os.join_path(ctx.data_dir, 'cli_utils')
	os.mkdir_all(cli_utils) or {}
	cli_apps := os.join_path(os.getwd(), 'cli_apps')

	return '{"places":[${places.join(',')}],"drives":[${drives.join(',')}],"platform":${json_str(plat)},"fileManagerName":${json_str(fm_name)},"separator":${json_str(os.path_separator)},"home":${json_str(ctx.home)},"cliUtilsDir":${json_str(cli_utils)},"cliAppsDir":${json_str(cli_apps)},"trash":{"count":${trash.len}},"settings":${settings_json}}'
}

// handle_props returns detailed properties, permissions, and checksums for one or more selected paths.
pub fn handle_props(ctx &FmContext, b map[string]json2.Any) !string {
	raw_paths := map_str_array(b, 'paths')
	if raw_paths.len == 0 {
		return error('BAD_REQUEST: Nothing was selected.')
	}
	mut paths := []string{}
	for rp in raw_paths {
		paths << resolve_existing(ctx, rp, false)!
	}
	mut total_size := i64(0)
	mut total_files := 0
	mut total_folders := 0
	mut partial := false
	for p in paths {
		if os.is_dir(p) && !os.is_link(p) {
			mut stack := [p]
			mut seen := 0
			for stack.len > 0 {
				if seen > 50000 {
					partial = true
					break
				}
				cur := stack.pop()
				names := os.ls(cur) or { continue }
				for n in names {
					seen++
					full := os.join_path(cur, n)
					if os.is_link(full) {
						total_files++
					} else if os.is_dir(full) {
						total_folders++
						stack << full
					} else if st := os.lstat(full) {
						total_files++
						total_size += i64(st.size)
					}
				}
			}
		} else if st := os.lstat(p) {
			total_files++
			total_size += i64(st.size)
		}
	}
	first := paths[0]
	single := paths.len == 1
	entry := build_entry(first, os.base(first)) or {
		return error('NOT_FOUND: Item could not be inspected.')
	}
	name := if single { entry.name } else { '${paths.len} items' }
	path_json := if single { json_str(first) } else { 'null' }
	loc_json := json_str(os.dir(first))
	kind_label := if single {
		if entry.is_symlink { 'Link' } else { entry.label }
	} else {
		'Several items'
	}
	folders_val := if single && !entry.is_dir { 0 } else { total_folders }
	created_json := if single { '${entry.ctime_ms}' } else { 'null' }
	mod_json := if single { '${entry.mtime_ms}' } else { 'null' }
	perm_oct := if single { json_str('${(entry.mode & 0o777):03o}') } else { 'null' }
	link_json := if single && entry.symlink_target != '' {
		json_str(entry.symlink_target)
	} else {
		'null'
	}
	return '{"properties":{"count":${paths.len},"name":${json_str(name)},"path":${path_json},"location":${loc_json},"kind":${json_str(kind_label)},"isDir":${json_bool(single && entry.is_dir)},"size":${total_size},"files":${total_files},"folders":${folders_val},"partial":${json_bool(partial)},"createdMs":${created_json},"modifiedMs":${mod_json},"accessedMs":${mod_json},"permissions":${perm_oct},"readOnly":${json_bool(single && !entry.writable)},"linkTarget":${link_json},"hidden":${json_bool(single && entry.hidden)}}}'
}

// handle_search searches for files matching a query string or glob pattern under a root directory.
pub fn handle_search(ctx &FmContext, b map[string]json2.Any) !string {
	raw_root := map_str(b, 'path', ctx.initial_path)
	root := resolve_existing(ctx, raw_root, true)!
	query := map_str(b, 'query', '').trim_space().to_lower()
	if query == '' {
		return error('BAD_REQUEST: Type something to search for.')
	}
	show_hidden := map_bool(b, 'showHidden', false)
	kind_filter := map_str(b, 'kind', '')
	mut entries := []FmEntry{}
	mut truncated := false
	mut skipped := 0
	mut scanned := 0
	struct DirDepth {
		dir   string
		depth int
	}
	mut queue := [DirDepth{root, 0}]
	for queue.len > 0 {
		cur := queue[0]
		queue = queue[1..]
		names := os.ls(cur.dir) or {
			skipped++
			continue
		}
		for n in names {
			if !show_hidden && is_hidden_name(n) {
				continue
			}
			scanned++
			if entries.len >= 1000 || scanned > 30000 {
				truncated = true
				break
			}
			full := os.join_path(cur.dir, n)
			is_dir := os.is_dir(full) && !os.is_link(full)
			if is_dir && cur.depth < 12 {
				queue << DirDepth{full, cur.depth + 1}
			}
			if n.to_lower().contains(query) {
				if mut e := build_entry(full, n) {
					if kind_filter == '' || e.is_dir || e.kind == kind_filter {
						e.folder = cur.dir
						entries << e
					}
				}
			}
		}
		if truncated {
			break
		}
	}
	return '{"entries":${entries_to_json(entries)},"truncated":${json_bool(truncated)},"skipped":${skipped},"scanned":${scanned}}'
}

// handle_typedpath resolves and autocompletes a user-typed path string for the address bar.
pub fn handle_typedpath(ctx &FmContext, b map[string]json2.Any) !string {
	cwd := map_str(b, 'cwd', ctx.home)
	mut text := map_str(b, 'text', '').trim_space()
	if (text.starts_with('"') && text.ends_with('"'))
		|| (text.starts_with("'") && text.ends_with("'")) {
		text = text[1..text.len - 1].trim_space()
	}
	if text == '' {
		return error('BAD_PATH: Type a folder location, like ~/Documents.')
	}
	if text.starts_with('file://') {
		text = text['file://'.len..]
	}
	resolved := if text == '~' {
		ctx.home
	} else if text.starts_with('~/') || text.starts_with('~\\') {
		os.join_path(ctx.home, text[2..])
	} else if os.is_abs_path(text) {
		os.norm_path(text)
	} else {
		os.norm_path(os.join_path(cwd, text))
	}
	if !inside_roots(ctx, resolved) {
		return error('OUTSIDE_ROOTS: Path is outside allowed roots.')
	}
	ex := os.exists(resolved)
	is_dir := ex && os.is_dir(resolved)
	return '{"path":${json_str(resolved)},"exists":${json_bool(ex)},"isDir":${json_bool(is_dir)}}'
}

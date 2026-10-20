module filemanager

import crypto.rand
import json2
import math
import os
import sync
import time

// app_name is the display name of the Codecaine File Manager application.
pub const app_name = 'Codecaine File Manager'
// app_version is the current semantic version string of Codecaine File Manager.
pub const app_version = '1.3.0'

// FmError represents a structured File Manager error with a machine-readable `code` and `msg`.
pub struct FmError {
pub:
	code    string
	message string
	status  int = 400
}

// FmTrashEntry stores metadata for an item moved to the File Manager trash index.
pub struct FmTrashEntry {
pub mut:
	id            string
	name          string
	original_path string
	stored_name   string
	deleted_at    string
	is_dir        bool
	size          i64
}

// JobConflict describes a source/destination path collision encountered during a background transfer job.
pub struct JobConflict {
pub mut:
	kind        string
	source_path string
	target_path string
	name        string
}

// FmJob tracks the progress, byte counts, conflicts, and status of an asynchronous file copy or move job.
pub struct FmJob {
pub mut:
	id               string
	kind             string
	status           string // 'running' | 'paused_conflict' | 'done' | 'cancelled' | 'error'
	total_items      int
	done_items       int
	total_bytes      i64
	done_bytes       i64
	current_item     string
	error_msg        string
	conflict         ?JobConflict
	created_paths    []string
	cancel_requested bool
	resolution       string
	apply_to_all     bool
}

// FmContext holds the runtime configuration, allowed root directories, trash paths, and active jobs for a File Manager instance.
@[heap]
pub struct FmContext {
pub mut:
	home            string
	roots           []string
	trash_dir       string
	trash_index     string
	data_dir        string
	settings_file   string
	themes_file     string
	workspaces_file string
	actions_file    string
	window_file     string
	token           string
	initial_path    string
	initial_tool    string
	initial_game    string
	tool_dirs       []string
	jobs_mu         &sync.Mutex = sync.new_mutex()
	jobs            map[string]&FmJob
	state_mu        &sync.Mutex = sync.new_mutex()
	kv_store        map[string]string
}

// FmContextOptions configures initial roots, start path, data directory, and custom themes directory for `create_context`.
@[params]
pub struct FmContextOptions {
pub:
	home         string
	roots        []string
	data_dir     string
	initial_path string
	initial_tool string
	initial_game string
	tool_dirs    []string
}

// random_hex generates a cryptographically random hexadecimal string from `nbytes` bytes.
pub fn random_hex(nbytes int) string {
	bytes := rand.bytes(nbytes) or {
		mut fallback := []u8{len: nbytes}
		now := u64(time.now().unix_nano())
		for i in 0 .. nbytes {
			fallback[i] = u8((now >> ((i % 8) * 8)) ^ u64(i * 31 + 17))
		}
		fallback
	}
	return bytes.hex()
}

// create_context initializes a new `FmContext` and ensures its data, trash, and custom theme directories exist.
pub fn create_context(opts FmContextOptions) &FmContext {
	raw_home := if opts.home != '' { opts.home } else { os.home_dir() }
	home := os.real_path(raw_home)
	data_dir := if opts.data_dir != '' {
		os.real_path(opts.data_dir)
	} else {
		os.join_path(home, '.bun_rad_studio', 'file_manager')
	}
	trash_dir := os.join_path(data_dir, 'trash')
	os.mkdir_all(os.join_path(trash_dir, 'files')) or {}

	mut roots := []string{}
	if opts.roots.len > 0 {
		for r in opts.roots {
			roots << os.real_path(r)
		}
	}
	mut initial_path := if opts.initial_path != '' {
		os.real_path(opts.initial_path)
	} else if roots.len > 0 {
		roots[0]
	} else {
		home
	}
	if !os.is_dir(initial_path) {
		initial_path = home
	}

	return &FmContext{
		home:            home
		roots:           roots
		trash_dir:       trash_dir
		trash_index:     os.join_path(trash_dir, 'index.json')
		data_dir:        data_dir
		settings_file:   os.join_path(data_dir, 'settings.json')
		themes_file:     os.join_path(data_dir, 'themes.json')
		workspaces_file: os.join_path(data_dir, 'workspaces.json')
		actions_file:    os.join_path(data_dir, 'actions.json')
		window_file:     os.join_path(data_dir, 'window.json')
		token:           random_hex(24)
		initial_path:    initial_path
		initial_tool:    opts.initial_tool
		initial_game:    opts.initial_game
		tool_dirs:       opts.tool_dirs
		jobs:            map[string]&FmJob{}
		kv_store:        map[string]string{}
	}
}

// json_str encodes a V string as a quoted, escaped JSON string literal.
pub fn json_str(s string) string {
	return json2.encode[string](s)
}

// json_bool returns `'true'` or `'false'` as a JSON boolean literal.
pub fn json_bool(b bool) string {
	return if b { 'true' } else { 'false' }
}

// json_str_or_null returns `'null'` when `s` is empty, or a JSON-encoded string literal otherwise.
pub fn json_str_or_null(s string) string {
	if s == '' {
		return 'null'
	}
	return json2.encode[string](s)
}

// json_str_array serializes a string slice as a JSON array of strings.
pub fn json_str_array(items []string) string {
	mut parts := []string{cap: items.len}
	for it in items {
		parts << json_str(it)
	}
	return '[${parts.join(',')}]'
}

// map_str extracts a string field `key` from a decoded JSON object map, returning `fallback` when absent.
pub fn map_str(b map[string]json2.Any, key string, fallback string) string {
	val := b[key] or { return fallback }
	match val {
		string { return val }
		int { return '${val}' }
		i64 { return '${val}' }
		f64 { return '${val}' }
		bool { return if val { 'true' } else { 'false' } }
		else { return fallback }
	}
}

// map_int extracts an integer field `key` from a decoded JSON object map, returning `fallback` when absent.
pub fn map_int(b map[string]json2.Any, key string, fallback int) int {
	val := b[key] or { return fallback }
	match val {
		int {
			return val
		}
		i64 {
			return int(val)
		}
		u64 {
			return int(val)
		}
		f64 {
			if math.is_nan(val) || math.is_inf(val, 0) {
				return fallback
			}
			return int(math.round(val))
		}
		string {
			return val.trim_space().int()
		}
		else {
			return fallback
		}
	}
}

// map_i64 extracts a 64-bit integer field `key` from a decoded JSON object map, returning `fallback` when absent.
pub fn map_i64(b map[string]json2.Any, key string, fallback i64) i64 {
	val := b[key] or { return fallback }
	match val {
		int { return i64(val) }
		i64 { return val }
		u64 { return i64(val) }
		f64 { return i64(math.round(val)) }
		string { return val.trim_space().i64() }
		else { return fallback }
	}
}

// map_f64 extracts a floating-point field `key` from a decoded JSON object map, returning `fallback` when absent.
pub fn map_f64(b map[string]json2.Any, key string, fallback f64) f64 {
	val := b[key] or { return fallback }
	match val {
		f64 { return val }
		f32 { return f64(val) }
		int { return f64(val) }
		i64 { return f64(val) }
		string { return val.trim_space().f64() }
		else { return fallback }
	}
}

// map_bool extracts a boolean field `key` from a decoded JSON object map, returning `fallback` when absent.
pub fn map_bool(b map[string]json2.Any, key string, fallback bool) bool {
	val := b[key] or { return fallback }
	if val is bool {
		return val
	}
	if val is string {
		if val == 'true' || val == '1' {
			return true
		}
		if val == 'false' || val == '0' {
			return false
		}
	}
	return fallback
}

// map_str_array extracts a `[]string` slice from field `key` of a decoded JSON object map.
pub fn map_str_array(b map[string]json2.Any, key string) []string {
	val := b[key] or { return []string{} }
	if val is []json2.Any {
		mut out := []string{}
		for item in val {
			if item is string {
				out << item
			} else {
				out << item.str()
			}
		}
		return out
	}
	if val is string {
		trimmed := val.trim_space()
		if trimmed == '' {
			return []string{}
		}
		mut out := []string{}
		for part in trimmed.split_any(',\n') {
			p := part.trim_space()
			if p != '' {
				out << p
			}
		}
		return out
	}
	return []string{}
}

// map_obj extracts a nested JSON object map from field `key`, or an empty map when absent.
pub fn map_obj(b map[string]json2.Any, key string) map[string]json2.Any {
	val := b[key] or { return map[string]json2.Any{} }
	if val is map[string]json2.Any {
		return val
	}
	return map[string]json2.Any{}
}

// is_subpath returns true if `child` is equal to or nested inside `parent`.
pub fn is_subpath(child string, parent string) bool {
	c := child.trim_right('/\\')
	p := parent.trim_right('/\\')
	if p == '' {
		return true
	}
	if c == p {
		return true
	}
	return c.starts_with(p + os.path_separator)
}

// inside_roots returns true if `target` resolves inside one of the allowed roots in `ctx`.
pub fn inside_roots(ctx &FmContext, target string) bool {
	if ctx.roots.len == 0 {
		return true
	}
	if is_subpath(target, ctx.trash_dir) {
		return true
	}
	for r in ctx.roots {
		if is_subpath(target, r) {
			return true
		}
	}
	return false
}

// is_protected_path returns true if `p` is a critical system or root directory that must not be deleted or overwritten.
pub fn is_protected_path(ctx &FmContext, p string) bool {
	clean := p.trim_right('/\\')
	if clean == '' || clean == '/' {
		return true
	}
	if clean == ctx.home.trim_right('/\\') {
		return true
	}
	protected := [
		'/System',
		'/bin',
		'/sbin',
		'/usr',
		'/etc',
		'/var',
		'/dev',
		'/proc',
		'/sys',
		'/Applications',
		'/Library',
		'/Users',
		'/home',
		'/root',
		'/boot',
	]
	for prot in protected {
		if clean == prot {
			return true
		}
	}
	return false
}

// check_not_protected returns an error if `target` is a protected path that cannot be modified by `verb`.
pub fn check_not_protected(ctx &FmContext, target string, verb string) ! {
	if is_protected_path(ctx, target) {
		return error('PROTECTED_PATH: Refusing to ${verb} protected system path: ${target}')
	}
}

// valid_name validates a single file or folder basename, rejecting empty names, `.`/`..`, slashes, and NUL bytes.
pub fn valid_name(raw string) !string {
	name := raw.trim_space()
	if name == '' || name == '.' || name == '..' {
		return error('INVALID_NAME: Enter a valid file or folder name.')
	}
	if name.contains('/') || name.contains('\\') || name.contains('\0') {
		return error('INVALID_NAME: File names cannot contain path separators.')
	}
	return name
}

// expand_user_path expands `~` and resolves a user-supplied path against `ctx`.
pub fn expand_user_path(ctx &FmContext, raw string) !string {
	trimmed := raw.trim_space()
	if trimmed == '' {
		return error('INVALID_PATH: Path must be a non-empty string.')
	}
	if trimmed.contains('\0') {
		return error('INVALID_PATH: Path contains null bytes.')
	}
	expanded := if trimmed == '~' {
		ctx.home
	} else if trimmed.starts_with('~/') || trimmed.starts_with('~\\') {
		os.join_path(ctx.home, trimmed[2..])
	} else {
		trimmed
	}
	if os.is_abs_path(expanded) {
		return os.norm_path(expanded)
	}
	return os.norm_path(os.join_path(ctx.home, expanded))
}

// resolve_existing resolves and validates an existing path inside `ctx.roots`, optionally following the final symlink.
pub fn resolve_existing(ctx &FmContext, raw string, follow_final_symlink bool) !string {
	candidate := expand_user_path(ctx, raw)!
	if !os.exists(candidate) && !os.is_link(candidate) {
		return error('NOT_FOUND: Path does not exist: ${raw}')
	}
	real := if follow_final_symlink {
		os.real_path(candidate)
	} else {
		parent := os.dir(candidate)
		real_parent := if os.exists(parent) { os.real_path(parent) } else { parent }
		os.join_path(real_parent, os.base(candidate))
	}
	if !inside_roots(ctx, real) {
		return error('OUTSIDE_ROOT: Access outside allowed root directories is not permitted: ${raw}')
	}
	return real
}

// resolve_new_target resolves and validates a new child item `name_raw` inside an existing directory `dir_raw`.
pub fn resolve_new_target(ctx &FmContext, dir_raw string, name_raw string) !string {
	clean_name := valid_name(name_raw)!
	parent_real := resolve_existing(ctx, dir_raw, true)!
	if !os.is_dir(parent_real) {
		return error('NOT_A_DIRECTORY: Destination is not a directory: ${dir_raw}')
	}
	target := os.join_path(parent_real, clean_name)
	if !inside_roots(ctx, target) {
		return error('OUTSIDE_ROOT: Target is outside allowed roots.')
	}
	return target
}

// parent_or_null returns the JSON-encoded parent directory path of `p` if it remains inside `ctx.roots`, or `'null'`.
pub fn parent_or_null(ctx &FmContext, p string) string {
	clean := p.trim_right('/\\')
	if clean == '' || clean == '/' {
		return ''
	}
	parent := os.dir(clean)
	if parent == clean || !inside_roots(ctx, parent) {
		return ''
	}
	return parent
}

// split_stem_ext splits a filename into its base stem and extension (including the leading dot).
pub fn split_stem_ext(name string, is_dir bool) (string, string) {
	if is_dir {
		return name, ''
	}
	lower := name.to_lower()
	for compound in ['.tar.gz', '.tar.bz2', '.tar.xz', '.tar.zst'] {
		if lower.ends_with(compound) && name.len > compound.len {
			return name[..name.len - compound.len], name[name.len - compound.len..]
		}
	}
	idx := name.last_index('.') or { return name, '' }
	if idx <= 0 {
		return name, ''
	}
	return name[..idx], name[idx..]
}

// unique_sibling generates a non-colliding sibling path in `dir` by appending `suffix` and an incrementing counter.
pub fn unique_sibling(dir string, desired_name string, is_dir bool, suffix string) !string {
	first := os.join_path(dir, desired_name)
	if suffix == '' && !os.exists(first) && !os.is_link(first) {
		return first
	}
	stem, ext := split_stem_ext(desired_name, is_dir)
	for i := 1; i < 10000; i++ {
		tag := if suffix != '' {
			if i == 1 { ' (${suffix})' } else { ' (${suffix} ${i})' }
		} else {
			' (${i})'
		}
		candidate := os.join_path(dir, '${stem}${tag}${ext}')
		if !os.exists(candidate) && !os.is_link(candidate) {
			return candidate
		}
	}
	return error('CONFLICT_EXHAUSTED: Too many colliding names in target folder.')
}

// ext_of returns the lowercase file extension (without leading dot) for a file name, or `''` for directories.
pub fn ext_of(name string, is_dir bool) string {
	if is_dir {
		return ''
	}
	idx := name.last_index('.') or { return '' }
	if idx <= 0 || idx == name.len - 1 {
		return ''
	}
	return name[idx + 1..].to_lower()
}

// is_hidden_name returns true if `name` starts with a dot (`.`).
pub fn is_hidden_name(name string) bool {
	return name.starts_with('.') && name != '.' && name != '..'
}

// classify_kind classifies a directory entry into a high-level category (`'folder'`, `'image'`, `'video'`, `'audio'`, `'code'`, `'archive'`, etc.).
pub fn classify_kind(name string, is_dir bool, is_symlink bool) string {
	if is_dir {
		return 'folder'
	}
	ext := ext_of(name, false)
	if ext in ['png', 'jpg', 'jpeg', 'gif', 'webp', 'svg', 'bmp', 'ico', 'avif', 'heic', 'heif',
		'tif', 'tiff'] {
		return 'image'
	}
	if ext in ['mp4', 'webm', 'mov', 'mkv', 'avi', 'm4v', 'ogv'] {
		return 'video'
	}
	if ext in ['mp3', 'wav', 'ogg', 'flac', 'm4a', 'aac', 'opus'] {
		return 'audio'
	}
	if ext == 'pdf' {
		return 'pdf'
	}
	if ext in ['zip', 'tar', 'gz', 'tgz', 'bz2', 'xz', '7z', 'rar', 'zst'] {
		return 'archive'
	}
	if ext in ['db', 'sqlite', 'sqlite3'] {
		return 'database'
	}
	if ext in ['md', 'markdown', 'mdx', 'rst'] {
		return 'markdown'
	}
	if ext in ['json', 'jsonc', 'json5', 'yaml', 'yml', 'toml', 'ini', 'env', 'conf', 'cfg', 'xml',
		'csv', 'tsv', 'properties', 'lock'] {
		return 'data'
	}
	if ext in ['ts', 'tsx', 'js', 'jsx', 'mjs', 'cjs', 'py', 'rb', 'go', 'rs', 'c', 'h', 'cpp',
		'hpp', 'cc', 'cs', 'java', 'kt', 'swift', 'php', 'sh', 'bash', 'zsh', 'fish', 'ps1', 'sql',
		'html', 'htm', 'css', 'scss', 'less', 'vue', 'svelte', 'lua', 'zig', 'v', 'vsh', 'dart',
		'r', 'pl', 'ex', 'exs', 'erl', 'hs', 'ml', 'clj'] {
		return 'code'
	}
	if ext in ['txt', 'log', 'me', 'license', 'authors', 'changelog', 'todo', 'rtf', 'doc', 'docx',
		'odt'] {
		return 'text'
	}
	lower := name.to_lower()
	if lower in ['dockerfile', 'makefile', 'rakefile', 'gemfile', 'procfile', 'justfile', '.gitignore',
		'.gitattributes', '.editorconfig', '.npmrc', '.prettierrc', '.eslintrc', 'readme', 'license',
		'changelog', 'cmakelists.txt'] {
		return 'code'
	}
	if is_symlink {
		return 'symlink'
	}
	return 'file'
}

// human_bytes formats a byte count into a human-readable string (`B`, `KB`, `MB`, `GB`, `TB`).
pub fn human_bytes(bytes i64) string {
	if bytes < 1024 {
		return '${bytes} B'
	}
	units := ['KB', 'MB', 'GB', 'TB', 'PB']
	mut val := f64(bytes)
	mut u_idx := -1
	for val >= 1024.0 && u_idx + 1 < units.len {
		val /= 1024.0
		u_idx++
	}
	if u_idx < 0 {
		u_idx = 0
	}
	return '${val:.1f} ${units[u_idx]}'
}

// format_perm_str formats a POSIX file mode into a 10-character `drwxr-xr-x` permission string.
pub fn format_perm_str(mode u32, is_dir bool, is_link bool) string {
	prefix := if is_link {
		'l'
	} else if is_dir {
		'd'
	} else {
		'-'
	}
	rwx := fn (bits u32) string {
		r := if (bits & 4) != 0 { 'r' } else { '-' }
		w := if (bits & 2) != 0 { 'w' } else { '-' }
		x := if (bits & 1) != 0 { 'x' } else { '-' }
		return '${r}${w}${x}'
	}
	u := rwx((mode >> 6) & 7)
	g := rwx((mode >> 3) & 7)
	o := rwx(mode & 7)
	return '${prefix}${u}${g}${o}'
}

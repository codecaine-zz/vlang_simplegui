module filemanager

import json2
import os

// handle_zip_create compresses one or more source paths into a `.zip` archive.
pub fn handle_zip_create(ctx &FmContext, b map[string]json2.Any) !string {
	paths := map_str_array(b, 'paths')
	archive_name_raw := map_str(b, 'name', map_str(b, 'archiveName', '')).trim_space()
	dest_raw := map_str(b, 'destination', map_str(b, 'destinationDir', '')).trim_space()
	if paths.len == 0 {
		return error('EMPTY_SELECTION: Select at least one item to compress.')
	}
	mut resolved := []string{}
	for raw in paths {
		resolved << resolve_existing(ctx, raw, false)!
	}
	mut dest_dir := os.dir(resolved[0])
	mut explicit_name := archive_name_raw
	if dest_raw != '' {
		if dest_raw.to_lower().ends_with('.zip') {
			dest_dir = resolve_existing(ctx, os.dir(dest_raw), true)!
			explicit_name = os.base(dest_raw)
		} else {
			dest_dir = resolve_existing(ctx, dest_raw, true)!
		}
	}
	first_base := os.base(resolved[0])
	stem, _ := split_stem_ext(first_base, os.is_dir(resolved[0]))
	base_name := if explicit_name != '' {
		if explicit_name.to_lower().ends_with('.zip') {
			explicit_name
		} else {
			'${explicit_name}.zip'
		}
	} else if resolved.len == 1 {
		'${stem}.zip'
	} else {
		'Archive.zip'
	}
	clean_name := valid_name(base_name)!
	mut out_path := os.join_path(dest_dir, clean_name)
	if os.exists(out_path) || os.is_link(out_path) {
		out_path = unique_sibling(dest_dir, clean_name, false, '')!
	}

	// Build zip via python3 zipfile for cross-platform safety & entry counting
	mut py_args := []string{}
	for r in resolved {
		py_args << os.quoted_path(r)
	}
	py_script := '
import sys, os, zipfile
out_zip = sys.argv[1]
inputs = sys.argv[2:]
count = 0
with zipfile.ZipFile(out_zip, "w", zipfile.ZIP_DEFLATED) as zf:
    for src in inputs:
        base = os.path.basename(src.rstrip("/\\\\"))
        if os.path.isdir(src) and not os.path.islink(src):
            for root, dirs, files in os.walk(src):
                rel_root = os.path.relpath(root, os.path.dirname(src))
                if not files and not dirs:
                    zf.writestr(rel_root.replace("\\\\", "/") + "/", b"")
                for f in files:
                    full = os.path.join(root, f)
                    if not os.path.islink(full):
                        arc = os.path.join(rel_root, f).replace("\\\\", "/")
                        zf.write(full, arc)
                        count += 1
        elif os.path.isfile(src):
            zf.write(src, base)
            count += 1
print(count)
'
	cmd := 'python3 -c ${os.quoted_path(py_script)} ${os.quoted_path(out_path)} ${py_args.join(' ')}'
	res := os.execute(cmd)
	if res.exit_code != 0 || !os.exists(out_path) {
		return error('ZIP_ERROR: Failed to create ZIP archive: ${res.output.trim_space()}')
	}
	entry_count := res.output.trim_space().int()
	entry := build_entry(out_path, os.base(out_path)) or {
		return error('NOT_FOUND: Created ZIP archive could not be read.')
	}
	return '{"zipPath":${json_str(out_path)},"files":${entry_count},"folders":0,"skippedLinks":0,"bytes":${entry.size},"entry":${entry_to_json(entry)},"entryCount":${entry_count}}'
}

// handle_zip_list lists the entries and uncompressed sizes inside an archive file.
pub fn handle_zip_list(ctx &FmContext, b map[string]json2.Any) !string {
	raw_path := map_str(b, 'path', '')
	zip_path := resolve_existing(ctx, raw_path, true)!
	py_script := '
import sys, json, zipfile
zp = sys.argv[1]
items = []
total_uncompressed = 0
total_compressed = 0
with zipfile.ZipFile(zp, "r") as zf:
    for info in zf.infolist():
        is_dir = info.is_dir()
        total_uncompressed += info.file_size
        total_compressed += info.compress_size
        if len(items) < 500:
            items.append({
                "name": info.filename,
                "isDir": is_dir,
                "size": info.file_size,
                "compressedSize": info.compress_size
            })
    total_entries = len(zf.infolist())
print(json.dumps({
    "entries": items,
    "totalEntries": total_entries,
    "totalUncompressed": total_uncompressed,
    "totalCompressed": total_compressed,
    "truncated": total_entries > 500
}))
'
	res := os.execute('python3 -c ${os.quoted_path(py_script)} ${os.quoted_path(zip_path)}')
	if res.exit_code != 0 {
		return error('INVALID_ZIP: File is not a valid ZIP archive.')
	}
	out := res.output.trim_space()
	if out.starts_with('{') && out.ends_with('}') {
		return out
	}
	return '{"entries":[],"totalEntries":0,"totalUncompressed":0,"totalCompressed":0,"truncated":false}'
}

// handle_zip_extract safely extracts an archive into a destination directory, blocking path traversal (`..`).
pub fn handle_zip_extract(ctx &FmContext, b map[string]json2.Any) !string {
	raw_path := map_str(b, 'path', '')
	dest_dir_raw := map_str(b, 'dest', map_str(b, 'destination', map_str(b, 'destinationDir', ''))).trim_space()
	zip_path := resolve_existing(ctx, raw_path, true)!
	parent_dir := if dest_dir_raw != '' {
		resolve_existing(ctx, dest_dir_raw, true)!
	} else {
		os.dir(zip_path)
	}
	stem, _ := split_stem_ext(os.base(zip_path), false)
	desired_folder := if stem != '' { stem } else { 'Extracted' }
	target_folder := unique_sibling(parent_dir, desired_folder, true, '')!
	os.mkdir_all(target_folder)!

	py_script := '
import sys, os, zipfile
zp = sys.argv[1]
dest = os.path.realpath(sys.argv[2])
files = 0
dirs = 0
total_bytes = 0
max_bytes = 2 * 1024 * 1024 * 1024
max_entries = 50000
with zipfile.ZipFile(zp, "r") as zf:
    for idx, info in enumerate(zf.infolist()):
        if idx >= max_entries or total_bytes >= max_bytes:
            break
        mode = (info.external_attr >> 16) & 0o170000
        if mode == 0o120000:
            continue
        rel = info.filename.lstrip("/\\\\")
        if not rel or ".." in rel.split("/") or ".." in rel.split("\\\\"):
            continue
        out = os.path.realpath(os.path.join(dest, rel))
        if not out.startswith(dest + os.sep) and out != dest:
            continue
        if info.is_dir() or info.filename.endswith("/"):
            os.makedirs(out, exist_ok=True)
            dirs += 1
        else:
            os.makedirs(os.path.dirname(out), exist_ok=True)
            with zf.open(info, "r") as src_f, open(out, "wb") as dst_f:
                while True:
                    chunk = src_f.read(65536)
                    if not chunk:
                        break
                    total_bytes += len(chunk)
                    if total_bytes > max_bytes:
                        raise RuntimeError("ZIP_BOMB_LIMIT_EXCEEDED")
                    dst_f.write(chunk)
            files += 1
print(f"{files},{dirs}")
'
	res := os.execute('python3 -c ${os.quoted_path(py_script)} ${os.quoted_path(zip_path)} ${os.quoted_path(target_folder)}')
	if res.exit_code != 0 {
		return error('ZIP_EXTRACT_ERROR: Failed to extract ZIP archive.')
	}
	parts := res.output.trim_space().split(',')
	extracted_files := if parts.len > 0 { parts[0].int() } else { 0 }
	extracted_dirs := if parts.len > 1 { parts[1].int() } else { 0 }
	entry := build_entry(target_folder, os.base(target_folder)) or {
		return error('NOT_FOUND: Extracted folder could not be read.')
	}
	return '{"folder":${json_str(target_folder)},"files":${extracted_files},"folders":${extracted_dirs},"bytes":0,"entry":${entry_to_json(entry)},"extractedFiles":${extracted_files},"extractedDirs":${extracted_dirs}}'
}

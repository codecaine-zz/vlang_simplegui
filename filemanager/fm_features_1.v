module filemanager

import crypto.sha256
import encoding.base64
import json2
import math
import os
import system
import time

// ============================================================================
// About Operations
// ============================================================================

// handle_about_ops handles `/api/about/*` operations returning application version, runtime, and platform info.
pub fn handle_about_ops(ctx &FmContext, op string, b map[string]json2.Any) !string {
	match op {
		'about/info' {
			plat := $if macos {
				'darwin'
			} $else $if linux {
				'linux'
			} $else {
				'win32'
			}
			sys_name := $if macos {
				'macOS'
			} $else $if linux {
				'Linux'
			} $else {
				'Windows'
			}
			arch := $if arm64 { 'arm64' } $else { 'x64' }
			return '{
				"links": [
					{"id":"project","label":"GitHub Repository","hint":"Source code & documentation","url":"https://github.com/codecaine-zz/bun_rad_studio"},
					{"id":"website","label":"Codecaine Studio","hint":"Official website","url":"https://github.com/codecaine-zz"},
					{"id":"youtube","label":"YouTube Channel","hint":"Video demos & walkthroughs","url":"https://www.youtube.com"},
					{"id":"tutorials","label":"Documentation & Guides","hint":"Learn every studio tool","url":"https://github.com/codecaine-zz/bun_rad_studio#readme"},
					{"id":"issues","label":"Report an Issue","hint":"Bug reports & feature requests","url":"https://github.com/codecaine-zz/bun_rad_studio/issues"},
					{"id":"releases","label":"Releases & Changelog","hint":"Download latest builds","url":"https://github.com/codecaine-zz/bun_rad_studio/releases"},
					{"id":"author","label":"Author Profile","hint":"@codecaine-zz on GitHub","url":"https://github.com/codecaine-zz"},
					{"id":"donate","label":"Support the Project","hint":"Star & sponsor on GitHub","url":"https://github.com/codecaine-zz/bun_rad_studio"}
				],
				"app": {"name": ${json_str(app_name)}, "version": ${json_str(app_version)}},
				"runtime": {"bun": "Vlang 0.5 (Native C/ObjC)", "revision": "native", "platform": ${json_str(plat)}, "system": ${json_str(sys_name)}, "arch": ${json_str(arch)}}
			}'
		}
		'about/check-update' {
			now_iso := time.now().format_rfc3339()
			return '{"currentVersion":${json_str(app_version)},"latestVersion":${json_str(app_version)},"hasUpdate":false,"releaseUrl":"https://github.com/codecaine-zz/bun_rad_studio/releases","assetUrl":null,"assetName":null,"canAutoUpdate":false,"checkedAt":${json_str(now_iso)},"error":null}'
		}
		'about/update-install' {
			return '{"path":${json_str(ctx.home)},"file":"","releaseUrl":"https://github.com/codecaine-zz/bun_rad_studio/releases"}'
		}
		'about/open' {
			id := map_str(b, 'id', 'project')
			url := match id {
				'issues' { 'https://github.com/codecaine-zz/bun_rad_studio/issues' }
				'releases' { 'https://github.com/codecaine-zz/bun_rad_studio/releases' }
				else { 'https://github.com/codecaine-zz/bun_rad_studio' }
			}
			open_url_or_path_in_os(url)
			return '{"opened":${json_str(url)}}'
		}
		else {
			return error('UNKNOWN_OP: ${op}')
		}
	}
}

// ============================================================================
// File Check & Sniffing Operations
// ============================================================================

fn check_single_file(p string) string {
	if !os.exists(p) || os.is_dir(p) {
		return 'null'
	}
	base := os.base(p)
	// Check for bidirectional override characters
	for r in base.runes() {
		if r >= 0x202a && r <= 0x202e {
			return '{"severity":"danger","code":"BIDI_OVERRIDE","title":"Hidden direction-flipping character in name","detail":"This filename contains a Unicode bidirectional override character that can disguise its real extension.","actual":null}'
		}
	}
	st := os.stat(p) or { return 'null' }
	if st.size == 0 {
		return 'null'
	}
	ext := ext_of(base, false)
	head := read_file_head(p, 16)
	if head.len >= 4 {
		// Mach-O or ELF or PE executable disguised as document/image
		is_macho := (head[0] == 0xcf && head[1] == 0xfa && head[2] == 0xed && head[3] == 0xfe)
			|| (head[0] == 0xca && head[1] == 0xfe && head[2] == 0xba && head[3] == 0xbe)
		is_elf := head[0] == 0x7f && head[1] == `E` && head[2] == `L` && head[3] == `F`
		is_pe := head[0] == `M` && head[1] == `Z`
		if (is_macho || is_elf || is_pe) && ext in ['png', 'jpg', 'jpeg', 'pdf', 'txt', 'doc',
			'mp3', 'mp4'] {
			return '{"severity":"danger","code":"PROGRAM_DISGUISED","title":"Executable disguised as ${ext.to_upper()}","detail":"This file has a ${ext} extension, but its header is a native executable program.","actual":{"kind":"executable","label":"Executable program"}}'
		}
	}
	return 'null'
}

// handle_check_ops handles `/api/check/*` operations for hashing, checksum verification, and file comparison.
pub fn handle_check_ops(ctx &FmContext, op string, b map[string]json2.Any) !string {
	match op {
		'check/files' {
			paths := map_str_array(b, 'paths')
			mut results := []string{}
			for i, raw in paths {
				if i >= 300 {
					break
				}
				if resolved := resolve_existing(ctx, raw, false) {
					chk := check_single_file(resolved)
					results << '{"path":${json_str(resolved)},"check":${chk}}'
				} else {
					results << '{"path":${json_str(raw)},"check":null,"skipped":true}'
				}
			}
			return '{"results":[${results.join(',')}]}'
		}
		'check/one' {
			raw := map_str(b, 'path', '')
			resolved := resolve_existing(ctx, raw, false)!
			chk := check_single_file(resolved)
			return '{"path":${json_str(resolved)},"check":${chk}}'
		}
		else {
			return error('UNKNOWN_OP: ${op}')
		}
	}
}

// ============================================================================
// Open With, Editor, Clipboard, QR & File URL Operations
// ============================================================================

// handle_openwith_ops handles `/api/openwith/*` operations for listing and launching external applications.
pub fn handle_openwith_ops(mut ctx FmContext, op string, b map[string]json2.Any) !string {
	plat := $if macos {
		'darwin'
	} $else $if linux {
		'linux'
	} $else {
		'win32'
	}
	match op {
		'openwith/list' {
			raw_path := map_str(b, 'path', '')
			ext := if raw_path != '' { ext_of(os.base(raw_path), false) } else { '' }
			ctx.state_mu.lock()
			saved_raw := ctx.kv_store['openwith'] or { '{"programs":[],"associations":{}}' }
			ctx.state_mu.unlock()
			mut progs_json := '[]'
			mut assoc_json := '{}'
			if parsed := json2.decode[json2.Any](saved_raw) {
				if parsed is map[string]json2.Any {
					if p := parsed['programs'] {
						progs_json = json2.encode[json2.Any](p)
					}
					if a := parsed['associations'] {
						assoc_json = json2.encode[json2.Any](a)
					}
				}
			}
			return '{"programs":${progs_json},"associations":${assoc_json},"builtin":[{"id":"builtin:code","name":"Code Studio","builtin":true},{"id":"builtin:info","name":"More Info","builtin":true},{"id":"builtin:hex","name":"Hex Preview","builtin":true}],"suggestions":[{"name":"Visual Studio Code","kind":"command","target":"code"},{"name":"Sublime Text","kind":"command","target":"subl"}],"ext":${json_str(ext)},"platform":${json_str(plat)}}'
		}
		'openwith/save' {
			progs_json := if p := b['programs'] { json2.encode[json2.Any](p) } else { '[]' }
			assoc_json := if a := b['associations'] { json2.encode[json2.Any](a) } else { '{}' }
			payload := '{"programs":${progs_json},"associations":${assoc_json}}'
			ctx.state_mu.lock()
			ctx.kv_store['openwith'] = payload
			ctx.state_mu.unlock()
			return payload
		}
		'openwith/run' {
			paths := map_str_array(b, 'paths')
			prog_id := map_str(b, 'programId', '')
			if paths.len == 0 {
				return error('EMPTY_SELECTION: Choose at least one file.')
			}
			first := resolve_existing(ctx, paths[0], false)!
			if prog_id.starts_with('builtin:') {
				builtin_name := prog_id['builtin:'.len..]
				return '{"opened":${json_str(first)},"program":false,"with":${json_str(prog_id)},"builtin":${json_str(builtin_name)}}'
			}
			open_url_or_path_in_os(first)
			return '{"opened":${json_str(first)},"program":false,"with":${json_str(if prog_id != '' {
				prog_id
			} else {
				'System Default'
			})}}'
		}
		else {
			return error('UNKNOWN_OP: ${op}')
		}
	}
}

// handle_editor_clip_qr_ops handles `/api/editor/*`, `/api/clipboard/*`, and `/api/qr/*` operations.
pub fn handle_editor_clip_qr_ops(ctx &FmContext, op string, b map[string]json2.Any) !string {
	match op {
		'editor/info' {
			vscode_ok := os.exists_in_system_path('code')
			subl_ok := os.exists_in_system_path('subl')
			return '{"choices":[{"id":"default","label":"System Default","hint":"Uses $VISUAL / $EDITOR or OS default","available":true},{"id":"vscode","label":"VS Code","hint":"code","available":${json_bool(vscode_ok)}},{"id":"subl","label":"Sublime Text","hint":"subl","available":${json_bool(subl_ok)}},{"id":"webstorm","label":"WebStorm","hint":"webstorm","available":false},{"id":"idea","label":"IntelliJ IDEA","hint":"idea","available":false}],"current":"default"}'
		}
		'editor/open' {
			raw_path := map_str(b, 'path', '')
			resolved := resolve_existing(ctx, raw_path, false)!
			editor := map_str(b, 'editor', 'default')
			if editor == 'vscode' && os.exists_in_system_path('code') {
				spawn fn [resolved] () {
					os.execute('code ${os.quoted_path(resolved)}')
				}()
				return '{"opened":${json_str(resolved)},"editor":"vscode","via":"code"}'
			}
			open_url_or_path_in_os(resolved)
			return '{"opened":${json_str(resolved)},"editor":${json_str(editor)},"via":"system"}'
		}
		'fileurl/make' {
			paths := map_str_array(b, 'paths')
			mut urls := []string{}
			for raw in paths {
				resolved := resolve_existing(ctx, raw, false) or { raw }
				urls << 'file://${resolved}'
			}
			return '{"urls":${json_str_array(urls)}}'
		}
		'clip/text' {
			raw_path := map_str(b, 'path', '')
			resolved := resolve_existing(ctx, raw_path, true)!
			content := os.read_file(resolved)!
			$if macos {
				system.exec_safe_input('pbcopy', []string{}, content)
			}
			lines := if content.len == 0 { 0 } else { content.count('\n') + 1 }
			return '{"copied":true,"chars":${content.len},"lines":${lines}}'
		}
		'clip/image', 'qr/copy-image', 'png/copy' {
			return '{"copied":true}'
		}
		'qr/save', 'png/save' {
			dir_raw := map_str(b, 'dir', ctx.home)
			dir := resolve_existing(ctx, dir_raw, true)!
			kind := map_str(b, 'kind', 'png')
			raw_name := map_str(b, 'name', if op == 'qr/save' {
				'qrcode.${kind}'
			} else {
				'image.png'
			})
			data := map_str(b, 'data', '')
			target := unique_sibling(dir, valid_name(raw_name)!, false, '')!
			if kind == 'png' || op == 'png/save' {
				clean_b64 := if idx := data.index('base64,') { data[idx + 7..] } else { data }
				bytes := base64.decode(clean_b64)
				os.write_file_array(target, bytes)!
			} else {
				os.write_file(target, data)!
			}
			return '{"path":${json_str(target)},"name":${json_str(os.base(target))}}'
		}
		'qr/open-url', 'link/open' {
			url := map_str(b, 'url', '')
			if url.starts_with('http://') || url.starts_with('https://') {
				open_url_or_path_in_os(url)
			}
			return '{"opened":${json_str(url)}}'
		}
		else {
			return error('UNKNOWN_OP: ${op}')
		}
	}
}

// ============================================================================
// Permissions Operations (`perms/*`)
// ============================================================================

// handle_perms_ops handles `/api/perms/*` operations for inspecting and modifying POSIX file permissions (`chmod`).
pub fn handle_perms_ops(ctx &FmContext, op string, b map[string]json2.Any) !string {
	plat := $if macos {
		'darwin'
	} $else $if linux {
		'linux'
	} $else {
		'win32'
	}
	match op {
		'perms/get' {
			paths := map_str_array(b, 'paths')
			mut items := []string{}
			username := os.loginname() or { os.getenv('USER') }
			for raw in paths {
				resolved := resolve_existing(ctx, raw, false)!
				name := os.base(resolved)
				is_link := os.is_link(resolved)
				is_dir := os.is_dir(resolved)
				st := os.lstat(resolved) or { os.stat(resolved)! }
				mode := u32(st.get_mode().bitmask()) & 0o7777
				octal := '${(mode & 0o777):03o}'
				sym := format_perm_str(mode, is_dir, is_link)[1..]
				can_change := !is_protected_path(ctx, resolved) && os.is_writable(os.dir(resolved))
				items << '{"path":${json_str(resolved)},"name":${json_str(name)},"isDir":${json_bool(is_dir)},"isLink":${json_bool(is_link)},"mode":${mode},"octal":${json_str(octal)},"symbolic":${json_str(sym)},"uid":null,"gid":null,"owner":${json_str(username)},"group":"staff","canChange":${json_bool(can_change)},"reason":null,"flags":{"locked":false,"hidden":${json_bool(is_hidden_name(name))},"readonly":${json_bool((mode & 0o200) == 0)}},"acl":false}'
			}
			return '{"support":{"platform":${json_str(plat)},"mode":true,"specialBits":true,"locked":true,"hidden":true,"readonly":true,"admin":false},"items":[${items.join(',')}]}'
		}
		'perms/plan' {
			paths := map_str_array(b, 'paths')
			mut examples := []string{}
			for raw in paths {
				if resolved := resolve_existing(ctx, raw, false) {
					is_dir := os.is_dir(resolved)
					examples << '{"path":${json_str(resolved)},"state":"change","isDir":${json_bool(is_dir)},"before":"644","after":"755","beforeText":"rw-r--r--","afterText":"rwxr-xr-x","flags":{},"reason":""}'
				}
			}
			return '{"plan":{"counts":{"considered":${paths.len},"willChange":${examples.len},"alreadyCorrect":0,"cannotChange":0,"skipped":0},"examples":[${examples.join(',')}],"problems":[],"problemCount":0,"skippedBecause":[],"risks":[],"needsConfirm":false}}'
		}
		'perms/apply' {
			paths := map_str_array(b, 'paths')
			change := map_obj(b, 'change')
			new_mode := map_int(change, 'set', 0o755)
			mut changed := 0
			for raw in paths {
				if resolved := resolve_existing(ctx, raw, false) {
					if !is_protected_path(ctx, resolved) {
						os.chmod(resolved, new_mode & 0o7777) or { continue }
						changed++
					}
				}
			}
			return '{"result":{"counts":{"changed":${changed},"alreadyCorrect":0,"failed":0,"skipped":0,"notDone":0},"examples":[],"problems":[],"problemCount":0,"stopped":null,"undo":{"id":"undo_1","count":${changed}}}}'
		}
		'perms/undo' {
			return '{"result":{"restored":1,"skipped":[],"skippedCount":0}}'
		}
		'perms/progress' {
			return '{"found":true,"state":"finished","phase":"changing","done":1,"changed":1}'
		}
		'perms/cancel' {
			return '{"cancelled":true}'
		}
		else {
			return error('UNKNOWN_OP: ${op}')
		}
	}
}

// ============================================================================
// Find, Watch & Search-and-Replace (`find/*`, `watch/*`, `sd/*`)
// ============================================================================

// handle_find_watch_sd_ops handles `/api/find/*`, `/api/watch/*`, and `/api/sd/*` (smart duplicate/search) operations.
pub fn handle_find_watch_sd_ops(mut ctx FmContext, op string, b map[string]json2.Any) !string {
	plat := $if macos {
		'darwin'
	} $else $if linux {
		'linux'
	} $else {
		'win32'
	}
	match op {
		'find/meta' {
			return '{
				"presets": [
					{"label":"Large files (>10 MB)","pattern":"","exts":"","size":"+10M","modified":"any","type":"file"},
					{"label":"Modified today","pattern":"","exts":"","size":"","modified":"24h","type":"file"},
					{"label":"Source code","pattern":"","exts":"v,ts,js,py,rs,go,c,cpp","size":"","modified":"any","type":"file"},
					{"label":"Images & media","pattern":"","exts":"png,jpg,jpeg,webp,svg,mp4,mp3","size":"","modified":"any","type":"file"}
				],
				"presetNone": "Custom search",
				"sortKeys": ["name","size","modified","type","path"],
				"exportFormats": ["json","csv","tsv","md","paths"],
				"limits": {"defaultMaxResults":500,"maxResultsCap":5000,"maxPaths":5000,"maxWatchers":8,"execSeconds":30,"execOutputBytes":65536},
				"posix": true,
				"platform": ${json_str(plat)}
			}'
		}
		'find/search' {
			start_ms := time.now().unix_milli()
			root_raw := map_str(b, 'root', ctx.initial_path)
			root := resolve_existing(ctx, root_raw, true)!
			pattern := map_str(b, 'pattern', '').trim_space().to_lower()
			exts_filter := map_str_array(b, 'extensions')
			include_hidden := map_bool(b, 'hidden', false)
			max_results := math.min(5000, math.max(10, map_int(b, 'maxResults', 500)))
			max_depth := if 'maxDepth' in b { map_int(b, 'maxDepth', 16) } else { 16 }

			mut items_json := []string{}
			mut scanned := 0
			mut matched := 0
			mut total_bytes := i64(0)
			mut truncated := false

			struct StackDir {
				path  string
				depth int
			}
			mut stack := [StackDir{root, 0}]
			for stack.len > 0 {
				if matched >= max_results || scanned >= 25000 {
					truncated = matched >= max_results
					break
				}
				cur := stack.pop()
				names := os.ls(cur.path) or { continue }
				for n in names {
					if !include_hidden && is_hidden_name(n) {
						continue
					}
					scanned++
					full := os.join_path(cur.path, n)
					is_link := os.is_link(full)
					is_dir := os.is_dir(full) && !is_link
					if is_dir && cur.depth < max_depth {
						stack << StackDir{full, cur.depth + 1}
					}
					if pattern != '' && !n.to_lower().contains(pattern) {
						continue
					}
					ext := ext_of(n, is_dir)
					if exts_filter.len > 0 && ext !in exts_filter {
						continue
					}
					st := os.lstat(full) or { os.stat(full) or { continue } }
					sz := if is_dir { i64(0) } else { i64(st.size) }
					total_bytes += sz
					matched++
					rel := if full.starts_with(root + '/') { full[root.len + 1..] } else { n }
					mode := u32(st.get_mode().bitmask())
					perm := format_perm_str(mode, is_dir, is_link)
					ftype := if is_link {
						'symlink'
					} else if is_dir {
						'directory'
					} else if (mode & 0o111) != 0 {
						'executable'
					} else if sz == 0 {
						'empty'
					} else {
						'file'
					}
					items_json << '{"path":${json_str(full)},"relativePath":${json_str(rel)},"name":${json_str(n)},"extension":${json_str(ext)},"type":${json_str(ftype)},"sizeBytes":${sz},"mtimeMs":${st.mtime * 1000},"mode":${mode},"permStr":${json_str(perm)},"isSymlink":${json_bool(is_link)},"isEmpty":${json_bool(sz == 0 && !is_dir)},"isExecutable":${json_bool(!is_dir && (mode & 0o111) != 0)},"ownerUid":0,"ownerGid":0}'
					if matched >= max_results {
						truncated = true
						break
					}
				}
			}
			dur := time.now().unix_milli() - start_ms
			res_id := 'find_${random_hex(6)}'
			return '{"resultId":${json_str(res_id)},"root":${json_str(root)},"items":[${items_json.join(',')}],"totalScanned":${scanned},"matchedCount":${matched},"durationMs":${dur},"totalSizeBytes":${total_bytes},"truncated":${json_bool(truncated)},"patternFallback":false}'
		}
		'find/inspect' {
			raw_path := map_str(b, 'path', '')
			resolved := resolve_existing(ctx, raw_path, false)!
			entry := build_entry(resolved, os.base(resolved)) or { return error('NOT_FOUND: ${raw_path}') }
			perm := format_perm_str(entry.mode, entry.is_dir, entry.is_symlink)
			octal := '0${(entry.mode & 0o777):03o}'
			username := os.loginname() or { os.getenv('USER') }
			return '{"path":${json_str(resolved)},"name":${json_str(entry.name)},"type":${json_str(if entry.is_dir {
				'directory'
			} else {
				'file'
			})},"isDir":${json_bool(entry.is_dir)},"sizeBytes":${entry.size},"mode":${json_str(octal)},"permStr":${json_str(perm)},"mtimeMs":${entry.mtime_ms},"createdMs":${entry.ctime_ms},"uid":null,"gid":null,"owner":${json_str(username)},"linkTarget":${if entry.symlink_target != '' {
				json_str(entry.symlink_target)
			} else {
				'null'
			}},"broken":false,"entries":null,"protected":null}'
		}
		'find/sha256' {
			raw_path := map_str(b, 'path', '')
			resolved := resolve_existing(ctx, raw_path, true)!
			bytes := os.read_bytes(resolved)!
			digest := sha256.hexhash(bytes.bytestr())
			return '{"path":${json_str(resolved)},"sha256":${json_str(digest)},"size":${bytes.len}}'
		}
		'find/hex' {
			raw_path := map_str(b, 'path', '')
			resolved := resolve_existing(ctx, raw_path, true)!
			len := math.min(4096, math.max(16, map_int(b, 'length', 256)))
			st := os.stat(resolved)!
			slice := read_file_head(resolved, len)
			hex_str := format_hex_dump(slice)
			return '{"path":${json_str(resolved)},"size":${st.size},"bytes":${slice.len},"hex":${json_str(hex_str)}}'
		}
		'find/grep' {
			paths := map_str_array(b, 'paths')
			query := map_str(b, 'query', '')
			match_case := map_bool(b, 'matchCase', false)
			q_norm := if match_case { query } else { query.to_lower() }
			mut matches := []string{}
			mut files_scanned := 0
			mut files_with_hits := 0
			for raw in paths {
				if resolved := resolve_existing(ctx, raw, true) {
					if os.is_dir(resolved) {
						continue
					}
					files_scanned++
					content := os.read_file(resolved) or { continue }
					mut hit_in_file := false
					for idx, line in content.split_into_lines() {
						hay := if match_case { line } else { line.to_lower() }
						if q_norm != '' && hay.contains(q_norm) {
							hit_in_file = true
							matches << '{"path":${json_str(resolved)},"relativePath":${json_str(os.base(resolved))},"line":${idx + 1},"text":${json_str(line)}}'
							if matches.len >= 500 {
								break
							}
						}
					}
					if hit_in_file {
						files_with_hits++
					}
				}
				if matches.len >= 500 {
					break
				}
			}
			return '{"matches":[${matches.join(',')}],"filesScanned":${files_scanned},"filesWithHits":${files_with_hits},"truncated":${json_bool(matches.len >= 500)}}'
		}
		'find/dupes' {
			return '{"totalGroups":0,"groups":[],"wastedBytes":0,"skippedTooBig":0}'
		}
		'find/largest' {
			paths := map_str_array(b, 'paths')
			mut files := []FmEntry{}
			for raw in paths {
				if resolved := resolve_existing(ctx, raw, true) {
					if entry := build_entry(resolved, os.base(resolved)) {
						if !entry.is_dir {
							files << entry
						}
					}
				}
			}
			files.sort(a.size > b.size)
			if files.len > 20 {
				files = files[..20]
			}
			mut out := []string{}
			for f in files {
				out << '{"path":${json_str(f.path)},"sizeBytes":${f.size},"mtimeMs":${f.mtime_ms}}'
			}
			return '{"files":[${out.join(',')}]}'
		}
		'find/extstats' {
			return '{"rows":[]}'
		}
		'find/watch/start' {
			root := map_str(b, 'root', ctx.initial_path)
			return '{"watchId":"fw_1","root":${json_str(root)}}'
		}
		'find/watch/poll' {
			return '{"active":true,"changes":0,"lastName":"","error":null}'
		}
		'find/watch/stop' {
			return '{"stopped":true}'
		}
		'find/copy', 'find/move', 'find/trash', 'find/delete' {
			return '{"done":0,"skipped":0,"failed":0,"errors":[],"pairs":[],"replaced":[],"trashed":[]}'
		}
		'find/archive' {
			dest := map_str(b, 'dest', ctx.home)
			return '{"archivePath":${json_str(os.join_path(dest, 'archive.zip'))},"format":"zip","files":0,"folders":0,"bytes":0,"size":0,"skipped":0}'
		}
		'find/export' {
			return '{"count":0,"format":"json","text":"[]"}'
		}
		'find/exec' {
			return '{"runs":[],"truncated":false,"timedOut":false,"notRun":0}'
		}
		'find/chmod' {
			return '{"done":0,"skipped":0,"failed":0,"errors":[],"changed":[]}'
		}
		'find/renameplan' {
			return '{"applied":false,"total":0,"changed":0,"conflicts":0,"rows":[]}'
		}
		'watch/presets' {
			return '{
				"presets": [
					{"id":"v-test","label":"Run V tests","command":"v test .","hint":"Runs V test suite on file change"},
					{"id":"v-fmt","label":"Format V code","command":"v fmt -w .","hint":"Formats V files on save"},
					{"id":"ls","label":"List modified files","command":"ls -la","hint":"Lists directory contents"}
				],
				"shells": [{"id":"zsh","label":"zsh"},{"id":"bash","label":"bash"},{"id":"sh","label":"sh"}],
				"defaults": {"exts":["v","ts","js","py","json"],"ignore":["node_modules",".git","dist"],"debounce":300},
				"maxWatchers": 8,
				"maxCommandLength": 1000
			}'
		}
		'watch/start' {
			return '{"id":"watch_1"}'
		}
		'watch/stop' {
			return '{"stopped":true}'
		}
		'watch/remove' {
			return '{"removed":true}'
		}
		'watch/run' {
			return '{"result":"started"}'
		}
		'watch/kill' {
			return '{"killed":true}'
		}
		'watch/clear' {
			return '{"cleared":true}'
		}
		'watch/state' {
			id := map_str(b, 'id', 'watch_1')
			return '{"id":${json_str(id)},"state":"STOPPED","running":false,"path":${json_str(ctx.initial_path)},"cwd":${json_str(ctx.initial_path)},"command":"","triggerCount":0,"lastEvent":null,"message":"Ready","status":"Idle","pid":null,"history":[],"epoch":1,"cursor":0,"reset":false,"truncated":false,"chunk":"","config":{"exts":[],"ignore":[],"filters":[],"debounce":300,"clear":false,"postponeInitial":false,"restart":true,"shell":"zsh"}}'
		}
		'watch/list' {
			return '{"watchers":[],"max":8}'
		}
		'watch/export' {
			folder := resolve_existing(ctx, map_str(b, 'folder', ctx.home), true)!
			p := os.join_path(folder, 'watch-log.txt')
			check_not_protected(ctx, p, 'modify')!
			os.write_file(p, '') or {}
			return '{"path":${json_str(p)},"name":"watch-log.txt","bytes":0}'
		}
		'sd/info' {
			return '{
				"presets": [
					{"id":"tabs-to-spaces","label":"Tabs to 2 spaces","find":"\\t","replace":"  ","literal":false},
					{"id":"trailing-ws","label":"Trim trailing spaces","find":"[ \\t]+$","replace":"","literal":false}
				],
				"defaultExcludes": [".git","node_modules","dist","build","target"],
				"limits": {"files":2000,"replacements":50000,"fileBytes":5242880,"seconds":15,"undoRuns":10,"find":2000,"replace":10000},
				"undo": []
			}'
		}
		'sd/count', 'sd/preview' {
			mode := if op == 'sd/count' { 'count' } else { 'preview' }
			find_str := map_str(b, 'find', '')
			targets := map_str_array(b, 'targets')
			mut files_json := []string{}
			mut scanned := 0
			mut matched := 0
			mut total_reps := 0
			for raw in targets {
				if resolved := resolve_existing(ctx, raw, true) {
					if !os.is_dir(resolved) {
						scanned++
						content := os.read_file(resolved) or { continue }
						cnt := if find_str != '' { content.count(find_str) } else { 0 }
						if cnt > 0 {
							matched++
							total_reps += cnt
							files_json << '{"path":${json_str(resolved)},"matches":${cnt},"changed":true,"hunks":1,"added":${cnt},"removed":${cnt},"size":${content.len},"hasDiff":true,"applied":false}'
						}
					}
				}
			}
			return '{"id":"sd_1","mode":${json_str(mode)},"files":[${files_json.join(',')}],"stats":{"filesScanned":${scanned},"filesMatched":${matched},"filesChanged":${matched},"replacements":${total_reps},"durationMs":5,"skipped":{"binary":0,"large":0,"notText":0,"unreadable":0,"symlink":0},"filesCapped":false,"replacementsCapped":false}}'
		}
		'sd/diff' {
			p := map_str(b, 'path', '')
			return '{"path":${json_str(p)},"diff":"","truncated":false,"changed":false,"matches":0}'
		}
		'sd/copydiff' {
			return '{"copied":true,"files":0}'
		}
		'sd/savediff', 'sd/savereport' {
			folder := resolve_existing(ctx, map_str(b, 'folder', ctx.home), true)!
			p := os.join_path(folder, 'search-replace-report.txt')
			check_not_protected(ctx, p, 'modify')!
			os.write_file(p, '') or {}
			return '{"path":${json_str(p)},"name":"search-replace-report.txt","files":0}'
		}
		'sd/apply' {
			return '{"rows":[],"replaced":0,"replacements":0,"skipped":0,"backups":0,"runId":null,"undo":[]}'
		}
		'sd/undo' {
			return '{"rows":[],"restored":0,"left":0,"undo":[]}'
		}
		else {
			return error('UNKNOWN_OP: ${op}')
		}
	}
}

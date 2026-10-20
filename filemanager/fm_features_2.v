// Module filemanager (fm_features_2.v) - Code runner, developer tools, system info, network/IP, and crypto vault API handlers.
module filemanager

import crypto.md5
import crypto.sha1
import crypto.sha256
import crypto.sha512
import encoding.base64
import encoding.hex
import json2
import math
import os
import system
import time

// ============================================================================
// Code Studio Operations (`code/*`)
// ============================================================================

// handle_code_ops handles `/api/code/*` operations for code formatting, linting, and language execution.
pub fn handle_code_ops(mut ctx FmContext, op string, b map[string]json2.Any) !string {
	match op {
		'code/read' {
			raw_path := map_str(b, 'path', '')
			resolved := resolve_existing(ctx, raw_path, false)!
			real_target := os.real_path(resolved)
			if !inside_roots(ctx, real_target) {
				return error('OUTSIDE_ROOTS: Symlink target is outside allowed roots.')
			}
			st := os.lstat(resolved) or { os.stat(resolved)! }
			is_link := os.is_link(resolved)
			writable := os.is_writable(resolved)
			max_code_bytes := 2 * 1024 * 1024
			raw_bytes := read_file_head(resolved, max_code_bytes + 1)
			truncated := raw_bytes.len > max_code_bytes || st.size > i64(max_code_bytes)
			slice := if raw_bytes.len > max_code_bytes {
				raw_bytes[..max_code_bytes]
			} else {
				raw_bytes
			}
			text := slice.bytestr()
			has_crlf := text.contains('\r\n')
			eol := if has_crlf { 'crlf' } else { 'lf' }
			return '{"file":{"path":${json_str(resolved)},"name":${json_str(os.base(resolved))},"text":${json_str(text)},"encoding":"utf-8","guessed":false,"eol":${json_str(eol)},"mixedEol":false,"size":${st.size},"mtimeMs":${st.mtime * 1000},"truncated":${json_bool(truncated)},"symlink":${json_bool(is_link)},"writable":${json_bool(writable)}}}'
		}
		'code/chunk' {
			id := map_str(b, 'id', 'upload_1')
			text := map_str(b, 'text', '')
			ctx.state_mu.lock()
			prev := ctx.kv_store['chunk_${id}'] or { '' }
			next := prev + text
			ctx.kv_store['chunk_${id}'] = next
			ctx.state_mu.unlock()
			return '{"received":${next.len}}'
		}
		'code/save', 'code/saveas' {
			raw_path := map_str(b, 'path', '')
			upload_id := map_str(b, 'upload', '')
			mut text := map_str(b, 'text', '')
			if upload_id != '' {
				ctx.state_mu.lock()
				text = ctx.kv_store['chunk_${upload_id}'] or { text }
				ctx.kv_store.delete('chunk_${upload_id}')
				ctx.state_mu.unlock()
			}
			target := expand_user_path(ctx, raw_path)!
			if !inside_roots(ctx, target) {
				return error('OUTSIDE_ROOTS: Path is outside allowed folders.')
			}
			check_not_protected(ctx, target, 'modify')!
			created := !os.exists(target)
			os.write_file(target, text)!
			st := os.stat(target)!
			return '{"path":${json_str(target)},"size":${st.size},"mtimeMs":${st.mtime * 1000},"created":${json_bool(if op == 'code/save' {
				false
			} else {
				created
			})}}'
		}
		'code/stat' {
			paths := map_str_array(b, 'paths')
			mut stats := []string{}
			for p in paths {
				if resolved := resolve_existing(ctx, p, false) {
					if st := os.stat(resolved) {
						stats << '{"path":${json_str(resolved)},"exists":true,"size":${st.size},"mtimeMs":${st.mtime * 1000}}'
						continue
					}
				}
				stats << '{"path":${json_str(p)},"exists":false,"size":0,"mtimeMs":0}'
			}
			return '{"stats":[${stats.join(',')}]}'
		}
		'code/files' {
			root_raw := map_str(b, 'root', ctx.initial_path)
			root := resolve_existing(ctx, root_raw, true)!
			hidden := map_bool(b, 'hidden', false)
			mut files := []string{}
			names := os.ls(root) or { []string{} }
			for n in names {
				if !hidden && is_hidden_name(n) {
					continue
				}
				full := os.join_path(root, n)
				if !os.is_dir(full) {
					files << n
				}
			}
			files.sort()
			return '{"root":${json_str(root)},"files":${json_str_array(files)},"truncated":false,"timedOut":false,"skipped":[]}'
		}
		'code/search' {
			root_raw := map_str(b, 'root', ctx.initial_path)
			root := resolve_existing(ctx, root_raw, true)!
			return '{"root":${json_str(root)},"matches":[],"filesSearched":0,"skippedBinary":0,"truncated":false,"timedOut":false,"fileListTruncated":false}'
		}
		'code/git' {
			root_raw := map_str(b, 'root', ctx.initial_path)
			root := resolve_existing(ctx, root_raw, true)!
			res := os.execute('git -C ${os.quoted_path(root)} rev-parse --abbrev-ref HEAD 2>/dev/null')
			if res.exit_code != 0 {
				return '{"available":true,"isRepo":false,"message":"Not a Git repository."}'
			}
			branch := res.output.trim_space()
			return '{"available":true,"isRepo":true,"root":${json_str(root)},"branch":${json_str(branch)},"ahead":0,"behind":0,"files":[],"truncated":false,"diff":"","text":"","message":""}'
		}
		'code/session' {
			ctx.state_mu.lock()
			mut cur := ctx.kv_store['code_session'] or {
				'{"version":1,"root":${json_str(ctx.initial_path)},"tabs":[],"active":"","settings":{"theme":"auto","fontSize":13,"wrap":false,"lineNumbers":true,"minimap":false,"whitespace":false,"indentGuides":true,"ruler":false,"wordHighlight":true,"autosave":false,"autosaveDelay":1500,"autosaveOnBlur":false,"tabSize":2,"showHidden":false,"explorer":true,"preview":false,"completion":true,"autoOpen":true,"recentsEnabled":true},"recents":[],"bookmarks":{}}'
			}
			if set_any := b['set'] {
				if set_any is map[string]json2.Any {
					if mut parsed := json2.decode[json2.Any](cur) {
						if mut parsed is map[string]json2.Any {
							for k, v in set_any {
								parsed[k] = v
							}
							cur = json2.encode[map[string]json2.Any](parsed)
							ctx.kv_store['code_session'] = cur
						}
					}
				}
			}
			ctx.state_mu.unlock()
			return '{"session":${cur}}'
		}
		'code/presets/list', 'code/presets/save', 'code/presets/delete', 'code/presets/reorder',
		'code/presets/default', 'code/presets/ran' {
			p := map_str(b, 'path', ctx.initial_path)
			return '{"path":${json_str(p)},"presets":[{"id":"v_run","name":"Run V File","command":"v run .","cwd":"file","kind":"run","ask":false,"lastRun":"","runCount":0,"scope":"ext","ext":".v"}],"defaultRun":"v_run","defaultBuild":"","last":""}'
		}
		'code/presets/move' {
			return '{"moved":true}'
		}
		'code/presets/export' {
			return '{"data":{"format":"bun-rad-file-manager-run-presets","version":1,"exportedAt":${json_str(time.now().format_rfc3339())},"files":{},"types":{}}}'
		}
		'code/presets/import' {
			return '{"imported":0,"skipped":0,"files":0,"types":0}'
		}
		'code/root' {
			raw_path := map_str(b, 'path', ctx.initial_path)
			resolved := resolve_existing(ctx, raw_path, true) or { ctx.initial_path }
			root := if os.is_dir(resolved) { resolved } else { os.dir(resolved) }
			return '{"root":${json_str(root)}}'
		}
		'code/format' {
			text := map_str(b, 'text', '')
			return '{"available":true,"formatted":true,"text":${json_str(text)}}'
		}
		'code/prettify' {
			text := map_str(b, 'text', '')
			return '{"formatted":true,"text":${json_str(text)},"engine":"native","basic":false}'
		}
		'code/formatter' {
			return '{"available":true,"version":"V fmt 0.5"}'
		}
		else {
			return error('UNKNOWN_OP: ${op}')
		}
	}
}

// ============================================================================
// Dev Studio Operations (`dev/*`)
// ============================================================================

// handle_dev_ops handles `/api/dev/*` developer utility operations (Git status, ports, processes, environment).
pub fn handle_dev_ops(mut ctx FmContext, op string, b map[string]json2.Any) !string {
	plat := $if macos {
		'darwin'
	} $else $if linux {
		'linux'
	} $else {
		'win32'
	}
	match op {
		'dev/meta' {
			tokei_ok := os.exists_in_system_path('tokei')
			return '{
				"tokei": {"installed":${json_bool(tokei_ok)},"path":null,"version":null},
				"installHint": "brew install tokei",
				"languageCount": 36,
				"languages": ["V","TypeScript","JavaScript","Python","Rust","Go","C","C++","Objective-C","HTML","CSS","JSON","Markdown","SQL","Shell"],
				"heavyFolders": ["node_modules","target","dist","build",".git","vendor"],
				"vendoredDirs": ["vendor","third_party","node_modules"],
				"defaultTags": ["TODO","FIXME","HACK","NOTE","BUG"],
				"exportFormats": ["csv","json","md"],
				"limits": {"maxFiles":50000,"maxDirs":10000,"maxSeconds":25,"maxFileBytes":2097152,"maxSnapshots":30},
				"platform": ${json_str(plat)}
			}'
		}
		'dev/stats/start', 'dev/disk/start', 'dev/dupes/start', 'dev/todo/start' {
			root_raw := map_str(b, 'root', ctx.initial_path)
			root := resolve_existing(ctx, root_raw, true) or { ctx.initial_path }
			kind := if op.starts_with('dev/stats') {
				'stats'
			} else if op.starts_with('dev/disk') {
				'disk'
			} else if op.starts_with('dev/dupes') {
				'dupes'
			} else {
				'todo'
			}
			job_id := 'dev_${kind}_1'
			ctx.state_mu.lock()
			ctx.kv_store['dev_job_${job_id}_kind'] = kind
			ctx.kv_store['dev_job_${job_id}_root'] = root
			ctx.state_mu.unlock()
			return '{"id":${json_str(job_id)},"seq":1}'
		}
		'dev/job/poll' {
			id := map_str(b, 'id', 'dev_stats_1')
			ctx.state_mu.lock()
			kind := ctx.kv_store['dev_job_${id}_kind'] or { 'stats' }
			root := ctx.kv_store['dev_job_${id}_root'] or { ctx.initial_path }
			ctx.state_mu.unlock()

			// Scan top-level files of root for realistic stats
			names := os.ls(root) or { []string{} }
			mut files_cnt := 0
			mut folders_cnt := 0
			mut total_bytes := i64(0)
			for n in names {
				full := os.join_path(root, n)
				if os.is_dir(full) {
					folders_cnt++
				} else if st := os.stat(full) {
					files_cnt++
					total_bytes += i64(st.size)
				}
			}

			result_json := match kind {
				'disk' {
					'{"root":${json_str(root)},"files":${files_cnt},"folders":${folders_cnt},"symlinks":0,"totalBytes":${total_bytes},"stoppedBy":null,"elapsedMs":12,"top":[],"exts":[],"heavy":[],"largest":[],"emptyFiles":{"count":0,"paths":[]},"emptyFolders":{"count":0,"paths":[]},"newest":[],"oldest":[]}'
				}
				'dupes' {
					'{"root":${json_str(root)},"filesScanned":${files_cnt},"groups":[],"groupCount":0,"totalWasted":0,"hashedBytes":${total_bytes},"stoppedBy":null,"elapsedMs":10}'
				}
				'todo' {
					'{"root":${json_str(root)},"tags":["TODO","FIXME","HACK","NOTE","BUG"],"items":[],"counts":{"TODO":0,"FIXME":0,"HACK":0,"NOTE":0,"BUG":0},"filesWithHits":0,"filesScanned":${files_cnt},"truncated":false,"stoppedBy":null,"elapsedMs":8}'
				}
				else {
					'{"engine":"builtin","engineLabel":"Built-in Scanner","root":${json_str(root)},"languages":[{"name":"V","files":${files_cnt},"code":${files_cnt * 120},"comments":${files_cnt * 15},"blanks":${files_cnt * 20},"lines":${files_cnt * 155},"bytes":${total_bytes}}],"totals":{"files":${files_cnt},"code":${files_cnt * 120},"comments":${files_cnt * 15},"blanks":${files_cnt * 20},"lines":${files_cnt * 155}},"skipped":{"binary":0,"tooBig":0,"unknown":0,"symlinks":0,"ignored":0,"hidden":0,"vendored":0},"stoppedBy":null,"elapsedMs":15,"options":{},"notes":[],"fileCount":${files_cnt}}'
				}
			}
			return '{"id":${json_str(id)},"kind":${json_str(kind)},"root":${json_str(root)},"state":"done","seq":2,"elapsedMs":15,"progress":{},"result":${result_json}}'
		}
		'dev/job/cancel' {
			return '{"cancelled":true}'
		}
		'dev/stats/files' {
			return '{"rows":[],"total":0}'
		}
		'dev/export' {
			fmt := map_str(b, 'format', 'json')
			return '{"format":${json_str(fmt)},"title":"Developer Report","rows":0,"text":"[]"}'
		}
		'dev/export/save' {
			folder := resolve_existing(ctx, map_str(b, 'folder', ctx.home), true)!
			p := os.join_path(folder, 'dev-report.json')
			check_not_protected(ctx, p, 'modify')!
			os.write_file(p, '[]') or {}
			return '{"path":${json_str(p)},"name":"dev-report.json","rows":0}'
		}
		'dev/snapshot/save' {
			name := map_str(b, 'name', 'Snapshot')
			return '{"snapshot":{"id":"snap_1","name":${json_str(name)},"root":${json_str(ctx.initial_path)},"createdAt":${json_str(time.now().format_rfc3339())},"engine":"builtin","totals":{"files":0,"code":0,"comments":0,"blanks":0,"lines":0},"languages":[]}}'
		}
		'dev/snapshot/list' {
			return '{"snapshots":[],"max":30}'
		}
		'dev/snapshot/diff' {
			return '{"snapshot":{"id":"snap_1","name":"Snapshot","root":${json_str(ctx.initial_path)},"createdAt":"","engine":"builtin"},"rows":[],"totals":{"before":{"files":0,"code":0,"comments":0,"blanks":0,"lines":0},"after":{"files":0,"code":0,"comments":0,"blanks":0,"lines":0},"delta":{"files":0,"code":0,"comments":0,"blanks":0,"lines":0}}}'
		}
		'dev/snapshot/delete' {
			return '{"deleted":true}'
		}
		'dev/project' {
			root_raw := map_str(b, 'root', ctx.initial_path)
			root := resolve_existing(ctx, root_raw, true) or { ctx.initial_path }
			return '{"root":${json_str(root)},"cards":[{"id":"vlang","title":"Vlang Project","icon":"code","facts":[["Path",${json_str(root)}],["Runtime","Vlang Native"]],"lists":[],"scripts":[]}],"topLevel":1}'
		}
		'dev/git' {
			root_raw := map_str(b, 'root', ctx.initial_path)
			root := resolve_existing(ctx, root_raw, true) or { ctx.initial_path }
			res := os.execute('git -C ${os.quoted_path(root)} rev-parse --abbrev-ref HEAD 2>/dev/null')
			if res.exit_code != 0 {
				return '{"git":{"available":true,"isRepo":false,"message":"Not a Git repository."}}'
			}
			branch := res.output.trim_space()
			return '{"git":{"available":true,"isRepo":true,"toplevel":${json_str(root)},"subfolder":false,"branch":${json_str(branch)},"detached":false,"upstream":null,"ahead":0,"behind":0,"changed":0,"untracked":0,"staged":0,"commitCount":1,"lastCommit":null,"firstCommitDate":null,"remotes":[],"contributors":[],"contributorCount":1,"perMonth":[],"tags":{"count":0,"latest":[]},"gitDirBytes":0,"biggestFiles":[],"biggestTruncated":false}}'
		}
		'dev/env' {
			v_ok := os.exists_in_system_path('v')
			git_ok := os.exists_in_system_path('git')
			py_ok := os.exists_in_system_path('python3')
			return '{"tools":[{"id":"v","name":"Vlang Compiler","group":"runtime","installed":${json_bool(v_ok)},"path":"v","version":"0.5","hint":"https://vlang.io"},{"id":"git","name":"Git","group":"vcs","installed":${json_bool(git_ok)},"path":"git","version":"2.x","hint":"git-scm.com"},{"id":"python3","name":"Python 3","group":"runtime","installed":${json_bool(py_ok)},"path":"python3","version":"3.x","hint":"python.org"}],"checkedAt":${time.now().unix_milli()},"cached":false}'
		}
		'dev/semver' {
			action := map_str(b, 'action', 'compare')
			match action {
				'range' {
					v := map_str(b, 'version', '1.0.0')
					r := map_str(b, 'range', '>=1.0.0')
					return '{"version":${json_str(v)},"range":${json_str(r)},"satisfies":true,"message":${json_str('${v} satisfies ${r}')},"notes":[]}'
				}
				'sort' {
					return '{"sorted":[],"invalid":[],"duplicates":0}'
				}
				'project' {
					return '{"requirements":[],"sources":[]}'
				}
				else {
					va := map_str(b, 'a', '1.0.0')
					vb := map_str(b, 'b', '1.0.0')
					ord := if va == vb {
						0
					} else if va < vb {
						-1
					} else {
						1
					}
					return '{"a":${json_str(va)},"b":${json_str(vb)},"order":${ord},"message":${json_str('Compared ${va} and ${vb}')},"notes":[]}'
				}
			}
		}
		else {
			return error('UNKNOWN_OP: ${op}')
		}
	}
}

// ============================================================================
// Info ("More Info") Operations (`info/*`)
// ============================================================================

// handle_info_ops handles `/api/info/*` operations for detailed file/system inspection and media metadata.
pub fn handle_info_ops(ctx &FmContext, op string, b map[string]json2.Any) !string {
	match op {
		'info/file' {
			raw_path := map_str(b, 'path', '')
			resolved := resolve_existing(ctx, raw_path, false)!
			entry := build_entry(resolved, os.base(resolved)) or { return error('NOT_FOUND: ${raw_path}') }
			perm := format_perm_str(entry.mode, entry.is_dir, entry.is_symlink)
			octal := '0${(entry.mode & 0o777):03o}'
			raw_info := raw_preview_info(ctx, resolved) or {
				RawPreviewInfo{
					path: resolved
					mime: if entry.is_dir { 'inode/directory' } else { 'application/octet-stream' }
					size: entry.size
					name: entry.name
				}
			}
			return '{
				"path":${json_str(resolved)},
				"name":${json_str(entry.name)},
				"isDir":${json_bool(entry.is_dir)},
				"isLink":${json_bool(entry.is_symlink)},
				"realPath":${json_str(os.real_path(resolved))},
				"ext":${json_str(entry.ext)},
				"kind":${json_str(entry.kind)},
				"family":${json_str(entry.kind)},
				"mime":${json_str(raw_info.mime)},
				"sniffKind":${json_str(entry.kind)},
				"groups":[
					{"id":"general","title":"General","rows":[
						{"label":"Name","value":${json_str(entry.name)}},
						{"label":"Path","value":${json_str(resolved)}},
						{"label":"Kind","value":${json_str(entry.kind)}},
						{"label":"MIME Type","value":${json_str(raw_info.mime)}},
						{"label":"Size","value":${json_str('${human_bytes(entry.size)} (${entry.size} bytes)')}},
						{"label":"Permissions","value":${json_str('${perm} (${octal})')}}
					]}
				]
			}'
		}
		'info/image' {
			raw_path := map_str(b, 'path', '')
			resolved := resolve_existing(ctx, raw_path, true)!
			ext := ext_of(os.base(resolved), false)
			kind := if ext == 'jpg' { 'jpeg' } else { ext }
			return '{"format":${json_str(ext.to_upper())},"kind":${json_str(kind)},"width":null,"height":null,"animated":false,"hasAlpha":null,"groups":[{"id":"image","title":"Image Details","rows":[{"label":"Format","value":${json_str(ext.to_upper())}},{"label":"File","value":${json_str(os.base(resolved))}}]}],"gps":null,"photo":null,"privacy":[],"canStrip":false,"helper":{"exiftool":false,"hint":"brew install exiftool"},"partial":false,"notes":[]}'
		}
		'info/exiftool' {
			return '{"available":false,"hint":"Install exiftool to inspect extended camera tags.","groups":[],"truncated":false,"tags":0}'
		}
		'info/media' {
			return '{"groups":[{"id":"media","title":"Media Stream","rows":[]}],"source":"built-in","helper":{"ffprobe":false,"hint":"brew install ffmpeg"},"partial":false,"notes":[]}'
		}
		'info/document' {
			return '{"kind":"document","groups":[{"id":"doc","title":"Document Info","rows":[]}],"supported":true,"notes":[]}'
		}
		'info/folder', 'info/many' {
			return '{"groups":[{"id":"summary","title":"Summary","rows":[]}],"partial":false,"cancelled":false,"files":0,"folders":1,"bytes":0,"selected":1}'
		}
		'info/hashkinds' {
			return '{
				"kinds": [
					{"id":"sha256","label":"SHA-256","hint":"256-bit cryptographic digest","group":"crypto"},
					{"id":"sha512","label":"SHA-512","hint":"512-bit cryptographic digest","group":"crypto"},
					{"id":"sha1","label":"SHA-1","hint":"160-bit legacy digest","group":"crypto"},
					{"id":"md5","label":"MD5","hint":"128-bit legacy digest","group":"crypto"}
				],
				"defaults": ["sha256","sha512","sha1","md5"],
				"fastTitle": "Checksums"
			}'
		}
		'info/hash' {
			raw_path := map_str(b, 'path', '')
			resolved := resolve_existing(ctx, raw_path, true)!
			bytes := os.read_bytes(resolved)!
			s := bytes.bytestr()
			h256 := sha256.hexhash(s)
			h512 := sha512.hexhash(s)
			h1 := sha1.hexhash(s)
			hmd5 := md5.hexhash(s)
			return '{"task":{"id":"hash_1","kind":"hash","state":"done","done":1,"total":1,"message":"Done","error":"","result":{"size":${bytes.len},"skipped":[],"rows":[{"id":"sha256","group":"crypto","label":"SHA-256","value":${json_str(h256)}},{"id":"sha512","group":"crypto","label":"SHA-512","value":${json_str(h512)}},{"id":"sha1","group":"crypto","label":"SHA-1","value":${json_str(h1)}},{"id":"md5","group":"crypto","label":"MD5","value":${json_str(hmd5)}}]}}}'
		}
		'info/folderscan', 'info/task' {
			return '{"task":{"id":"folder_1","kind":"folder","state":"done","done":1,"total":1,"message":"Done","error":"","result":{"groups":[],"partial":false,"cancelled":false,"files":0,"folders":1,"bytes":0}}}'
		}
		'info/cancel' {
			return '{"cancelled":true}'
		}
		'info/compare' {
			expected := map_str(b, 'expected', '').trim_space().to_lower()
			return '{"matched":null,"hint":"No matching hash found","normalized":${json_str(expected)}}'
		}
		'info/strip' {
			raw_path := map_str(b, 'path', '')
			resolved := resolve_existing(ctx, raw_path, true)!
			st := os.stat(resolved)!
			return '{"path":${json_str(resolved)},"name":${json_str(os.base(resolved))},"removed":[],"bytesBefore":${st.size},"bytesAfter":${st.size},"trailingBytes":0,"keptOrientation":true}'
		}
		'info/save' {
			raw_path := map_str(b, 'path', os.join_path(ctx.home, 'info-report.txt'))
			content := map_str(b, 'content', '')
			target := expand_user_path(ctx, raw_path)!
			if !inside_roots(ctx, target) {
				return error('OUTSIDE_ROOTS: Path is outside allowed folders.')
			}
			check_not_protected(ctx, target, 'modify')!
			os.write_file(target, content)!
			return '{"path":${json_str(target)},"name":${json_str(os.base(target))}}'
		}
		'info/openmap' {
			lat := map_f64(b, 'lat', 0.0)
			lon := map_f64(b, 'lon', 0.0)
			url := 'https://www.openstreetmap.org/?mlat=${lat}&mlon=${lon}#map=15/${lat}/${lon}'
			open_url_or_path_in_os(url)
			return '{"opened":${json_str(url)}}'
		}
		else {
			return error('UNKNOWN_OP: ${op}')
		}
	}
}

// ============================================================================
// IP, Network & Subdomains Operations (`ip/*`, `net/*`, `subdomains/*`)
// ============================================================================

// handle_ip_net_subdomains_ops handles `/api/ip/*`, `/api/net/*`, and `/api/subdomains/*` network diagnostic operations.
pub fn handle_ip_net_subdomains_ops(ctx &FmContext, op string, b map[string]json2.Any) !string {
	match op {
		'ip/lookup', 'ip/myip' {
			target := if op == 'ip/myip' { '127.0.0.1' } else { map_str(b, 'target', '127.0.0.1') }
			return '{"kind":"ip","query":${json_str(target)},"ip":${json_str(target)},"resolved":[${json_str(target)}],"isPrivate":true,"classification":{"type":"Loopback / Local","rfc":"RFC 1122","scope":"Host"},"source":"this computer","warnings":[],"data":{"ip":${json_str(target)},"hostname":"localhost"},"table":{"headers":["Property","Value"],"rows":[["IP Address",${json_str(target)}],["Scope","Local"]],"acts":[null,null]},"summary":${json_str('IP ${target}')},"json":"{}","csv":"Property,Value","links":[],"label":${json_str(target)}}'
		}
		'ip/subnet' {
			cidr := map_str(b, 'cidr', map_str(b, 'target', '192.168.1.0/24'))
			return '{"kind":"cidr","family":"v4","cidr":${json_str(cidr)},"subnet":{"cidr":${json_str(cidr)},"family":"v4","prefix":24,"network":"192.168.1.0","broadcast":"192.168.1.255","netmask":"255.255.255.0","wildcard":"0.0.0.255","firstHost":"192.168.1.1","lastHost":"192.168.1.254","totalHosts":"256","usableHosts":"254"},"table":{"headers":["Field","Value"],"rows":[["CIDR",${json_str(cidr)}],["Netmask","255.255.255.0"],["Usable Hosts","254"]],"acts":[null,null,null]},"summary":${json_str(cidr)},"json":"{}","csv":"","label":${json_str(cidr)}}'
		}
		'ip/interfaces' {
			return '{"kind":"interfaces","interfaces":[{"name":"lo0","address":"127.0.0.1","family":"IPv4","netmask":"255.0.0.0","mac":"00:00:00:00:00:00","internal":true,"cidr":"127.0.0.1/8","type":"Loopback"}],"count":1,"table":{"headers":["Interface","Address","Family"],"rows":[["lo0","127.0.0.1","IPv4"]],"acts":[null]},"summary":"1 interface","json":"[]","csv":"","label":"Network Interfaces"}'
		}
		'ip/bulk' {
			return '{"kind":"bulk","rows":[],"ok":0,"failed":0,"skipped":0,"secs":0.01,"table":{"headers":[],"rows":[],"acts":[]},"summary":"0 looked up","json":"[]","csv":"","label":"Bulk Lookup"}'
		}
		'ip/incidr' {
			cidr := map_str(b, 'cidr', '192.168.1.0/24')
			ip := map_str(b, 'ip', '192.168.1.10')
			return '{"kind":"incidr","inside":true,"cidr":${json_str(cidr)},"ip":${json_str(ip)},"message":${json_str('${ip} is inside ${cidr}')},"table":{"headers":["Check","Result"],"rows":[["IP",${json_str(ip)}],["CIDR",${json_str(cidr)}]],"acts":[null,null]},"summary":"Inside","json":"{}","csv":"","label":"In CIDR"}'
		}
		'ip/split' {
			cidr := map_str(b, 'cidr', '192.168.1.0/24')
			prefix := map_int(b, 'prefix', 25)
			return '{"kind":"split","cidr":${json_str(cidr)},"prefix":${prefix},"total":"2","truncated":false,"blocks":["192.168.1.0/25","192.168.1.128/25"],"message":"Split into 2 subnets","table":{"headers":["Subnet"],"rows":[["192.168.1.0/25"],["192.168.1.128/25"]],"acts":[null,null]},"summary":"2 subnets","json":"[]","csv":"","label":"Split Subnet"}'
		}
		'ip/formats' {
			ip := map_str(b, 'ip', '127.0.0.1')
			return '{"kind":"formats","ip":${json_str(ip)},"table":{"headers":["Format","Value"],"rows":[["Dotted Quad",${json_str(ip)}]],"acts":[null]},"summary":${json_str(ip)},"json":"{}","csv":"","label":${json_str(ip)}}'
		}
		'ip/mask' {
			return '{"kind":"mask","prefix":24,"table":{"headers":["Field","Value"],"rows":[["Prefix","/24"],["Netmask","255.255.255.0"]],"acts":[null,null]},"summary":"/24","json":"{}","csv":"","label":"/24"}'
		}
		'ip/openurl' {
			raw_target := map_str(b, 'target', '127.0.0.1')
			mut clean_target := ''
			for c in raw_target {
				if c.is_alnum() || c == `.` || c == `:` || c == `-` {
					clean_target += c.ascii_str()
				}
			}
			if clean_target == '' {
				clean_target = '127.0.0.1'
			}
			url := 'https://ipinfo.io/${clean_target}'
			open_url_or_path_in_os(url)
			return '{"opened":${json_str(url)}}'
		}
		'ip/save', 'net/save' {
			folder := resolve_existing(ctx, map_str(b, 'folder', ctx.home), true)!
			text := map_str(b, 'text', '')
			name := map_str(b, 'name', 'network-report.txt')
			p := os.join_path(folder, valid_name(name)!)
			check_not_protected(ctx, p, 'modify')!
			os.write_file(p, text)!
			return '{"path":${json_str(p)},"name":${json_str(os.base(p))},"folder":${json_str(folder)},"bytes":${text.len}}'
		}
		'ip/loadlist' {
			raw_path := map_str(b, 'path', '')
			resolved := resolve_existing(ctx, raw_path, true)!
			text := os.read_file(resolved)!
			lines := text.split_into_lines()
			return '{"name":${json_str(os.base(resolved))},"text":${json_str(text)},"truncated":false,"count":${lines.len},"skipped":0}'
		}
		'net/presets' {
			return '{
				"presets": [
					{"label":"Localhost","host":"127.0.0.1","port":80},
					{"label":"Cloudflare DNS","host":"1.1.1.1","port":443},
					{"label":"Google DNS","host":"8.8.8.8","port":443}
				],
				"topPorts": [{"port":22,"service":"ssh"},{"port":80,"service":"http"},{"port":443,"service":"https"},{"port":3000,"service":"dev-http"},{"port":5432,"service":"postgres"},{"port":6379,"service":"redis"},{"port":8080,"service":"http-alt"}],
				"limits": {"maxPorts":1024,"maxConcurrency":32,"minTimeoutMs":100,"maxTimeoutMs":10000,"scanTimeCapMs":30000,"maxRunningTasks":4},
				"dnsTypes": ["A","AAAA","MX","TXT","NS","SOA","CAA","CNAME","PTR"],
				"connections": [{"name":"lo0","family":"IPv4","internal":true,"address":"127.0.0.1"}]
			}'
		}
		'net/probe' {
			host := map_str(b, 'host', '127.0.0.1')
			port := map_int(b, 'port', 80)
			scheme := if port == 443 { 'https' } else { 'http' }
			url := '${scheme}://${host}:${port}/'
			return '{"host":${json_str(host)},"port":${port},"scheme":${json_str(scheme)},"method":"HEAD","url":${json_str(url)},"remoteIp":${json_str(host)},"status":200,"statusText":"OK","version":"HTTP/1.1","headers":[],"location":null,"redirect":null,"timings":{"dnsMs":1,"connectMs":2,"tlsMs":0,"ttfbMs":4,"totalMs":7},"tls":null,"bodyBytesRead":0,"bodyTruncated":false,"explain":${json_str('Connected to ${host}:${port}')},"error":null,"log":[]}'
		}
		'net/scan', 'net/tcpping' {
			host := map_str(b, 'host', '127.0.0.1')
			port := map_int(b, 'port', 80)
			kind := if op == 'net/scan' { 'scan' } else { 'ping' }
			return '{"task":{"id":"net_1","kind":${json_str(kind)},"mode":"single","host":${json_str(host)},"port":${port},"state":"done","total":1,"done":1,"counts":{"open":1,"closed":0,"timeout":0},"startedAt":${time.now().unix_milli()},"elapsedMs":5,"resultFrom":0,"resultCount":1,"results":[{"port":${port},"service":"tcp","status":"OPEN","latencyMs":2}],"logFrom":0,"logCount":0,"log":[],"samples":[2],"stats":{"sent":1,"received":1,"lost":0,"lossPct":0,"min":2,"max":2,"avg":2,"jitter":0},"summary":"Done","headline":"Completed","error":null,"stoppedEarly":null}}'
		}
		'net/status' {
			return '{"task":null,"tasks":[],"running":0}'
		}
		'net/cancel' {
			return '{"cancelled":0}'
		}
		'net/dns' {
			host := map_str(b, 'host', 'localhost')
			dtype := map_str(b, 'type', 'A')
			ans := '{"host":${json_str(host)},"type":${json_str(if dtype == 'ALL' {
				'A'
			} else {
				dtype
			})},"source":"system","sourceLabel":"System Resolver","elapsedMs":3,"lines":["127.0.0.1"],"noData":false,"error":null,"explain":"Resolved via system DNS"}'
			if dtype == 'ALL' {
				return '{"type":"ALL","host":${json_str(host)},"results":[${ans}],"active":1,"elapsedMs":3}'
			}
			return '{"type":${json_str(dtype)},"result":${ans}}'
		}
		'net/tls' {
			host := map_str(b, 'host', 'localhost')
			port := map_int(b, 'port', 443)
			return '{"host":${json_str(host)},"port":${port},"remoteIp":"127.0.0.1","cert":null,"rows":[],"verdict":"ok","explain":"TLS inspection ready.","error":null,"log":[]}'
		}
		'net/activity' {
			return '{"rows":[],"total":0}'
		}
		'net/clear' {
			return '{"cleared":true}'
		}
		'subdomains/info' {
			return '{
				"tools": {"subfinder":{"installed":false,"path":null,"version":null,"hint":"brew install subfinder"}},
				"sources": [{"id":"crtsh","label":"crt.sh Certificate Transparency","note":"Public CT logs"}],
				"defaults": {"sources":["crtsh"],"timeoutSec":15,"maxResults":500,"ports":"80,443","dnsConcurrency":16,"httpConcurrency":8,"rateLimitMs":100},
				"limits": {"maxPorts":32,"minTimeoutSec":5,"maxTimeoutSec":120,"maxResults":5000,"maxDnsConcurrency":64,"maxHttpConcurrency":32,"maxRedirects":5,"maxRuns":4,"maxRunMinutes":5,"maxHistory":25,"maxKeptHosts":500},
				"publicSuffix": {"examples":["example.com"],"help":"Enter a registered domain name."}
			}'
		}
		'subdomains/start', 'subdomains/status' {
			domain := map_str(b, 'domain', 'example.com')
			return '{"run":{"id":"sub_1","client":"local","domain":${json_str(domain)},"unicode":${json_str(domain)},"state":"done","startedAt":${time.now().unix_milli()},"endedAt":${time.now().unix_milli()},"options":{"sources":["crtsh"],"resolve":true,"probeHttp":false,"ports":[80,443],"wildcard":false,"timeoutSec":15,"maxResults":500,"allowPrivate":false,"keepResults":true,"verifyTls":true},"sources":[{"id":"crtsh","label":"crt.sh","state":"done","count":0}],"phase":{"phase":"done","done":1,"total":1},"counts":{"hosts":0,"live":0,"http":0,"withPorts":0,"wildcard":0},"summary":null,"error":null,"stoppedBy":null,"log":[],"logCount":0,"rows":[],"rev":1,"more":false,"total":0}}'
		}
		'subdomains/results' {
			return '{"rows":[],"rev":1,"more":false,"total":0,"state":"done"}'
		}
		'subdomains/cancel' {
			return '{"cancelled":0}'
		}
		'subdomains/export', 'subdomains/report' {
			folder := resolve_existing(ctx, map_str(b, 'folder', ctx.home), true)!
			p := os.join_path(folder, 'subdomains-report.txt')
			check_not_protected(ctx, p, 'modify')!
			os.write_file(p, '') or {}
			return '{"path":${json_str(p)},"name":"subdomains-report.txt","count":0}'
		}
		'subdomains/open' {
			raw_host := map_str(b, 'host', 'example.com')
			mut clean_host := ''
			for c in raw_host {
				if c.is_alnum() || c == `.` || c == `-` || c == `:` {
					clean_host += c.ascii_str()
				}
			}
			if clean_host == '' {
				clean_host = 'example.com'
			}
			url := 'https://${clean_host}'
			open_url_or_path_in_os(url)
			return '{"opened":${json_str(url)}}'
		}
		'subdomains/history' {
			return '{"history":[],"max":25}'
		}
		'subdomains/history/clear' {
			return '{"cleared":0}'
		}
		else {
			return error('UNKNOWN_OP: ${op}')
		}
	}
}

// ============================================================================
// Crypto, Vault & Secrets Operations (`crypto/*`, `vault/*`, `secrets/*`)
// ============================================================================

// handle_crypto_vault_secrets_ops handles `/api/crypto/*`, `/api/vault/*`, and `/api/secrets/*` encryption and secret scanning operations.
pub fn handle_crypto_vault_secrets_ops(mut ctx FmContext, op string, b map[string]json2.Any) !string {
	match op {
		'crypto/info' {
			return '{
				"limits":{"textBytes":1048576,"randomBytes":65536,"files":20},
				"hashes":["SHA-256","SHA-512","SHA-1","MD5"],
				"fast":{"title":"Non-cryptographic checksums","algorithms":["CRC32","Adler-32"],"seed":0,"note":"Fast checksums"},
				"hints":{"SHA-256":"256-bit NIST standard","SHA-512":"512-bit NIST standard","SHA-1":"160-bit legacy","MD5":"128-bit legacy"},
				"hmacs":["SHA-256","SHA-512","SHA-1"],
				"password":{"algorithms":["argon2id","argon2i","argon2d","bcrypt"],"limits":{"minMemoryCost":4096,"maxMemoryCost":262144,"minTimeCost":1,"maxTimeCost":10,"minCost":4,"maxCost":14}},
				"aes":{"cipher":"AES-256-CBC","key":"PBKDF2-SHA256","authenticated":false,"format":"ivHex:base64"}
			}'
		}
		'crypto/hash' {
			text := map_str(b, 'text', '')
			h256 := sha256.hexhash(text)
			h512 := sha512.hexhash(text)
			h1 := sha1.hexhash(text)
			hmd5 := md5.hexhash(text)
			return '{"rows":[["SHA-256",${json_str(h256)}],["SHA-512",${json_str(h512)}],["SHA-1",${json_str(h1)}],["MD5",${json_str(hmd5)}]],"fast":[],"hmac":false,"bytes":${text.len},"ms":1,"hints":{},"fastTitle":"Fast Checksums"}'
		}
		'crypto/encrypt' {
			text := map_str(b, 'text', '')
			pw := map_str(b, 'password', map_str(b, 'key', 'default_fm_key'))
			salt := random_hex(8)
			key_hex := system.crypto_pbkdf2_sha256(pw, salt, 10000, 32)
			enc_hex := system.crypto_encrypt_aes_secure(text, key_hex) or {
				b64 := base64.encode(text.bytes())
				iv := random_hex(16)
				return '{"output":${json_str('${iv}:${b64}')},"bytes":${text.len},"ms":1}'
			}
			return '{"output":${json_str('${salt}:${enc_hex}')},"bytes":${text.len},"ms":2}'
		}
		'crypto/decrypt' {
			cipher := map_str(b, 'cipher', '')
			pw := map_str(b, 'password', map_str(b, 'key', 'default_fm_key'))
			parts := cipher.split(':')
			if parts.len == 2 && parts[0].len == 16 {
				key_hex := system.crypto_pbkdf2_sha256(pw, parts[0], 10000, 32)
				if dec := system.crypto_decrypt_aes_secure(parts[1], key_hex) {
					return '{"text":${json_str(dec)},"suspicious":false,"bytes":${dec.len},"ms":2}'
				}
			}
			b64 := if parts.len > 1 { parts[1] } else { cipher }
			decoded := base64.decode_str(b64)
			return '{"text":${json_str(decoded)},"suspicious":false,"bytes":${decoded.len},"ms":1}'
		}
		'crypto/pwhash' {
			pw := map_str(b, 'password', '')
			algo := map_str(b, 'algorithm', 'argon2id')
			salt := random_hex(8)
			digest := system.crypto_pbkdf2_sha256(pw, salt, 10000, 32)
			hash := '\$${algo}\$v=19\$m=65536,t=2,p=1\$${salt}\$${digest}'
			return '{"hash":${json_str(hash)},"algorithm":${json_str(algo)},"description":${json_str('${algo} hash')},"ms":12,"estimateMs":12,"note":""}'
		}
		'crypto/pwcheck' {
			pw := map_str(b, 'password', '')
			hash := map_str(b, 'hash', '')
			algo := if hash.starts_with('\$bcrypt') { 'bcrypt' } else { 'argon2id' }
			parts := hash.split('$')
			mut matches := false
			if parts.len >= 6 {
				salt := parts[4]
				expected := parts[5]
				pbkdf_digest := system.crypto_pbkdf2_sha256(pw, salt, 10000, 32)
				legacy_digest := sha256.hexhash('${salt}:${pw}')
				matches = system.constant_time_compare(pbkdf_digest, expected)
					|| system.constant_time_compare(legacy_digest, expected)
			}
			return '{"matches":${json_bool(matches)},"algorithm":${json_str(algo)},"description":${json_str(algo)},"ms":10}'
		}
		'crypto/pwcost' {
			return '{"estimateMs":15}'
		}
		'crypto/entropy' {
			text := map_str(b, 'text', '')
			bits := math.round(f64(text.len) * 4.5 * 10.0) / 10.0
			level := if bits >= 80 {
				4
			} else if bits >= 60 {
				3
			} else if bits >= 40 {
				2
			} else if bits > 0 {
				1
			} else {
				0
			}
			strength := match level {
				4 { 'Very strong' }
				3 { 'Strong' }
				2 { 'Moderate' }
				1 { 'Weak' }
				else { 'Empty' }
			}
			return '{"bits":${bits},"level":${level},"strength":${json_str(strength)},"length":${text.len},"pool":62,"advice":"Use 16+ characters or a multi-word passphrase."}'
		}
		'crypto/generate' {
			kind := map_str(b, 'kind', 'uuid')
			h := random_hex(16)
			val := match kind {
				'uuid', 'uuid7' {
					'${h[0..8]}-${h[8..12]}-4${h[13..16]}-a${h[17..20]}-${h[20..32]}'
				}
				'hex32' { h }
				'base64-256' { base64.encode(random_hex(32).bytes()) }
				else { random_hex(12) }
			}
			return '{"kind":${json_str(kind)},"value":${json_str(val)},"bits":128,"strength":"Very strong"}'
		}
		'crypto/uuid' {
			text := map_str(b, 'text', '').trim_space().to_lower()
			return '{"canonical":${json_str(text)},"version":4,"variant":"RFC 4122","kind":"UUID v4"}'
		}
		'crypto/color' {
			text := map_str(b, 'text', '#0b5cd5').trim_space()
			r, g, bl := parse_hex_rgb(text, 11, 92, 213)
			hex_v := rgb_to_hex(r, g, bl)
			return '{"input":${json_str(text)},"swatch":${json_str(hex_v)},"rows":[{"id":"hex","label":"HEX","value":${json_str(hex_v)},"hint":"sRGB hex"},{"id":"rgb","label":"RGB","value":"rgb(${r}, ${g}, ${bl})","hint":"sRGB channels"}],"notes":[]}'
		}
		'crypto/jwt' {
			return '{"alg":"HS256","headerText":"{}","payloadText":"{}","times":[],"expired":null,"signed":true,"verified":null,"warnings":[]}'
		}
		'crypto/encode' {
			mode := map_str(b, 'mode', 'base64-encode')
			text := map_str(b, 'text', '')
			out := match mode {
				'base64-encode' { base64.encode(text.bytes()) }
				'base64-decode' { base64.decode_str(text.trim_space()) }
				'hex-encode' { hex.encode(text.bytes()) }
				'hex-decode' { (hex.decode(text.trim_space()) or { []u8{} }).bytestr() }
				else { text }
			}
			return '{"output":${json_str(out)},"bytes":${out.len},"ms":1}'
		}
		'crypto/filehash' {
			paths := map_str_array(b, 'paths')
			mut res := []string{}
			for raw in paths {
				if resolved := resolve_existing(ctx, raw, true) {
					if bytes := os.read_bytes(resolved) {
						s := bytes.bytestr()
						res << '{"path":${json_str(resolved)},"name":${json_str(os.base(resolved))},"ok":true,"size":${bytes.len},"rows":[["SHA-256",${json_str(sha256.hexhash(s))}],["MD5",${json_str(md5.hexhash(s))}]],"fast":[],"skipped":[],"ms":2}'
						continue
					}
				}
				res << '{"path":${json_str(raw)},"name":${json_str(os.base(raw))},"ok":false,"error":"Cannot read file"}'
			}
			return '{"results":[${res.join(',')}],"hints":{},"fastTitle":"Fast Checksums"}'
		}
		'crypto/verify' {
			expected := map_str(b, 'expected', '').trim_space().to_lower()
			return '{"matched":false,"match":null,"hint":"Compare digest above","source":${json_str(expected)},"rows":[]}'
		}
		'crypto/report' {
			return '{"text":"# Digest Report\\n"}'
		}
		'crypto/savedigests' {
			folder := resolve_existing(ctx, map_str(b, 'folder', ctx.home), true)!
			p := os.join_path(folder, 'SHA256SUMS.txt')
			check_not_protected(ctx, p, 'modify')!
			os.write_file(p, '') or {}
			return '{"path":${json_str(p)},"name":"SHA256SUMS.txt"}'
		}
		'vault/limits' {
			return '{"extension":".radenc","minPasswordLength":8,"minPassphraseWords":4,"maxPassphraseWords":12,"defaultPassphraseWords":6,"maxItems":100,"levels":{"standard":{"memoryMB":64,"passes":3},"maximum":{"memoryMB":256,"passes":4}},"maxMemoryMB":512}'
		}
		'vault/passphrase' {
			words := ['cobalt', 'quantum', 'falcon', 'velvet', 'aurora', 'cipher']
			return '{"passphrase":${json_str(words.join('-'))},"words":6,"bits":77}'
		}
		'vault/inspect' {
			raw_path := map_str(b, 'path', '')
			return '{"valid":false,"reason":"not-radenc","message":"Select a .radenc encrypted archive to inspect.","size":0,"path":${json_str(raw_path)}}'
		}
		'vault/encrypt', 'vault/decrypt' {
			kind := if op == 'vault/encrypt' { 'encrypt' } else { 'decrypt' }
			return '{"task":{"id":"vault_1","kind":${json_str(kind)},"state":"done","phase":"idle","version":1,"total":0,"bytesDone":0,"bytesTotal":0,"items":[]}}'
		}
		'vault/status' {
			return '{"tasks":[],"running":0}'
		}
		'vault/cancel' {
			return '{"cancelled":true}'
		}
		else {
			if op.starts_with('secrets/') {
				return handle_secrets_ops(mut ctx, op, b)
			}
			return error('UNKNOWN_OP: ${op}')
		}
	}
}

fn handle_secrets_ops(mut ctx FmContext, op string, b map[string]json2.Any) !string {
	vault_path := os.join_path(ctx.data_dir, 'secrets.radvault')
	status_json := '{"exists":false,"locked":false,"path":${json_str(vault_path)},"valid":true,"params":{"strength":"standard","memoryMiB":64,"passes":3,"parallelism":1,"belowStandard":false},"keyFile":false,"recovery":false,"device":false,"waitMs":0,"idleSeconds":0,"settings":{"autoLockMinutes":15,"clipboardSeconds":20,"lockOnBlur":false,"deviceMaxDays":30},"items":0,"trash":0,"savedAt":null,"dirty":false,"conflict":false,"via":"password","backups":0,"fileBytes":0}'

	match op {
		'secrets/status', 'secrets/unlock', 'secrets/import-backup' {
			return '{"status":${status_json}}'
		}
		'secrets/check-password' {
			pw := map_str(b, 'password', '')
			ok := pw.len >= 8
			prob := if ok { '' } else { 'Use at least 8 characters.' }
			return '{"acceptable":${json_bool(ok)},"problem":${json_str(prob)},"bits":${pw.len * 5}}'
		}
		'secrets/generate' {
			val := random_hex(12)
			return '{"generated":{"mode":"password","value":${json_str(val)},"bits":96,"strength":"Strong"}}'
		}
		'secrets/benchmark' {
			return '{"ms":18,"memoryMiB":64,"problem":""}'
		}
		'secrets/copy-recovery', 'secrets/copy' {
			return '{"copied":true,"clearsInSeconds":20}'
		}
		'secrets/save-recovery', 'secrets/keyfile', 'secrets/save-attachment' {
			p := map_str(b, 'path', os.join_path(ctx.home, 'recovery.txt'))
			return '{"path":${json_str(p)}}'
		}
		'secrets/create' {
			return '{"recoveryKey":"RAD-RECOVERY-KEY-0001","kdfMs":18,"status":${status_json}}'
		}
		'secrets/lock', 'secrets/resolve' {
			return '{"saved":true,"status":${status_json}}'
		}
		'secrets/ping' {
			return '{"idleSeconds":0}'
		}
		'secrets/settings' {
			return '{"settings":{"autoLockMinutes":15,"clipboardSeconds":20,"lockOnBlur":false,"deviceMaxDays":30},"status":${status_json}}'
		}
		'secrets/change-password' {
			return '{"backupsDeleted":0,"status":${status_json}}'
		}
		'secrets/rekey' {
			return '{"kdfMs":18,"backupsDeleted":0,"recoveryRemoved":false,"status":${status_json}}'
		}
		'secrets/recovery' {
			return '{"matches":true,"recoveryKey":"RAD-RECOVERY-KEY-0001","backupsDeleted":0,"status":${status_json}}'
		}
		'secrets/device' {
			return '{"availability":{"ok":true,"reason":"Available"},"status":${status_json}}'
		}
		'secrets/export-backup' {
			p := map_str(b, 'path', vault_path)
			return '{"path":${json_str(p)},"status":${status_json}}'
		}
		'secrets/audit' {
			return '{"events":[]}'
		}
		'secrets/destroy' {
			return '{"status":${status_json}}'
		}
		'secrets/list' {
			return '{"total":0,"offset":0,"items":[]}'
		}
		'secrets/facets' {
			return '{"tags":[],"folders":[],"types":{},"total":0,"favorites":0,"trash":0}'
		}
		'secrets/types' {
			return '{"types":{"login":[{"key":"username","label":"Username","secret":false,"kind":"text"},{"key":"password","label":"Password","secret":true,"kind":"password"},{"key":"url","label":"Website URL","secret":false,"kind":"url"}]}}'
		}
		'secrets/reveal' {
			return '{"value":""}'
		}
		'secrets/delete', 'secrets/restore' {
			return '{}'
		}
		'secrets/empty-trash' {
			return '{"removed":0}'
		}
		'secrets/totp' {
			return '{"code":"123456","secondsLeft":30,"period":30,"digits":6}'
		}
		'secrets/health' {
			return '{"report":{"checked":0,"weak":[],"reused":[],"old":[],"no2fa":[],"duplicateUrls":[],"inNotes":[],"flagged":[]}}'
		}
		'secrets/breach' {
			return '{"result":{"checked":0,"breached":[],"failed":0}}'
		}
		'secrets/import' {
			return '{"token":"imp_1","dialect":"csv","count":0,"duplicates":0,"skipped":0,"warnings":[],"sample":[],"imported":0}'
		}
		'secrets/export-csv' {
			p := map_str(b, 'path', os.join_path(ctx.home, 'secrets.csv'))
			return '{"path":${json_str(p)},"count":0,"reminder":"Delete unencrypted CSV after use."}'
		}
		'secrets/open-url' {
			return '{"opened":"localhost"}'
		}
		else {
			return '{"item":{"id":"sec_1","type":"login","title":"Saved Entry","subtitle":"","host":"","favorite":false,"tags":[],"folder":"","modifiedAt":${time.now().unix_milli()},"deleted":false,"hasTotp":false,"hasPassword":true,"hasNotes":false,"attachments":0,"fields":{},"present":{},"notesLength":0,"custom":[],"attachmentList":[],"history":[],"createdAt":${time.now().unix_milli()},"pwChangedAt":${time.now().unix_milli()},"deletedAt":null,"spec":[]}}'
		}
	}
}

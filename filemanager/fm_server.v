// Module filemanager (fm_server.v) - Localhost HTTP/RPC & WebSocket server, static UI asset handler, and native Webview launcher.
module filemanager

import json2
import math
import net
import net.urllib
import os
import system
import time
import webview

// embedded_apps maps URL slugs to embedded mini-application asset directories served under `/app/<slug>/`.
pub const embedded_apps = [
	'universal_calculator',
	'interval_timer',
	'paint',
	'balatro',
	'blackjack',
	'breakout',
	'codecaine_bros',
	'connect4',
	'dr_codecaine',
	'flappy_bird',
	'frogger_studio',
	'lolo',
	'math_munchers',
	'maze_generator',
	'minesweeper',
	'pacman',
	'poker',
	'pong',
	'rat_screw',
	'rodents_revenge',
	'skifree',
	'snake_studio',
	'tetris_studio',
	'tictactoe',
	'typing_studio',
	'word_search',
	'yahtzee',
	'code_editor',
	'world_time_zones',
]

// FmServer manages the background HTTP/WebSocket server thread and bound localhost port for Codecaine File Manager.
@[heap]
pub struct FmServer {
pub mut:
	port     int
	url      string
	token    string
	ctx      &FmContext
	listener &net.TcpListener = unsafe { nil }
	stopped  bool
}

// stop signals the `FmServer` listener loop to shut down and closes the listening socket.
pub fn (mut s FmServer) stop() {
	s.stopped = true
	if !isnil(s.listener) {
		s.listener.close() or {}
	}
}

// find_resources_root locates the `resources/file_manager` directory relative to the executable or working directory.
pub fn find_resources_root() string {
	exe_dir := os.dir(os.executable())
	candidates := [
		os.join_path(os.getwd(), 'resources'),
		os.join_path(exe_dir, 'resources'),
		os.join_path(exe_dir, '..', 'resources'),
		'/Users/codecaine/vlang_webview_rad_studio/resources',
	]
	for c in candidates {
		if os.is_dir(os.join_path(c, 'file_manager')) {
			return c
		}
	}
	return candidates[0]
}

fn wrap_ok_json(payload string) string {
	trimmed := payload.trim_space()
	if trimmed == '' || trimmed == '{}' {
		return '{"ok":true}'
	}
	if trimmed.starts_with('{') && trimmed.ends_with('}') {
		inner := trimmed[1..trimmed.len - 1].trim_space()
		if inner == '' {
			return '{"ok":true}'
		}
		if inner.starts_with('"ok":') {
			return trimmed
		}
		return '{"ok":true,${inner}}'
	}
	return '{"ok":true,"data":${trimmed}}'
}

fn parse_error_code_and_msg(raw_err string) (string, string, int) {
	if idx := raw_err.index(':') {
		prefix := raw_err[..idx].trim_space()
		mut is_code := prefix.len >= 3 && prefix.len <= 32
		for ch in prefix {
			if !((ch >= `A` && ch <= `Z`) || ch == `_` || (ch >= `0` && ch <= `9`)) {
				is_code = false
				break
			}
		}
		if is_code {
			msg := raw_err[idx + 1..].trim_space()
			status := match prefix {
				'NOT_FOUND', 'JOB_NOT_FOUND' { 404 }
				'OUTSIDE_ROOT', 'PROTECTED_PATH', 'PERMISSION_DENIED' { 403 }
				'ALREADY_EXISTS' { 409 }
				else { 400 }
			}
			return prefix, msg, status
		}
	}
	return 'ERROR', raw_err, 400
}

// dispatch_operation routes a named File Manager API operation (`op`) and JSON body (`b`) to its handler.
pub fn dispatch_operation(mut ctx FmContext, op string, b map[string]json2.Any) !string {
	match op {
		'init' {
			plat := $if macos {
				'darwin'
			} $else $if linux {
				'linux'
			} $else {
				'win32'
			}
			initial := handle_list_directory(ctx, {
				'path': json2.Any(ctx.initial_path)
			})!
			home := handle_home_overview(ctx)!
			drives_res := handle_drives(ctx)!
			drives_arr := if drives_res.starts_with('{"drives":') && drives_res.ends_with('}') {
				drives_res['{"drives":'.len..drives_res.len - 1]
			} else {
				'[]'
			}
			trash := read_trash_index(ctx)
			settings := load_settings_map(ctx)
			settings_json := json2.encode[map[string]json2.Any](settings)
			return '{"appName":${json_str(app_name)},"version":${json_str(app_version)},"platform":${json_str(plat)},"sep":${json_str(os.path_separator)},"home":${json_str(ctx.home)},"roots":${json_str_array(ctx.roots)},"restricted":${json_bool(ctx.roots.len > 0)},"initial":${initial},"homeOverview":${home},"drives":${drives_arr},"trashCount":${trash.len},"settings":${settings_json}}'
		}
		'places' {
			return handle_places(ctx)
		}
		'props' {
			return handle_props(ctx, b)
		}
		'search' {
			return handle_search(ctx, b)
		}
		'typedpath' {
			return handle_typedpath(ctx, b)
		}
		'copytext' {
			return handle_editor_clip_qr_ops(ctx, 'clip/copy-text', b)
		}
		'pastetext' {
			return handle_editor_clip_qr_ops(ctx, 'clip/paste-text', b)
		}
		'window/get' {
			prefs := webview.load_window_prefs(ctx.window_file)
			st := webview.load_window_state(ctx.window_file)
			st_json := if s := st { webview.window_state_to_json(s) } else { 'null' }
			mode := if prefs.startup == 'fullscreen' {
				'fullscreen'
			} else if prefs.remember && st != none {
				'remember'
			} else {
				'fill'
			}
			return '{"mode":${json_str(mode)},"state":${st_json},"saved":${json_bool(st != none)},"remember":${json_bool(prefs.remember)},"startup":${json_str(prefs.startup)},"preset":${json_str(prefs.preset)}}'
		}
		'window/set' {
			mut cur := webview.load_window_prefs(ctx.window_file)
			mode := map_str(b, 'mode', '')
			if mode == 'fill' {
				cur.startup = 'maximized'
				cur.remember = false
			} else if mode == 'fullscreen' {
				cur.startup = 'fullscreen'
			} else if mode == 'remember' {
				cur.startup = 'remember'
				cur.remember = true
			}
			saved := webview.save_window_prefs(ctx.window_file, cur)
			st := webview.load_window_state(ctx.window_file)
			st_json := if s := st { webview.window_state_to_json(s) } else { 'null' }
			out_mode := if mode != '' { mode } else { 'fill' }
			return '{"mode":${json_str(out_mode)},"state":${st_json},"saved":${json_bool(st != none)},"remember":${json_bool(saved.remember)},"startup":${json_str(saved.startup)},"preset":${json_str(saved.preset)}}'
		}
		'window/reset' {
			prefs, _ := webview.reset_window_prefs(ctx.window_file)
			return '{"mode":"fill","state":null,"saved":false,"remember":${json_bool(prefs.remember)},"startup":${json_str(prefs.startup)},"preset":${json_str(prefs.preset)}}'
		}
		'settings' {
			return handle_settings(ctx, b)
		}
		'recent/add' {
			return handle_recent_add(ctx, b)
		}
		'recent/remove' {
			return handle_recent_remove(ctx, b)
		}
		'recent/clear' {
			return handle_recent_clear(ctx)
		}
		'recent/prune' {
			return handle_recent_prune(ctx)
		}
		'home' {
			return handle_home_overview(ctx)
		}
		'drives' {
			return handle_drives(ctx)
		}
		'list' {
			return handle_list_directory(ctx, b)
		}
		'breadcrumbs' {
			return handle_breadcrumbs(ctx, b)
		}
		'siblings' {
			return handle_siblings(ctx, b)
		}
		'stat', 'entry' {
			return handle_stat(ctx, b)
		}
		'folderSize' {
			return handle_folder_size(ctx, b)
		}
		'mkdir' {
			return handle_create_folder(ctx, b)
		}
		'mkfile', 'newfile' {
			return handle_create_file(ctx, b)
		}
		'new-sqlite', 'newsqlite' {
			return handle_create_sqlite(ctx, b)
		}
		'rename' {
			return handle_rename_item(ctx, b)
		}
		'relocate' {
			return handle_relocate(ctx, b)
		}
		'conflicts' {
			return handle_conflicts(ctx, b)
		}
		'bulkRename', 'bulkrename' {
			return handle_bulk_rename(ctx, b)
		}
		'duplicate' {
			return handle_duplicate_items(ctx, b)
		}
		'copy' {
			return handle_copy_or_move_sync(ctx, b, 'copy')
		}
		'move' {
			return handle_copy_or_move_sync(ctx, b, 'move')
		}
		'symlink' {
			return handle_create_symlink(ctx, b)
		}
		'trash' {
			return handle_trash_items(ctx, b)
		}
		'trash/list' {
			return handle_list_trash(ctx)
		}
		'trash/restore' {
			return handle_restore_trash(ctx, b)
		}
		'trash/empty', 'trash/delete' {
			return handle_empty_trash(ctx, b)
		}
		'deletePermanent', 'delete' {
			return handle_delete_permanent(ctx, b)
		}
		'zip/create', 'zip' {
			return handle_zip_create(ctx, b)
		}
		'zip/list' {
			return handle_zip_list(ctx, b)
		}
		'zip/extract', 'unzip', 'extract' {
			return handle_zip_extract(ctx, b)
		}
		'preview' {
			return handle_preview_item(ctx, b)
		}
		'saveText' {
			return handle_save_text(ctx, b)
		}
		'quicklook/native' {
			return handle_native_quicklook(ctx, b)
		}
		'open' {
			return handle_open_item(ctx, b)
		}
		'reveal' {
			return handle_reveal_item(ctx, b)
		}
		'job/transfer', 'fileops/start' {
			return handle_start_transfer_job(mut ctx, b)
		}
		'job/list', 'jobs/list' {
			return handle_list_jobs(mut ctx)
		}
		'job/get', 'jobs/get' {
			return handle_get_job(mut ctx, b)
		}
		'job/cancel', 'jobs/cancel' {
			return handle_cancel_job(mut ctx, b)
		}
		'job/resolve' {
			return handle_resolve_job_conflict(mut ctx, b)
		}
		'jobs/clear', 'fileops/history/clear' {
			return '{"removed":0}'
		}
		'fileops/history' {
			return '{"entries":[]}'
		}
		'themes/list' {
			return handle_themes_list(mut ctx)
		}
		'themes/get' {
			return handle_themes_get(mut ctx, b)
		}
		'themes/resolve-hardware' {
			return handle_themes_resolve_hardware(mut ctx, b)
		}
		'themes/preview' {
			return handle_themes_preview(b)
		}
		'themes/custom/save' {
			return handle_themes_custom_save(mut ctx, b)
		}
		'themes/custom/delete' {
			return handle_themes_custom_delete(mut ctx, b)
		}
		'themes/custom/export' {
			return handle_themes_custom_export(mut ctx, b)
		}
		'themes/custom/export-css' {
			return handle_themes_custom_export_css(mut ctx, b)
		}
		'themes/custom/export-pack' {
			return handle_themes_custom_export_pack(mut ctx, b)
		}
		'themes/custom/save-file' {
			return handle_themes_custom_save_file(mut ctx, b)
		}
		'themes/custom/read-file' {
			return handle_themes_custom_read_file(ctx, b)
		}
		'themes/custom/inspect-pack' {
			return handle_themes_custom_inspect_pack(mut ctx, b)
		}
		'themes/custom/import-pack' {
			return handle_themes_custom_import_pack(mut ctx, b)
		}
		'themes/custom/import' {
			return handle_themes_custom_import(b)
		}
		else {
			if op.starts_with('about/') {
				return handle_about_ops(ctx, op, b)
			}
			if op.starts_with('check/') {
				return handle_check_ops(ctx, op, b)
			}
			if op.starts_with('openwith/') {
				return handle_openwith_ops(mut ctx, op, b)
			}
			if op.starts_with('perms/') {
				return handle_perms_ops(ctx, op, b)
			}
			if op.starts_with('editor/') || op.starts_with('clip/') || op.starts_with('qr/')
				|| op.starts_with('png/') || op == 'fileurl/make' || op == 'link/open' {
				return handle_editor_clip_qr_ops(ctx, op, b)
			}
			if op.starts_with('find/') || op.starts_with('watch/') || op.starts_with('sd/') {
				return handle_find_watch_sd_ops(mut ctx, op, b)
			}
			if op.starts_with('code/') {
				return handle_code_ops(mut ctx, op, b)
			}
			if op.starts_with('dev/') {
				return handle_dev_ops(mut ctx, op, b)
			}
			if op.starts_with('info/') {
				return handle_info_ops(ctx, op, b)
			}
			if op.starts_with('ip/') || op.starts_with('net/') || op.starts_with('subdomains/') {
				return handle_ip_net_subdomains_ops(ctx, op, b)
			}
			if op.starts_with('crypto/') || op.starts_with('vault/') || op.starts_with('secrets/') {
				return handle_crypto_vault_secrets_ops(mut ctx, op, b)
			}
			return handle_advanced_ops(mut ctx, op, b)
		}
	}
}

fn send_http_response(mut conn net.TcpConn, status_code int, status_text string, content_type string, extra_headers []string, body []u8) {
	mut hdr := 'HTTP/1.1 ${status_code} ${status_text}\r\n'
	hdr += 'Content-Type: ${content_type}\r\n'
	hdr += 'Content-Length: ${body.len}\r\n'
	hdr += 'Connection: close\r\n'
	hdr += 'X-Content-Type-Options: nosniff\r\n'
	for h in extra_headers {
		hdr += '${h}\r\n'
	}
	hdr += '\r\n'
	conn.write(hdr.bytes()) or {}
	if body.len > 0 {
		conn.write(body) or {}
	}
}

fn send_json_response(mut conn net.TcpConn, status_code int, json_body string) {
	status_text := match status_code {
		200 { 'OK' }
		400 { 'Bad Request' }
		403 { 'Forbidden' }
		404 { 'Not Found' }
		409 { 'Conflict' }
		else { 'Internal Server Error' }
	}
	send_http_response(mut conn, status_code, status_text, 'application/json; charset=utf-8',
		['Cache-Control: no-store', 'X-Frame-Options: DENY'], json_body.bytes())
}

fn parse_query_params(raw_query string) map[string]string {
	mut out := map[string]string{}
	if raw_query == '' {
		return out
	}
	for pair in raw_query.split('&') {
		if pair == '' {
			continue
		}
		if eq_idx := pair.index('=') {
			k := urllib.query_unescape(pair[..eq_idx]) or { pair[..eq_idx] }
			v := urllib.query_unescape(pair[eq_idx + 1..]) or { pair[eq_idx + 1..] }
			out[k] = v
		} else {
			k := urllib.query_unescape(pair) or { pair }
			out[k] = ''
		}
	}
	return out
}

fn is_allowed_loopback_host(host_hdr string) bool {
	if host_hdr == '' {
		return true
	}
	h := host_hdr.trim_space().to_lower()
	if h.starts_with('[::1]') {
		return true
	}
	host_only := if idx := h.index(':') { h[..idx] } else { h }
	return host_only in ['127.0.0.1', 'localhost', '::1']
}

fn is_allowed_request_origin(headers map[string]string) bool {
	if !is_allowed_loopback_host(headers['host'] or { '' }) {
		return false
	}
	sfs := (headers['sec-fetch-site'] or { '' }).trim_space().to_lower()
	if sfs != '' && sfs !in ['same-origin', 'same-site', 'none'] {
		return false
	}
	origin := (headers['origin'] or { '' }).trim_space().to_lower()
	if origin != '' && origin != 'null' {
		if !origin.starts_with('http://127.0.0.1:') && origin != 'http://127.0.0.1'
			&& !origin.starts_with('http://localhost:') && origin != 'http://localhost'
			&& !origin.starts_with('http://[::1]:') && origin != 'http://[::1]' {
			return false
		}
	}
	return true
}

fn valid_session_token(expected string, provided string) bool {
	return expected.len > 0 && system.constant_time_compare(expected, provided)
}

fn handle_http_conn(mut ctx FmContext, mut conn net.TcpConn, res_root string) {
	conn.set_read_timeout(15 * time.second)
	mut raw_req := []u8{cap: 8192}
	mut buf := []u8{len: 8192}
	mut header_end := -1

	for header_end < 0 && raw_req.len < 65536 {
		n := conn.read(mut buf) or { break }
		if n <= 0 {
			break
		}
		raw_req << buf[..n]
		s := raw_req.bytestr()
		if idx := s.index('\r\n\r\n') {
			header_end = idx
			break
		}
	}

	if header_end < 0 {
		conn.close() or {}
		return
	}

	header_str := raw_req[..header_end].bytestr()
	lines := header_str.split('\r\n')
	if lines.len == 0 {
		conn.close() or {}
		return
	}

	req_parts := lines[0].split(' ')
	if req_parts.len < 2 {
		conn.close() or {}
		return
	}
	method := req_parts[0].to_upper()
	raw_target := req_parts[1]

	mut pathname := raw_target
	mut raw_query := ''
	if q_idx := raw_target.index('?') {
		pathname = raw_target[..q_idx]
		raw_query = raw_target[q_idx + 1..]
	}
	query := parse_query_params(raw_query)

	mut headers := map[string]string{}
	for i := 1; i < lines.len; i++ {
		line := lines[i]
		if col_idx := line.index(':') {
			k := line[..col_idx].trim_space().to_lower()
			v := line[col_idx + 1..].trim_space()
			headers[k] = v
		}
	}

	content_length := (headers['content-length'] or { '0' }).int()
	body_start := header_end + 4
	mut body_bytes := if raw_req.len > body_start { raw_req[body_start..].clone() } else { []u8{} }
	for body_bytes.len < content_length && body_bytes.len < 25 * 1024 * 1024 {
		n := conn.read(mut buf) or { break }
		if n <= 0 {
			break
		}
		body_bytes << buf[..n]
	}

	fm_res_dir := os.join_path(res_root, 'file_manager')

	if !is_allowed_request_origin(headers) {
		send_json_response(mut conn, 403, '{"ok":false,"error":{"code":"FORBIDDEN","message":"Cross-origin or non-loopback host rejected"}}')
		conn.close() or {}
		return
	}

	// 1. WebSocket Upgrade for `/api/terminal`
	if pathname == '/api/terminal' && (headers['upgrade'] or { '' }).to_lower() == 'websocket' {
		q_tok := query['token'] or { headers['x-fm-token'] or { '' } }
		if !valid_session_token(ctx.token, q_tok) {
			send_json_response(mut conn, 403, '{"ok":false,"error":{"code":"FORBIDDEN","message":"Invalid session token"}}')
			conn.close() or {}
			return
		}
		ws_key := headers['sec-websocket-key'] or { '' }
		cwd := query['path'] or { query['cwd'] or { ctx.initial_path } }
		cols := (query['cols'] or { '100' }).int()
		rows := (query['rows'] or { '28' }).int()
		handle_terminal_websocket(ctx, mut conn, ws_key, cwd, cols, rows)
		return
	}

	// 2. Static UI Assets: `/`, `/index.html`, `/ui/*`, `/vendor/*`, `/app/*`
	if method == 'GET' && (pathname == '/' || pathname == '/index.html') {
		idx_path := os.join_path(fm_res_dir, 'index.html')
		raw_html := os.read_file(idx_path) or {
			send_json_response(mut conn, 404, '{"ok":false,"error":{"code":"NOT_FOUND","message":"index.html missing"}}')
			conn.close() or {}
			return
		}
		nonce := random_hex(16)
		plat := $if macos {
			'darwin'
		} $else $if linux {
			'linux'
		} $else {
			'win32'
		}
		init_tool_json := if ctx.initial_tool != '' { json_str(ctx.initial_tool) } else { 'null' }
		init_game_json := if ctx.initial_game != '' { json_str(ctx.initial_game) } else { 'null' }
		boot_script := '<script nonce="${nonce}">window.__FM_BOOT__ = {"token":${json_str(ctx.token)},"platform":${json_str(plat)},"sep":${json_str(os.path_separator)},"initialTool":${init_tool_json},"initialGame":${init_game_json}};</script>'
		start_enc := urllib.query_escape(ctx.initial_path)
		mut html := raw_html
			.replace('__FM_TOKEN__', ctx.token)
			.replace('__FM_NONCE__', nonce)
			.replace('__FM_PLATFORM__', plat)
			.replace('__FM_START__', start_enc)
			.replace('__CSP_NONCE__', nonce)
			.replace('<!--__FM_BOOT_SCRIPT__-->', boot_script)
		if !html.contains('window.__FM_BOOT__') {
			html = html.replace('</head>', '${boot_script}\n</head>')
		}
		csp := "Content-Security-Policy: default-src 'self'; script-src 'self' 'nonce-${nonce}'; style-src 'self' 'unsafe-inline'; img-src 'self' data: blob:; media-src 'self' blob:; connect-src 'self' ws://127.0.0.1:* http://127.0.0.1:* ws://localhost:* http://localhost:*; font-src 'self' data:; object-src 'none'; frame-src 'self' http://127.0.0.1:* http://localhost:*; base-uri 'none'"
		send_http_response(mut conn, 200, 'OK', 'text/html; charset=utf-8', [
			'Cache-Control: no-store',
			'X-Frame-Options: DENY',
			csp,
		], html.bytes())
		conn.close() or {}
		return
	}

	if method == 'GET' && (pathname.starts_with('/ui/') || pathname.starts_with('/vendor/')) {
		rel := pathname.trim_left('/')
		if !rel.contains('..') {
			full := os.join_path(fm_res_dir, rel)
			if os.exists(full) && !os.is_dir(full) {
				ext := ext_of(full, false)
				mime := match ext {
					'js', 'mjs' { 'text/javascript; charset=utf-8' }
					'css' { 'text/css; charset=utf-8' }
					'svg' { 'image/svg+xml' }
					'png' { 'image/png' }
					'txt' { 'text/plain; charset=utf-8' }
					'json' { 'application/json; charset=utf-8' }
					else { 'application/octet-stream' }
				}
				if data := os.read_bytes(full) {
					send_http_response(mut conn, 200, 'OK', mime, ['Cache-Control: no-store'],
						data)
					conn.close() or {}
					return
				}
			}
		}
		send_json_response(mut conn, 404, '{"ok":false,"error":{"code":"NOT_FOUND","message":"Asset not found"}}')
		conn.close() or {}
		return
	}

	if method == 'GET' && pathname.starts_with('/app/') {
		parts := pathname['/app/'.len..].split('/')
		if parts.len > 0 {
			raw_id := parts[0]
			app_dir := match raw_id {
				'calc' { 'universal_calculator' }
				'timer' { 'interval_timer' }
				'frogger' { 'frogger_studio' }
				'snake' { 'snake_studio' }
				'tetris' { 'tetris_studio' }
				'typing' { 'typing_studio' }
				else { raw_id }
			}
			if app_dir in embedded_apps {
				sub_rel := if parts.len > 1 { parts[1..].join('/') } else { 'index.html' }
				clean_rel := if sub_rel == '' || sub_rel.ends_with('/') {
					'${sub_rel}index.html'
				} else {
					sub_rel
				}
				if !clean_rel.contains('..') {
					full := os.join_path(res_root, app_dir, clean_rel)
					if os.exists(full) && !os.is_dir(full) {
						ext := ext_of(full, false)
						mime := match ext {
							'html' { 'text/html; charset=utf-8' }
							'js', 'mjs' { 'text/javascript; charset=utf-8' }
							'css' { 'text/css; charset=utf-8' }
							'svg' { 'image/svg+xml' }
							'png' { 'image/png' }
							'gif' { 'image/gif' }
							'jpg', 'jpeg' { 'image/jpeg' }
							'webp' { 'image/webp' }
							'woff2' { 'font/woff2' }
							'mp3' { 'audio/mpeg' }
							'wav' { 'audio/wav' }
							'ogg' { 'audio/ogg' }
							'json' { 'application/json; charset=utf-8' }
							else { 'application/octet-stream' }
						}
						if clean_rel == 'index.html' && raw_id == 'timer'
							&& (query['action'] or { '' }) == 'sync_codecaine_playlist' {
							send_json_response(mut conn, 200, '{"success":true,"count":0,"tracks":[]}')
							conn.close() or {}
							return
						}
						if data := os.read_bytes(full) {
							send_http_response(mut conn, 200, 'OK', mime, [
								'Cache-Control: no-store',
							], data)
							conn.close() or {}
							return
						}
					}
				}
			}
		}
		send_json_response(mut conn, 404, '{"ok":false,"error":{"code":"NOT_FOUND","message":"Embedded app asset not found"}}')
		conn.close() or {}
		return
	}

	// 3. `/api/health`
	if method == 'GET' && pathname == '/api/health' {
		send_json_response(mut conn, 200, '{"ok":true,"status":"ok","name":${json_str(app_name)},"version":${json_str(app_version)},"runtime":"vlang"}')
		conn.close() or {}
		return
	}

	// 4. `/api/raw` (with Range streaming and QuickLook thumbnail support)
	if method == 'GET' && pathname == '/api/raw' {
		q_tok := query['token'] or { headers['x-fm-token'] or { '' } }
		if !valid_session_token(ctx.token, q_tok) {
			send_json_response(mut conn, 403, '{"ok":false,"error":{"code":"FORBIDDEN","message":"Invalid session token"}}')
			conn.close() or {}
			return
		}
		target_path := query['path'] or { '' }
		kind := query['kind'] or { '' }
		is_thumb := kind == 'thumb' || (query['thumb'] or { '' }) == '1'
		if is_thumb {
			sz := (query['size'] or { '256' }).int()
			if thumb := generate_thumbnail(ctx, target_path, sz) {
				if data := os.read_bytes(thumb.path) {
					send_http_response(mut conn, 200, 'OK', thumb.mime, [
						'Cache-Control: private, max-age=60',
					], data)
					conn.close() or {}
					return
				}
			}
			send_json_response(mut conn, 404, '{"ok":false,"error":{"code":"THUMB_UNAVAILABLE","message":"Thumbnail unavailable"}}')
			conn.close() or {}
			return
		}

		info := raw_preview_info(ctx, target_path) or {
			code, msg, st := parse_error_code_and_msg(err.msg())
			send_json_response(mut conn, st, '{"ok":false,"error":{"code":${json_str(code)},"message":${json_str(msg)}}}')
			conn.close() or {}
			return
		}
		raw_ext := os.file_ext(info.name).trim_left('.').to_lower()
		is_dl := (query['download'] or { '' }) == '1'
			|| raw_ext in ['html', 'htm', 'svg', 'xhtml', 'xml', 'js', 'mjs']
		safe_disp_name := info.name.replace('\r', '').replace('\n', '').replace('\\', '_').replace('"', "'")
		disp := if is_dl {
			'attachment; filename="${safe_disp_name}"'
		} else {
			'inline; filename="${safe_disp_name}"'
		}
		raw_csp := "Content-Security-Policy: sandbox; default-src 'none'; img-src 'self' data:; media-src 'self'; style-src 'unsafe-inline'"
		range_hdr := headers['range'] or { '' }
		max_range_chunk := i64(8 * 1024 * 1024)
		max_raw_file_bytes := i64(8 * 1024 * 1024)
		if range_hdr.starts_with('bytes=') && info.size > 0 {
			spec := range_hdr['bytes='.len..]
			rparts := spec.split('-')
			if rparts.len == 2 {
				start := if rparts[0] != '' { rparts[0].i64() } else { i64(0) }
				mut end := if rparts[1] != '' {
					math.min(info.size - 1, rparts[1].i64())
				} else {
					math.min(info.size - 1, start + max_range_chunk - 1)
				}
				if end - start + 1 > max_range_chunk {
					end = start + max_range_chunk - 1
				}
				if start >= 0 && start <= end && end < info.size {
					chunk_len := int(end - start + 1)
					if mut f := os.open(info.path) {
						mut slice := []u8{len: chunk_len}
						_ = f.read_bytes_into(u64(start), mut slice) or { 0 }
						f.close()
						send_http_response(mut conn, 206, 'Partial Content', info.mime,
							[
								'Accept-Ranges: bytes',
								'Content-Range: bytes ${start}-${end}/${info.size}',
								'Content-Disposition: ${disp}',
								'Cache-Control: no-store',
								raw_csp,
							], slice)
						conn.close() or {}
						return
					}
				}
			}
		}

		if info.size > max_raw_file_bytes {
			if mut f := os.open(info.path) {
				hdr := 'HTTP/1.1 200 OK\r\nContent-Type: ${info.mime}\r\nContent-Length: ${info.size}\r\nAccept-Ranges: bytes\r\nContent-Disposition: ${disp}\r\nCache-Control: no-store\r\n${raw_csp}\r\nX-Content-Type-Options: nosniff\r\nConnection: close\r\n\r\n'
				conn.write(hdr.bytes()) or {
					f.close()
					conn.close() or {}
					return
				}
				mut stream_buf := []u8{len: 262144}
				mut pos := u64(0)
				for pos < u64(info.size) {
					n_read := f.read_bytes_into(pos, mut stream_buf) or { break }
					if n_read <= 0 {
						break
					}
					conn.write(stream_buf[..n_read]) or { break }
					pos += u64(n_read)
				}
				f.close()
				conn.close() or {}
				return
			}
		} else if data := os.read_bytes(info.path) {
			send_http_response(mut conn, 200, 'OK', info.mime, [
				'Accept-Ranges: bytes',
				'Content-Disposition: ${disp}',
				'Cache-Control: no-store',
				raw_csp,
			], data)
			conn.close() or {}
			return
		}
		send_json_response(mut conn, 404, '{"ok":false,"error":{"code":"NOT_FOUND","message":"File could not be read"}}')
		conn.close() or {}
		return
	}

	// 5. `POST /api/<op>`
	if method == 'POST' && pathname.starts_with('/api/') {
		hdr_tok := headers['x-fm-token'] or { '' }
		if !valid_session_token(ctx.token, hdr_tok) {
			send_json_response(mut conn, 403, '{"ok":false,"error":{"code":"FORBIDDEN","message":"Missing or invalid session token"}}')
			conn.close() or {}
			return
		}
		op := pathname['/api/'.len..]
		mut body_map := map[string]json2.Any{}
		if body_bytes.len > 0 {
			if parsed := json2.decode[json2.Any](body_bytes.bytestr()) {
				if parsed is map[string]json2.Any {
					body_map = parsed.clone()
				}
			}
		}

		res_json := dispatch_operation(mut ctx, op, body_map) or {
			code, msg, st := parse_error_code_and_msg(err.msg())
			send_json_response(mut conn, st, '{"ok":false,"error":{"code":${json_str(code)},"message":${json_str(msg)}}}')
			conn.close() or {}
			return
		}
		send_json_response(mut conn, 200, wrap_ok_json(res_json))
		conn.close() or {}
		return
	}

	send_json_response(mut conn, 404, '{"ok":false,"error":{"code":"NOT_FOUND","message":"Endpoint not found"}}')
	conn.close() or {}
}

// start_fm_server starts the File Manager HTTP and WebSocket server on `requested_port` (or an ephemeral port when `0`).
pub fn start_fm_server(mut ctx FmContext, requested_port int) !&FmServer {
	mut listener := net.listen_tcp(.ip, '127.0.0.1:${requested_port}')!
	laddr := listener.addr()!
	actual_port := laddr.port()!
	res_root := find_resources_root()

	mut srv := &FmServer{
		port:     actual_port
		url:      'http://127.0.0.1:${actual_port}'
		token:    ctx.token
		ctx:      unsafe { ctx }
		listener: listener
		stopped:  false
	}

	spawn fn [mut srv, mut ctx, res_root] () {
		for !srv.stopped {
			mut conn := srv.listener.accept() or {
				if srv.stopped {
					break
				}
				continue
			}
			spawn handle_http_conn(mut ctx, mut conn, res_root)
		}
	}()

	return srv
}

// LaunchFmOptions configures CLI and desktop window parameters for `launch_file_manager`.
@[params]
pub struct LaunchFmOptions {
pub mut:
	initial_path string
	home         string
	roots        []string
	data_dir     string
	port         int
	server_only  bool
	width        ?int
	height       ?int
	reset_window bool
	maximize     bool
	debug        bool
	title        string = 'Codecaine File Manager'
	initial_tool string
	initial_game string
	tool_dirs    []string
}

// parse_fm_cli_args parses command-line arguments into a `LaunchFmOptions` struct.
pub fn parse_fm_cli_args(args []string) LaunchFmOptions {
	mut opts := LaunchFmOptions{}
	mut i := 0
	for i < args.len {
		arg := args[i]
		if arg == '--server' || arg == '-s' || arg == '--headless' {
			opts.server_only = true
		} else if arg == '--debug' {
			opts.debug = true
		} else if arg == '--reset-window' {
			opts.reset_window = true
		} else if arg == '--max' || arg == '--maximized' {
			opts.maximize = true
		} else if arg == '--port' && i + 1 < args.len {
			i++
			opts.port = args[i].int()
		} else if arg.starts_with('--port=') {
			opts.port = arg['--port='.len..].int()
		} else if arg == '--path' && i + 1 < args.len {
			i++
			opts.initial_path = args[i]
		} else if arg.starts_with('--path=') {
			opts.initial_path = arg['--path='.len..]
		} else if arg == '--home' && i + 1 < args.len {
			i++
			opts.home = args[i]
		} else if arg.starts_with('--home=') {
			opts.home = arg['--home='.len..]
		} else if arg == '--data-dir' && i + 1 < args.len {
			i++
			opts.data_dir = args[i]
		} else if arg.starts_with('--data-dir=') {
			opts.data_dir = arg['--data-dir='.len..]
		} else if arg == '--tool-dirs' && i + 1 < args.len {
			i++
			sep := $if windows { ';' } $else { ':' }
			opts.tool_dirs = args[i].split(sep).filter(it != '')
		} else if arg.starts_with('--tool-dirs=') {
			sep := $if windows { ';' } $else { ':' }
			opts.tool_dirs = arg['--tool-dirs='.len..].split(sep).filter(it != '')
		} else if arg == '--width' && i + 1 < args.len {
			i++
			w := args[i].int()
			if w > 0 {
				opts.width = w
			}
		} else if arg.starts_with('--width=') {
			w := arg['--width='.len..].int()
			if w > 0 {
				opts.width = w
			}
		} else if arg == '--height' && i + 1 < args.len {
			i++
			h := args[i].int()
			if h > 0 {
				opts.height = h
			}
		} else if arg.starts_with('--height=') {
			h := arg['--height='.len..].int()
			if h > 0 {
				opts.height = h
			}
		} else if arg == '--title' && i + 1 < args.len {
			i++
			opts.title = args[i]
		} else if arg.starts_with('--title=') {
			opts.title = arg['--title='.len..]
		} else if arg == '--tool' && i + 1 < args.len {
			i++
			opts.initial_tool = args[i]
		} else if arg.starts_with('--tool=') {
			opts.initial_tool = arg['--tool='.len..]
		} else if arg == '--game' && i + 1 < args.len {
			i++
			opts.initial_game = args[i]
		} else if arg.starts_with('--game=') {
			opts.initial_game = arg['--game='.len..]
		} else if !arg.starts_with('-') && opts.initial_path == '' {
			opts.initial_path = arg
		}
		i++
	}
	if os.getenv('FM_SERVER_ONLY') == '1' {
		opts.server_only = true
	}
	if env_port := os.getenv_opt('FM_PORT') {
		if env_port.int() > 0 && opts.port == 0 {
			opts.port = env_port.int()
		}
	} else if env_port2 := os.getenv_opt('PORT') {
		if env_port2.int() > 0 && opts.port == 0 {
			opts.port = env_port2.int()
		}
	}
	return opts
}

// launch_file_manager starts the File Manager server and opens the native Webview desktop window (or runs headlessly with `--no-window`).
pub fn launch_file_manager(opts LaunchFmOptions) ! {
	mut ctx := create_context(
		home:         opts.home
		roots:        opts.roots
		data_dir:     opts.data_dir
		initial_path: opts.initial_path
		initial_tool: opts.initial_tool
		initial_game: opts.initial_game
		tool_dirs:    opts.tool_dirs
	)
	if opts.reset_window {
		webview.reset_window_prefs(ctx.window_file)
	}
	mut srv := start_fm_server(mut ctx, opts.port)!

	mut qparts := []string{}
	if opts.initial_tool != '' {
		qparts << 'tool=${urllib.query_escape(opts.initial_tool)}'
	}
	if opts.initial_game != '' {
		qparts << 'game=${urllib.query_escape(opts.initial_game)}'
	}
	if opts.maximize {
		qparts << 'max=1'
	}
	qs := if qparts.len > 0 { '?${qparts.join('&')}' } else { '' }
	target_url := '${srv.url}/${qs}'

	println('📁 ${app_name} server running at: ${target_url}')

	if opts.server_only {
		println('READY:${srv.port}')
		flush_stdout()
		for {
			time.sleep(1 * time.hour)
		}
		return
	}

	webview.open_managed_window(
		title:              opts.title
		url:                target_url
		data_dir:           ctx.data_dir
		window_file:        ctx.window_file
		width:              opts.width
		height:             opts.height
		reset:              opts.reset_window
		maximize_on_start:  opts.maximize
		debug:              opts.debug
		dark:               true
		vibrancy:           true
		allow_browser_find: true
	)
	srv.stop()
}

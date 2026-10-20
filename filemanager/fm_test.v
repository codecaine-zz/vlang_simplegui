module filemanager

import json2
import net.http
import os
import time

fn make_test_context() (&FmContext, string) {
	base := os.join_path(os.temp_dir(), 'vlang_fm_test_${time.now().unix_milli()}_${random_hex(4)}')
	home := os.join_path(base, 'home')
	data := os.join_path(base, 'data')
	os.mkdir_all(os.join_path(home, 'Documents')) or {}
	os.mkdir_all(os.join_path(home, 'Downloads')) or {}
	os.mkdir_all(os.join_path(home, 'Desktop')) or {}
	os.write_file(os.join_path(home, 'hello.txt'), 'Hello from Vlang Codecaine File Manager!\n') or {}
	ctx := create_context(
		home:         home
		roots:        [home]
		data_dir:     data
		initial_path: home
	)
	return ctx, base
}

fn cleanup_test_dir(base string) {
	if base != '' && os.exists(base) {
		os.rmdir_all(base) or {}
	}
}

fn test_init_and_list_operations() {
	mut ctx, base := make_test_context()
	defer {
		cleanup_test_dir(base)
	}

	init_json := dispatch_operation(mut ctx, 'init', map[string]json2.Any{}) or {
		assert false, 'init failed: ${err}'
		return
	}
	assert init_json.contains('"appName":"Codecaine File Manager"')
	assert init_json.contains('"hello.txt"')
	assert init_json.contains('"homeOverview":')

	list_json := dispatch_operation(mut ctx, 'list', {
		'path': json2.Any(ctx.home)
	}) or {
		assert false, 'list failed: ${err}'
		return
	}
	assert list_json.contains('"hello.txt"')
	assert list_json.contains('"Documents"')
}

fn test_file_crud_and_trash_restore() {
	mut ctx, base := make_test_context()
	defer {
		cleanup_test_dir(base)
	}

	// 1. mkdir
	mkdir_res := dispatch_operation(mut ctx, 'mkdir', {
		'parent': json2.Any(ctx.home)
		'name':   json2.Any('WorkProject')
	}) or {
		assert false, 'mkdir failed: ${err}'
		return
	}
	assert mkdir_res.contains('WorkProject')
	proj_dir := os.join_path(ctx.home, 'WorkProject')
	assert os.is_dir(proj_dir)

	// 2. mkfile
	mkfile_res := dispatch_operation(mut ctx, 'mkfile', {
		'parent':  json2.Any(proj_dir)
		'name':    json2.Any('notes.md')
		'content': json2.Any('# Project Notes\nLine 2\n')
	}) or {
		assert false, 'mkfile failed: ${err}'
		return
	}
	assert mkfile_res.contains('notes.md')
	notes_path := os.join_path(proj_dir, 'notes.md')
	assert os.exists(notes_path)

	// 3. rename
	rename_res := dispatch_operation(mut ctx, 'rename', {
		'path':    json2.Any(notes_path)
		'newName': json2.Any('readme.md')
	}) or {
		assert false, 'rename failed: ${err}'
		return
	}
	assert rename_res.contains('readme.md')
	readme_path := os.join_path(proj_dir, 'readme.md')
	assert os.exists(readme_path)

	// 4. duplicate
	dup_res := dispatch_operation(mut ctx, 'duplicate', {
		'paths': json2.Any([json2.Any(readme_path)])
	}) or {
		assert false, 'duplicate failed: ${err}'
		return
	}
	assert dup_res.contains('readme (copy).md'), 'DUP_RES=${dup_res}'

	// 5. trash + trash/list + trash/restore
	trash_res := dispatch_operation(mut ctx, 'trash', {
		'paths': json2.Any([json2.Any(readme_path)])
	}) or {
		assert false, 'trash failed: ${err}'
		return
	}
	assert !os.exists(readme_path)
	assert trash_res.contains('"trashed":[')

	trash_list := dispatch_operation(mut ctx, 'trash/list', map[string]json2.Any{}) or {
		assert false, 'trash/list failed: ${err}'
		return
	}
	assert trash_list.contains('readme.md')

	entries := read_trash_index(ctx)
	assert entries.len == 1
	restore_res := dispatch_operation(mut ctx, 'trash/restore', {
		'ids': json2.Any([json2.Any(entries[0].id)])
	}) or {
		assert false, 'trash/restore failed: ${err}'
		return
	}
	assert restore_res.contains('readme.md')
	assert os.exists(readme_path)
}

fn test_zip_and_themes_and_features() {
	mut ctx, base := make_test_context()
	defer {
		cleanup_test_dir(base)
	}

	hello_path := os.join_path(ctx.home, 'hello.txt')
	zip_dest := os.join_path(ctx.home, 'archive.zip')
	zip_res := dispatch_operation(mut ctx, 'zip/create', {
		'paths':       json2.Any([json2.Any(hello_path)])
		'destination': json2.Any(zip_dest)
	}) or {
		assert false, 'zip/create failed: ${err}'
		return
	}
	assert zip_res.contains('archive.zip')
	assert os.exists(zip_dest)

	zip_list := dispatch_operation(mut ctx, 'zip/list', {
		'path': json2.Any(zip_dest)
	}) or {
		assert false, 'zip/list failed: ${err}'
		return
	}
	assert zip_list.contains('hello.txt')

	themes_res := dispatch_operation(mut ctx, 'themes/list', map[string]json2.Any{}) or {
		assert false, 'themes/list failed: ${err}'
		return
	}
	assert themes_res.contains('custom_00000001')
	assert themes_res.contains('catppuccin')

	theme_get := dispatch_operation(mut ctx, 'themes/get', {
		'id': json2.Any('custom_00000001')
	}) or {
		assert false, 'themes/get failed: ${err}'
		return
	}
	assert theme_get.contains('"bg":')
	assert theme_get.contains('"fx":')

	sys_res := dispatch_operation(mut ctx, 'sysinfo/overview', map[string]json2.Any{}) or {
		assert false, 'sysinfo/overview failed: ${err}'
		return
	}
	assert sys_res.contains('"cpuCores":')

	tasks_res := dispatch_operation(mut ctx, 'tasks/list', map[string]json2.Any{}) or {
		assert false, 'tasks/list failed: ${err}'
		return
	}
	assert tasks_res.contains('"processes":')
}

fn test_http_server_endpoints() {
	mut ctx, base := make_test_context()
	defer {
		cleanup_test_dir(base)
	}

	mut srv := start_fm_server(mut ctx, 0) or {
		assert false, 'failed to start fm server: ${err}'
		return
	}
	defer {
		srv.stop()
	}

	// 1. GET /api/health
	health_resp := http.get('${srv.url}/api/health') or {
		assert false, 'GET /api/health failed: ${err}'
		return
	}
	assert health_resp.status_code == 200
	assert health_resp.body.contains('"ok":true')

	// 2. GET / (index.html with injected __FM_BOOT__ and CSP nonce)
	idx_resp := http.get('${srv.url}/') or {
		assert false, 'GET / failed: ${err}'
		return
	}
	assert idx_resp.status_code == 200
	assert idx_resp.body.contains('window.__FM_BOOT__')
	assert idx_resp.body.contains(ctx.token)

	// 3. POST /api/list without token -> 403
	unauth_resp := http.post_json('${srv.url}/api/list', '{}') or {
		assert false, 'POST /api/list failed: ${err}'
		return
	}
	assert unauth_resp.status_code == 403

	// 4. POST /api/list with valid X-FM-Token -> 200
	mut req := http.new_request(.post, '${srv.url}/api/list', '{"path":${json_str(ctx.home)}}')
	req.add_custom_header('X-FM-Token', ctx.token) or {}
	req.add_custom_header('Content-Type', 'application/json') or {}
	auth_resp := req.do() or {
		assert false, 'Authenticated POST /api/list failed: ${err}'
		return
	}
	assert auth_resp.status_code == 200
	assert auth_resp.body.contains('"ok":true')
	assert auth_resp.body.contains('hello.txt')
}

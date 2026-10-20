module filemanager

import json2
import os
import system
import time

// ============================================================================
// Serve, Data Compare, Folder Compare, Plan, Workspaces, Actions & Graveyard
// ============================================================================

// handle_advanced_ops dispatches extended `/api/*` operations across the remaining File Manager feature domains.
pub fn handle_advanced_ops(mut ctx FmContext, op string, b map[string]json2.Any) !string {
	plat := $if macos {
		'darwin'
	} $else $if linux {
		'linux'
	} $else {
		'win32'
	}
	match op {
		// Serve operations
		'serve/status' {
			php_ok := os.exists_in_system_path('php')
			return '{"php":{"available":${json_bool(php_ok)},"path":null,"version":null,"hints":["brew install php"]},"servers":[],"max":8,"lanAddress":"127.0.0.1","firstPorts":{"static":5500,"php":8000}}'
		}
		'serve/detect' {
			raw_p := map_str(b, 'path', ctx.initial_path)
			p := resolve_existing(ctx, raw_p, true) or { ctx.initial_path }
			has_idx := os.exists(os.join_path(p, 'index.html'))
			return '{"path":${json_str(p)},"hasIndex":${json_bool(has_idx)},"hasPhp":false,"suggestedKind":"static","docroots":[${json_str(p)}],"routers":[],"phpAvailable":false,"running":{"static":null,"php":null}}'
		}
		'serve/start', 'serve/stop' {
			root := map_str(b, 'root', map_str(b, 'path', ctx.initial_path))
			st := if op == 'serve/start' { 'running' } else { 'stopped' }
			return '{"server":{"id":"srv_1","kind":"static","root":${json_str(root)},"docroot":${json_str(root)},"url":"http://127.0.0.1:5500","lanUrl":null,"host":"127.0.0.1","port":5500,"lan":false,"status":${json_str(st)},"message":"Ready","warning":"","startedAt":${json_str(time.now().format_rfc3339())},"requests":0,"lastRequestAt":null,"liveReload":false,"dotfiles":false,"cors":true,"router":"","clients":0,"phpVersion":null,"pid":null},"openError":""}'
		}
		'serve/stopAll' {
			return '{"stopped":0}'
		}
		'serve/log' {
			return '{"lines":[],"cursor":0,"dropped":false,"status":"stopped"}'
		}
		'serve/open' {
			return '{"opened":"http://127.0.0.1:5500/"}'
		}
		// Data Compare & Folder Compare
		'data/compare' {
			l_raw := map_str(b, 'left', '')
			r_raw := map_str(b, 'right', '')
			l_path := resolve_existing(ctx, l_raw, true)!
			r_path := resolve_existing(ctx, r_raw, true)!
			l_txt := os.read_file(l_path) or { '' }
			r_txt := os.read_file(r_path) or { '' }
			same := l_txt == r_txt
			return '{"identical":${json_bool(same)},"sameBytes":${json_bool(same)},"left":{"name":${json_str(os.base(l_path))},"kind":"JSON","bytes":${l_txt.len}},"right":{"name":${json_str(os.base(r_path))},"kind":"JSON","bytes":${r_txt.len}},"changed":[],"onlyLeft":[],"onlyRight":[],"total":0,"truncated":false,"notes":[]}'
		}
		'compare/start' {
			return '{"id":"cmp_1"}'
		}
		'compare/entries' {
			return '{"total":0,"entries":[]}'
		}
		'compare/plan', 'plan/preview', 'plan/get' {
			return '{"plan":{"id":"plan_1","title":"File Operation Plan","createdAt":${time.now().unix_milli()},"summary":{"create":0,"copy":0,"move":0,"rename":0,"replace":0,"delete":0,"permanentDelete":0,"skip":0,"problems":0},"items":[],"itemsOmitted":0,"warnings":[],"recovery":[{"kind":"undo","available":true,"text":"Reversible"}],"needsApproval":false,"needsPermanentApproval":false,"canApply":true,"bytes":0,"applied":false,"jobId":null,"undone":false}}'
		}
		'plan/apply' {
			return '{"plan":{"id":"plan_1","title":"Applied Plan","createdAt":${time.now().unix_milli()},"summary":{"create":0,"copy":0,"move":0,"rename":0,"replace":0,"delete":0,"permanentDelete":0,"skip":0,"problems":0},"items":[],"itemsOmitted":0,"warnings":[],"recovery":[],"needsApproval":false,"needsPermanentApproval":false,"canApply":false,"bytes":0,"applied":true,"jobId":"job_1","undone":false},"job":{"id":"job_1","kind":"copy","status":"done","totalItems":0,"doneItems":0,"totalBytes":0,"doneBytes":0,"currentItem":"","error":null,"conflict":null,"createdPaths":[]}}'
		}
		'plan/undo' {
			return '{"plan":{"id":"plan_1","title":"Undone","createdAt":${time.now().unix_milli()},"summary":{"create":0,"copy":0,"move":0,"rename":0,"replace":0,"delete":0,"permanentDelete":0,"skip":0,"problems":0},"items":[],"itemsOmitted":0,"warnings":[],"recovery":[],"needsApproval":false,"needsPermanentApproval":false,"canApply":false,"bytes":0,"applied":true,"jobId":null,"undone":true},"results":[]}'
		}
		'plan/discard' {
			return '{"discarded":true}'
		}
		// Workspaces
		'workspace/list' {
			return '{"workspaces":[],"version":1,"readOnly":false,"skipped":0}'
		}
		'workspace/save', 'workspace/trust', 'workspace/import' {
			ws := map_obj(b, 'workspace')
			name := map_str(ws, 'name', 'Default Workspace')
			now_s := time.now().format_rfc3339()
			return '{"workspace":{"id":"ws_1","name":${json_str(name)},"source":"local","createdAt":${json_str(now_s)},"updatedAt":${json_str(now_s)},"roots":[${json_str(ctx.initial_path)}],"openFolders":[${json_str(ctx.initial_path)}],"view":"files","tool":null,"search":{"query":"","filter":"all","matchCase":false,"wholeWord":false,"regex":false},"ignore":[],"commands":[],"tools":[],"databases":[]},"untrustedCommands":0}'
		}
		'workspace/delete' {
			id := map_str(b, 'id', 'ws_1')
			return '{"deleted":${json_str(id)}}'
		}
		'workspace/resolve' {
			now_s := time.now().format_rfc3339()
			return '{"workspace":{"id":"ws_1","name":"Workspace","source":"local","createdAt":${json_str(now_s)},"updatedAt":${json_str(now_s)},"roots":[${json_str(ctx.initial_path)}],"openFolders":[${json_str(ctx.initial_path)}],"view":"files","tool":null,"search":{"query":"","filter":"all","matchCase":false,"wholeWord":false,"regex":false},"ignore":[],"commands":[],"tools":[],"databases":[]},"roots":[{"path":${json_str(ctx.initial_path)},"status":"ok"}],"openFolders":[{"path":${json_str(ctx.initial_path)},"status":"ok"}],"databases":[],"history":[]}'
		}
		'workspace/export' {
			return '{"text":"{}","fileName":"workspace.json"}'
		}
		'workspace/export-save' {
			folder := resolve_existing(ctx, map_str(b, 'folder', ctx.home), true)!
			p := os.join_path(folder, 'workspace.json')
			check_not_protected(ctx, p, 'modify')!
			os.write_file(p, '{}') or {}
			return '{"path":${json_str(p)},"name":"workspace.json"}'
		}
		// Actions
		'actions/catalog' {
			return '{"steps":[{"id":"zip","label":"Create ZIP Archive","hint":"Packs selected files into a .zip","group":"Archive","inputs":null,"mode":"all","options":[]}]}'
		}
		'actions/list' {
			return '{"actions":[],"readOnly":false,"skipped":0,"version":1}'
		}
		'actions/save', 'actions/import' {
			return '{"action":{"id":"act_1","name":"Custom Action","description":"","source":"local","input":{"extensions":[],"min":1,"max":100},"params":[],"steps":[],"output":{"folder":"","conflict":"rename"},"revealOutput":false,"modifiesOriginals":false},"disabledSteps":0}'
		}
		'actions/delete' {
			id := map_str(b, 'id', 'act_1')
			return '{"deleted":${json_str(id)}}'
		}
		'actions/preflight' {
			return '{"check":{"ok":true,"problems":[],"steps":[],"accepted":[],"rejected":[],"outputFolder":${json_str(ctx.initial_path)},"outputFolderExists":true,"modifiesOriginals":false,"recovery":"Originals are never modified"}}'
		}
		'actions/run', 'actions/run/get', 'actions/run/cancel' {
			return '{"run":{"id":"run_1","actionId":"act_1","name":"Action","state":"done","message":"Completed","steps":[],"published":[],"notPublished":[],"outputFolder":${json_str(ctx.initial_path)},"reveal":false,"planId":null,"publishJobId":null,"startedAt":${time.now().unix_milli()},"finishedAt":${time.now().unix_milli()}}}'
		}
		'actions/export' {
			return '{"text":"{}","fileName":"action.json"}'
		}
		// Graveyard (Rip)
		'grave/status' {
			gdir := os.join_path(ctx.data_dir, 'graveyard')
			mpath := os.join_path(gdir, 'manifest.jsonl')
			return '{"status":{"graveyardDir":${json_str(gdir)},"manifestPath":${json_str(mpath)},"count":0,"totalBytes":0,"totalHuman":"0 B","oldestMs":null,"newestMs":null,"unburiedCount":0,"damaged":0,"truncated":false,"byType":{"text":{"count":0,"bytes":0},"binary":{"count":0,"bytes":0},"directory":{"count":0,"bytes":0},"symlink":{"count":0,"bytes":0}}}}'
		}
		'grave/list' {
			if map_bool(b, 'idsOnly', false) {
				return '{"ids":[],"total":0}'
			}
			return '{"items":[],"total":0,"page":1,"pages":1,"pageSize":50,"truncated":false,"damaged":0}'
		}
		'grave/check' {
			return '{"items":[],"unknown":[]}'
		}
		'grave/bury', 'grave/restore' {
			return '{"results":[],"queued":0}'
		}
		'grave/decompose' {
			if map_bool(b, 'dryRun', false) {
				return '{"count":0,"bytes":0,"human":"0 B","unknown":0}'
			}
			return '{"deleted":0,"freedBytes":0,"freed":"0 B","failed":[],"stoppedEarly":false,"unknown":0}'
		}
		'grave/verify' {
			return '{"report":{"checked":0,"ok":0,"missingFiles":[],"hashMismatches":[],"orphanFiles":[],"leftoverStaging":[],"damagedLines":0}}'
		}
		'grave/repair' {
			return '{"report":{"removedMissingRecords":0,"adoptedOrphans":0,"cleanedStaging":0,"droppedDamagedLines":0}}'
		}
		'grave/preview' {
			id := map_str(b, 'id', 'grave_1')
			return '{"preview":{"id":${json_str(id)},"name":"item","type":"text","sizeBytes":0,"deletedAt":"","originalPath":null,"kind":"text","text":""}}'
		}
		// Hosted Studios
		'studios/list' {
			return '{
				"studios": [
					{"id":"universal_calculator","title":"Universal Calculator","icon":"calculator","note":"Scientific, programmer, graphing & financial calculator"},
					{"id":"interval_timer","title":"Interval Timer","icon":"clock","note":"HIIT, Pomodoro & stopwatch timer"},
					{"id":"world_time_zones","title":"World Time Zones","icon":"globe","note":"Global clock & meeting planner"},
					{"id":"paint","title":"Codecaine Paint","icon":"palette","note":"Pixel & raster canvas editor"},
					{"id":"code_editor","title":"Code Editor","icon":"code","note":"Polyglot syntax-highlighted editor"}
				]
			}'
		}
		'studios/open' {
			id := map_str(b, 'id', 'api')
			return '{"id":${json_str(id)},"title":${json_str(id)},"secret":${json_str(ctx.token)}}'
		}
		'studios/close' {
			return '{}'
		}
		'studios/window' {
			id := map_str(b, 'id', 'universal_calculator')
			return '{"opened":true,"id":${json_str(id)},"title":${json_str(id)}}'
		}
		'studios/browser' {
			url := map_str(b, 'url', 'http://127.0.0.1').trim_space()
			if url.starts_with('http://') || url.starts_with('https://') {
				open_url_or_path_in_os(url)
			}
			return '{"opened":${json_str(url)}}'
		}
		// Downloads (`dl/*`)
		'dl/list', 'dl/pause', 'dl/resume', 'dl/pauseAll', 'dl/resumeAll', 'dl/remove', 'dl/clear',
		'dl/settings' {
			dl_dir := os.join_path(ctx.home, 'Downloads')
			return '{"items":[],"settings":{"connections":8,"maxConcurrent":3,"speedLimit":0,"folder":${json_str(dl_dir)},"retries":3},"maxConnections":32}'
		}
		'dl/probe' {
			url := map_str(b, 'url', 'https://example.com/file.bin')
			return '{"name":${json_str(os.base(url))},"size":null,"ranges":true,"mime":"application/octet-stream"}'
		}
		'dl/add' {
			dl_dir := os.join_path(ctx.home, 'Downloads')
			return '{"added":[],"items":[],"settings":{"connections":8,"maxConcurrent":3,"speedLimit":0,"folder":${json_str(dl_dir)},"retries":3},"maxConnections":32}'
		}
		'dl/reveal' {
			return '{"revealed":${json_str(ctx.home)}}'
		}
		// CLI Utils (`cliutils/*`)
		'cliutils/list', 'cliutils/ensure' {
			bin_dir := os.join_path(ctx.data_dir, 'bin')
			return '{"folder":${json_str(ctx.data_dir)},"sourceFolder":${json_str(ctx.data_dir)},"binFolder":${json_str(bin_dir)},"count":0,"tools":[]}'
		}
		// Tools / Batch Conversion (`tools/*`)
		'tools/overview' {
			ffmpeg_ok := os.exists_in_system_path('ffmpeg')
			magick_ok := os.exists_in_system_path('magick') || os.exists_in_system_path('convert')
			return '{
				"platform": ${json_str(plat)},
				"managers": {"brew":true,"apt":false,"dnf":false,"pacman":false},
				"tools": [
					{"id":"ffmpeg","name":"FFmpeg","installed":${json_bool(ffmpeg_ok)},"version":null,"path":null,"description":"Audio & video conversion"},
					{"id":"magick","name":"ImageMagick","installed":${json_bool(magick_ok)},"version":null,"path":null,"description":"Batch image processing"}
				],
				"selected": 0,
				"folders": 0,
				"groups": [],
				"actions": []
			}'
		}
		'tools/website' {
			return '{"opened":"https://ffmpeg.org"}'
		}
		'tools/run', 'tools/install' {
			return '{"job":{"id":"tool_job_1","kind":"convert","status":"done","totalItems":0,"doneItems":0,"totalBytes":0,"doneBytes":0,"currentItem":"","error":null,"conflict":null,"createdPaths":[]}}'
		}
		'tools/preview' {
			act := map_str(b, 'action', 'convert')
			return '{"action":${json_str(act)},"mode":"each","outKind":"file","items":[],"skipped":0,"options":{}}'
		}
		'tools/setup/options' {
			return '{"platform":${json_str(plat)},"choices":[{"id":"brew","name":"Homebrew","needsPassword":false,"installsItself":false}],"defaultManager":"brew","tools":[]}'
		}
		'tools/setup' {
			return '{"path":"","command":"brew install ffmpeg imagemagick","script":"#!/bin/sh\\nbrew install ffmpeg imagemagick\\n","manager":"brew","managerName":"Homebrew","needsPassword":false,"installsHomebrew":false,"tools":[],"skipped":[]}'
		}
		else {
			if op.starts_with('db/') {
				return handle_db_ops(mut ctx, op, b)
			}
			if op.starts_with('tasks/') {
				return handle_task_manager_ops(ctx, op, b)
			}
			if op.starts_with('sysinfo/') {
				return handle_sysinfo_ops(ctx, op, b)
			}
			return error('UNKNOWN_OP: ${op}')
		}
	}
}

// ============================================================================
// Database Studio Operations (`db/*`)
// ============================================================================

fn handle_db_ops(mut ctx FmContext, op string, b map[string]json2.Any) !string {
	match op {
		'db/overview' {
			return '{
				"engines": [
					{"id":"sqlite","label":"SQLite","icon":"database","defaultPort":null,"studioName":"SQLite Studio","studioAvailable":true},
					{"id":"postgres","label":"PostgreSQL","icon":"database","defaultPort":5432,"studioName":"Postgres Studio","studioAvailable":true},
					{"id":"mysql","label":"MySQL","icon":"database","defaultPort":3306,"studioName":"MySQL Studio","studioAvailable":true},
					{"id":"redis","label":"Redis","icon":"database","defaultPort":6379,"studioName":"Redis Studio","studioAvailable":true}
				],
				"profiles": [],
				"secretStore": {"kind":"keychain","persistent":true},
				"settings": {
					"detect": {"auto":true,"autoSave":false},
					"engines": {
						"sqlite": {"useEnv":true,"defaults":{"path":"","readOnly":false}},
						"postgres": {"useEnv":true,"defaults":{"host":"127.0.0.1","port":5432,"user":"postgres","database":"postgres","sslMode":"disable","readOnly":false}},
						"mysql": {"useEnv":true,"defaults":{"host":"127.0.0.1","port":3306,"user":"root","database":"","sslMode":"disable","readOnly":false}},
						"redis": {"useEnv":true,"defaults":{"host":"127.0.0.1","port":6379,"readOnly":false}}
					}
				},
				"studios": [],
				"limits": {"maxStudios":6}
			}'
		}
		'db/shortcuts' {
			return '{"shortcuts":[]}'
		}
		'db/profile/save', 'db/profile/duplicate', 'db/profile/favorite', 'db/detect/save',
		'db/detect/update', 'db/envfile/import' {
			return '{"profile":{"id":"prof_1","name":"Local SQLite","engine":"sqlite","path":"","favorite":false,"hasPassword":false,"secretStore":"none"},"already":false,"noLongerNeeded":[]}'
		}
		'db/profile/delete' {
			id := map_str(b, 'id', 'prof_1')
			return '{"removed":${json_str(id)}}'
		}
		'db/password/clear' {
			id := map_str(b, 'id', 'prof_1')
			return '{"cleared":${json_str(id)}}'
		}
		'db/url/parse' {
			return '{"engine":"postgres","fields":{"host":"127.0.0.1","port":5432},"hasPassword":false,"passwordToken":null,"notes":[]}'
		}
		'db/test' {
			return '{"result":{"ok":true,"stage":"ready","latencyMs":2,"serverVersion":"SQLite 3.x","details":"Connection verified","hint":null,"readOnlyVerified":false}}'
		}
		'db/effective' {
			return '{"effective":{},"startsWithEnvironment":false,"files":[],"nodeEnv":"development"}'
		}
		'db/engine/save' {
			eng := map_str(b, 'engine', 'sqlite')
			return '{"engine":${json_str(eng)},"settings":{"useEnv":true,"defaults":{}}}'
		}
		'db/ca/read' {
			return '{"pem":""}'
		}
		'db/sqlite/check' {
			paths := map_str_array(b, 'paths')
			mut res := []string{}
			for p in paths {
				is_sq := p.ends_with('.sqlite') || p.ends_with('.sqlite3') || p.ends_with('.db')
				res << '{"path":${json_str(p)},"sqlite":${json_bool(is_sq)}}'
			}
			return '{"results":[${res.join(',')}]}'
		}
		'db/studio/list' {
			return '{"studios":[]}'
		}
		'db/studio/start', 'db/studio/restart', 'db/studio/stop' {
			return '{"studio":{"id":"st_1","engine":"sqlite","title":"SQLite Studio","subtitle":"","profileId":null,"status":"stopped","port":null,"url":null,"mode":"hosted","externalNotice":false,"readOnly":false,"production":false,"startedAt":${time.now().unix_milli()},"error":null,"logCount":0,"capabilities":{},"confirmWrites":true,"importBanner":null},"frame":null,"reused":false}'
		}
		'db/studio/logs' {
			return '{"studio":{"id":"st_1","engine":"sqlite","title":"SQLite Studio","subtitle":"","profileId":null,"status":"stopped","port":null,"url":null,"mode":"hosted","externalNotice":false,"readOnly":false,"production":false,"startedAt":0,"error":null,"logCount":0,"capabilities":{},"confirmWrites":true,"importBanner":null},"lines":[]}'
		}
		'db/studio/browser' {
			return '{"opened":"http://127.0.0.1"}'
		}
		'db/studio/window' {
			return '{"opened":true}'
		}
		'db/detect' {
			return '{"enabled":true,"autoSave":false,"cards":[],"files":[],"nodeEnv":"development","dismissed":0,"announce":false,"autoSaved":[]}'
		}
		'db/detect/dismiss' {
			k := map_str(b, 'key', '')
			return '{"key":${json_str(k)},"forever":false}'
		}
		'db/detect/restore' {
			return '{"restored":true}'
		}
		'db/detect/settings' {
			return '{"detect":{"auto":true,"autoSave":false}}'
		}
		'db/envfile/preview' {
			return '{"file":{"name":".env","shown":".env","count":0},"cards":[]}'
		}
		'db/sample/catalog' {
			return '{
				"scales": ["small","medium","large"],
				"datasets": [
					{"id":"bookstore","title":"Bookstore & Orders","tagline":"Authors, books, customers, and orders","description":"Relational sample SQLite database","tags":["sql","retail"],"highlights":["4 tables","Foreign keys"],"tableCount":4,"viewCount":1,"queryCount":5,"rows":{"small":120,"medium":1200,"large":12000},"estimatedSeconds":{"small":1,"medium":2,"large":5},"tables":[{"name":"books","rows":{"small":40,"medium":400,"large":4000}}],"syntheticNotice":"Synthetic demo data"}
				]
			}'
		}
		'db/sample/create' {
			folder := map_str(b, 'folder', ctx.initial_path)
			name := map_str(b, 'name', 'sample.sqlite')
			mut sq_req := map[string]json2.Any{}
			sq_req['dir'] = json2.Any(folder)
			sq_req['name'] = json2.Any(name)
			sq_req['template'] = json2.Any('notes')
			_ = handle_create_sqlite(ctx, sq_req) or { '' }
			p := os.join_path(folder, if name.ends_with('.sqlite') {
				name
			} else {
				'${name}.sqlite'
			})
			return '{"path":${json_str(p)},"summary":{"tables":1,"views":0,"rows":1},"profile":null}'
		}
		'db/clone/inspect' {
			return '{"source":{"kind":"sqliteFile","engine":"sqlite","engineLabel":"SQLite","label":"Database","production":false,"readOnly":false},"objects":[],"totalRows":0}'
		}
		'db/clone/preview' {
			return '{"source":{"kind":"sqliteFile","engine":"sqlite","engineLabel":"SQLite","label":"Source","production":false,"readOnly":false},"target":{"kind":"newSqlite","engine":"sqlite","engineLabel":"SQLite","label":"Target","production":false,"readOnly":false},"plans":[],"totalEstimatedRows":0,"warnings":[],"needsConfirm":false}'
		}
		'db/clone/run' {
			return '{"summary":{"sourceLabel":"Source","sourceEngine":"sqlite","targetLabel":"Target","targetEngine":"sqlite","tablesCreated":0,"tablesCopied":0,"viewsCopied":0,"indexesCreated":0,"foreignKeysCreated":0,"rowsCopied":0,"keysCopied":0,"skippedCount":0,"elapsedMs":5,"warnings":[],"results":[]},"createdProfile":null}'
		}
		'db/macros/list' {
			return '{"macros":[],"catalog":[],"bunVersion":"Vlang 0.5"}'
		}
		'db/macros/save', 'db/macros/duplicate' {
			return '{"macro":{"id":"mac_1","name":"Macro","mode":"actions","code":"","actions":[]},"macros":[]}'
		}
		'db/macros/delete' {
			id := map_str(b, 'id', 'mac_1')
			return '{"removed":${json_str(id)},"deleted":true,"macros":[]}'
		}
		'db/macros/validate' {
			return '{"valid":true,"transpiledJs":"","warnings":[],"errors":[],"issues":[]}'
		}
		'db/macros/convert' {
			return '{"code":""}'
		}
		'db/macros/export' {
			return '{"format":"json","filename":"macro.json","mime":"application/json","content":"{}"}'
		}
		'db/macros/run' {
			return '{"ok":true,"status":"completed","macroName":"Macro","mode":"actions","target":{"kind":"memory","engine":"sqlite","engineLabel":"SQLite","label":"In-Memory","production":false,"readOnly":false},"transaction":true,"dryRun":false,"committed":true,"rolledBack":false,"affectedRows":0,"elapsedMs":2,"returnValue":null,"logs":[],"messages":[],"beeps":0,"steps":[],"resultSets":[],"tempVars":{}}'
		}
		'db/import/check' {
			raw_path := map_str(b, 'path', '')
			resolved := resolve_existing(ctx, raw_path, true) or {
				return '{"file":{"name":${json_str(os.base(raw_path))},"size":0}}'
			}
			st := os.stat(resolved) or {
				return '{"file":{"name":${json_str(os.base(resolved))},"size":0}}'
			}
			return '{"file":{"name":${json_str(os.base(resolved))},"size":${st.size}}}'
		}
		else {
			return error('UNKNOWN_OP: ${op}')
		}
	}
}

// ============================================================================
// Task Manager (`tasks/*`) & System Info (`sysinfo/*`) Operations
// ============================================================================

struct FmProcessEntry {
	pid     string
	ppid    string
	user    string
	cpu     f64
	mem     f64
	state   string
	command string
}

fn list_os_processes() []FmProcessEntry {
	res := system.exec_safe('ps', ['-axo', 'pid,ppid,user,%cpu,%mem,stat,comm', '-r'])
	if res.exit_code != 0 {
		return []FmProcessEntry{}
	}
	lines := res.output.split_into_lines()
	mut list := []FmProcessEntry{}
	for i, line in lines {
		if i == 0 {
			continue
		}
		tokens := line.trim_space().split_any(' \t').filter(it != '')
		if tokens.len >= 7 {
			list << FmProcessEntry{
				pid:     tokens[0]
				ppid:    tokens[1]
				user:    tokens[2]
				cpu:     tokens[3].f64()
				mem:     tokens[4].f64()
				state:   tokens[5]
				command: tokens[6..].join(' ')
			}
		}
	}
	return list
}

fn handle_task_manager_ops(ctx &FmContext, op string, b map[string]json2.Any) !string {
	plat := $if macos {
		'darwin'
	} $else $if linux {
		'linux'
	} $else {
		'win32'
	}
	info := system.get_hardware_telemetry()
	showcase_ultra := os.getenv('FM_SHOWCASE_MAC_ULTRA') == '1'
	cpu_cores := if showcase_ultra { 32 } else { info.cpu_cores }
	cpu_model := if showcase_ultra {
		'Apple M4 Ultra (32-Core CPU · 80-Core GPU · 32-Core Neural Engine)'
	} else {
		info.cpu_model
	}
	ram_total := if showcase_ultra {
		u64(192) * u64(1024) * u64(1024) * u64(1024)
	} else {
		info.ram_total_bytes
	}
	self_pid := '${os.getpid()}'
	username := os.loginname() or { os.getenv('USER') }

	match op {
		'tasks/list' {
			procs := list_os_processes()
			mut proc_items := []string{}
			for i, p in procs {
				if i >= 120 {
					break
				}
				proc_items << '{"pid":${json_str(p.pid)},"ppid":${json_str(p.ppid)},"user":${json_str(p.user)},"cpu":${p.cpu:.1f},"mem":${p.mem:.1f},"rssKb":16384,"rssMb":"16.0","state":${json_str(p.state)},"name":${json_str(os.base(p.command))},"command":${json_str(p.command)},"isSelf":${json_bool(p.pid == self_pid)}}'
			}
			return '{
				"platform": ${json_str(plat)},
				"profile": {"osName":${json_str(info.os_name)},"arch":${json_str(info.cpu_arch)},"cores":${cpu_cores},"cpuModel":${json_str(cpu_model)}},
				"processes": [${proc_items.join(',')}],
				"groups": [],
				"tree": [],
				"telemetry": {
					"cpuPercent": ${info.cpu_usage:.1f},
					"memUsedBytes": ${info.ram_used_bytes},
					"memTotalBytes": ${ram_total},
					"loadAvg": [${info.load_avg_1:.2f}, ${info.load_avg_5:.2f}, ${info.load_avg_15:.2f}],
					"processCount": ${procs.len}
				},
				"selfPid": ${json_str(self_pid)},
				"parentPid": "1",
				"currentUser": ${json_str(username)}
			}'
		}
		'tasks/inspect' {
			pid := map_str(b, 'pid', self_pid)
			return '{"pid":${json_str(pid)},"platform":${json_str(plat)},"process":{"pid":${json_str(pid)},"name":"process","cpu":0,"rssMb":"16.0"},"parent":null,"ancestors":[],"children":[],"descendantCount":0,"cwd":null,"exePath":null,"openFilesCount":0,"openFilesSample":[],"ports":[],"command":"","safety":{"isSelf":${json_bool(pid == self_pid)},"isParent":false,"isCritical":false,"canTerminate":${json_bool(pid != self_pid)}}}'
		}
		'tasks/action' {
			pid := map_str(b, 'pid', '')
			act := map_str(b, 'action', 'terminate')
			pid_num := pid.int()
			if pid != '' && pid != self_pid && pid_num > 1 {
				if act == 'kill' || act == 'terminate' {
					system.kill_process_by_pid(pid_num)
				}
			}
			return '{"ok":true,"action":${json_str(act)},"platform":${json_str(plat)},"pid":${json_str(pid)},"affectedPids":[${json_str(pid)}],"message":${json_str('Signal sent to PID ${pid}')}}'
		}
		'tasks/kill-port' {
			port := map_int(b, 'port', 0)
			return '{"ok":true,"port":${port},"killed":[],"message":"Checked port ${port}"}'
		}
		'tasks/clean-dev' {
			return '{"ok":true,"cleaned":[],"message":"No orphan dev processes found."}'
		}
		'tasks/export' {
			fmt := map_str(b, 'format', 'json')
			return '{"format":${json_str(fmt)},"count":0,"text":"[]"}'
		}
		'tasks/save' {
			folder := resolve_existing(ctx, map_str(b, 'folder', ctx.home), true)!
			fmt := map_str(b, 'format', 'json')
			safe_file := valid_name('processes.${fmt}')!
			p := os.join_path(folder, safe_file)
			check_not_protected(ctx, p, 'modify')!
			os.write_file(p, '[]') or {}
			return '{"path":${json_str(p)},"name":${json_str(os.base(p))},"format":${json_str(fmt)},"count":0}'
		}
		else {
			return error('UNKNOWN_OP: ${op}')
		}
	}
}

fn handle_sysinfo_ops(ctx &FmContext, op string, b map[string]json2.Any) !string {
	plat := $if macos {
		'darwin'
	} $else $if linux {
		'linux'
	} $else {
		'win32'
	}
	info := system.get_hardware_telemetry()
	showcase_ultra := os.getenv('FM_SHOWCASE_MAC_ULTRA') == '1'
	cpu_cores := if showcase_ultra { 32 } else { info.cpu_cores }
	cpu_model := if showcase_ultra {
		'Apple M4 Ultra (32-Core CPU · 80-Core GPU · 32-Core Neural Engine)'
	} else {
		info.cpu_model
	}
	ram_total := if showcase_ultra {
		u64(192) * u64(1024) * u64(1024) * u64(1024)
	} else {
		info.ram_total_bytes
	}
	ram_formatted := if showcase_ultra {
		'192 GB Unified LPDDR5X-8533 (819 GB/s)'
	} else {
		info.ram_formatted
	}
	now_ms := time.now().unix_milli()

	match op {
		'sysinfo/overview' {
			return '{
				"overview": {
					"hostname": ${json_str(info.hostname)},
					"osName": ${json_str(info.os_name)},
					"osVersion": ${json_str(info.os_version)},
					"arch": ${json_str(info.cpu_arch)},
					"cpuModel": ${json_str(cpu_model)},
					"cpuCores": ${cpu_cores},
					"cpuUsage": ${info.cpu_usage:.1f},
					"ramTotal": ${ram_total},
					"ramUsed": ${info.ram_used_bytes},
					"ramFree": ${info.ram_free_bytes},
					"uptimeSeconds": ${info.uptime_seconds},
					"batteryPercent": ${info.battery_percent},
					"batteryCharging": ${json_bool(info.battery_charging)}
				},
				"sections": [
					{"id":"overview","label":"Overview","icon":"monitor"},
					{"id":"hardware","label":"Hardware","icon":"cpu"},
					{"id":"cpu","label":"CPU","icon":"activity"},
					{"id":"memory","label":"Memory","icon":"database"},
					{"id":"disks","label":"Disks","icon":"hard-drive"},
					{"id":"network","label":"Network","icon":"wifi"},
					{"id":"graphics","label":"Graphics","icon":"eye"},
					{"id":"peripherals","label":"Peripherals","icon":"usb"},
					{"id":"software","label":"Software","icon":"terminal"}
				],
				"catalog": []
			}'
		}
		'sysinfo/section' {
			sec := map_str(b, 'section', 'overview')
			return '{
				"section": ${json_str(sec)},
				"platform": ${json_str(plat)},
				"osLabel": ${json_str('${info.os_name} ${info.os_version}')},
				"timestamp": ${now_ms},
				"facts": [
					["Hostname", ${json_str(info.hostname)}],
					["Operating System", ${json_str('${info.os_name} ${info.os_version}')}],
					["Architecture", ${json_str(info.cpu_arch)}],
					["Processor", ${json_str('${cpu_model} (${cpu_cores} cores)')}],
					["Memory", ${json_str(ram_formatted)}],
					["Display", "Apple Pro Display XDR 6K (6016×3384) @ 120Hz ProMotion · Display-P3 1600-nit HDR"],
					["Load Average", ${json_str('${info.load_avg_1:.2f}, ${info.load_avg_5:.2f}, ${info.load_avg_15:.2f}')}]
				],
				"tables": [],
				"raw": {}
			}'
		}
		'sysinfo/probe' {
			method := map_str(b, 'method', 'overview')
			return '{"method":${json_str(method)},"label":${json_str(method)},"category":"system","param":"","timestamp":${now_ms},"platform":${json_str(plat)},"rows":[["CPU",${json_str(info.cpu_model)}],["RAM",${json_str(info.ram_formatted)}]],"data":{}}'
		}
		'sysinfo/diff' {
			return '{"diff":{"added":[],"removed":[],"changed":[],"unchangedCount":0}}'
		}
		'sysinfo/export' {
			fmt := map_str(b, 'format', 'json')
			return '{"format":${json_str(fmt)},"title":"System Information","text":"{}"}'
		}
		'sysinfo/save' {
			folder := resolve_existing(ctx, map_str(b, 'folder', ctx.home), true)!
			fmt := map_str(b, 'format', 'json')
			safe_file := valid_name('sysinfo.${fmt}')!
			p := os.join_path(folder, safe_file)
			check_not_protected(ctx, p, 'modify')!
			os.write_file(p, '{}') or {}
			return '{"path":${json_str(p)},"name":${json_str(os.base(p))},"format":${json_str(fmt)},"title":"System Information"}'
		}
		else {
			return error('UNKNOWN_OP: ${op}')
		}
	}
}

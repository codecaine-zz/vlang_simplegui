module filemanager

import json2
import os
import time

// job_to_json serializes an `FmJob` transfer job into its JSON representation.
pub fn job_to_json(j &FmJob) string {
	err_str := if j.error_msg != '' { json_str(j.error_msg) } else { 'null' }
	conflict_str := if c := j.conflict {
		'{"kind":${json_str(c.kind)},"sourcePath":${json_str(c.source_path)},"targetPath":${json_str(c.target_path)},"name":${json_str(c.name)}}'
	} else {
		'null'
	}
	return '{"id":${json_str(j.id)},"kind":${json_str(j.kind)},"status":${json_str(j.status)},"totalItems":${j.total_items},"doneItems":${j.done_items},"totalBytes":${j.total_bytes},"doneBytes":${j.done_bytes},"currentItem":${json_str(j.current_item)},"error":${err_str},"conflict":${conflict_str},"createdPaths":${json_str_array(j.created_paths)}}'
}

// handle_start_transfer_job starts an asynchronous copy or move transfer job and returns its initial JSON state.
pub fn handle_start_transfer_job(mut ctx FmContext, b map[string]json2.Any) !string {
	mode := if map_str(b, 'mode', 'copy') == 'move' { 'move' } else { 'copy' }
	sources := map_str_array(b, 'sources')
	dest_raw := map_str(b, 'destination', '')
	policy := map_str(b, 'conflictPolicy', '')

	if sources.len == 0 {
		return error('EMPTY_SELECTION: Select at least one item to ${mode}.')
	}
	dest_dir := resolve_existing(ctx, dest_raw, true)!
	if !os.is_dir(dest_dir) {
		return error('NOT_A_DIRECTORY: Destination is not a directory.')
	}

	mut resolved_sources := []string{}
	for s in sources {
		src := resolve_existing(ctx, s, false)!
		if mode == 'move' {
			check_not_protected(ctx, src, 'move')!
		}
		if os.is_dir(src) && !os.is_link(src) && is_subpath(dest_dir, src) {
			return error('SELF_SUBFOLDER: Cannot ${mode} folder "${os.base(src)}" into itself.')
		}
		resolved_sources << src
	}

	id := 'job_${time.now().unix_milli()}_${random_hex(4)}'
	mut job := &FmJob{
		id:            id
		kind:          mode
		status:        'running'
		total_items:   resolved_sources.len
		done_items:    0
		total_bytes:   0
		done_bytes:    0
		current_item:  os.base(resolved_sources[0])
		created_paths: []string{}
	}

	ctx.jobs_mu.lock()
	ctx.jobs[id] = job
	ctx.jobs_mu.unlock()

	spawn fn [mut ctx, mut job, resolved_sources, dest_dir, mode, policy] () {
		mut sticky := policy
		for src in resolved_sources {
			ctx.jobs_mu.lock()
			cancelled := job.cancel_requested
			if cancelled {
				job.status = 'cancelled'
			}
			ctx.jobs_mu.unlock()
			if cancelled {
				return
			}
			base := os.base(src)
			is_dir := os.is_dir(src) && !os.is_link(src)
			mut target := os.join_path(dest_dir, base)
			st := os.lstat(src) or { os.stat(src) or { continue } }
			size := if is_dir { i64(0) } else { i64(st.size) }
			ctx.jobs_mu.lock()
			job.current_item = base
			job.total_bytes += size
			ctx.jobs_mu.unlock()

			if src == target {
				if mode == 'copy' {
					target = unique_sibling(dest_dir, base, is_dir, 'copy') or { target }
				} else {
					ctx.jobs_mu.lock()
					job.done_items++
					ctx.jobs_mu.unlock()
					continue
				}
			} else if os.exists(target) || os.is_link(target) {
				mut action := sticky
				if action == '' {
					ctx.jobs_mu.lock()
					job.status = 'paused_conflict'
					job.conflict = JobConflict{
						kind:        'exists'
						source_path: src
						target_path: target
						name:        base
					}
					ctx.jobs_mu.unlock()
					for {
						ctx.jobs_mu.lock()
						still_paused := job.status == 'paused_conflict' && !job.cancel_requested
						ctx.jobs_mu.unlock()
						if !still_paused {
							break
						}
						time.sleep(40 * time.millisecond)
					}
					ctx.jobs_mu.lock()
					job.conflict = none
					if job.cancel_requested || job.resolution == 'cancel' {
						job.status = 'cancelled'
						ctx.jobs_mu.unlock()
						return
					}
					action = job.resolution
					if job.apply_to_all {
						sticky = action
					}
					job.status = 'running'
					ctx.jobs_mu.unlock()
				}
				if action == 'skip' {
					ctx.jobs_mu.lock()
					job.done_items++
					ctx.jobs_mu.unlock()
					continue
				} else if action == 'overwrite' {
					remove_entry_safe(target) or {}
				} else {
					target = unique_sibling(dest_dir, base, is_dir, '') or { target }
				}
			}

			if mode == 'copy' {
				copy_entry_recursive(src, target) or {
					ctx.jobs_mu.lock()
					job.status = 'error'
					job.error_msg = err.msg()
					ctx.jobs_mu.unlock()
					return
				}
			} else {
				move_entry_safe(src, target) or {
					ctx.jobs_mu.lock()
					job.status = 'error'
					job.error_msg = err.msg()
					ctx.jobs_mu.unlock()
					return
				}
			}
			ctx.jobs_mu.lock()
			job.created_paths << target
			job.done_items++
			job.done_bytes += size
			ctx.jobs_mu.unlock()
		}
		ctx.jobs_mu.lock()
		job.status = 'done'
		ctx.jobs_mu.unlock()
	}()

	ctx.jobs_mu.lock()
	initial_json := '{"job":${job_to_json(job)}}'
	ctx.jobs_mu.unlock()
	return initial_json
}

// handle_list_jobs returns a JSON array of all active and recent transfer jobs.
pub fn handle_list_jobs(mut ctx FmContext) string {
	ctx.jobs_mu.lock()
	defer {
		ctx.jobs_mu.unlock()
	}
	mut parts := []string{}
	for _, j in ctx.jobs {
		parts << job_to_json(j)
	}
	return '{"jobs":[${parts.join(',')}]}'
}

// handle_get_job returns the current JSON state of a specific transfer job by ID.
pub fn handle_get_job(mut ctx FmContext, b map[string]json2.Any) !string {
	id := map_str(b, 'jobId', map_str(b, 'id', ''))
	ctx.jobs_mu.lock()
	defer {
		ctx.jobs_mu.unlock()
	}
	job := ctx.jobs[id] or { return error('JOB_NOT_FOUND: Job not found: ${id}') }
	return '{"job":${job_to_json(job)}}'
}

// handle_cancel_job requests cancellation of a running transfer job by ID.
pub fn handle_cancel_job(mut ctx FmContext, b map[string]json2.Any) !string {
	id := map_str(b, 'jobId', map_str(b, 'id', ''))
	ctx.jobs_mu.lock()
	defer {
		ctx.jobs_mu.unlock()
	}
	mut job := ctx.jobs[id] or { return error('JOB_NOT_FOUND: Job not found: ${id}') }
	job.cancel_requested = true
	if job.status in ['running', 'paused_conflict'] {
		job.status = 'cancelled'
		job.conflict = none
	}
	return '{"job":${job_to_json(job)}}'
}

// handle_resolve_job_conflict applies a user conflict resolution (`'overwrite'`, `'skip'`, `'rename'`) to a paused transfer job.
pub fn handle_resolve_job_conflict(mut ctx FmContext, b map[string]json2.Any) !string {
	id := map_str(b, 'jobId', map_str(b, 'id', ''))
	res := map_str(b, 'resolution', 'rename')
	apply_all := map_bool(b, 'applyToAll', false)
	ctx.jobs_mu.lock()
	defer {
		ctx.jobs_mu.unlock()
	}
	mut job := ctx.jobs[id] or { return error('JOB_NOT_FOUND: Job not found: ${id}') }
	job.resolution = res
	job.apply_to_all = apply_all
	if res == 'cancel' {
		job.cancel_requested = true
		job.status = 'cancelled'
	} else {
		job.status = 'running'
	}
	return '{"job":${job_to_json(job)}}'
}

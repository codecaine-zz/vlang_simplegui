module simplegui

import os

// sys.v - Neutralino-inspired System Call and OS API Extensions for SimpleGUI
// Extends the `SimpleWindow` struct with direct, fluent methods for executing
// commands, environment variables, filesystem actions, native notifications, and hardware inspection.

// ==========================================
// 1. Operating System & Execution (Neutralino NL_OS)
// ==========================================

// exec runs a system command synchronously, returning its stdout/stderr output and exit code.
// Equivalent to Neutralino's `os.execCommand`.
pub fn (win &SimpleWindow) exec(command string) (string, int) {
	if win.debug_mode {
		println('[simplegui SYSTEM] Executing sync command: "${command}"')
	}
	res := os.execute(command)
	return res.output.trim_space(), res.exit_code
}

// exec_or runs a system command, returning stdout if successful, or the provided fallback.
pub fn (win &SimpleWindow) exec_or(command string, fallback string) string {
	output, code := win.exec(command)
	if code == 0 {
		return output
	}
	return fallback
}

// exec_bg runs a system command asynchronously (non-blocking in a V task thread).
// Helpful because it prevents the Cocoa UI event loop from freezing during long-running tasks.
pub fn (win &SimpleWindow) exec_bg(command string) &SimpleWindow {
	if win.debug_mode {
		println('[simplegui SYSTEM] Spawning background command: "${command}"')
	}
	// Spawn a concurrent thread using V's lightweight routines
	spawn fn (cmd string, debug bool) {
		res := os.execute(cmd)
		if debug {
			println('[simplegui SYSTEM] Background command finished (code: ${res.exit_code}): "${cmd}"')
			if res.output.trim_space().len > 0 {
				println('[simplegui SYSTEM] Output: ${res.output.trim_space()}')
			}
		}
	}(command, win.debug_mode)
	
	return win
}

// get_env retrieves the value of a system environment variable.
// Equivalent to Neutralino's `os.getEnv`.
pub fn (win &SimpleWindow) get_env(key string) string {
	return os.getenv(key)
}

// set_env sets a system environment variable for the application process.
// Equivalent to Neutralino's `os.setEnv`.
pub fn (win &SimpleWindow) set_env(key string, val string) &SimpleWindow {
	if win.debug_mode {
		println('[simplegui SYSTEM] Setting environment: ${key} = ${val}')
	}
	os.setenv(key, val, true)
	return win
}

// unset_env clears a system environment variable.
pub fn (win &SimpleWindow) unset_env(key string) &SimpleWindow {
	if win.debug_mode {
		println('[simplegui SYSTEM] Unsetting environment: ${key}')
	}
	os.unsetenv(key)
	return win
}

// show_system_notification triggers a native macOS system notification banner.
// Equivalent to Neutralino's `os.showNotification`. Uses AppleScript under the hood.
pub fn (win &SimpleWindow) show_system_notification(title string, message string) &SimpleWindow {
	if win.debug_mode {
		println('[simplegui SYSTEM] Triggering system notification: "${title}" - "${message}"')
	}
	// Escape double quotes for execution safety
	title_escaped := title.replace('"', '\\"')
	msg_escaped := message.replace('"', '\\"')
	cmd := "osascript -e 'display notification \"${msg_escaped}\" with title \"${title_escaped}\"'"
	win.exec_bg(cmd)
	return win
}

// ==========================================
// 2. Hardware and Computer Info (Neutralino NL_COMPUTER)
// ==========================================

// get_cpu_info retrieves the local computer's processor information.
// Equivalent to Neutralino's `computer.getCPUInfo`.
pub fn (win &SimpleWindow) get_cpu_info() string {
	return win.exec_or('sysctl -n machdep.cpu.brand_string', 'Unknown macOS CPU')
}

// get_cpu_cores retrieves the total CPU core count (physical + virtual).
pub fn (win &SimpleWindow) get_cpu_cores() int {
	cores_str := win.exec_or('sysctl -n hw.ncpu', '0')
	return cores_str.int()
}

// get_memory_info retrieves physical RAM details on the machine.
// Equivalent to Neutralino's `computer.getMemoryInfo`.
pub fn (win &SimpleWindow) get_memory_info() string {
	bytes_str := win.exec_or('sysctl -n hw.memsize', '')
	if bytes_str.len > 0 {
		bytes := bytes_str.u64()
		gb := f64(bytes) / (1024.0 * 1024.0 * 1024.0)
		return '${gb:.1f} GB RAM'
	}
	return 'Unknown RAM'
}

// ==========================================
// 3. System Directory Lookup (Neutralino os.getPath/NL_PATH)
// ==========================================

// get_system_path resolves paths to standard environment folders on macOS.
pub fn (win &SimpleWindow) get_system_path(name string) string {
	home := os.home_dir()
	return match name.to_lower() {
		'home' { home }
		'temp', 'tmp' { os.temp_dir() }
		'desktop' { os.join_path(home, 'Desktop') }
		'documents' { os.join_path(home, 'Documents') }
		'downloads' { os.join_path(home, 'Downloads') }
		'cache' { os.cache_dir() }
		'config' { os.config_dir() or { '' } }
		'data' { os.data_dir() }
		'app' { os.dir(os.executable()) }
		else { home }
	}
}

// ==========================================
// 4. File System Utilities (Neutralino NL_FILESYSTEM)
// ==========================================

// file_exists checks if a file or folder exists at the specified path.
pub fn (win &SimpleWindow) file_exists(path string) bool {
	return os.exists(path)
}

// is_dir checks if the given path is a directory.
pub fn (win &SimpleWindow) is_dir(path string) bool {
	return os.is_dir(path)
}

// read_file_opt reads file contents, returning a standard V Result string.
// Forces robust error propagation and aligns with V's Option & Result practices.
pub fn (win &SimpleWindow) read_file_opt(path string) !string {
	if !os.exists(path) {
		return error('File does not exist: ' + path)
	}
	content := os.read_file(path) or { return error(err.msg()) }
	return content
}

// read_file reads file contents, returning an empty string if reading fails.
pub fn (win &SimpleWindow) read_file(path string) string {
	res := win.read_file_opt(path) or { return '' }
	return res
}

// write_file_opt writes dynamic content to a file, returning a Result flag.
pub fn (win &SimpleWindow) write_file_opt(path string, content string) !&SimpleWindow {
	os.write_file(path, content) or { return error(err.msg()) }
	return win
}

// write_file writes dynamic content to a file. Silent if failed (errors out if debugging is enabled).
pub fn (win &SimpleWindow) write_file(path string, content string) &SimpleWindow {
	win.write_file_opt(path, content) or {
		if win.debug_mode {
			println('[simplegui ERROR] Failed to write to file "${path}": ${err}')
		}
	}
	return win
}

// delete_file deletes a file or directory path.
pub fn (win &SimpleWindow) delete_file(path string) &SimpleWindow {
	if win.debug_mode {
		println('[simplegui SYSTEM] Deleting path: "${path}"')
	}
	os.rm(path) or {
		if win.debug_mode {
			println('[simplegui ERROR] Failed to delete path: ${err}')
		}
	}
	return win
}

// create_directory recursively creates a nested directory structure/folder path.
pub fn (win &SimpleWindow) create_directory(path string) &SimpleWindow {
	if win.debug_mode {
		println('[simplegui SYSTEM] Creating directory tree: "${path}"')
	}
	os.mkdir_all(path) or {
		if win.debug_mode {
			println('[simplegui ERROR] Failed to create directories: ${err}')
		}
	}
	return win
}

// read_dir lists all filenames inside any target folder.
pub fn (win &SimpleWindow) read_dir(path string) []string {
	return os.ls(path) or { []string{} }
}

// ==========================================
// 5. New System Call & OS API Extensions (V standard library os/process/stat details)
// ==========================================

// DiskStats represents disk space utilization statistics.
pub struct DiskStats {
pub:
	total     u64
	available u64
	used      u64
}

// FileMetadata represents comprehensive file information and permissions.
pub struct FileMetadata {
pub:
	size          i64
	inode         u64
	nlink         u64
	dev           u64
	uid           u32
	gid           u32
	atime         i64
	mtime         i64
	ctime         i64
	file_type     string
	mode_bitmask  u32
	owner_r       bool
	owner_w       bool
	owner_x       bool
	group_r       bool
	group_w       bool
	group_x       bool
	others_r      bool
	others_w      bool
	others_x      bool
}

// SimpleProcess provides a high-level wrapper to control a background subprocess.
pub struct SimpleProcess {
pub mut:
	proc &os.Process = unsafe { nil }
}

// get_env_opt retrieves an environment variable value, returning none if it's not set.
pub fn (win &SimpleWindow) get_env_opt(key string) ?string {
	return os.getenv_opt(key)
}

// get_envs retrieves all system environment variables as a key-value map.
pub fn (win &SimpleWindow) get_envs() map[string]string {
	return os.environ()
}

// get_hostname retrieves the network hostname of the current machine.
pub fn (win &SimpleWindow) get_hostname() string {
	return os.hostname() or { 'unknown' }
}

// get_username retrieves the active username running the application.
pub fn (win &SimpleWindow) get_username() string {
	return os.loginname() or { 'unknown' }
}

// get_user_os returns a string identifying the host OS.
pub fn (win &SimpleWindow) get_user_os() string {
	return os.user_os()
}

// get_pid returns the current Process ID (PID).
pub fn (win &SimpleWindow) get_pid() int {
	return os.getpid()
}

// get_ppid returns the Parent Process ID (PPID).
pub fn (win &SimpleWindow) get_ppid() int {
	return os.getppid()
}

// get_uid returns the real User ID (UID).
pub fn (win &SimpleWindow) get_uid() int {
	return os.getuid()
}

// get_gid returns the real Group ID (GID).
pub fn (win &SimpleWindow) get_gid() int {
	return os.getgid()
}

// get_euid returns the effective User ID (EUID).
pub fn (win &SimpleWindow) get_euid() int {
	return os.geteuid()
}

// get_egid returns the effective Group ID (EGID).
pub fn (win &SimpleWindow) get_egid() int {
	return os.getegid()
}

// exists_in_path checks if a given executable/command binary is present in the system's PATH.
pub fn (win &SimpleWindow) exists_in_path(cmd string) bool {
	return os.exists_in_system_path(cmd)
}

// find_executable returns the absolute path of the specified command binary if it exists in the system's PATH.
pub fn (win &SimpleWindow) find_executable(cmd string) string {
	return os.find_abs_path_of_executable(cmd) or { '' }
}

// get_executable_path returns the absolute path of the current running executable.
pub fn (win &SimpleWindow) get_executable_path() string {
	return os.executable()
}

// get_disk_usage retrieves disk space usage statistics for the given folder/path.
pub fn (win &SimpleWindow) get_disk_usage(path string) !DiskStats {
	du := os.disk_usage(path)!
	return DiskStats{
		total: du.total
		available: du.available
		used: du.used
	}
}

// write_lines writes an array of strings to a file, separating them with newlines.
pub fn (win &SimpleWindow) write_lines(path string, lines []string) !&SimpleWindow {
	os.write_lines(path, lines)!
	return win
}

// read_lines reads a file line-by-line and returns an array of strings.
pub fn (win &SimpleWindow) read_lines(path string) ![]string {
	return os.read_lines(path)!
}

// write_bytes writes a byte array to a file.
pub fn (win &SimpleWindow) write_bytes(path string, bytes []u8) !&SimpleWindow {
	os.write_bytes(path, bytes)!
	return win
}

// read_bytes reads a file's content as a byte array.
pub fn (win &SimpleWindow) read_bytes(path string) ![]u8 {
	return os.read_bytes(path)!
}

// is_file returns true if the path points to a regular file.
pub fn (win &SimpleWindow) is_file(path string) bool {
	return os.is_file(path)
}

// is_dir_empty checks if the directory has no files or subfolders.
pub fn (win &SimpleWindow) is_dir_empty(path string) bool {
	return os.is_dir_empty(path)
}

// create_single_directory creates a single new directory (non-recursive).
pub fn (win &SimpleWindow) create_single_directory(path string) !&SimpleWindow {
	os.mkdir(path)!
	return win
}

// delete_single_directory deletes a single empty directory.
pub fn (win &SimpleWindow) delete_single_directory(path string) !&SimpleWindow {
	os.rmdir(path)!
	return win
}

// delete_directory recursively removes a directory and all of its contents (rmdir_all).
pub fn (win &SimpleWindow) delete_directory(path string) !&SimpleWindow {
	os.rmdir_all(path)!
	return win
}

// copy_file copies a file from a source path to a destination path.
pub fn (win &SimpleWindow) copy_file(src string, dest string) !&SimpleWindow {
	os.cp(src, dest)!
	return win
}

// move_file moves or renames a file.
pub fn (win &SimpleWindow) move_file(src string, dest string) !&SimpleWindow {
	os.mv(src, dest)!
	return win
}

// create_symlink creates a symbolic link pointing to a target path.
pub fn (win &SimpleWindow) create_symlink(target string, linkpath string) !&SimpleWindow {
	os.symlink(target, linkpath)!
	return win
}

// is_symlink checks if a path points to a symbolic link.
pub fn (win &SimpleWindow) is_symlink(path string) bool {
	return os.is_link(path)
}

// get_working_directory returns the current active working directory.
pub fn (win &SimpleWindow) get_working_directory() string {
	return os.getwd()
}

// set_working_directory changes the current active working directory.
pub fn (win &SimpleWindow) set_working_directory(path string) !&SimpleWindow {
	os.chdir(path)!
	return win
}

// get_file_size returns the size of a file in bytes.
pub fn (win &SimpleWindow) get_file_size(path string) !i64 {
	st := os.stat(path)!
	return st.size
}

// get_last_modified returns the Unix timestamp when the file was last modified.
pub fn (win &SimpleWindow) get_last_modified(path string) i64 {
	return os.file_last_mod_unix(path)
}

// glob finds all files matching a wildcard pattern (e.g. *.txt).
pub fn (win &SimpleWindow) glob(pattern string) ![]string {
	return os.glob(pattern)!
}

// walk recursively traverses a directory, executing a callback function for each file found.
pub fn (win &SimpleWindow) walk(path string, callback fn (string)) {
	os.walk(path, callback)
}

// walk_ext traverses a directory, returning a list of files that match a file extension filter (e.g. ".txt").
pub fn (win &SimpleWindow) walk_ext(path string, ext string) []string {
	return os.walk_ext(path, ext, os.WalkParams{})
}

// set_permissions changes the permission bits on a file.
pub fn (win &SimpleWindow) set_permissions(path string, mode int) !&SimpleWindow {
	os.chmod(path, mode)!
	return win
}

// set_ownership changes the owner user ID (UID) and group ID (GID) of a file.
pub fn (win &SimpleWindow) set_ownership(path string, uid int, gid int) !&SimpleWindow {
	os.chown(path, uid, gid)!
	return win
}

// is_readable checks if a path is readable.
pub fn (win &SimpleWindow) is_readable(path string) bool {
	return os.is_readable(path)
}

// is_writable checks if a path is writable.
pub fn (win &SimpleWindow) is_writable(path string) bool {
	return os.is_writable(path)
}

// is_executable checks if a path is executable.
pub fn (win &SimpleWindow) is_executable(path string) bool {
	return os.is_executable(path)
}

// path_dir returns the parent directory of the path.
pub fn (win &SimpleWindow) path_dir(path string) string {
	return os.dir(path)
}

// path_base returns the last element of the path.
pub fn (win &SimpleWindow) path_base(path string) string {
	return os.base(path)
}

// path_ext returns the file extension of the path (including the dot).
pub fn (win &SimpleWindow) path_ext(path string) string {
	return os.file_ext(path)
}

// path_name returns the filename without the path.
pub fn (win &SimpleWindow) path_name(path string) string {
	return os.file_name(path)
}

// path_is_abs checks if the path is an absolute path.
pub fn (win &SimpleWindow) path_is_abs(path string) bool {
	return os.is_abs_path(path)
}

// path_real resolves all symbolic links and relative references to return an absolute path.
pub fn (win &SimpleWindow) path_real(path string) string {
	return os.real_path(path)
}

// path_norm normalizes path separators.
pub fn (win &SimpleWindow) path_norm(path string) string {
	return os.norm_path(path)
}

// path_split splits a path into (directory, filename, extension).
pub fn (win &SimpleWindow) path_split(path string) (string, string, string) {
	return os.split_path(path)
}

// get_file_metadata retrieves detailed metadata (size, timestamps, owners, permissions) for the file at the given path.
pub fn (win &SimpleWindow) get_file_metadata(path string) !FileMetadata {
	st := os.stat(path)!
	fm := st.get_mode()
	return FileMetadata{
		size: st.size
		inode: st.inode
		nlink: st.nlink
		dev: st.dev
		uid: st.uid
		gid: st.gid
		atime: st.atime
		mtime: st.mtime
		ctime: st.ctime
		file_type: st.get_filetype().str()
		mode_bitmask: fm.bitmask()
		owner_r: fm.owner.read
		owner_w: fm.owner.write
		owner_x: fm.owner.execute
		group_r: fm.group.read
		group_w: fm.group.write
		group_x: fm.group.execute
		others_r: fm.others.read
		others_w: fm.others.write
		others_x: fm.others.execute
	}
}

// spawn_process starts a background subprocess with stdout/stderr redirected.
pub fn (win &SimpleWindow) spawn_process(path string, args []string, env map[string]string) !&SimpleProcess {
	mut p := os.new_process(path)
	p.set_args(args)
	p.set_environment(env)
	p.set_redirect_stdio()
	p.use_stdio_ctl = true
	p.run()
	return &SimpleProcess{
		proc: p
	}
}

// is_alive checks if the child process is still running.
pub fn (mut sp SimpleProcess) is_alive() bool {
	if sp.proc == unsafe { nil } {
		return false
	}
	return sp.proc.is_alive()
}

// write sends input data to the process's standard input.
pub fn (mut sp SimpleProcess) write(data string) {
	if sp.proc == unsafe { nil } {
		return
	}
	sp.proc.stdin_write(data)
}

// read reads any output currently available in the process's stdout pipe.
pub fn (mut sp SimpleProcess) read() string {
	if sp.proc == unsafe { nil } {
		return ''
	}
	return sp.proc.stdout_read()
}

// stop suspends the process using a POSIX SIGSTOP signal.
pub fn (mut sp SimpleProcess) stop() {
	if sp.proc != unsafe { nil } {
		sp.proc.signal_stop()
	}
}

// resume resumes a suspended process using a POSIX SIGCONT signal.
pub fn (mut sp SimpleProcess) resume() {
	if sp.proc != unsafe { nil } {
		sp.proc.signal_continue()
	}
}

// terminate terminates the process using a POSIX SIGTERM signal.
pub fn (mut sp SimpleProcess) terminate() {
	if sp.proc != unsafe { nil } {
		sp.proc.signal_term()
	}
}

// wait waits for the subprocess to exit and blocks until completion.
pub fn (mut sp SimpleProcess) wait() {
	if sp.proc != unsafe { nil } {
		sp.proc.wait()
	}
}

// close cleans up and releases process resources.
pub fn (mut sp SimpleProcess) close() {
	if sp.proc != unsafe { nil } {
		sp.proc.close()
	}
}

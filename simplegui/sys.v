module simplegui

import os
import time
import net
import net.http

#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/time.h>

// C function declarations for direct POSIX/BSD system calls used in this file.
fn C.getloadavg(loadavg &f64, nelem int) int
fn C.sysctl(name &int, namelen u32, oldp voidptr, oldlenp &usize, newp voidptr, newlen usize) int

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
	size         i64
	inode        u64
	nlink        u64
	dev          u64
	uid          u32
	gid          u32
	atime        i64
	mtime        i64
	ctime        i64
	file_type    string
	mode_bitmask u32
	owner_r      bool
	owner_w      bool
	owner_x      bool
	group_r      bool
	group_w      bool
	group_x      bool
	others_r     bool
	others_w     bool
	others_x     bool
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
		total:     du.total
		available: du.available
		used:      du.used
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
		size:         st.size
		inode:        st.inode
		nlink:        st.nlink
		dev:          st.dev
		uid:          st.uid
		gid:          st.gid
		atime:        st.atime
		mtime:        st.mtime
		ctime:        st.ctime
		file_type:    st.get_filetype().str()
		mode_bitmask: fm.bitmask()
		owner_r:      fm.owner.read
		owner_w:      fm.owner.write
		owner_x:      fm.owner.execute
		group_r:      fm.group.read
		group_w:      fm.group.write
		group_x:      fm.group.execute
		others_r:     fm.others.read
		others_w:     fm.others.write
		others_x:     fm.others.execute
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

// Uname represents kernel and operating system description details.
pub struct Uname {
pub:
	sysname  string
	nodename string
	release  string
	version  string
	machine  string
}

// get_uname retrieves system operating system and kernel architecture details.
pub fn (win &SimpleWindow) get_uname() Uname {
	u := os.uname()
	return Uname{
		sysname:  u.sysname
		nodename: u.nodename
		release:  u.release
		version:  u.version
		machine:  u.machine
	}
}

// ==========================================
// 6. System Clock & Time
// ==========================================


// SystemTime holds a structured representation of the current local time.
pub struct SystemTime {
pub:
	year        int
	month       int
	day         int
	hour        int
	minute      int
	second      int
	unix_epoch  i64
	unix_milli  i64
	rfc3339     string
	weekday     string
}

// get_time returns the current local date and time packed into a SystemTime struct.
pub fn (win &SimpleWindow) get_time() SystemTime {
	now := time.now()
	return SystemTime{
		year:       now.year
		month:      now.month
		day:        now.day
		hour:       now.hour
		minute:     now.minute
		second:     now.second
		unix_epoch: now.unix()
		unix_milli: now.unix_milli()
		rfc3339:    now.format_rfc3339()
		weekday:    now.weekday_str()
	}
}

// get_unix_epoch returns the current time as a Unix epoch timestamp (seconds since 1970-01-01).
pub fn (win &SimpleWindow) get_unix_epoch() i64 {
	return time.now().unix()
}

// get_unix_milli returns the current time as a Unix epoch in milliseconds.
pub fn (win &SimpleWindow) get_unix_milli() i64 {
	return time.now().unix_milli()
}

// get_time_formatted returns the current local time as a formatted string.
// format uses V's time.Time.custom_format(), e.g. "YYYY-MM-DD HH:mm:ss".
pub fn (win &SimpleWindow) get_time_formatted(format string) string {
	return time.now().custom_format(format)
}

// sleep_ms pauses execution for the specified number of milliseconds (blocking).
// Use exec_bg/spawn to avoid freezing the Cocoa UI event loop.
pub fn (win &SimpleWindow) sleep_ms(ms u64) &SimpleWindow {
	time.sleep(ms * time.millisecond)
	return win
}

// get_uptime_seconds returns how long the macOS system has been running (in seconds).
// Uses C sysctl() directly via V's C interop — no subprocess required.
pub fn (win &SimpleWindow) get_uptime_seconds() i64 {
	// kern.boottime is a struct timeval { tv_sec, tv_usec }
	$if macos || freebsd {
		mib := [C.CTL_KERN, C.KERN_BOOTTIME]!
		tv := C.timeval{}
		sz := usize(sizeof(C.timeval))
		if unsafe { C.sysctl(&mib[0], 2, &tv, &sz, nil, 0) } == 0 {
			return time.now().unix() - i64(tv.tv_sec)
		}
	}
	// Fallback: parse sysctl text output on other POSIX systems
	raw := win.exec_or('sysctl -n kern.boottime', '')
	if raw.len > 0 {
		parts := raw.split('=')
		if parts.len >= 2 {
			boot_sec := parts[1].trim_space().split(',')[0].trim_space().i64()
			return time.now().unix() - boot_sec
		}
	}
	return 0
}

// ==========================================
// 7. Clipboard
// NOTE: clipboard_copy(text) and clipboard_read() are implemented in stdlib.v
// using the native V `clipboard` module. Use those methods on SimpleWindow.
// ==========================================

// ==========================================
// 8. macOS Open / Reveal Commands
// ==========================================

// NOTE: open_url(url) is already implemented in simplegui.v via the native Cocoa C bridge.
// Use win.open_url(url) directly — it calls window_open_url() in the Objective-C layer.

// reveal_in_finder opens and highlights a file or folder in macOS Finder.
pub fn (win &SimpleWindow) reveal_in_finder(path string) &SimpleWindow {
	if win.debug_mode {
		println('[simplegui SYSTEM] Revealing in Finder: ${path}')
	}
	win.exec_bg('open -R "${path}"')
	return win
}

// open_in_default_app opens a file with its default associated application.
pub fn (win &SimpleWindow) open_in_default_app(path string) &SimpleWindow {
	if win.debug_mode {
		println('[simplegui SYSTEM] Opening file with default app: ${path}')
	}
	win.exec_bg('open "${path}"')
	return win
}

// open_with_app opens a file using a specific application by bundle ID or app name.
// Example: win.open_with_app('/path/to/file.txt', 'com.apple.TextEdit')
pub fn (win &SimpleWindow) open_with_app(path string, app_id string) &SimpleWindow {
	if win.debug_mode {
		println('[simplegui SYSTEM] Opening "${path}" with app: ${app_id}')
	}
	win.exec_bg('open -a "${app_id}" "${path}"')
	return win
}

// open_terminal opens a new macOS Terminal window.
pub fn (win &SimpleWindow) open_terminal() &SimpleWindow {
	win.exec_bg('open -a Terminal')
	return win
}

// ==========================================
// 9. Network Utilities
// ==========================================

// get_local_ip returns the primary local IP address of this machine.
// Uses os.hostname() + net.resolve_ipaddrs() — no subprocess required.
pub fn (win &SimpleWindow) get_local_ip() string {
	// Resolve the machine's own hostname to get its primary IP
	host := os.hostname() or { return 'unavailable' }
	addrs := net.resolve_ipaddrs(host, .ip, .tcp) or {
		// Fallback: if hostname resolution fails, return unavailable
		return 'unavailable'
	}
	for addr in addrs {
		s := addr.str()
		// Skip loopback addresses (127.x.x.x)
		if !s.starts_with('127.') && !s.starts_with('::1') {
			// strip port suffix if present
			return s.split(':')[0]
		}
	}
	// Return loopback as last resort
	if addrs.len > 0 {
		return addrs[0].str().split(':')[0]
	}
	return 'unavailable'
}

// get_external_ip fetches the machine's public/external IP address using a fast curl request with fallback.
// Uses a 2-second timeout to prevent UI freezes.
pub fn (win &SimpleWindow) get_external_ip() string {
	res := win.exec_or('curl -s --max-time 2 https://api.ipify.org', '')
	if res.len > 0 && !res.contains('html') && !res.contains('error') {
		return res.trim_space()
	}
	resp := http.get('https://api.ipify.org') or { return 'unavailable' }
	if resp.status_code == 200 {
		return resp.body.trim_space()
	}
	return 'unavailable'
}

// ping tests network connectivity to a host. Returns true if the host is reachable.
// Uses macOS netcat with a 1-second connection timeout — non-blocking and fast.
pub fn (win &SimpleWindow) ping(host string, count int) bool {
	iterations := if count < 1 { 1 } else { count }
	for _ in 0 .. iterations {
		_, code80 := win.exec('nc -z -G 1 "${host}" 80 2>/dev/null')
		if code80 == 0 {
			return true
		}
		_, code443 := win.exec('nc -z -G 1 "${host}" 443 2>/dev/null')
		if code443 == 0 {
			return true
		}
	}
	return false
}

// dns_lookup performs a DNS forward lookup, returning the resolved IP address.
// Uses net.resolve_ipaddrs() — direct libc getaddrinfo(), no subprocess.
pub fn (win &SimpleWindow) dns_lookup(hostname string) string {
	addrs := net.resolve_ipaddrs(hostname, .ip, .tcp) or { return '' }
	if addrs.len > 0 {
		// addr.str() gives "IP:port" — return just the IP part
		return addrs[0].str().split(':')[0]
	}
	return ''
}

// get_wifi_ssid returns the SSID of the currently connected Wi-Fi network (macOS).
// Uses fast ipconfig getsummary, falling back to the airport tool.
pub fn (win &SimpleWindow) get_wifi_ssid() string {
	ssid_ip := win.exec_or("ipconfig getsummary en0 2>/dev/null | awk -F ' : ' '/ SSID /{print $2}'", '').trim_space()
	if ssid_ip.len > 0 {
		return ssid_ip
	}
	return win.exec_or(
		'/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I 2>/dev/null | awk \'/ SSID:/{print $2}\'',
		'').trim_space()
}

// get_network_interfaces lists all active network interface names on the machine.
// No V stdlib API exists for enumerating interfaces; uses ifconfig.
pub fn (win &SimpleWindow) get_network_interfaces() []string {
	raw := win.exec_or('ifconfig -l', '')
	return raw.trim_space().split(' ').filter(it.len > 0)
}

// ==========================================
// 10. System Resource Monitoring
// ==========================================

// get_cpu_usage_percent returns an instantaneous CPU usage percentage estimate (macOS).
// Uses `ps` to aggregate all process CPU usage — a quick approximation.
pub fn (win &SimpleWindow) get_cpu_usage_percent() f64 {
	raw := win.exec_or("ps -A -o %cpu | awk '{s+=$1} END {print s}'", '0')
	return raw.trim_space().f64()
}

// get_load_average returns the 1, 5, and 15 minute system load averages.
// Uses C getloadavg() via V C interop on POSIX systems — no subprocess.
pub fn (win &SimpleWindow) get_load_average() (f64, f64, f64) {
	$if macos || linux || freebsd {
		loadavg := [f64(0), f64(0), f64(0)]!
		if C.getloadavg(&loadavg[0], 3) == 3 {
			return loadavg[0], loadavg[1], loadavg[2]
		}
	}
	// Fallback: parse sysctl text on other systems
	raw := win.exec_or('sysctl -n vm.loadavg', '{ 0.00 0.00 0.00 }')
	clean := raw.trim_space().trim('{').trim('}').trim_space()
	parts := clean.split(' ').filter(it.len > 0)
	if parts.len >= 3 {
		return parts[0].f64(), parts[1].f64(), parts[2].f64()
	}
	return 0.0, 0.0, 0.0
}

// get_memory_pressure returns a macOS memory pressure string: "normal", "warn", or "critical".
// Uses sysctl for sub-millisecond kernel lookup.
pub fn (win &SimpleWindow) get_memory_pressure() string {
	level := win.exec_or('sysctl -n kern.memorystatus_vm_pressure_level 2>/dev/null', '').trim_space().int()
	if level >= 4 {
		return 'critical'
	} else if level >= 2 {
		return 'warn'
	} else if level == 1 {
		return 'normal'
	}
	raw := win.exec_or('sysctl -n vm.memory_pressure 2>/dev/null', '')
	lower := raw.to_lower()
	if lower.contains('critical') {
		return 'critical'
	} else if lower.contains('warn') {
		return 'warn'
	}
	return 'normal'
}

// get_running_process_count returns the total number of running processes.
pub fn (win &SimpleWindow) get_running_process_count() int {
	raw := win.exec_or('ps -A | wc -l', '0')
	return raw.trim_space().int()
}

// get_open_file_count returns the total count of open file descriptors in the system.
pub fn (win &SimpleWindow) get_open_file_count() int {
	raw := win.exec_or('sysctl -n kern.num_files', '0')
	return raw.trim_space().int()
}

// get_swap_usage returns a human-readable description of current macOS swap usage.
pub fn (win &SimpleWindow) get_swap_usage() string {
	return win.exec_or('sysctl -n vm.swapusage', 'unknown').trim_space()
}

// ==========================================
// 11. Terminal / Shell Utilities
// ==========================================

// beep plays the macOS system alert sound (NSBeep) using osascript.
pub fn (win &SimpleWindow) beep() &SimpleWindow {
	win.exec_bg("osascript -e 'beep'")
	return win
}

// beep_n plays the macOS system alert sound n times.
pub fn (win &SimpleWindow) beep_n(n int) &SimpleWindow {
	count := if n < 1 { 1 } else { n }
	win.exec_bg("osascript -e 'beep ${count}'")
	return win
}

// osascript_dialog shows a native macOS input dialog box and returns what the user typed.
// Returns an empty string if the user cancels.
pub fn (win &SimpleWindow) osascript_dialog(prompt string, default_value string) string {
	prompt_esc := prompt.replace('"', '\\"')
	default_esc := default_value.replace('"', '\\"')
	script := 'osascript -e \'set ans to text returned of (display dialog "${prompt_esc}" default answer "${default_esc}" buttons {"Cancel","OK"} default button "OK")\''
	output, code := win.exec(script)
	if code == 0 {
		return output.trim_space()
	}
	return ''
}

// osascript_alert shows a native macOS alert dialog with a message.
// Blocks until the user clicks OK or Cancel. Returns true if OK was clicked.
pub fn (win &SimpleWindow) osascript_alert(title string, message string) bool {
	title_esc := title.replace('"', '\\"')
	msg_esc := message.replace('"', '\\"')
	script := 'osascript -e \'button returned of (display alert "${title_esc}" message "${msg_esc}" buttons {"Cancel","OK"} default button "OK")\''
	output, code := win.exec(script)
	if code == 0 {
		return output.trim_space() == 'OK'
	}
	return false
}

// osascript_choose_file shows a native macOS file-picker dialog and returns the chosen path.
// Returns an empty string if cancelled.
pub fn (win &SimpleWindow) osascript_choose_file() string {
	script := "osascript -e 'POSIX path of (choose file)'"
	output, code := win.exec(script)
	if code == 0 {
		return output.trim_space()
	}
	return ''
}

// osascript_choose_folder shows a native macOS folder-picker dialog and returns the chosen path.
// Returns an empty string if cancelled.
pub fn (win &SimpleWindow) osascript_choose_folder() string {
	script := "osascript -e 'POSIX path of (choose folder)'"
	output, code := win.exec(script)
	if code == 0 {
		return output.trim_space()
	}
	return ''
}

// say uses macOS text-to-speech to speak a message out loud.
pub fn (win &SimpleWindow) say(text string) &SimpleWindow {
	escaped := text.replace('"', '\\"')
	win.exec_bg('say "${escaped}"')
	return win
}

// ==========================================
// 12. macOS-Specific System Information
// ==========================================

// system_version_plist_value reads a key from the macOS SystemVersion.plist file
// using pure V file I/O — no sw_vers subprocess required.
fn system_version_plist_value(key string) string {
	plist_path := '/System/Library/CoreServices/SystemVersion.plist'
	content := os.read_file(plist_path) or { return 'unknown' }
	// Simple linear search for the key/value pair in plist XML:
	// <key>ProductVersion</key><string>14.5</string>
	key_tag := '<key>${key}</key>'
	key_idx := content.index(key_tag) or { return 'unknown' }
	after_key := content[key_idx + key_tag.len..]
	val_start_tag := '<string>'
	val_end_tag := '</string>'
	val_start := after_key.index(val_start_tag) or { return 'unknown' }
	after_start := after_key[val_start + val_start_tag.len..]
	val_end := after_start.index(val_end_tag) or { return 'unknown' }
	return after_start[..val_end].trim_space()
}

// get_macos_version returns the human-readable macOS version string (e.g. "14.5").
// Reads /System/Library/CoreServices/SystemVersion.plist directly — no sw_vers subprocess.
pub fn (win &SimpleWindow) get_macos_version() string {
	return system_version_plist_value('ProductVersion')
}

// get_macos_build returns the macOS build number (e.g. "23F79").
// Reads /System/Library/CoreServices/SystemVersion.plist directly — no sw_vers subprocess.
pub fn (win &SimpleWindow) get_macos_build() string {
	return system_version_plist_value('ProductBuildVersion')
}

// get_macos_product_name returns the product name (e.g. "macOS", "Mac OS X").
// Reads /System/Library/CoreServices/SystemVersion.plist directly — no sw_vers subprocess.
pub fn (win &SimpleWindow) get_macos_product_name() string {
	return system_version_plist_value('ProductName')
}

// get_device_model returns the hardware model identifier (e.g. "MacBookPro18,3").
pub fn (win &SimpleWindow) get_device_model() string {
	return win.exec_or('sysctl -n hw.model', 'unknown').trim_space()
}

// get_serial_number returns the device serial number.
// Uses targeted ioreg query for sub-millisecond resolution.
pub fn (win &SimpleWindow) get_serial_number() string {
	return win.exec_or(
		"ioreg -c IOPlatformExpertDevice 2>/dev/null | awk -F '\"' '/IOPlatformSerialNumber/{print $4}'",
		'unavailable').trim_space()
}

// get_screen_resolution returns the primary display resolution (e.g. "2560 x 1600").
// Uses fast AppleScript desktop query with fallback.
pub fn (win &SimpleWindow) get_screen_resolution() string {
	raw := win.exec_or(
		"osascript -e 'tell application \"Finder\" to get bounds of window of desktop' 2>/dev/null",
		'')
	if raw.len > 0 {
		parts := raw.split(',').map(it.trim_space())
		if parts.len >= 4 {
			return '${parts[2]} x ${parts[3]}'
		}
	}
	return win.exec_or(
		"system_profiler SPDisplaysDataType 2>/dev/null | awk '/Resolution:/{print $2\" x \"$4; exit}'",
		'unknown').trim_space()
}

// get_gpu_info returns the GPU model string of the primary graphics adapter.
// Uses fast IOPCIDevice ioreg lookup with fallback.
pub fn (win &SimpleWindow) get_gpu_info() string {
	ioreg_gpu := win.exec_or(
		"ioreg -rc IOPCIDevice 2>/dev/null | awk -F '\"' '/\"model\" = /{print $4}' | head -1",
		'').trim_space()
	if ioreg_gpu.len > 0 {
		return ioreg_gpu
	}
	return win.exec_or(
		"system_profiler SPDisplaysDataType 2>/dev/null | awk '/Chipset Model:/{sub(/.*Chipset Model: /,\"\"); print; exit}'",
		'unknown').trim_space()
}

// get_battery_percent returns the battery charge percentage, or -1 if no battery is present.
pub fn (win &SimpleWindow) get_battery_percent() int {
	raw := win.exec_or(
		"pmset -g batt 2>/dev/null | grep -oE '[0-9]+%' | head -1 | tr -d '%'",
		'')
	pct := raw.trim_space()
	if pct.len == 0 {
		return -1
	}
	return pct.int()
}

// is_on_ac_power returns true if the machine is currently plugged into AC power.
pub fn (win &SimpleWindow) is_on_ac_power() bool {
	raw := win.exec_or("pmset -g batt 2>/dev/null | head -1", '')
	return raw.contains("AC Power")
}

// get_app_bundle_id returns the bundle identifier of the running app (macOS bundles only).
// Reads Info.plist directly with os.read_file() — no defaults subprocess.
pub fn (win &SimpleWindow) get_app_bundle_id() string {
	exe := os.executable()
	// In a .app bundle the plist is at Contents/Info.plist relative to the binary
	plist_path := os.join_path(os.dir(exe), '..', 'Info.plist')
	if os.exists(plist_path) {
		content := os.read_file(plist_path) or { return '' }
		key_tag := '<key>CFBundleIdentifier</key>'
		key_idx := content.index(key_tag) or { return '' }
		after_key := content[key_idx + key_tag.len..]
		val_start_tag := '<string>'
		val_end_tag := '</string>'
		val_start := after_key.index(val_start_tag) or { return '' }
		after_start := after_key[val_start + val_start_tag.len..]
		val_end := after_start.index(val_end_tag) or { return '' }
		return after_start[..val_end].trim_space()
	}
	return ''
}

// get_system_locale returns the primary locale string configured on the system (e.g. "en_US").
// Reads standard POSIX locale environment variables via os.getenv() — no subprocess.
pub fn (win &SimpleWindow) get_system_locale() string {
	// Check standard POSIX locale env vars in priority order
	for key in ['LC_ALL', 'LC_MESSAGES', 'LANG'] {
		val := os.getenv(key)
		if val.len > 0 {
			// Strip encoding suffix: "en_US.UTF-8" -> "en_US"
			return val.split('.')[0]
		}
	}
	// macOS fallback: read AppleLocale from the user defaults plist directly
	plist := os.join_path(os.home_dir(), 'Library', 'Preferences', '.GlobalPreferences.plist')
	if os.exists(plist) {
		raw := win.exec_or("defaults read NSGlobalDomain AppleLocale 2>/dev/null", '')
		if raw.len > 0 {
			return raw.trim_space()
		}
	}
	return 'unknown'
}

// get_timezone returns the current system timezone string (e.g. "America/Chicago").
// Uses os.real_path() on /etc/localtime — pure V, no readlink/sed subprocess.
pub fn (win &SimpleWindow) get_timezone() string {
	// /etc/localtime is a symlink to the active zoneinfo file
	resolved := os.real_path('/etc/localtime')
	// Strip the zoneinfo prefix to get just the timezone name
	for prefix in ['/var/db/timezone/zoneinfo/', '/usr/share/zoneinfo/', '/usr/lib/zoneinfo/'] {
		if resolved.starts_with(prefix) {
			return resolved[prefix.len..]
		}
	}
	// Final fallback: check the TZ environment variable
	tz := os.getenv('TZ')
	if tz.len > 0 {
		return tz
	}
	return 'unknown'
}

// launch_at_login_add registers the current application with macOS Login Items so it
// auto-launches when the user logs in. Uses osascript/launchctl (best-effort).
pub fn (win &SimpleWindow) launch_at_login_add(app_name_or_path string) &SimpleWindow {
	escaped := app_name_or_path.replace('"', '\\"')
	script := 'osascript -e \'tell application "System Events" to make login item at end with properties {path:"${escaped}", hidden:false}\''
	win.exec_bg(script)
	return win
}

// launch_at_login_remove removes the application from macOS Login Items.
pub fn (win &SimpleWindow) launch_at_login_remove(app_name string) &SimpleWindow {
	escaped := app_name.replace('"', '\\"')
	script := 'osascript -e \'tell application "System Events" to delete login item "${escaped}"\''
	win.exec_bg(script)
	return win
}

// set_dock_badge sets the macOS Dock badge count for the current application.
// Pass 0 to clear the badge.
pub fn (win &SimpleWindow) set_dock_badge(count int) &SimpleWindow {
	if count <= 0 {
		win.exec_bg("osascript -e 'tell application \"System Events\" to set the dock badge of the front application to 0'")
	} else {
		win.exec_bg("osascript -e 'tell application \"System Events\" to set the dock badge of the front application to ${count}'")
	}
	return win
}

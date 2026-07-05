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
		'cache' { os.join_path(home, 'Library/Caches') }
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

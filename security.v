module simplegui

import os
import time

// quote_arg escapes a string so that it can be safely used as a single shell argument.
// Uses strict POSIX single-quote wrapping: wraps in '...' and replaces internal ' with '\''.
pub fn quote_arg(s string) string {
	if s == '' {
		return "''"
	}
	return "'" + s.replace("'", "'\\''") + "'"
}

// quote_path validates that a path does not contain null bytes and safely quotes it.
pub fn quote_path(path string) string {
	clean := path.replace('\x00', '').trim_space()
	return quote_arg(clean)
}

// exec_safe executes a binary with an array of arguments, ensuring every argument
// is strictly quoted with quote_arg to prevent command injection and shell syntax errors.
pub fn exec_safe(bin string, args []string) os.Result {
	safe_bin := quote_arg(bin)
	mut safe_args := []string{}
	for a in args {
		safe_args << quote_arg(a)
	}
	cmd := '${safe_bin} ${safe_args.join(' ')}'
	return os.execute(cmd)
}

// exec_safe_stdin executes a binary with arguments while piping standard input from a target file
// (or raw text string if input_file is not an existing path on disk) securely.
pub fn exec_safe_stdin(bin string, args []string, input_file string) os.Result {
	if input_file != '' && os.is_file(input_file) {
		safe_bin := quote_arg(bin)
		mut safe_args := []string{}
		for a in args {
			safe_args << quote_arg(a)
		}
		cmd := '${safe_bin} ${safe_args.join(' ')} < ${quote_path(input_file)}'
		return os.execute(cmd)
	}
	return exec_safe_input(bin, args, input_file)
}

// exec_safe_input executes a binary with arguments while piping raw text into standard input via a temporary file.
pub fn exec_safe_input(bin string, args []string, stdin_text string) os.Result {
	tmp_path := os.join_path(os.temp_dir(), 'simplegui_stdin_${os.getpid()}_${time.now().unix_nano()}.tmp')
	os.write_file(tmp_path, '') or {
		return os.Result{
			exit_code: 1
			output:    err.msg()
		}
	}
	$if !windows {
		os.chmod(tmp_path, 0o600) or {}
	}
	os.write_file(tmp_path, stdin_text) or {
		os.rm(tmp_path) or {}
		return os.Result{
			exit_code: 1
			output:    err.msg()
		}
	}
	defer {
		os.rm(tmp_path) or {}
	}
	safe_bin := quote_arg(bin)
	mut safe_args := []string{}
	for a in args {
		safe_args << quote_arg(a)
	}
	cmd := '${safe_bin} ${safe_args.join(' ')} < ${quote_path(tmp_path)}'
	return os.execute(cmd)
}

// expand_tilde expands a leading '~' or '~/' to the user's home directory without corrupting mid-path '~' characters.
pub fn expand_tilde(path string) string {
	trimmed := path.trim_space()
	if trimmed == '~' {
		return os.home_dir()
	}
	if trimmed.starts_with('~/') {
		return os.join_path(os.home_dir(), trimmed[2..])
	}
	return trimmed
}

// sanitize_filename strips path traversal and shell metacharacters from user-provided file names.
pub fn sanitize_filename(name string) string {
	mut s := name.replace('\x00', '').replace('\r', '_').replace('\n', '_').replace('\t', '_')
	s = s.replace('/', '_').replace('\\', '_').replace(':', '_')
	s = s.replace(';', '_').replace('&', '_').replace('|', '_').replace('`', '_').replace('$', '_')
	s = s.replace('(', '_').replace(')', '_').replace('"', '_').replace("'", '_')
	s = s.replace('<', '_').replace('>', '_').replace('*', '_').replace('?', '_').trim_space()
	if s == '.' || s == '..' {
		return '_'.repeat(s.len)
	}
	return s
}


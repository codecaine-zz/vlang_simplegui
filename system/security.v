module system

import os
import time
import crypto.rand as crand
import encoding.hex

// =============================================================================
// Security Utilities - Cross-Platform Command Injection & Path Traversal Guards
// =============================================================================

// quote_arg escapes a string so that it can be safely used as a single shell argument.
// Uses strict POSIX single-quote wrapping: wraps in '...' and replaces internal ' with '\''.
// On Windows, wraps in double-quotes and escapes inner quotes.
pub fn quote_arg(s string) string {
	clean := s.replace('\x00', '')
	if clean == '' {
		$if windows {
			return '""'
		} $else {
			return "''"
		}
	}
	$if windows {
		return '"' + clean.replace('"', '""') + '"'
	} $else {
		return "'" + clean.replace("'", "'\\''") + "'"
	}
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
	cmd := '${safe_bin} ${safe_args.join(' ')} 2>&1'
	return os.execute(cmd)
}

// exec_safe_stdin executes a binary with arguments while piping standard input from a target file securely.
pub fn exec_safe_stdin(bin string, args []string, input_file string) os.Result {
	if input_file != '' && os.is_file(input_file) {
		safe_bin := quote_arg(bin)
		mut safe_args := []string{}
		for a in args {
			safe_args << quote_arg(a)
		}
		cmd := '${safe_bin} ${safe_args.join(' ')} < ${quote_path(input_file)} 2>&1'
		return os.execute(cmd)
	}
	return exec_safe_input(bin, args, input_file)
}

// exec_safe_input executes a binary with arguments while piping raw text into standard input via a mode-0600 temporary file.
pub fn exec_safe_input(bin string, args []string, stdin_text string) os.Result {
	tok := generate_secure_token(8)
	tmp_path := os.join_path(os.temp_dir(), 'sys_stdin_${os.getpid()}_${tok}.tmp')
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
	cmd := '${safe_bin} ${safe_args.join(' ')} < ${quote_path(tmp_path)} 2>&1'
	return os.execute(cmd)
}

// sanitize_filename strips path traversal sequences and dangerous shell metacharacters from user-provided file names.
pub fn sanitize_filename(name string) string {
	mut s := name.replace('\x00', '').replace('\r', '_').replace('\n', '_')
	s = s.replace('/', '_').replace('\\', '_').replace(':', '_')
	s = s.replace(';', '_').replace('&', '_').replace('|', '_').replace('`', '_').replace('$', '_')
	s = s.replace('(', '_').replace(')', '_').replace('"', '_').replace("'", '_')
	s = s.replace('<', '_').replace('>', '_').replace('*', '_').replace('?', '_')
	for s.contains('..') {
		s = s.replace('..', '_')
	}
	return s.trim_space()
}

// validate_path ensures that target path stays strictly inside base_dir to prevent directory traversal attacks.
pub fn validate_path(target_path string, base_dir string) !string {
	if target_path.contains('\x00') || base_dir.contains('\x00') {
		return error('Path traversal detected: null byte in path')
	}
	clean_base := os.real_path(base_dir)
	clean_target := os.real_path(target_path)
	base_with_sep := clean_base.trim_right('/\\') + os.path_separator
	if clean_target != clean_base && !clean_target.starts_with(base_with_sep) {
		return error('Path traversal detected: "${target_path}" is outside "${base_dir}"')
	}
	return clean_target
}

// constant_time_compare compares two strings in constant time to prevent side-channel timing attacks on tokens and hashes.
pub fn constant_time_compare(a string, b string) bool {
	if a.len != b.len {
		return false
	}
	mut diff := u8(0)
	for i in 0 .. a.len {
		diff |= a[i] ^ b[i]
	}
	return diff == 0
}

// mask_secret masks a sensitive string (e.g. API key, credit card, password) leaving visible characters at head and tail.
pub fn mask_secret(secret string, visible_start int, visible_end int) string {
	if secret.len <= visible_start + visible_end {
		return '*'.repeat(secret.len)
	}
	head := secret[..visible_start]
	tail := secret[secret.len - visible_end..]
	stars := '*'.repeat(secret.len - visible_start - visible_end)
	return '${head}${stars}${tail}'
}

// sanitize_html strips potentially dangerous script tags and event handlers from HTML.
pub fn sanitize_html(raw_html string) string {
	mut s := raw_html
	for tag in ['script', 'iframe', 'object', 'embed'] {
		s = replace_case_insensitive(s, '<${tag}', '&lt;${tag}')
		s = replace_case_insensitive(s, '</${tag}>', '&lt;/${tag}&gt;')
		s = replace_case_insensitive(s, '</${tag}', '&lt;/${tag}')
	}
	for proto in ['javascript:', 'vbscript:', 'data:text/html'] {
		s = replace_case_insensitive(s, proto, '')
	}
	for ev in ['onload=', 'onerror=', 'onclick=', 'onmouseover=', 'onfocus=', 'onblur=', 'oninput=',
		'onchange=', 'onsubmit=', 'onkeydown=', 'onkeyup=', 'onanimationstart=', 'ontoggle='] {
		s = replace_case_insensitive(s, ev, 'data-blocked=')
	}
	return s
}

fn replace_case_insensitive(input string, needle string, replacement string) string {
	if needle.len == 0 || input.len < needle.len {
		return input
	}
	lower_needle := needle.to_lower()
	mut res := input
	for {
		lower_res := res.to_lower()
		idx := lower_res.index(lower_needle) or { break }
		res = res[..idx] + replacement + res[idx + needle.len..]
	}
	return res
}

// is_safe_url checks whether a URL uses an approved secure protocol (http or https).
pub fn is_safe_url(raw_url string) bool {
	trimmed := raw_url.trim_space()
	for c in trimmed {
		if c <= 32 || c == 127 {
			return false
		}
	}
	lower := trimmed.to_lower()
	return lower.starts_with('https://') || lower.starts_with('http://')
}

// generate_secure_token generates a cryptographically random hexadecimal token of specified byte length.
pub fn generate_secure_token(byte_length int) string {
	if byte_length <= 0 {
		return ''
	}
	bytes := crand.bytes(byte_length) or {
		// Fallback deterministic if entropy pool fails
		return 'token_${time.now().unix_nano()}'
	}
	return hex.encode(bytes)
}

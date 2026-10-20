module procutils

import os
import strings
import time

// ProcessCommand represents an external command program and its argument list.
pub struct ProcessCommand {
pub:
	program string
	args    []string
}

// to_shell formats the command with POSIX single-quote escaping for shell execution
pub fn (c ProcessCommand) to_shell() string {
	mut parts := [quote_arg(c.program)]
	for a in c.args {
		parts << quote_arg(a)
	}
	return parts.join(' ')
}

// ProcessResult holds the exit code, standard output, and standard error of a completed process.
pub struct ProcessResult {
pub:
	exit_code int
	stdout    string
	stderr    string
}

// success returns true when the process exited with status code 0.
pub fn (r ProcessResult) success() bool {
	return r.exit_code == 0
}

// quote_arg strictly quotes an argument using POSIX single quotes to eliminate shell injection
pub fn quote_arg(arg string) string {
	if arg.len == 0 {
		return "''"
	}
	return "'" + arg.replace("'", '\'"\'"\'') + "'"
}

// cmd creates a ProcessCommand with program and arguments
pub fn cmd(program string, args ...string) ProcessCommand {
	mut a := []string{}
	for arg in args {
		a << arg
	}
	return ProcessCommand{
		program: program
		args:    a
	}
}

fn drain_lines(rem string, chunk string, is_stderr bool, on_line fn (line string, is_stderr bool)) string {
	if chunk.len == 0 {
		return rem
	}
	mut cur := rem + chunk
	for {
		idx := cur.index('\n') or { break }
		mut line := cur[..idx]
		if line.ends_with('\r') {
			line = line[..line.len - 1]
		}
		on_line(line, is_stderr)
		cur = cur[idx + 1..]
	}
	return cur
}

// exec_stream executes a command while streaming output in real-time via callback
pub fn exec_stream(program string, args []string, on_line fn (line string, is_stderr bool)) !ProcessResult {
	mut p := os.new_process(program)
	p.set_args(args)
	p.set_redirect_stdio()
	p.run()

	mut full_stdout := []string{}
	mut full_stderr := []string{}
	mut out_rem := ''
	mut err_rem := ''

	for p.is_alive() {
		mut got := false
		if p.is_pending(.stdout) {
			out_chunk := p.stdout_read()
			if out_chunk.len > 0 {
				full_stdout << out_chunk
				out_rem = drain_lines(out_rem, out_chunk, false, on_line)
				got = true
			}
		}
		if p.is_pending(.stderr) {
			err_chunk := p.stderr_read()
			if err_chunk.len > 0 {
				full_stderr << err_chunk
				err_rem = drain_lines(err_rem, err_chunk, true, on_line)
				got = true
			}
		}
		if !got {
			time.sleep(5 * time.millisecond)
		}
	}

	// Slurp any trailing bytes remaining on the pipes
	last_out := p.stdout_slurp()
	if last_out.len > 0 {
		full_stdout << last_out
		out_rem = drain_lines(out_rem, last_out, false, on_line)
	}
	if out_rem.len > 0 {
		mut line := out_rem
		if line.ends_with('\r') {
			line = line[..line.len - 1]
		}
		on_line(line, false)
	}
	last_err := p.stderr_slurp()
	if last_err.len > 0 {
		full_stderr << last_err
		err_rem = drain_lines(err_rem, last_err, true, on_line)
	}
	if err_rem.len > 0 {
		mut line := err_rem
		if line.ends_with('\r') {
			line = line[..line.len - 1]
		}
		on_line(line, true)
	}

	p.wait()
	p.close()

	return ProcessResult{
		exit_code: p.code
		stdout:    full_stdout.join('')
		stderr:    full_stderr.join('')
	}
}

// exec_with_timeout executes a command and kills it if it exceeds timeout_ms
pub fn exec_with_timeout(program string, args []string, timeout_ms int) !ProcessResult {
	mut p := os.new_process(program)
	p.set_args(args)
	p.set_redirect_stdio()
	p.run()

	mut out := strings.new_builder(256)
	mut errb := strings.new_builder(64)
	start := time.now()
	for p.is_alive() {
		mut got := false
		if p.is_pending(.stdout) {
			out.write_string(p.stdout_read())
			got = true
		}
		if p.is_pending(.stderr) {
			errb.write_string(p.stderr_read())
			got = true
		}
		elapsed := time.since(start).milliseconds()
		if elapsed > timeout_ms {
			p.signal_kill()
			p.wait()
			p.close()
			return error('process ${program} exceeded timeout of ${timeout_ms}ms')
		}
		if !got {
			time.sleep(5 * time.millisecond)
		}
	}

	out.write_string(p.stdout_slurp())
	errb.write_string(p.stderr_slurp())
	p.wait()
	p.close()

	return ProcessResult{
		exit_code: p.code
		stdout:    out.str()
		stderr:    errb.str()
	}
}

// pipeline chains multiple commands using shell piping with POSIX quote-escaping
pub fn pipeline(commands []ProcessCommand) !string {
	if commands.len == 0 {
		return ''
	}

	mut parts := []string{}
	for c in commands {
		parts << c.to_shell()
	}
	pipeline_str := parts.join(' | ')

	res := os.execute(pipeline_str)
	if res.exit_code != 0 {
		return error('pipeline execution failed with code ${res.exit_code}')
	}
	return res.output
}

// Module filemanager (fm_terminal.v) - RFC 6455 WebSocket handshake, frame codec, and interactive PTY shell session bridge.
module filemanager

import crypto.sha1
import encoding.base64
import json2
import net
import os
import sync
import time

#flag linux -lutil
#include "@VMODROOT/filemanager/pty_helper.h"

fn C.rad_pty_spawn(shell_path &char, cwd &char, cols int, rows int, out_pid &int) int
fn C.rad_pty_read(master_fd int, buf &u8, cap int) int
fn C.rad_pty_write(master_fd int, data &char, len int) int
fn C.rad_pty_resize(master_fd int, cols int, rows int)
fn C.rad_pty_check_exit(pid int, out_code &int) int
fn C.rad_pty_close(master_fd int, pid int)

const ws_magic_guid = '258EAFA5-E914-47DA-95CA-C5AB0DC85B11'

// compute_ws_accept_key computes the RFC 6455 `Sec-WebSocket-Accept` handshake key from `client_key`.
pub fn compute_ws_accept_key(client_key string) string {
	combined := client_key.trim_space() + ws_magic_guid
	digest := sha1.sum(combined.bytes())
	return base64.encode(digest)
}

fn ws_encode_text_frame(payload string) []u8 {
	bytes := payload.bytes()
	len := bytes.len
	mut frame := []u8{cap: len + 10}
	frame << u8(0x81) // FIN + text opcode
	if len < 126 {
		frame << u8(len)
	} else if len <= 65535 {
		frame << u8(126)
		frame << u8((len >> 8) & 0xff)
		frame << u8(len & 0xff)
	} else {
		frame << u8(127)
		for shift := 56; shift >= 0; shift -= 8 {
			frame << u8((u64(len) >> shift) & 0xff)
		}
	}
	frame << bytes
	return frame
}

fn read_exact_bytes(mut conn net.TcpConn, count int) ?[]u8 {
	if count <= 0 {
		return []u8{}
	}
	mut out := []u8{cap: count}
	mut buf := []u8{len: count}
	for out.len < count {
		rem := count - out.len
		n := conn.read(mut buf[..rem]) or { return none }
		if n <= 0 {
			return none
		}
		out << buf[..n]
	}
	return out
}

fn ws_read_frame(mut conn net.TcpConn) ?(int, []u8) {
	hdr := read_exact_bytes(mut conn, 2) or { return none }
	opcode := int(hdr[0] & 0x0f)
	masked := (hdr[1] & 0x80) != 0
	mut payload_len := int(hdr[1] & 0x7f)

	if payload_len == 126 {
		ext := read_exact_bytes(mut conn, 2) or { return none }
		payload_len = (int(ext[0]) << 8) | int(ext[1])
	} else if payload_len == 127 {
		ext := read_exact_bytes(mut conn, 8) or { return none }
		mut l64 := u64(0)
		for b in ext {
			l64 = (l64 << 8) | u64(b)
		}
		if l64 > 10 * 1024 * 1024 {
			return none
		}
		payload_len = int(l64)
	}

	mut mask_key := []u8{}
	if masked {
		mask_key = read_exact_bytes(mut conn, 4) or { return none }
	}
	mut payload := read_exact_bytes(mut conn, payload_len) or { return none }
	if masked && mask_key.len == 4 {
		for i in 0 .. payload.len {
			payload[i] = payload[i] ^ mask_key[i & 3]
		}
	}
	return opcode, payload
}

fn detect_default_shell() string {
	env_shell := os.getenv('SHELL').trim_space()
	if env_shell != '' && os.exists(env_shell) {
		return env_shell
	}
	for sh in ['/bin/zsh', '/bin/bash', '/bin/sh'] {
		if os.exists(sh) {
			return sh
		}
	}
	return '/bin/sh'
}

// handle_terminal_websocket upgrades an HTTP connection to a WebSocket and bridges it to a pseudo-terminal shell session.
pub fn handle_terminal_websocket(ctx &FmContext, mut conn net.TcpConn, ws_key string, raw_cwd string, cols int, rows int) {
	accept_key := compute_ws_accept_key(ws_key)
	handshake := 'HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: ${accept_key}\r\n\r\n'
	conn.write(handshake.bytes()) or {
		conn.close() or {}
		return
	}

	mut cwd := ctx.initial_path
	if raw_cwd != '' {
		if resolved := resolve_existing(ctx, raw_cwd, true) {
			if os.is_dir(resolved) {
				cwd = resolved
			}
		}
	}
	if !os.is_dir(cwd) {
		cwd = ctx.home
	}

	shell := detect_default_shell()
	init_cols := if cols >= 20 && cols <= 500 { cols } else { 100 }
	init_rows := if rows >= 5 && rows <= 200 { rows } else { 28 }

	mut pid := 0
	master_fd := C.rad_pty_spawn(&char(shell.str), &char(cwd.str), init_cols, init_rows,
		&pid)

	mut write_mu := sync.new_mutex()
	send_ws_json := fn [mut conn, mut write_mu] (json_msg string) bool {
		frame := ws_encode_text_frame(json_msg)
		write_mu.lock()
		defer {
			write_mu.unlock()
		}
		conn.write(frame) or { return false }
		return true
	}

	if master_fd < 0 || pid <= 0 {
		send_ws_json('{"type":"error","message":"Failed to spawn native PTY shell."}')
		conn.close() or {}
		return
	}

	send_ws_json('{"type":"ready","pid":${pid},"shell":${json_str(os.base(shell))},"cwd":${json_str(cwd)}}')

	mut closed := false

	// Background reader thread: reads PTY output and sends WebSocket frames
	spawn fn [master_fd, pid, send_ws_json, mut closed] () {
		mut buf := []u8{len: 8192}
		mut exit_code := 0
		for !closed {
			n := C.rad_pty_read(master_fd, buf.data, buf.len)
			if n > 0 {
				chunk := buf[..n].bytestr()
				if !send_ws_json('{"type":"output","data":${json_str(chunk)}}') {
					closed = true
					break
				}
			} else if n == -2 {
				break
			} else {
				if C.rad_pty_check_exit(pid, &exit_code) != 0 {
					break
				}
				time.sleep(12 * time.millisecond)
			}
		}
		C.rad_pty_check_exit(pid, &exit_code)
		if !closed {
			send_ws_json('{"type":"exit","code":${exit_code}}')
			closed = true
		}
	}()

	// Main WebSocket frame loop: reads client input / resize / chdir commands
	conn.set_read_timeout(24 * time.hour)
	for !closed {
		opcode, payload := ws_read_frame(mut conn) or { break }
		if opcode == 0x8 { // Close frame
			break
		}
		if opcode == 0x9 { // Ping -> Pong (RFC 6455 control frames max 125 bytes)
			pong_len := if payload.len > 125 { 125 } else { payload.len }
			mut pong := []u8{cap: pong_len + 2}
			pong << u8(0x8a)
			pong << u8(pong_len)
			if pong_len > 0 {
				pong << payload[..pong_len]
			}
			write_mu.lock()
			conn.write(pong) or {}
			write_mu.unlock()
			continue
		}
		if opcode != 0x1 && opcode != 0x2 {
			continue
		}
		text := payload.bytestr()
		parsed := json2.decode[json2.Any](text) or {
			C.rad_pty_write(master_fd, &char(text.str), text.len)
			continue
		}
		if parsed is map[string]json2.Any {
			msg_type := map_str(parsed, 'type', '')
			match msg_type {
				'input' {
					data := map_str(parsed, 'data', '')
					if data.len > 0 {
						C.rad_pty_write(master_fd, &char(data.str), data.len)
					}
				}
				'resize' {
					c := map_int(parsed, 'cols', 100)
					r := map_int(parsed, 'rows', 28)
					if c >= 20 && r >= 5 {
						C.rad_pty_resize(master_fd, c, r)
					}
				}
				'chdir' {
					raw_p := map_str(parsed, 'path', '')
					if resolved := resolve_existing(ctx, raw_p, true) {
						if os.is_dir(resolved) && !resolved.contains('\n') && !resolved.contains('\r')
							&& !resolved.contains('\x00') {
							escaped := resolved.replace("'", "'\\''")
							cmd := "cd -- '${escaped}'\r"
							C.rad_pty_write(master_fd, &char(cmd.str), cmd.len)
						}
					}
				}
				'ping' {
					send_ws_json('{"type":"pong"}')
				}
				else {}
			}
		}
	}

	closed = true
	C.rad_pty_close(master_fd, pid)
	conn.close() or {}
}

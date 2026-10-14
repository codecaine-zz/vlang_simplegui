module main

import os

// Unit tests for programmer calculator algorithms and CLI workflow

fn parse_radix_number_test(s string) u64 {
	mut clean := s.trim_space().to_lower().replace('_', '')
	if clean.starts_with('0x') {
		mut res := u64(0)
		for c in clean[2..] {
			digit := match c {
				`0`...`9` { u64(c - `0`) }
				`a`...`f` { u64(c - `a` + 10) }
				else { u64(0) }
			}
			res = (res << 4) | digit
		}
		return res
	} else if clean.starts_with('0b') {
		mut res := u64(0)
		for c in clean[2..] {
			bit := if c == `1` { u64(1) } else { u64(0) }
			res = (res << 1) | bit
		}
		return res
	} else if clean.starts_with('0o') {
		mut res := u64(0)
		for c in clean[2..] {
			if c >= `0` && c <= `7` {
				res = (res * 8) + u64(c - `0`)
			}
		}
		return res
	}
	return clean.u64()
}

fn to_octal_string_test(v u64) string {
	if v == 0 {
		return '0o0'
	}
	mut val := v
	mut s := ''
	for val > 0 {
		digit := val % 8
		s = digit.str() + s
		val /= 8
	}
	return '0o' + s
}

fn count_ones_64_test(v u64) int {
	mut count := 0
	mut n := v
	for n > 0 {
		count += int(n & 1)
		n >>= 1
	}
	return count
}

fn rotate_left_64_test(v u64, shift int) u64 {
	s := shift % 64
	if s == 0 {
		return v
	}
	return (v << u64(s)) | (v >> u64(64 - s))
}

fn rotate_right_64_test(v u64, shift int) u64 {
	s := shift % 64
	if s == 0 {
		return v
	}
	return (v >> u64(s)) | (v << u64(64 - s))
}

fn swap_bytes_64_test(v u64) u64 {
	return ((v & 0xFF00000000000000) >> 56) | ((v & 0x00FF000000000000) >> 40) | ((v & 0x0000FF0000000000) >> 24) | ((v & 0x000000FF00000000) >> 8) | ((v & 0x00000000FF000000) << 8) | ((v & 0x0000000000FF0000) << 24) | ((v & 0x000000000000FF00) << 40) | ((v & 0x00000000000000FF) << 56)
}

fn test_radix_parsing() {
	// Decimal
	assert parse_radix_number_test('0') == u64(0)
	assert parse_radix_number_test('255') == u64(255)
	assert parse_radix_number_test('1_000_000') == u64(1000000)

	// Hexadecimal
	assert parse_radix_number_test('0x0') == u64(0)
	assert parse_radix_number_test('0xFF') == u64(255)
	assert parse_radix_number_test('0Xff') == u64(255)
	assert parse_radix_number_test('0xDEAD_BEEF') == u64(0xDEADBEEF)

	// Binary
	assert parse_radix_number_test('0b0') == u64(0)
	assert parse_radix_number_test('0b1111') == u64(15)
	assert parse_radix_number_test('0b1111_0000') == u64(240)

	// Octal
	assert parse_radix_number_test('0o0') == u64(0)
	assert parse_radix_number_test('0o12') == u64(10)
	assert parse_radix_number_test('0o377') == u64(255)
	assert parse_radix_number_test('0o77_77') == u64(4095)
}

fn test_octal_formatting() {
	assert to_octal_string_test(0) == '0o0'
	assert to_octal_string_test(8) == '0o10'
	assert to_octal_string_test(10) == '0o12'
	assert to_octal_string_test(255) == '0o377'
	assert to_octal_string_test(4095) == '0o7777'
}

fn test_bit_manipulations() {
	// Popcount
	assert count_ones_64_test(0) == 0
	assert count_ones_64_test(1) == 1
	assert count_ones_64_test(0xFF) == 8
	assert count_ones_64_test(0b1010101) == 4

	// Rotate left & right
	val := u64(0x8000000000000001)
	assert rotate_left_64_test(val, 1) == u64(0x0000000000000003)
	assert rotate_right_64_test(0x0000000000000003, 1) == val

	// Endianness swap
	orig := u64(0x0102030405060708)
	swapped := swap_bytes_64_test(orig)
	assert swapped == u64(0x0807060504030201)
	assert swap_bytes_64_test(swapped) == orig
}

fn test_calc_cli_execution() {
	// Build or run calc_cli binary to test command line flags
	exe := os.find_abs_path_of_executable('v') or { 'v' }
	root := os.dir(os.dir(@FILE))
	app_path := os.join_path(root, 'cli_apps', 'calc_cli.v')
	assert os.exists(app_path)

	// Test 1: Single value display with octal
	res := os.execute('${os.quoted_path(exe)} run ${os.quoted_path(app_path)} --val 10')
	assert res.exit_code == 0
	assert res.output.contains('0xA')
	assert res.output.contains('0o12')
	assert res.output.contains('Popcount (Set Bits)')

	// Test 2: Bitwise AND operation
	res_and := os.execute('${os.quoted_path(exe)} run ${os.quoted_path(app_path)} --val 0xFF --op AND --val2 0x0F')
	assert res_and.exit_code == 0
	assert res_and.output.contains('Bitwise Operation: AND')
	assert res_and.output.contains('0xF')
}

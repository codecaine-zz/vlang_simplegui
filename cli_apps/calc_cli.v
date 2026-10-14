module main

import simplecli

fn main() {
	mut app := simplecli.new_app('calc-cli', '1.1.0')
	app.set_description('Programmer Calculator (HEX, DEC, OCT, BIN, Bitwise Ops) CLI')

	app.add_flag_string('val', 'n', '255',
		'Numeric value (prefix with 0x for Hex, 0b for Binary, 0o for Octal, or standard Decimal)')
	app.add_flag_string('op', 'o', '', 'Bitwise operation (e.g. NOT, AND, OR, XOR, SHL, SHR, ROL, ROR)')
	app.add_flag_string('val2', 'w', '', 'Second operand for binary bitwise operation')
	app.add_flag_bool('interactive', 'x', false, 'Launch interactive programmer calculator')

	app.parse_cli() or { return }

	app.banner('Programmer Calculator CLI', 'v1.1.0 - Radix & Bitwise Engine')

	if app.get_flag_bool('interactive') {
		run_interactive(mut app)
		return
	}

	val_str := app.get_flag_string('val')
	num := parse_radix_number(val_str)
	op_str := app.get_flag_string('op')

	if op_str.len > 0 {
		val2_str := app.get_flag_string('val2')
		num2 := if val2_str.len > 0 { parse_radix_number(val2_str) } else { u64(0) }
		res := execute_bitwise_op(op_str, num, num2) or {
			app.error('Unsupported bitwise operation: ${op_str}')
			app.info('Supported operations: NOT, AND, OR, XOR, SHL, SHR, ROL, ROR')
			return
		}
		display_operation_result(mut app, op_str, num, num2, res)
	} else {
		display_radix_table(mut app, num)
	}
}

pub fn parse_radix_number(s string) u64 {
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

pub fn to_octal_string(v u64) string {
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

pub fn to_binary_string(v u64) string {
	mut s := ''
	for i := 63; i >= 0; i-- {
		bit := (v >> u64(i)) & 1
		s += bit.str()
		if i % 8 == 0 && i > 0 {
			s += ' '
		}
	}
	return s
}

pub fn count_ones_64(v u64) int {
	mut count := 0
	mut n := v
	for n > 0 {
		count += int(n & 1)
		n >>= 1
	}
	return count
}

pub fn rotate_left_64(v u64, shift int) u64 {
	s := shift % 64
	if s == 0 {
		return v
	}
	return (v << u64(s)) | (v >> u64(64 - s))
}

pub fn rotate_right_64(v u64, shift int) u64 {
	s := shift % 64
	if s == 0 {
		return v
	}
	return (v >> u64(s)) | (v << u64(64 - s))
}

pub fn swap_bytes_64(v u64) u64 {
	return ((v & 0xFF00000000000000) >> 56) | ((v & 0x00FF000000000000) >> 40) | ((v & 0x0000FF0000000000) >> 24) | ((v & 0x000000FF00000000) >> 8) | ((v & 0x00000000FF000000) << 8) | ((v & 0x0000000000FF0000) << 24) | ((v & 0x000000000000FF00) << 40) | ((v & 0x00000000000000FF) << 56)
}

pub fn execute_bitwise_op(op string, val1 u64, val2 u64) ?u64 {
	clean_op := op.trim_space().to_upper()
	return match clean_op {
		'NOT', 'INV', '~' {
			~val1
		}
		'AND', '&' {
			val1 & val2
		}
		'OR', '|' {
			val1 | val2
		}
		'XOR', '^' {
			val1 ^ val2
		}
		'SHL', '<<' {
			val1 << (val2 % 64)
		}
		'SHR', '>>' {
			val1 >> (val2 % 64)
		}
		'ROL' {
			rotate_left_64(val1, int(val2 % 64))
		}
		'ROR' {
			rotate_right_64(val1, int(val2 % 64))
		}
		else {
			none
		}
	}
}

fn display_radix_table(mut app simplecli.SimpleCli, val u64) {
	hex_val := '0x' + val.hex().to_upper()
	dec_val := val.str()
	oct_val := to_octal_string(val)
	bin_val := to_binary_string(val)
	ones := count_ones_64(val)
	parity := if ones % 2 == 0 { 'Even' } else { 'Odd' }

	app.table(['Radix Base', 'Representation', 'Bit Size'], [
		['HEX (Base 16)', hex_val, '64-bit'],
		['DEC (Base 10)', dec_val, '64-bit'],
		['OCT (Base 8)', oct_val, '64-bit'],
		['BIN (Base 2)', bin_val, '64-bit formatted'],
	])

	not_val := ~val
	app.print_kv({
		'Bitwise NOT (~val)':    '0x' + not_val.hex().to_upper()
		'Byte Swapped (endian)': '0x' + swap_bytes_64(val).hex().to_upper()
		'Popcount (Set Bits)':   ones.str()
		'Parity':                parity
	})
}

fn display_operation_result(mut app simplecli.SimpleCli, op string, val1 u64, val2 u64, res u64) {
	upper_op := op.to_upper()
	op_expr := if upper_op in ['NOT', 'INV', '~'] {
		'~${val1}'
	} else {
		'${val1} ${upper_op} ${val2}'
	}
	app.panel('Bitwise Operation: ${upper_op}', 'Expression: ${op_expr}')

	app.table(['Radix Base', 'Operand 1', 'Operand 2', 'Result'], [
		['HEX (Base 16)', '0x' + val1.hex().to_upper(), '0x' + val2.hex().to_upper(),
			'0x' + res.hex().to_upper()],
		['DEC (Base 10)', val1.str(), val2.str(), res.str()],
		['OCT (Base 8)', to_octal_string(val1), to_octal_string(val2), to_octal_string(res)],
		['BIN (Base 2)', to_binary_string(val1), to_binary_string(val2), to_binary_string(res)],
	])

	ones := count_ones_64(res)
	parity := if ones % 2 == 0 { 'Even' } else { 'Odd' }
	app.print_kv({
		'Result (HEX)':        '0x' + res.hex().to_upper()
		'Result (DEC)':        res.str()
		'Popcount (Set Bits)': ones.str()
		'Parity':              parity
		'Byte Swapped':        '0x' + swap_bytes_64(res).hex().to_upper()
	})
}

fn run_interactive(mut app simplecli.SimpleCli) {
	app.panel('Programmer Calculator REPL',
		'Enter numbers (e.g. 255, 0xFF, 0b1111, 0o377) or operations (e.g. 0xFF AND 0x0F).')
	for {
		input := app.prompt('Enter number or operation', '0xDEADBEEF')
		clean := input.trim_space()
		if clean == 'exit' || clean == 'q' {
			break
		}
		parts := clean.split(' ')
		if parts.len >= 3 {
			val1 := parse_radix_number(parts[0])
			op := parts[1]
			val2 := parse_radix_number(parts[2])
			if res := execute_bitwise_op(op, val1, val2) {
				display_operation_result(mut app, op, val1, val2, res)
			} else {
				app.error('Unsupported operation: ${op}')
			}
		} else if parts.len == 2 && parts[0].to_upper() in ['NOT', 'INV', '~'] {
			val1 := parse_radix_number(parts[1])
			if res := execute_bitwise_op(parts[0], val1, 0) {
				display_operation_result(mut app, parts[0], val1, 0, res)
			}
		} else {
			num := parse_radix_number(clean)
			display_radix_table(mut app, num)
		}
		if !app.confirm('Continue calculating?', true) {
			break
		}
	}
}

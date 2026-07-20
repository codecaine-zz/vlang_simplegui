module main

import simplegui

fn main() {
	println('--- Testing New SimpleGUI Standard Library Wrappers ---')

	// 1. Math
	sin_val := simplegui.math_sin(1.57079632679)
	cos_val := simplegui.math_cos(0.0)
	sqrt_val := simplegui.math_sqrt(144.0)
	pow_val := simplegui.math_pow(2.0, 10.0)
	println('Math sin(pi/2): ${sin_val:.4f}, cos(0): ${cos_val:.4f}, sqrt(144): ${sqrt_val}, pow(2,10): ${pow_val}')

	// 2. Stats
	data := [10.0, 20.0, 30.0, 40.0, 50.0]
	mean := simplegui.stats_mean(data)
	median := simplegui.stats_median(data)
	std_dev := simplegui.stats_sample_std_dev(data)
	println('Stats mean: ${mean}, median: ${median}, std_dev: ${std_dev:.2f}')

	// 3. BigInt
	b1 := simplegui.big_int_from_str('123456789012345678901234567890')
	b2 := simplegui.big_int_from_int(2)
	b3 := b1.mul(b2)
	println('BigInt multiply: ${b3.str()}')

	// 4. Arrays
	nums := [15, 3, 99, 42, 8]
	println('Array min: ${simplegui.array_min(nums)}, max: ${simplegui.array_max(nums)}, sum: ${simplegui.array_sum(nums)}')
	tags := ['v', 'gui', 'v', 'cocoa', 'gui', 'v']
	unique_tags := simplegui.array_unique_strings(tags)
	println('Unique tags: ${unique_tags}')

	// Weighted Choice Picker
	rarities := ['Common', 'Uncommon', 'Rare', 'Legendary']
	weights := [70.0, 20.0, 9.0, 1.0]
	picked_rarity := simplegui.rand_weighted_choice_strings(rarities, weights)
	println('Weighted random choice pick: ${picked_rarity}')

	// 5. UTF-8 & Strings
	utf8_text := 'SimpleGUI 🚀'
	println('UTF-8 len of "${utf8_text}": ${simplegui.utf8_len(utf8_text)}, valid: ${simplegui.utf8_is_valid(utf8_text)}')
	dist := simplegui.string_levenshtein('simplegui', 'simple_gui')
	println('Levenshtein distance: ${dist}')

	// 6. String Builder
	mut sb := simplegui.new_string_builder()
	sb.write('Hello from ')
	sb.write_line('SimpleGUI!')
	println('StringBuilder result: ${sb.str().trim_space()}')

	// 7. CSV
	csv_text := 'Name,Role,Score\nAlice,Admin,98\nBob,User,85'
	rows := simplegui.csv_parse(csv_text)
	println('Parsed CSV row count: ${rows.len}')
	encoded_csv := simplegui.csv_encode(rows)
	println('Re-encoded CSV:\n${encoded_csv.trim_space()}')

	// 8. Ed25519
	kp := simplegui.crypto_ed25519_generate_key() or { return }
	msg := 'Sign this message'
	sig := simplegui.crypto_ed25519_sign(kp.priv_key, msg) or { return }
	verified := simplegui.crypto_ed25519_verify(kp.pub_key, msg, sig)
	println('Ed25519 Signature Verified: ${verified}')

	// 9. PBKDF2
	dk := simplegui.crypto_pbkdf2('my_password', 'unique_salt', 1000, 32)
	println('PBKDF2 Derived Key Byte Length: ${dk.len}')

	// 10. Concurrency (Mutex & WaitGroup)
	mut mutex := simplegui.new_mutex()
	mutex.lock()
	println('Mutex locked and unlocked cleanly.')
	mutex.unlock()

	mut wg := simplegui.new_wait_group()
	wg.add(1)
	wg.done()
	wg.wait()
	println('WaitGroup finished cleanly.')

	println('--- All Extended Standard Library Functions Tested Successfully! ---')
}

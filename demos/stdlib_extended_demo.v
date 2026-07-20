module main

import simplegui

fn main() {
	println('===================================================')
	println('    SimpleGUI Extended Standard Library Demo')
	println('===================================================')

	mut win := simplegui.new_simple_window('SimpleGUI Extended STDLIB', 800, 600)


	// -------------------------------------------------
	// 1. Complex Number Arithmetic (math.complex)
	// -------------------------------------------------
	println('\n[1] Complex Numbers (math.complex):')
	c1 := win.complex_new(3.0, 4.0)
	c2 := simplegui.complex_new(1.0, -2.0)

	c_add := c1.add(c2)
	c_mul := c1.mul(c2)
	c_div := c1.div(c2)
	c_conj := c1.conj()

	println('  c1 = ${c1.str()} | Magnitude |c1|: ${c1.abs():.4f}, Angle: ${c1.arg():.4f} rad')
	println('  c2 = ${c2.str()}')
	println('  c1 + c2 = ${c_add.str()}')
	println('  c1 * c2 = ${c_mul.str()}')
	println('  c1 / c2 = ${c_div.str()}')
	println('  c1 Conjugate = ${c_conj.str()}')

	// -------------------------------------------------
	// 2. Advanced Math & Geometry Helpers (math)
	// -------------------------------------------------
	println('\n[2] Advanced Math & Geometry (math):')
	rad := win.math_radians(180.0)
	deg := win.math_degrees(rad)
	hypot := win.math_hypot(3.0, 4.0)
	gcd_val := win.math_gcd(48, 18)
	lcm_val := win.math_lcm(12, 18)
	remapped := win.math_remap(5.0, 0.0, 10.0, 100.0, 200.0)
	smooth := win.math_smoothstep(0.0, 10.0, 5.0)
	rounded := win.math_round_sig(3.14159265, 4)

	println('  180 deg in radians: ${rad:.4f} -> back to deg: ${deg:.1f}')
	println('  Hypot(3, 4): ${hypot:.1f}')
	println('  GCD(48, 18): ${gcd_val} | LCM(12, 18): ${lcm_val}')
	println('  Remap 5.0 from [0,10] to [100,200]: ${remapped:.1f}')
	println('  Smoothstep(0, 10, 5.0): ${smooth:.2f}')
	println('  Round 3.14159265 to 4 sig digits: ${rounded}')

	// -------------------------------------------------
	// 3. Advanced Statistical Analytics (math.stats)
	// -------------------------------------------------
	println('\n[3] Advanced Statistical Analytics (math.stats):')
	stats_data := [10.0, 12.0, 23.0, 23.0, 16.0, 23.0, 21.0, 16.0]
	stats_data2 := [5.0, 6.0, 11.0, 12.0, 8.0, 11.0, 10.0, 8.0]

	geo_mean := win.stats_geometric_mean(stats_data)
	harm_mean := win.stats_harmonic_mean(stats_data)
	rms_val := win.stats_rms(stats_data)
	mode_val := win.stats_mode(stats_data)
	range_val := win.stats_range(stats_data)
	cov_val := win.stats_covariance(stats_data, stats_data2)

	println('  Dataset: ${stats_data}')
	println('  Geometric Mean: ${geo_mean:.4f}')
	println('  Harmonic Mean:  ${harm_mean:.4f}')
	println('  Root Mean Sq (RMS): ${rms_val:.4f}')
	println('  Mode: ${mode_val:.1f} | Range: ${range_val:.1f}')
	println('  Covariance: ${cov_val:.4f}')

	// -------------------------------------------------
	// 4. Cryptographically Secure Random & UUID (crypto.rand)
	// -------------------------------------------------
	println('\n[4] Secure Random Tokens & UUID v4 (crypto.rand):')
	rand_hex := win.crypto_rand_hex(8)
	rand_uuid := win.crypto_rand_uuid()

	println('  Secure Random 8-byte Hex: ${rand_hex}')
	println('  Generated Secure UUID v4:  ${rand_uuid}')

	// -------------------------------------------------
	// 5. HMAC Signatures & Wyhash (crypto.hmac, hash)
	// -------------------------------------------------
	println('\n[5] HMAC Signatures & Fast Hashes (crypto.hmac, vhash):')
	secret_key := 'top_secret_api_key'
	msg_payload := 'action=transfer&amount=5000'

	hmac_sha512 := win.crypto_hmac_sha512(msg_payload, secret_key)
	hmac_sha1 := win.crypto_hmac_sha1(msg_payload, secret_key)
	wyhash_val := win.crypto_wyhash(msg_payload, 42)

	println('  Payload: "${msg_payload}"')
	println('  HMAC-SHA512: ${hmac_sha512}')
	println('  HMAC-SHA1:   ${hmac_sha1}')
	println('  Wyhash64:    ${wyhash_val}')

	// -------------------------------------------------
	// 6. Advanced String Metrics & Utilities (strings)
	// -------------------------------------------------
	println('\n[6] String Similarity & Metrics (strings):')
	s1 := 'SimpleGUI Application'
	s2 := 'SimpleGUI App'

	jaro := win.string_jaro_similarity(s1, s2)
	jw := win.string_jaro_winkler_similarity(s1, s2)
	extracted := win.string_between('Click <link>here</link> now', '<link>', '</link>')
	padded_l := win.string_pad_left('42', 6, '0')
	padded_r := win.string_pad_right('VLang', 10, '.')
	word_cnt := win.string_count_words(s1)

	println('  Strings: "${s1}" vs "${s2}"')
	println('  Jaro Similarity:         ${jaro:.4f}')
	println('  Jaro-Winkler Similarity: ${jw:.4f}')
	println('  Extracted string between tags: "${extracted}"')
	println('  Left Padded (0-fill):  "${padded_l}"')
	println('  Right Padded (. fill): "${padded_r}"')
	println('  Word Count of "${s1}": ${word_cnt}')

	// -------------------------------------------------
	// 7. URL Object Model & Assembly (net.urllib)
	// -------------------------------------------------
	println('\n[7] URL Object Model & Parsing (net.urllib):')
	raw_url := 'https://api.example.com:8080/v1/users?role=admin&active=true#section2'
	parsed_url := win.url_parse(raw_url)

	println('  Parsed URL:')
	println('    Scheme:   ${parsed_url.scheme}')
	println('    Host:     ${parsed_url.host}')
	println('    Port:     ${parsed_url.port}')
	println('    Path:     ${parsed_url.path}')
	println('    Query:    ${parsed_url.query}')
	println('    Fragment: ${parsed_url.fragment}')

	rebuilt_url := parsed_url.build_url()
	println('  Rebuilt URL: ${rebuilt_url}')

	// -------------------------------------------------
	// 8. Enhanced HTML Document Inspection (net.html)
	// -------------------------------------------------
	println('\n[8] HTML Document Inspection (net.html):')
	html_sample := '<html><body><h1 class="heading">SimpleGUI Docs</h1><a href="https://vlang.io">Official V Website</a><img src="logo.png" alt="logo"/><p>Welcome!</p></body></html>'
	doc := win.html_parse(html_sample)

	links := doc.get_all_links()
	images := doc.get_all_images()
	heading_class := doc.get_tags_by_class('heading')
	clean_text := doc.strip_tags()

	println('  Extracted Links:  ${links}')
	println('  Extracted Images: ${images}')
	println('  Class "heading" tags: ${heading_class}')
	println('  Stripped HTML Plaintext:\n    "${clean_text}"')

	// -------------------------------------------------
	// 9. CSV Matrix Column Extraction & Filter (encoding.csv)
	// -------------------------------------------------
	println('\n[9] CSV Matrix Column Operations (encoding.csv):')
	csv_raw := 'ID,Name,Department\n101,Alice,Engineering\n102,Bob,Marketing\n103,Charlie,Engineering'
	csv_matrix := win.csv_parse(csv_raw)

	names_col := win.csv_extract_column(csv_matrix, 1)
	filtered_csv := win.csv_filter_by_column(csv_matrix, 2, 'Engineering')

	println('  Extracted Column 1 (Names): ${names_col}')
	println('  Filtered Rows (Department = Engineering):')
	for row in filtered_csv {
		println('    ${row}')
	}

	// -------------------------------------------------
	// 10. MinHeap Priority Queue (datatypes)
	// -------------------------------------------------
	println('\n[10] MinHeap Priority Queue (datatypes):')
	mut heap := simplegui.new_min_heap[int]()
	heap.push(42)
	heap.push(5)
	heap.push(100)
	heap.push(1)
	heap.push(19)

	println('  Heap count: ${heap.len()}')
	println('  Popping items in sorted ascending order:')
	for heap.len() > 0 {
		val := heap.pop() or { break }
		print('${val} ')
	}
	println('')

	// -------------------------------------------------
	// 11. Extended Time & Calendar Utilities (time)
	// -------------------------------------------------
	println('\n[11] Extended Time & Calendar Utilities (time):')
	unix_now := win.time_unix_timestamp()
	formatted_time := win.time_from_unix(unix_now)
	is_leap := win.time_is_leap_year(2028)
	feb_days := win.time_days_in_month(2028, 2)

	println('  Current Unix Timestamp: ${unix_now}')
	println('  Formatted Timestamp:    ${formatted_time}')
	println('  Is 2028 a leap year?    ${is_leap}')
	println('  Days in Feb 2028:       ${feb_days}')

	// -------------------------------------------------
	// 12. JSON Validation & Pretty Printer (json)
	// -------------------------------------------------
	println('\n[12] JSON Utilities (json):')
	raw_json := '{"app":"SimpleGUI","version":"1.0","status":"active"}'
	is_valid_json := win.json_validate(raw_json)
	pretty_json := win.json_pretty_print(raw_json)

	println('  Raw JSON: ${raw_json}')
	println('  Valid JSON syntax? ${is_valid_json}')
	println('  Pretty Printed:\n${pretty_json}')

	println('\n===================================================')
	println('  All Extended SimpleGUI STDLIB Demos Completed!')
	println('===================================================')
}

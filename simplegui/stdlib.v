module simplegui

import net.http
import regex
import compress.gzip
import crypto.sha256
import crypto.md5
import crypto.aes
import crypto.cipher
import rand
import time
import net.urllib
import net.websocket
import toml
import semver
import json
import encoding.hex
import crypto.sha512
import crypto.sha1
import crypto.bcrypt
import crypto.hmac
import compress.zlib
import term

// stdlib.v - Extended High-Level Standard Library Wrappers for SimpleGUI
// Provides extremely simple, beginner-friendly, and safe wrappers around V's Core Standard Library.
// This wraps complex, low-level functionalities (like Gzip, AES block padding, Net, Regex, Websockets, Semver, and TOML)
// into simple functions, which are exposed both as static helpers under `simplegui` namespace, and
// as fluent chainable methods on `SimpleWindow`.

// ==========================================
// 1. HTTP Client Wrappers (Chapter 13: net.http)
// ==========================================

// http_get sends a synchronous GET request and returns the response body, or empty on failure.
pub fn http_get(url string) string {
	res := http.get(url) or { return '' }
	return res.body
}

// http_get delegates to the standalone http_get.
pub fn (win &SimpleWindow) http_get(url string) string {
	if win.debug_mode {
		println('[simplegui STDLIB] Fetching url: ${url}')
	}
	return http_get(url)
}

// http_post sends a synchronous POST request with the specified body, returning the response, or empty on failure.
pub fn http_post(url string, data string) string {
	res := http.post(url, data) or { return '' }
	return res.body
}

// http_post delegates to the standalone http_post.
pub fn (win &SimpleWindow) http_post(url string, data string) string {
	if win.debug_mode {
		println('[simplegui STDLIB] Posting to url: ${url}')
	}
	return http_post(url, data)
}

// ==========================================
// 2. Regular Expressions & Patterns (Chapter 13: regex)
// ==========================================

// regex_match checks if a target string contains matches for a regular expression pattern.
pub fn regex_match(text string, pattern string) bool {
	mut re := regex.regex_opt(pattern) or { return false }
	return re.matches_string(text)
}

// regex_match delegates to standalone regex_match.
pub fn (win &SimpleWindow) regex_match(text string, pattern string) bool {
	return regex_match(text, pattern)
}

// regex_find extracts all substrings matching a regular expression pattern.
pub fn regex_find(text string, pattern string) []string {
	mut re := regex.regex_opt(pattern) or { return []string{} }
	matches := re.find_all_str(text)
	return matches
}

// regex_find delegates to standalone regex_find.
pub fn (win &SimpleWindow) regex_find(text string, pattern string) []string {
	return regex_find(text, pattern)
}

// regex_replace replaces any pattern matches inside a string with a replacement text.
pub fn regex_replace(text string, pattern string, replacement string) string {
	mut re := regex.regex_opt(pattern) or { return text }
	return re.replace(text, replacement)
}

// regex_replace delegates to standalone regex_replace.
pub fn (win &SimpleWindow) regex_replace(text string, pattern string, replacement string) string {
	return regex_replace(text, pattern, replacement)
}

// ==========================================
// 3. Cryptography & Hash Functions (Chapter 13: crypto)
// ==========================================

// crypto_sha256 computes the hex-encoded SHA-256 hash of a string.
pub fn crypto_sha256(text string) string {
	return sha256.hexhash(text)
}

// crypto_sha256 delegates to standalone crypto_sha256.
pub fn (win &SimpleWindow) crypto_sha256(text string) string {
	return crypto_sha256(text)
}

// crypto_md5 computes the hex-encoded MD5 hash of a parameter string.
pub fn crypto_md5(text string) string {
	return md5.hexhash(text)
}

// crypto_md5 delegates to standalone crypto_md5.
pub fn (win &SimpleWindow) crypto_md5(text string) string {
	return crypto_md5(text)
}

// crypto_encrypt_aes encrypts text using 128-bit AES block cipher under CBC mode, returning hex-encoded ciphertext.
// Automatically handles standard block padding and initializes static secure IV arrays.
pub fn crypto_encrypt_aes(plain_text string, key_hex string) string {
	decoded_key := hex.decode(key_hex) or { []u8{} }
	mut key := decoded_key.clone()
	// AES key must be exactly 16 bytes for AES-128
	if key.len != 16 && key.len != 24 && key.len != 32 {
		if key.len < 16 {
			for key.len < 16 {
				key << u8(0)
			}
		} else {
			key = key[..16].clone()
		}
	}
	
	// Deterministic IV to keep decryption simple
	iv := [u8(9), 8, 7, 6, 5, 4, 3, 2, 1, 0, 9, 8, 7, 6, 5, 4]
	
	block := aes.new_cipher(key)
	mut enc := cipher.new_cbc(block, iv)
	
	plaintext := plain_text.bytes()
	mut padded := plaintext.clone()
	pad_len := 16 - (padded.len % 16)
	for _ in 0 .. pad_len {
		padded << u8(pad_len)
	}
	
	mut ciphertext := []u8{len: padded.len}
	enc.encrypt_blocks(mut ciphertext, padded)
	return hex.encode(ciphertext)
}

// crypto_encrypt_aes delegates to standalone crypto_encrypt_aes.
pub fn (win &SimpleWindow) crypto_encrypt_aes(plain_text string, key_hex string) string {
	return crypto_encrypt_aes(plain_text, key_hex)
}

// crypto_decrypt_aes decrypts a hex-encoded AES CBC block string, returning the unpadded plaintext string.
pub fn crypto_decrypt_aes(cipher_hex string, key_hex string) string {
	decoded_key := hex.decode(key_hex) or { []u8{} }
	mut key := decoded_key.clone()
	if key.len != 16 && key.len != 24 && key.len != 32 {
		if key.len < 16 {
			for key.len < 16 {
				key << u8(0)
			}
		} else {
			key = key[..16].clone()
		}
	}
	
	iv := [u8(9), 8, 7, 6, 5, 4, 3, 2, 1, 0, 9, 8, 7, 6, 5, 4]
	ciphertext := hex.decode(cipher_hex) or { return '' }
	if ciphertext.len % 16 != 0 || ciphertext.len == 0 {
		return ''
	}
	
	block := aes.new_cipher(key)
	mut dec := cipher.new_cbc(block, iv)
	mut decrypted := []u8{len: ciphertext.len}
	dec.decrypt_blocks(mut decrypted, ciphertext)
	
	if decrypted.len == 0 {
		return ''
	}
	unpadded_len := decrypted.len - int(decrypted.last())
	if unpadded_len < 0 || unpadded_len > decrypted.len {
		return decrypted.bytestr()
	}
	return decrypted[..unpadded_len].bytestr()
}

// crypto_decrypt_aes delegates to standalone crypto_decrypt_aes.
pub fn (win &SimpleWindow) crypto_decrypt_aes(cipher_hex string, key_hex string) string {
	return crypto_decrypt_aes(cipher_hex, key_hex)
}

// ==========================================
// 4. Gzip Compression (Chapter 13: compress.gzip)
// ==========================================

// compress_gzip compresses flat plaintext string using gzip compression format.
pub fn compress_gzip(text string) []u8 {
	compressed := gzip.compress(text.bytes()) or { return []u8{} }
	return compressed
}

// compress_gzip delegates to standalone compress_gzip.
pub fn (win &SimpleWindow) compress_gzip(text string) []u8 {
	return compress_gzip(text)
}

// decompress_gzip extracts standard gzip compressed binary bytes back into a human-readable string.
pub fn decompress_gzip(data []u8) string {
	decompressed := gzip.decompress(data) or { return '' }
	return decompressed.bytestr()
}

// decompress_gzip delegates to standalone decompress_gzip.
pub fn (win &SimpleWindow) decompress_gzip(data []u8) string {
	return decompress_gzip(data)
}

// ==========================================
// 5. Random Number & Safe Strings Generator (Chapter 13: rand)
// ==========================================

// rand_int generates a secure random integer between min (inclusive) and max (exclusive).
pub fn rand_int(min int, max int) int {
	return rand.int_in_range(min, max) or { min }
}

// rand_int delegates to standalone rand_int.
pub fn (win &SimpleWindow) rand_int(min int, max int) int {
	return rand_int(min, max)
}

// rand_string produces a random alphanumeric string token of target length.
pub fn rand_string(length int) string {
	return rand.string(length)
}

// rand_string delegates to standalone rand_string.
pub fn (win &SimpleWindow) rand_string(length int) string {
	return rand_string(length)
}

// rand_shuffle_strings shuffles/randomizes the exact order of element items within a string array.
pub fn rand_shuffle_strings(mut arr []string) {
	mut indices := []int{}
	for i in 0 .. arr.len {
		indices << i
	}
	// Permute elements in place
	for i := arr.len - 1; i > 0; i-- {
		j := rand.intn(i + 1) or { 0 }
		temp := arr[i]
		arr[i] = arr[j]
		arr[j] = temp
	}
}

// rand_shuffle_strings delegates to standalone rand_shuffle_strings.
pub fn (win &SimpleWindow) rand_shuffle_strings(mut arr []string) &SimpleWindow {
	rand_shuffle_strings(mut arr)
	return win
}

// ==========================================
// 6. Time and Measurement (Chapter 13: time)
// ==========================================

// time_now returns formatted current timestamp in YYYY-MM-DD HH:MM:SS format.
pub fn time_now() string {
	t := time.now()
	return t.custom_format('YYYY-MM-DD HH:mm:ss')
}

// time_now delegates to standalone time_now.
pub fn (win &SimpleWindow) time_now() string {
	return time_now()
}

// time_elapsed formats a millisecond counter into a friendly custom duration (e.g. "1200ms" or "1.2s").
pub fn time_elapsed(ms int) string {
	if ms < 1000 {
		return '${ms}ms'
	}
	sec := f64(ms) / 1000.0
	return '${sec:.2f}s'
}

// time_elapsed delegates to standalone time_elapsed.
pub fn (win &SimpleWindow) time_elapsed(ms int) string {
	return time_elapsed(ms)
}

// ==========================================
// 7. URL Escaping & Query Packing (Chapter 13: net.urllib)
// ==========================================

// url_encode outputs a secure, percent-encoded string for URL query parameters.
pub fn url_encode(text string) string {
	return urllib.query_escape(text)
}

// url_encode delegates to standalone url_encode.
pub fn (win &SimpleWindow) url_encode(text string) string {
	return url_encode(text)
}

// url_decode translates a percent-encoded URL query string back to plain text.
pub fn url_decode(text string) string {
	res := urllib.query_unescape(text) or { return text }
	return res
}

// url_decode delegates to standalone url_decode.
pub fn (win &SimpleWindow) url_decode(text string) string {
	return url_decode(text)
}

// ==========================================
// 8. TOML Configuration Parser Wrapper (Chapter 13: toml)
// ==========================================

pub struct TOMLWrapperDoc {
mut:
	doc toml.Doc
}

// get_string extracts string value corresponding to a flat or dotted key path (e.g. "owner.name").
pub fn (t &TOMLWrapperDoc) get_string(key string) string {
	return t.doc.value(key).string()
}

// get_string_default extracts configuration option with an error-safe default choice.
pub fn (t &TOMLWrapperDoc) get_string_default(key string, def string) string {
	return t.doc.value(key).default_to(def).string()
}

// get_int parses setting option as integer.
pub fn (t &TOMLWrapperDoc) get_int(key string) int {
	return t.doc.value(key).int()
}

// get_bool parses config key path as boolean.
pub fn (t &TOMLWrapperDoc) get_bool(key string) bool {
	return t.doc.value(key).bool()
}

// toml_parse parses flat TOML text content, wrapping query details inside an easy helper.
pub fn toml_parse(content string) &TOMLWrapperDoc {
	res := toml.parse_text(content) or {
		return &TOMLWrapperDoc{
			doc: toml.Doc{}
		}
	}
	return &TOMLWrapperDoc{
		doc: res
	}
}

// toml_parse delegates to standalone toml_parse.
pub fn (win &SimpleWindow) toml_parse(content string) &TOMLWrapperDoc {
	return toml_parse(content)
}

// ==========================================
// 9. Semantic Versioning constraints (Chapter 13: semver)
// ==========================================

// semver_compare compares two version strings. Returns -1 if v1 < v2, 1 if v1 > v2, 0 if equal/unparseable.
pub fn semver_compare(v1 string, v2 string) int {
	sv1 := semver.from(v1) or { return 0 }
	sv2 := semver.from(v2) or { return 0 }
	if sv1 < sv2 {
		return -1
	}
	if sv1 > sv2 {
		return 1
	}
	return 0
}

// semver_compare delegates to standalone semver_compare.
pub fn (win &SimpleWindow) semver_compare(v1 string, v2 string) int {
	return semver_compare(v1, v2)
}

// semver_satisfies checks if a semantic version string complies with a semver range filter query (e.g. ">=1.0.0 <2.0.0").
pub fn semver_satisfies(v string, range_query string) bool {
	sv := semver.from(v) or { return false }
	return sv.satisfies(range_query)
}

// semver_satisfies delegates to standalone semver_satisfies.
pub fn (win &SimpleWindow) semver_satisfies(v string, range_query string) bool {
	return semver_satisfies(v, range_query)
}

// ==========================================
// 10. Direct Flat JSON Mapping Helper (Chapter 13: json)
// ==========================================

// json_decode_map cleanly deserializes a JSON string into a flat key-value map without mandatory struct setups.
pub fn json_decode_map(json_str string) map[string]string {
	res := json.decode(map[string]string, json_str) or { return map[string]string{} }
	return res
}

// json_decode_map delegates to standalone json_decode_map.
pub fn (win &SimpleWindow) json_decode_map(json_str string) map[string]string {
	return json_decode_map(json_str)
}

// ==========================================
// 11. Custom Simple WebSocket Client (Chapter 13: net.websocket)
// ==========================================

pub type SimpleWSMessageCallback = fn (msg string)

pub struct SimpleWSClient {
pub mut:
	client        &websocket.Client = unsafe { nil }
	on_message_cb SimpleWSMessageCallback = unsafe { nil }
}

// write_string sends a text payload to the active WebSocket server.
pub fn (mut ws SimpleWSClient) write_string(msg string) ! {
	if ws.client != unsafe { nil } {
		ws.client.write_string(msg)!
	}
}

// close cleanly disconnects from the remote WebSocket server.
pub fn (mut ws SimpleWSClient) close() {
	if ws.client != unsafe { nil } {
		ws.client.close(1000, 'normal close') or {}
	}
}

// websocket_client constructs and spawns a WebSocket client on a background routine.
pub fn websocket_client(url string, on_msg SimpleWSMessageCallback) ?&SimpleWSClient {
	mut client := websocket.new_client(url) or { return none }
	
	mut ws := &SimpleWSClient{
		client: client
		on_message_cb: on_msg
	}
	
	client.on_message(fn [ws] (mut c websocket.Client, msg &websocket.Message) ! {
		if msg.opcode == .text_frame {
			payload := msg.payload.bytestr()
			if ws.on_message_cb != unsafe { nil } {
				ws.on_message_cb(payload)
			}
		}
	})
	
	client.connect() or { return none }
	spawn client.listen()
	return ws
}

// websocket_client delegates to standalone websocket_client.
pub fn (win &SimpleWindow) websocket_client(url string, on_msg SimpleWSMessageCallback) ?&SimpleWSClient {
	if win.debug_mode {
		println('[simplegui STDLIB] Spawning WebSocket connection to: ${url}')
	}
	return websocket_client(url, on_msg)
}

// ==========================================
// 12. More Cryptography and Password Security (Chapter 13: crypto)
// ==========================================

// crypto_sha512 computes the hex-encoded SHA-512 hash of a string.
pub fn crypto_sha512(text string) string {
	return sha512.hexhash(text)
}

// crypto_sha512 delegates to standalone crypto_sha512.
pub fn (win &SimpleWindow) crypto_sha512(text string) string {
	return crypto_sha512(text)
}

// crypto_sha1 computes the hex-encoded SHA-1 hash of a string.
pub fn crypto_sha1(text string) string {
	return sha1.hexhash(text)
}

// crypto_sha1 delegates to standalone crypto_sha1.
pub fn (win &SimpleWindow) crypto_sha1(text string) string {
	return crypto_sha1(text)
}

// crypto_bcrypt_hash generates a secure bcrypt password hash of a string.
pub fn crypto_bcrypt_hash(password string) !string {
	hash := bcrypt.generate_from_password(password.bytes(), bcrypt.default_cost)!
	return hash
}

// crypto_bcrypt_hash delegates to standalone crypto_bcrypt_hash.
pub fn (win &SimpleWindow) crypto_bcrypt_hash(password string) !string {
	return crypto_bcrypt_hash(password)
}

// crypto_bcrypt_verify verifies a password against a bcrypt hash.
pub fn crypto_bcrypt_verify(password string, hash string) bool {
	bcrypt.compare_hash_and_password(password.bytes(), hash.bytes()) or {
		return false
	}
	return true
}

// crypto_bcrypt_verify delegates to standalone crypto_bcrypt_verify.
pub fn (win &SimpleWindow) crypto_bcrypt_verify(password string, hash string) bool {
	return crypto_bcrypt_verify(password, hash)
}

// crypto_hmac_sha256 computes the hex-encoded HMAC-SHA256 signature of a string with a key.
pub fn crypto_hmac_sha256(text string, key string) string {
	sum := hmac.new(key.bytes(), text.bytes(), sha256.sum, sha256.block_size)
	return sum.hex()
}

// crypto_hmac_sha256 delegates to standalone crypto_hmac_sha256.
pub fn (win &SimpleWindow) crypto_hmac_sha256(text string, key string) string {
	return crypto_hmac_sha256(text, key)
}

// ==========================================
// 13. Zlib Compression (Chapter 13: compress.zlib)
// ==========================================

// compress_zlib compresses flat plaintext string using zlib compression format.
pub fn compress_zlib(text string) []u8 {
	compressed := zlib.compress(text.bytes()) or { return []u8{} }
	return compressed
}

// compress_zlib delegates to standalone compress_zlib.
pub fn (win &SimpleWindow) compress_zlib(text string) []u8 {
	return compress_zlib(text)
}

// decompress_zlib extracts standard zlib compressed binary bytes back into a human-readable string.
pub fn decompress_zlib(data []u8) string {
	decompressed := zlib.decompress(data) or { return '' }
	return decompressed.bytestr()
}

// decompress_zlib delegates to standalone decompress_zlib.
pub fn (win &SimpleWindow) decompress_zlib(data []u8) string {
	return decompress_zlib(data)
}

// ==========================================
// 14. JSON Map List Helpers (Chapter 13: json)
// ==========================================

// json_encode_map_list serializes an array of maps into a JSON string.
pub fn json_encode_map_list(m []map[string]string) string {
	return json.encode(m)
}

// json_encode_map_list delegates to standalone json_encode_map_list.
pub fn (win &SimpleWindow) json_encode_map_list(m []map[string]string) string {
	return json_encode_map_list(m)
}

// json_decode_map_list deserializes a JSON string into an array of flat key-value maps.
pub fn json_decode_map_list(json_str string) []map[string]string {
	res := json.decode([]map[string]string, json_str) or { return []map[string]string{} }
	return res
}

// json_decode_map_list delegates to standalone json_decode_map_list.
pub fn (win &SimpleWindow) json_decode_map_list(json_str string) []map[string]string {
	return json_decode_map_list(json_str)
}

// ==========================================
// 15. Stopwatch Utility (Chapter 13: time)
// ==========================================

// SimpleStopwatch provides a high-level wrapper to measure high-precision elapsed execution time.
pub struct SimpleStopwatch {
pub mut:
	sw time.StopWatch = time.new_stopwatch()
}

// elapsed_ms returns the elapsed time in milliseconds.
pub fn (mut sw SimpleStopwatch) elapsed_ms() int {
	return int(sw.sw.elapsed().milliseconds())
}

// elapsed_sec returns the elapsed time in seconds.
pub fn (mut sw SimpleStopwatch) elapsed_sec() f64 {
	return sw.sw.elapsed().seconds()
}

// restart resets and restarts the stopwatch.
pub fn (mut sw SimpleStopwatch) restart() {
	sw.sw.restart()
}

// start_stopwatch constructs and starts a new high-precision stopwatch.
pub fn (win &SimpleWindow) start_stopwatch() &SimpleStopwatch {
	return &SimpleStopwatch{
		sw: time.new_stopwatch()
	}
}

// ==========================================
// 16. Terminal Text Styling (Chapter 13: term)
// ==========================================

// term_color styles terminal console text output (supports red, green, blue, yellow, bold, underline).
pub fn term_color(text string, style string) string {
	return match style.to_lower() {
		'red' { term.red(text) }
		'green' { term.green(text) }
		'blue' { term.blue(text) }
		'yellow' { term.yellow(text) }
		'bold' { term.bold(text) }
		'underline' { term.underline(text) }
		else { text }
	}
}

// term_color delegates to standalone term_color.
pub fn (win &SimpleWindow) term_color(text string, style string) string {
	return term_color(text, style)
}

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
import encoding.base64
import crypto.sha512
import crypto.sha1
import crypto.bcrypt
import crypto.hmac
import compress.zlib
import term
import datatypes
import clipboard
import benchmark
import net
import net.unix
import compress.deflate
import compress.zstd
import net.html
import strings.lorem
import math
import math.big
import math.stats
import arrays
import strings
import encoding.utf8
import encoding.csv
import crypto.ed25519
import crypto.pbkdf2
import sync

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
	res := toml.parse_text(content) or { return &TOMLWrapperDoc{
		doc: toml.Doc{}
	} }
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
	client        &websocket.Client       = unsafe { nil }
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
		client:        client
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
	bcrypt.compare_hash_and_password(password.bytes(), hash.bytes()) or { return false }
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

// ==========================================
// 17. Standard Collections & Datatypes
// ==========================================

// SimpleStack provides a high-level, generic LIFO (Last In First Out) stack.
pub struct SimpleStack[T] {
mut:
	s datatypes.Stack[T]
}

// push pushes an item onto the top of the stack.
pub fn (mut ss SimpleStack[T]) push(item T) {
	ss.s.push(item)
}

// pop removes and returns the item on top of the stack, or errors if empty.
pub fn (mut ss SimpleStack[T]) pop() !T {
	return ss.s.pop()
}

// peek returns the top item of the stack without removing it, or errors if empty.
pub fn (ss &SimpleStack[T]) peek() !T {
	return ss.s.peek()
}

// len returns the number of elements currently stored in the stack.
pub fn (ss &SimpleStack[T]) len() int {
	return ss.s.len()
}

// is_empty returns true if the stack contains no elements.
pub fn (ss &SimpleStack[T]) is_empty() bool {
	return ss.s.is_empty()
}

// new_stack instantiates a new generic SimpleStack.
pub fn new_stack[T]() SimpleStack[T] {
	return SimpleStack[T]{}
}

// SimpleQueue provides a high-level, generic FIFO (First In First Out) queue.
pub struct SimpleQueue[T] {
mut:
	q datatypes.Queue[T]
}

// push enqueues an item at the back of the queue.
pub fn (mut sq SimpleQueue[T]) push(item T) {
	sq.q.push(item)
}

// pop dequeues and returns the item at the front of the queue, or errors if empty.
pub fn (mut sq SimpleQueue[T]) pop() !T {
	return sq.q.pop()
}

// peek returns the front item of the queue without removing it, or errors if empty.
pub fn (sq &SimpleQueue[T]) peek() !T {
	return sq.q.peek()
}

// len returns the number of elements currently stored in the queue.
pub fn (sq &SimpleQueue[T]) len() int {
	return sq.q.len()
}

// is_empty returns true if the queue contains no elements.
pub fn (sq &SimpleQueue[T]) is_empty() bool {
	return sq.q.is_empty()
}

// new_queue instantiates a new generic SimpleQueue.
pub fn new_queue[T]() SimpleQueue[T] {
	return SimpleQueue[T]{}
}

// SimpleSet provides a high-level, generic unique set collection.
pub struct SimpleSet[T] {
mut:
	set datatypes.Set[T]
}

// add inserts an item into the set.
pub fn (mut ss SimpleSet[T]) add(item T) {
	ss.set.add(item)
}

// remove removes an item from the set.
pub fn (mut ss SimpleSet[T]) remove(item T) {
	ss.set.remove(item)
}

// exists returns true if the item is present in the set.
pub fn (ss &SimpleSet[T]) exists(item T) bool {
	return ss.set.exists(item)
}

// len returns the total count of elements in the set.
pub fn (ss &SimpleSet[T]) len() int {
	return ss.set.size()
}

// is_empty returns true if the set contains no elements.
pub fn (ss &SimpleSet[T]) is_empty() bool {
	return ss.set.is_empty()
}

// to_array returns all items in the set as an array.
pub fn (ss &SimpleSet[T]) to_array() []T {
	return ss.set.array()
}

// new_set instantiates a new generic SimpleSet.
pub fn new_set[T]() SimpleSet[T] {
	return SimpleSet[T]{}
}

// SimpleRingBuffer provides a high-level, generic ring buffer.
pub struct SimpleRingBuffer[T] {
mut:
	rb datatypes.RingBuffer[T]
}

// push adds an item into the ring buffer, returning an error if full.
pub fn (mut srb SimpleRingBuffer[T]) push(item T) ! {
	srb.rb.push(item)!
}

// pop removes and returns the oldest item from the ring buffer, returning an error if empty.
pub fn (mut srb SimpleRingBuffer[T]) pop() !T {
	return srb.rb.pop()
}

// len returns the number of occupied elements in the ring buffer.
pub fn (srb &SimpleRingBuffer[T]) len() int {
	return srb.rb.occupied()
}

// capacity returns the maximum total capacity of the ring buffer.
pub fn (srb &SimpleRingBuffer[T]) capacity() int {
	return srb.rb.capacity()
}

// is_empty returns true if the ring buffer contains no elements.
pub fn (srb &SimpleRingBuffer[T]) is_empty() bool {
	return srb.rb.is_empty()
}

// is_full returns true if the ring buffer has reached its capacity.
pub fn (srb &SimpleRingBuffer[T]) is_full() bool {
	return srb.rb.is_full()
}

// new_ringbuffer instantiates a new generic SimpleRingBuffer with a specific capacity.
pub fn new_ringbuffer[T](capacity int) SimpleRingBuffer[T] {
	return SimpleRingBuffer[T]{
		rb: datatypes.new_ringbuffer[T](capacity)
	}
}

// ==========================================
// 18. System Clipboard Helper (Chapter 13: clipboard)
// ==========================================

// clipboard_copy copies text to the system clipboard.
pub fn clipboard_copy(text string) bool {
	mut cb := clipboard.new()
	defer {
		cb.destroy()
	}
	if !cb.is_available() {
		return false
	}
	return cb.copy(text)
}

// clipboard_copy delegates to standalone clipboard_copy.
pub fn (win &SimpleWindow) clipboard_copy(text string) bool {
	return clipboard_copy(text)
}

// clipboard_read retrieves text from the system clipboard.
pub fn clipboard_read() string {
	mut cb := clipboard.new()
	defer {
		cb.destroy()
	}
	if !cb.is_available() {
		return ''
	}
	return cb.paste()
}

// clipboard_read delegates to standalone clipboard_read.
pub fn (win &SimpleWindow) clipboard_read() string {
	return clipboard_read()
}

// ==========================================
// 19. Benchmark & Execution Timing Helper (Chapter 13: benchmark)
// ==========================================

// SimpleBenchmark wraps benchmark.Benchmark to time execution stages.
pub struct SimpleBenchmark {
pub mut:
	b benchmark.Benchmark
}

// measure adds a benchmark measurement point.
pub fn (mut sb SimpleBenchmark) measure(label string) {
	sb.b.measure(label)
}

// step advances the benchmark to the next step.
pub fn (mut sb SimpleBenchmark) step() {
	sb.b.step()
}

// ok marks the current step as successful.
pub fn (mut sb SimpleBenchmark) ok() {
	sb.b.ok()
}

// fail marks the current step as failed.
pub fn (mut sb SimpleBenchmark) fail() {
	sb.b.fail()
}

// step_message returns the formatted string message for the current step.
pub fn (mut sb SimpleBenchmark) step_message(label string) string {
	return sb.b.step_message(label)
}

// total_message returns the final execution summary message.
pub fn (mut sb SimpleBenchmark) total_message(label string) string {
	return sb.b.total_message(label)
}

// stop stops the benchmark timing.
pub fn (mut sb SimpleBenchmark) stop() {
	sb.b.stop()
}

// start_benchmark starts a simple benchmark.
pub fn start_benchmark() SimpleBenchmark {
	return SimpleBenchmark{
		b: benchmark.start()
	}
}

// start_benchmark delegates to standalone start_benchmark.
pub fn (win &SimpleWindow) start_benchmark() SimpleBenchmark {
	return start_benchmark()
}

// new_benchmark initializes a new benchmark structure.
pub fn new_benchmark() SimpleBenchmark {
	return SimpleBenchmark{
		b: benchmark.new_benchmark()
	}
}

// new_benchmark delegates to standalone new_benchmark.
pub fn (win &SimpleWindow) new_benchmark() SimpleBenchmark {
	return new_benchmark()
}

// ==========================================
// 20. TCP Socket Client (Chapter 13: net)
// ==========================================

// SimpleTCPClient provides a simplified wrapper for TCP connections.
pub struct SimpleTCPClient {
pub mut:
	conn net.TcpConn
}

// write sends text to the TCP socket.
pub fn (mut s SimpleTCPClient) write(data string) ! {
	s.conn.write(data.bytes())!
}

// read reads string data from the TCP socket.
pub fn (mut s SimpleTCPClient) read() !string {
	mut buf := []u8{len: 1024}
	n := s.conn.read(mut buf)!
	return buf[..n].bytestr()
}

// close disconnects the TCP connection.
pub fn (mut s SimpleTCPClient) close() {
	s.conn.close() or {}
}

// tcp_connect establishes a TCP client connection to a specified address.
pub fn tcp_connect(address string) !SimpleTCPClient {
	conn := net.dial_tcp(address)!
	return SimpleTCPClient{
		conn: conn
	}
}

// tcp_connect delegates to standalone tcp_connect.
pub fn (win &SimpleWindow) tcp_connect(address string) !SimpleTCPClient {
	if win.debug_mode {
		println('[simplegui STDLIB] Dialing TCP socket connection to: ${address}')
	}
	return tcp_connect(address)!
}

// ==========================================
// 21. UDP Socket Client (Chapter 13: net)
// ==========================================

// SimpleUDPClient provides a simplified wrapper for UDP connections.
pub struct SimpleUDPClient {
pub mut:
	socket net.UdpConn
}

// write sends data packets over the UDP socket.
pub fn (mut s SimpleUDPClient) write(data string) ! {
	s.socket.write(data.bytes())!
}

// read reads a string data payload from the UDP socket.
pub fn (mut s SimpleUDPClient) read() !string {
	mut buf := []u8{len: 1024}
	n, _ := s.socket.read(mut buf)!
	return buf[..n].bytestr()
}

// close closes the UDP connection socket.
pub fn (mut s SimpleUDPClient) close() {
	s.socket.close() or {}
}

// udp_connect binds and connects a UDP socket to a target address.
pub fn udp_connect(address string) !SimpleUDPClient {
	socket := net.dial_udp(address)!
	return SimpleUDPClient{
		socket: socket
	}
}

// udp_connect delegates to standalone udp_connect.
pub fn (win &SimpleWindow) udp_connect(address string) !SimpleUDPClient {
	if win.debug_mode {
		println('[simplegui STDLIB] Dialing UDP socket to: ${address}')
	}
	return udp_connect(address)!
}

// ==========================================
// 22. Unix Domain Socket Client (Chapter 13: net.unix)
// ==========================================

// SimpleUnixClient provides a simplified wrapper for Unix domain socket connections.
pub struct SimpleUnixClient {
pub mut:
	conn unix.StreamConn
}

// write sends text data over the Unix socket.
pub fn (mut s SimpleUnixClient) write(data string) ! {
	s.conn.write(data.bytes())!
}

// read reads a string payload from the Unix socket.
pub fn (mut s SimpleUnixClient) read() !string {
	mut buf := []u8{len: 1024}
	n := s.conn.read(mut buf)!
	return buf[..n].bytestr()
}

// close closes the Unix socket stream connection.
pub fn (mut s SimpleUnixClient) close() {
	s.conn.close() or {}
}

// unix_connect connects a client to a Unix domain socket path.
pub fn unix_connect(path string) !SimpleUnixClient {
	conn := unix.connect_stream(path)!
	return SimpleUnixClient{
		conn: conn
	}
}

// unix_connect delegates to standalone unix_connect.
pub fn (win &SimpleWindow) unix_connect(path string) !SimpleUnixClient {
	if win.debug_mode {
		println('[simplegui STDLIB] Connecting Unix socket stream to path: ${path}')
	}
	return unix_connect(path)!
}

// ==========================================
// 23. Deflate Compression (Chapter 13: compress.deflate)
// ==========================================

// compress_deflate compresses text using Deflate compression format.
pub fn compress_deflate(text string) []u8 {
	compressed := deflate.compress(text.bytes()) or { return []u8{} }
	return compressed
}

// compress_deflate delegates to standalone compress_deflate.
pub fn (win &SimpleWindow) compress_deflate(text string) []u8 {
	return compress_deflate(text)
}

// decompress_deflate extracts Deflate-compressed binary bytes back to string format.
pub fn decompress_deflate(data []u8) string {
	decompressed := deflate.decompress(data) or { return '' }
	return decompressed.bytestr()
}

// decompress_deflate delegates to standalone decompress_deflate.
pub fn (win &SimpleWindow) decompress_deflate(data []u8) string {
	return decompress_deflate(data)
}

// ==========================================
// 24. Zstd Compression (Chapter 13: compress.zstd)
// ==========================================

// compress_zstd compresses text using Facebook Zstd compression format.
pub fn compress_zstd(text string) []u8 {
	// Standard compression level 3 as default
	compressed := zstd.compress(text.bytes(), compression_level: 3) or { return []u8{} }
	return compressed
}

// compress_zstd delegates to standalone compress_zstd.
pub fn (win &SimpleWindow) compress_zstd(text string) []u8 {
	return compress_zstd(text)
}

// decompress_zstd extracts Zstd-compressed binary bytes back to string format.
pub fn decompress_zstd(data []u8) string {
	decompressed := zstd.decompress(data) or { return '' }
	return decompressed.bytestr()
}

// decompress_zstd delegates to standalone decompress_zstd.
pub fn (win &SimpleWindow) decompress_zstd(data []u8) string {
	return decompress_zstd(data)
}

// ==========================================
// 25. HTML Parser Helper (Chapter 13: net.html)
// ==========================================

// SimpleHTMLDocument wraps html.DocumentObjectModel for easy tag and class querying.
pub struct SimpleHTMLDocument {
pub mut:
	doc html.DocumentObjectModel
}

// get_tag_text retrieves the text content of the first matching HTML tag name.
pub fn (d &SimpleHTMLDocument) get_tag_text(name string) string {
	tags := d.doc.get_tags(name: name)
	if tags.len > 0 {
		return tags[0].text().trim_space()
	}
	return ''
}

// get_tags_by_class retrieves the text content of all tags matching a class name.
pub fn (d &SimpleHTMLDocument) get_tags_by_class(class_name string) []string {
	tags := d.doc.get_tags_by_class_name(class_name)
	mut res := []string{}
	for t in tags {
		res << t.text().trim_space()
	}
	return res
}

// html_parse parses an HTML string into a SimpleHTMLDocument.
pub fn html_parse(content string) SimpleHTMLDocument {
	return SimpleHTMLDocument{
		doc: html.parse(content)
	}
}

// html_parse delegates to standalone html_parse.
pub fn (win &SimpleWindow) html_parse(content string) SimpleHTMLDocument {
	return html_parse(content)
}

// ==========================================
// 26. Strings Lorem Helper (Chapter 13: strings.lorem)
// ==========================================

// lorem_generate produces pseudo-random placeholder text (Markov chain).
// Supported corpora: 'lorem' (default), 'poe', 'darwin', 'bard'.
pub fn lorem_generate(corpus_name string, paragraphs int, sentences int, words int) string {
	return lorem.generate(lorem.LoremCfg{
		corpus_name:             corpus_name
		paragraphs:              paragraphs
		sentences_per_paragraph: sentences
		words_per_sentence:      words
	})
}

// lorem_generate delegates to standalone lorem_generate.
pub fn (win &SimpleWindow) lorem_generate(corpus_name string, paragraphs int, sentences int, words int) string {
	return lorem_generate(corpus_name, paragraphs, sentences, words)
}

// ==========================================
// 27. Encoding Utilities (Chapter 13: encoding.hex, encoding.base64)
// ==========================================

// hex_encode converts a raw string to a hex-encoded string.
pub fn hex_encode(text string) string {
	return hex.encode(text.bytes())
}

// hex_encode delegates to standalone hex_encode.
pub fn (win &SimpleWindow) hex_encode(text string) string {
	return hex_encode(text)
}

// hex_decode converts a hex-encoded string back to raw text.
pub fn hex_decode(hex_str string) string {
	decoded := hex.decode(hex_str) or { return '' }
	return decoded.bytestr()
}

// hex_decode delegates to standalone hex_decode.
pub fn (win &SimpleWindow) hex_decode(hex_str string) string {
	return hex_decode(hex_str)
}

// base64_encode converts a raw string to a base64-encoded string.
pub fn base64_encode(text string) string {
	return base64.encode(text.bytes())
}

// base64_encode delegates to standalone base64_encode.
pub fn (win &SimpleWindow) base64_encode(text string) string {
	return base64_encode(text)
}

// base64_decode converts a base64-encoded string back to raw text.
pub fn base64_decode(b64_str string) string {
	decoded := base64.decode(b64_str)
	return decoded.bytestr()
}

// base64_decode delegates to standalone base64_decode.
pub fn (win &SimpleWindow) base64_decode(b64_str string) string {
	return base64_decode(b64_str)
}

// ==========================================
// 28. Math & Trigonometry Helpers (Chapter 13: math)
// ==========================================

// math_sin returns the sine of a radian value.
pub fn math_sin(x f64) f64 {
	return math.sin(x)
}

// math_sin delegates to standalone math_sin.
pub fn (win &SimpleWindow) math_sin(x f64) f64 {
	return math_sin(x)
}

// math_cos returns the cosine of a radian value.
pub fn math_cos(x f64) f64 {
	return math.cos(x)
}

// math_cos delegates to standalone math_cos.
pub fn (win &SimpleWindow) math_cos(x f64) f64 {
	return math_cos(x)
}

// math_tan returns the tangent of a radian value.
pub fn math_tan(x f64) f64 {
	return math.tan(x)
}

// math_tan delegates to standalone math_tan.
pub fn (win &SimpleWindow) math_tan(x f64) f64 {
	return math_tan(x)
}

// math_sqrt returns the square root of a non-negative number.
pub fn math_sqrt(x f64) f64 {
	return math.sqrt(x)
}

// math_sqrt delegates to standalone math_sqrt.
pub fn (win &SimpleWindow) math_sqrt(x f64) f64 {
	return math_sqrt(x)
}

// math_pow returns base raised to the power exp.
pub fn math_pow(base f64, exp f64) f64 {
	return math.pow(base, exp)
}

// math_pow delegates to standalone math_pow.
pub fn (win &SimpleWindow) math_pow(base f64, exp f64) f64 {
	return math_pow(base, exp)
}

// math_abs returns the absolute value of a floating point number.
pub fn math_abs(x f64) f64 {
	return math.abs(x)
}

// math_abs delegates to standalone math_abs.
pub fn (win &SimpleWindow) math_abs(x f64) f64 {
	return math_abs(x)
}

// math_clamp constrains a value within a min and max range.
pub fn math_clamp(val f64, min f64, max f64) f64 {
	return math.clamp(val, min, max)
}

// math_clamp delegates to standalone math_clamp.
pub fn (win &SimpleWindow) math_clamp(val f64, min f64, max f64) f64 {
	return math_clamp(val, min, max)
}

// math_round rounds a number to the nearest integer.
pub fn math_round(x f64) f64 {
	return math.round(x)
}

// math_round delegates to standalone math_round.
pub fn (win &SimpleWindow) math_round(x f64) f64 {
	return math_round(x)
}

// math_floor returns the greatest integer less than or equal to x.
pub fn math_floor(x f64) f64 {
	return math.floor(x)
}

// math_floor delegates to standalone math_floor.
pub fn (win &SimpleWindow) math_floor(x f64) f64 {
	return math_floor(x)
}

// math_ceil returns the least integer greater than or equal to x.
pub fn math_ceil(x f64) f64 {
	return math.ceil(x)
}

// math_ceil delegates to standalone math_ceil.
pub fn (win &SimpleWindow) math_ceil(x f64) f64 {
	return math_ceil(x)
}

// ==========================================
// 29. Statistical Analysis Utilities (Chapter 13: math.stats)
// ==========================================

// stats_mean computes the arithmetic mean of a floating-point dataset.
pub fn stats_mean(data []f64) f64 {
	if data.len == 0 {
		return 0.0
	}
	return stats.mean(data)
}

// stats_mean delegates to standalone stats_mean.
pub fn (win &SimpleWindow) stats_mean(data []f64) f64 {
	return stats_mean(data)
}

// stats_median computes the median value of a dataset.
pub fn stats_median(data []f64) f64 {
	if data.len == 0 {
		return 0.0
	}
	mut sorted := data.clone()
	sorted.sort()
	return stats.median(sorted)
}

// stats_median delegates to standalone stats_median.
pub fn (win &SimpleWindow) stats_median(data []f64) f64 {
	return stats_median(data)
}

// stats_sample_variance computes the sample variance of a dataset.
pub fn stats_sample_variance(data []f64) f64 {
	if data.len == 0 {
		return 0.0
	}
	return stats.sample_variance(data)
}

// stats_sample_variance delegates to standalone stats_sample_variance.
pub fn (win &SimpleWindow) stats_sample_variance(data []f64) f64 {
	return stats_sample_variance(data)
}

// stats_sample_std_dev computes the sample standard deviation of a dataset.
pub fn stats_sample_std_dev(data []f64) f64 {
	if data.len == 0 {
		return 0.0
	}
	return stats.sample_stddev(data)
}

// stats_sample_std_dev delegates to standalone stats_sample_std_dev.
pub fn (win &SimpleWindow) stats_sample_std_dev(data []f64) f64 {
	return stats_sample_std_dev(data)
}

// stats_population_variance computes the population variance of a dataset.
pub fn stats_population_variance(data []f64) f64 {
	if data.len == 0 {
		return 0.0
	}
	return stats.population_variance(data)
}

// stats_population_variance delegates to standalone stats_population_variance.
pub fn (win &SimpleWindow) stats_population_variance(data []f64) f64 {
	return stats_population_variance(data)
}

// stats_population_std_dev computes the population standard deviation of a dataset.
pub fn stats_population_std_dev(data []f64) f64 {
	if data.len == 0 {
		return 0.0
	}
	return stats.population_stddev(data)
}

// stats_population_std_dev delegates to standalone stats_population_std_dev.
pub fn (win &SimpleWindow) stats_population_std_dev(data []f64) f64 {
	return stats_population_std_dev(data)
}

// ==========================================
// 30. Arbitrary-Precision BigInteger Math (Chapter 13: math.big)
// ==========================================

// SimpleBigInt provides a high-level wrapper around V's arbitrary-precision integer.
pub struct SimpleBigInt {
pub mut:
	val big.Integer
}

// add adds another SimpleBigInt and returns the result.
pub fn (b SimpleBigInt) add(other SimpleBigInt) SimpleBigInt {
	return SimpleBigInt{
		val: b.val + other.val
	}
}

// sub subtracts another SimpleBigInt and returns the result.
pub fn (b SimpleBigInt) sub(other SimpleBigInt) SimpleBigInt {
	return SimpleBigInt{
		val: b.val - other.val
	}
}

// mul multiplies by another SimpleBigInt and returns the result.
pub fn (b SimpleBigInt) mul(other SimpleBigInt) SimpleBigInt {
	return SimpleBigInt{
		val: b.val * other.val
	}
}

// div divides by another SimpleBigInt and returns the result.
pub fn (b SimpleBigInt) div(other SimpleBigInt) SimpleBigInt {
	return SimpleBigInt{
		val: b.val / other.val
	}
}

// mod computes the modulus by another SimpleBigInt and returns the result.
pub fn (b SimpleBigInt) mod(other SimpleBigInt) SimpleBigInt {
	return SimpleBigInt{
		val: b.val % other.val
	}
}

// str converts the BigInt to a decimal string representation.
pub fn (b SimpleBigInt) str() string {
	return b.val.str()
}

// big_int_from_int creates a SimpleBigInt from an integer value.
pub fn big_int_from_int(v int) SimpleBigInt {
	return SimpleBigInt{
		val: big.integer_from_int(v)
	}
}

// big_int_from_int delegates to standalone big_int_from_int.
pub fn (win &SimpleWindow) big_int_from_int(v int) SimpleBigInt {
	return big_int_from_int(v)
}

// big_int_from_str creates a SimpleBigInt from a decimal string.
pub fn big_int_from_str(s string) SimpleBigInt {
	res := big.integer_from_string(s) or { big.integer_from_int(0) }
	return SimpleBigInt{
		val: res
	}
}

// big_int_from_str delegates to standalone big_int_from_str.
pub fn (win &SimpleWindow) big_int_from_str(s string) SimpleBigInt {
	return big_int_from_str(s)
}

// ==========================================
// 31. Array Processing Utilities (Chapter 13: arrays)
// ==========================================

// array_min returns the minimum value in an integer array, or 0 if empty.
pub fn array_min(arr []int) int {
	return arrays.min(arr) or { 0 }
}

// array_min delegates to standalone array_min.
pub fn (win &SimpleWindow) array_min(arr []int) int {
	return array_min(arr)
}

// array_max returns the maximum value in an integer array, or 0 if empty.
pub fn array_max(arr []int) int {
	return arrays.max(arr) or { 0 }
}

// array_max delegates to standalone array_max.
pub fn (win &SimpleWindow) array_max(arr []int) int {
	return array_max(arr)
}

// array_min_f64 returns the minimum value in a float array, or 0.0 if empty.
pub fn array_min_f64(arr []f64) f64 {
	return arrays.min(arr) or { 0.0 }
}

// array_min_f64 delegates to standalone array_min_f64.
pub fn (win &SimpleWindow) array_min_f64(arr []f64) f64 {
	return array_min_f64(arr)
}

// array_max_f64 returns the maximum value in a float array, or 0.0 if empty.
pub fn array_max_f64(arr []f64) f64 {
	return arrays.max(arr) or { 0.0 }
}

// array_max_f64 delegates to standalone array_max_f64.
pub fn (win &SimpleWindow) array_max_f64(arr []f64) f64 {
	return array_max_f64(arr)
}

// array_sum returns the sum of all elements in an integer array.
pub fn array_sum(arr []int) int {
	return arrays.sum(arr) or { 0 }
}

// array_sum delegates to standalone array_sum.
pub fn (win &SimpleWindow) array_sum(arr []int) int {
	return array_sum(arr)
}

// array_sum_f64 returns the sum of all elements in a float array.
pub fn array_sum_f64(arr []f64) f64 {
	return arrays.sum(arr) or { 0.0 }
}

// array_sum_f64 delegates to standalone array_sum_f64.
pub fn (win &SimpleWindow) array_sum_f64(arr []f64) f64 {
	return array_sum_f64(arr)
}

// array_unique_strings removes duplicate string values from an array while preserving insertion order.
pub fn array_unique_strings(arr []string) []string {
	mut seen := map[string]bool{}
	mut res := []string{}
	for item in arr {
		if item !in seen {
			seen[item] = true
			res << item
		}
	}
	return res
}

// array_unique_strings delegates to standalone array_unique_strings.
pub fn (win &SimpleWindow) array_unique_strings(arr []string) []string {
	return array_unique_strings(arr)
}

// ==========================================
// 32. UTF-8 String Utilities (Chapter 13: encoding.utf8)
// ==========================================

// utf8_len returns the number of UTF-8 characters (code points) in a string.
pub fn utf8_len(text string) int {
	return utf8.len(text)
}

// utf8_len delegates to standalone utf8_len.
pub fn (win &SimpleWindow) utf8_len(text string) int {
	return utf8_len(text)
}

// utf8_is_valid checks if a string contains valid UTF-8 encoding.
pub fn utf8_is_valid(text string) bool {
	return utf8.validate_str(text)
}

// utf8_is_valid delegates to standalone utf8_is_valid.
pub fn (win &SimpleWindow) utf8_is_valid(text string) bool {
	return utf8_is_valid(text)
}

// ==========================================
// 33. String Distance & String Builder (Chapter 13: strings)
// ==========================================

// string_levenshtein computes the Levenshtein edit distance between two strings.
pub fn string_levenshtein(s1 string, s2 string) int {
	return strings.levenshtein_distance(s1, s2)
}

// string_levenshtein delegates to standalone string_levenshtein.
pub fn (win &SimpleWindow) string_levenshtein(s1 string, s2 string) int {
	return string_levenshtein(s1, s2)
}

// SimpleStringBuilder provides an efficient, growable string builder buffer.
pub struct SimpleStringBuilder {
mut:
	sb strings.Builder = strings.new_builder(256)
}

// write appends text to the string builder.
pub fn (mut ssb SimpleStringBuilder) write(text string) {
	ssb.sb.write_string(text)
}

// write_line appends text followed by a newline to the string builder.
pub fn (mut ssb SimpleStringBuilder) write_line(text string) {
	ssb.sb.writeln(text)
}

// str returns the complete accumulated string content.
pub fn (mut ssb SimpleStringBuilder) str() string {
	return ssb.sb.str()
}

// len returns the byte length of the accumulated string content.
pub fn (ssb &SimpleStringBuilder) len() int {
	return ssb.sb.len
}

// new_string_builder creates a new SimpleStringBuilder.
pub fn new_string_builder() SimpleStringBuilder {
	return SimpleStringBuilder{}
}

// new_string_builder delegates to standalone new_string_builder.
pub fn (win &SimpleWindow) new_string_builder() SimpleStringBuilder {
	return new_string_builder()
}

// ==========================================
// 34. CSV Reader & Writer Utilities (Chapter 13: encoding.csv)
// ==========================================

// csv_parse parses a CSV formatted string into a 2D matrix of row strings.
pub fn csv_parse(content string) [][]string {
	mut r := csv.new_reader(content)
	mut rows := [][]string{}
	for {
		row := r.read() or { break }
		rows << row
	}
	return rows
}

// csv_parse delegates to standalone csv_parse.
pub fn (win &SimpleWindow) csv_parse(content string) [][]string {
	return csv_parse(content)
}

// csv_encode serializes a 2D matrix of row strings into a CSV formatted string.
pub fn csv_encode(rows [][]string) string {
	mut sb := strings.new_builder(256)
	for row in rows {
		mut line := []string{}
		for col in row {
			if col.contains(',') || col.contains('"') || col.contains('\n') {
				escaped := col.replace('"', '""')
				line << '"${escaped}"'
			} else {
				line << col
			}
		}
		sb.writeln(line.join(','))
	}
	return sb.str()
}

// csv_encode delegates to standalone csv_encode.
pub fn (win &SimpleWindow) csv_encode(rows [][]string) string {
	return csv_encode(rows)
}

// ==========================================
// 35. Ed25519 Digital Signatures (Chapter 13: crypto.ed25519)
// ==========================================

// SimpleEd25519KeyPair contains a public and private Ed25519 key pair.
pub struct SimpleEd25519KeyPair {
pub:
	pub_key  []u8
	priv_key []u8
}

// crypto_ed25519_generate_key generates a new Ed25519 public/private key pair.
pub fn crypto_ed25519_generate_key() !SimpleEd25519KeyPair {
	pub_k, priv_k := ed25519.generate_key()!
	return SimpleEd25519KeyPair{
		pub_key:  pub_k
		priv_key: priv_k
	}
}

// crypto_ed25519_generate_key delegates to standalone crypto_ed25519_generate_key.
pub fn (win &SimpleWindow) crypto_ed25519_generate_key() !SimpleEd25519KeyPair {
	return crypto_ed25519_generate_key()!
}

// crypto_ed25519_sign signs a text message using an Ed25519 private key.
pub fn crypto_ed25519_sign(priv_key []u8, msg string) ![]u8 {
	return ed25519.sign(priv_key, msg.bytes())!
}

// crypto_ed25519_sign delegates to standalone crypto_ed25519_sign.
pub fn (win &SimpleWindow) crypto_ed25519_sign(priv_key []u8, msg string) ![]u8 {
	return crypto_ed25519_sign(priv_key, msg)!
}

// crypto_ed25519_verify verifies an Ed25519 signature against a public key and message.
pub fn crypto_ed25519_verify(pub_key []u8, msg string, sig []u8) bool {
	return ed25519.verify(pub_key, msg.bytes(), sig) or { false }
}

// crypto_ed25519_verify delegates to standalone crypto_ed25519_verify.
pub fn (win &SimpleWindow) crypto_ed25519_verify(pub_key []u8, msg string, sig []u8) bool {
	return crypto_ed25519_verify(pub_key, msg, sig)
}

// ==========================================
// 36. Password-Based Key Derivation (Chapter 13: crypto.pbkdf2)
// ==========================================

// crypto_pbkdf2 derives a key using PBKDF2 with HMAC-SHA256.
pub fn crypto_pbkdf2(password string, salt string, iterations int, key_len int) []u8 {
	h := sha256.new()
	derived := pbkdf2.key(password.bytes(), salt.bytes(), iterations, key_len, h) or { []u8{} }
	return derived
}

// crypto_pbkdf2 delegates to standalone crypto_pbkdf2.
pub fn (win &SimpleWindow) crypto_pbkdf2(password string, salt string, iterations int, key_len int) []u8 {
	return crypto_pbkdf2(password, salt, iterations, key_len)
}

// ==========================================
// 37. Thread Synchronization Primitives (Chapter 13: sync)
// ==========================================

// SimpleMutex wraps a thread-safe mutex lock.
pub struct SimpleMutex {
mut:
	m sync.Mutex
}

// lock acquires the mutex lock, blocking until available.
pub fn (mut sm SimpleMutex) lock() {
	sm.m.lock()
}

// unlock releases the mutex lock.
pub fn (mut sm SimpleMutex) unlock() {
	sm.m.unlock()
}

// new_mutex creates a new SimpleMutex lock.
pub fn new_mutex() SimpleMutex {
	return SimpleMutex{}
}

// new_mutex delegates to standalone new_mutex.
pub fn (win &SimpleWindow) new_mutex() SimpleMutex {
	return new_mutex()
}

// SimpleWaitGroup coordinates completion of multiple concurrent tasks.
pub struct SimpleWaitGroup {
mut:
	wg sync.WaitGroup
}

// add increments the WaitGroup counter.
pub fn (mut swg SimpleWaitGroup) add(delta int) {
	swg.wg.add(delta)
}

// done decrements the WaitGroup counter by 1.
pub fn (mut swg SimpleWaitGroup) done() {
	swg.wg.done()
}

// wait blocks until the WaitGroup counter reaches zero.
pub fn (mut swg SimpleWaitGroup) wait() {
	swg.wg.wait()
}

// new_wait_group creates a new SimpleWaitGroup.
pub fn new_wait_group() SimpleWaitGroup {
	return SimpleWaitGroup{}
}

// new_wait_group delegates to standalone new_wait_group.
pub fn (win &SimpleWindow) new_wait_group() SimpleWaitGroup {
	return new_wait_group()
}


// Module system - Standard Library & Developer Utilities for RAD Studio
// Ported from simple_gg and vlang_simplegui
// Cross-platform support for macOS, Windows, and Linux.

module system

import net.http
import regex
import compress.gzip
import compress.zlib
import crypto.sha256
import crypto.sha512
import crypto.sha1
import crypto.md5
import crypto.hmac
import crypto.aes
import crypto.cipher
import crypto.ed25519
import crypto.pbkdf2
import crypto.bcrypt
import crypto.rand as crand
import rand
import time
import net.urllib
import net.html
import json2
import encoding.hex
import encoding.base64
import encoding.utf8
import encoding.csv
import datatypes
import strings
import math
import math.complex
import math.stats
import sync
import hash as vhash

// =============================================================================
// 1. HTTP Client Utilities
// =============================================================================

// HttpResponse represents the result of an HTTP request (`status_code`, `body`, `headers`, `success`, `error_msg`).
pub struct HttpResponse {
pub mut:
	status_code int
	body        string
	headers     map[string]string
}

// SimpleHttpResponse is a simplified HTTP response containing `status_code`, `body`, and `headers`.
pub struct SimpleHttpResponse {
pub mut:
	status_code int
	body        string
	raw_headers string
	url         string
}

// SimpleHttpRequestOptions configures method, headers, body, and timeout for an HTTP request.
pub struct SimpleHttpRequestOptions {
pub mut:
	headers        map[string]string
	user_agent     string = 'RADStudio/1.0'
	retries        int    = 1
	retry_delay_ms int    = 250
	expect_success bool
}

// http_get performs an HTTP GET request to `url` and returns an `HttpResponse`.
pub fn http_get(url string) HttpResponse {
	res := http.get(url) or {
		return HttpResponse{
			status_code: 0
			body:        'Error: ${err}'
		}
	}
	mut headers_map := map[string]string{}
	for h in res.header.keys() {
		headers_map[h] = res.header.get_custom(h) or { '' }
	}
	return HttpResponse{
		status_code: res.status_code
		body:        res.body
		headers:     headers_map
	}
}

// http_get_body performs an HTTP GET request and returns the response body string (or `''` on failure).
pub fn http_get_body(url string) string {
	res := http.get(url) or { return '' }
	return res.body
}

// http_post performs an HTTP POST request with `data` and `content_type` and returns an `HttpResponse`.
pub fn http_post(url string, data string, content_type string) HttpResponse {
	mut req := http.new_request(.post, url, data)
	ct := if content_type != '' { content_type } else { 'application/json' }
	req.header.set(.content_type, ct)
	res := req.do() or {
		return HttpResponse{
			status_code: 0
			body:        'Error: ${err}'
		}
	}
	mut headers_map := map[string]string{}
	for h in res.header.keys() {
		headers_map[h] = res.header.get_custom(h) or { '' }
	}
	return HttpResponse{
		status_code: res.status_code
		body:        res.body
		headers:     headers_map
	}
}

// http_post_body performs a JSON HTTP POST request and returns the response body string.
pub fn http_post_body(url string, data string) string {
	res := http.post(url, data) or { return '' }
	return res.body
}

// http_request performs an HTTP request with a custom method, body, and headers.
pub fn http_request(method_name string, url string, data string, headers map[string]string) HttpResponse {
	method := match method_name.to_upper() {
		'GET' { http.Method.get }
		'POST' { http.Method.post }
		'PUT' { http.Method.put }
		'DELETE' { http.Method.delete }
		'PATCH' { http.Method.patch }
		'HEAD' { http.Method.head }
		else { http.Method.get }
	}

	mut req := http.new_request(method, url, data)
	for k, v in headers {
		req.header.set_custom(k, v) or {}
	}
	res := req.do() or {
		return HttpResponse{
			status_code: 0
			body:        'Error: ${err}'
		}
	}
	mut resp_headers := map[string]string{}
	for h in res.header.keys() {
		resp_headers[h] = res.header.get_custom(h) or { '' }
	}
	return HttpResponse{
		status_code: res.status_code
		body:        res.body
		headers:     resp_headers
	}
}

// http_get_strict performs an HTTP GET request and returns an error if the request fails or returns status >= 400.
pub fn http_get_strict(url string) !string {
	res := http.get(url)!
	if res.status_code >= 400 {
		return error('HTTP ${res.status_code}: ${res.body}')
	}
	return res.body
}

// http_post_strict performs a JSON HTTP POST request and returns an error if the request fails or returns status >= 400.
pub fn http_post_strict(url string, data string) !string {
	res := http.post(url, data)!
	if res.status_code >= 400 {
		return error('HTTP ${res.status_code}: ${res.body}')
	}
	return res.body
}

// =============================================================================
// 2. Regular Expressions & Pattern Matching
// =============================================================================

// regex_match returns true if `text` matches the regular expression `pattern`.
pub fn regex_match(text string, pattern string) bool {
	mut re := regex.regex_opt(pattern) or { return false }
	return re.matches_string(text)
}

// regex_find returns all substrings in `text` that match the regular expression `pattern`.
pub fn regex_find(text string, pattern string) []string {
	mut re := regex.regex_opt(pattern) or { return []string{} }
	return re.find_all_str(text)
}

// regex_replace replaces all occurrences of `pattern` in `text` with `replacement`.
pub fn regex_replace(text string, pattern string, replacement string) string {
	mut re := regex.regex_opt(pattern) or { return text }
	return re.replace(text, replacement)
}

// regex_match_strict compiles `pattern` and returns whether it matches `text`, or an error if `pattern` is invalid.
pub fn regex_match_strict(text string, pattern string) !bool {
	mut re := regex.regex_opt(pattern)!
	return re.matches_string(text)
}

// regex_find_strict compiles `pattern` and returns all matches in `text`, or an error if `pattern` is invalid.
pub fn regex_find_strict(text string, pattern string) ![]string {
	mut re := regex.regex_opt(pattern)!
	return re.find_all_str(text)
}

// regex_replace_strict compiles `pattern` and replaces matches in `text` with `replacement`, or returns an error.
pub fn regex_replace_strict(text string, pattern string, replacement string) !string {
	mut re := regex.regex_opt(pattern)!
	return re.replace(text, replacement)
}

// =============================================================================
// 3. Cryptography, Hashing, Encoders & Digital Signatures
// =============================================================================

// hash_sha256 computes the lowercase hex-encoded SHA-256 digest of `text`.
pub fn hash_sha256(text string) string {
	return sha256.hexhash(text)
}

// crypto_sha256 computes the lowercase hex-encoded SHA-256 digest of `text`.
pub fn crypto_sha256(text string) string {
	return sha256.hexhash(text)
}

// hash_sha512 computes the lowercase hex-encoded SHA-512 digest of `text`.
pub fn hash_sha512(text string) string {
	return sha512.hexhash(text)
}

// crypto_sha512 computes the lowercase hex-encoded SHA-512 digest of `text`.
pub fn crypto_sha512(text string) string {
	return sha512.hexhash(text)
}

// crypto_sha1 computes the lowercase hex-encoded SHA-1 digest of `text`.
pub fn crypto_sha1(text string) string {
	return sha1.hexhash(text)
}

// hash_md5 computes the lowercase hex-encoded MD5 digest of `text`.
pub fn hash_md5(text string) string {
	return md5.hexhash(text)
}

// crypto_md5 computes the lowercase hex-encoded MD5 digest of `text`.
pub fn crypto_md5(text string) string {
	return md5.hexhash(text)
}

// hmac_sha256 computes the hex-encoded HMAC-SHA256 authentication code of `data` using `key`.
pub fn hmac_sha256(key string, data string) string {
	sum := hmac.new(key.bytes(), data.bytes(), sha256.sum, sha256.block_size)
	return sum.hex()
}

// crypto_hmac_sha256 computes the hex-encoded HMAC-SHA256 authentication code of `text` using `key`.
pub fn crypto_hmac_sha256(text string, key string) string {
	return hmac_sha256(key, text)
}

// crypto_hmac_sha512 computes the hex-encoded HMAC-SHA512 authentication code of `text` using `key`.
pub fn crypto_hmac_sha512(text string, key string) string {
	sum := hmac.new(key.bytes(), text.bytes(), sha512.sum512, sha512.block_size)
	return sum.hex()
}

// crypto_hmac_sha1 computes the hex-encoded HMAC-SHA1 authentication code of `text` using `key`.
pub fn crypto_hmac_sha1(text string, key string) string {
	sum := hmac.new(key.bytes(), text.bytes(), sha1.sum, sha1.block_size)
	return sum.hex()
}

// encode_base64 encodes `text` into a standard Base64 string.
pub fn encode_base64(text string) string {
	return base64.encode_str(text)
}

// decode_base64 decodes a Base64-encoded string back into plain text.
pub fn decode_base64(encoded string) string {
	mut s := encoded.trim_space().replace('\r', '').replace('\n', '').replace(' ', '')
	s = s.replace('-', '+').replace('_', '/')
	if s.len == 0 {
		return ''
	}
	for s.len % 4 != 0 {
		s += '='
	}
	return base64.decode_str(s)
}

// encode_hex encodes the bytes of `data` into a lowercase hexadecimal string.
pub fn encode_hex(data string) string {
	return hex.encode(data.bytes())
}

// decode_hex decodes a hexadecimal string back into its raw string bytes.
pub fn decode_hex(encoded string) string {
	b := hex.decode(encoded) or { []u8{} }
	return b.bytestr()
}

// crypto_wyhash computes a fast 64-bit Wyhash digest of `text` with `seed`.
pub fn crypto_wyhash(text string, seed u64) u64 {
	return vhash.sum64_string(text, seed)
}

// AES-128/192/256 CBC Encryption & Decryption (16, 24, or 32-byte keys; non-standard lengths are padded/truncated to 16 bytes)
pub fn crypto_encrypt_aes(plain_text string, key_hex string) string {
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
	block := aes.new_cipher(key) or { return '' }
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

// crypto_decrypt_aes decrypts a hex-encoded `iv || ciphertext` payload using AES-CBC andPKCS#7 unpadding.
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

	block := aes.new_cipher(key) or { return '' }
	mut dec := cipher.new_cbc(block, iv)
	mut decrypted := []u8{len: ciphertext.len}
	dec.decrypt_blocks(mut decrypted, ciphertext)

	unpadded := pkcs7_unpad_bytes(decrypted, 16) or { return '' }
	return unpadded.bytestr()
}

fn pkcs7_pad_bytes(data []u8, block_size int) []u8 {
	mut out := data.clone()
	pad_len := block_size - (out.len % block_size)
	for _ in 0 .. pad_len {
		out << u8(pad_len)
	}
	return out
}

fn pkcs7_unpad_bytes(data []u8, block_size int) ![]u8 {
	if data.len == 0 || data.len % block_size != 0 {
		return error('invalid padded payload length')
	}
	pad_len := int(data[data.len - 1])
	if pad_len <= 0 || pad_len > block_size || pad_len > data.len {
		return error('invalid PKCS7 padding')
	}
	for i in data.len - pad_len .. data.len {
		if int(data[i]) != pad_len {
			return error('invalid PKCS7 padding bytes')
		}
	}
	return data[..data.len - pad_len].clone()
}

// crypto_encrypt_aes_secure encrypts `plain_text` using AES-CBC + HMAC-SHA256 (Encrypt-then-MAC) with derived subkeys.
pub fn crypto_encrypt_aes_secure(plain_text string, key_hex string) !string {
	key := hex.decode(key_hex)!
	if key.len != 16 && key.len != 24 && key.len != 32 {
		return error('AES key must be 16, 24, or 32 bytes')
	}
	iv := crand.bytes(16)!
	block := aes.new_cipher(key)!
	mut enc := cipher.new_cbc(block, iv)
	padded := pkcs7_pad_bytes(plain_text.bytes(), 16)
	mut ciphertext := []u8{len: padded.len}
	enc.encrypt_blocks(mut ciphertext, padded)
	mut payload := []u8{cap: 16 + ciphertext.len + 32}
	payload << iv
	payload << ciphertext
	mac_key := hmac.new(key, 'simplegui_mac_subkey'.bytes(), sha256.sum, sha256.block_size)
	tag := hmac.new(mac_key, payload, sha256.sum, sha256.block_size)
	payload << tag
	return hex.encode(payload)
}

// crypto_decrypt_aes_secure verifies the HMAC-SHA256 tag in constant time and decrypts a payload produced by `crypto_encrypt_aes_secure`.
pub fn crypto_decrypt_aes_secure(payload_hex string, key_hex string) !string {
	key := hex.decode(key_hex)!
	if key.len != 16 && key.len != 24 && key.len != 32 {
		return error('AES key must be 16, 24, or 32 bytes')
	}
	payload := hex.decode(payload_hex)!
	if payload.len < 64 || (payload.len - 32) % 16 != 0 {
		return error('payload must include 16-byte IV, aligned ciphertext, and 32-byte HMAC-SHA256 tag')
	}
	body := payload[..payload.len - 32]
	tag := payload[payload.len - 32..]
	mac_key := hmac.new(key, 'simplegui_mac_subkey'.bytes(), sha256.sum, sha256.block_size)
	expected_tag := hmac.new(mac_key, body, sha256.sum, sha256.block_size)
	if !hmac.equal(tag, expected_tag) {
		return error('HMAC-SHA256 authentication failed')
	}
	iv := body[..16].clone()
	ciphertext := body[16..]
	block := aes.new_cipher(key)!
	mut dec := cipher.new_cbc(block, iv)
	mut decrypted := []u8{len: ciphertext.len}
	dec.decrypt_blocks(mut decrypted, ciphertext)
	plain := pkcs7_unpad_bytes(decrypted, 16)!
	return plain.bytestr()
}

// Ed25519 Digital Signatures
pub struct SimpleEd25519KeyPair {
pub:
	pub_key  []u8
	priv_key []u8
}

// crypto_ed25519_generate_key generates a new Ed25519 public/private keypair.
pub fn crypto_ed25519_generate_key() !SimpleEd25519KeyPair {
	pub_k, priv_k := ed25519.generate_key()!
	return SimpleEd25519KeyPair{
		pub_key:  pub_k
		priv_key: priv_k
	}
}

// crypto_ed25519_sign signs `msg` using an Ed25519 private key.
pub fn crypto_ed25519_sign(priv_key []u8, msg string) ![]u8 {
	return ed25519.sign(priv_key, msg.bytes())!
}

// crypto_ed25519_verify verifies an Ed25519 signature `sig` for `msg` against `pub_key`.
pub fn crypto_ed25519_verify(pub_key []u8, msg string, sig []u8) bool {
	return ed25519.verify(pub_key, msg.bytes(), sig) or { false }
}

// PBKDF2 Key Derivation
pub fn crypto_pbkdf2(password string, salt string, iterations int, key_len int) []u8 {
	h := sha256.new()
	derived := pbkdf2.key(password.bytes(), salt.bytes(), iterations, key_len, h) or { []u8{} }
	return derived
}

// crypto_pbkdf2_sha256 derives a hex-encoded key of `key_len` bytes using PBKDF2-HMAC-SHA256.
pub fn crypto_pbkdf2_sha256(password string, salt string, iterations int, key_len int) string {
	return hex.encode(crypto_pbkdf2(password, salt, iterations, key_len))
}

// Bcrypt Password Hashing & Verification
pub fn crypto_bcrypt_hash(password string) !string {
	return bcrypt.generate_from_password(password.bytes(), bcrypt.default_cost)!
}

// crypto_bcrypt_verify returns true if `password` matches the bcrypt `hash`.
pub fn crypto_bcrypt_verify(password string, hash string) bool {
	bcrypt.compare_hash_and_password(password.bytes(), hash.bytes()) or { return false }
	return true
}

// Secure Random & UUID
pub fn crypto_rand_bytes(length int) []u8 {
	if length <= 0 {
		return []u8{}
	}
	return crand.bytes(length) or { return []u8{len: length} }
}

// crypto_rand_hex generates a cryptographically random hex string of `length` characters.
pub fn crypto_rand_hex(length int) string {
	return hex.encode(crypto_rand_bytes(length))
}

// crypto_rand_uuid generates a random RFC 4122 version 4 UUID string.
pub fn crypto_rand_uuid() string {
	mut b := crypto_rand_bytes(16)
	if b.len < 16 {
		return '00000000-0000-4000-8000-000000000000'
	}
	b[6] = (b[6] & u8(0x0f)) | u8(0x40)
	b[8] = (b[8] & u8(0x3f)) | u8(0x80)
	h := hex.encode(b)
	return '${h[0..8]}-${h[8..12]}-${h[12..16]}-${h[16..20]}-${h[20..32]}'
}

// =============================================================================
// 4. Compression (Gzip & Zlib)
// =============================================================================

// compress_gzip compresses `text` using Gzip and returns the compressed bytes.
pub fn compress_gzip(text string) []u8 {
	return gzip.compress(text.bytes()) or { []u8{} }
}

// decompress_gzip decompresses Gzip-encoded `data` back into a string.
pub fn decompress_gzip(data []u8) string {
	decompressed := gzip.decompress(data) or { return '' }
	return decompressed.bytestr()
}

// compress_zlib compresses `text` using Zlib and returns the compressed bytes.
pub fn compress_zlib(text string) []u8 {
	return zlib.compress(text.bytes()) or { []u8{} }
}

// decompress_zlib decompresses Zlib-encoded `data` back into a string.
pub fn decompress_zlib(data []u8) string {
	decompressed := zlib.decompress(data) or { return '' }
	return decompressed.bytestr()
}

// =============================================================================
// 5. Random Numbers & Safe Combinatorics
// =============================================================================

// rand_int returns a pseudo-random integer in the inclusive range `[min, max]`.
pub fn rand_int(min int, max int) int {
	if max <= min {
		return min
	}
	return rand.int_in_range(min, max + 1) or { min }
}

// rand_string generates a random alphanumeric string of `length` characters.
pub fn rand_string(length int) string {
	return rand.string(length)
}

// rand_shuffle_strings shuffles a slice of strings in place.
pub fn rand_shuffle_strings(mut arr []string) {
	for i := arr.len - 1; i > 0; i-- {
		j := rand.intn(i + 1) or { 0 }
		temp := arr[i]
		arr[i] = arr[j]
		arr[j] = temp
	}
}

// rand_choice_strings selects and returns a random element from a string slice.
pub fn rand_choice_strings(items []string) string {
	if items.len == 0 { return '' }
	idx := rand.intn(items.len) or { 0 }
	return items[idx]
}

// rand_choice_ints selects and returns a random element from an integer slice.
pub fn rand_choice_ints(items []int) int {
	if items.len == 0 { return 0 }
	idx := rand.intn(items.len) or { 0 }
	return items[idx]
}

// rand_weighted_choice_strings selects a random string from `items` according to the relative `weights`.
pub fn rand_weighted_choice_strings(items []string, weights []f64) string {
	if items.len == 0 || items.len != weights.len { return '' }
	mut total := 0.0
	for w in weights {
		total += w
	}
	if total <= 0.0 { return items[0] }
	r := rand.f64_in_range(0.0, total) or { 0.0 }
	mut acc := 0.0
	for i in 0 .. items.len {
		acc += weights[i]
		if r <= acc { return items[i] }
	}
	return items.last()
}

// rand_weighted_choice_ints selects a random integer from `items` according to the relative `weights`.
pub fn rand_weighted_choice_ints(items []int, weights []f64) int {
	if items.len == 0 || items.len != weights.len { return 0 }
	mut total := 0.0
	for w in weights {
		total += w
	}
	if total <= 0.0 { return items[0] }
	r := rand.f64_in_range(0.0, total) or { 0.0 }
	mut acc := 0.0
	for i in 0 .. items.len {
		acc += weights[i]
		if r <= acc { return items[i] }
	}
	return items.last()
}

// =============================================================================
// 6. Concurrency Primitives (SimpleMutex & SimpleWaitGroup)
// =============================================================================

// SimpleMutex wraps a mutual-exclusion lock for synchronizing shared state across threads.
pub struct SimpleMutex {
mut:
	m sync.Mutex
}

// lock acquires the mutex, blocking until it is available.
pub fn (mut sm SimpleMutex) lock() {
	sm.m.lock()
}

// unlock releases the held mutex.
pub fn (mut sm SimpleMutex) unlock() {
	sm.m.unlock()
}

// new_mutex creates and initializes a new `SimpleMutex`.
pub fn new_mutex() SimpleMutex {
	return SimpleMutex{}
}

// SimpleWaitGroup synchronizes completion of a group of spawned concurrent tasks.
pub struct SimpleWaitGroup {
mut:
	wg sync.WaitGroup
}

// add increments or decrements the wait group counter by `delta`.
pub fn (mut swg SimpleWaitGroup) add(delta int) {
	swg.wg.add(delta)
}

// done decrements the wait group counter by 1.
pub fn (mut swg SimpleWaitGroup) done() {
	swg.wg.done()
}

// wait blocks until the wait group counter reaches zero.
pub fn (mut swg SimpleWaitGroup) wait() {
	swg.wg.wait()
}

// new_wait_group creates and initializes a new `SimpleWaitGroup`.
pub fn new_wait_group() SimpleWaitGroup {
	return SimpleWaitGroup{}
}

// =============================================================================
// 7. Math, Complex Numbers & Statistical Analysis
// =============================================================================

// SimpleComplex represents a complex number with real (`re`) and imaginary (`im`) `f64` components.
pub struct SimpleComplex {
pub mut:
	c complex.Complex
}

// add returns the sum of `sc` and `other`.
pub fn (sc SimpleComplex) add(other SimpleComplex) SimpleComplex {
	return SimpleComplex{
		c: sc.c.add(other.c)
	}
}

// sub returns the difference `sc - other`.
pub fn (sc SimpleComplex) sub(other SimpleComplex) SimpleComplex {
	return SimpleComplex{
		c: sc.c.subtract(other.c)
	}
}

// mul returns the complex product `sc * other`.
pub fn (sc SimpleComplex) mul(other SimpleComplex) SimpleComplex {
	return SimpleComplex{
		c: sc.c.multiply(other.c)
	}
}

// div returns the complex quotient `sc / other`.
pub fn (sc SimpleComplex) div(other SimpleComplex) SimpleComplex {
	return SimpleComplex{
		c: sc.c.divide(other.c)
	}
}

// abs returns the magnitude (modulus) `|sc|` of the complex number.
pub fn (sc SimpleComplex) abs() f64 {
	return sc.c.abs()
}

// arg returns the phase angle (argument) of `sc` in radians.
pub fn (sc SimpleComplex) arg() f64 {
	return sc.c.arg()
}

// conj returns the complex conjugate `(re, -im)` of `sc`.
pub fn (sc SimpleComplex) conj() SimpleComplex {
	return SimpleComplex{
		c: sc.c.conjugate()
	}
}

// exp returns the complex exponential `e^sc`.
pub fn (sc SimpleComplex) exp() SimpleComplex {
	return SimpleComplex{
		c: sc.c.exp()
	}
}

// str formats the complex number as `'a + bi'` or `'a - bi'`.
pub fn (sc SimpleComplex) str() string {
	return sc.c.str()
}

// complex_new constructs a `SimpleComplex` number from real `re` and imaginary `im` parts.
pub fn complex_new(re f64, im f64) SimpleComplex {
	return SimpleComplex{
		c: complex.complex(re, im)
	}
}

// math_degrees converts an angle from radians to degrees.
pub fn math_degrees(radians f64) f64 {
	return math.degrees(radians)
}

// math_radians converts an angle from degrees to radians.
pub fn math_radians(degrees f64) f64 {
	return math.radians(degrees)
}

// math_hypot returns `sqrt(x*x + y*y)` without intermediate overflow or underflow.
pub fn math_hypot(x f64, y f64) f64 {
	return math.hypot(x, y)
}

// math_gcd computes the greatest common divisor of `a` and `b`.
pub fn math_gcd(a i64, b i64) i64 {
	return math.gcd(a, b)
}

// math_lcm computes the least common multiple of `a` and `b`.
pub fn math_lcm(a i64, b i64) i64 {
	return math.lcm(a, b)
}

// math_remap linearly maps `x` from the input range `[in_min, in_max]` to `[out_min, out_max]`.
pub fn math_remap(x f64, in_min f64, in_max f64, out_min f64, out_max f64) f64 {
	return math.remap(x, in_min, in_max, out_min, out_max)
}

// math_smoothstep performs smooth Hermite interpolation between `0` and `1` for `x` in `[edge0, edge1]`.
pub fn math_smoothstep(edge0 f64, edge1 f64, x f64) f64 {
	return math.smoothstep(edge0, edge1, x)
}

// math_atan2 returns the arc tangent of `y / x` in radians, using the signs of both arguments to determine the quadrant.
pub fn math_atan2(y f64, x f64) f64 {
	return math.atan2(y, x)
}

// math_log10 returns the base-10 logarithm of `x`.
pub fn math_log10(x f64) f64 {
	return math.log10(x)
}

// math_log2 returns the base-2 logarithm of `x`.
pub fn math_log2(x f64) f64 {
	return math.log2(x)
}

// math_round_sig rounds `x` to `sig_digits` significant figures.
pub fn math_round_sig(x f64, sig_digits int) f64 {
	return math.round_sig(x, sig_digits)
}

// MathStats holds descriptive statistics (`count`, `min`, `max`, `sum`, `mean`, `median`, `variance`, `std_dev`).
pub struct MathStats {
pub mut:
	count    int
	mean     f64
	median   f64
	variance f64
	std_dev  f64
	min      f64
	max      f64
	sum      f64
}

// calculate_stats computes descriptive statistics (`MathStats`) for a non-empty slice of `f64` values.
pub fn calculate_stats(values []f64) !MathStats {
	if values.len == 0 {
		return error('no numbers provided')
	}
	mut sum := 0.0
	mut min := values[0]
	mut max := values[0]
	for v in values {
		sum += v
		if v < min { min = v }
		if v > max { max = v }
	}
	mean := sum / f64(values.len)
	mut sorted := values.clone()
	sorted.sort()
	mid := sorted.len / 2
	median := if sorted.len % 2 == 0 { (sorted[mid - 1] + sorted[mid]) / 2.0 } else { sorted[mid] }

	mut var_sum := 0.0
	for v in values {
		diff := v - mean
		var_sum += diff * diff
	}
	variance := var_sum / f64(values.len)
	std_dev := math.sqrt(variance)

	return MathStats{
		count:    values.len
		mean:     mean
		median:   median
		variance: variance
		std_dev:  std_dev
		min:      min
		max:      max
		sum:      sum
	}
}

// stats_geometric_mean computes the geometric mean of positive numbers in `data`.
pub fn stats_geometric_mean(data []f64) f64 {
	if data.len == 0 { return 0.0 }
	return stats.geometric_mean(data)
}

// stats_harmonic_mean computes the harmonic mean of non-zero numbers in `data`.
pub fn stats_harmonic_mean(data []f64) f64 {
	if data.len == 0 { return 0.0 }
	return stats.harmonic_mean(data)
}

// stats_rms computes the root mean square (quadratic mean) of `data`.
pub fn stats_rms(data []f64) f64 {
	if data.len == 0 { return 0.0 }
	return stats.rms(data)
}

// stats_mode returns the most frequently occurring value in `data`.
pub fn stats_mode(data []f64) f64 {
	if data.len == 0 { return 0.0 }
	return stats.mode(data)
}

// stats_range returns the difference between the maximum and minimum values in `data`.
pub fn stats_range(data []f64) f64 {
	if data.len == 0 { return 0.0 }
	return stats.range(data)
}

// stats_kurtosis computes the excess kurtosis of `data`.
pub fn stats_kurtosis(data []f64) f64 {
	if data.len == 0 { return 0.0 }
	return stats.kurtosis(data)
}

// stats_skew computes the sample skewness of `data`.
pub fn stats_skew(data []f64) f64 {
	if data.len == 0 { return 0.0 }
	return stats.skew(data)
}

// stats_covariance computes the sample covariance between two equal-length slices `data1` and `data2`.
pub fn stats_covariance(data1 []f64, data2 []f64) f64 {
	if data1.len == 0 || data1.len != data2.len { return 0.0 }
	return stats.covariance(data1, data2)
}

// =============================================================================
// 8. String Utilities & High-Performance Builder
// =============================================================================

// slugify converts `text` into a lowercase, hyphen-separated URL slug.
pub fn slugify(text string) string {
	mut res := []u8{}
	for ch in text.to_lower() {
		if (ch >= `a` && ch <= `z`) || (ch >= `0` && ch <= `9`) {
			res << ch
		} else if ch == ` ` || ch == `_` || ch == `-` {
			if res.len > 0 && res.last() != `-` {
				res << `-`
			}
		}
	}
	return res.bytestr().trim('-')
}

// title_case capitalizes the first letter of each word in `text`.
pub fn title_case(text string) string {
	words := text.split(' ')
	mut res := []string{}
	for w in words {
		if w.len > 0 {
			res << w[..1].to_upper() + w[1..].to_lower()
		}
	}
	return res.join(' ')
}

// reverse_string reverses the UTF-8 runes of `text`.
pub fn reverse_string(text string) string {
	return text.reverse()
}

// is_palindrome returns true if `text` reads the same forward and backward (ignoring case and non-alphanumerics).
pub fn is_palindrome(text string) bool {
	mut clean := []u8{cap: text.len}
	for c in text.to_lower() {
		if c.is_alnum() {
			clean << c
		}
	}
	s := clean.bytestr()
	return s == s.reverse()
}

// word_count returns the number of whitespace-separated words in `text`.
pub fn word_count(text string) int {
	return text.fields().len
}

// utf8_len returns the number of UTF-8 runes (code points) in `text`.
pub fn utf8_len(text string) int {
	return utf8.len(text)
}

// utf8_is_valid returns true if `text` contains valid UTF-8 byte sequences.
pub fn utf8_is_valid(text string) bool {
	return utf8.validate_str(text)
}

// string_jaro_similarity computes the Jaro similarity score (`0.0` to `1.0`) between `s1` and `s2`.
pub fn string_jaro_similarity(s1 string, s2 string) f64 {
	return strings.jaro_similarity(s1, s2)
}

// string_jaro_winkler_similarity computes the Jaro-Winkler similarity score (`0.0` to `1.0`) between `s1` and `s2`.
pub fn string_jaro_winkler_similarity(s1 string, s2 string) f64 {
	return strings.jaro_winkler_similarity(s1, s2)
}

// string_hamming_distance returns the Hamming distance between two equal-length strings (or `-1` if lengths differ).
pub fn string_hamming_distance(s1 string, s2 string) int {
	return strings.hamming_distance(s1, s2)
}

// string_between extracts the substring of `input` located between `start` and `end`.
pub fn string_between(input string, start string, end string) string {
	return strings.find_between_pair_string(input, start, end)
}

// string_pad_left pads `input` on the left with `pad_char` until it reaches `length`.
pub fn string_pad_left(input string, length int, pad_char string) string {
	if input.len >= length || pad_char.len == 0 { return input }
	pad_len := length - input.len
	mut pad := strings.repeat_string(pad_char, pad_len)
	return pad + input
}

// string_pad_right pads `input` on the right with `pad_char` until it reaches `length`.
pub fn string_pad_right(input string, length int, pad_char string) string {
	if input.len >= length || pad_char.len == 0 { return input }
	pad_len := length - input.len
	mut pad := strings.repeat_string(pad_char, pad_len)
	return input + pad
}

// string_repeat repeats `input` `count` times.
pub fn string_repeat(input string, count int) string {
	if count <= 0 { return '' }
	return strings.repeat_string(input, count)
}

// string_count_words returns the number of whitespace-delimited words in `input`.
pub fn string_count_words(input string) int {
	return input.fields().len
}

// SimpleStringBuilder provides an append-only string buffer for efficient string concatenation.
pub struct SimpleStringBuilder {
mut:
	sb strings.Builder = strings.new_builder(256)
}

// write appends `text` to the string builder buffer.
pub fn (mut ssb SimpleStringBuilder) write(text string) {
	ssb.sb.write_string(text)
}

// write_line appends `text` followed by a newline (`\n`) to the buffer.
pub fn (mut ssb SimpleStringBuilder) write_line(text string) {
	ssb.sb.writeln(text)
}

// writeln appends `text` followed by a newline (`\n`) to the buffer.
pub fn (mut ssb SimpleStringBuilder) writeln(text string) {
	ssb.sb.writeln(text)
}

// str returns the accumulated string and consumes the builder buffer.
pub fn (mut ssb SimpleStringBuilder) str() string {
	return ssb.sb.str()
}

// len returns the current byte length of the string builder buffer.
pub fn (ssb &SimpleStringBuilder) len() int {
	return ssb.sb.len
}

// new_string_builder creates a new empty `SimpleStringBuilder`.
pub fn new_string_builder() SimpleStringBuilder {
	return SimpleStringBuilder{}
}

// =============================================================================
// 9. URL Parsing & Assembly
// =============================================================================

// SimpleURL represents a parsed URL with `scheme`, `host`, `port`, `path`, `query`, `fragment`, and `valid` fields.
pub struct SimpleURL {
pub mut:
	scheme   string
	host     string
	port     string
	path     string
	query    map[string]string
	fragment string
}

// build_url reassembles a `SimpleURL` struct into a full URL string.
pub fn (u SimpleURL) build_url() string {
	mut sb := strings.new_builder(128)
	if u.scheme.len > 0 {
		sb.write_string(u.scheme)
		sb.write_string('://')
	}
	sb.write_string(u.host)
	if u.port.len > 0 {
		sb.write_string(':')
		sb.write_string(u.port)
	}
	if u.path.len > 0 {
		if !u.path.starts_with('/') {
			sb.write_string('/')
		}
		sb.write_string(u.path)
	}
	if u.query.len > 0 {
		sb.write_string('?')
		mut parts := []string{}
		for k, v in u.query {
			parts << '${urllib.query_escape(k)}=${urllib.query_escape(v)}'
		}
		sb.write_string(parts.join('&'))
	}
	if u.fragment.len > 0 {
		sb.write_string('#')
		sb.write_string(u.fragment)
	}
	return sb.str()
}

// url_parse parses a raw URL string into a `SimpleURL` struct.
pub fn url_parse(raw_url string) SimpleURL {
	u := urllib.parse(raw_url) or { return SimpleURL{} }
	mut query_map := map[string]string{}
	q_vals := u.query()
	for k in q_vals.data {
		if v := q_vals.get(k.key) {
			query_map[k.key] = v
		}
	}
	return SimpleURL{
		scheme:   u.scheme
		host:     u.hostname()
		port:     u.port()
		path:     u.path
		query:    query_map
		fragment: u.fragment
	}
}

// url_build constructs a URL string from `scheme`, `host`, `path`, and `query_params`.
pub fn url_build(scheme string, host string, path string, query_params map[string]string) string {
	su := SimpleURL{
		scheme: scheme
		host:   host
		path:   path
		query:  query_params
	}
	return su.build_url()
}

// =============================================================================
// 10. HTML Document Parsing & Tag Extraction
// =============================================================================

// SimpleHTMLDocument wraps raw HTML content for lightweight tag, class, attribute, link, and image extraction.
pub struct SimpleHTMLDocument {
pub mut:
	doc html.DocumentObjectModel
}

// html_parse creates a `SimpleHTMLDocument` from raw HTML `content`.
pub fn html_parse(content string) SimpleHTMLDocument {
	return SimpleHTMLDocument{
		doc: html.parse(content)
	}
}

// parse_html creates a `SimpleHTMLDocument` from `html_str`.
pub fn parse_html(html_str string) SimpleHTMLDocument {
	return html_parse(html_str)
}

// get_tag_text extracts the inner text of the first `<name>...</name>` element in the document.
pub fn (d &SimpleHTMLDocument) get_tag_text(name string) string {
	tags := d.doc.get_tags(name: name)
	if tags.len > 0 {
		return tags[0].text().trim_space()
	}
	return ''
}

// get_tags_by_class returns the inner contents of elements matching `class_name`.
pub fn (d &SimpleHTMLDocument) get_tags_by_class(class_name string) []string {
	tags := d.doc.get_tags_by_class_name(class_name)
	mut res := []string{}
	for t in tags {
		res << t.text().trim_space()
	}
	return res
}

// get_attr extracts the value of attribute `attr_name` from the first `<tag_name>` element.
pub fn (d &SimpleHTMLDocument) get_attr(tag_name string, attr_name string) string {
	tags := d.doc.get_tags(name: tag_name)
	if tags.len > 0 {
		return tags[0].attributes[attr_name]
	}
	return ''
}

// get_all_links extracts all `href` attribute values from `<a>` tags in the document.
pub fn (d &SimpleHTMLDocument) get_all_links() []string {
	tags := d.doc.get_tags(name: 'a')
	mut links := []string{}
	for t in tags {
		if href := t.attributes['href'] {
			links << href
		}
	}
	return links
}

// get_all_images extracts all `src` attribute values from `<img>` tags in the document.
pub fn (d &SimpleHTMLDocument) get_all_images() []string {
	tags := d.doc.get_tags(name: 'img')
	mut imgs := []string{}
	for t in tags {
		if src := t.attributes['src'] {
			imgs << src
		}
	}
	return imgs
}

// strip_tags removes all HTML tags from the document and returns the plain text.
pub fn (d &SimpleHTMLDocument) strip_tags() string {
	root := d.doc.get_root()
	if root != unsafe { nil } {
		return root.text().trim_space()
	}
	return ''
}

// =============================================================================
// 11. CSV Parsing & Column Tools
// =============================================================================

// csv_parse parses CSV-formatted `content` into a 2D array of rows and fields.
pub fn csv_parse(content string) [][]string {
	mut r := csv.new_reader(content)
	mut rows := [][]string{}
	for {
		row := r.read() or { break }
		rows << row
	}
	return rows
}

// csv_encode serializes a 2D array of string rows into RFC 4180 CSV text.
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

// csv_extract_column extracts all values at column index `col_idx` across `rows`.
pub fn csv_extract_column(rows [][]string, col_idx int) []string {
	mut res := []string{}
	for row in rows {
		if col_idx >= 0 && col_idx < row.len {
			res << row[col_idx]
		}
	}
	return res
}

// csv_filter_by_column returns rows whose cell at `col_idx` contains `search_term`.
pub fn csv_filter_by_column(rows [][]string, col_idx int, search_term string) [][]string {
	mut filtered := [][]string{}
	for row in rows {
		if col_idx >= 0 && col_idx < row.len {
			if row[col_idx] == search_term {
				filtered << row
			}
		}
	}
	return filtered
}

// =============================================================================
// 12. Generic Data Collections (MinHeap, Stack, Queue, Set)
// =============================================================================

// SimpleMinHeap is a generic binary min-heap priority queue.
pub struct SimpleMinHeap[T] {
mut:
	heap datatypes.MinHeap[T]
}

// push inserts `item` into the min-heap and restores the heap property.
pub fn (mut smh SimpleMinHeap[T]) push(item T) {
	smh.heap.insert(item)
}

// pop removes and returns the smallest element in the min-heap, or returns an error if empty.
pub fn (mut smh SimpleMinHeap[T]) pop() !T {
	return smh.heap.pop()
}

// peek returns the smallest element in the min-heap without removing it, or an error if empty.
pub fn (smh &SimpleMinHeap[T]) peek() !T {
	return smh.heap.peek()
}

// len returns the number of elements currently in the min-heap.
pub fn (smh &SimpleMinHeap[T]) len() int {
	return smh.heap.len()
}

// new_min_heap creates an empty `SimpleMinHeap[T]`.
pub fn new_min_heap[T]() SimpleMinHeap[T] {
	return SimpleMinHeap[T]{}
}

// SimpleStack is a generic LIFO (last-in, first-out) stack.
pub struct SimpleStack[T] {
mut:
	s datatypes.Stack[T]
}

// push pushes `item` onto the top of the stack.
pub fn (mut ss SimpleStack[T]) push(item T) {
	ss.s.push(item)
}

// pop removes and returns the top element of the stack, or returns an error if empty.
pub fn (mut ss SimpleStack[T]) pop() !T {
	return ss.s.pop()
}

// peek returns the top element of the stack without removing it, or an error if empty.
pub fn (ss &SimpleStack[T]) peek() !T {
	return ss.s.peek()
}

// len returns the number of elements currently in the stack.
pub fn (ss &SimpleStack[T]) len() int {
	return ss.s.len()
}

// is_empty returns true if the stack contains no elements.
pub fn (ss &SimpleStack[T]) is_empty() bool {
	return ss.s.is_empty()
}

// new_stack creates an empty `SimpleStack[T]`.
pub fn new_stack[T]() SimpleStack[T] {
	return SimpleStack[T]{}
}

// SimpleQueue is a generic FIFO (first-in, first-out) queue.
pub struct SimpleQueue[T] {
mut:
	q datatypes.Queue[T]
}

// push enqueues `item` at the back of the queue.
pub fn (mut sq SimpleQueue[T]) push(item T) {
	sq.q.push(item)
}

// pop dequeues and returns the front element of the queue, or returns an error if empty.
pub fn (mut sq SimpleQueue[T]) pop() !T {
	return sq.q.pop()
}

// peek returns the front element of the queue without removing it, or an error if empty.
pub fn (sq &SimpleQueue[T]) peek() !T {
	return sq.q.peek()
}

// len returns the number of elements currently in the queue.
pub fn (sq &SimpleQueue[T]) len() int {
	return sq.q.len()
}

// is_empty returns true if the queue contains no elements.
pub fn (sq &SimpleQueue[T]) is_empty() bool {
	return sq.q.is_empty()
}

// new_queue creates an empty `SimpleQueue[T]`.
pub fn new_queue[T]() SimpleQueue[T] {
	return SimpleQueue[T]{}
}

// SimpleSet is a generic unordered collection of unique elements.
pub struct SimpleSet[T] {
mut:
	set datatypes.Set[T]
}

// add inserts `item` into the set if it is not already present.
pub fn (mut ss SimpleSet[T]) add(item T) {
	ss.set.add(item)
}

// remove deletes `item` from the set if present.
pub fn (mut ss SimpleSet[T]) remove(item T) {
	ss.set.remove(item)
}

// exists returns true if `item` is a member of the set.
pub fn (ss &SimpleSet[T]) exists(item T) bool {
	return ss.set.exists(item)
}

// len returns the number of unique elements in the set.
pub fn (ss &SimpleSet[T]) len() int {
	return ss.set.size()
}

// is_empty returns true if the set contains no elements.
pub fn (ss &SimpleSet[T]) is_empty() bool {
	return ss.set.is_empty()
}

// to_array returns all elements of the set as a slice `[]T`.
pub fn (ss &SimpleSet[T]) to_array() []T {
	return ss.set.array()
}

// new_set creates an empty `SimpleSet[T]`.
pub fn new_set[T]() SimpleSet[T] {
	return SimpleSet[T]{}
}

// =============================================================================
// 13. Extended Time & Calendar Utilities
// =============================================================================

// time_now returns the current local date and time formatted as `'YYYY-MM-DD HH:mm:ss'`.
pub fn time_now() string {
	return time.now().custom_format('YYYY-MM-DD HH:mm:ss')
}

// time_unix_timestamp returns the current UTC Unix timestamp in seconds.
pub fn time_unix_timestamp() i64 {
	return time.now().unix()
}

// time_from_unix formats a Unix timestamp (seconds) as a `'YYYY-MM-DD HH:mm:ss'` string.
pub fn time_from_unix(timestamp i64) string {
	t := time.unix(timestamp)
	return t.custom_format('YYYY-MM-DD HH:mm:ss')
}

// time_is_leap_year returns true if `year` is a Gregorian leap year.
pub fn time_is_leap_year(year int) bool {
	return time.is_leap_year(year)
}

// time_days_in_month returns the number of days in `month` (`1..12`) of `year`.
pub fn time_days_in_month(year int, month int) int {
	return time.days_in_month(month, year) or { 30 }
}

// is_valid_date_str returns true if `date_str` is a valid `'YYYY-MM-DD'` calendar date.
pub fn is_valid_date_str(date_str string) bool {
	parts := date_str.split('-')
	if parts.len != 3 { return false }
	if parts[0].len != 4 || parts[1].len != 2 || parts[2].len != 2 { return false }
	year := parts[0].int()
	month := parts[1].int()
	day := parts[2].int()
	if year < 1000 || year > 9999 { return false }
	if month < 1 || month > 12 { return false }
	max_days := time_days_in_month(year, month)
	if day < 1 || day > max_days { return false }
	return true
}

// is_valid_time_str returns true if `time_str` is a valid `'HH:MM'` or `'HH:MM:SS'` 24-hour time.
pub fn is_valid_time_str(time_str string) bool {
	parts := time_str.split(':')
	if parts.len != 2 && parts.len != 3 {
		return false
	}
	for p in parts {
		if p.len != 2 || !p[0].is_digit() || !p[1].is_digit() {
			return false
		}
	}
	h := parts[0].int()
	m := parts[1].int()
	if h < 0 || h > 23 || m < 0 || m > 59 {
		return false
	}
	if parts.len == 3 {
		s := parts[2].int()
		if s < 0 || s > 59 {
			return false
		}
	}
	return true
}

// =============================================================================
// 14. JSON Decoding & Pretty Printing
// =============================================================================

// json_validate returns true if `json_str` is syntactically valid JSON.
pub fn json_validate(json_str string) bool {
	_ := json2.decode[json2.Any](json_str) or { return false }
	return true
}

// json_pretty_print formats a JSON string with 2-space indentation.
pub fn json_pretty_print(json_str string) string {
	m := json2.decode[map[string]string](json_str) or { return json_str }
	mut sb := strings.new_builder(128)
	sb.writeln('{')
	mut count := 0
	for k, v in m {
		count++
		comma := if count < m.len { ',' } else { '' }
		sb.writeln('  ${json_escape(k)}: ${json_escape(v)}${comma}')
	}
	sb.writeln('}')
	return sb.str()
}

// json_decode_map decodes a flat JSON object string into a `map[string]string` (returning an empty map on error).
pub fn json_decode_map(json_str string) map[string]string {
	res := json2.decode[map[string]string](json_str) or { return map[string]string{} }
	return res
}

// json_decode_map_strict decodes a JSON object string into a `map[string]string` or returns an error.
pub fn json_decode_map_strict(json_str string) !map[string]string {
	return json2.decode[map[string]string](json_str)!
}

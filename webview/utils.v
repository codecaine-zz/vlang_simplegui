module webview

import json2

// ReturnKind indicates whether a bound RPC callback resolved with a `.value` or rejected with an `.error`.
pub enum ReturnKind {
	value = 0
	error = 1
}

fn copy_char(s &char) &char {
	if isnil(s) {
		return &char(c'')
	}
	return unsafe { &char(cstring_to_vstring(s).str) }
}

// @return JSON-encodes `result` and resolves or rejects the JavaScript Promise associated with `e`.
pub fn (e &Event) @return[T](result T, kind ReturnKind) {
	$if result is voidptr {
		C.webview_return(e.instance, e.event_id, int(kind), &char(c''))
	} $else $if result is string {
		encoded := json2.encode[string](result)
		C.webview_return(e.instance, e.event_id, int(kind), &char(encoded.str))
	} $else {
		encoded := json2.encode[T](result)
		C.webview_return(e.instance, e.event_id, int(kind), &char(encoded.str))
	}
}

// return_raw returns a raw JSON value string directly to JavaScript without extra quoting.
pub fn (e &Event) return_raw(raw_json string, kind ReturnKind) {
	payload := if raw_json.len == 0 { 'null' } else { raw_json }
	C.webview_return(e.instance, e.event_id, int(kind), &char(payload.str))
}

// async clones the event's C strings so the Event can be safely used from a spawned background thread.
pub fn (e &Event) async() &Event {
	return &Event{e.instance, copy_char(e.event_id), copy_char(e.args)}
}

// get_raw_args returns the raw JSON array string of arguments passed from JavaScript.
pub fn (e &Event) get_raw_args() string {
	if isnil(e.args) {
		return ''
	}
	return unsafe { e.args.vstring() }
}

// get_any_arg decodes the argument at `idx` (supports negative indexing) into a dynamic `json2.Any` value.
pub fn (e &Event) get_any_arg(idx int) !json2.Any {
	raw := e.get_raw_args()
	if raw.len == 0 {
		return error('no arguments provided')
	}
	parsed := json2.decode[json2.Any](raw) or {
		return error('Failed decoding raw args JSON: ${err}')
	}
	if parsed is []json2.Any {
		i := if idx < 0 { parsed.len + idx } else { idx }
		if i >= 0 && i < parsed.len {
			return parsed[i]
		}
		return error('Argument index ${idx} out of range (length: ${parsed.len})')
	}
	return error('Raw args is not a JSON array')
}

// get_map_arg decodes the argument at `idx` as a JSON object (`map[string]json2.Any`).
pub fn (e &Event) get_map_arg(idx int) !map[string]json2.Any {
	val := e.get_any_arg(idx)!
	if val is map[string]json2.Any {
		return val
	}
	return error('Argument at index ${idx} is not a JSON object')
}

// get_arg decodes the JavaScript argument at `idx` (0-based, or negative from the end) into type `T`.
pub fn (e &Event) get_arg[T](idx int) !T {
	raw := e.get_raw_args()
	if raw.len == 0 {
		return error('no arguments provided')
	}
	if args := json2.decode[[]T](raw) {
		i := if idx < 0 { args.len + idx } else { idx }
		if i >= 0 && i < args.len {
			return args[i]
		}
		return error('Argument index ${idx} out of range (length: ${args.len})')
	}
	any_val := e.get_any_arg(idx)!
	item_json := json2.encode[json2.Any](any_val)
	return json2.decode[T](item_json) or {
		return error('Failed decoding argument of type `${T.name}` at index `${idx}`: ${err}')
	}
}

module main

import simplegui

fn main() {
	mut gui := simplegui.new_simple_window('Deflate Compression Demo', 500, 380)
	gui.set_padding(20)
	gui.set_spacing(10)

	gui.add_label('header', '🗜️ Deflate Compression Demo')
	gui.set_control_font_size('header', 16)
	gui.set_control_font_bold('header', true)

	gui.add_label('lbl_input', 'Text to Compress:')
	gui.add_input('input_text', 'SimpleGUI Deflate byte stream compression and decompression walkthrough!')

	gui.begin_row('buttons_row')
	gui.add_button('btn_compress', 'Compress & Decompress')
	gui.end_row()

	gui.add_textarea('output_text', 'Click Compress to verify Deflate round-trip...')
	gui.set_control_height('output_text', 130)

	gui.on_click('btn_compress', fn (mut win simplegui.SimpleWindow) {
		input := win.get_text('input_text')
		if input.len == 0 {
			win.alert('Input Error', 'Input text cannot be empty.')
			return
		}

		win.set_status('Compressing string data...')
		compressed := win.compress_deflate(input)
		decompressed := win.decompress_deflate(compressed)

		ratio := f64(compressed.len) / f64(input.len) * 100.0

		formatted := 'Deflate Compression Results:
  Original String:    "${input}" (${input.len} bytes)
  Compressed Size:    ${compressed.len} bytes
  Compression Ratio:  ${ratio:.2f}%
  Decompressed Text:  "${decompressed}"
  Verified Lossless:  ${decompressed == input}'

		win.set_text('output_text', formatted)
		win.set_status('Deflate round-trip verification completed.')
	})

	gui.set_theme('dark')
	gui.run()
}

module main

import simplegui

fn main() {
	mut gui := simplegui.new_simple_window('HTML Parser & Lorem Generator Demo', 550,
		520)
	gui.set_padding(20)
	gui.set_spacing(10)

	gui.add_label('header', '📝 HTML Parser & Lorem Generator Demo')
	gui.set_control_font_size('header', 16)
	gui.set_control_font_bold('header', true)

	// 1. Strings Lorem Section
	gui.add_group_box('lorem_group', '✍️ Placeholder Text Generator (strings.lorem)')

	gui.begin_row('row_lorem_1')
	gui.add_label('lbl_corpus', 'Corpus:')
	gui.add_input('input_corpus', 'poe') // default poe, options poe, lorem, darwin, bard
	gui.add_label('lbl_paras', 'Paragraphs:')
	gui.add_input('input_paras', '2')
	gui.end_row()

	gui.begin_row('row_lorem_2')
	gui.add_label('lbl_sentences', 'Sentences:')
	gui.add_input('input_sentences', '3')
	gui.add_label('lbl_words', 'Words/Sentence:')
	gui.add_input('input_words', '6')
	gui.add_button('btn_lorem_gen', 'Generate Text')
	gui.end_row()

	// 2. Net.HTML Parser Section
	gui.add_group_box('html_group', '🌐 DOM HTML Parser (net.html)')

	gui.add_label('lbl_html_input', 'HTML Input string:')
	gui.add_input('input_html_text', '<html><body><h1 class="title">SimpleGUI Rules!</h1><p class="desc">HTML parse demo.</p><p class="desc">Vlang standard library is powerful.</p></body></html>')

	gui.begin_row('row_html_btn')
	gui.add_button('btn_html_parse', 'Parse HTML Title & Classes')
	gui.end_row()

	// Output area
	gui.add_textarea('output_box', 'Output results will be displayed here...')
	gui.set_control_height('output_box', 150)

	// Lorem Generator Click Handler
	gui.on_click('btn_lorem_gen', fn (mut win simplegui.SimpleWindow) {
		corpus := win.get_text('input_corpus').trim_space()
		paras := win.get_text('input_paras').int()
		sentences := win.get_text('input_sentences').int()
		words := win.get_text('input_words').int()

		if corpus != 'lorem' && corpus != 'poe' && corpus != 'darwin' && corpus != 'bard' {
			win.alert('Corpus Error', 'Corpus must be one of: lorem, poe, darwin, bard')
			return
		}

		win.set_status('Generating lorem placeholder text...')
		result := win.lorem_generate(corpus, paras, sentences, words)
		win.set_text('output_box', 'Generated placeholder text using corpus "${corpus}":\n\n' +
			result)
		win.set_status('Lorem text generation complete.')
	})

	// HTML Parser Click Handler
	gui.on_click('btn_html_parse', fn (mut win simplegui.SimpleWindow) {
		html_str := win.get_text('input_html_text')
		if html_str.trim_space().len == 0 {
			win.alert('Input Error', 'HTML input field cannot be empty.')
			return
		}

		win.set_status('Parsing HTML DOM...')
		doc := win.html_parse(html_str)

		title_text := doc.get_tag_text('h1')
		desc_paragraphs := doc.get_tags_by_class('desc')

		mut formatted_desc := ''
		for i, desc in desc_paragraphs {
			formatted_desc += '  Description ${i + 1}: "${desc}"\n'
		}

		formatted := 'Parsed HTML Document DOM successfully!\n' +
			'  Found Title (h1 tag text): "${title_text}"\n' +
			'  Found Paragraphs with class "desc":\n' + formatted_desc

		win.set_text('output_box', formatted)
		win.set_status('HTML parsing completed.')
	})

	gui.set_theme('dark')
	gui.run()
}

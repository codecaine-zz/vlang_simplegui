module main

import simplecli

fn main() {
	mut app := simplecli.new_app('mediastudio-cli', '1.0.0')
	app.set_description('Master Media Hub & Multi-Tool Video/Audio/Image Controller CLI')

	app.add_flag_string('input', 'i', '', 'Input media file')
	app.add_flag_string('action', 'a', '', 'Action: transcode, thumbnail, ocr, audio-extract, tts')
	app.add_flag_bool('interactive', 'x', false, 'Launch interactive Media Studio Hub')

	app.parse_cli() or { return }

	app.banner('Media Studio Hub CLI', 'v1.0.0 - Unified Media & Graphics Workbench')

	if app.get_flag_bool('interactive') {
		run_interactive(mut app)
		return
	}

	input_file := app.get_flag_string('input')
	action := app.get_flag_string('action').to_lower()

	if action.len > 0 {
		if action == 'tts' {
			msg := if input_file.len > 0 { input_file } else { 'Media Studio Hub active.' }
			app.say(msg)
			app.success('Synthesized speech: "${msg}"')
			return
		}

		if input_file.len == 0 {
			app.error('Input media file (-i) is required for action "${action}".')
			return
		}
		if !app.file_exists(input_file) {
			app.error('Input file not found: ${input_file}')
			return
		}

		match action {
			'transcode' {
				out_file := 'transcoded_output.mp4'
				out, code := app.exec_safe('ffmpeg', [
					'-y',
					'-i',
					input_file,
					'-c:v',
					'libx264',
					'-c:a',
					'aac',
					out_file,
				])
				if code == 0 {
					app.success('Transcoded media saved to ${out_file}')
				} else {
					app.error('Transcode failed:\n${out}')
				}
			}
			'audio-extract' {
				out_file := 'extracted_audio.mp3'
				out, code := app.exec_safe('ffmpeg', [
					'-y',
					'-i',
					input_file,
					'-vn',
					'-ab',
					'320k',
					out_file,
				])
				if code == 0 {
					app.success('Extracted audio saved to ${out_file}')
				} else {
					app.error('Audio extraction failed:\n${out}')
				}
			}
			'thumbnail' {
				out_file := 'thumbnail.png'
				magick_cmd := if app.command_exists('magick') { 'magick' } else { 'convert' }
				out, code := app.exec_safe(magick_cmd, [input_file, '-resize', '50%', out_file])
				if code == 0 {
					app.success('Thumbnail saved to ${out_file}')
				} else {
					app.error('Thumbnail generation failed:\n${out}')
				}
			}
			'ocr' {
				out, code := app.exec_safe('tesseract', [input_file, 'stdout'])
				if code == 0 {
					println(out)
				} else {
					app.error('OCR failed:\n${out}')
				}
			}
			else {
				app.error('Unknown action "${action}". Supported: transcode, thumbnail, ocr, audio-extract, tts')
			}
		}
		return
	}

	app.info('Installed media engines:')
	app.print_kv({
		'FFmpeg':        if app.command_exists('ffmpeg') {
			app.green('Available')
		} else {
			app.dim('Missing')
		}
		'ImageMagick':   if app.command_exists('magick') || app.command_exists('convert') {
			app.green('Available')
		} else {
			app.dim('Missing')
		}
		'yt-dlp':        if app.command_exists('yt-dlp') {
			app.green('Available')
		} else {
			app.dim('Missing')
		}
		'Tesseract OCR': if app.command_exists('tesseract') {
			app.green('Available')
		} else {
			app.dim('Missing')
		}
		'Speech (say)':  if app.command_exists('say') {
			app.green('Available')
		} else {
			app.dim('Missing')
		}
	})
	app.println(app.dim('Tip: Run with -x for the interactive master media workstation.'))
}

fn run_interactive(mut app simplecli.SimpleCli) {
	app.panel('Media Studio Operations Hub',
		'Unified launcher for audio, video, graphics, and text processing.')
	choice := app.select('Select Media Subsystem:', [
		'Audio Extraction (FFmpeg)',
		'Image Resizing / Thumbnail (ImageMagick)',
		'Document OCR (Tesseract)',
		'Speech Synthesis (say)',
	])

	match choice {
		'Audio Extraction (FFmpeg)' {
			in_file := app.prompt('Input video file', 'video.mp4')
			out_file := app.prompt('Output MP3 file', 'audio.mp3')
			app.exec_safe('ffmpeg', ['-y', '-i', in_file, '-vn', '-ab', '320k', out_file])
		}
		'Image Resizing / Thumbnail (ImageMagick)' {
			in_img := app.prompt('Input image file', 'photo.png')
			out_img := app.prompt('Output thumbnail file', 'thumb.png')
			app.exec_safe('magick', [in_img, '-resize', '50%', out_img])
		}
		'Document OCR (Tesseract)' {
			in_img := app.prompt('Input document image', 'scan.png')
			out, _ := app.exec_safe('tesseract', [in_img, 'stdout'])
			println(out)
		}
		else {
			msg := app.prompt('Enter message to speak', 'Media Studio Hub active.')
			app.say(msg)
		}
	}
}

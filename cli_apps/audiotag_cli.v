module main

import os
import simplecli

fn main() {
	mut app := simplecli.new_app('audiotag-cli', '1.0.0')
	app.set_description('Audio Tag Inspector & ID3 Metadata Editor CLI')

	app.add_flag_string('input', 'i', '', 'Input audio file path (MP3, FLAC, M4A, OGG)')
	app.add_flag_string('title', 't', '', 'Set song title metadata')
	app.add_flag_string('artist', 'a', '', 'Set artist name metadata')
	app.add_flag_string('album', 'l', '', 'Set album title metadata')
	app.add_flag_string('year', 'y', '', 'Set release year metadata')
	app.add_flag_bool('interactive', 'x', false, 'Launch interactive audio tag editor')

	app.parse_cli() or { return }

	app.banner('Audio Tag Studio CLI', 'v1.0.0 - ID3 & Music Metadata Editor')

	if app.get_flag_bool('interactive') {
		run_interactive(mut app)
		return
	}

	input_path := app.get_flag_string('input')
	if input_path.len == 0 {
		app.warn('No audio file specified. Run with -i <song.mp3> or -x for interactive mode.')
		app.print_help()
		return
	}

	if !app.file_exists(input_path) {
		app.error('File not found: ${input_path}')
		return
	}

	title := app.get_flag_string('title')
	artist := app.get_flag_string('artist')
	album := app.get_flag_string('album')
	year := app.get_flag_string('year')

	if title.len > 0 || artist.len > 0 || album.len > 0 || year.len > 0 {
		ext := os.file_ext(input_path)
		tmp_out := '${input_path}.tagged_tmp${ext}'
		mut ff_args := ['-y', '-i', input_path, '-c', 'copy']
		if title.len > 0 {
			ff_args << ['-metadata', 'title=${title}']
		}
		if artist.len > 0 {
			ff_args << ['-metadata', 'artist=${artist}']
		}
		if album.len > 0 {
			ff_args << ['-metadata', 'album=${album}']
		}
		if year.len > 0 {
			ff_args << ['-metadata', 'date=${year}']
		}
		ff_args << tmp_out
		app.info('Writing updated metadata tags to ${input_path}...')
		ff_out, ff_code := app.exec_safe('ffmpeg', ff_args)
		if ff_code == 0 {
			os.mv(tmp_out, input_path) or {
				os.rm(tmp_out) or {}
				app.error('Failed to replace original file with tagged audio: ${err}')
				return
			}
			app.success('Successfully updated audio metadata tags.')
		} else {
			os.rm(tmp_out) or {}
			app.error('Failed to write metadata tags:\n${ff_out}')
			return
		}
	}

	// Read metadata using ffprobe
	app.info('Inspecting audio tags for ${input_path}...')
	out, _ := app.exec_safe('ffprobe', [
		'-v',
		'error',
		'-show_entries',
		'format_tags',
		'-of',
		'default=noprint_wrappers=1',
		input_path,
	])
	if out.trim_space().len > 0 {
		println(out)
	} else {
		app.warn('No embedded ID3 tags detected in file.')
	}
}

fn run_interactive(mut app simplecli.SimpleCli) {
	app.panel('Audio Tag Wizard', 'View and modify ID3 / FLAC metadata tags.')
	file_path := app.prompt('Enter audio file path', 'song.mp3')
	if !app.file_exists(file_path) {
		app.warn('File does not exist.')
		return
	}
	out, _ := app.exec_safe('ffprobe', [
		'-v',
		'error',
		'-show_entries',
		'format_tags',
		'-of',
		'default=noprint_wrappers=1',
		file_path,
	])
	println(out)
}

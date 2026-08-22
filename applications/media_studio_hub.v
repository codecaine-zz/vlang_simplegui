module main

import os
import simplegui

fn check_bin(name string, fallbacks []string) (bool, string) {
	if path := os.find_abs_path_of_executable(name) {
		return true, path
	}
	for p in fallbacks {
		if os.exists(p) {
			return true, p
		}
	}
	return false, 'Not found'
}

fn main() {
	println('Starting SimpleGUI - Media & Data Studio Hub (Async Non-Blocking Engine)...')

	mut win := simplegui.new_simple_window('🚀 SimpleGUI - Media & Data Studio Hub', 980, 870)
	win.set_spacing(10)
	win.set_padding(18)

	saved_theme := simplegui.get_saved_theme()
	win.set_theme(saved_theme)

	// Top Section
	win.begin_row('row_hub_top')
	win.add_heading('🚀 SimpleGUI Media & Data Studio Hub')
	win.add_label('lbl_theme_select', '🎨 Theme:')
	win.add_dropdown('dd_hub_theme', simplegui.list_themes(), saved_theme)
	win.set_control_width('dd_hub_theme', 160)
	win.end_row()
	win.add_label('lbl_sub', 'Unified macOS Pro Engineering Suite for Media, Data & CLI Utilities')

	// -------------------------------------------------------------
	// System Diagnostics
	// -------------------------------------------------------------
	has_ffmpeg, ffmpeg_path := check_bin('ffmpeg', ['/opt/homebrew/bin/ffmpeg', '/opt/homebrew/opt/ffmpeg-full/bin/ffmpeg', '/usr/local/bin/ffmpeg'])
	has_ffprobe, ffprobe_path := check_bin('ffprobe', ['/opt/homebrew/bin/ffprobe', '/opt/homebrew/opt/ffmpeg-full/bin/ffprobe', '/usr/local/bin/ffprobe'])
	has_magick, magick_path := check_bin('magick', ['/opt/homebrew/bin/magick', '/opt/homebrew/opt/imagemagick-full/bin/magick', '/usr/local/bin/magick', '/opt/homebrew/bin/convert', '/usr/local/bin/convert'])
	_, identify_path := check_bin('identify', ['/opt/homebrew/bin/identify', '/opt/homebrew/opt/imagemagick-full/bin/identify', '/usr/local/bin/identify'])
	has_gawk, gawk_path := check_bin('gawk', ['/opt/homebrew/bin/gawk', '/usr/local/bin/gawk', '/usr/bin/awk', '/bin/awk'])
	has_sd, sd_path := check_bin('sd', ['/opt/homebrew/bin/sd', '/usr/local/bin/sd', '/bin/sd'])
	has_subfinder, subfinder_path := check_bin('subfinder', ['/opt/homebrew/bin/subfinder', '/usr/local/bin/subfinder', '/bin/subfinder'])
	has_ytdlp, ytdlp_path := check_bin('yt-dlp', ['/opt/homebrew/bin/yt-dlp', '/usr/local/bin/yt-dlp', '/bin/yt-dlp'])
	has_wget2, wget2_path := check_bin('wget2', ['/opt/homebrew/bin/wget2', '/usr/local/bin/wget2', '/opt/homebrew/bin/wget', '/usr/local/bin/wget', '/bin/wget'])
	has_pandoc, pandoc_path := check_bin('pandoc', ['/opt/homebrew/bin/pandoc', '/usr/local/bin/pandoc', '/bin/pandoc'])
	has_fd, fd_path := check_bin('fd', ['/opt/homebrew/bin/fd', '/usr/local/bin/fd', '/bin/fd', '/usr/bin/fdfind'])
	has_rg, rg_path := check_bin('rg', ['/opt/homebrew/bin/rg', '/usr/local/bin/rg', '/bin/rg', '/usr/bin/rg'])
	has_cut, cut_path := check_bin('cut', ['/usr/bin/cut', '/bin/cut', '/opt/homebrew/bin/gcut'])
	has_tr, tr_path := check_bin('tr', ['/usr/bin/tr', '/bin/tr', '/opt/homebrew/bin/gtr'])
	has_say, say_path := check_bin('say', ['/usr/bin/say', '/bin/say'])
	has_find, find_path := check_bin('find', ['/usr/bin/find', '/bin/find', '/opt/homebrew/bin/gfind'])
	has_ouch, ouch_path := check_bin('ouch', ['/opt/homebrew/bin/ouch', '/usr/local/bin/ouch', '/usr/bin/ouch'])

	win.begin_group_box('grp_env', '⚡ System Environment Status')
	win.begin_row('row_env_1')
	ffmpeg_status := if has_ffmpeg { '✅ FFmpeg: ' + ffmpeg_path } else { '❌ FFmpeg: Missing' }
	win.add_label('lbl_stat_ffmpeg', ffmpeg_status)
	ffprobe_status := if has_ffprobe { '✅ FFprobe: ' + ffprobe_path } else { '❌ FFprobe: Missing' }
	win.add_label('lbl_stat_ffprobe', ffprobe_status)
	ytdlp_status := if has_ytdlp { '✅ yt-dlp: ' + ytdlp_path } else { '❌ yt-dlp: Missing' }
	win.add_label('lbl_stat_ytdlp', ytdlp_status)
	wget2_status := if has_wget2 { '✅ Wget2: ' + wget2_path } else { '❌ Wget2: Missing' }
	win.add_label('lbl_stat_wget2', wget2_status)
	tr_status := if has_tr { '✅ tr: ' + tr_path } else { '❌ tr: Missing' }
	win.add_label('lbl_stat_tr', tr_status)
	say_status := if has_say { '✅ say: ' + say_path } else { '❌ say: Missing' }
	win.add_label('lbl_stat_say', say_status)
	ouch_status := if has_ouch { '✅ ouch: ' + ouch_path } else { '❌ ouch: Missing' }
	win.add_label('lbl_stat_ouch', ouch_status)
	win.end_row()

	win.begin_row('row_env_2')
	magick_status := if has_magick { '✅ ImageMagick: ' + magick_path } else { '❌ ImageMagick: Missing' }
	win.add_label('lbl_stat_magick', magick_status)
	gawk_status := if has_gawk { '✅ GAWK: ' + gawk_path } else { '❌ GAWK: Missing' }
	win.add_label('lbl_stat_gawk', gawk_status)
	sd_status := if has_sd { '✅ SD: ' + sd_path } else { '❌ SD: Missing' }
	win.add_label('lbl_stat_sd', sd_status)
	subf_status := if has_subfinder { '✅ Subfinder: ' + subfinder_path } else { '❌ Subfinder: Missing' }
	win.add_label('lbl_stat_subf', subf_status)
	pandoc_status := if has_pandoc { '✅ Pandoc: ' + pandoc_path } else { '❌ Pandoc: Missing' }
	win.add_label('lbl_stat_pandoc', pandoc_status)
	fd_status := if has_fd { '✅ FD: ' + fd_path } else { '❌ FD: Missing' }
	win.add_label('lbl_stat_fd', fd_status)
	rg_status := if has_rg { '✅ ripgrep: ' + rg_path } else { '❌ ripgrep: Missing' }
	win.add_label('lbl_stat_rg', rg_status)
	find_status := if has_find { '✅ find: ' + find_path } else { '❌ find: Missing' }
	win.add_label('lbl_stat_find', find_status)
	cut_status := if has_cut { '✅ cut: ' + cut_path } else { '❌ cut: Missing' }
	win.add_label('lbl_stat_cut', cut_status)
	win.end_row()
	win.end_group_box()

	// -------------------------------------------------------------
	// Dedicated Studio Launchers
	// -------------------------------------------------------------
	win.begin_group_box('grp_launchers', '🚀 Dedicated Studio Workstations')
	win.begin_row('row_apps')
	win.add_button('btn_launch_taskman', '⚡ Task Manager')
	win.add_button('btn_launch_ouch', '📦 ouch')
	win.add_button('btn_launch_ffmpeg', '🎬 FFmpeg')
	win.add_button('btn_launch_magick', '🎨 ImageMagick')
	win.add_button('btn_launch_gawk', '⚡ GAWK')
	win.add_button('btn_launch_sd', '🔍 SD')
	win.add_button('btn_launch_say', '🗣️ Say')
	win.add_button('btn_launch_find', '📂 find')
	win.add_button('btn_launch_cut', '✂️ cut')
	win.add_button('btn_launch_tr', '🔄 tr')
	win.add_button('btn_launch_rg', '🔍 ripgrep')
	win.add_button('btn_launch_fd', '⚡ FD')
	win.add_button('btn_launch_subfinder', '🌐 Subfinder')
	win.add_button('btn_launch_ytdlp', '⬇️ yt-dlp')
	win.add_button('btn_launch_wget2', '⚡ Wget2')
	win.add_button('btn_launch_pandoc', '📄 Pandoc')
	win.end_row()
	win.end_group_box()

	// -------------------------------------------------------------
	// Quick Tools Suite
	// -------------------------------------------------------------
	win.begin_group_box('grp_quick', '⚡ Instant Quick Tools (Async Non-Blocking)')
	
	win.begin_row('row_quick_in')
	win.add_label('lbl_quick_file', 'Target File:')
	win.add_input('txt_quick_in', '')
	win.set_control_width('txt_quick_in', 560)
	win.add_button('btn_quick_browse', '📂 Pick File...')
	win.add_button('btn_q_info', '🔍 Inspect')
	win.end_row()

	// Row 1: Video & Audio Quick Tools
	win.begin_row('row_quick_btns_1')
	win.add_button('btn_q_mp4', '🎥 Convert to MP4')
	win.add_button('btn_q_discord', '🎯 Discord Size (<10MB)')
	win.add_button('btn_q_reels', '📱 TikTok / Reels (9:16)')
	win.add_button('btn_q_mp3', '🎵 Extract MP3')
	win.add_button('btn_q_loudnorm', '🎙️ Loudnorm Audio')
	win.end_row()

	// Row 2: Image & Graphic Quick Tools
	win.begin_row('row_quick_btns_2')
	win.add_button('btn_q_webp', '🖼️ Compress to WebP')
	win.add_button('btn_q_ico', '🌟 Make Favicon.ico')
	win.add_button('btn_q_nobg', '🪄 Remove White BG')
	win.add_button('btn_q_gif', '🎞️ Video to HD GIF')
	win.add_button('btn_q_resize', '📐 Resize 50%')
	win.end_row()
	win.end_group_box()

	// -------------------------------------------------------------
	// Activity & Operations Log
	// -------------------------------------------------------------
	win.begin_row('row_log_head')
	win.add_label('lbl_log', 'Activity & Operations Log:')
	win.add_button('btn_open_finder', '📂 Open Containing Folder')
	win.add_button('btn_clear_hub_log', '🧹 Clear')
	win.end_row()

	win.add_console('hub_log', 170)

	win.append_console('hub_log', '🚀 SimpleGUI Media & Data Studio Hub Initialized.\n', 1)
	if has_ffmpeg && has_magick && has_gawk {
		win.append_console('hub_log', '✅ All engineering CLI engines (FFmpeg, ImageMagick, GAWK) are online and ready!\n', 4)
	} else {
		win.append_console('hub_log', '⚠️ Some engines were not found in standard paths. Please verify brew install.\n', 2)
	}

	// -------------------------------------------------------------
	// Events & Logic (All Async Background Dispatched)
	// -------------------------------------------------------------

	// Theme Change
	win.on_change('dd_hub_theme', fn (mut w simplegui.SimpleWindow, selected string) {
		w.set_theme(selected)
		w.toast('Theme changed to ${selected}')
	})

	// Launch FFmpeg Studio
	win.on_click('btn_launch_ffmpeg', fn (mut w simplegui.SimpleWindow) {
		app_path := os.join_path(os.dir(@FILE), 'ffmpeg_studio.v')
		w.append_console('hub_log', '🎬 Launching FFmpeg Studio Pro in background...\n', 1)
		go fn [app_path] () {
			simplegui.exec_safe('v', ['run', app_path])
		}()
		w.toast('FFmpeg Studio Pro launched!')
	})

	// Launch ImageMagick Studio
	win.on_click('btn_launch_magick', fn (mut w simplegui.SimpleWindow) {
		app_path := os.join_path(os.dir(@FILE), 'imagemagick_studio.v')
		w.append_console('hub_log', '🎨 Launching ImageMagick Studio Pro in background...\n', 1)
		go fn [app_path] () {
			simplegui.exec_safe('v', ['run', app_path])
		}()
		w.toast('ImageMagick Studio Pro launched!')
	})

	// Launch GAWK Studio
	win.on_click('btn_launch_gawk', fn (mut w simplegui.SimpleWindow) {
		app_path := os.join_path(os.dir(@FILE), 'gawk_studio.v')
		w.append_console('hub_log', '⚡ Launching GAWK Studio Pro in background...\n', 1)
		go fn [app_path] () {
			simplegui.exec_safe('v', ['run', app_path])
		}()
		w.toast('GAWK Studio Pro launched!')
	})

	// Launch SD Studio
	win.on_click('btn_launch_sd', fn (mut w simplegui.SimpleWindow) {
		app_path := os.join_path(os.dir(@FILE), 'sd_studio.v')
		w.append_console('hub_log', '🔍 Launching SD Studio Pro in background...\n', 1)
		go fn [app_path] () {
			simplegui.exec_safe('v', ['run', app_path])
		}()
		w.toast('SD Studio Pro launched!')
	})

	// Launch Say Studio
	win.on_click('btn_launch_say', fn (mut w simplegui.SimpleWindow) {
		app_path := os.join_path(os.dir(@FILE), 'say_studio.v')
		w.append_console('hub_log', '🗣️ Launching Say Studio Pro in background...\n', 1)
		go fn [app_path] () {
			simplegui.exec_safe('v', ['run', app_path])
		}()
		w.toast('Say Studio Pro launched!')
	})

	// Launch Find Studio
	win.on_click('btn_launch_find', fn (mut w simplegui.SimpleWindow) {
		app_path := os.join_path(os.dir(@FILE), 'find_studio.v')
		w.append_console('hub_log', '📂 Launching Find Studio Pro in background...\n', 1)
		go fn [app_path] () {
			simplegui.exec_safe('v', ['run', app_path])
		}()
		w.toast('Find Studio Pro launched!')
	})

	// Launch Task Manager
	win.on_click('btn_launch_taskman', fn (mut w simplegui.SimpleWindow) {
		app_path := os.join_path(os.dir(@FILE), 'task_manager.v')
		w.append_console('hub_log', '⚡ Launching Task Manager Pro in background...\n', 1)
		go fn [app_path] () {
			simplegui.exec_safe('v', ['run', app_path])
		}()
		w.toast('Task Manager Pro launched!')
	})

	// Launch Ouch Studio
	win.on_click('btn_launch_ouch', fn (mut w simplegui.SimpleWindow) {
		app_path := os.join_path(os.dir(@FILE), 'ouch_studio.v')
		w.append_console('hub_log', '📦 Launching Ouch Studio Pro in background...\n', 1)
		go fn [app_path] () {
			simplegui.exec_safe('v', ['run', app_path])
		}()
		w.toast('Ouch Studio Pro launched!')
	})

	// Launch Subfinder Studio
	win.on_click('btn_launch_subfinder', fn (mut w simplegui.SimpleWindow) {
		app_path := os.join_path(os.dir(@FILE), 'subfinder_studio.v')
		w.append_console('hub_log', '🌐 Launching Subfinder Studio Pro in background...\n', 1)
		go fn [app_path] () {
			simplegui.exec_safe('v', ['run', app_path])
		}()
		w.toast('Subfinder Studio Pro launched!')
	})

	// Launch yt-dlp Studio
	win.on_click('btn_launch_ytdlp', fn (mut w simplegui.SimpleWindow) {
		app_path := os.join_path(os.dir(@FILE), 'yt_dlp_studio.v')
		w.append_console('hub_log', '🎬 Launching yt-dlp Studio Pro in background...\n', 1)
		go fn [app_path] () {
			simplegui.exec_safe('v', ['run', app_path])
		}()
		w.toast('yt-dlp Studio Pro launched!')
	})

	// Launch Wget2 Studio
	win.on_click('btn_launch_wget2', fn (mut w simplegui.SimpleWindow) {
		app_path := os.join_path(os.dir(@FILE), 'wget2_studio.v')
		w.append_console('hub_log', '⚡ Launching Wget2 Studio Pro in background...\n', 1)
		go fn [app_path] () {
			simplegui.exec_safe('v', ['run', app_path])
		}()
		w.toast('Wget2 Studio Pro launched!')
	})

	// Launch Pandoc Studio
	win.on_click('btn_launch_pandoc', fn (mut w simplegui.SimpleWindow) {
		app_path := os.join_path(os.dir(@FILE), 'pandoc_studio.v')
		w.append_console('hub_log', '📄 Launching Pandoc Studio Pro in background...\n', 1)
		go fn [app_path] () {
			simplegui.exec_safe('v', ['run', app_path])
		}()
		w.toast('Pandoc Studio Pro launched!')
	})

	// Launch FD Studio
	win.on_click('btn_launch_fd', fn (mut w simplegui.SimpleWindow) {
		app_path := os.join_path(os.dir(@FILE), 'fd_studio.v')
		w.append_console('hub_log', '⚡ Launching FD Studio Pro in background...\n', 1)
		go fn [app_path] () {
			simplegui.exec_safe('v', ['run', app_path])
		}()
		w.toast('FD Studio Pro launched!')
	})

	// Launch ripgrep Studio
	win.on_click('btn_launch_rg', fn (mut w simplegui.SimpleWindow) {
		app_path := os.join_path(os.dir(@FILE), 'rg_studio.v')
		w.append_console('hub_log', '🔍 Launching RG Studio Pro in background...\n', 1)
		go fn [app_path] () {
			simplegui.exec_safe('v', ['run', app_path])
		}()
		w.toast('RG Studio Pro launched!')
	})

	// Launch Cut Studio
	win.on_click('btn_launch_cut', fn (mut w simplegui.SimpleWindow) {
		app_path := os.join_path(os.dir(@FILE), 'cut_studio.v')
		w.append_console('hub_log', '✂️ Launching Cut Studio Pro in background...\n', 1)
		go fn [app_path] () {
			simplegui.exec_safe('v', ['run', app_path])
		}()
		w.toast('Cut Studio Pro launched!')
	})

	// Launch TR Studio
	win.on_click('btn_launch_tr', fn (mut w simplegui.SimpleWindow) {
		app_path := os.join_path(os.dir(@FILE), 'tr_studio.v')
		w.append_console('hub_log', '🔄 Launching TR Studio Pro in background...\n', 1)
		go fn [app_path] () {
			simplegui.exec_safe('v', ['run', app_path])
		}()
		w.toast('TR Studio Pro launched!')
	})

	// Pick File
	win.on_click('btn_quick_browse', fn (mut w simplegui.SimpleWindow) {
		path := w.select_file()
		if path != '' {
			w.set('txt_quick_in', path)
			w.append_console('hub_log', '📁 Selected file: ${path}\n', 1)
		}
	})

	// Quick MP4 (Async)
	win.on_click('btn_q_mp4', fn [ffmpeg_path] (mut w simplegui.SimpleWindow) {
		in_f := w.get('txt_quick_in').trim_space()
		if in_f == '' || !os.exists(in_f) {
			w.alert('File Required', 'Please select a valid input video file first.')
			return
		}
		out_f := os.join_path(os.dir(in_f), os.file_name(in_f).all_before_last('.') + '_h264.mp4')
		raw_args := ['-y', '-i', in_f, '-c:v', 'libx264', '-crf', '22', '-preset', 'fast', '-c:a', 'aac', '-b:a', '192k', '-movflags', '+faststart', out_f]
		w.append_console('hub_log', '▶ Running MP4 conversion in background securely...\n', 1)
		w.set_status('Converting video to MP4 in background...')
		w.toast('⚡ Conversion running...')

		go fn [mut w, ffmpeg_path, raw_args, out_f] () {
			res := simplegui.exec_safe(ffmpeg_path, raw_args)
			w.run_on_main_thread(fn [res, out_f] (mut win_main simplegui.SimpleWindow) {
				if res.exit_code == 0 {
					win_main.append_console('hub_log', '✅ Converted to MP4: ${out_f}\n', 4)
					win_main.set_status('MP4 conversion completed.')
					win_main.toast('Converted to MP4 successfully!')
				} else {
					win_main.append_console('hub_log', '❌ FFmpeg error:\n' + res.output + '\n', 3)
					win_main.set_status('Error converting to MP4.')
				}
			})
		}()
	})

	// Quick Discord Compress (< 10MB) (Async)
	win.on_click('btn_q_discord', fn [ffmpeg_path, ffprobe_path] (mut w simplegui.SimpleWindow) {
		in_f := w.get('txt_quick_in').trim_space()
		if in_f == '' || !os.exists(in_f) {
			w.alert('File Required', 'Please select a valid video file first.')
			return
		}
		
		w.append_console('hub_log', '▶ Calculating bitrate for Discord (<10MB)...\n', 1)
		w.set_status('Calculating bitrate & compressing...')
		w.toast('⚡ Compressing for Discord...')

		go fn [mut w, in_f, ffprobe_path, ffmpeg_path] () {
			d_res := simplegui.exec_safe(ffprobe_path, ['-v', 'error', '-show_entries', 'format=duration', '-of', 'default=noprint_wrappers=1:nokey=1', in_f])
			mut dur := d_res.output.trim_space().f64()
			if dur <= 0.0 { dur = 60.0 }
			
			audio_k := 96.0
			total_k := 9.0 * 8192.0
			v_rate := int((total_k / dur) - audio_k)
			final_v := if v_rate > 100 { v_rate } else { 150 }

			out_f := os.join_path(os.dir(in_f), os.file_name(in_f).all_before_last('.') + '_discord.mp4')
			raw_args := ['-y', '-i', in_f, '-c:v', 'libx264', '-b:v', '${final_v}k', '-preset', 'medium', '-c:a', 'aac', '-b:a', '96k', '-movflags', '+faststart', out_f]
			
			w.run_on_main_thread(fn (mut win_main simplegui.SimpleWindow) {
				win_main.append_console('hub_log', '▶ Compressing for Discord securely in background...\n', 1)
			})

			res := simplegui.exec_safe(ffmpeg_path, raw_args)
			w.run_on_main_thread(fn [res, out_f] (mut win_main simplegui.SimpleWindow) {
				if res.exit_code == 0 {
					sz := os.file_size(out_f)
					mb := f64(sz) / (1024.0 * 1024.0)
					win_main.append_console('hub_log', '✅ Discord Video Created: ${out_f} (${mb:.2f} MB)\n', 4)
					win_main.set_status('Discord video created: ${mb:.2f} MB.')
					win_main.toast('Compressed for Discord (${mb:.2f} MB)!')
				} else {
					win_main.append_console('hub_log', '❌ FFmpeg error:\n' + res.output + '\n', 3)
					win_main.set_status('Error compressing for Discord.')
				}
			})
		}()
	})

	// Quick TikTok / Reels Vertical (9:16) (Async)
	win.on_click('btn_q_reels', fn [ffmpeg_path] (mut w simplegui.SimpleWindow) {
		in_f := w.get('txt_quick_in').trim_space()
		if in_f == '' || !os.exists(in_f) {
			w.alert('File Required', 'Please select a valid video file first.')
			return
		}
		out_f := os.join_path(os.dir(in_f), os.file_name(in_f).all_before_last('.') + '_reels_9x16.mp4')
		raw_args := ['-y', '-i', in_f, '-vf', 'scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=black', '-c:v', 'libx264', '-crf', '22', '-preset', 'fast', '-c:a', 'aac', '-b:a', '192k', out_f]
		w.append_console('hub_log', '▶ Converting to 9:16 Vertical in background...\n', 1)
		w.set_status('Creating vertical 9:16 video...')
		w.toast('⚡ Converting to Reels / TikTok format...')

		go fn [mut w, ffmpeg_path, raw_args, out_f] () {
			res := simplegui.exec_safe(ffmpeg_path, raw_args)
			w.run_on_main_thread(fn [res, out_f] (mut win_main simplegui.SimpleWindow) {
				if res.exit_code == 0 {
					win_main.append_console('hub_log', '✅ Converted to 9:16 Reels/TikTok: ${out_f}\n', 4)
					win_main.set_status('9:16 video created.')
					win_main.toast('Vertical 9:16 Video Ready!')
				} else {
					win_main.append_console('hub_log', '❌ FFmpeg error:\n' + res.output + '\n', 3)
					win_main.set_status('Error converting video.')
				}
			})
		}()
	})

	// Quick MP3 (Async)
	win.on_click('btn_q_mp3', fn [ffmpeg_path] (mut w simplegui.SimpleWindow) {
		in_f := w.get('txt_quick_in').trim_space()
		if in_f == '' || !os.exists(in_f) {
			w.alert('File Required', 'Please select a valid input media file first.')
			return
		}
		out_f := os.join_path(os.dir(in_f), os.file_name(in_f).all_before_last('.') + '_audio.mp3')
		raw_args := ['-y', '-i', in_f, '-vn', '-c:a', 'libmp3lame', '-b:a', '256k', out_f]
		w.append_console('hub_log', '▶ Extracting Audio securely in background...\n', 1)
		w.set_status('Extracting MP3 audio...')
		w.toast('⚡ Extracting MP3...')

		go fn [mut w, ffmpeg_path, raw_args, out_f] () {
			res := simplegui.exec_safe(ffmpeg_path, raw_args)
			w.run_on_main_thread(fn [res, out_f] (mut win_main simplegui.SimpleWindow) {
				if res.exit_code == 0 {
					win_main.append_console('hub_log', '✅ Extracted MP3: ${out_f}\n', 4)
					win_main.set_status('MP3 extracted successfully.')
					win_main.toast('Audio extracted successfully!')
				} else {
					win_main.append_console('hub_log', '❌ Error extracting audio:\n' + res.output + '\n', 3)
					win_main.set_status('Error extracting audio.')
				}
			})
		}()
	})

	// Quick Loudnorm Audio (Async)
	win.on_click('btn_q_loudnorm', fn [ffmpeg_path] (mut w simplegui.SimpleWindow) {
		in_f := w.get('txt_quick_in').trim_space()
		if in_f == '' || !os.exists(in_f) {
			w.alert('File Required', 'Please select a valid audio/video file first.')
			return
		}
		out_f := os.join_path(os.dir(in_f), os.file_name(in_f).all_before_last('.') + '_loudnorm.mp3')
		raw_args := ['-y', '-i', in_f, '-vn', '-af', 'loudnorm=I=-16:TP=-1.5:LRA=11', '-c:a', 'libmp3lame', '-b:a', '256k', out_f]
		w.append_console('hub_log', '▶ Normalizing Audio (EBU R128) in background...\n', 1)
		w.set_status('Normalizing audio levels in background...')
		w.toast('⚡ Normalizing audio...')

		go fn [mut w, ffmpeg_path, raw_args, out_f] () {
			res := simplegui.exec_safe(ffmpeg_path, raw_args)
			w.run_on_main_thread(fn [res, out_f] (mut win_main simplegui.SimpleWindow) {
				if res.exit_code == 0 {
					win_main.append_console('hub_log', '✅ Normalized Audio Created: ${out_f}\n', 4)
					win_main.set_status('Audio normalized successfully.')
					win_main.toast('Audio normalized to broadcast standards!')
				} else {
					win_main.append_console('hub_log', '❌ Normalization error:\n' + res.output + '\n', 3)
					win_main.set_status('Error normalizing audio.')
				}
			})
		}()
	})

	// Quick WebP (Async)
	win.on_click('btn_q_webp', fn [magick_path] (mut w simplegui.SimpleWindow) {
		in_f := w.get('txt_quick_in').trim_space()
		if in_f == '' || !os.exists(in_f) {
			w.alert('File Required', 'Please select a valid input image first.')
			return
		}
		out_f := os.join_path(os.dir(in_f), os.file_name(in_f).all_before_last('.') + '_optimized.webp')
		raw_args := [in_f, '-quality', '85', '-strip', out_f]
		w.append_console('hub_log', '▶ Converting Image to WebP in background...\n', 1)
		w.set_status('Converting image to WebP in background...')
		w.toast('⚡ Compressing image to WebP...')

		go fn [mut w, magick_path, raw_args, out_f] () {
			res := simplegui.exec_safe(magick_path, raw_args)
			w.run_on_main_thread(fn [res, out_f] (mut win_main simplegui.SimpleWindow) {
				if res.exit_code == 0 {
					win_main.append_console('hub_log', '✅ Created WebP: ${out_f}\n', 4)
					win_main.set_status('WebP image ready.')
					win_main.toast('WebP image created successfully!')
				} else {
					win_main.append_console('hub_log', '❌ ImageMagick error:\n' + res.output + '\n', 3)
					win_main.set_status('Error creating WebP.')
				}
			})
		}()
	})

	// Quick Favicon.ico (Async)
	win.on_click('btn_q_ico', fn [magick_path] (mut w simplegui.SimpleWindow) {
		in_f := w.get('txt_quick_in').trim_space()
		if in_f == '' || !os.exists(in_f) {
			w.alert('File Required', 'Please select a valid image/icon file first.')
			return
		}
		out_f := os.join_path(os.dir(in_f), 'favicon.ico')
		raw_args := [in_f, '-define', 'icon:auto-resize=64,48,32,16', out_f]
		w.append_console('hub_log', '▶ Generating Multi-Resolution Favicon.ico in background...\n', 1)
		w.set_status('Generating multi-layer Favicon.ico...')
		w.toast('⚡ Generating Favicon.ico...')

		go fn [mut w, magick_path, raw_args, out_f] () {
			res := simplegui.exec_safe(magick_path, raw_args)
			w.run_on_main_thread(fn [res, out_f] (mut win_main simplegui.SimpleWindow) {
				if res.exit_code == 0 {
					win_main.append_console('hub_log', '✅ Multi-Size Favicon Generated: ${out_f}\n', 4)
					win_main.set_status('Favicon.ico created.')
					win_main.toast('Favicon.ico generated successfully!')
				} else {
					win_main.append_console('hub_log', '❌ Error creating favicon:\n' + res.output + '\n', 3)
					win_main.set_status('Error generating favicon.')
				}
			})
		}()
	})

	// Quick Remove White Background (Async)
	win.on_click('btn_q_nobg', fn [magick_path] (mut w simplegui.SimpleWindow) {
		in_f := w.get('txt_quick_in').trim_space()
		if in_f == '' || !os.exists(in_f) {
			w.alert('File Required', 'Please select a valid image file first.')
			return
		}
		out_f := os.join_path(os.dir(in_f), os.file_name(in_f).all_before_last('.') + '_transparent.png')
		raw_args := [in_f, '-fuzz', '10%', '-transparent', 'white', '-trim', '+repage', out_f]
		w.append_console('hub_log', '▶ Removing Solid White Background in background...\n', 1)
		w.set_status('Removing white background...')
		w.toast('⚡ Creating transparent PNG...')

		go fn [mut w, magick_path, raw_args, out_f] () {
			res := simplegui.exec_safe(magick_path, raw_args)
			w.run_on_main_thread(fn [res, out_f] (mut win_main simplegui.SimpleWindow) {
				if res.exit_code == 0 {
					win_main.append_console('hub_log', '✅ Background Removed: ${out_f}\n', 4)
					win_main.set_status('Transparent PNG created.')
					win_main.toast('Transparent PNG created!')
				} else {
					win_main.append_console('hub_log', '❌ Error removing background:\n' + res.output + '\n', 3)
					win_main.set_status('Error removing background.')
				}
			})
		}()
	})

	// Quick Video to HD GIF (Async)
	win.on_click('btn_q_gif', fn [ffmpeg_path] (mut w simplegui.SimpleWindow) {
		in_f := w.get('txt_quick_in').trim_space()
		if in_f == '' || !os.exists(in_f) {
			w.alert('File Required', 'Please select a valid video file first.')
			return
		}
		out_f := os.join_path(os.dir(in_f), os.file_name(in_f).all_before_last('.') + '_palette.gif')
		raw_args := ['-y', '-t', '10', '-i', in_f, '-vf', 'fps=15,scale=480:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse', out_f]
		w.append_console('hub_log', '▶ Converting Video to HD 2-Pass GIF in background...\n', 1)
		w.set_status('Generating HD GIF with 2-pass palette filter...')
		w.toast('⚡ Generating HD GIF...')

		go fn [mut w, ffmpeg_path, raw_args, out_f] () {
			res := simplegui.exec_safe(ffmpeg_path, raw_args)
			w.run_on_main_thread(fn [res, out_f] (mut win_main simplegui.SimpleWindow) {
				if res.exit_code == 0 {
					win_main.append_console('hub_log', '✅ HD GIF Created: ${out_f}\n', 4)
					win_main.set_status('HD GIF ready.')
					win_main.toast('HD GIF generated successfully!')
				} else {
					win_main.append_console('hub_log', '❌ GIF conversion error:\n' + res.output + '\n', 3)
					win_main.set_status('Error generating GIF.')
				}
			})
		}()
	})

	// Quick Resize 50% (Async)
	win.on_click('btn_q_resize', fn [magick_path] (mut w simplegui.SimpleWindow) {
		in_f := w.get('txt_quick_in').trim_space()
		if in_f == '' || !os.exists(in_f) {
			w.alert('File Required', 'Please select a valid input image first.')
			return
		}
		ext := os.file_ext(in_f)
		out_f := os.join_path(os.dir(in_f), os.file_name(in_f).all_before_last('.') + '_50pct' + ext)
		raw_args := [in_f, '-resize', '50%', out_f]
		w.append_console('hub_log', '▶ Resizing Image (50%) in background...\n', 1)
		w.set_status('Resizing image in background...')
		w.toast('⚡ Resizing image...')

		go fn [mut w, magick_path, raw_args, out_f] () {
			res := simplegui.exec_safe(magick_path, raw_args)
			w.run_on_main_thread(fn [res, out_f] (mut win_main simplegui.SimpleWindow) {
				if res.exit_code == 0 {
					win_main.append_console('hub_log', '✅ Resized image: ${out_f}\n', 4)
					win_main.set_status('Image resized 50%.')
					win_main.toast('Image resized 50% successfully!')
				} else {
					win_main.append_console('hub_log', '❌ ImageMagick error:\n' + res.output + '\n', 3)
					win_main.set_status('Error resizing image.')
				}
			})
		}()
	})

	// Quick Inspect (Async)
	win.on_click('btn_q_info', fn [ffprobe_path, identify_path] (mut w simplegui.SimpleWindow) {
		in_f := w.get('txt_quick_in').trim_space()
		if in_f == '' || !os.exists(in_f) {
			w.alert('File Required', 'Please select a valid file to inspect.')
			return
		}
		ext := os.file_ext(in_f).to_lower()
		w.append_console('hub_log', '🔍 Inspecting metadata for: ${in_f}...\n', 1)
		w.set_status('Extracting media metadata...')

		go fn [mut w, in_f, ext, ffprobe_path, identify_path] () {
			if ext in ['.mp4', '.mkv', '.mov', '.avi', '.webm', '.mp3', '.wav', '.flac', '.m4a'] {
				res := simplegui.exec_safe(ffprobe_path, ['-v', 'error', '-show_format', '-show_streams', '-pretty', in_f])
				w.run_on_main_thread(fn [res] (mut win_main simplegui.SimpleWindow) {
					win_main.append_console('hub_log', res.output + '\n', 4)
					win_main.set_status('Metadata inspection ready.')
				})
			} else {
				res := simplegui.exec_safe(identify_path, ['-verbose', in_f])
				w.run_on_main_thread(fn [res] (mut win_main simplegui.SimpleWindow) {
					win_main.append_console('hub_log', res.output + '\n', 4)
					win_main.set_status('EXIF metadata inspection ready.')
				})
			}
		}()
	})

	// Open in Finder
	win.on_click('btn_open_finder', fn (mut w simplegui.SimpleWindow) {
		in_f := w.get('txt_quick_in').trim_space()
		if in_f != '' && os.exists(in_f) {
			os.execute('open -R "${in_f}"')
		} else {
			os.execute('open .')
		}
		w.toast('Opened in Finder.')
	})

	// Clear Hub Log
	win.on_click('btn_clear_hub_log', fn (mut w simplegui.SimpleWindow) {
		w.clear_console('hub_log')
	})

	println('Media & Data Studio Hub configured. Starting event loop...')
	win.run()
}

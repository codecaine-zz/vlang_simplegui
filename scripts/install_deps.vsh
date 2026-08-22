#!/usr/bin/env -S v run

import os
import time

struct ToolDep {
	formula     string
	bin_name    string
	description string
	used_by     []string
}

fn get_tool_definitions() []ToolDep {
	return [
		ToolDep{
			formula: 'ripgrep'
			bin_name: 'rg'
			description: 'Fast line-oriented search engine'
			used_by: ['rg_studio.v', 'text_editor.v']
		},
		ToolDep{
			formula: 'fd'
			bin_name: 'fd'
			description: 'Simple, fast and user-friendly alternative to find'
			used_by: ['fd_studio.v']
		},
		ToolDep{
			formula: 'sd'
			bin_name: 'sd'
			description: 'Intuitive find & replace CLI tool'
			used_by: ['sd_studio.v']
		},
		ToolDep{
			formula: 'gawk'
			bin_name: 'gawk'
			description: 'GNU awk pattern scanning and processing language'
			used_by: ['gawk_studio.v']
		},
		ToolDep{
			formula: 'ouch'
			bin_name: 'ouch'
			description: 'Fast compression & decompression utility (zip, tar, zstd, 7z)'
			used_by: ['ouch_studio.v']
		},
		ToolDep{
			formula: 'ffmpeg'
			bin_name: 'ffmpeg'
			description: 'Audio/video processing, transcoding & filtering engine'
			used_by: ['ffmpeg_studio.v', 'audiotag_studio.v', 'media_studio_hub.v', 'yt_dlp_studio.v']
		},
		ToolDep{
			formula: 'imagemagick'
			bin_name: 'magick'
			description: 'Image processing and manipulation suite'
			used_by: ['imagemagick_studio.v', 'media_studio_hub.v']
		},
		ToolDep{
			formula: 'pandoc'
			bin_name: 'pandoc'
			description: 'Universal document converter (Markdown, Docx, PDF, LaTeX)'
			used_by: ['pandoc_studio.v']
		},
		ToolDep{
			formula: 'wget2'
			bin_name: 'wget2'
			description: 'Multi-threaded file download accelerator'
			used_by: ['wget2_studio.v']
		},
		ToolDep{
			formula: 'yt-dlp'
			bin_name: 'yt-dlp'
			description: 'Media streamer and video/audio extractor'
			used_by: ['yt_dlp_studio.v']
		},
		ToolDep{
			formula: 'subfinder'
			bin_name: 'subfinder'
			description: 'Fast passive subdomain enumeration tool'
			used_by: ['subfinder_studio.v']
		},
		ToolDep{
			formula: 'jq'
			bin_name: 'jq'
			description: 'Command-line JSON processor and filter'
			used_by: ['jq_studio.v']
		},
		ToolDep{
			formula: 'libqalculate'
			bin_name: 'qalc'
			description: 'Advanced symbolic mathematics & unit conversion engine'
			used_by: ['qalc_studio.v']
		},
		ToolDep{
			formula: 'numbat'
			bin_name: 'numbat'
			description: 'Statically typed dimensional analysis and physical calculation engine'
			used_by: ['numbat_studio.v']
		},
		ToolDep{
			formula: 'kalker'
			bin_name: 'kalker'
			description: 'Natural syntax scientific math & calculus CLI'
			used_by: ['kalker_studio.v']
		},
		ToolDep{
			formula: 'nmap'
			bin_name: 'nmap'
			description: 'Network exploration tool and security / port scanner'
			used_by: ['nmap_studio.v']
		},
		ToolDep{
			formula: 'exiftool'
			bin_name: 'exiftool'
			description: 'Read, write and edit EXIF/IPTC image metadata'
			used_by: ['exif_studio.v']
		},
		ToolDep{
			formula: 'tesseract'
			bin_name: 'tesseract'
			description: 'OCR (Optical Character Recognition) engine'
			used_by: ['ocr_studio.v']
		},
		ToolDep{
			formula: 'graphviz'
			bin_name: 'dot'
			description: 'Graph visualization and DOT diagram compiler'
			used_by: ['dot_studio.v']
		},
	]
}

fn check_brew_installed() string {
	brew_path := os.find_abs_path_of_executable('brew') or {
		// Check common homebrew installation paths on Apple Silicon and Intel
		if os.exists('/opt/homebrew/bin/brew') {
			'/opt/homebrew/bin/brew'
		} else if os.exists('/usr/local/bin/brew') {
			'/usr/local/bin/brew'
		} else {
			''
		}
	}
	return brew_path
}

fn is_tool_available(dep ToolDep) (bool, string) {
	// 1. Direct executable lookup
	if path := os.find_abs_path_of_executable(dep.bin_name) {
		return true, path
	}

	// 2. Check standard Homebrew bin folders
	standard_paths := [
		'/opt/homebrew/bin/${dep.bin_name}',
		'/usr/local/bin/${dep.bin_name}',
	]
	for p in standard_paths {
		if os.exists(p) {
			return true, p
		}
	}

	// Special check for imagemagick fallback 'convert'
	if dep.bin_name == 'magick' {
		if convert_path := os.find_abs_path_of_executable('convert') {
			return true, convert_path
		}
	}

	return false, ''
}

fn print_help() {
	println('======================================================================')
	println('SimpleGUI Homebrew Dependency Installer for macOS')
	println('======================================================================')
	println('Usage: v run scripts/install_deps.vsh [options] [app_filter]')
	println('')
	println('Options:')
	println('  --check, -c      Only verify and report missing dependencies (no install)')
	println('  --dry-run, -d    Show the brew command that would run without installing')
	println('  --all, -a        Check and install all known dependencies (default)')
	println('  --app <name>     Check/install only dependencies needed by specific studio app')
	println('  --help, -h       Show this help documentation')
	println('')
	println('Examples:')
	println('  v run scripts/install_deps.vsh                  # Checks & installs all missing')
	println('  v run scripts/install_deps.vsh --check          # Fast status report')
	println('  v run scripts/install_deps.vsh --app jq_studio  # Only for JQ Studio')
	println('======================================================================')
}

fn main() {
	$if !macos {
		eprintln('⚠️  SimpleGUI applications suite is designed for macOS (Aqua Cocoa backend).')
		eprintln('   Current OS is not macOS.')
	}

	mut check_only := false
	mut dry_run := false
	mut target_app := ''

	mut i := 1
	for i < os.args.len {
		arg := os.args[i]
		if arg in ['-h', '--help'] {
			print_help()
			return
		} else if arg in ['-c', '--check'] {
			check_only = true
		} else if arg in ['-d', '--dry-run'] {
			dry_run = true
		} else if arg in ['-a', '--all'] {
			target_app = ''
		} else if arg == '--app' {
			if i + 1 < os.args.len {
				i++
				target_app = os.args[i].replace('.v', '')
			}
		} else if !arg.starts_with('-') {
			target_app = arg.replace('.v', '')
		}
		i++
	}

	brew_bin := check_brew_installed()
	if brew_bin == '' {
		eprintln('❌ Homebrew is not installed on this system!')
		eprintln('')
		eprintln('To install Homebrew, run the official installer:')
		eprintln('   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"')
		eprintln('')
		exit(1)
	}

	all_deps := get_tool_definitions()

	// Filter if target app requested
	mut active_deps := []ToolDep{}
	for dep in all_deps {
		if target_app == '' {
			active_deps << dep
		} else {
			mut matches := false
			for used in dep.used_by {
				if used.contains(target_app) || dep.formula.contains(target_app) || dep.bin_name == target_app {
					matches = true
					break
				}
			}
			if matches {
				active_deps << dep
			}
		}
	}

	if active_deps.len == 0 {
		println('No matching tool dependencies found for "${target_app}".')
		println('Available studio apps: jq, ffmpeg, imagemagick, ripgrep, ouch, pandoc, etc.')
		exit(0)
	}

	println('======================================================================')
	println('🍺 SimpleGUI Homebrew Dependency Inspector')
	println('======================================================================')
	println('Brew Executable : ${brew_bin}')
	if target_app != '' {
		println('Target Filter   : ${target_app}')
	}
	println('Checking ${active_deps.len} dependency packages...')
	println('----------------------------------------------------------------------')

	mut installed_list := []ToolDep{}
	mut missing_list := []ToolDep{}

	for dep in active_deps {
		ok, path := is_tool_available(dep)
		if ok {
			installed_list << dep
			println('  ✅ [INSTALLED] ${dep.formula:-15s} (binary: ${dep.bin_name}) -> ${path}')
		} else {
			missing_list << dep
			println('  ⚠️  [MISSING]   ${dep.formula:-15s} (binary: ${dep.bin_name}) - ${dep.description}')
		}
	}

	println('----------------------------------------------------------------------')
	println('Status: ${installed_list.len} installed, ${missing_list.len} missing.')

	if missing_list.len == 0 {
		println('✨ All required Homebrew dependencies are already installed and up to date!')
		return
	}

	if check_only {
		println('\nTo install all missing dependencies, run:')
		mut pkg_names := []string{}
		for dep in missing_list {
			pkg_names << dep.formula
		}
		println('   brew install ${pkg_names.join(' ')}')
		return
	}

	mut missing_formulae := []string{}
	for dep in missing_list {
		missing_formulae << dep.formula
	}
	brew_cmd := '${brew_bin} install ${missing_formulae.join(' ')}'

	if dry_run {
		println('\n[DRY RUN] Would execute command:')
		println('   ${brew_cmd}')
		return
	}

	println('\n🚀 Installing ${missing_list.len} missing package(s) via Homebrew...')
	println('Command: ${brew_cmd}\n')

	t0 := time.now()
	exit_code := os.system(brew_cmd)
	elapsed := time.since(t0)

	println('----------------------------------------------------------------------')
	if exit_code == 0 {
		println('🎉 Successfully installed all missing dependencies in ${elapsed.seconds():.2f}s!')
	} else {
		eprintln('❌ Homebrew installation finished with exit code ${exit_code}.')
		exit(exit_code)
	}
}

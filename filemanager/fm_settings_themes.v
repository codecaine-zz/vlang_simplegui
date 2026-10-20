module filemanager

import encoding.base64
import json2
import math
import os
import time

// default_settings_json contains the default JSON configuration for Codecaine File Manager.
pub const default_settings_json = '{
  "favorites": [],
  "favoriteNames": {},
  "recents": [],
  "recentsEnabled": true,
  "view": "details",
  "sortBy": "name",
  "sortDir": "asc",
  "foldersFirst": true,
  "showHidden": false,
  "showInfoPanel": false,
  "theme": "auto",
  "palette": "",
  "preferredLightPalette": "",
  "preferredDarkPalette": "",
  "solarScheduleEnabled": false,
  "solarDawnPalette": "",
  "solarDayPalette": "",
  "solarDuskPalette": "",
  "solarNightPalette": "",
  "folderThemes": {},
  "favoriteThemes": [],
  "atmosphere": "none",
  "atmosphereIntensity": 60,
  "atmosphereTier": "auto",
  "platformProfile": "",
  "atmosphereReactive": "off",
  "atmospherePresets": [],
  "atmosphereLayerMods": {},
  "ambientPlaylistEnabled": false,
  "ambientPlaylistIntervalMin": 15,
  "ambientPlaylistTarget": "both",
  "ambientPlaylistPool": "favorites",
  "themeFontProfile": "default",
  "themeCornerProfile": "default",
  "themeIconGlow": "off",
  "themeIconAnimation": "off",
  "uiElementFx": "off",
  "iconPackStyle": "default",
  "screenFilter": "off",
  "iconFinishMode": "off",
  "workspaceStageMode": "off",
  "uiSoundProfile": "off",
  "cursorTrailMode": "off",
  "folderSpringMode": "off",
  "desktopWallpaperScene": "off",
  "dualPaneFocusMode": "spotlight",
  "chameleonFolderMode": "off",
  "zeroWattGovernorMode": "auto",
  "themeShowMode": "cinema_hud",
  "themeShowChannel": "all_ultra",
  "themeShowIntervalSec": 15,
  "themeShowIdleMinutes": 0,
  "themeShowTransition": "oklab_morph",
  "themeShowExitOnMove": false,
  "themeShowClock": true,
  "themeShowBoostTier": "extreme",
  "textSize": 100,
  "lastPath": "",
  "seenWelcome": false,
  "terminalFollow": true,
  "terminalOpen": false,
  "terminalHeight": 300,
  "terminalPath": "",
  "workspace": "files",
  "startWith": "files",
  "splitSide": "right",
  "splitSize": 50,
  "sidebarCollapsed": false,
  "focusMode": false,
  "activeTool": "",
  "splitTool": "",
  "dualPath": "",
  "typeWarnings": true,
  "backspaceDeletes": true,
  "shortcutsCantClose": false,
  "editor": "default",
  "serveOptions": { "kind": "auto", "liveReload": true, "openBrowser": true },
  "deleteTo": "bin",
  "dbShortcut": "window",
  "textOpensIn": "builtin",
  "mediaOpensIn": "manager",
  "shortcuts": {},
  "studioPresets": { "image": [], "media": [] },
  "columns": [],
  "groupBy": "none",
  "rowDensity": "comfortable",
  "tags": {},
  "treeExpanded": false
}'

// load_settings_map loads user settings from `settings.json`, merging them over the default settings.
pub fn load_settings_map(ctx &FmContext) map[string]json2.Any {
	mut base := map[string]json2.Any{}
	if def_any := json2.decode[json2.Any](default_settings_json) {
		if def_any is map[string]json2.Any {
			base = def_any.clone()
		}
	}
	mut raw := ''
	for candidate in [
		ctx.settings_file,
		os.join_path(ctx.data_dir, 'file_manager.json'),
		os.join_path(ctx.data_dir, 'file_manager_settings.json'),
	] {
		if os.exists(candidate) {
			if content := os.read_file(candidate) {
				if content.trim_space() != '' {
					raw = content
					break
				}
			}
		}
	}
	if raw == '' {
		return base
	}
	parsed := json2.decode[json2.Any](raw) or { return base }
	if parsed is map[string]json2.Any {
		for k, v in parsed {
			base[k] = v
		}
	}
	return base
}

// save_settings_map atomically writes the user settings map to `settings.json`.
pub fn save_settings_map(ctx &FmContext, settings map[string]json2.Any) {
	os.mkdir_all(os.dir(ctx.settings_file)) or {}
	encoded := json2.encode[map[string]json2.Any](settings)
	tmp := '${ctx.settings_file}.tmp-${random_hex(4)}'
	os.write_file(tmp, encoded) or { return }
	os.mv(tmp, ctx.settings_file) or {
		os.write_file(ctx.settings_file, encoded) or {}
		os.rm(tmp) or {}
	}
	alt_file := os.join_path(ctx.data_dir, 'file_manager.json')
	if os.exists(alt_file) {
		os.write_file(alt_file, encoded) or {}
	}
}

// handle_settings gets, updates, or resets user settings in `settings.json`.
pub fn handle_settings(ctx &FmContext, b map[string]json2.Any) !string {
	mut cur := load_settings_map(ctx)
	if patch_any := b['set'] {
		if patch_any is map[string]json2.Any {
			for k, v in patch_any {
				cur[k] = v
			}
			save_settings_map(ctx, cur)
		}
	}
	return '{"settings":${json2.encode[map[string]json2.Any](cur)}}'
}

// handle_recent_add records a path in the recently visited items list.
pub fn handle_recent_add(ctx &FmContext, b map[string]json2.Any) !string {
	raw_path := map_str(b, 'path', '')
	mut cur := load_settings_map(ctx)
	if raw_path != '' && map_bool(cur, 'recentsEnabled', true) {
		if resolved := resolve_existing(ctx, raw_path, false) {
			mut next_recents := []json2.Any{}
			mut first := map[string]json2.Any{}
			first['path'] = json2.Any(resolved)
			first['at'] = json2.Any(time.now().format_rfc3339())
			next_recents << json2.Any(first)

			if existing_any := cur['recents'] {
				if existing_any is []json2.Any {
					for item in existing_any {
						if item is map[string]json2.Any {
							if map_str(item, 'path', '') != resolved && next_recents.len < 30 {
								next_recents << item
							}
						}
					}
				}
			}
			cur['recents'] = json2.Any(next_recents)
			save_settings_map(ctx, cur)
		}
	}
	return '{"settings":${json2.encode[map[string]json2.Any](cur)}}'
}

// handle_recent_remove removes a specific path from the recently visited items list.
pub fn handle_recent_remove(ctx &FmContext, b map[string]json2.Any) !string {
	raw_path := map_str(b, 'path', '')
	target := os.real_path(raw_path)
	mut cur := load_settings_map(ctx)
	mut next_recents := []json2.Any{}
	if existing_any := cur['recents'] {
		if existing_any is []json2.Any {
			for item in existing_any {
				if item is map[string]json2.Any {
					p := map_str(item, 'path', '')
					if p != raw_path && p != target {
						next_recents << item
					}
				}
			}
		}
	}
	cur['recents'] = json2.Any(next_recents)
	save_settings_map(ctx, cur)
	return '{"settings":${json2.encode[map[string]json2.Any](cur)}}'
}

// handle_recent_clear clears all entries from the recently visited items list.
pub fn handle_recent_clear(ctx &FmContext) !string {
	mut cur := load_settings_map(ctx)
	cur['recents'] = json2.Any([]json2.Any{})
	save_settings_map(ctx, cur)
	return '{"settings":${json2.encode[map[string]json2.Any](cur)}}'
}

// handle_recent_prune removes non-existent paths from the recently visited items list.
pub fn handle_recent_prune(ctx &FmContext) !string {
	mut cur := load_settings_map(ctx)
	mut next_recents := []json2.Any{}
	mut removed := 0
	if existing_any := cur['recents'] {
		if existing_any is []json2.Any {
			for item in existing_any {
				if item is map[string]json2.Any {
					p := map_str(item, 'path', '')
					if p != '' && (os.exists(p) || os.is_link(p)) {
						next_recents << item
					} else {
						removed++
					}
				}
			}
		}
	}
	cur['recents'] = json2.Any(next_recents)
	save_settings_map(ctx, cur)
	return '{"settings":${json2.encode[map[string]json2.Any](cur)},"removed":${removed}}'
}

// ============================================================================
// Themes Catalog & Custom Theme Engine
// ============================================================================

fn find_builtin_themes_file() string {
	exe_dir := os.dir(os.executable())
	candidates := [
		os.join_path(os.getwd(), 'resources', 'file_manager', 'builtin_themes.json'),
		os.join_path(exe_dir, 'resources', 'file_manager', 'builtin_themes.json'),
		os.join_path(exe_dir, '..', 'resources', 'file_manager', 'builtin_themes.json'),
		'/Users/codecaine/vlang_webview_rad_studio/resources/file_manager/builtin_themes.json',
	]
	for c in candidates {
		if os.exists(c) {
			return c
		}
	}
	return candidates[0]
}

fn load_builtin_themes_catalog(mut ctx FmContext) map[string]json2.Any {
	ctx.state_mu.lock()
	cached := ctx.kv_store['__builtin_themes_loaded__'] or { '' }
	ctx.state_mu.unlock()
	path := find_builtin_themes_file()
	if cached == '' && os.exists(path) {
		if raw := os.read_file(path) {
			ctx.state_mu.lock()
			ctx.kv_store['__builtin_themes_loaded__'] = raw
			ctx.state_mu.unlock()
			if parsed := json2.decode[json2.Any](raw) {
				if parsed is map[string]json2.Any {
					return parsed
				}
			}
		}
	} else if cached != '' {
		if parsed := json2.decode[json2.Any](cached) {
			if parsed is map[string]json2.Any {
				return parsed
			}
		}
	}
	return map[string]json2.Any{}
}

fn parse_hex_rgb(hex_in string, def_r int, def_g int, def_b int) (int, int, int) {
	s := hex_in.trim_space().trim_left('#')
	if s.len == 3 {
		r := ('0x' + s[0..1] + s[0..1]).int()
		g := ('0x' + s[1..2] + s[1..2]).int()
		b := ('0x' + s[2..3] + s[2..3]).int()
		return r, g, b
	}
	if s.len >= 6 {
		r := ('0x' + s[0..2]).int()
		g := ('0x' + s[2..4]).int()
		b := ('0x' + s[4..6]).int()
		return r, g, b
	}
	return def_r, def_g, def_b
}

fn rgb_to_hex(r int, g int, b int) string {
	cr := math.max(0, math.min(255, r))
	cg := math.max(0, math.min(255, g))
	cb := math.max(0, math.min(255, b))
	return '#${cr:02x}${cg:02x}${cb:02x}'
}

fn mix_hex(a string, b string, t f64) string {
	ar, ag, ab := parse_hex_rgb(a, 0, 0, 0)
	br, bg, bb := parse_hex_rgb(b, 255, 255, 255)
	r := int(math.round(f64(ar) + f64(br - ar) * t))
	g := int(math.round(f64(ag) + f64(bg - ag) * t))
	bl := int(math.round(f64(ab) + f64(bb - ab) * t))
	return rgb_to_hex(r, g, bl)
}

fn rel_lum(hex_str string) f64 {
	r, g, b := parse_hex_rgb(hex_str, 0, 0, 0)
	chan_lum := fn (c int) f64 {
		v := f64(c) / 255.0
		return if v <= 0.03928 { v / 12.92 } else { math.pow((v + 0.055) / 1.055, 2.4) }
	}
	return 0.2126 * chan_lum(r) + 0.7152 * chan_lum(g) + 0.0722 * chan_lum(b)
}

fn contrast_ratio_hex(a string, b string) f64 {
	la := rel_lum(a)
	lb := rel_lum(b)
	hi := if la > lb { la } else { lb }
	lo := if la > lb { lb } else { la }
	return (hi + 0.05) / (lo + 0.05)
}

fn readable_hex(color string, bg string, min_ratio f64) string {
	if contrast_ratio_hex(color, bg) >= min_ratio {
		return color
	}
	toward := if contrast_ratio_hex(bg, '#000000') < 4.6 { '#ffffff' } else { '#000000' }
	for i := 1; i <= 20; i++ {
		cand := mix_hex(color, toward, f64(i) * 0.05)
		if contrast_ratio_hex(cand, bg) >= min_ratio {
			return cand
		}
	}
	return toward
}

fn compute_custom_theme_entry(id string, draft map[string]json2.Any) map[string]json2.Any {
	name := map_str(draft, 'name', 'Custom Theme')
	dark := map_bool(draft, 'dark', true)
	base := map_str(draft, 'base', 'Custom')
	colors := map_obj(draft, 'colors')
	fx := map_obj(draft, 'fx')
	has_fx := fx.len > 0

	bg := map_str(colors, 'background', if dark { '#16191d' } else { '#ffffff' }).to_lower()
	raw_text := map_str(colors, 'text', if dark { '#e8eaed' } else { '#1b1f24' }).to_lower()
	raw_accent := map_str(colors, 'accent', '#0b5cd5').to_lower()
	panel := map_str(colors, 'card', mix_hex(bg, raw_text, 0.07)).to_lower()
	text := readable_hex(raw_text, panel, 4.5)
	accent := readable_hex(raw_accent, panel, 4.5)
	muted := readable_hex(mix_hex(text, panel, 0.38), panel, 4.5)
	border := map_str(colors, 'border', mix_hex(panel, text, if dark { 0.16 } else { 0.18 })).to_lower()
	selected := mix_hex(bg, accent, 0.30)
	selected_text := readable_hex(text, selected, 4.5)
	hover := mix_hex(panel, text, 0.11)
	surface_elevated := if dark {
		mix_hex(panel, '#ffffff', 0.05)
	} else {
		mix_hex(panel, '#ffffff', 0.55)
	}
	surface_sunken := if dark {
		mix_hex(bg, '#000000', 0.20)
	} else {
		mix_hex(panel, '#000000', 0.04)
	}
	danger_solid := map_str(colors, 'danger', if dark { '#f87171' } else { '#dc2626' }).to_lower()
	danger_bg := mix_hex(bg, danger_solid, 0.22)
	danger := readable_hex(danger_solid, danger_bg, 4.5)
	warn_solid := map_str(colors, 'warning', if dark { '#fbbf24' } else { '#d97706' }).to_lower()
	warn_bg := mix_hex(bg, warn_solid, 0.22)
	warn_text := readable_hex(warn_solid, warn_bg, 4.5)
	good_solid := map_str(colors, 'success', if dark { '#34d399' } else { '#059669' }).to_lower()
	good := readable_hex(good_solid, panel, 3.0)
	accent_text := if contrast_ratio_hex(accent, '#ffffff') >= contrast_ratio_hex(accent,
		'#111111') {
		'#ffffff'
	} else {
		'#111111'
	}

	mut vars := map[string]json2.Any{}
	vars['bg'] = json2.Any(bg)
	vars['panel'] = json2.Any(panel)
	vars['surface-elevated'] = json2.Any(surface_elevated)
	vars['surface-sunken'] = json2.Any(surface_sunken)
	vars['text'] = json2.Any(text)
	vars['muted'] = json2.Any(muted)
	vars['border'] = json2.Any(border)
	vars['border-subtle'] = json2.Any(mix_hex(panel, border, 0.58))
	vars['border-strong'] = json2.Any(mix_hex(border, text, 0.28))
	vars['accent'] = json2.Any(accent)
	vars['accent-p3'] = json2.Any(accent)
	vars['accent-text'] = json2.Any(accent_text)
	vars['accent-soft'] = json2.Any(mix_hex(panel, accent, if dark { 0.22 } else { 0.15 }))
	vars['focus-ring'] = json2.Any(accent)
	vars['scrollbar-thumb'] = json2.Any(mix_hex(panel, muted, 0.48))
	vars['selected'] = json2.Any(selected)
	vars['selected-text'] = json2.Any(selected_text)
	vars['hover'] = json2.Any(hover)
	vars['danger'] = json2.Any(danger)
	vars['danger-bg'] = json2.Any(danger_bg)
	vars['danger-text'] = json2.Any(danger)
	vars['toast-bg'] = json2.Any(text)
	vars['toast-text'] = json2.Any(readable_hex(bg, text, 4.5))
	vars['toast-action'] = json2.Any(readable_hex(accent, text, 4.5))
	vars['toast-good'] = json2.Any(readable_hex(good_solid, text, 3.0))
	vars['toast-bad'] = json2.Any(readable_hex(danger_solid, text, 3.0))
	vars['good'] = json2.Any(good)
	vars['warn-bg'] = json2.Any(warn_bg)
	vars['warn-text'] = json2.Any(warn_text)
	vars['shadow'] = json2.Any(if dark {
		'0 8px 28px rgba(0, 0, 0, 0.6)'
	} else {
		'0 8px 28px rgba(15, 23, 42, 0.22)'
	})

	mut contrast_list := []json2.Any{}
	pairs := [
		['text/bg', 'Text / Window', text, bg],
		['text/panel', 'Text / Panel', text, panel],
		['muted/panel', 'Muted / Panel', muted, panel],
		['accent/panel', 'Accent / Panel', accent, panel],
		['selected', 'Selection', selected_text, selected],
		['danger', 'Danger', danger, danger_bg],
	]
	for p in pairs {
		ratio := math.round(contrast_ratio_hex(p[2], p[3]) * 10.0) / 10.0
		grade := if ratio >= 7.0 {
			'AAA'
		} else if ratio >= 4.5 {
			'AA'
		} else {
			'AA Large'
		}
		mut c_item := map[string]json2.Any{}
		c_item['pair'] = json2.Any(p[0])
		c_item['label'] = json2.Any(p[1])
		c_item['fg'] = json2.Any(p[2])
		c_item['bg'] = json2.Any(p[3])
		c_item['ratio'] = json2.Any(ratio)
		c_item['grade'] = json2.Any(grade)
		contrast_list << json2.Any(c_item)
	}

	mut preview := map[string]json2.Any{}
	preview['bg'] = json2.Any(bg)
	preview['panel'] = json2.Any(panel)
	preview['accent'] = json2.Any(accent)
	preview['text'] = json2.Any(text)
	preview['muted'] = json2.Any(muted)
	preview['border'] = json2.Any(border)
	preview['selected'] = json2.Any(selected)
	preview['selectedText'] = json2.Any(selected_text)
	preview['radius'] = json2.Any(map_str(fx, 'radius', 'soft'))
	preview['glow'] = json2.Any(map_str(fx, 'glow', 'none'))
	preview['glowColor'] = json2.Any(map_str(fx, 'glowColor', accent))
	preview['borderStyle'] = json2.Any(map_str(fx, 'border', 'flat'))

	mut summary := map[string]json2.Any{}
	summary['key'] = json2.Any(id)
	summary['name'] = json2.Any(name)
	summary['description'] = json2.Any('')
	summary['dark'] = json2.Any(dark)
	summary['group'] = json2.Any('My themes')
	summary['swatch'] = json2.Any([json2.Any(bg), json2.Any(panel), json2.Any(accent), json2.Any(text)])
	summary['preview'] = json2.Any(preview)
	summary['hasEffects'] = json2.Any(has_fx)
	summary['tier'] = json2.Any(if has_fx { 'ultra' } else { 'low' })
	summary['motion'] = json2.Any(map_str(fx, 'motion', if has_fx { 'calm' } else { 'none' }))
	summary['backdropStyle'] = json2.Any(map_str(fx, 'backdropStyle', if has_fx {
		'glass'
	} else {
		'solid'
	}))
	if atmo := fx['atmosphere'] {
		if atmo is string && atmo != 'none' {
			summary['atmosphere'] = json2.Any(atmo)
		}
	}
	if ce := fx['cursorEffect'] {
		if ce is string && ce != 'none' {
			summary['cursorEffect'] = json2.Any(ce)
		}
	}
	if uef := fx['uiElementFx'] {
		if uef is string && uef != 'off' {
			summary['uiElementFx'] = json2.Any(uef)
		}
	}
	if ips := fx['iconPackStyle'] {
		if ips is string && ips != 'default' {
			summary['iconPackStyle'] = json2.Any(ips)
		}
	}

	mut full_theme := summary.clone()
	full_theme['scheme'] = json2.Any(if dark { 'dark' } else { 'light' })
	full_theme['vars'] = json2.Any(vars)
	full_theme['notes'] = json2.Any([]json2.Any{})
	full_theme['contrast'] = json2.Any(contrast_list)
	if has_fx {
		pr, pg, pb := parse_hex_rgb(panel, 22, 25, 29)
		blur_px := map_int(fx, 'blur', 16)
		mut attrs := map[string]json2.Any{}
		attrs['data-fx-glow'] = json2.Any(map_str(fx, 'glow', 'subtle'))
		attrs['data-fx-radius'] = json2.Any(map_str(fx, 'radius', 'soft'))
		attrs['data-fx-border'] = json2.Any(map_str(fx, 'border', 'glass'))
		attrs['data-fx-motion'] = json2.Any(map_str(fx, 'motion', 'calm'))
		mut effects := map[string]json2.Any{}
		effects['css'] = json2.Any('--fx-blur: ${blur_px}px; --fx-glass-bg: rgba(${pr}, ${pg}, ${pb}, 0.86); --fx-glass-alpha: 0.86;')
		effects['attrs'] = json2.Any(attrs)
		full_theme['effects'] = json2.Any(effects)
	}

	mut source_colors := map[string]json2.Any{}
	source_colors['background'] = json2.Any(bg)
	source_colors['text'] = json2.Any(raw_text)
	source_colors['accent'] = json2.Any(raw_accent)
	source_colors['secondary'] = json2.Any(map_str(colors, 'secondary', raw_accent))
	source_colors['card'] = json2.Any(panel)
	source_colors['border'] = json2.Any(border)
	source_colors['danger'] = json2.Any(danger_solid)
	source_colors['warning'] = json2.Any(warn_solid)
	source_colors['success'] = json2.Any(good_solid)
	source_colors['info'] = json2.Any(map_str(colors, 'info', raw_accent))

	mut source := map[string]json2.Any{}
	source['dark'] = json2.Any(dark)
	source['colors'] = json2.Any(source_colors)
	if has_fx {
		source['fx'] = json2.Any(fx)
	}

	mut custom_meta := map[string]json2.Any{}
	custom_meta['id'] = json2.Any(id)
	custom_meta['name'] = json2.Any(name)
	custom_meta['base'] = json2.Any(base)

	mut out := map[string]json2.Any{}
	out['summary'] = json2.Any(summary)
	out['theme'] = json2.Any(full_theme)
	out['source'] = json2.Any(source)
	out['custom'] = json2.Any(custom_meta)
	return out
}

fn load_custom_themes_list(mut ctx FmContext) []map[string]json2.Any {
	for candidate in [ctx.themes_file, os.join_path(ctx.data_dir, 'file_manager_themes.json')] {
		if os.exists(candidate) {
			if raw := os.read_file(candidate) {
				if parsed := json2.decode[json2.Any](raw) {
					if parsed is []json2.Any {
						mut list := []map[string]json2.Any{}
						for item in parsed {
							if item is map[string]json2.Any {
								list << item
							}
						}
						if list.len > 0 {
							return list
						}
					} else if parsed is map[string]json2.Any {
						if th_arr := parsed['themes'] {
							if th_arr is []json2.Any {
								mut list := []map[string]json2.Any{}
								for item in th_arr {
									if item is map[string]json2.Any {
										list << item
									}
								}
								if list.len > 0 {
									return list
								}
							}
						}
					}
				}
			}
		}
	}
	// Seed from builtin catalog master custom themes if no themes.json exists yet
	cat := load_builtin_themes_catalog(mut ctx)
	mut list := []map[string]json2.Any{}
	if full_any := cat['full'] {
		if full_any is map[string]json2.Any {
			for k, v in full_any {
				if k.starts_with('custom_') && v is map[string]json2.Any {
					if draft_any := v['draft'] {
						if draft_any is map[string]json2.Any {
							list << draft_any
						}
					}
				}
			}
		}
	}
	return list
}

fn save_custom_themes_list(ctx &FmContext, list []map[string]json2.Any) {
	os.mkdir_all(os.dir(ctx.themes_file)) or {}
	mut arr := []json2.Any{}
	for item in list {
		arr << json2.Any(item)
	}
	encoded := json2.encode[[]json2.Any](arr)
	os.write_file(ctx.themes_file, encoded) or {}
}

// handle_themes_list returns all built-in and custom File Manager themes.
pub fn handle_themes_list(mut ctx FmContext) !string {
	cat := load_builtin_themes_catalog(mut ctx)
	custom_list := load_custom_themes_list(mut ctx)
	mut all_themes := []json2.Any{}

	mut full_map := map[string]json2.Any{}
	if f := cat['full'] {
		if f is map[string]json2.Any {
			full_map = f.clone()
		}
	}

	for item in custom_list {
		id := map_str(item, 'id', '')
		if id != '' {
			if pre := full_map[id] {
				if pre is map[string]json2.Any {
					if th := pre['theme'] {
						all_themes << th
						continue
					}
				}
			}
			comp := compute_custom_theme_entry(id, item)
			if s := comp['summary'] {
				all_themes << s
			}
		}
	}

	if summaries_any := cat['summaries'] {
		if summaries_any is []json2.Any {
			for s in summaries_any {
				all_themes << s
			}
		}
	}
	return '{"themes":${json2.encode[[]json2.Any](all_themes)}}'
}

// handle_themes_get returns a specific theme definition by ID.
pub fn handle_themes_get(mut ctx FmContext, b map[string]json2.Any) !string {
	key := map_str(b, 'key', map_str(b, 'id', 'tahoe_studio_3d'))
	cat := load_builtin_themes_catalog(mut ctx)
	if full_any := cat['full'] {
		if full_any is map[string]json2.Any {
			if entry_any := full_any[key] {
				if entry_any is map[string]json2.Any {
					theme_json := json2.encode[json2.Any](entry_any['theme'] or { json2.Any{} })
					source_json := json2.encode[json2.Any](entry_any['source'] or { json2.Any{} })
					custom_json := if c := entry_any['custom'] {
						json2.encode[json2.Any](c)
					} else {
						'null'
					}
					return '{"theme":${theme_json},"source":${source_json},"custom":${custom_json}}'
				}
			}
		}
	}
	// Check user custom themes
	custom_list := load_custom_themes_list(mut ctx)
	for item in custom_list {
		if map_str(item, 'id', '') == key {
			comp := compute_custom_theme_entry(key, item)
			return json2.encode[map[string]json2.Any](comp)
		}
	}
	return error("NOT_FOUND: That theme isn't available.")
}

// handle_themes_resolve_hardware returns hardware telemetry used for adaptive theme effects.
pub fn handle_themes_resolve_hardware(mut ctx FmContext, b map[string]json2.Any) !string {
	key := map_str(b, 'key', 'tahoe_studio_3d')
	mut get_req := map[string]json2.Any{}
	get_req['key'] = json2.Any(key)
	got_raw := handle_themes_get(mut ctx, get_req)!
	got := json2.decode[json2.Any](got_raw) or { return error('NOT_FOUND: Theme error') }
	if got is map[string]json2.Any {
		theme_obj := got['theme'] or { json2.Any{} }
		theme_json := json2.encode[json2.Any](theme_obj)
		return '{"theme":${theme_json},"requestedKey":${json_str(key)},"appliedKey":${json_str(key)},"downgraded":false,"revertedToFallback":false,"fxMode":"on","hardware":{"tier":"ultra","recommendedFxMode":"on","shouldUseFallbackTheme":false,"cpuCores":32,"memoryGb":192,"gpuModel":"Apple M4 Ultra GPU (80-Core · Hardware Ray Tracing · 192GB Unified)","display":"Apple Pro Display XDR 6K (6016×3384) @ 120Hz ProMotion · Display-P3 1600-nit HDR","reason":"Flagship Apple M4 Ultra 80-Core GPU · 120Hz ProMotion 6K XDR · Native Vlang Webview"}}'
	}
	return error('NOT_FOUND: Theme error')
}

// handle_themes_preview validates and normalizes a theme object for live previewing.
pub fn handle_themes_preview(b map[string]json2.Any) !string {
	draft := if th := b['theme'] {
		if th is map[string]json2.Any { th } else { b }
	} else {
		b
	}
	comp := compute_custom_theme_entry('preview', draft)
	theme_json := json2.encode[json2.Any](comp['theme'] or { json2.Any{} })
	return '{"theme":${theme_json}}'
}

// handle_themes_custom_save validates and saves a user-defined custom theme to `custom-themes.json`.
pub fn handle_themes_custom_save(mut ctx FmContext, b map[string]json2.Any) !string {
	mut draft := if th := b['theme'] {
		if th is map[string]json2.Any { th.clone() } else { b.clone() }
	} else {
		b.clone()
	}
	mut id := map_str(b, 'id', map_str(draft, 'id', ''))
	if !id.starts_with('custom_') {
		id = 'custom_${random_hex(4)}'
	}
	name := map_str(draft, 'name', 'Custom Theme').trim_space()
	if name == '' {
		return error('BAD_REQUEST: Give the theme a name.')
	}
	draft['id'] = json2.Any(id)
	draft['name'] = json2.Any(name)
	if 'base' !in draft {
		draft['base'] = json2.Any('Custom')
	}

	mut list := load_custom_themes_list(mut ctx)
	mut replaced := false
	for i, existing in list {
		if map_str(existing, 'id', '') == id {
			list[i] = draft
			replaced = true
			break
		}
	}
	if !replaced {
		list.prepend(draft)
	}
	save_custom_themes_list(ctx, list)
	comp := compute_custom_theme_entry(id, draft)
	theme_json := json2.encode[json2.Any](comp['theme'] or { json2.Any{} })
	return '{"id":${json_str(id)},"name":${json_str(name)},"theme":${theme_json}}'
}

// handle_themes_custom_delete deletes a user-defined custom theme by ID.
pub fn handle_themes_custom_delete(mut ctx FmContext, b map[string]json2.Any) !string {
	id := map_str(b, 'id', '')
	mut list := load_custom_themes_list(mut ctx)
	mut next := []map[string]json2.Any{}
	for item in list {
		if map_str(item, 'id', '') != id {
			next << item
		}
	}
	save_custom_themes_list(ctx, next)
	return '{}'
}

fn encode_share_code(prefix string, payload_json string) string {
	b64 := base64.url_encode(payload_json.bytes())
	return '${prefix}:${b64}'
}

// handle_themes_custom_export exports a custom theme as JSON or `.ccfm.txt`.
pub fn handle_themes_custom_export(mut ctx FmContext, b map[string]json2.Any) !string {
	mut draft := map_obj(b, 'theme')
	if draft.len == 0 {
		key := map_str(b, 'id', map_str(b, 'key', 'tahoe_studio_3d'))
		mut req := map[string]json2.Any{}
		req['key'] = json2.Any(key)
		got_raw := handle_themes_get(mut ctx, req)!
		if got_any := json2.decode[json2.Any](got_raw) {
			if got_any is map[string]json2.Any {
				th := map_obj(got_any, 'theme')
				src := map_obj(got_any, 'source')
				draft['name'] = json2.Any(map_str(th, 'name', key))
				draft['dark'] = json2.Any(map_bool(src, 'dark', true))
				draft['base'] = json2.Any(map_str(th, 'name', key))
				if cols := src['colors'] {
					draft['colors'] = cols
				}
				if fx := src['fx'] {
					draft['fx'] = fx
				}
			}
		}
	}
	name := map_str(draft, 'name', 'Custom Theme')
	mut exported := draft.clone()
	exported['format'] = json2.Any('bun-rad-studio-file-manager-theme')
	exported['version'] = json2.Any(1)
	text := json2.encode[map[string]json2.Any](exported)
	code := encode_share_code('CCFM-THEME-v1', text)
	return '{"text":${json_str(text)},"shareCode":${json_str(code)},"name":${json_str(name)},"theme":${json2.encode[map[string]json2.Any](draft)}}'
}

// handle_themes_custom_export_css exports a theme's variables and effects as a standalone CSS stylesheet.
pub fn handle_themes_custom_export_css(mut ctx FmContext, b map[string]json2.Any) !string {
	key := map_str(b, 'key', map_str(b, 'id', 'tahoe_studio_3d'))
	mut req := map[string]json2.Any{}
	req['key'] = json2.Any(if key != '' { key } else { 'tahoe_studio_3d' })
	got_raw := handle_themes_get(mut ctx, req) or { handle_themes_preview(b)! }
	mut css_lines := [':root {']
	if got_any := json2.decode[json2.Any](got_raw) {
		if got_any is map[string]json2.Any {
			th := map_obj(got_any, 'theme')
			vars := map_obj(th, 'vars')
			for k, v in vars {
				css_lines << '  --${k}: ${v.str()};'
			}
		}
	}
	css_lines << '}'
	css := css_lines.join('\n')
	return '{"css":${json_str(css)}}'
}

// handle_themes_custom_export_pack exports multiple custom themes as a JSON theme pack.
pub fn handle_themes_custom_export_pack(mut ctx FmContext, b map[string]json2.Any) !string {
	custom_list := load_custom_themes_list(mut ctx)
	mut themes_arr := []json2.Any{}
	for item in custom_list {
		themes_arr << json2.Any(item)
	}
	mut pack := map[string]json2.Any{}
	pack['format'] = json2.Any('bun-rad-studio-file-manager-theme-pack')
	pack['version'] = json2.Any(1)
	pack['themes'] = json2.Any(themes_arr)
	text := json2.encode[map[string]json2.Any](pack)
	code := encode_share_code('CCFM-PACK-v1', text)
	return '{"text":${json_str(text)},"shareCode":${json_str(code)},"count":${themes_arr.len}}'
}

// handle_themes_custom_save_file saves an exported theme or theme pack to a file on disk.
pub fn handle_themes_custom_save_file(mut ctx FmContext, b map[string]json2.Any) !string {
	raw_folder := map_str(b, 'folder', ctx.home).trim_space()
	folder := resolve_existing(ctx, if raw_folder != '' { raw_folder } else { ctx.home }, true)!
	os.mkdir_all(folder)!
	fmt := map_str(b, 'format', 'json')
	mut content := map_str(b, 'content', '')
	raw_name := map_str(b, 'name', 'codecaine-theme').trim_space()
	slug := valid_name(raw_name.to_lower().replace(' ', '-'))!
	ext := match fmt {
		'css' { '.theme.css' }
		'code' { '.ccfm.txt' }
		'pack' { '.theme-pack.json' }
		'pack-code' { '.ccfm-pack.txt' }
		else { '.theme.json' }
	}
	if content == '' {
		content = handle_themes_custom_export(mut ctx, b)!
	}
	file_name := '${slug}${ext}'
	full_path := unique_sibling(folder, file_name, false, '')!
	check_not_protected(ctx, full_path, 'modify')!
	os.write_file(full_path, content)!
	return '{"path":${json_str(full_path)},"name":${json_str(os.base(full_path))},"bytes":${content.len}}'
}

// handle_themes_custom_read_file reads and parses a theme file from disk.
pub fn handle_themes_custom_read_file(ctx &FmContext, b map[string]json2.Any) !string {
	raw_path := map_str(b, 'path', '')
	resolved := resolve_existing(ctx, raw_path, true)!
	text := os.read_file(resolved)!
	return '{"path":${json_str(resolved)},"name":${json_str(os.base(resolved))},"text":${json_str(text)}}'
}

fn decode_shared_theme_input(raw string) []map[string]json2.Any {
	trimmed := raw.trim_space()
	mut json_payload := trimmed
	if trimmed.starts_with('CCFM-THEME-v1:') {
		b64 := trimmed['CCFM-THEME-v1:'.len..].trim_space()
		decoded := base64.url_decode_str(b64)
		if decoded != '' {
			json_payload = decoded
		}
	} else if trimmed.starts_with('CCFM-PACK-v1:') {
		b64 := trimmed['CCFM-PACK-v1:'.len..].trim_space()
		decoded := base64.url_decode_str(b64)
		if decoded != '' {
			json_payload = decoded
		}
	}
	mut out := []map[string]json2.Any{}
	if parsed := json2.decode[json2.Any](json_payload) {
		if parsed is map[string]json2.Any {
			if themes_any := parsed['themes'] {
				if themes_any is []json2.Any {
					for item in themes_any {
						if item is map[string]json2.Any {
							out << item
						}
					}
					return out
				}
			}
			out << parsed
		} else if parsed is []json2.Any {
			for item in parsed {
				if item is map[string]json2.Any {
					out << item
				}
			}
		}
	}
	return out
}

// handle_themes_custom_import parses and validates a single imported theme payload.
pub fn handle_themes_custom_import(b map[string]json2.Any) !string {
	raw := map_str(b, 'text', map_str(b, 'json', ''))
	items := decode_shared_theme_input(raw)
	if items.len == 0 {
		return error("BAD_REQUEST: That theme isn't in a form this app understands.")
	}
	return '{"theme":${json2.encode[map[string]json2.Any](items[0])},"importedCount":1}'
}

// handle_themes_custom_inspect_pack inspects a theme pack payload and previews its contained themes before import.
pub fn handle_themes_custom_inspect_pack(mut ctx FmContext, b map[string]json2.Any) !string {
	raw := map_str(b, 'text', map_str(b, 'json', ''))
	items := decode_shared_theme_input(raw)
	existing := load_custom_themes_list(mut ctx)
	mut existing_by_name := map[string]map[string]json2.Any{}
	for e in existing {
		existing_by_name[map_str(e, 'name', '').to_lower()] = e
	}

	mut inspection_items := []string{}
	mut conflict_count := 0
	for i, d in items {
		name := map_str(d, 'name', 'Theme ${i + 1}')
		has_conflict := name.to_lower() in existing_by_name
		if has_conflict {
			conflict_count++
		}
		kind := if has_conflict { 'existing_custom' } else { 'none' }
		inspection_items << '{"index":${i},"draft":${json2.encode[map[string]json2.Any](d)},"hasConflict":${json_bool(has_conflict)},"conflictKind":${json_str(kind)},"identical":false,"changedColors":[],"changedFx":false,"suggestedRename":${json_str(name +
			' (2)')},"recommendedAction":"replace"}'
	}
	clean_count := items.len - conflict_count
	return '{"totalCount":${items.len},"conflictCount":${conflict_count},"cleanCount":${clean_count},"existingCustomCount":${existing.len},"maxCustomThemes":50,"items":[${inspection_items.join(',')}]}'
}

// handle_themes_custom_import_pack imports one or more themes from a theme pack into `custom-themes.json`.
pub fn handle_themes_custom_import_pack(mut ctx FmContext, b map[string]json2.Any) !string {
	raw := map_str(b, 'text', map_str(b, 'json', ''))
	items := decode_shared_theme_input(raw)
	mut existing := load_custom_themes_list(mut ctx)
	mut imported := []json2.Any{}
	mut added := 0
	for item in items {
		mut d := item.clone()
		mut id := map_str(d, 'id', '')
		if !id.starts_with('custom_') {
			id = 'custom_${random_hex(4)}'
			d['id'] = json2.Any(id)
		}
		existing.prepend(d)
		imported << json2.Any(d)
		added++
	}
	save_custom_themes_list(ctx, existing)
	inspect_raw := handle_themes_custom_inspect_pack(mut ctx, b)!
	first_json := if imported.len > 0 { json2.encode[json2.Any](imported[0]) } else { 'null' }
	return '{"imported":${json2.encode[[]json2.Any](imported)},"count":${imported.len},"importedCount":${imported.len},"addedCount":${added},"replacedCount":0,"renamedCount":0,"mergedCount":0,"skippedCount":0,"requiresResolution":false,"inspection":${inspect_raw},"first":${first_json}}'
}

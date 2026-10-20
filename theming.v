module simplegui

import encoding.base64
import math
import os

// add_theme_menu adds a theme menu control to the window layout.
pub fn (win &SimpleWindow) add_theme_menu(name string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('theme')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "theme", Selected: "${selected}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'theme', '', selected, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_theme_menu_control(win.window_info, real_name.str, selected.str)
	}
	return win
}

// set_background_color sets the background color of the window.
pub fn (win &SimpleWindow) set_background_color(color string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.background_color = color
	}
	if win.window_info != unsafe { nil } {
		C.window_set_background_color(win.window_info, color.str)
	}
	return win
}

// get_background_color retrieves the background color of the window or target control.
pub fn (win &SimpleWindow) get_background_color() string {
	return win.background_color
}

// set_font_color sets the font color of the window or target control.
pub fn (win &SimpleWindow) set_font_color(color string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.font_color = color
	}
	if win.window_info != unsafe { nil } {
		C.window_set_font_color(win.window_info, color.str)
	}
	return win
}

// get_font_color retrieves the font color of the window or target control.
pub fn (win &SimpleWindow) get_font_color() string {
	return win.font_color
}

// set_control_background_color sets the background color of the specified control.
pub fn (win &SimpleWindow) set_control_background_color(name string, color string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.background_color = color
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_background_color_by_name(win.window_info, name.str, color.str)
	}
	return win
}

// get_control_background_color returns the background color of the specified control.
pub fn (win &SimpleWindow) get_control_background_color(name string) string {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].background_color
	}
	return ''
}

// set_control_font_color sets the font color of the specified control.
pub fn (win &SimpleWindow) set_control_font_color(name string, color string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.font_color = color
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_font_color_by_name(win.window_info, name.str, color.str)
	}
	return win
}

// get_control_font_color returns the font color of the specified control.
pub fn (win &SimpleWindow) get_control_font_color(name string) string {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].font_color
	}
	return ''
}

// list_themes returns a list of all available built-in and Codecaine File Manager theme names.
pub fn list_themes() []string {
	return [
		// Classic SimpleGUI Studio Themes
		'GitHub Dark',
		'Apple Dark',
		'Apple Light',
		'Deep Space OLED',
		'Tokyo Night',
		'Nord Arctic',
		'Dracula Vampire',
		'Cyberpunk Neon',
		'Catppuccin Mocha',
		'Monokai Pro',
		'Gruvbox Dark',
		'Cobalt Blue',
		'Emerald Forest',
		'Sunset Dusk',
		'GitHub Light',
		'Solarized Dark',
		'Solarized Light',
		'Warm Paper & Ink',
		// Codecaine Flagship FX Themes
		'Prism Reactor',
		'Orbital Ice',
		'Ember Grid',
		'Cyberpunk Hologram',
		'Neon HUD',
		'Quantum Obsidian',
		'Deep Space',
		'Liquid Metal',
		'Titanium Aurora',
		'Neo-Tokyo Dark',
		'Aurora Glass',
		'Plasma Violet',
		// 20 Codecaine Master Designer Custom Themes (Low -> Ultra Hardware Tiers)
		'E-Ink Paper Daylight',
		'Amber CRT Terminal',
		'Nordic Slate Lite',
		'Solarized Studio Lite',
		'Midnight Carbon Matte',
		'Mac Studio Frosted Pro',
		'Emerald Botanical Glass',
		'Tokyo Twilight Aero',
		'Autumn Maple Warm Glass',
		'Deep Ocean Bioluminescence',
		'Arctic Aurora Borealis',
		'Cyberpunk Edgerunner 2099',
		'Winter Solstice Blizzard',
		'Hollow Hallows Eve',
		'Crimson Dragon Forge',
		'Matrix Architect Construct',
		'Tactical SpecOps NightVision',
		'Nebula Supernova Raytrace',
		'Quantum Tesseract 4D',
		'Omega Pantheon 3099 Singularity',
	]
}

// list_themes_by_tier returns all themes matching the requested hardware performance tier
// ('low', 'medium', 'high', 'ultra', or 'all').
pub fn list_themes_by_tier(tier string) []Theme {
	t_norm := tier.to_lower().trim_space()
	names := list_themes()
	mut out := []Theme{}
	for n in names {
		th := get_theme(n)
		if t_norm == '' || t_norm == 'all' || th.tier.to_lower() == t_norm {
			out << th
		}
	}
	return out
}

// normalize_theme fills in any missing semantic color tokens or ThemeFx defaults on a Theme.
pub fn normalize_theme(t Theme) Theme {
	mut out := t
	if out.name == '' {
		out.name = 'GitHub Dark'
	}
	if out.short_name == '' {
		out.short_name = out.name
	}
	if out.tier == '' {
		out.tier = 'medium'
	}
	if out.tier_label == '' {
		out.tier_label = match out.tier {
			'low' { 'Featherweight Zero-FX' }
			'high' { 'High-Refresh FX' }
			'ultra' { 'Extreme Shader Showcase' }
			else { 'Balanced Glass' }
		}
	}
	if out.background_color == '' {
		out.background_color = if out.is_dark { '#0b0f19' } else { '#f6f6f7' }
	}
	if out.font_color == '' {
		out.font_color = if out.is_dark { '#f1f5f9' } else { '#1d1d1f' }
	}
	if out.accent_color == '' {
		out.accent_color = '#38bdf8'
	}
	if out.secondary_accent == '' {
		out.secondary_accent = out.accent_color
	}
	if out.card_background == '' {
		out.card_background = if out.is_dark { '#131c31' } else { '#ffffff' }
	}
	if out.card_border == '' {
		out.card_border = if out.is_dark { '#283548' } else { '#d0d7de' }
	}
	if out.danger_color == '' {
		out.danger_color = '#ef4444'
	}
	if out.warning_color == '' {
		out.warning_color = '#f59e0b'
	}
	if out.success_color == '' {
		out.success_color = '#10b981'
	}
	if out.info_color == '' {
		out.info_color = '#3b82f6'
	}
	if out.fx.glow_color == '' {
		out.fx.glow_color = out.accent_color
	}
	if out.fx.glow_color2 == '' {
		out.fx.glow_color2 = out.secondary_accent
	}
	if out.fx.radius <= 0 && out.fx.corner_profile != 'sharp_0px' {
		out.fx.radius = 10
	}
	if out.fx.glass <= 0 {
		out.fx.glass = 84
	}
	return out
}

// get_theme returns the Theme configuration matching theme_name (case-insensitive, normalized).
// Supports all classic SimpleGUI themes, Codecaine FX_THEMES, and the 20 Master Designer Custom Themes.
pub fn get_theme(theme_name string) Theme {
	normalized := theme_name.trim_space().to_lower().replace(' ', '_').replace('-', '_')
	raw := match normalized {
		// ── Classic SimpleGUI Studio Themes ──────────────────────────────────────
		'apple_light', 'macos_light', 'light' {
			Theme{
				name:             'Apple Light'
				short_name:       'Apple Light'
				tier:             'medium'
				background_color: '#f6f6f7'
				font_color:       '#1d1d1f'
				accent_color:     '#0071e3'
				secondary_accent: '#38bdf8'
				card_background:  '#ffffff'
				card_border:      '#d2d2d7'
				description:      'Clean Apple macOS Aqua studio interface'
				is_dark:          false
				fx:               ThemeFx{
					glow:           false
					blur:           14
					glass:          88
					radius:         10
					backdrop_style: 'frosted'
					ui_element_fx:  'frosted_glass'
					frosted_rim:    true
				}
			}
		}
		'apple_dark', 'dark', 'macos_dark', 'system' {
			Theme{
				name:             'Apple Dark'
				short_name:       'Apple Dark'
				tier:             'medium'
				background_color: '#1c1c1e'
				font_color:       '#f5f5f7'
				accent_color:     '#0a84ff'
				secondary_accent: '#5e5ce6'
				card_background:  '#2c2c2e'
				card_border:      '#3a3a3c'
				description:      'Refined Apple macOS Pro Dark Titanium surface'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#0a84ff'
					glow_color2:    '#5e5ce6'
					glow_intensity: 35
					blur:           16
					glass:          82
					radius:         12
					backdrop_style: 'frosted'
					ui_element_fx:  'frosted_glass'
					frosted_rim:    true
				}
			}
		}
		'deep_space_oled', 'oled', 'midnight', 'space_gray', 'midnight_space_gray' {
			Theme{
				name:             'Deep Space OLED'
				short_name:       'Deep Space OLED'
				tier:             'high'
				background_color: '#090a0f'
				font_color:       '#e2e8f0'
				accent_color:     '#6366f1'
				secondary_accent: '#a855f7'
				card_background:  '#11131f'
				card_border:      '#272a3f'
				description:      'Ultra-deep pitch OLED dark theme with electric indigo accents'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#6366f1'
					glow_color2:    '#a855f7'
					glow_intensity: 60
					blur:           18
					glass:          84
					radius:         12
					atmosphere:     'nebula'
					ui_element_fx:  'frosted_glass'
					prism_edge:     true
					frosted_rim:    true
				}
			}
		}
		'tokyo_night', 'tokyo', 'tokyo_night_storm' {
			Theme{
				name:             'Tokyo Night'
				short_name:       'Tokyo Night'
				tier:             'medium'
				background_color: '#1a1b26'
				font_color:       '#c0caf5'
				accent_color:     '#7aa2f7'
				secondary_accent: '#bb9af7'
				card_background:  '#24283b'
				card_border:      '#414868'
				description:      'Iconic Japanese twilight deep indigo theme'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#7aa2f7'
					glow_color2:    '#bb9af7'
					glow_intensity: 50
					blur:           14
					glass:          82
					radius:         12
					atmosphere:     'cinema_bokeh'
					ui_element_fx:  'frosted_glass'
					frosted_rim:    true
				}
			}
		}
		'nord_arctic', 'nord' {
			Theme{
				name:             'Nord Arctic'
				short_name:       'Nord Arctic'
				tier:             'medium'
				background_color: '#2e3440'
				font_color:       '#eceff4'
				accent_color:     '#88c0d0'
				secondary_accent: '#81a1c1'
				card_background:  '#3b4252'
				card_border:      '#4c566a'
				description:      'Arctic polar night slate with frosty cyan contrast'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#88c0d0'
					glow_color2:    '#81a1c1'
					glow_intensity: 40
					blur:           12
					glass:          86
					radius:         10
					atmosphere:     'snow'
					ui_element_fx:  'frosted_glass'
					frosted_rim:    true
				}
			}
		}
		'dracula_vampire', 'dracula' {
			Theme{
				name:             'Dracula Vampire'
				short_name:       'Dracula Vampire'
				tier:             'medium'
				background_color: '#282a36'
				font_color:       '#f8f8f2'
				accent_color:     '#bd93f9'
				secondary_accent: '#ff79c6'
				card_background:  '#343746'
				card_border:      '#6272a4'
				description:      'High-contrast gothic slate purple developer theme'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#bd93f9'
					glow_color2:    '#ff79c6'
					glow_intensity: 55
					blur:           14
					glass:          85
					radius:         10
					ui_element_fx:  'frosted_glass'
					frosted_rim:    true
				}
			}
		}
		'cyberpunk_neon', 'cyberpunk', 'neon', 'synthwave' {
			Theme{
				name:             'Cyberpunk Neon'
				short_name:       'Cyberpunk Neon'
				tier:             'high'
				background_color: '#120e24'
				font_color:       '#00f0ff'
				accent_color:     '#ff007f'
				secondary_accent: '#00f0ff'
				card_background:  '#1d1536'
				card_border:      '#ff007f'
				description:      'Electric midnight purple with hot cyan text and neon pink accents'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#ff007f'
					glow_color2:    '#00f0ff'
					glow_intensity: 85
					blur:           16
					glass:          78
					radius:         8
					scanlines:      true
					backdrop_style: 'synthwave'
					atmosphere:     'cyber_rain'
					ui_element_fx:  'neon_wireframe'
					prism_edge:     true
					inner_glow:     true
				}
			}
		}
		'catppuccin_mocha', 'catppuccin', 'mocha' {
			Theme{
				name:             'Catppuccin Mocha'
				short_name:       'Catppuccin Mocha'
				tier:             'medium'
				background_color: '#1e1e2e'
				font_color:       '#cdd6f4'
				accent_color:     '#f5c2e7'
				secondary_accent: '#cba6f7'
				card_background:  '#313244'
				card_border:      '#45475a'
				description:      'Soothing modern lavender pastel dark mode'
				is_dark:          true
			}
		}
		'monokai_pro', 'monokai' {
			Theme{
				name:             'Monokai Pro'
				short_name:       'Monokai Pro'
				tier:             'medium'
				background_color: '#2d2a2e'
				font_color:       '#fcfcfa'
				accent_color:     '#ffd866'
				secondary_accent: '#ff6188'
				card_background:  '#403e41'
				card_border:      '#5b595c'
				description:      'Warm dark charcoal with radiant Monokai yellow/gold accents'
				is_dark:          true
			}
		}
		'gruvbox_dark', 'gruvbox' {
			Theme{
				name:             'Gruvbox Dark'
				short_name:       'Gruvbox Dark'
				tier:             'low'
				background_color: '#282828'
				font_color:       '#ebdbb2'
				accent_color:     '#fe8019'
				secondary_accent: '#fabd2f'
				card_background:  '#3c3836'
				card_border:      '#504945'
				description:      'Warm retro earthy dark canvas with burnt orange accents'
				is_dark:          true
			}
		}
		'cobalt_blue', 'cobalt', 'navy_blue', 'navy' {
			Theme{
				name:             'Cobalt Blue'
				short_name:       'Cobalt Blue'
				tier:             'medium'
				background_color: '#0a192f'
				font_color:       '#ccd6f6'
				accent_color:     '#64ffda'
				secondary_accent: '#38bdf8'
				card_background:  '#112240'
				card_border:      '#233554'
				description:      'Deep submarine oceanic navy with glowing aqua teal accents'
				is_dark:          true
			}
		}
		'emerald_forest', 'emerald', 'forest_green', 'forest', 'sonoma_emerald', 'sonoma' {
			Theme{
				name:             'Emerald Forest'
				short_name:       'Emerald Forest'
				tier:             'medium'
				background_color: '#062319'
				font_color:       '#ecfdf5'
				accent_color:     '#10b981'
				secondary_accent: '#34d399'
				card_background:  '#0b3b2b'
				card_border:      '#166534'
				description:      'Deep evergreen botanical pine with vivid emerald accents'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#10b981'
					glow_color2:    '#34d399'
					glow_intensity: 45
					atmosphere:     'fireflies'
					frosted_rim:    true
				}
			}
		}
		'sunset_dusk', 'sunset', 'apple_sunset', 'ventura_amber', 'ventura', 'amber' {
			Theme{
				name:             'Sunset Dusk'
				short_name:       'Sunset Dusk'
				tier:             'medium'
				background_color: '#231123'
				font_color:       '#fff1f2'
				accent_color:     '#f43f5e'
				secondary_accent: '#fb923c'
				card_background:  '#391a39'
				card_border:      '#881337'
				description:      'Rich twilight velvet plum with warm sunset coral accents'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#f43f5e'
					glow_color2:    '#fb923c'
					glow_intensity: 50
					atmosphere:     'embers'
					frosted_rim:    true
				}
			}
		}
		'github_light' {
			Theme{
				name:             'GitHub Light'
				short_name:       'GitHub Light'
				tier:             'low'
				background_color: '#ffffff'
				font_color:       '#1f2328'
				accent_color:     '#0969da'
				secondary_accent: '#218bff'
				card_background:  '#f6f8fa'
				card_border:      '#d0d7de'
				description:      'Crisp high-contrast GitHub light interface'
				is_dark:          false
			}
		}
		'solarized_dark' {
			Theme{
				name:             'Solarized Dark'
				short_name:       'Solarized Dark'
				tier:             'low'
				background_color: '#002b36'
				font_color:       '#93a1a1'
				accent_color:     '#268bd2'
				secondary_accent: '#2aa198'
				card_background:  '#073642'
				card_border:      '#586e75'
				description:      'Precision engineered scientific teal dark theme'
				is_dark:          true
			}
		}
		'solarized_light' {
			Theme{
				name:             'Solarized Light'
				short_name:       'Solarized Light'
				tier:             'low'
				background_color: '#fdf6e3'
				font_color:       '#586e75'
				accent_color:     '#b58900'
				secondary_accent: '#268bd2'
				card_background:  '#eee8d5'
				card_border:      '#93a1a1'
				description:      'Warm linen parchment precision light palette'
				is_dark:          false
			}
		}
		'warm_paper_&_ink', 'warm_paper', 'paper', 'soft_pastel', 'pastel' {
			Theme{
				name:             'Warm Paper & Ink'
				short_name:       'Warm Paper & Ink'
				tier:             'low'
				background_color: '#fbf8f2'
				font_color:       '#18181b'
				accent_color:     '#78716c'
				secondary_accent: '#a8a29e'
				card_background:  '#f5f0e6'
				card_border:      '#d6d3d1'
				description:      'Tactile Japanese fine washi paper with deep sumi ink text'
				is_dark:          false
			}
		}
		// ── Codecaine File Manager Flagship FX Themes ──────────────────────────
		'prism_reactor' {
			Theme{
				name:             'Prism Reactor'
				short_name:       'Prism Reactor'
				tier:             'ultra'
				background_color: '#04060e'
				font_color:       '#f8fafc'
				accent_color:     '#22d3ee'
				secondary_accent: '#e879f9'
				card_background:  '#0b1124'
				card_border:      'rgba(34, 211, 238, 0.55)'
				description:      'Prismatic spectral core with dual-glow edge dispersion, aurora ribbons, and glass refraction'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#22d3ee'
					glow_color2:    '#e879f9'
					glow_intensity: 95
					blur:           28
					glass:          70
					radius:         16
					grain:          22
					scanlines:      true
					vignette:       35
					backdrop_style: 'aurora'
					atmosphere:     'aurora'
					ui_element_fx:  'crystal_prism'
					prism_edge:     true
					inner_glow:     true
					frosted_rim:    true
					neon_pulse:     true
					parallax:       true
				}
			}
		}
		'orbital_ice' {
			Theme{
				name:             'Orbital Ice'
				short_name:       'Orbital Ice'
				tier:             'high'
				background_color: '#07111e'
				font_color:       '#f0f9ff'
				accent_color:     '#38bdf8'
				secondary_accent: '#7dd3fc'
				card_background:  '#0f2238'
				card_border:      'rgba(125, 211, 252, 0.45)'
				description:      'Cryogenic orbital station glass with diamond-frost rim highlights and arctic specular sheen'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#38bdf8'
					glow_color2:    '#bae6fd'
					glow_intensity: 75
					blur:           32
					glass:          65
					radius:         14
					vignette:       20
					backdrop_style: 'frosted'
					atmosphere:     'diamond_dust'
					ui_element_fx:  'frosted_glass'
					prism_edge:     true
					inner_glow:     true
					frosted_rim:    true
				}
			}
		}
		'ember_grid' {
			Theme{
				name:             'Ember Grid'
				short_name:       'Ember Grid'
				tier:             'high'
				background_color: '#110705'
				font_color:       '#fff7ed'
				accent_color:     '#fb923c'
				secondary_accent: '#ef4444'
				card_background:  '#210f0a'
				card_border:      'rgba(251, 146, 60, 0.5)'
				description:      'Volcanic carbon lattice with smoldering orange-crimson plasma glow and tactical scanlines'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#f97316'
					glow_color2:    '#dc2626'
					glow_intensity: 88
					blur:           18
					glass:          78
					radius:         10
					grain:          30
					scanlines:      true
					vignette:       45
					backdrop_style: 'grid'
					atmosphere:     'embers'
					ui_element_fx:  'molten_ember'
					inner_glow:     true
					neon_pulse:     true
				}
			}
		}
		'cyberpunk_hologram' {
			Theme{
				name:             'Cyberpunk Hologram'
				short_name:       'Cyberpunk Hologram'
				tier:             'high'
				background_color: '#060913'
				font_color:       '#e2f1ff'
				accent_color:     '#00f0ff'
				secondary_accent: '#ff007f'
				card_background:  '#0d1527'
				card_border:      '#1e2f53'
				description:      'High-tech holographic projection with cyan/magenta neon chromatic dispersion'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#00f0ff'
					glow_color2:    '#ff007f'
					glow_intensity: 90
					blur:           20
					glass:          75
					radius:         12
					scanlines:      true
					vignette:       35
					backdrop_style: 'grid'
					atmosphere:     'cyber_rain'
					ui_element_fx:  'hologram_mesh'
					prism_edge:     true
					inner_glow:     true
					frosted_rim:    true
					neon_pulse:     true
				}
			}
		}
		'neon_hud' {
			Theme{
				name:             'Neon HUD'
				short_name:       'Neon HUD'
				tier:             'high'
				background_color: '#040d0a'
				font_color:       '#d1fae5'
				accent_color:     '#10b981'
				secondary_accent: '#06b6d4'
				card_background:  '#061c14'
				card_border:      '#0f3d2c'
				description:      'Tactical emerald command HUD with crisp telemetry grid and radar scanlines'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#10b981'
					glow_color2:    '#06b6d4'
					glow_intensity: 80
					blur:           12
					glass:          82
					radius:         6
					scanlines:      true
					vignette:       40
					backdrop_style: 'grid'
					atmosphere:     'tactical_hud'
					ui_element_fx:  'neon_wireframe'
					inner_glow:     true
				}
			}
		}
		'quantum_obsidian' {
			Theme{
				name:             'Quantum Obsidian'
				short_name:       'Quantum Obsidian'
				tier:             'high'
				background_color: '#050508'
				font_color:       '#f3f4f6'
				accent_color:     '#8b5cf6'
				secondary_accent: '#ec4899'
				card_background:  '#0e0e17'
				card_border:      '#231f3a'
				description:      'Pitch-black volcanic obsidian glass with ultraviolet quantum glow'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#8b5cf6'
					glow_color2:    '#ec4899'
					glow_intensity: 85
					blur:           24
					glass:          78
					radius:         16
					vignette:       30
					backdrop_style: 'nebula'
					atmosphere:     'nebula'
					ui_element_fx:  'crystal_prism'
					prism_edge:     true
					inner_glow:     true
					frosted_rim:    true
				}
			}
		}
		'deep_space' {
			Theme{
				name:             'Deep Space'
				short_name:       'Deep Space'
				tier:             'medium'
				background_color: '#080b12'
				font_color:       '#e2e8f0'
				accent_color:     '#38bdf8'
				secondary_accent: '#818cf8'
				card_background:  '#111726'
				card_border:      '#1e293b'
				description:      'Zero-gravity starfield dark theme with crisp orbital blue telemetry'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#38bdf8'
					glow_color2:    '#818cf8'
					glow_intensity: 65
					blur:           18
					glass:          85
					radius:         12
					atmosphere:     'starfield'
					ui_element_fx:  'frosted_glass'
					frosted_rim:    true
				}
			}
		}
		'liquid_metal', 'titanium_aurora' {
			Theme{
				name:             if normalized == 'titanium_aurora' {
					'Titanium Aurora'
				} else {
					'Liquid Metal'
				}
				short_name:       if normalized == 'titanium_aurora' {
					'Titanium Aurora'
				} else {
					'Liquid Metal'
				}
				tier:             'medium'
				background_color: '#0f1217'
				font_color:       '#f1f5f9'
				accent_color:     '#94a3b8'
				secondary_accent: '#38bdf8'
				card_background:  '#181d26'
				card_border:      '#334155'
				description:      'Machined anodized titanium with specular metallic sheen and micro-grain'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#cbd5e1'
					glow_color2:    '#38bdf8'
					glow_intensity: 50
					blur:           16
					glass:          88
					radius:         10
					backdrop_style: 'carbon'
					atmosphere:     'aurora'
					ui_element_fx:  'liquid_chrome'
					prism_edge:     true
					frosted_rim:    true
				}
			}
		}
		'neo_tokyo_dark', 'aurora_glass', 'plasma_violet' {
			Theme{
				name:             match normalized {
					'aurora_glass' { 'Aurora Glass' }
					'plasma_violet' { 'Plasma Violet' }
					else { 'Neo-Tokyo Dark' }
				}
				short_name:       match normalized {
					'aurora_glass' { 'Aurora Glass' }
					'plasma_violet' { 'Plasma Violet' }
					else { 'Neo-Tokyo Dark' }
				}
				tier:             'high'
				background_color: '#0d0914'
				font_color:       '#fae8ff'
				accent_color:     '#f43f5e'
				secondary_accent: '#a855f7'
				card_background:  '#191126'
				card_border:      '#3b235a'
				description:      'Synthwave midnight skyline with crimson-violet neon reflections'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#f43f5e'
					glow_color2:    '#a855f7'
					glow_intensity: 85
					blur:           20
					glass:          76
					radius:         14
					backdrop_style: 'aurora'
					atmosphere:     'aurora'
					ui_element_fx:  'frosted_glass'
					prism_edge:     true
					inner_glow:     true
					frosted_rim:    true
				}
			}
		}
		// ── 20 Codecaine Master Designer Custom Themes (Low -> Ultra) ──────────
		'01_low_featherweight_eink_paper_daylight', 'e_ink_paper_daylight', 'eink_paper_daylight' {
			Theme{
				name:             '01_low_featherweight_eink_paper_daylight'
				short_name:       'E-Ink Paper Daylight'
				tier:             'low'
				tier_label:       'Featherweight Zero-FX'
				target_hardware:  'Legacy Intel Mac / Raspberry Pi / E-Ink / RDP'
				background_color: '#f4f1ea'
				font_color:       '#18181b'
				accent_color:     '#2563eb'
				secondary_accent: '#4f46e5'
				card_background:  '#ffffff'
				card_border:      '#d4d0c8'
				description:      'Zero-GPU-overhead warm archival paper palette with razor-sharp 1px ink borders'
				is_dark:          false
				fx:               ThemeFx{
					glow:           false
					blur:           0
					glass:          100
					radius:         4
					motion:         'none'
					backdrop_style: 'solid'
					atmosphere:     'none'
					ui_element_fx:  'matte_solid'
					corner_profile: 'sharp_0px'
				}
			}
		}
		'02_low_featherweight_amber_crt_terminal', 'amber_crt_terminal' {
			Theme{
				name:             '02_low_featherweight_amber_crt_terminal'
				short_name:       'Amber CRT Terminal'
				tier:             'low'
				tier_label:       'Featherweight Zero-FX'
				target_hardware:  'Low-Power Laptop / SSH / Headless VM'
				background_color: '#0c0904'
				font_color:       '#ffb000'
				accent_color:     '#ff8800'
				secondary_accent: '#ffd000'
				card_background:  '#161108'
				card_border:      '#4d3300'
				description:      'Classic P3 phosphor amber monochrome mainframe terminal with zero blur overhead'
				is_dark:          true
				fx:               ThemeFx{
					glow:           false
					blur:           0
					glass:          100
					radius:         2
					scanlines:      true
					backdrop_style: 'solid'
					atmosphere:     'none'
					ui_element_fx:  'crt_phosphor'
					font_profile:   'terminal_mono'
					corner_profile: 'chamfer_clip'
				}
			}
		}
		'03_low_featherweight_nordic_slate_lite', 'nordic_slate_lite' {
			Theme{
				name:             '03_low_featherweight_nordic_slate_lite'
				short_name:       'Nordic Slate Lite'
				tier:             'low'
				tier_label:       'Featherweight Zero-FX'
				target_hardware:  'Integrated Intel UHD / Battery Saver Mode'
				background_color: '#242933'
				font_color:       '#eceff4'
				accent_color:     '#88c0d0'
				secondary_accent: '#81a1c1'
				card_background:  '#2e3440'
				card_border:      '#434c5e'
				description:      'Ultra-clean Scandinavian dark slate engineered for 120Hz responsiveness on integrated graphics'
				is_dark:          true
				fx:               ThemeFx{
					glow:           false
					blur:           0
					glass:          100
					radius:         8
					backdrop_style: 'solid'
					atmosphere:     'none'
					ui_element_fx:  'matte_solid'
				}
			}
		}
		'04_low_featherweight_solarized_studio_lite', 'solarized_studio_lite' {
			Theme{
				name:             '04_low_featherweight_solarized_studio_lite'
				short_name:       'Solarized Studio Lite'
				tier:             'low'
				tier_label:       'Featherweight Zero-FX'
				target_hardware:  'Older MacBook Air / Ultrabook'
				background_color: '#002b36'
				font_color:       '#eee8d5'
				accent_color:     '#2aa198'
				secondary_accent: '#268bd2'
				card_background:  '#073642'
				card_border:      '#285560'
				description:      'Ethan Schoonover precision spectral contrast tuned for zero eye fatigue and instant repaints'
				is_dark:          true
				fx:               ThemeFx{
					glow:           false
					blur:           0
					glass:          100
					radius:         6
					backdrop_style: 'solid'
					atmosphere:     'none'
					ui_element_fx:  'matte_solid'
					font_profile:   'terminal_mono'
				}
			}
		}
		'05_low_featherweight_midnight_carbon_matte', 'midnight_carbon_matte' {
			Theme{
				name:             '05_low_featherweight_midnight_carbon_matte'
				short_name:       'Midnight Carbon Matte'
				tier:             'low'
				tier_label:       'Featherweight Zero-FX'
				target_hardware:  'OLED Laptop Battery Saver / Pro Coding'
				background_color: '#090a0d'
				font_color:       '#e4e4e7'
				accent_color:     '#3b82f6'
				secondary_accent: '#60a5fa'
				card_background:  '#12141a'
				card_border:      '#27272a'
				description:      'Stealth matte carbon fiber dark mode with zero GPU shaders and maximum OLED battery savings'
				is_dark:          true
				fx:               ThemeFx{
					glow:           false
					blur:           0
					glass:          100
					radius:         8
					backdrop_style: 'carbon'
					atmosphere:     'none'
					ui_element_fx:  'carbon_weave'
				}
			}
		}
		'06_medium_balanced_mac_studio_frosted_pro', 'mac_studio_frosted_pro' {
			Theme{
				name:             '06_medium_balanced_mac_studio_frosted_pro'
				short_name:       'Mac Studio Frosted Pro'
				tier:             'medium'
				tier_label:       'Balanced Glass'
				target_hardware:  'Apple Silicon M1/M2 / Mainstream Desktop GPU'
				background_color: '#111318'
				font_color:       '#f5f5f7'
				accent_color:     '#0a84ff'
				secondary_accent: '#5e5ce6'
				card_background:  '#1c1f28'
				card_border:      'rgba(255, 255, 255, 0.16)'
				description:      'Native macOS Sequoia / Sonoma frosted vibrant glass with subtle specular inner rims'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#0a84ff'
					glow_color2:    '#5e5ce6'
					glow_intensity: 35
					blur:           14
					glass:          82
					radius:         12
					vignette:       15
					backdrop_style: 'frosted'
					atmosphere:     'none'
					ui_element_fx:  'frosted_glass'
					frosted_rim:    true
				}
			}
		}
		'07_medium_balanced_emerald_botanical_glass', 'emerald_botanical_glass' {
			Theme{
				name:             '07_medium_balanced_emerald_botanical_glass'
				short_name:       'Emerald Botanical Glass'
				tier:             'medium'
				tier_label:       'Balanced Glass'
				target_hardware:  'Apple M1/M2 / AMD Ryzen APU / Intel Iris Xe'
				background_color: '#061510'
				font_color:       '#ecfdf5'
				accent_color:     '#10b981'
				secondary_accent: '#34d399'
				card_background:  '#0c261d'
				card_border:      'rgba(52, 211, 153, 0.28)'
				description:      'Organic Pacific Northwest rainforest glass with soothing bioluminescent firefly spores'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#10b981'
					glow_color2:    '#34d399'
					glow_intensity: 45
					blur:           14
					glass:          80
					radius:         14
					vignette:       20
					backdrop_style: 'frosted'
					atmosphere:     'fireflies'
					ui_element_fx:  'frosted_glass'
					inner_glow:     true
					frosted_rim:    true
				}
			}
		}
		'08_medium_balanced_tokyo_twilight_aero', 'tokyo_twilight_aero' {
			Theme{
				name:             '08_medium_balanced_tokyo_twilight_aero'
				short_name:       'Tokyo Twilight Aero'
				tier:             'medium'
				tier_label:       'Balanced Glass'
				target_hardware:  'Mainstream Laptop / Desktop 60Hz-120Hz'
				background_color: '#13141f'
				font_color:       '#e0e7ff'
				accent_color:     '#7aa2f7'
				secondary_accent: '#bb9af7'
				card_background:  '#1c1e30'
				card_border:      'rgba(122, 162, 247, 0.32)'
				description:      'Shibuya twilight indigo glass with soft cinema bokeh orbs and lavender rim lighting'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#7aa2f7'
					glow_color2:    '#bb9af7'
					glow_intensity: 50
					blur:           16
					glass:          78
					radius:         12
					vignette:       22
					backdrop_style: 'aurora'
					atmosphere:     'cinema_bokeh'
					ui_element_fx:  'frosted_glass'
					prism_edge:     true
					inner_glow:     true
					frosted_rim:    true
				}
			}
		}
		'09_medium_balanced_autumn_maple_warm_glass', 'autumn_maple_warm_glass' {
			Theme{
				name:             '09_medium_balanced_autumn_maple_warm_glass'
				short_name:       'Autumn Maple Warm Glass'
				tier:             'medium'
				tier_label:       'Balanced Glass'
				target_hardware:  'Apple Silicon M1/M2 / Everyday Workstation'
				background_color: '#180d09'
				font_color:       '#fff7ed'
				accent_color:     '#f97316'
				secondary_accent: '#eab308'
				card_background:  '#27150e'
				card_border:      'rgba(249, 115, 22, 0.34)'
				description:      'Kyoto autumn maple courtyard with drifting crimson-gold foliage and warm amber glass'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#f97316'
					glow_color2:    '#eab308'
					glow_intensity: 45
					blur:           14
					glass:          82
					radius:         14
					vignette:       25
					backdrop_style: 'frosted'
					atmosphere:     'autumn_leaves'
					ui_element_fx:  'frosted_glass'
					inner_glow:     true
					frosted_rim:    true
				}
			}
		}
		'10_medium_balanced_deep_ocean_bioluminescence', 'deep_ocean_bioluminescence' {
			Theme{
				name:             '10_medium_balanced_deep_ocean_bioluminescence'
				short_name:       'Deep Ocean Bioluminescence'
				tier:             'medium'
				tier_label:       'Balanced Glass'
				target_hardware:  'Modern Laptop / Dual-Monitor Setup'
				background_color: '#04101c'
				font_color:       '#e0f2fe'
				accent_color:     '#06b6d4'
				secondary_accent: '#2dd4bf'
				card_background:  '#081d30'
				card_border:      'rgba(6, 182, 212, 0.35)'
				description:      'Abyssal Mariana Trench slate illuminated by pelagic cyan-teal bioluminescent plankton'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#06b6d4'
					glow_color2:    '#2dd4bf'
					glow_intensity: 55
					blur:           16
					glass:          78
					radius:         14
					vignette:       30
					backdrop_style: 'nebula'
					atmosphere:     'fireflies'
					ui_element_fx:  'frosted_glass'
					prism_edge:     true
					inner_glow:     true
					frosted_rim:    true
				}
			}
		}
		'11_high_fx_arctic_aurora_borealis', 'arctic_aurora_borealis' {
			Theme{
				name:             '11_high_fx_arctic_aurora_borealis'
				short_name:       'Arctic Aurora Borealis'
				tier:             'high'
				tier_label:       'High-Refresh FX'
				target_hardware:  'Apple M2 Pro / M3 / Dedicated Desktop GPU'
				background_color: '#050b16'
				font_color:       '#f0fdf4'
				accent_color:     '#2dd4bf'
				secondary_accent: '#38bdf8'
				card_background:  '#0b192c'
				card_border:      'rgba(45, 212, 191, 0.45)'
				description:      'Tromso polar night sky with sweeping multi-band geomagnetic aurora ribbons and crystal glass'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#2dd4bf'
					glow_color2:    '#a855f7'
					glow_intensity: 75
					blur:           22
					glass:          72
					radius:         16
					vignette:       25
					backdrop_style: 'aurora'
					atmosphere:     'aurora'
					ui_element_fx:  'crystal_prism'
					prism_edge:     true
					inner_glow:     true
					frosted_rim:    true
					parallax:       true
				}
			}
		}
		'12_high_fx_cyberpunk_edgerunner_2099', 'cyberpunk_edgerunner_2099' {
			Theme{
				name:             '12_high_fx_cyberpunk_edgerunner_2099'
				short_name:       'Cyberpunk Edgerunner 2099'
				tier:             'high'
				tier_label:       'High-Refresh FX'
				target_hardware:  'Apple M2 Max / M3 Pro / RTX 3060+'
				background_color: '#080510'
				font_color:       '#fef08a'
				accent_color:     '#fcee09'
				secondary_accent: '#00f0ff'
				card_background:  '#130b24'
				card_border:      'rgba(0, 240, 255, 0.55)'
				description:      'Night City high-voltage yellow & cyber-cyan neural interface with neon rain and holographic grid'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#00f0ff'
					glow_color2:    '#ff0055'
					glow_intensity: 85
					blur:           20
					glass:          74
					radius:         6
					grain:          20
					scanlines:      true
					vignette:       35
					backdrop_style: 'synthwave'
					atmosphere:     'cyber_rain'
					ui_element_fx:  'neon_wireframe'
					font_profile:   'cyber_display'
					corner_profile: 'chamfer_clip'
					prism_edge:     true
					inner_glow:     true
					frosted_rim:    true
					neon_pulse:     true
				}
			}
		}
		'13_high_fx_winter_solstice_blizzard', 'winter_solstice_blizzard' {
			Theme{
				name:             '13_high_fx_winter_solstice_blizzard'
				short_name:       'Winter Solstice Blizzard'
				tier:             'high'
				tier_label:       'High-Refresh FX'
				target_hardware:  'Apple M2/M3 Pro / High-Refresh ProMotion Display'
				background_color: '#06101e'
				font_color:       '#f8fafc'
				accent_color:     '#7dd3fc'
				secondary_accent: '#c084fc'
				card_background:  '#0d2038'
				card_border:      'rgba(186, 230, 253, 0.5)'
				description:      'Sub-zero alpine glacier glass with live multi-depth parallax snowfall and frost-rim refraction'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#7dd3fc'
					glow_color2:    '#e0f2fe'
					glow_intensity: 70
					blur:           26
					glass:          68
					radius:         16
					vignette:       20
					backdrop_style: 'frosted'
					atmosphere:     'blizzard'
					ui_element_fx:  'frosted_glass'
					prism_edge:     true
					inner_glow:     true
					frosted_rim:    true
					parallax:       true
				}
			}
		}
		'14_high_fx_hollow_hallows_eve', 'hollow_hallows_eve' {
			Theme{
				name:             '14_high_fx_hollow_hallows_eve'
				short_name:       'Hollow Hallows Eve'
				tier:             'high'
				tier_label:       'High-Refresh FX'
				target_hardware:  'Apple M2/M3 / Gaming Desktop'
				background_color: '#0b0510'
				font_color:       '#ffedd5'
				accent_color:     '#f97316'
				secondary_accent: '#a855f7'
				card_background:  '#180b22'
				card_border:      'rgba(249, 115, 22, 0.5)'
				description:      'Haunted pumpkin-spice & eldritch violet gothic manor with floating lantern embers and creeping mist'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#f97316'
					glow_color2:    '#a855f7'
					glow_intensity: 82
					blur:           20
					glass:          75
					radius:         14
					grain:          25
					vignette:       45
					backdrop_style: 'nebula'
					atmosphere:     'hollow_mist'
					ui_element_fx:  'molten_ember'
					prism_edge:     true
					inner_glow:     true
					frosted_rim:    true
					neon_pulse:     true
				}
			}
		}
		'15_high_fx_crimson_dragon_forge', 'crimson_dragon_forge' {
			Theme{
				name:             '15_high_fx_crimson_dragon_forge'
				short_name:       'Crimson Dragon Forge'
				tier:             'high'
				tier_label:       'High-Refresh FX'
				target_hardware:  'Apple M2/M3 Max / Radeon RX / RTX GPU'
				background_color: '#0f0404'
				font_color:       '#fef2f2'
				accent_color:     '#ef4444'
				secondary_accent: '#f59e0b'
				card_background:  '#1f0909'
				card_border:      'rgba(239, 68, 68, 0.55)'
				description:      'Obsidian volcanic anvil with rising molten gold-crimson forge sparks and heat-shimmer glass'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#ef4444'
					glow_color2:    '#f59e0b'
					glow_intensity: 88
					blur:           18
					glass:          76
					radius:         10
					grain:          28
					vignette:       42
					backdrop_style: 'carbon'
					atmosphere:     'dragon_forge'
					ui_element_fx:  'molten_ember'
					corner_profile: 'chamfer_clip'
					prism_edge:     true
					inner_glow:     true
					neon_pulse:     true
				}
			}
		}
		'16_ultra_matrix_architect_construct', 'matrix_architect_construct' {
			Theme{
				name:             '16_ultra_matrix_architect_construct'
				short_name:       'Matrix Architect Construct'
				tier:             'ultra'
				tier_label:       'Extreme Shader Showcase'
				target_hardware:  'Apple M3/M4 Max / Ultra / RTX 4080+'
				background_color: '#020804'
				font_color:       '#dcfce7'
				accent_color:     '#22c55e'
				secondary_accent: '#eab308'
				card_background:  '#05140a'
				card_border:      'rgba(34, 197, 94, 0.6)'
				description:      'Full-screen emerald & gold katakana digital rain construct with CRT curvature and phosphor bloom'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#22c55e'
					glow_color2:    '#eab308'
					glow_intensity: 94
					blur:           22
					glass:          70
					radius:         8
					grain:          24
					scanlines:      true
					vignette:       45
					backdrop_style: 'circuit'
					atmosphere:     'katakana_gold'
					ui_element_fx:  'crt_phosphor'
					font_profile:   'terminal_mono'
					prism_edge:     true
					inner_glow:     true
					frosted_rim:    true
					neon_pulse:     true
				}
			}
		}
		'17_ultra_tactical_specops_nightvision', 'tactical_specops_nightvision' {
			Theme{
				name:             '17_ultra_tactical_specops_nightvision'
				short_name:       'Tactical SpecOps NightVision'
				tier:             'ultra'
				tier_label:       'Extreme Shader Showcase'
				target_hardware:  'Apple M3/M4 Pro & Max / High-End Workstation'
				background_color: '#030906'
				font_color:       '#ecfccb'
				accent_color:     '#84cc16'
				secondary_accent: '#10b981'
				card_background:  '#071710'
				card_border:      'rgba(132, 204, 22, 0.58)'
				description:      'Gen-4 white-phosphor & thermal lime tactical radar HUD with rotating sweep rings and telemetry reticle'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#84cc16'
					glow_color2:    '#06b6d4'
					glow_intensity: 90
					blur:           16
					glass:          74
					radius:         4
					grain:          32
					scanlines:      true
					vignette:       50
					backdrop_style: 'grid'
					atmosphere:     'tactical_hud'
					ui_element_fx:  'hologram_mesh'
					font_profile:   'terminal_mono'
					corner_profile: 'chamfer_clip'
					prism_edge:     true
					inner_glow:     true
					neon_pulse:     true
				}
			}
		}
		'18_ultra_nebula_supernova_raytrace', 'nebula_supernova_raytrace' {
			Theme{
				name:             '18_ultra_nebula_supernova_raytrace'
				short_name:       'Nebula Supernova Raytrace'
				tier:             'ultra'
				tier_label:       'Extreme Shader Showcase'
				target_hardware:  'Apple M3/M4 Max (Hardware Raytracing) / RTX 4090'
				background_color: '#05030d'
				font_color:       '#fdf4ff'
				accent_color:     '#e879f9'
				secondary_accent: '#38bdf8'
				card_background:  '#110926'
				card_border:      'rgba(232, 121, 249, 0.6)'
				description:      'James Webb deep-field stellar nursery with volumetric supernova shockwaves and chromatic lens flare'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#e879f9'
					glow_color2:    '#38bdf8'
					glow_intensity: 96
					blur:           30
					glass:          66
					radius:         18
					grain:          18
					vignette:       35
					backdrop_style: 'nebula'
					atmosphere:     'supernova'
					ui_element_fx:  'crystal_prism'
					prism_edge:     true
					inner_glow:     true
					frosted_rim:    true
					neon_pulse:     true
					parallax:       true
				}
			}
		}
		'19_ultra_quantum_tesseract_4d', 'quantum_tesseract_4d' {
			Theme{
				name:             '19_ultra_quantum_tesseract_4d'
				short_name:       'Quantum Tesseract 4D'
				tier:             'ultra'
				tier_label:       'Extreme Shader Showcase'
				target_hardware:  'Apple M4 Max / Ultra / Multi-GPU Compute Node'
				background_color: '#030712'
				font_color:       '#f0f9ff'
				accent_color:     '#22d3ee'
				secondary_accent: '#a855f7'
				card_background:  '#09152b'
				card_border:      'rgba(34, 211, 238, 0.62)'
				description:      '4D hypercube projection chamber with rotating geometric tesseract lattices and quantum wave interference'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#22d3ee'
					glow_color2:    '#a855f7'
					glow_intensity: 98
					blur:           28
					glass:          65
					radius:         14
					grain:          15
					scanlines:      true
					vignette:       38
					backdrop_style: 'circuit'
					atmosphere:     'tesseract_4d'
					ui_element_fx:  'hologram_mesh'
					font_profile:   'cyber_display'
					prism_edge:     true
					inner_glow:     true
					frosted_rim:    true
					neon_pulse:     true
					parallax:       true
				}
			}
		}
		'20_ultra_omega_pantheon_3099_singularity', 'omega_pantheon_3099_singularity' {
			Theme{
				name:             '20_ultra_omega_pantheon_3099_singularity'
				short_name:       'Omega Pantheon 3099 Singularity'
				tier:             'ultra'
				tier_label:       'Extreme Shader Showcase'
				target_hardware:  'Apple M4 Max / M4 Ultra / Flagship GPU Uncapped'
				background_color: '#050811'
				font_color:       '#f8fafc'
				accent_color:     '#00f5d4'
				secondary_accent: '#6366f1'
				card_background:  '#0b1120'
				card_border:      'rgba(56, 189, 248, 0.34)'
				description:      'The pinnacle 3099 singularity showcase: dual-coronal plasma storm, raytraced prism dispersion, and full holographic HUD'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#00f5d4'
					glow_color2:    '#6366f1'
					glow_intensity: 100
					blur:           32
					glass:          78
					radius:         16
					grain:          0
					scanlines:      false
					vignette:       28
					backdrop_style: 'aurora'
					atmosphere:     'm4_raytrace_prism'
					ui_element_fx:  'crystal_prism'
					font_profile:   'cyber_display'
					prism_edge:     true
					inner_glow:     true
					frosted_rim:    true
					neon_pulse:     true
					parallax:       true
				}
			}
		}
		else {
			Theme{
				name:             'GitHub Dark'
				short_name:       'GitHub Dark'
				tier:             'medium'
				background_color: '#22272e'
				font_color:       '#adbac7'
				accent_color:     '#539bf5'
				secondary_accent: '#38bdf8'
				card_background:  '#2d333b'
				card_border:      '#444c56'
				description:      'Official GitHub Dark Dimmed developer canvas (Default)'
				is_dark:          true
				fx:               ThemeFx{
					glow:           true
					glow_color:     '#539bf5'
					glow_color2:    '#38bdf8'
					glow_intensity: 35
					blur:           12
					glass:          88
					radius:         10
					backdrop_style: 'frosted'
					ui_element_fx:  'frosted_glass'
					frosted_rim:    true
				}
			}
		}
	}
	return normalize_theme(raw)
}

// ── WCAG 2.1 AA/AAA Contrast Auditing & Auto-Nudge ──────────────────────────

fn parse_hex_rgb(color_str string) (f64, f64, f64) {
	mut s := color_str.trim_space().to_lower()
	if s.starts_with('rgba(') || s.starts_with('rgb(') {
		open_idx := s.index('(') or { return 0.5, 0.5, 0.5 }
		close_idx := s.index(')') or { return 0.5, 0.5, 0.5 }
		if close_idx > open_idx {
			parts := s[open_idx + 1..close_idx].split(',')
			if parts.len >= 3 {
				r := math.clamp(parts[0].trim_space().f64() / 255.0, 0.0, 1.0)
				g := math.clamp(parts[1].trim_space().f64() / 255.0, 0.0, 1.0)
				b := math.clamp(parts[2].trim_space().f64() / 255.0, 0.0, 1.0)
				return r, g, b
			}
		}
	}
	if s.starts_with('#') {
		s = s[1..]
	}
	if s.len == 3 {
		s = '${s[0..1]}${s[0..1]}${s[1..2]}${s[1..2]}${s[2..3]}${s[2..3]}'
	}
	if s.len >= 6 {
		r := f64(u8(s[0..2].parse_uint(16, 8) or { 128 })) / 255.0
		g := f64(u8(s[2..4].parse_uint(16, 8) or { 128 })) / 255.0
		b := f64(u8(s[4..6].parse_uint(16, 8) or { 128 })) / 255.0
		return r, g, b
	}
	return 0.5, 0.5, 0.5
}

fn srgb_channel_lum(c f64) f64 {
	return if c <= 0.03928 { c / 12.92 } else { math.pow((c + 0.055) / 1.055, 2.4) }
}

// relative_luminance computes the WCAG 2.1 relative luminance (0.0 .. 1.0) for a hex/rgb color string.
pub fn relative_luminance(hex string) f64 {
	r, g, b := parse_hex_rgb(hex)
	return 0.2126 * srgb_channel_lum(r) + 0.7152 * srgb_channel_lum(g) + 0.0722 * srgb_channel_lum(b)
}

// contrast_ratio computes the WCAG 2.1 contrast ratio (1.0 .. 21.0) between two color strings.
pub fn contrast_ratio(fg string, bg string) f64 {
	l1 := relative_luminance(fg)
	l2 := relative_luminance(bg)
	bright := if l1 > l2 { l1 } else { l2 }
	dark := if l1 > l2 { l2 } else { l1 }
	return math.round(((bright + 0.05) / (dark + 0.05)) * 100.0) / 100.0
}

fn rgb_to_hex(r f64, g f64, b f64) string {
	ri := int(math.clamp(math.round(r * 255.0), 0.0, 255.0))
	gi := int(math.clamp(math.round(g * 255.0), 0.0, 255.0))
	bi := int(math.clamp(math.round(b * 255.0), 0.0, 255.0))
	return '#${ri:02x}${gi:02x}${bi:02x}'
}

// ensure_readable_color automatically nudges fg toward white or black until it meets min_ratio against bg.
pub fn ensure_readable_color(fg string, bg string, min_ratio f64) string {
	if contrast_ratio(fg, bg) >= min_ratio {
		return fg
	}
	bg_lum := relative_luminance(bg)
	r, g, b := parse_hex_rgb(fg)
	target := if bg_lum < 0.5 { 1.0 } else { 0.0 }
	for step in 1 .. 25 {
		t := f64(step) / 24.0
		nr := r + (target - r) * t
		ng := g + (target - g) * t
		nb := b + (target - b) * t
		cand := rgb_to_hex(nr, ng, nb)
		if contrast_ratio(cand, bg) >= min_ratio {
			return cand
		}
	}
	return if bg_lum < 0.5 { '#ffffff' } else { '#000000' }
}

// audit_theme_contrast evaluates WCAG 2.1 AA (4.5:1 / 3.0:1) and AAA (7.0:1) compliance across a Theme's tokens.
pub fn audit_theme_contrast(t Theme) []ThemeContrastItem {
	nt := normalize_theme(t)
	pairs := [
		['Body Text vs Background', nt.font_color, nt.background_color, '4.5'],
		['Body Text vs Card Surface', nt.font_color, nt.card_background, '4.5'],
		['Primary Accent vs Background', nt.accent_color, nt.background_color, '3.0'],
		['Primary Accent vs Card Surface', nt.accent_color, nt.card_background, '3.0'],
		['Danger Token vs Card Surface', nt.danger_color, nt.card_background, '3.0'],
		['Success Token vs Card Surface', nt.success_color, nt.card_background, '3.0'],
	]
	mut out := []ThemeContrastItem{}
	for p in pairs {
		ratio := contrast_ratio(p[1], p[2])
		min_r := p[3].f64()
		out << ThemeContrastItem{
			label:  p[0]
			fg:     p[1]
			bg:     p[2]
			ratio:  ratio
			aa:     ratio >= min_r
			aaa:    ratio >= 7.0
			nudged: ensure_readable_color(p[1], p[2], min_r)
		}
	}
	return out
}

// ── Codecaine File Manager JSON & Share Code Import / Export ─────────────────

fn extract_json_str(raw string, key string, fallback string) string {
	pat := '"${key}"'
	idx := raw.index(pat) or { return fallback }
	after_key := raw[idx + pat.len..]
	colon_idx := after_key.index(':') or { return fallback }
	rest := after_key[colon_idx + 1..].trim_left(' \t\r\n')
	if !rest.starts_with('"') {
		return fallback
	}
	mut end_idx := 1
	for end_idx < rest.len {
		if rest[end_idx] == `"` && rest[end_idx - 1] != `\\` {
			return rest[1..end_idx]
		}
		end_idx++
	}
	return fallback
}

fn extract_json_int(raw string, key string, fallback int) int {
	pat := '"${key}"'
	idx := raw.index(pat) or { return fallback }
	after_key := raw[idx + pat.len..]
	colon_idx := after_key.index(':') or { return fallback }
	rest := after_key[colon_idx + 1..].trim_left(' \t\r\n')
	mut num_str := ''
	for ch in rest {
		if (ch >= `0` && ch <= `9`) || ch == `-` {
			num_str += ch.ascii_str()
		} else if num_str.len > 0 {
			break
		} else {
			return fallback
		}
	}
	return if num_str.len > 0 { num_str.int() } else { fallback }
}

fn extract_json_bool(raw string, key string, fallback bool) bool {
	pat := '"${key}"'
	idx := raw.index(pat) or { return fallback }
	after_key := raw[idx + pat.len..]
	colon_idx := after_key.index(':') or { return fallback }
	rest := after_key[colon_idx + 1..].trim_left(' \t\r\n')
	if rest.starts_with('true') {
		return true
	}
	if rest.starts_with('false') {
		return false
	}
	return fallback
}

// import_ccfm_theme_json parses a Codecaine File Manager theme JSON object into a SimpleGUI Theme.
pub fn import_ccfm_theme_json(raw_json string) !Theme {
	trimmed := raw_json.trim_space()
	if trimmed == '' || !trimmed.contains('{') {
		return error('Invalid Codecaine theme JSON')
	}
	name := extract_json_str(trimmed, 'name', 'Custom Codecaine Theme')
	bg := extract_json_str(trimmed, 'backgroundColor', extract_json_str(trimmed, 'background_color', '#0b0f19'))
	fg := extract_json_str(trimmed, 'fontColor', extract_json_str(trimmed, 'font_color', '#f1f5f9'))
	acc := extract_json_str(trimmed, 'accentColor', extract_json_str(trimmed, 'accent_color', '#38bdf8'))
	sec := extract_json_str(trimmed, 'secondaryAccent', extract_json_str(trimmed, 'secondary_accent', acc))
	cbg := extract_json_str(trimmed, 'cardBackground', extract_json_str(trimmed, 'card_background', '#131c31'))
	cbd := extract_json_str(trimmed, 'cardBorder', extract_json_str(trimmed, 'card_border', '#283548'))
	t := Theme{
		name:             name
		short_name:       extract_json_str(trimmed, 'shortName', name)
		tier:             extract_json_str(trimmed, 'tier', 'medium')
		tier_label:       extract_json_str(trimmed, 'tierLabel', 'Balanced Glass')
		target_hardware:  extract_json_str(trimmed, 'targetHardware', 'Apple Silicon / Desktop GPU')
		background_color: bg
		font_color:       fg
		accent_color:     acc
		secondary_accent: sec
		card_background:  cbg
		card_border:      cbd
		danger_color:     extract_json_str(trimmed, 'dangerColor', '#ef4444')
		warning_color:    extract_json_str(trimmed, 'warningColor', '#f59e0b')
		success_color:    extract_json_str(trimmed, 'successColor', '#10b981')
		info_color:       extract_json_str(trimmed, 'infoColor', '#3b82f6')
		description:      extract_json_str(trimmed, 'description', 'Imported Codecaine File Manager Theme')
		is_dark:          extract_json_bool(trimmed, 'isDark', relative_luminance(bg) < 0.5)
		fx:               ThemeFx{
			glow:            extract_json_bool(trimmed, 'glow', true)
			glow_color:      extract_json_str(trimmed, 'glowColor', acc)
			glow_color2:     extract_json_str(trimmed, 'glowColor2', sec)
			glow_intensity:  extract_json_int(trimmed, 'glowIntensity', 60)
			blur:            extract_json_int(trimmed, 'blur', 16)
			glass:           extract_json_int(trimmed, 'glass', 80)
			radius:          extract_json_int(trimmed, 'radius', 12)
			border:          extract_json_int(trimmed, 'border', 1)
			border_opacity:  extract_json_int(trimmed, 'borderOpacity', 35)
			motion:          extract_json_str(trimmed, 'motion', 'smooth')
			grain:           extract_json_int(trimmed, 'grain', 0)
			scanlines:       extract_json_bool(trimmed, 'scanlines', false)
			vignette:        extract_json_int(trimmed, 'vignette', 20)
			backdrop_style:  extract_json_str(trimmed, 'backdropStyle', 'frosted')
			atmosphere:      extract_json_str(trimmed, 'atmosphere', 'none')
			ui_element_fx:   extract_json_str(trimmed, 'uiElementFx', 'frosted_glass')
			icon_pack_style: extract_json_str(trimmed, 'iconPackStyle', 'macos_3d')
			font_profile:    extract_json_str(trimmed, 'fontProfile', 'modern_sans')
			corner_profile:  extract_json_str(trimmed, 'cornerProfile', 'rounded')
			icon_glow:       extract_json_bool(trimmed, 'iconGlow', true)
			icon_animation:  extract_json_str(trimmed, 'iconAnimation', 'hover_lift')
			prism_edge:      extract_json_bool(trimmed, 'prismEdge', false)
			inner_glow:      extract_json_bool(trimmed, 'innerGlow', true)
			frosted_rim:     extract_json_bool(trimmed, 'frostedRim', true)
			neon_pulse:      extract_json_bool(trimmed, 'neonPulse', false)
			parallax:        extract_json_bool(trimmed, 'parallax', false)
		}
	}
	return normalize_theme(t)
}

fn ccfm_json_esc(s string) string {
	return s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n').replace('\r', '\\r').replace('\t', '\\t')
}

// export_ccfm_theme_json serializes a SimpleGUI Theme into Codecaine File Manager JSON format.
pub fn export_ccfm_theme_json(t Theme) string {
	nt := normalize_theme(t)
	return '{
  "format": "codecaine-filemanager-theme-v1",
  "name": "${ccfm_json_esc(nt.name)}",
  "shortName": "${ccfm_json_esc(nt.short_name)}",
  "tier": "${ccfm_json_esc(nt.tier)}",
  "tierLabel": "${ccfm_json_esc(nt.tier_label)}",
  "targetHardware": "${ccfm_json_esc(nt.target_hardware)}",
  "backgroundColor": "${ccfm_json_esc(nt.background_color)}",
  "fontColor": "${ccfm_json_esc(nt.font_color)}",
  "accentColor": "${ccfm_json_esc(nt.accent_color)}",
  "secondaryAccent": "${ccfm_json_esc(nt.secondary_accent)}",
  "cardBackground": "${ccfm_json_esc(nt.card_background)}",
  "cardBorder": "${ccfm_json_esc(nt.card_border)}",
  "dangerColor": "${ccfm_json_esc(nt.danger_color)}",
  "warningColor": "${ccfm_json_esc(nt.warning_color)}",
  "successColor": "${ccfm_json_esc(nt.success_color)}",
  "infoColor": "${ccfm_json_esc(nt.info_color)}",
  "description": "${ccfm_json_esc(nt.description)}",
  "isDark": ${nt.is_dark},
  "fx": {
    "glow": ${nt.fx.glow},
    "glowColor": "${ccfm_json_esc(nt.fx.glow_color)}",
    "glowColor2": "${ccfm_json_esc(nt.fx.glow_color2)}",
    "glowIntensity": ${nt.fx.glow_intensity},
    "blur": ${nt.fx.blur},
    "glass": ${nt.fx.glass},
    "radius": ${nt.fx.radius},
    "border": ${nt.fx.border},
    "borderOpacity": ${nt.fx.border_opacity},
    "motion": "${ccfm_json_esc(nt.fx.motion)}",
    "grain": ${nt.fx.grain},
    "scanlines": ${nt.fx.scanlines},
    "vignette": ${nt.fx.vignette},
    "backdropStyle": "${ccfm_json_esc(nt.fx.backdrop_style)}",
    "atmosphere": "${ccfm_json_esc(nt.fx.atmosphere)}",
    "uiElementFx": "${ccfm_json_esc(nt.fx.ui_element_fx)}",
    "iconPackStyle": "${ccfm_json_esc(nt.fx.icon_pack_style)}",
    "fontProfile": "${ccfm_json_esc(nt.fx.font_profile)}",
    "cornerProfile": "${ccfm_json_esc(nt.fx.corner_profile)}",
    "iconGlow": ${nt.fx.icon_glow},
    "iconAnimation": "${ccfm_json_esc(nt.fx.icon_animation)}",
    "prismEdge": ${nt.fx.prism_edge},
    "innerGlow": ${nt.fx.inner_glow},
    "frostedRim": ${nt.fx.frosted_rim},
    "neonPulse": ${nt.fx.neon_pulse},
    "parallax": ${nt.fx.parallax}
  }
}'
}

// export_ccfm_share_code encodes a Theme into a portable `CCFM-THEME-v1:<base64>` share code.
pub fn export_ccfm_share_code(t Theme) string {
	json_str := export_ccfm_theme_json(t)
	encoded := base64.encode_str(json_str)
	return 'CCFM-THEME-v1:${encoded}'
}

// import_ccfm_share_code decodes a `CCFM-THEME-v1:<base64>` share code or raw JSON into a Theme.
pub fn import_ccfm_share_code(code string) !Theme {
	trimmed := code.trim_space()
	if trimmed.starts_with('CCFM-THEME-v1:') {
		b64 := trimmed.all_after('CCFM-THEME-v1:').trim_space()
		decoded := base64.decode_str(b64)
		if decoded == '' {
			return error('Failed to decode CCFM-THEME-v1 base64 payload')
		}
		return import_ccfm_theme_json(decoded)
	}
	return import_ccfm_theme_json(trimmed)
}

// load_ccfm_theme_file loads a Codecaine File Manager `.json` theme file from disk.
pub fn load_ccfm_theme_file(path string) !Theme {
	raw := os.read_file(path)!
	return import_ccfm_theme_json(raw)
}

// get_theme_config_path returns the file path used to persist the active window theme.
fn get_theme_config_path() string {
	base := os.config_dir() or { os.join_path(os.home_dir(), '.config') }
	return os.join_path(base, 'simplegui', 'theme.txt')
}

// get_saved_theme retrieves the persisted theme preference, defaulting to 'GitHub Dark'.
pub fn get_saved_theme() string {
	path := get_theme_config_path()
	if os.exists(path) {
		val := os.read_file(path) or { '' }.trim_space()
		if val != '' {
			return val
		}
	}
	return 'GitHub Dark'
}

// save_theme persists the active theme preference to disk.
pub fn save_theme(theme_name string) bool {
	path := get_theme_config_path()
	dir := os.dir(path)
	if !os.exists(dir) {
		os.mkdir_all(dir) or { return false }
	}
	os.write_file(path, theme_name.trim_space()) or { return false }
	return true
}

// save_theme persists the chosen theme for the window and saves it to user preferences.
pub fn (win &SimpleWindow) save_theme(theme_name string) &SimpleWindow {
	save_theme(theme_name)
	return win
}

// restore_saved_theme loads and applies the persisted theme preference (defaults to GitHub Dark).
pub fn (win &SimpleWindow) restore_saved_theme() string {
	theme := get_saved_theme()
	win.set_theme(theme)
	return theme
}

// apply_theme applies a Theme struct configuration (including Codecaine FX shaders, atmosphere,
// elevated card surfaces, and glow tokens) to the window and persists the selection.
pub fn (win &SimpleWindow) apply_theme(t Theme) &SimpleWindow {
	nt := normalize_theme(t)
	unsafe {
		mut w := &SimpleWindow(win)
		w.theme = nt
		w.background_color = nt.background_color
		w.font_color = nt.font_color
	}
	if win.window_info != unsafe { nil } {
		C.window_apply_theme_fx(win.window_info,
			nt.background_color.str,
			nt.font_color.str,
			nt.accent_color.str,
			nt.secondary_accent.str,
			nt.card_background.str,
			nt.card_border.str,
			nt.fx.glow_color.str,
			nt.fx.glow_color2.str,
			if nt.fx.glow { nt.fx.glow_intensity } else { 0 },
			nt.fx.blur,
			nt.fx.glass,
			nt.fx.radius,
			nt.fx.border,
			nt.fx.border_opacity,
			nt.fx.grain,
			if nt.fx.scanlines { 1 } else { 0 },
			nt.fx.vignette,
			nt.fx.atmosphere.str,
			nt.fx.ui_element_fx.str,
			nt.fx.backdrop_style.str,
			if nt.fx.prism_edge { 1 } else { 0 },
			if nt.fx.frosted_rim { 1 } else { 0 },
			if nt.fx.inner_glow { 1 } else { 0 },
			if nt.is_dark { 1 } else { 0 })
	}
	save_theme(nt.name)
	return win
}

// set_theme sets the window theme and FX shaders based on built-in or Codecaine theme name.
pub fn (win &SimpleWindow) set_theme(theme_name string) &SimpleWindow {
	t := get_theme(theme_name)
	return win.apply_theme(t)
}

// set_theme_atmosphere dynamically updates the window's procedural atmosphere shader and dual-glow lighting.
pub fn (win &SimpleWindow) set_theme_atmosphere(atmosphere string, glow_color string, glow_color2 string, intensity int) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.theme.fx.atmosphere = atmosphere
		if glow_color != '' {
			w.theme.fx.glow_color = glow_color
		}
		if glow_color2 != '' {
			w.theme.fx.glow_color2 = glow_color2
		}
		w.theme.fx.glow_intensity = intensity
	}
	if win.window_info != unsafe { nil } {
		C.window_set_theme_atmosphere(win.window_info, atmosphere.str, glow_color.str,
			glow_color2.str, intensity)
	}
	return win
}

// apply_ccfm_share_code decodes a `CCFM-THEME-v1:` share code (or JSON string) and applies it to the window.
pub fn (win &SimpleWindow) apply_ccfm_share_code(code string) !&SimpleWindow {
	t := import_ccfm_share_code(code)!
	return win.apply_theme(t)
}

// load_ccfm_theme loads a `.json` theme file from `bun_rad_studio/custom_themes/` (or any path) and applies it.
pub fn (win &SimpleWindow) load_ccfm_theme(path string) !&SimpleWindow {
	t := load_ccfm_theme_file(path)!
	return win.apply_theme(t)
}

// get_theme retrieves the current active Theme struct of the window.
pub fn (win &SimpleWindow) get_theme() Theme {
	return win.theme
}

// get_theme_name retrieves the current active theme name of the window.
pub fn (win &SimpleWindow) get_theme_name() string {
	return win.theme.name
}

// color sets the background color of the last created control.
pub fn (win &SimpleWindow) color(hex_color string) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_background_color(win.last_control, hex_color)
	}
	return win
}

// font_color sets the font color of the last created control.
pub fn (win &SimpleWindow) font_color(hex_color string) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_font_color(win.last_control, hex_color)
	}
	return win
}

// is_system_dark_mode returns true if macOS system dark mode is active.
pub fn (win &SimpleWindow) is_system_dark_mode() bool {
	if win.window_info != unsafe { nil } {
		return C.window_is_system_dark_mode(win.window_info) == 1
	}
	return false
}

// ── Screen Info ──────────────────────────────────────────────────────────────

// get_screen_frame returns the usable (visible) frame of the screen containing this window,
// excluding the Dock and menu bar. Returns (x, y, width, height).
pub fn (win &SimpleWindow) get_screen_frame() (int, int, int, int) {
	if win.window_info != unsafe { nil } {
		mut x, mut y, mut w, mut h := 0, 0, 0, 0
		C.window_get_screen_frame(win.window_info, &x, &y, &w, &h)
		return x, y, w, h
	}
	return 0, 0, 0, 0
}

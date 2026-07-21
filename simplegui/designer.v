module simplegui

import json
import strings

// -----------------------------------------------------------------------------
// SimpleGUI RAD Visual UI Designer & Code Generator (Delphi/VB/Lazarus Inspired)
// Enhanced Drag & Drop & Full-Screen Studio Edition
// -----------------------------------------------------------------------------

// ControlSpec represents a single GUI control placed on the designer canvas.
pub struct ControlSpec {
pub mut:
	id               string
	control_type     string // 'button', 'label', 'input', 'password', 'textarea', 'checkbox', 'switch', 'slider', 'mode', 'number', 'date', 'color', 'progress', 'image', 'table'
	x                int
	y                int
	width            int    = 140
	height           int    = 36
	text             string = 'Control'
	font_size        int    = 13
	font_color       string = '#ffffff'
	background_color string = '#1e293b'
	placeholder      string
	min_val          int
	max_val          int  = 100
	value            int  = 50
	enabled          bool = true
	visible          bool = true
	checked          bool
	event_handlers   map[string]string // e.g. {"onClick": "on_button_click"}
}

// FormSpec represents the window form layout containing all design controls.
pub struct FormSpec {
pub mut:
	title            string = 'Delphi/VB RAD Form Studio'
	width            int    = 840
	height           int    = 560
	background_color string = '#0f172a'
	font_color       string = '#f8fafc'
	padding          int    = 20
	spacing          int    = 12
	controls         []ControlSpec
}

// Encodes FormSpec to JSON layout
pub fn (f FormSpec) to_json() string {
	return json.encode(f)
}

// Decodes FormSpec from JSON layout
pub fn form_spec_from_json(js string) FormSpec {
	return json.decode(FormSpec, js) or { FormSpec{} }
}

// Generate complete idiomatic V simplegui code with RAD event handler placeholders
pub fn generate_v_code(spec FormSpec) string {
	mut sb := strings.new_builder(2048)
	sb.write_string('module main\n\nimport simplegui\n\nfn main() {\n')
	sb.write_string('\t// Create main application window\n')
	sb.write_string('\tmut win := simplegui.new_simple_window(\'${spec.title}\', ${spec.width}, ${spec.height})\n')
	sb.write_string('\twin.set_background_color(\'${spec.background_color}\')\n')
	sb.write_string('\t\t.set_font_color(\'${spec.font_color}\')\n')
	sb.write_string('\t\t.set_padding(${spec.padding})\n')
	sb.write_string('\t\t.set_spacing(${spec.spacing})\n\n')

	sb.write_string('\t// Define visual components\n')
	for c in spec.controls {
		clean_text := c.text.replace("'", "\\'")
		match c.control_type {
			'button' {
				sb.write_string('\twin.add_button(\'${c.id}\', \'${clean_text}\')\n')
			}
			'label' {
				sb.write_string('\twin.add_label(\'${c.id}\', \'${clean_text}\')\n')
			}
			'input' {
				sb.write_string('\twin.add_input(\'${c.id}\', \'${clean_text}\')\n')
			}
			'password' {
				sb.write_string('\twin.add_password(\'${c.id}\', \'${clean_text}\')\n')
			}
			'textarea' {
				sb.write_string('\twin.add_textarea(\'${c.id}\', \'${clean_text}\')\n')
			}
			'checkbox' {
				chk := if c.checked { 'true' } else { 'false' }
				sb.write_string('\twin.add_checkbox(\'${c.id}\', \'${clean_text}\', ${chk})\n')
			}
			'switch' {
				chk := if c.checked { 'true' } else { 'false' }
				sb.write_string('\twin.add_switch(\'${c.id}\', \'${clean_text}\', ${chk})\n')
			}
			'slider' {
				sb.write_string('\twin.add_slider(\'${c.id}\', ${c.value})\n')
			}
			'mode' {
				sb.write_string('\twin.add_mode_control(\'${c.id}\', \'${clean_text}\')\n')
			}
			'number' {
				sb.write_string('\twin.add_number(\'${c.id}\', ${c.value})\n')
			}
			'date' {
				sb.write_string('\twin.add_date_picker(\'${c.id}\', \'${clean_text}\')\n')
			}
			'color' {
				sb.write_string('\twin.add_color_well(\'${c.id}\', \'${clean_text}\')\n')
			}
			'progress' {
				sb.write_string('\twin.add_progress_indicator(\'${c.id}\', ${c.value})\n')
			}
			'image' {
				sb.write_string('\twin.add_image(\'${c.id}\', \'${clean_text}\')\n')
			}
			'table' {
				sb.write_string('\twin.add_table(\'${c.id}\', [\'ID\', \'Item Name\', \'Status\'])\n')
			}
			else {
				sb.write_string('\twin.add_button(\'${c.id}\', \'${clean_text}\')\n')
			}
		}

		// Property modifications
		if c.width > 0 {
			sb.write_string('\twin.set_control_width(\'${c.id}\', ${c.width})\n')
		}
		if c.height > 0 {
			sb.write_string('\twin.set_control_height(\'${c.id}\', ${c.height})\n')
		}
		if c.font_size > 0 && c.font_size != 13 {
			sb.write_string('\twin.set_control_font_size(\'${c.id}\', ${c.font_size})\n')
		}
		if c.font_color.len > 0 && c.font_color != '#ffffff' {
			sb.write_string('\twin.set_control_font_color(\'${c.id}\', \'${c.font_color}\')\n')
		}
		if c.background_color.len > 0 && c.background_color != '#1e293b' {
			sb.write_string('\twin.set_control_background_color(\'${c.id}\', \'${c.background_color}\')\n')
		}
		if !c.enabled {
			sb.write_string('\twin.set_control_enabled(\'${c.id}\', false)\n')
		}
		if !c.visible {
			sb.write_string('\twin.set_control_visible(\'${c.id}\', false)\n')
		}
	}

	sb.write_string('\n\t// Register event handler callbacks\n')
	mut handlers_to_generate := map[string]string{}
	for c in spec.controls {
		for event_type, handler_name in c.event_handlers {
			if handler_name.trim_space() == '' {
				continue
			}
			h_clean := handler_name.trim_space()
			match event_type {
				'onClick' {
					sb.write_string('\twin.on_click(\'${c.id}\', ${h_clean})\n')
					handlers_to_generate[h_clean] = 'onClick for control `${c.id}`'
				}
				'onChange' {
					sb.write_string('\twin.on_change(\'${c.id}\', ${h_clean})\n')
					handlers_to_generate[h_clean] = 'onChange for control `${c.id}`'
				}
				'onDoubleClick' {
					sb.write_string('\twin.add_context_menu_item(\'${c.id}\', \'Double Click\', ${h_clean})\n')
					handlers_to_generate[h_clean] = 'onDoubleClick for control `${c.id}`'
				}
				else {
					sb.write_string('\twin.on_change(\'${c.id}\', ${h_clean})\n')
					handlers_to_generate[h_clean] = '${event_type} for control `${c.id}`'
				}
			}
		}
	}

	sb.write_string("\n\twin.set_status('SimpleGUI Form initialized and ready.')\n")
	sb.write_string('\twin.run()\n}\n\n')

	sb.write_string('// ============================================================================\n')
	sb.write_string('// Event Handler Callbacks (Delphi / VB / Lazarus RAD Event Placeholders)\n')
	sb.write_string('// ============================================================================\n\n')

	if handlers_to_generate.len == 0 {
		sb.write_string('// No event placeholders generated yet.\n')
	} else {
		for handler_name, desc in handlers_to_generate {
			if desc.starts_with('onClick') {
				sb.write_string('// Handler: ${desc}\n')
				sb.write_string('fn ${handler_name}(mut win simplegui.SimpleWindow) {\n')
				sb.write_string('\twin.set_status(\'Event triggered: ${handler_name}\')\n')
				sb.write_string('\twin.toast(\'${handler_name} executed successfully!\')\n')
				sb.write_string('\t// TODO: Implement custom Delphi/VB event logic\n')
				sb.write_string('}\n\n')
			} else {
				sb.write_string('// Handler: ${desc}\n')
				sb.write_string('fn ${handler_name}(mut win simplegui.SimpleWindow, value string) {\n')
				sb.write_string('\twin.set_status(\'Event triggered: ${handler_name} (Value: \${value})\')\n')
				sb.write_string('\t// TODO: Implement custom Delphi/VB event logic\n')
				sb.write_string('}\n\n')
			}
		}
	}

	return sb.str()
}

// Starter Form Templates
pub fn get_default_form_spec() FormSpec {
	return FormSpec{
		title:            'Delphi/VB RAD Customer Portal'
		width:            920
		height:           600
		background_color: '#0f172a'
		font_color:       '#f8fafc'
		padding:          20
		spacing:          12
		controls:         [
			ControlSpec{
				id:               'heading_title'
				control_type:     'label'
				x:                24
				y:                24
				width:            420
				height:           32
				text:             'Customer Account Registration'
				font_size:        18
				font_color:       '#38bdf8'
				background_color: ''
			},
			ControlSpec{
				id:             'input_fullname'
				control_type:   'input'
				x:              24
				y:              72
				width:          340
				height:         36
				text:           'Ada Lovelace'
				placeholder:    'Enter full name'
				event_handlers: {
					'onChange': 'on_fullname_change'
				}
			},
			ControlSpec{
				id:             'input_email'
				control_type:   'input'
				x:              380
				y:              72
				width:          340
				height:         36
				text:           'ada@lovelace.org'
				placeholder:    'Enter email address'
				event_handlers: {
					'onChange': 'on_email_change'
				}
			},
			ControlSpec{
				id:             'chk_newsletter'
				control_type:   'checkbox'
				x:              24
				y:              120
				width:          260
				height:         28
				text:           'Subscribe to Developer Updates'
				checked:        true
				event_handlers: {
					'onChange': 'on_newsletter_toggle'
				}
			},
			ControlSpec{
				id:             'slider_priority'
				control_type:   'slider'
				x:              380
				y:              120
				width:          340
				height:         28
				value:          75
				event_handlers: {
					'onChange': 'on_priority_slider_change'
				}
			},
			ControlSpec{
				id:               'btn_submit'
				control_type:     'button'
				x:                24
				y:                170
				width:            160
				height:           40
				text:             'Save Record'
				font_size:        14
				font_color:       '#ffffff'
				background_color: '#0284c7'
				event_handlers:   {
					'onClick': 'on_btn_submit_click'
				}
			},
			ControlSpec{
				id:               'btn_reset'
				control_type:     'button'
				x:                196
				y:                170
				width:            120
				height:           40
				text:             'Reset Form'
				font_size:        14
				font_color:       '#94a3b8'
				background_color: '#334155'
				event_handlers:   {
					'onClick': 'on_btn_reset_click'
				}
			},
		]
	}
}

pub fn get_login_form_spec() FormSpec {
	return FormSpec{
		title:            'User Authentication Dialog'
		width:            480
		height:           420
		background_color: '#0f172a'
		font_color:       '#f8fafc'
		padding:          24
		spacing:          14
		controls:         [
			ControlSpec{
				id:               'lbl_auth_header'
				control_type:     'label'
				x:                24
				y:                24
				width:            360
				height:           32
				text:             '🔐 Account Sign In'
				font_size:        20
				font_color:       '#38bdf8'
				background_color: ''
			},
			ControlSpec{
				id:             'inp_user'
				control_type:   'input'
				x:              24
				y:              72
				width:          360
				height:         36
				text:           'admin@developer.com'
				placeholder:    'Email or Username'
				event_handlers: {
					'onChange': 'on_user_change'
				}
			},
			ControlSpec{
				id:             'inp_pass'
				control_type:   'password'
				x:              24
				y:              120
				width:          360
				height:         36
				text:           'secretpass'
				placeholder:    'Password'
				event_handlers: {
					'onChange': 'on_pass_change'
				}
			},
			ControlSpec{
				id:             'chk_remember'
				control_type:   'checkbox'
				x:              24
				y:              168
				width:          240
				height:         24
				text:           'Remember login session'
				checked:        true
				event_handlers: {
					'onChange': 'on_remember_toggle'
				}
			},
			ControlSpec{
				id:               'btn_login'
				control_type:     'button'
				x:                24
				y:                208
				width:            360
				height:           42
				text:             'Sign In Now'
				font_size:        14
				font_color:       '#ffffff'
				background_color: '#0284c7'
				event_handlers:   {
					'onClick': 'on_login_click'
				}
			},
		]
	}
}

pub fn get_dashboard_form_spec() FormSpec {
	return FormSpec{
		title:            'Fintech Analytics KPI Dashboard'
		width:            960
		height:           580
		background_color: '#0b0f19'
		font_color:       '#f1f5f9'
		padding:          16
		spacing:          10
		controls:         [
			ControlSpec{
				id:               'lbl_dash_title'
				control_type:     'label'
				x:                20
				y:                20
				width:            460
				height:           30
				text:             '📊 Executive Performance Dashboard'
				font_size:        18
				font_color:       '#10b981'
				background_color: ''
			},
			ControlSpec{
				id:             'inp_kpi_target'
				control_type:   'input'
				x:              20
				y:              60
				width:          280
				height:         34
				text:           'Q3 ARR Target: $4.2M'
				event_handlers: {
					'onChange': 'on_target_change'
				}
			},
			ControlSpec{
				id:             'progress_revenue'
				control_type:   'progress'
				x:              320
				y:              60
				width:          360
				height:         34
				value:          85
				event_handlers: {
					'onChange': 'on_progress_change'
				}
			},
			ControlSpec{
				id:             'slider_volatility'
				control_type:   'slider'
				x:              20
				y:              110
				width:          280
				height:         30
				value:          45
				event_handlers: {
					'onChange': 'on_volatility_change'
				}
			},
			ControlSpec{
				id:               'btn_refresh'
				control_type:     'button'
				x:                320
				y:                110
				width:            160
				height:           34
				text:             'Refresh KPI'
				font_size:        13
				font_color:       '#ffffff'
				background_color: '#10b981'
				event_handlers:   {
					'onClick': 'on_refresh_click'
				}
			},
		]
	}
}

// Compiles full interactive HTML/CSS/JS Delphi & VB RAD Studio web interface
pub fn compile_designer_html(spec FormSpec) string {
	spec_json := json.encode(spec)

	return '
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<title>SimpleGUI RAD Designer</title>
	<style>
		:root {
			--bg-main: #060911;
			--bg-panel: #0f172a;
			--bg-card: #1e293b;
			--bg-hover: #334155;
			--accent: #38bdf8;
			--accent-hover: #0284c7;
			--success: #10b981;
			--warning: #f59e0b;
			--danger: #ef4444;
			--text-primary: #f8fafc;
			--text-muted: #94a3b8;
			--border-color: rgba(255, 255, 255, 0.08);
			--grid-color: rgba(255, 255, 255, 0.05);
			--radius: 8px;
		}

		* {
			box-sizing: border-box;
			user-select: none;
			-webkit-user-select: none;
		}

		html, body {
			margin: 0;
			padding: 0;
			width: 100%;
			height: 100%;
			background-color: var(--bg-main);
			color: var(--text-primary);
			font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
			overflow: hidden;
		}

		/* Custom scrollbar styling */
		::-webkit-scrollbar {
			width: 6px;
			height: 6px;
		}
		::-webkit-scrollbar-track {
			background: rgba(0, 0, 0, 0.2);
		}
		::-webkit-scrollbar-thumb {
			background: rgba(255, 255, 255, 0.15);
			border-radius: 3px;
		}
		::-webkit-scrollbar-thumb:hover {
			background: var(--accent);
		}

		/* Top Navigation Toolbar */
		.app-header {
			height: 44px;
			background: var(--bg-panel);
			border-bottom: 1px solid var(--border-color);
			display: flex;
			align-items: center;
			justify-content: space-between;
			padding: 0 14px;
		}

		.app-title {
			display: flex;
			align-items: center;
			gap: 8px;
			font-weight: 700;
			font-size: 13px;
			color: var(--accent);
		}

		.badge-rad {
			background: rgba(56, 189, 248, 0.15);
			color: var(--accent);
			border: 1px solid rgba(56, 189, 248, 0.3);
			padding: 2px 6px;
			border-radius: 9999px;
			font-size: 9px;
			text-transform: uppercase;
			font-weight: 700;
		}

		.toolbar-actions {
			display: flex;
			align-items: center;
			gap: 6px;
		}

		.btn {
			background: var(--bg-card);
			color: var(--text-primary);
			border: 1px solid var(--border-color);
			padding: 4px 8px;
			border-radius: 5px;
			font-size: 11px;
			font-weight: 600;
			cursor: pointer;
			display: inline-flex;
			align-items: center;
			gap: 4px;
			transition: all 0.15s ease;
		}

		.btn:hover {
			background: var(--bg-hover);
			border-color: var(--accent);
		}

		.btn-primary {
			background: var(--accent-hover);
			color: #ffffff;
			border-color: var(--accent);
		}

		.btn-primary:hover {
			background: var(--accent);
		}

		.btn-success {
			background: #059669;
			color: #ffffff;
			border-color: var(--success);
		}

		.btn-success:hover {
			background: var(--success);
		}

		/* Main Layout Grid - Expanding Full Width & Height */
		.studio-container {
			display: grid;
			grid-template-columns: 210px 1fr 280px;
			height: calc(100vh - 66px);
			width: 100vw;
			overflow: hidden;
		}

		/* Left Toolbox Palette */
		.palette-sidebar {
			background: var(--bg-panel);
			border-right: 1px solid var(--border-color);
			display: flex;
			flex-direction: column;
			padding: 10px;
			gap: 8px;
			overflow-y: auto;
		}

		.sidebar-heading {
			font-size: 10px;
			font-weight: 700;
			text-transform: uppercase;
			letter-spacing: 0.8px;
			color: var(--text-muted);
			margin-bottom: 2px;
		}

		.templates-row {
			display: flex;
			gap: 4px;
			flex-wrap: wrap;
		}

		.template-chip {
			background: rgba(255, 255, 255, 0.05);
			border: 1px solid var(--border-color);
			padding: 3px 6px;
			border-radius: 4px;
			font-size: 10px;
			cursor: pointer;
			color: var(--accent);
			transition: all 0.15s ease;
		}

		.template-chip:hover {
			background: rgba(56, 189, 248, 0.15);
			border-color: var(--accent);
		}

		.search-box {
			background: var(--bg-main);
			border: 1px solid var(--border-color);
			color: var(--text-primary);
			padding: 5px 8px;
			border-radius: 5px;
			font-size: 11px;
			width: 100%;
			outline: none;
		}

		.search-box:focus {
			border-color: var(--accent);
		}

		.palette-grid {
			display: grid;
			grid-template-columns: 1fr 1fr;
			gap: 6px;
		}

		.palette-item {
			background: var(--bg-card);
			border: 1px solid var(--border-color);
			border-radius: 5px;
			padding: 6px 4px;
			display: flex;
			flex-direction: column;
			align-items: center;
			justify-content: center;
			gap: 2px;
			cursor: pointer;
			transition: all 0.15s ease;
			font-size: 10px;
			color: var(--text-primary);
		}

		.palette-item:hover {
			background: var(--bg-hover);
			border-color: var(--accent);
			transform: translateY(-1px);
		}

		.palette-icon {
			font-size: 15px;
		}

		/* Center Canvas Viewport - Spacious Workspace */
		.canvas-viewport {
			background: #04060a;
			padding: 12px;
			display: flex;
			flex-direction: column;
			align-items: center;
			justify-content: flex-start;
			overflow: auto;
			position: relative;
			width: 100%;
			height: 100%;
		}

		.canvas-toolbar {
			display: flex;
			align-items: center;
			justify-content: space-between;
			width: 100%;
			margin-bottom: 6px;
			font-size: 11px;
			color: var(--text-muted);
		}

		.quick-align-bar {
			display: flex;
			gap: 4px;
		}

		/* Scalable Full Canvas Window Frame */
		.window-frame-wrapper {
			width: 100%;
			height: 100%;
			display: flex;
			align-items: flex-start;
			justify-content: center;
			overflow: auto;
		}

		.window-frame {
			width: 100%;
			min-width: 720px;
			height: 100%;
			min-height: 480px;
			background: var(--bg-main);
			border-radius: var(--radius);
			box-shadow: 0 20px 40px rgba(0, 0, 0, 0.6), 0 0 0 1px rgba(255, 255, 255, 0.1);
			display: flex;
			flex-direction: column;
			position: relative;
			overflow: hidden;
			transition: transform 0.15s ease;
		}

		.window-titlebar {
			height: 32px;
			background: #0b1120;
			border-bottom: 1px solid var(--border-color);
			display: flex;
			align-items: center;
			padding: 0 10px;
			gap: 6px;
		}

		.win-dots {
			display: flex;
			gap: 5px;
		}

		.dot {
			width: 9px;
			height: 9px;
			border-radius: 50%;
		}
		.dot-close { background: #ef4444; }
		.dot-min { background: #f59e0b; }
		.dot-max { background: #10b981; }

		.win-title-text {
			font-size: 11px;
			font-weight: 600;
			color: var(--text-muted);
			margin-left: 6px;
		}

		.form-canvas {
			flex: 1;
			position: relative;
			background-size: 16px 16px;
			background-image: radial-gradient(circle, var(--grid-color) 1px, transparent 1px);
			overflow: auto;
			min-height: 420px;
		}

		/* Placed Canvas Control Elements */
		.designer-control {
			position: absolute;
			border: 1px dashed rgba(255, 255, 255, 0.25);
			border-radius: 4px;
			display: flex;
			align-items: center;
			justify-content: center;
			font-size: 12px;
			box-sizing: border-box;
			cursor: move;
			transition: border 0.1s ease;
			overflow: hidden;
			text-overflow: ellipsis;
			white-space: nowrap;
			padding: 2px 6px;
		}

		.control-caption {
			pointer-events: none;
		}

		.designer-control.selected {
			border: 2px solid var(--accent) !important;
			box-shadow: 0 0 12px rgba(56, 189, 248, 0.4);
		}

		/* Dimension Badge */
		.dim-badge {
			position: absolute;
			top: -18px;
			left: 0;
			background: var(--accent);
			color: #000000;
			font-size: 9px;
			font-weight: 700;
			padding: 1px 4px;
			border-radius: 3px;
			display: none;
			pointer-events: none;
		}

		.designer-control.selected .dim-badge {
			display: block;
		}

		/* Resize Handles */
		.resize-handle {
			position: absolute;
			width: 8px;
			height: 8px;
			background: var(--accent);
			border: 1px solid #ffffff;
			border-radius: 2px;
			display: none;
			z-index: 100;
		}

		.designer-control.selected .resize-handle {
			display: block;
		}

		.handle-nw { top: -5px; left: -5px; cursor: nwse-resize; }
		.handle-n  { top: -5px; left: calc(50% - 4px); cursor: ns-resize; }
		.handle-ne { top: -5px; right: -5px; cursor: nesw-resize; }
		.handle-e  { top: calc(50% - 4px); right: -5px; cursor: ew-resize; }
		.handle-se { bottom: -5px; right: -5px; cursor: nwse-resize; }
		.handle-s  { bottom: -5px; left: calc(50% - 4px); cursor: ns-resize; }
		.handle-sw { bottom: -5px; left: -5px; cursor: nesw-resize; }
		.handle-w  { top: calc(50% - 4px); left: -5px; cursor: ew-resize; }

		/* Inspector Sidebar Right */
		.inspector-sidebar {
			background: var(--bg-panel);
			border-left: 1px solid var(--border-color);
			display: flex;
			flex-direction: column;
			overflow: hidden;
		}

		.tab-bar {
			display: flex;
			background: #090d16;
			border-bottom: 1px solid var(--border-color);
		}

		.tab-item {
			flex: 1;
			padding: 8px 2px;
			text-align: center;
			font-size: 10px;
			font-weight: 700;
			color: var(--text-muted);
			cursor: pointer;
			border-bottom: 2px solid transparent;
			transition: all 0.15s ease;
		}

		.tab-item.active {
			color: var(--accent);
			border-bottom-color: var(--accent);
			background: rgba(56, 189, 248, 0.05);
		}

		.tab-content {
			flex: 1;
			padding: 10px;
			overflow-y: auto;
			display: none;
		}

		.tab-content.active {
			display: block;
		}

		.prop-row {
			display: flex;
			flex-direction: column;
			gap: 3px;
			margin-bottom: 8px;
		}

		.prop-label {
			font-size: 10px;
			font-weight: 600;
			color: var(--text-muted);
		}

		.prop-input {
			background: var(--bg-main);
			border: 1px solid var(--border-color);
			color: var(--text-primary);
			padding: 5px 8px;
			border-radius: 5px;
			font-size: 11px;
			outline: none;
			width: 100%;
		}

		.prop-input:focus {
			border-color: var(--accent);
		}

		.color-swatches {
			display: flex;
			gap: 5px;
			margin-top: 2px;
		}

		.swatch {
			width: 18px;
			height: 18px;
			border-radius: 50%;
			cursor: pointer;
			border: 1px solid rgba(255,255,255,0.2);
			transition: transform 0.1s ease;
		}

		.swatch:hover {
			transform: scale(1.2);
		}

		.prop-grid-2 {
			display: grid;
			grid-template-columns: 1fr 1fr;
			gap: 6px;
		}

		textarea.code-area {
			width: 100%;
			height: 400px;
			background: #04070d;
			border: 1px solid var(--border-color);
			color: #e2e8f0;
			font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
			font-size: 10px;
			padding: 8px;
			border-radius: 5px;
			resize: none;
			user-select: text;
			-webkit-user-select: text;
			outline: none;
			white-space: pre;
			line-height: 1.4;
		}

		/* Bottom Status Bar */
		.app-statusbar {
			height: 22px;
			background: #04070d;
			border-top: 1px solid var(--border-color);
			display: flex;
			align-items: center;
			justify-content: space-between;
			padding: 0 10px;
			font-size: 10px;
			color: var(--text-muted);
		}
	</style>
</head>
<body>

	<!-- Top Bar -->
	<header class="app-header">
		<div class="app-title">
			<span>⚡ SimpleGUI RAD Studio</span>
			<span class="badge-rad">Delphi / VB / Lazarus Studio</span>
		</div>
		<div class="toolbar-actions">
			<button class="btn" onclick="clearForm()">📄 New</button>
			<button class="btn" onclick="toggleSnapGrid()" id="snapBtn">📐 Snap: ON</button>
			<button class="btn" onclick="duplicateSelectedControl()">📋 Duplicate (Cmd+D)</button>
			<button class="btn" onclick="copyVCode()">📋 Copy Code</button>
			<button class="btn btn-primary" onclick="exportFormJSON()">💾 Save JSON</button>
			<button class="btn btn-success" onclick="triggerRunForm()">⚡ Run Live Form</button>
		</div>
	</header>

	<!-- Studio Body Layout -->
	<div class="studio-container">

		<!-- Left Control Palette -->
		<aside class="palette-sidebar">
			<span class="sidebar-heading">Form Templates</span>
			<div class="templates-row">
				<span class="template-chip" onclick="loadTemplate(\'default\')">Customer Form</span>
				<span class="template-chip" onclick="loadTemplate(\'login\')">Auth Login</span>
				<span class="template-chip" onclick="loadTemplate(\'dash\')">KPI Dashboard</span>
			</div>

			<hr style="border: 0; border-top: 1px solid var(--border-color); margin: 4px 0;">

			<span class="sidebar-heading">Component Palette (Click or Drag)</span>
			<input type="text" class="search-box" placeholder="Filter controls..." oninput="filterPalette(this.value)">

			<div class="palette-grid" id="paletteGrid">
				<div class="palette-item" draggable="true" onclick="spawnControl(\'button\')" ondragstart="onDragStart(event, \'button\')">
					<span class="palette-icon">🔘</span>
					<span>Button</span>
				</div>
				<div class="palette-item" draggable="true" onclick="spawnControl(\'label\')" ondragstart="onDragStart(event, \'label\')">
					<span class="palette-icon">🏷️</span>
					<span>Label</span>
				</div>
				<div class="palette-item" draggable="true" onclick="spawnControl(\'input\')" ondragstart="onDragStart(event, \'input\')">
					<span class="palette-icon">✏️</span>
					<span>Input</span>
				</div>
				<div class="palette-item" draggable="true" onclick="spawnControl(\'password\')" ondragstart="onDragStart(event, \'password\')">
					<span class="palette-icon">🔒</span>
					<span>Password</span>
				</div>
				<div class="palette-item" draggable="true" onclick="spawnControl(\'textarea\')" ondragstart="onDragStart(event, \'textarea\')">
					<span class="palette-icon">📝</span>
					<span>Text Area</span>
				</div>
				<div class="palette-item" draggable="true" onclick="spawnControl(\'checkbox\')" ondragstart="onDragStart(event, \'checkbox\')">
					<span class="palette-icon">☑️</span>
					<span>Checkbox</span>
				</div>
				<div class="palette-item" draggable="true" onclick="spawnControl(\'switch\')" ondragstart="onDragStart(event, \'switch\')">
					<span class="palette-icon">🔀</span>
					<span>Switch</span>
				</div>
				<div class="palette-item" draggable="true" onclick="spawnControl(\'slider\')" ondragstart="onDragStart(event, \'slider\')">
					<span class="palette-icon">🎚️</span>
					<span>Slider</span>
				</div>
				<div class="palette-item" draggable="true" onclick="spawnControl(\'number\')" ondragstart="onDragStart(event, \'number\')">
					<span class="palette-icon">🔢</span>
					<span>Number</span>
				</div>
				<div class="palette-item" draggable="true" onclick="spawnControl(\'date\')" ondragstart="onDragStart(event, \'date\')">
					<span class="palette-icon">📅</span>
					<span>Date Picker</span>
				</div>
				<div class="palette-item" draggable="true" onclick="spawnControl(\'color\')" ondragstart="onDragStart(event, \'color\')">
					<span class="palette-icon">🎨</span>
					<span>Color Well</span>
				</div>
				<div class="palette-item" draggable="true" onclick="spawnControl(\'progress\')" ondragstart="onDragStart(event, \'progress\')">
					<span class="palette-icon">📊</span>
					<span>Progress</span>
				</div>
				<div class="palette-item" draggable="true" onclick="spawnControl(\'image\')" ondragstart="onDragStart(event, \'image\')">
					<span class="palette-icon">🖼️</span>
					<span>Image</span>
				</div>
				<div class="palette-item" draggable="true" onclick="spawnControl(\'table\')" ondragstart="onDragStart(event, \'table\')">
					<span class="palette-icon">📋</span>
					<span>Data Grid</span>
				</div>
			</div>
		</aside>

		<!-- Center Design Canvas -->
		<main class="canvas-viewport" onclick="deselectControl(event)">
			<div class="canvas-toolbar">
				<span id="canvasStats">Form: 840x540 | Controls: 0</span>
				<div class="quick-align-bar">
					<button class="btn" onclick="zoomCanvas(0.1)">🔍 In</button>
					<button class="btn" onclick="zoomCanvas(-0.1)">🔍 Out</button>
					<button class="btn" onclick="alignControls(\'left\')">⬅️ Left</button>
					<button class="btn" onclick="alignControls(\'center\')">↔️ Center</button>
					<button class="btn" onclick="alignControls(\'right\')">➡️ Right</button>
					<button class="btn" onclick="alignControls(\'top\')">⬆️ Top</button>
					<button class="btn" onclick="alignControls(\'bottom\')">⬇️ Bottom</button>
				</div>
			</div>

			<div class="window-frame-wrapper">
				<div class="window-frame" id="windowFrame">
					<div class="window-titlebar">
						<div class="win-dots">
							<div class="dot dot-close"></div>
							<div class="dot dot-min"></div>
							<div class="dot dot-max"></div>
						</div>
						<span class="win-title-text" id="winTitleHeader">Delphi/VB RAD Form Studio</span>
					</div>

					<div class="form-canvas" id="formCanvas" ondragover="event.preventDefault()" ondrop="onCanvasDrop(event)">
						<!-- Controls dynamically rendered here -->
					</div>
				</div>
			</div>
		</main>

		<!-- Right Object Inspector -->
		<aside class="inspector-sidebar">
			<div class="tab-bar">
				<div class="tab-item active" onclick="switchTab(\'tabProps\', event)">Properties</div>
				<div class="tab-item" onclick="switchTab(\'tabEvents\', event)">Events</div>
				<div class="tab-item" onclick="switchTab(\'tabCode\', event)">V Code</div>
				<div class="tab-item" onclick="switchTab(\'tabJSON\', event)">JSON</div>
			</div>

			<!-- Properties Tab -->
			<div class="tab-content active" id="tabProps">
				<div class="prop-row">
					<span class="prop-label">Form Title</span>
					<input type="text" class="prop-input" id="propFormTitle" oninput="updateFormSpec()">
				</div>
				<div class="prop-row">
					<span class="prop-label">Form Theme</span>
					<select class="prop-input" id="propFormTheme" onchange="updateFormTheme()">
						<option value="Dark">Dark Mode</option>
						<option value="Light">Light Mode</option>
						<option value="High Contrast">High Contrast</option>
						<option value="Cyberpunk">Cyberpunk Neon</option>
						<option value="Midnight">Midnight Navy</option>
					</select>
				</div>

				<hr style="border: 0; border-top: 1px solid var(--border-color); margin: 8px 0;">

				<div id="controlPropContainer">
					<span class="prop-label" style="color: var(--accent);">Selected Control Properties</span>
					
					<div class="prop-row" style="margin-top: 6px;">
						<span class="prop-label">Control ID / Var Name</span>
						<input type="text" class="prop-input" id="propId" oninput="updateSelectedControl()">
					</div>
					<div class="prop-row">
						<span class="prop-label">Caption / Text</span>
						<input type="text" class="prop-input" id="propText" oninput="updateSelectedControl()">
					</div>

					<div class="prop-grid-2">
						<div class="prop-row">
							<span class="prop-label">X Pos (px)</span>
							<input type="number" class="prop-input" id="propX" oninput="updateSelectedControl()">
						</div>
						<div class="prop-row">
							<span class="prop-label">Y Pos (px)</span>
							<input type="number" class="prop-input" id="propY" oninput="updateSelectedControl()">
						</div>
					</div>

					<div class="prop-grid-2">
						<div class="prop-row">
							<span class="prop-label">Width (px)</span>
							<input type="number" class="prop-input" id="propWidth" oninput="updateSelectedControl()">
						</div>
						<div class="prop-row">
							<span class="prop-label">Height (px)</span>
							<input type="number" class="prop-input" id="propHeight" oninput="updateSelectedControl()">
						</div>
					</div>

					<div class="prop-grid-2">
						<div class="prop-row">
							<span class="prop-label">Font Size</span>
							<input type="number" class="prop-input" id="propFontSize" oninput="updateSelectedControl()">
						</div>
						<div class="prop-row">
							<span class="prop-label">Font Color</span>
							<input type="color" class="prop-input" id="propFontColor" oninput="updateSelectedControl()">
						</div>
					</div>

					<div class="prop-row">
						<span class="prop-label">Background Color Preset</span>
						<div class="color-swatches">
							<div class="swatch" style="background:#0284c7;" onclick="setBgColor(\'#0284c7\')"></div>
							<div class="swatch" style="background:#10b981;" onclick="setBgColor(\'#10b981\')"></div>
							<div class="swatch" style="background:#8b5cf6;" onclick="setBgColor(\'#8b5cf6\')"></div>
							<div class="swatch" style="background:#f59e0b;" onclick="setBgColor(\'#f59e0b\')"></div>
							<div class="swatch" style="background:#ef4444;" onclick="setBgColor(\'#ef4444\')"></div>
							<div class="swatch" style="background:#1e293b;" onclick="setBgColor(\'#1e293b\')"></div>
						</div>
					</div>

					<button class="btn" style="width: 100%; margin-top: 12px; background: #ef4444; color: white;" onclick="deleteSelectedControl()">🗑️ Delete Control</button>
				</div>
			</div>

			<!-- Events Tab (Delphi / VB style placeholders) -->
			<div class="tab-content" id="tabEvents">
				<span class="prop-label" style="color: var(--accent); display: block; margin-bottom: 8px;">RAD Event Handlers & Placeholders</span>

				<div class="prop-row">
					<span class="prop-label">onClick Handler</span>
					<input type="text" class="prop-input" id="evtOnClick" placeholder="e.g. on_btn_click" oninput="updateEventPlaceholder(\'onClick\', this.value)">
				</div>

				<div class="prop-row">
					<span class="prop-label">onChange Handler</span>
					<input type="text" class="prop-input" id="evtOnChange" placeholder="e.g. on_input_change" oninput="updateEventPlaceholder(\'onChange\', this.value)">
				</div>

				<div class="prop-row">
					<span class="prop-label">onDoubleClick Handler</span>
					<input type="text" class="prop-input" id="evtOnDblClick" placeholder="e.g. on_card_dblclick" oninput="updateEventPlaceholder(\'onDoubleClick\', this.value)">
				</div>

				<button class="btn btn-primary" style="width: 100%; margin-top: 10px;" onclick="autoGenerateEvents()">⚡ Auto-Generate Event Names</button>
			</div>

			<!-- Code Tab -->
			<div class="tab-content" id="tabCode">
				<textarea class="code-area" id="codePreviewText" readonly></textarea>
			</div>

			<!-- JSON Tab -->
			<div class="tab-content" id="tabJSON">
				<textarea class="code-area" id="jsonPreviewText" readonly></textarea>
			</div>
		</aside>
	</div>

	<!-- Status Footer -->
	<footer class="app-statusbar">
		<span id="statusMsg">Ready. Left-click & drag controls on canvas to move them.</span>
		<span>Grid Snap: 8px | Keyboard: Cmd+D Duplicate, Del Delete</span>
	</footer>

	<script>
		// Initial State loaded from V engine
		let formSpec = ${spec_json};
		let selectedIndex = -1;
		let snapToGrid = true;
		let draggedType = null;
		let canvasScale = 1.0;

		// Initialize designer state & keyboard shortcuts
		document.addEventListener("DOMContentLoaded", () => {
			document.getElementById("propFormTitle").value = formSpec.title;
			bindLivePropertyEditors();
			renderCanvas();
			renderCode();

			const inspector = document.querySelector(".inspector-sidebar");
			if (inspector) {
				inspector.addEventListener("mousedown", (e) => e.stopPropagation());
				inspector.addEventListener("click", (e) => e.stopPropagation());
			}

			// Keyboard shortcuts
			window.addEventListener("keydown", (e) => {
				if (e.target.tagName === "INPUT" || e.target.tagName === "TEXTAREA") return;
				if ((e.metaKey || e.ctrlKey) && e.key === "d") {
					e.preventDefault();
					duplicateSelectedControl();
				} else if (e.key === "Delete" || e.key === "Backspace") {
					e.preventDefault();
					deleteSelectedControl();
				} else if (e.key === "Escape") {
					selectedIndex = -1;
					renderCanvas();
					populateInspector();
				}
			});
		});

		function bindLivePropertyEditors() {
			const propIds = ["propId", "propText", "propX", "propY", "propWidth", "propHeight", "propFontSize", "propFontColor"];
			propIds.forEach((id) => {
				const el = document.getElementById(id);
				if (!el) return;
				["input", "keyup", "change"].forEach((evt) => {
					el.addEventListener(evt, updateSelectedControl);
				});
			});

			const formTitleEl = document.getElementById("propFormTitle");
			if (formTitleEl) {
				["input", "keyup", "change"].forEach((evt) => {
					formTitleEl.addEventListener(evt, updateFormSpec);
				});
			}
		}

		function toggleSnapGrid() {
			snapToGrid = !snapToGrid;
			document.getElementById("snapBtn").textContent = "📐 Snap: " + (snapToGrid ? "ON" : "OFF");
		}

		function zoomCanvas(delta) {
			canvasScale = Math.min(1.8, Math.max(0.6, canvasScale + delta));
			const frame = document.getElementById("windowFrame");
			frame.style.transform = "scale(" + canvasScale + ")";
			frame.style.transformOrigin = "top center";
		}

		function filterPalette(query) {
			const items = document.querySelectorAll(".palette-item");
			query = query.toLowerCase();
			items.forEach(item => {
				const match = item.textContent.toLowerCase().includes(query);
				item.style.display = match ? "flex" : "none";
			});
		}

		function spawnControl(type) {
			const count = formSpec.controls.length + 1;
			const id = type + "_" + count;

			// Stagger controls across canvas grid
			const row = Math.floor(formSpec.controls.length / 4);
			const col = formSpec.controls.length % 4;
			let x = 30 + col * 180;
			let y = 50 + row * 65;

			if (snapToGrid) {
				x = Math.round(x / 8) * 8;
				y = Math.round(y / 8) * 8;
			}

			const newControl = {
				id: id,
				control_type: type,
				x: x,
				y: y,
				width: type === "textarea" || type === "table" ? 280 : 150,
				height: type === "textarea" ? 80 : (type === "table" ? 120 : 36),
				text: capitalize(type) + " " + count,
				font_size: 13,
				font_color: "#ffffff",
				background_color: type === "button" ? "#0284c7" : "#1e293b",
				enabled: true,
				visible: true,
				event_handlers: {
					"onClick": "on_" + id + "_click"
				}
			};

			formSpec.controls.push(newControl);
			selectedIndex = formSpec.controls.length - 1;
			renderCanvas();
			renderCode();
			populateInspector();
			document.getElementById("statusMsg").textContent = "Placed " + type + " control (" + id + ")";
		}

		function onDragStart(e, type) {
			draggedType = type;
			e.dataTransfer.setData("text/plain", type);
		}

		function onCanvasDrop(e) {
			e.preventDefault();
			const canvas = document.getElementById("formCanvas");
			const rect = canvas.getBoundingClientRect();
			let x = Math.round((e.clientX - rect.left) / canvasScale);
			let y = Math.round((e.clientY - rect.top) / canvasScale);

			if (snapToGrid) {
				x = Math.round(x / 8) * 8;
				y = Math.round(y / 8) * 8;
			}

			const type = draggedType || e.dataTransfer.getData("text/plain") || "button";
			const count = formSpec.controls.length + 1;
			const id = type + "_" + count;

			const newControl = {
				id: id,
				control_type: type,
				x: Math.max(10, x),
				y: Math.max(10, y),
				width: type === "textarea" || type === "table" ? 280 : 150,
				height: type === "textarea" ? 80 : (type === "table" ? 120 : 36),
				text: capitalize(type) + " " + count,
				font_size: 13,
				font_color: "#ffffff",
				background_color: type === "button" ? "#0284c7" : "#1e293b",
				enabled: true,
				visible: true,
				event_handlers: {
					"onClick": "on_" + id + "_click"
				}
			};

			formSpec.controls.push(newControl);
			selectedIndex = formSpec.controls.length - 1;
			renderCanvas();
			renderCode();
			populateInspector();
			document.getElementById("statusMsg").textContent = "Dropped " + type + " control (" + id + ")";
		}

		function duplicateSelectedControl() {
			if (selectedIndex < 0) return;
			const orig = formSpec.controls[selectedIndex];
			const count = formSpec.controls.length + 1;
			const newId = orig.control_type + "_" + count;

			const copy = JSON.parse(JSON.stringify(orig));
			copy.id = newId;
			copy.x += 16;
			copy.y += 16;
			copy.event_handlers = { "onClick": "on_" + newId + "_click" };

			formSpec.controls.push(copy);
			selectedIndex = formSpec.controls.length - 1;
			renderCanvas();
			renderCode();
			populateInspector();
			document.getElementById("statusMsg").textContent = "Duplicated control: " + newId;
		}

		function alignControls(mode) {
			if (selectedIndex < 0) return;
			const active = formSpec.controls[selectedIndex];
			if (mode === "left") active.x = 24;
			if (mode === "center") active.x = Math.max(10, Math.round((formSpec.width - active.width) / 2));
			if (mode === "right") active.x = Math.max(10, formSpec.width - active.width - 24);
			if (mode === "top") active.y = 24;
			if (mode === "bottom") active.y = Math.max(10, formSpec.height - active.height - 24);
			renderCanvas();
			renderCode();
			populateInspector();
		}

		function updateFormTheme() {
			const theme = document.getElementById("propFormTheme").value;
			if (theme === "Light") {
				formSpec.background_color = "#f8fafc";
				formSpec.font_color = "#0f172a";
			} else if (theme === "High Contrast") {
				formSpec.background_color = "#000000";
				formSpec.font_color = "#00ff00";
			} else if (theme === "Cyberpunk") {
				formSpec.background_color = "#0d0221";
				formSpec.font_color = "#00f6ff";
			} else if (theme === "Midnight") {
				formSpec.background_color = "#090d16";
				formSpec.font_color = "#e2e8f0";
			} else { // Dark
				formSpec.background_color = "#0f172a";
				formSpec.font_color = "#f8fafc";
			}
			renderCanvas();
			renderCode();
		}

		function loadTemplate(name) {
			if (name === "login") {
				formSpec.title = "User Authentication Dialog";
				formSpec.width = 480;
				formSpec.height = 420;
				formSpec.controls = [
					{ id: "lbl_header", control_type: "label", x: 24, y: 24, width: 360, height: 32, text: "🔐 Account Sign In", font_size: 18, font_color: "#38bdf8", background_color: "" },
					{ id: "inp_email", control_type: "input", x: 24, y: 70, width: 360, height: 36, text: "admin@developer.org", event_handlers: { "onChange": "on_email_change" } },
					{ id: "inp_pass", control_type: "password", x: 24, y: 116, width: 360, height: 36, text: "password123", event_handlers: { "onChange": "on_pass_change" } },
					{ id: "chk_remember", control_type: "checkbox", x: 24, y: 162, width: 240, height: 24, text: "Remember login session", checked: true },
					{ id: "btn_signin", control_type: "button", x: 24, y: 200, width: 360, height: 42, text: "Sign In Now", background_color: "#0284c7", event_handlers: { "onClick": "on_signin_click" } }
				];
			} else if (name === "dash") {
				formSpec.title = "Fintech KPI Dashboard";
				formSpec.width = 960;
				formSpec.height = 580;
				formSpec.controls = [
					{ id: "lbl_dash", control_type: "label", x: 20, y: 20, width: 460, height: 32, text: "📊 Executive Performance Dashboard", font_size: 18, font_color: "#10b981" },
					{ id: "inp_target", control_type: "input", x: 20, y: 64, width: 280, height: 34, text: "Q3 Target: $4.2M" },
					{ id: "progress_target", control_type: "progress", x: 320, y: 64, width: 360, height: 34, value: 85 },
					{ id: "btn_refresh", control_type: "button", x: 20, y: 110, width: 160, height: 36, text: "Refresh Data", background_color: "#10b981", event_handlers: { "onClick": "on_refresh_click" } }
				];
			} else {
				// default
				formSpec.title = "Delphi/VB RAD Form Studio";
				formSpec.width = 920;
				formSpec.height = 600;
				formSpec.controls = [
					{ id: "lbl_title", control_type: "label", x: 24, y: 24, width: 420, height: 32, text: "Customer Account Portal", font_size: 18, font_color: "#38bdf8" },
					{ id: "inp_name", control_type: "input", x: 24, y: 72, width: 340, height: 36, text: "Ada Lovelace" },
					{ id: "btn_save", control_type: "button", x: 24, y: 120, width: 160, height: 40, text: "Save Customer", background_color: "#0284c7", event_handlers: { "onClick": "on_save_click" } }
				];
			}
			selectedIndex = -1;
			document.getElementById("propFormTitle").value = formSpec.title;
			renderCanvas();
			renderCode();
			populateInspector();
			document.getElementById("statusMsg").textContent = "Loaded " + name + " template layout.";
		}

		function setBgColor(hex) {
			document.getElementById("propBgColor").value = hex;
			updateSelectedControl();
		}

		function capitalize(str) {
			return str.charAt(0).toUpperCase() + str.slice(1);
		}

		function selectControl(idx, e) {
			if (e) e.stopPropagation();
			selectedIndex = idx;
			renderCanvas();
			populateInspector();
		}

		function syncControlDom(ctrl, div, dimBadge) {
			div.style.left = ctrl.x + "px";
			div.style.top = ctrl.y + "px";
			div.style.width = ctrl.width + "px";
			div.style.height = ctrl.height + "px";
			div.style.backgroundColor = ctrl.background_color || "#1e293b";
			div.style.color = ctrl.font_color || "#ffffff";
			div.style.fontSize = (ctrl.font_size || 12) + "px";
			if (dimBadge) {
				dimBadge.textContent = ctrl.id + " (" + ctrl.width + "x" + ctrl.height + ")";
			}
		}

		function getSelectedControlDom() {
			const div = document.querySelector(".designer-control.selected");
			if (!div) return null;
			const dimBadge = div.querySelector(".dim-badge");
			const caption = div.querySelector(".control-caption");
			return { div: div, dimBadge: dimBadge, caption: caption };
		}

		function deselectControl(e) {
			if (e.target.id === "formCanvas" || e.target.id === "windowFrame") {
				selectedIndex = -1;
				renderCanvas();
				populateInspector();
			}
		}

		function renderCanvas() {
			const canvas = document.getElementById("formCanvas");
			canvas.innerHTML = "";
			canvas.style.backgroundColor = formSpec.background_color || "#0f172a";
			canvas.style.color = formSpec.font_color || "#f8fafc";

			document.getElementById("winTitleHeader").textContent = formSpec.title;
			document.getElementById("canvasStats").textContent = "Form: " + formSpec.width + "x" + formSpec.height + " | Controls: " + formSpec.controls.length;

			formSpec.controls.forEach((ctrl, idx) => {
				const div = document.createElement("div");
				div.className = "designer-control" + (idx === selectedIndex ? " selected" : "");
				div.setAttribute("draggable", "false");
				div.dataset.ctrlIndex = String(idx);
				syncControlDom(ctrl, div, null);

				const caption = document.createElement("span");
				caption.className = "control-caption";
				caption.textContent = ctrl.text || ctrl.id;
				div.appendChild(caption);

				// Dimension badge
				const dimBadge = document.createElement("span");
				dimBadge.className = "dim-badge";
				dimBadge.textContent = ctrl.id + " (" + ctrl.width + "x" + ctrl.height + ")";
				div.appendChild(dimBadge);

				div.ondblclick = (e) => {
					selectControl(idx, e);
					switchTab("tabEvents");
					autoGenerateEvents();
				};

				// Left-click Drag & Repositioning Logic
				let isDragging = false;
				let startX, startY, origX, origY;

				div.onmousedown = (e) => {
					if (e.button !== 0) return; // Only primary left-click
					if (e.target.classList.contains("resize-handle")) return;
					
					e.preventDefault(); // Prevent native text selection & HTML5 drag interference
					e.stopPropagation();

					if (selectedIndex !== idx) {
						selectedIndex = idx;
						document.querySelectorAll(".designer-control.selected").forEach((el) => el.classList.remove("selected"));
						div.classList.add("selected");
						populateInspector();
					}

					isDragging = true;
					startX = e.clientX;
					startY = e.clientY;
					origX = ctrl.x;
					origY = ctrl.y;

					const onMouseMove = (me) => {
						if (!isDragging) return;
						me.preventDefault();

						let dx = (me.clientX - startX) / canvasScale;
						let dy = (me.clientY - startY) / canvasScale;
						let newX = origX + dx;
						let newY = origY + dy;

						if (snapToGrid) {
							newX = Math.round(newX / 8) * 8;
							newY = Math.round(newY / 8) * 8;
						}

						ctrl.x = Math.max(0, Math.round(newX));
						ctrl.y = Math.max(0, Math.round(newY));

						syncControlDom(ctrl, div, dimBadge);
						document.getElementById("propX").value = ctrl.x;
						document.getElementById("propY").value = ctrl.y;
						document.getElementById("statusMsg").textContent = "Moving " + ctrl.id + " to " + ctrl.x + "," + ctrl.y;
					};

					const onMouseUp = (ue) => {
						isDragging = false;
						window.removeEventListener("mousemove", onMouseMove);
						window.removeEventListener("mouseup", onMouseUp);
						renderCanvas();
						renderCode();
						populateInspector();
					};

					window.addEventListener("mousemove", onMouseMove);
					window.addEventListener("mouseup", onMouseUp);
				};

				// Full 8-Handle Resize System (N, S, E, W, NW, NE, SW, SE)
				if (idx === selectedIndex) {
					["nw", "n", "ne", "e", "se", "s", "sw", "w"].forEach(handlePos => {
						const handle = document.createElement("div");
						handle.className = "resize-handle handle-" + handlePos;
						handle.setAttribute("draggable", "false");

						handle.onmousedown = (he) => {
							if (he.button !== 0) return;
							he.preventDefault();
							he.stopPropagation();

							let rStartX = he.clientX;
							let rStartY = he.clientY;
							let rOrigX = ctrl.x;
							let rOrigY = ctrl.y;
							let rOrigW = ctrl.width;
							let rOrigH = ctrl.height;

							const onResizeMove = (rme) => {
								rme.preventDefault();
								let rdx = (rme.clientX - rStartX) / canvasScale;
								let rdy = (rme.clientY - rStartY) / canvasScale;

								if (handlePos.includes("e")) {
									ctrl.width = Math.max(30, Math.round(rOrigW + rdx));
								}
								if (handlePos.includes("w")) {
									let nw = Math.max(30, Math.round(rOrigW - rdx));
									ctrl.x = Math.round(rOrigX + (rOrigW - nw));
									ctrl.width = nw;
									div.style.left = ctrl.x + "px";
									document.getElementById("propX").value = ctrl.x;
								}
								if (handlePos.includes("s")) {
									ctrl.height = Math.max(20, Math.round(rOrigH + rdy));
								}
								if (handlePos.includes("n")) {
									let nh = Math.max(20, Math.round(rOrigH - rdy));
									ctrl.y = Math.round(rOrigY + (rOrigH - nh));
									ctrl.height = nh;
									div.style.top = ctrl.y + "px";
									document.getElementById("propY").value = ctrl.y;
								}

								syncControlDom(ctrl, div, dimBadge);

								document.getElementById("propWidth").value = ctrl.width;
								document.getElementById("propHeight").value = ctrl.height;
								document.getElementById("statusMsg").textContent = "Resizing " + ctrl.id + " to " + ctrl.width + "x" + ctrl.height;
							};

							const onResizeUp = () => {
								window.removeEventListener("mousemove", onResizeMove);
								window.removeEventListener("mouseup", onResizeUp);
								renderCode();
								populateInspector();
							};

							window.addEventListener("mousemove", onResizeMove);
							window.addEventListener("mouseup", onResizeUp);
						};
						div.appendChild(handle);
					});
				}

				canvas.appendChild(div);
			});
		}

		function populateInspector() {
			const container = document.getElementById("controlPropContainer");
			if (selectedIndex < 0 || selectedIndex >= formSpec.controls.length) {
				container.style.opacity = "0.4";
				container.style.pointerEvents = "none";
				return;
			}
			container.style.opacity = "1";
			container.style.pointerEvents = "auto";

			const c = formSpec.controls[selectedIndex];
			document.getElementById("propId").value = c.id;
			document.getElementById("propText").value = c.text;
			document.getElementById("propX").value = c.x;
			document.getElementById("propY").value = c.y;
			document.getElementById("propWidth").value = c.width;
			document.getElementById("propHeight").value = c.height;
			document.getElementById("propFontSize").value = c.font_size || 13;
			document.getElementById("propFontColor").value = c.font_color || "#ffffff";
			document.getElementById("propBgColor").value = c.background_color || "#1e293b";

			// Populate Events tab
			c.event_handlers = c.event_handlers || {};
			document.getElementById("evtOnClick").value = c.event_handlers["onClick"] || "";
			document.getElementById("evtOnChange").value = c.event_handlers["onChange"] || "";
			document.getElementById("evtOnDblClick").value = c.event_handlers["onDoubleClick"] || "";
		}

		function updateSelectedControl() {
			if (selectedIndex < 0) return;
			const c = formSpec.controls[selectedIndex];

			const parseOrKeep = (value, fallback, minVal) => {
				if (value === "") return fallback;
				const parsed = parseInt(value, 10);
				if (Number.isNaN(parsed)) return fallback;
				return Math.max(minVal, parsed);
			};

			c.id = document.getElementById("propId").value || c.id;
			c.text = document.getElementById("propText").value;
			c.x = parseOrKeep(document.getElementById("propX").value, c.x, 0);
			c.y = parseOrKeep(document.getElementById("propY").value, c.y, 0);
			c.width = parseOrKeep(document.getElementById("propWidth").value, c.width, 30);
			c.height = parseOrKeep(document.getElementById("propHeight").value, c.height, 20);
			c.font_size = parseOrKeep(document.getElementById("propFontSize").value, c.font_size || 13, 1);
			c.font_color = document.getElementById("propFontColor").value;
			c.background_color = document.getElementById("propBgColor").value;

			let selectedDom = getSelectedControlDom();
			if (!selectedDom) {
				const fallbackDiv = Array.from(document.querySelectorAll(".designer-control")).find(el => el.dataset.ctrlIndex === String(selectedIndex));
				if (fallbackDiv) {
					fallbackDiv.classList.add("selected");
					selectedDom = {
						div: fallbackDiv,
						dimBadge: fallbackDiv.querySelector(".dim-badge"),
						caption: fallbackDiv.querySelector(".control-caption")
					};
				}
			}

			if (selectedDom) {
				syncControlDom(c, selectedDom.div, selectedDom.dimBadge);
				if (selectedDom.caption) {
					selectedDom.caption.textContent = c.text || c.id;
				}
			}

			document.getElementById("statusMsg").textContent = "Applied property changes to " + c.id;
			renderCode();
		}

		function updateEventPlaceholder(evtName, val) {
			if (selectedIndex < 0) return;
			const c = formSpec.controls[selectedIndex];
			c.event_handlers = c.event_handlers || {};
			c.event_handlers[evtName] = val;
			renderCode();
		}

		function autoGenerateEvents() {
			if (selectedIndex < 0) return;
			const c = formSpec.controls[selectedIndex];
			c.event_handlers = c.event_handlers || {};
			c.event_handlers["onClick"] = "on_" + c.id + "_click";
			c.event_handlers["onChange"] = "on_" + c.id + "_change";
			populateInspector();
			renderCode();
			document.getElementById("statusMsg").textContent = "Auto-generated RAD event placeholders for " + c.id;
		}

		function deleteSelectedControl() {
			if (selectedIndex < 0) return;
			formSpec.controls.splice(selectedIndex, 1);
			selectedIndex = -1;
			renderCanvas();
			renderCode();
			populateInspector();
			document.getElementById("statusMsg").textContent = "Control deleted.";
		}

		function updateFormSpec() {
			formSpec.title = document.getElementById("propFormTitle").value;
			renderCanvas();
			renderCode();
		}

		function switchTab(tabId, evt) {
			document.querySelectorAll(".tab-item").forEach(t => t.classList.remove("active"));
			document.querySelectorAll(".tab-content").forEach(c => c.classList.remove("active"));

			if (evt && evt.target) evt.target.classList.add("active");
			document.getElementById(tabId).classList.add("active");
		}

		function syncSpecToV() {
			const payload = JSON.stringify(formSpec);
			if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.simplegui) {
				window.webkit.messageHandlers.simplegui.postMessage({
					control: "designer_canvas",
					event: "change",
					value: "spec_update:" + payload
				});
			} else {
				window.location.href = "simplegui://change/designer_canvas/spec_update:" + encodeURIComponent(payload);
			}
		}

		function renderCode() {
			const jsonStr = JSON.stringify(formSpec, null, 2);
			document.getElementById("jsonPreviewText").value = jsonStr;

			// Construct dynamic V code
			let vcode = "module main\\n\\nimport simplegui\\n\\nfn main() {\\n";
			vcode += "  mut win := simplegui.new_simple_window(\'" + formSpec.title + "\', " + formSpec.width + ", " + formSpec.height + ")\\n";
			vcode += "  win.set_background_color(\'" + formSpec.background_color + "\')\\n";
			vcode += "    .set_font_color(\'" + formSpec.font_color + "\')\\n";
			vcode += "    .set_padding(" + formSpec.padding + ")\\n";
			vcode += "    .set_spacing(" + formSpec.spacing + ")\\n\\n";

			formSpec.controls.forEach(c => {
				vcode += "  win.add_" + c.control_type + "(\'" + c.id + "\', \'" + c.text + "\')\\n";
				if (c.width) vcode += "  win.set_control_width(\'" + c.id + "\', " + c.width + ")\\n";
				if (c.height) vcode += "  win.set_control_height(\'" + c.id + "\', " + c.height + ")\\n";
			});

			vcode += "\\n  // RAD Event Bindings\\n";
			let handlers = [];
			formSpec.controls.forEach(c => {
				if (c.event_handlers) {
					for (let evt in c.event_handlers) {
						let fname = c.event_handlers[evt];
						if (fname && fname.trim()) {
							vcode += "  win.on_click(\'" + c.id + "\', " + fname.trim() + ")\\n";
							handlers.push({ name: fname.trim(), id: c.id });
						}
					}
				}
			});

			vcode += "\\n  win.run()\\n}\\n\\n";
			vcode += "// RAD Event Callback Placeholders\\n";
			handlers.forEach(h => {
				vcode += "fn " + h.name + "(mut win simplegui.SimpleWindow) {\\n";
				vcode += "  win.set_status(\'Event: " + h.name + " on " + h.id + "\')\\n";
				vcode += "  // TODO: Implement business logic\\n}\\n\\n";
			});

			document.getElementById("codePreviewText").value = vcode;
			syncSpecToV();
		}

		function clearForm() {
			if (confirm("Clear all controls from canvas?")) {
				formSpec.controls = [];
				selectedIndex = -1;
				renderCanvas();
				renderCode();
				populateInspector();
			}
		}

		function copyVCode() {
			const text = document.getElementById("codePreviewText").value;
			navigator.clipboard.writeText(text);
			document.getElementById("statusMsg").textContent = "V source code copied to clipboard!";
		}

		function exportFormJSON() {
			const text = document.getElementById("jsonPreviewText").value;
			navigator.clipboard.writeText(text);
			document.getElementById("statusMsg").textContent = "Form JSON layout copied to clipboard!";
		}

		function triggerRunForm() {
			document.getElementById("statusMsg").textContent = "Launching live SimpleGUI test window...";
			const payload = JSON.stringify(formSpec);
			if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.simplegui) {
				window.webkit.messageHandlers.simplegui.postMessage({
					control: "designer_canvas",
					event: "change",
					value: "run_spec:" + payload
				});
			} else {
				window.location.href = "simplegui://change/designer_canvas/run_spec:" + encodeURIComponent(payload);
			}
		}
	</script>
</body>
</html>
	'
}

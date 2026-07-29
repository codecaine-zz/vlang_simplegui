module main

import simplegui

fn main() {
	mut win := simplegui.new_simple_window('Cloud Operations Studio — Card & Container Gallery', 760, 920)
		.configure(fn (mut cfg simplegui.WindowConfig) {
			cfg.padding = 20
			cfg.spacing = 14
			cfg.background_color = '#0F172A' // Dark Slate theme
			cfg.font_color = '#F8FAFC'
		})

	win.add_heading('🌩️ Cloud Infrastructure & Analytics Studio')
	win.add_label('lbl_sub', 'Explore visual containers featuring custom border strokes, corner radii, background fills, elevation shadows, and caption alignments.')
	win.set_control_font_size('lbl_sub', 12)

	win.add_vertical_spacer(4)

	// ----------------------------------------------------
	// 1. Elevated Card with Shadow: System Telemetry & Cluster Metrics
	// ----------------------------------------------------
	win.card_with_title('card_telemetry', '📊 Cluster Telemetry & Node Health', fn (mut w simplegui.SimpleWindow) {
		w.flex_box('row_telemetry_status', 'row', 'space_between', 'center', fn (mut w simplegui.SimpleWindow) {
			w.add_status_indicator('ind_cluster', 'online', 'Kubernetes Cluster us-east-1 (128 Nodes Active)')
			w.add_badge('badge_status', 'HEALTHY', 'success')
		})

		w.add_vertical_spacer(4)
		w.add_label('lbl_cpu', 'CPU Utilization Across Node Pools (42%)')
		w.add_progress_indicator('prog_cpu', 42)

		w.add_label('lbl_mem', 'Memory Consumption (16.4 GB / 32 GB)')
		w.add_progress_indicator('prog_mem', 51)
	})

	// ----------------------------------------------------
	// 2. Custom Colored Accent Pill Card (18px Radius, Soft Indigo Fill & Stroke)
	// ----------------------------------------------------
	win.group_config('card_security', simplegui.GroupConfig{
		title: '🔒 Security & Access Baseline Policies'
		border: true
		border_width: 2.0
		border_color: '#6366F1'
		corner_radius: 18.0
		bg_color: '#1E1B4B'
		padding: 16
		show_caption: true
		caption_color: '#A5B4FC'
		caption_alignment: 'left'
	}, fn (mut w simplegui.SimpleWindow) {
		w.add_switch('sw_mfa', 'Enforce Mandatory Multi-Factor Authentication (MFA)', true)
		w.add_switch('sw_vpn', 'Restrict Control Plane to Verified Corporate VPN Subnets', true)

		w.add_vertical_spacer(4)
		w.add_label('lbl_roles', 'Active IAM Identity Role Group:')
		w.add_chip_group('chip_roles', ['SecOps Admin', 'DevOps Engineer', 'Auditor', 'Billing Spec'], 'DevOps Engineer')

		w.add_action('btn_sec_apply', 'Apply Security Baseline', fn (mut w simplegui.SimpleWindow) {
			w.alert('Security Baseline', 'IAM security baseline policies enforced successfully across all clusters.')
		})
	})

	// ----------------------------------------------------
	// 3. Emerald Glass Card (Centered Caption, 14px Radius, Emerald Stroke)
	// ----------------------------------------------------
	win.group_config('card_api_quota', simplegui.GroupConfig{
		title: '⚡ API Gateway Quota & Rate Limit Rules'
		border: true
		border_width: 1.5
		border_color: '#10B981'
		corner_radius: 14.0
		bg_color: '#064E3B'
		padding: 16
		show_caption: true
		caption_color: '#6EE7B7'
		caption_alignment: 'center'
		shadow: true
	}, fn (mut w simplegui.SimpleWindow) {
		w.add_label('lbl_rate_desc', 'Adjust maximum allowed request burst throughput per client IP address:')
		w.add_slider('sl_rate', 45)
		w.add_label('lbl_rate_info', 'Current Limit: 2,500 requests / sec (Burst Window: 5,000 req / min)')

		w.row('row_api_actions', fn (mut w simplegui.SimpleWindow) {
			w.add_action('btn_purge', 'Purge Edge Cache', fn (mut w simplegui.SimpleWindow) {
				w.alert('Edge Cache', 'CDN edge caches invalidated for global endpoints.')
			})
			w.add_action('btn_sync', 'Sync Rate Limiters', fn (mut w simplegui.SimpleWindow) {
				w.alert('Rate Limiter', 'Rate limiter rules synced across 14 edge pop locations.')
			})
		})
	})

	// ----------------------------------------------------
	// 4. Interactive Live Style Inspector Target
	// ----------------------------------------------------
	win.group_config('grp_live_target', simplegui.GroupConfig{
		title: '🎨 Interactive Live Container Style Target'
		border: true
		border_width: 2.0
		border_color: '#F59E0B'
		corner_radius: 12.0
		bg_color: '#451A03'
		padding: 16
		show_caption: true
		caption_color: '#FBBF24'
		caption_alignment: 'left'
	}, fn (mut w simplegui.SimpleWindow) {
		w.add_label('lbl_live_status', 'Active Preset: Amber Warm Slate (2px Stroke, 12px Radius)')
		w.add_input('inp_sample', 'Sample input element inside live target container')
	})

	win.add_label('lbl_presets_head', 'Click a preset button below to dynamically morph the container style at runtime:')

	win.row('row_presets', fn (mut w simplegui.SimpleWindow) {
		w.add_action('btn_p_neon', 'Neon Pink Cyber', fn (mut w simplegui.SimpleWindow) {
			w.set_group_style('grp_live_target', simplegui.GroupConfig{
				border: true
				border_width: 3.0
				border_color: '#EC4899'
				corner_radius: 8.0
				bg_color: '#500724'
				shadow: true
			})
			w.set_text('lbl_live_status', 'Active Preset: Neon Pink Cyber (3px Stroke, 8px Radius)')
		})

		w.add_action('btn_p_emerald', 'Emerald Pill', fn (mut w simplegui.SimpleWindow) {
			w.set_group_style('grp_live_target', simplegui.GroupConfig{
				border: true
				border_width: 2.0
				border_color: '#10B981'
				corner_radius: 24.0
				bg_color: '#022C22'
				shadow: false
			})
			w.set_text('lbl_live_status', 'Active Preset: Emerald Pill (2px Stroke, 24px Radius)')
		})

		w.add_action('btn_p_card', 'Elevated Card', fn (mut w simplegui.SimpleWindow) {
			w.set_group_style('grp_live_target', simplegui.GroupConfig{
				border: false
				shadow: true
				corner_radius: 16.0
				bg_color: '#1E293B'
			})
			w.set_text('lbl_live_status', 'Active Preset: Elevated Borderless Card with Shadow')
		})

		w.add_action('btn_p_industrial', 'Sharp Industrial', fn (mut w simplegui.SimpleWindow) {
			w.set_group_style('grp_live_target', simplegui.GroupConfig{
				border: true
				border_width: 1.0
				border_color: '#94A3B8'
				corner_radius: 0.0
				bg_color: '#0F172A'
				shadow: false
			})
			w.set_text('lbl_live_status', 'Active Preset: Sharp Industrial Minimal (1px Stroke, 0px Radius)')
		})
	})

	win.run()
}

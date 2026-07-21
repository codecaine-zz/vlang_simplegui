module simplegui

#include <Cocoa/Cocoa.h>
#include "@VMODROOT/simplegui/window.h"
#flag -framework Cocoa
#flag -framework WebKit
#flag -framework QuartzCore
#flag @VMODROOT/simplegui/window.m

fn C.window_app_init(&WindowParams) &WindowInfo
fn C.window_app_run(&WindowInfo)
fn C.window_app_exit(&WindowInfo)
fn C.window_set_title_text(&WindowInfo, &u8)
fn C.window_set_status_text(&WindowInfo, &u8)
fn C.window_set_always_on_top(&WindowInfo, int)
fn C.window_get_always_on_top(&WindowInfo) int
fn C.window_set_background_color(&WindowInfo, &u8)
fn C.window_set_padding(&WindowInfo, int)
fn C.window_set_spacing(&WindowInfo, int)
fn C.window_set_responsive_layout(&WindowInfo, int)
fn C.window_add_group_box_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_tabs_control(&WindowInfo, &u8, &&u8, int) voidptr
fn C.window_add_scroll_view_control(&WindowInfo, &u8, int) voidptr
fn C.window_focus_control(&WindowInfo, &u8)
fn C.window_set_placeholder_by_name(&WindowInfo, &u8, &u8)
fn C.window_set_error_by_name(&WindowInfo, &u8, &u8)
fn C.window_set_tooltip_by_name(&WindowInfo, &u8, &u8)
fn C.window_set_default_button_by_name(&WindowInfo, &u8)
fn C.window_run_after(&WindowInfo, int, &u8)
fn C.window_show_toast(&WindowInfo, &u8)
fn C.window_open_url(&WindowInfo, &u8)
fn C.window_copy_to_clipboard(&WindowInfo, &u8)
fn C.window_get_clipboard_text() &u8
fn C.window_reveal_in_finder(&u8) int
fn C.window_set_font_color(&WindowInfo, &u8)
fn C.window_set_control_background_color_by_name(&WindowInfo, &u8, &u8)
fn C.window_set_control_font_color_by_name(&WindowInfo, &u8, &u8)
fn C.window_set_control_width_by_name(&WindowInfo, &u8, int)
fn C.window_set_control_height_by_name(&WindowInfo, &u8, int)
fn C.window_set_control_font_size_by_name(&WindowInfo, &u8, int)
fn C.window_set_control_font_bold_by_name(&WindowInfo, &u8, int)
fn C.window_set_control_font_name_by_name(&WindowInfo, &u8, &u8)
fn C.window_show_choice_dialog(&WindowInfo, &u8, &u8, &&u8, int) int
fn C.window_add_context_menu_item(&WindowInfo, &u8, &u8, &u8)

// Dialogs and Message boxes
fn C.window_show_alert(&WindowInfo, &u8, &u8)
fn C.window_show_alert_with_style(&WindowInfo, &u8, &u8, &u8)
fn C.window_show_confirm(&WindowInfo, &u8, &u8) int
fn C.window_show_prompt(&WindowInfo, &u8, &u8, &u8) &u8

// File Panels
fn C.window_select_file(&WindowInfo) &u8
fn C.window_select_file_with_extensions(&WindowInfo, &u8) &u8
fn C.window_select_folder(&WindowInfo) &u8
fn C.window_save_file_picker(&WindowInfo) &u8

// Visibility & Enabled
fn C.window_set_control_visible_by_name(&WindowInfo, &u8, int)
fn C.window_get_control_visible_by_name(&WindowInfo, &u8) int
fn C.window_set_control_enabled_by_name(&WindowInfo, &u8, int)
fn C.window_get_control_enabled_by_name(&WindowInfo, &u8) int

// Timers
fn C.window_set_interval(&WindowInfo, int, &u8)
fn C.window_stop_interval(&WindowInfo, &u8)

// List Box and Image View Controls
fn C.window_add_list_box_control(&WindowInfo, &u8, &&u8, int) voidptr
fn C.window_update_list_items(&WindowInfo, &u8, &&u8, int)
fn C.window_set_list_selected(&WindowInfo, &u8, int)
fn C.window_get_list_selected(&WindowInfo, &u8) int
fn C.window_set_list_multi_select(&WindowInfo, &u8, int)
fn C.window_get_list_selected_indexes(&WindowInfo, &u8) &u8
fn C.window_set_list_selected_indexes(&WindowInfo, &u8, &u8)
fn C.window_select_all_list_items(&WindowInfo, &u8)
fn C.window_clear_list_selection(&WindowInfo, &u8)
fn C.window_add_image_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_set_image_path(&WindowInfo, &u8, &u8)

// Hover tracking
fn C.window_enable_hover_events(&WindowInfo, &u8)

// Menu Customization
fn C.window_add_menu_item(&WindowInfo, &u8, &u8, &u8, &u8)

// Name-based generic control accessors
fn C.window_set_control_text_by_name(&WindowInfo, &u8, &u8)
fn C.window_get_control_text_by_name(&WindowInfo, &u8) &u8
fn C.window_set_control_bool_by_name(&WindowInfo, &u8, int)
fn C.window_get_control_bool_by_name(&WindowInfo, &u8) int
fn C.window_set_control_int_by_name(&WindowInfo, &u8, int)
fn C.window_get_control_int_by_name(&WindowInfo, &u8) int

// Dynamic control creation bridges
fn C.window_add_label_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_input_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_password_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_textarea_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_html_view_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_drop_zone_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_checkbox_control(&WindowInfo, &u8, &u8, int) voidptr
fn C.window_add_button_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_number_control(&WindowInfo, &u8, int) voidptr
fn C.window_add_slider_control(&WindowInfo, &u8, int) voidptr
fn C.window_add_theme_menu_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_color_well_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_date_picker_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_date_time_picker_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_mode_control_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_progress_indicator_control(&WindowInfo, &u8, int) voidptr

// Layout row & container groupings
fn C.window_begin_row(&WindowInfo, &u8)
fn C.window_end_row(&WindowInfo)
fn C.window_begin_grid(&WindowInfo, &u8, int, int)
fn C.window_end_grid(&WindowInfo)
fn C.window_begin_flex_box(&WindowInfo, &u8, &u8, &u8, &u8)
fn C.window_end_flex_box(&WindowInfo)
fn C.window_set_control_alignment_by_name(&WindowInfo, &u8, &u8)
fn C.window_set_control_expand_fill_by_name(&WindowInfo, &u8, int)

// Spacers and Separators
fn C.window_add_vertical_spacer(&WindowInfo, int)
fn C.window_add_horizontal_spacer(&WindowInfo, int)
fn C.window_add_separator(&WindowInfo)

// Multi-Column Table Controls
fn C.window_add_table_control(&WindowInfo, &u8, &&u8, int) voidptr
fn C.window_set_table_rows(&WindowInfo, &u8, &&u8, int, int)

// Tree View Controls
fn C.window_add_tree_view_control(&WindowInfo, &u8, int) voidptr
fn C.window_set_tree_nodes(&WindowInfo, &u8, &&u8, int)
fn C.window_get_tree_selected(&WindowInfo, &u8) &u8
fn C.window_set_tree_selected(&WindowInfo, &u8, &u8)
fn C.window_tree_expand_all(&WindowInfo, &u8)
fn C.window_tree_collapse_all(&WindowInfo, &u8)
fn C.window_tree_expand_node(&WindowInfo, &u8, &u8, int)
fn C.window_tree_collapse_node(&WindowInfo, &u8, &u8, int)

// System Menu Bar/Tray App Mode
fn C.window_enable_status_bar(&WindowInfo, &u8)
fn C.window_show(&WindowInfo)

// Thread Safety Runner
fn C.window_run_on_main_thread(voidptr, voidptr)
fn C.window_run_on_main_thread_sync(voidptr, voidptr)

// New general-purpose controls
fn C.window_add_dropdown_control(&WindowInfo, &u8, &&u8, int, &u8) voidptr
fn C.window_add_segmented_control_custom(&WindowInfo, &u8, &&u8, int, &u8) voidptr
fn C.window_add_radio_group_control(&WindowInfo, &u8, &&u8, int, &u8) voidptr
fn C.window_add_switch_control(&WindowInfo, &u8, &u8, int) voidptr
fn C.window_add_search_field_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_combo_box_control(&WindowInfo, &u8, &&u8, int, &u8) voidptr
fn C.window_add_level_indicator_control(&WindowInfo, &u8, int, int, int, int) voidptr
fn C.window_add_spinner_control(&WindowInfo, &u8, int) voidptr
fn C.window_add_path_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_token_field_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_console_control(&WindowInfo, &u8, int) voidptr
fn C.window_append_console_text(&WindowInfo, &u8, &u8, int)
fn C.window_clear_console(&WindowInfo, &u8)
fn C.window_add_chart_control(&WindowInfo, &u8, &u8, int) voidptr
fn C.window_set_chart_data(&WindowInfo, &u8, &f64, int)
fn C.window_add_shortcut_recorder_control(&WindowInfo, &u8) voidptr
fn C.window_add_circular_progress_control(&WindowInfo, &u8, f64, f64, f64) voidptr
fn C.window_set_circular_progress_value(&WindowInfo, &u8, f64)
fn C.window_add_breadcrumbs_control(&WindowInfo, &u8, &&u8, int) voidptr
fn C.window_set_breadcrumbs(&WindowInfo, &u8, &&u8, int)
fn C.window_add_property_grid_control(&WindowInfo, &u8, &&u8, &&u8, int) voidptr
fn C.window_set_property_grid_value(&WindowInfo, &u8, &u8, &u8)
fn C.window_add_color_grid_control(&WindowInfo, &u8, &&u8, int) voidptr
fn C.window_set_color_grid_selected(&WindowInfo, &u8, &u8)
fn C.window_add_grid_control(&WindowInfo, &u8, &&u8, int) voidptr
fn C.window_grid_add_row(&WindowInfo, &u8, &&u8, int)
fn C.window_grid_delete_row(&WindowInfo, &u8, int)
fn C.window_grid_add_column(&WindowInfo, &u8, &u8)
fn C.window_grid_delete_column(&WindowInfo, &u8, int)
fn C.window_grid_set_cell(&WindowInfo, &u8, int, int, &u8)
fn C.window_grid_get_cell(&WindowInfo, &u8, int, int) &u8
fn C.window_grid_get_selected_row(&WindowInfo, &u8) int
fn C.window_grid_get_column_editable(&WindowInfo, &u8, int) int
fn C.window_grid_get_row_editable(&WindowInfo, &u8, int) int
fn C.window_grid_get_cell_editable(&WindowInfo, &u8, int, int) int
fn C.window_grid_get_column_enabled(&WindowInfo, &u8, int) int
fn C.window_grid_get_row_enabled(&WindowInfo, &u8, int) int
fn C.window_grid_get_cell_enabled(&WindowInfo, &u8, int, int) int
fn C.window_grid_get_filter(&WindowInfo, &u8) &u8
fn C.window_grid_get_row_count(&WindowInfo, &u8) int
fn C.window_grid_get_column_count(&WindowInfo, &u8) int
fn C.window_grid_set_column_type(&WindowInfo, &u8, int, &u8)
fn C.window_grid_set_column_width(&WindowInfo, &u8, int, int)
fn C.window_grid_set_row_height(&WindowInfo, &u8, int)
fn C.window_grid_sort_by_column(&WindowInfo, &u8, int, int)
fn C.window_grid_get_selected_column(&WindowInfo, &u8) int
fn C.window_grid_set_selected_column(&WindowInfo, &u8, int)
fn C.window_grid_set_selected_cell(&WindowInfo, &u8, int, int)
fn C.window_grid_set_filter(&WindowInfo, &u8, &u8)
fn C.window_grid_clear_filter(&WindowInfo, &u8)
fn C.window_grid_autosize_columns(&WindowInfo, &u8)
fn C.window_grid_set_selected_row(&WindowInfo, &u8, int)
fn C.window_grid_clear(&WindowInfo, &u8)
fn C.window_grid_set_column_editable(&WindowInfo, &u8, int, int)
fn C.window_grid_set_row_editable(&WindowInfo, &u8, int, int)
fn C.window_grid_set_cell_editable(&WindowInfo, &u8, int, int, int)
fn C.window_grid_set_column_enabled(&WindowInfo, &u8, int, int)
fn C.window_grid_set_row_enabled(&WindowInfo, &u8, int, int)
fn C.window_grid_set_cell_enabled(&WindowInfo, &u8, int, int, int)

// Window constraints and behavior options
fn C.window_set_min_size(&WindowInfo, int, int)
fn C.window_set_max_size(&WindowInfo, int, int)
fn C.window_set_resizable(&WindowInfo, int)
fn C.window_set_minimizable(&WindowInfo, int)
fn C.window_set_maximizable(&WindowInfo, int)
fn C.window_set_closable(&WindowInfo, int)
fn C.window_get_closable(&WindowInfo) int
fn C.window_set_has_shadow(&WindowInfo, int)
fn C.window_get_has_shadow(&WindowInfo) int
fn C.window_set_movable_by_window_background(&WindowInfo, int)
fn C.window_get_movable_by_window_background(&WindowInfo) int
fn C.window_is_visible(&WindowInfo) int
fn C.window_set_title_visible(&WindowInfo, int)
fn C.window_get_title_visible(&WindowInfo) int
fn C.window_get_titlebar_visible(&WindowInfo) int

// Additional Window Operations
fn C.window_close(&WindowInfo)
fn C.window_hide(&WindowInfo)
fn C.window_center(&WindowInfo)
fn C.window_align(&WindowInfo, &u8)
fn C.window_set_size(&WindowInfo, int, int)
fn C.window_get_width(&WindowInfo) int
fn C.window_get_height(&WindowInfo) int
fn C.window_set_position(&WindowInfo, int, int)
fn C.window_get_x(&WindowInfo) int
fn C.window_get_y(&WindowInfo) int
fn C.window_set_opacity(&WindowInfo, f64)
fn C.window_get_opacity(&WindowInfo) f64
fn C.window_toggle_fullscreen(&WindowInfo)
fn C.window_minimize(&WindowInfo)
fn C.window_deminimize(&WindowInfo)
fn C.window_maximize(&WindowInfo)
fn C.window_is_minimized(&WindowInfo) int
fn C.window_is_maximized(&WindowInfo) int
fn C.window_is_fullscreen(&WindowInfo) int
fn C.window_is_active(&WindowInfo) int
fn C.window_set_titlebar_visible(&WindowInfo, int)
fn C.window_request_attention(&WindowInfo, int)

fn C.window_deliver_notification(&u8, &u8)
fn C.window_set_dock_badge(&u8)
fn C.window_set_slider_range(&WindowInfo, &u8, f64, f64)
fn C.window_add_link_control(&WindowInfo, &u8, &u8, &u8) voidptr
fn C.window_beep()

fn C.window_add_disclosure_control(&WindowInfo, &u8, &u8, int) voidptr
fn C.window_enable_search_history(&WindowInfo, &u8, &u8)
fn C.window_add_stepper_control(&WindowInfo, &u8, f64, f64, f64, f64) voidptr
fn C.window_add_help_button_control(&WindowInfo, &u8) voidptr
fn C.window_add_knob_control(&WindowInfo, &u8, f64, f64, f64) voidptr
fn C.window_add_pull_down_control(&WindowInfo, &u8, &u8, &&u8, int) voidptr
fn C.window_add_image_button_control(&WindowInfo, &u8, &u8, &u8) voidptr
fn C.window_set_status_bar_icon(&WindowInfo, &u8)
fn C.window_set_status_bar_title(&WindowInfo, &u8)
fn C.window_set_dock_icon(&u8)
fn C.window_play_system_sound(&u8)

// Animations and Transition Helpers C declarations
fn C.window_animate_control_opacity(&WindowInfo, &u8, f64, int)
fn C.window_animate_opacity(&WindowInfo, f64, int)
fn C.window_animate_control_shake(&WindowInfo, &u8)
fn C.window_shake(&WindowInfo)
fn C.window_animate_control_width(&WindowInfo, &u8, int, int)
fn C.window_animate_control_height(&WindowInfo, &u8, int, int)
fn C.window_animate_control_size(&WindowInfo, &u8, int, int, int)
fn C.window_animate_size(&WindowInfo, int, int, int)
fn C.window_animate_position(&WindowInfo, int, int, int)
fn C.window_animate_bounds(&WindowInfo, int, int, int, int, int)

fn C.window_add_toolbar_item(&WindowInfo, &u8, &u8, &u8, &u8)
fn C.window_add_toolbar_space(&WindowInfo)
fn C.window_add_toolbar_flexible_space(&WindowInfo)
fn C.window_set_toolbar_style(&WindowInfo, &u8)
fn C.window_show_sheet_alert(&WindowInfo, &u8, &u8, &u8)
fn C.window_add_dock_menu_item(&WindowInfo, &u8, &u8)

// New controls C declarations
fn C.window_begin_split_view(&WindowInfo, &u8, int)
fn C.window_split_view_next_pane(&WindowInfo)
fn C.window_end_split_view(&WindowInfo)
fn C.window_add_collection_view_control(&WindowInfo, &u8, int, int) voidptr
fn C.window_set_collection_items(&WindowInfo, &u8, &&u8, int)
fn C.window_show_popover(&WindowInfo, &u8, &u8, &u8)
fn C.window_add_calendar_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_add_canvas_control(&WindowInfo, &u8, int) voidptr
fn C.window_draw_line(&WindowInfo, &u8, f64, f64, f64, f64, &u8, f64)
fn C.window_draw_rect(&WindowInfo, &u8, f64, f64, f64, f64, &u8, int, f64)
fn C.window_draw_circle(&WindowInfo, &u8, f64, f64, f64, &u8, int, f64)
fn C.window_clear_canvas(&WindowInfo, &u8)

// Glass, Badge, Icon Segment C declarations
fn C.window_begin_glass_box(&WindowInfo, &u8, &u8)
fn C.window_end_glass_box(&WindowInfo)
fn C.window_add_badge_control(&WindowInfo, &u8, &u8, &u8) voidptr
fn C.window_add_icon_segments_control(&WindowInfo, &u8, &&u8, int, &u8) voidptr
fn C.window_add_stat_card_control(&WindowInfo, &u8, &u8, &u8, &u8, &u8) voidptr
fn C.window_set_stat_card_value(&WindowInfo, &u8, &u8, &u8, &u8)
fn C.window_add_banner_control(&WindowInfo, &u8, &u8, &u8) voidptr
fn C.window_add_section_header_control(&WindowInfo, &u8, &u8, &u8) voidptr
fn C.window_add_vertical_slider_control(&WindowInfo, &u8, int, int, int, int) voidptr
fn C.window_add_chip_group_control(&WindowInfo, &u8, &&u8, int, &u8) voidptr
fn C.window_set_banner_value(&WindowInfo, &u8, &u8)
fn C.window_set_vertical_slider_value(&WindowInfo, &u8, int)
fn C.window_set_chip_group_selected(&WindowInfo, &u8, &u8)
fn C.window_set_badge_value(&WindowInfo, &u8, &u8, &u8)
fn C.window_add_status_indicator_control(&WindowInfo, &u8, &u8, &u8) voidptr
fn C.window_set_status_indicator_value(&WindowInfo, &u8, &u8)
fn C.window_add_metric_meter_control(&WindowInfo, &u8, &u8, int, int, int, &u8) voidptr
fn C.window_set_metric_meter_value(&WindowInfo, &u8, int)
fn C.window_add_avatar_card_control(&WindowInfo, &u8, &u8, &u8, &u8) voidptr
fn C.window_set_avatar_card_value(&WindowInfo, &u8, &u8, &u8, &u8)
fn C.window_add_time_picker_control(&WindowInfo, &u8, &u8) voidptr
fn C.window_set_time_picker_value(&WindowInfo, &u8, &u8)
fn C.window_get_time_picker_value(&WindowInfo, &u8) &u8
fn C.window_add_tray_icon_control(&WindowInfo, &u8, &u8, &u8)
fn C.window_set_tray_icon_value(&WindowInfo, &u8, &u8, &u8)
fn C.window_add_collapsible_section_control(&WindowInfo, &u8, &u8, int) voidptr
fn C.window_set_collapsible_section_expanded(&WindowInfo, &u8, int)
fn C.window_add_code_editor_control(&WindowInfo, &u8, &u8, int) voidptr
fn C.window_set_code_editor_value(&WindowInfo, &u8, &u8)
fn C.window_get_code_editor_value(&WindowInfo, &u8) &u8
fn C.window_add_timeline_view_control(&WindowInfo, &u8, int) voidptr
fn C.window_add_timeline_entry(&WindowInfo, &u8, &u8, &u8, &u8, &u8)
fn C.window_clear_timeline(&WindowInfo, &u8)
fn C.window_add_toolbar_button(&WindowInfo, &u8, &u8, &u8)
fn C.window_set_toolbar_visible(&WindowInfo, int)

fn C.window_grid_get_row_values(&WindowInfo, &u8, int, &&u8, int) int
fn C.window_set_checkbox_state(&WindowInfo, int)
fn C.window_set_input_text(&WindowInfo, &u8)
fn C.window_set_number_value(&WindowInfo, int)
fn C.window_set_text_area(&WindowInfo, &u8)

fn C.window_set_subtitle(&WindowInfo, &u8)
fn C.window_get_subtitle(&WindowInfo) &u8
fn C.window_set_titlebar_appears_transparent(&WindowInfo, int)
fn C.window_get_titlebar_appears_transparent(&WindowInfo) int
fn C.window_set_full_size_content_view(&WindowInfo, int)
fn C.window_get_full_size_content_view(&WindowInfo) int
fn C.window_set_movable(&WindowInfo, int)
fn C.window_get_movable(&WindowInfo) int
fn C.window_set_window_level(&WindowInfo, &u8)
fn C.window_set_aspect_ratio(&WindowInfo, f64, f64)
fn C.window_reset_aspect_ratio(&WindowInfo)
fn C.window_bounce_dock_icon(int)

fn C.window_set_vibrancy(&WindowInfo, &u8)
fn C.window_set_corner_radius(&WindowInfo, f64)
fn C.window_get_corner_radius(&WindowInfo) f64
fn C.window_set_background_blur(&WindowInfo, int)
fn C.window_flash_frame(&WindowInfo, int)
fn C.window_center_on_active_screen(&WindowInfo)
fn C.window_set_level_type(&WindowInfo, &u8)
fn C.window_get_window_level(&WindowInfo) &u8
fn C.window_set_fullscreen(&WindowInfo, int)
fn C.window_snap_to_edge(&WindowInfo, &u8)
fn C.window_set_bounds(&WindowInfo, int, int, int, int)
fn C.window_get_bounds(&WindowInfo, &int, &int, &int, &int)
fn C.window_has_aspect_ratio(&WindowInfo) int
fn C.window_set_ignores_mouse_events(&WindowInfo, int)
fn C.window_get_ignores_mouse_events(&WindowInfo) int
fn C.window_set_hides_on_deactivate(&WindowInfo, int)
fn C.window_get_hides_on_deactivate(&WindowInfo) int
fn C.window_set_prevents_app_termination(&WindowInfo, int)
fn C.window_get_prevents_app_termination(&WindowInfo) int
fn C.window_set_represented_filename(&WindowInfo, &u8)
fn C.window_get_represented_filename(&WindowInfo) &u8
fn C.window_set_frame_autosave_name(&WindowInfo, &u8)
fn C.window_get_frame_autosave_name(&WindowInfo) &u8
fn C.window_save_frame(&WindowInfo) int
fn C.window_restore_frame(&WindowInfo) int
fn C.window_capture_screenshot(&WindowInfo, &u8) int
fn C.window_set_document_edited(&WindowInfo, int)
fn C.window_is_document_edited(&WindowInfo) int
fn C.window_fade_in(&WindowInfo, int)
fn C.window_fade_out(&WindowInfo, int)
fn C.window_order_front(&WindowInfo)
fn C.window_order_back(&WindowInfo)

fn C.window_add_rating_control(&WindowInfo, &u8, int, int) voidptr
fn C.window_set_rating_value(&WindowInfo, &u8, int)
fn C.window_get_rating_value(&WindowInfo, &u8) int

fn C.window_add_range_slider_control(&WindowInfo, &u8, int, int, int, int) voidptr
fn C.window_set_range_slider_values(&WindowInfo, &u8, int, int)
fn C.window_get_range_slider_low(&WindowInfo, &u8) int
fn C.window_get_range_slider_high(&WindowInfo, &u8) int

fn C.window_add_split_button_control(&WindowInfo, &u8, &u8, &&u8, int) voidptr
fn C.window_add_tag_cloud_control(&WindowInfo, &u8, &&u8, int) voidptr
fn C.window_set_tag_cloud_tags(&WindowInfo, &u8, &&u8, int)
fn C.window_add_wizard_stepper_control(&WindowInfo, &u8, &&u8, int, int) voidptr
fn C.window_set_wizard_stepper_step(&WindowInfo, &u8, int)

fn C.window_add_gauge_control(&WindowInfo, &u8, &u8, int, int, int, &u8) voidptr
fn C.window_set_gauge_value(&WindowInfo, &u8, int)
fn C.window_get_gauge_value(&WindowInfo, &u8) int

fn C.window_add_pagination_control(&WindowInfo, &u8, int, int) voidptr
fn C.window_set_pagination_page(&WindowInfo, &u8, int, int)
fn C.window_get_pagination_page(&WindowInfo, &u8) int

fn C.window_add_activity_feed_control(&WindowInfo, &u8, int) voidptr
fn C.window_add_activity_feed_item(&WindowInfo, &u8, &u8, &u8, &u8)
fn C.window_clear_activity_feed(&WindowInfo, &u8)

fn C.window_add_markdown_view_control(&WindowInfo, &u8, &u8, int) voidptr
fn C.window_set_markdown_view_text(&WindowInfo, &u8, &u8)
fn C.window_get_markdown_view_text(&WindowInfo, &u8) &u8

fn C.window_add_sparkline_control(&WindowInfo, &u8, &f64, int, int) voidptr
fn C.window_set_sparkline_data(&WindowInfo, &u8, &f64, int)

fn C.window_add_pin_code_control(&WindowInfo, &u8, int) voidptr
fn C.window_set_pin_code_value(&WindowInfo, &u8, &u8)
fn C.window_get_pin_code_value(&WindowInfo, &u8) &u8

fn C.window_add_color_palette_control(&WindowInfo, &u8, &&u8, int, &u8) voidptr
fn C.window_set_color_palette_selected(&WindowInfo, &u8, &u8)
fn C.window_get_color_palette_selected(&WindowInfo, &u8) &u8

fn C.window_add_timeline_control(&WindowInfo, &u8, int) voidptr
fn C.window_add_timeline_item(&WindowInfo, &u8, &u8, &u8, &u8, &u8)

fn C.window_add_metric_card_control(&WindowInfo, &u8, &u8, &u8, &u8, &u8) voidptr

fn C.window_set_metric_card_value(&WindowInfo, &u8, &u8, &u8)

fn C.window_add_tab_pills_control(&WindowInfo, &u8, &&u8, int, &u8) voidptr
fn C.window_set_tab_pills_active(&WindowInfo, &u8, &u8)
fn C.window_get_tab_pills_active(&WindowInfo, &u8) &u8

fn C.window_add_transfer_list_control(&WindowInfo, &u8, &&u8, int, &&u8, int, bool) voidptr

fn C.window_add_audio_waveform_control(&WindowInfo, &u8, &f64, int, int) voidptr
fn C.window_set_audio_waveform_data(&WindowInfo, &u8, &f64, int)

fn C.window_add_rating_breakdown_control(&WindowInfo, &u8, f64, int, &f64, int) voidptr
fn C.window_set_rating_breakdown_data(&WindowInfo, &u8, f64, int, &f64, int)

fn C.window_add_code_view_control(&WindowInfo, &u8, &u8, &u8, int) voidptr
fn C.window_set_code_view_text(&WindowInfo, &u8, &u8)
fn C.window_get_code_view_text(&WindowInfo, &u8) &u8

fn C.window_add_alert_banner_control(&WindowInfo, &u8, &u8, &u8, &u8) voidptr
fn C.window_set_alert_banner_value(&WindowInfo, &u8, &u8, &u8, &u8)

fn C.window_add_step_tracker_control(&WindowInfo, &u8, &&u8, int, int) voidptr
fn C.window_set_step_tracker_step(&WindowInfo, &u8, int)
fn C.window_get_step_tracker_step(&WindowInfo, &u8) int

fn C.window_add_filter_chips_control(&WindowInfo, &u8, &&u8, int, &&u8, int, bool) voidptr
fn C.window_set_filter_chips_selected(&WindowInfo, &u8, &&u8, int)
fn C.window_get_filter_chips_selected(&WindowInfo, &u8) &u8

fn C.window_add_file_picker_field_control(&WindowInfo, &u8, &u8, &u8, bool) voidptr
fn C.window_set_file_picker_path(&WindowInfo, &u8, &u8)
fn C.window_get_file_picker_path(&WindowInfo, &u8) &u8

fn C.window_add_radial_gauge_control(&WindowInfo, &u8, &u8, f64, f64, f64, &u8) voidptr
fn C.window_set_radial_gauge_value(&WindowInfo, &u8, f64)
fn C.window_get_radial_gauge_value(&WindowInfo, &u8) f64

fn C.window_add_key_value_card_control(&WindowInfo, &u8, &u8, &&u8, &&u8, int) voidptr
fn C.window_set_key_value_card_data(&WindowInfo, &u8, &&u8, &&u8, int)

fn C.window_add_diff_view_control(&WindowInfo, &u8, &u8, &u8, int) voidptr
fn C.window_set_diff_view_text(&WindowInfo, &u8, &u8, &u8)
fn C.window_add_json_tree_control(&WindowInfo, &u8, &u8, int) voidptr
fn C.window_set_json_tree_data(&WindowInfo, &u8, &u8)
fn C.window_add_http_request_card_control(&WindowInfo, &u8, &u8, &u8, int, int) voidptr
fn C.window_set_http_request_card_data(&WindowInfo, &u8, &u8, &u8, int, int)
fn C.window_add_terminal_view_control(&WindowInfo, &u8, &u8, int) voidptr
fn C.window_append_terminal_line(&WindowInfo, &u8, &u8, int)
fn C.window_clear_terminal(&WindowInfo, &u8)
fn C.window_add_resource_monitor_control(&WindowInfo, &u8, int, int, int, int) voidptr
fn C.window_set_resource_monitor_metrics(&WindowInfo, &u8, int, int, int, int)
fn C.window_add_env_vars_control(&WindowInfo, &u8, &u8, &&u8, &&u8, int) voidptr
fn C.window_set_env_vars_data(&WindowInfo, &u8, &&u8, &&u8, int)

fn C.window_add_badge_button_control(&WindowInfo, &u8, &u8, int, &u8) voidptr
fn C.window_set_badge_button_count(&WindowInfo, &u8, int)
fn C.window_add_command_palette_control(&WindowInfo, &u8, &u8, &u8) voidptr
fn C.window_set_command_palette_text(&WindowInfo, &u8, &u8)
fn C.window_add_status_banner_control(&WindowInfo, &u8, &u8, &u8, &u8) voidptr
fn C.window_set_status_banner_text(&WindowInfo, &u8, &u8, &u8, &u8)
fn C.window_add_pill_toggle_control(&WindowInfo, &u8, &&u8, int, int) voidptr
fn C.window_set_pill_toggle_selected(&WindowInfo, &u8, int)
fn C.window_add_color_swatch_panel_control(&WindowInfo, &u8, &&u8, int, &u8) voidptr
fn C.window_set_color_swatch_selected(&WindowInfo, &u8, &u8)
fn C.window_add_hotkey_badge_control(&WindowInfo, &u8, &u8, &u8) voidptr
fn C.window_set_hotkey_badge_shortcut(&WindowInfo, &u8, &u8, &u8)

// 6 New UI Controls C declarations
fn C.window_add_quick_action_bar_control(&WindowInfo, &u8, &&u8, &&u8, int) voidptr
fn C.window_set_quick_action_enabled(&WindowInfo, &u8, int, int)
fn C.window_add_accordion_group_control(&WindowInfo, &u8, &&u8, int, int) voidptr
fn C.window_set_accordion_expanded(&WindowInfo, &u8, int, int)
fn C.window_add_segment_distribution_bar_control(&WindowInfo, &u8, &&u8, &f64, &&u8, int, int) voidptr
fn C.window_set_segment_distribution_values(&WindowInfo, &u8, &f64, int)
fn C.window_add_tag_input_field_control(&WindowInfo, &u8, &&u8, int) voidptr
fn C.window_set_tag_input_tags(&WindowInfo, &u8, &&u8, int)
fn C.window_get_tag_input_tags(&WindowInfo, &u8) &u8
fn C.window_add_status_dock_control(&WindowInfo, &u8, &u8, &u8, &u8) voidptr
fn C.window_set_status_dock_info(&WindowInfo, &u8, &u8, &u8, &u8)
fn C.window_add_info_callout_control(&WindowInfo, &u8, &u8, &u8, &u8, &u8) voidptr
fn C.window_set_info_callout_text(&WindowInfo, &u8, &u8, &u8)

fn C.window_set_alpha(&WindowInfo, f64)
fn C.window_get_alpha(&WindowInfo) f64
fn C.window_get_min_size(&WindowInfo, &int, &int)
fn C.window_get_max_size(&WindowInfo, &int, &int)
fn C.window_set_collection_behavior(&WindowInfo, &u8)
fn C.window_set_close_button_enabled(&WindowInfo, int)
fn C.window_set_minimize_button_enabled(&WindowInfo, int)
fn C.window_set_zoom_button_enabled(&WindowInfo, int)
fn C.window_set_content_insets(&WindowInfo, int, int, int, int)
fn C.window_set_tabbing_mode(&WindowInfo, &u8)
fn C.window_get_tabbing_mode(&WindowInfo) &char
fn C.window_set_tabbing_identifier(&WindowInfo, &u8)
fn C.window_get_tabbing_identifier(&WindowInfo) &char
fn C.window_toggle_tab_bar(&WindowInfo)
fn C.window_select_next_tab(&WindowInfo)
fn C.window_select_previous_tab(&WindowInfo)
fn C.window_set_sharing_type(&WindowInfo, &u8)

// Appearance Override
fn C.window_set_window_appearance(&WindowInfo, &u8)
fn C.window_get_window_appearance(&WindowInfo) &char
fn C.window_is_system_dark_mode(&WindowInfo) int

// Screen Info
fn C.window_get_screen_frame(&WindowInfo, &int, &int, &int, &int)
fn C.window_get_screen_full_frame(&WindowInfo, &int, &int, &int, &int)
fn C.window_get_screen_scale_factor(&WindowInfo) f64

// Cursor Control
fn C.window_set_cursor_hidden(&WindowInfo, int)
fn C.window_set_cursor(&WindowInfo, &u8)
fn C.window_get_cursor(&WindowInfo) &u8
fn C.window_set_cursor_scale(&WindowInfo, f64)
fn C.window_get_cursor_scale(&WindowInfo) f64
fn C.window_reset_cursor(&WindowInfo)
fn C.window_push_cursor(&WindowInfo, &u8)
fn C.window_pop_cursor(&WindowInfo)
fn C.window_set_control_cursor_by_name(&WindowInfo, &u8, &u8)
fn C.window_get_mouse_location(&WindowInfo, &int, &int)
fn C.window_move_cursor_to(&WindowInfo, int, int)

// Resize Indicator
fn C.window_set_shows_resize_indicator(&WindowInfo, int)
fn C.window_get_shows_resize_indicator(&WindowInfo) int

// Content Size Constraints
fn C.window_set_content_min_size(&WindowInfo, int, int)
fn C.window_set_content_max_size(&WindowInfo, int, int)
fn C.window_get_content_min_size(&WindowInfo, &int, &int)
fn C.window_get_content_max_size(&WindowInfo, &int, &int)

// Tab Count
fn C.window_get_tab_count(&WindowInfo) int

pub type StringEventCallback = fn (mut win SimpleWindow, value string)

pub type VoidEventCallback = fn (mut win SimpleWindow)

pub type FileDropCallback = fn (mut win SimpleWindow, files []string)

pub type ControlValidator = fn (value string) string

pub struct MenuItem {
pub:
	title    string
	shortcut string
	callback VoidEventCallback = unsafe { nil }
}

pub struct WindowConfig {
pub mut:
	title                        string
	width                        int
	height                       int
	padding                      int
	spacing                      int
	background_color             string
	font_color                   string
	always_on_top                bool
	responsive_layout            bool
	resizable                    bool
	minimizable                  bool
	maximizable                  bool
	closable                     bool
	has_shadow                   bool
	movable_by_window_background bool
	titlebar_visible             bool
	title_visible                bool
}

pub struct WindowParams {
	title                        string
	width                        int
	height                       int
	win_ptr                      voidptr
	padding                      int
	spacing                      int
	always_on_top                int
	responsive_layout            int
	resizable                    int
	minimizable                  int
	maximizable                  int
	closable                     int
	has_shadow                   int
	movable_by_window_background int
	titlebar_visible             int
	title_visible                int
}

pub struct WindowInfo {
	app          voidptr
	app_delegate voidptr
}

@[heap]
pub struct SimpleWindow {
mut:
	window_info                  &WindowInfo = unsafe { nil }
	width                        int
	height                       int
	title                        string
	controls                     []ControlEntry
	status_text                  string
	handlers                     []ControlEventHandler
	background_color             string
	font_color                   string
	padding                      int
	spacing                      int
	always_on_top                bool
	responsive_layout            bool = true
	placeholders                 map[string]string
	tooltips                     map[string]string
	errors                       map[string]string
	default_button               string
	debug_mode                   bool
	last_control                 string
	min_width                    int
	min_height                   int
	max_width                    int
	max_height                   int
	resizable                    bool = true
	minimizable                  bool = true
	maximizable                  bool = true
	closable                     bool = true
	has_shadow                   bool = true
	movable_by_window_background bool
	titlebar_visible             bool = true
	title_visible                bool = true
	subtitle                     string
	corner_radius                f64
	vibrancy_material            string
	window_level                 string = 'normal'
	movable                      bool   = true
	ignores_mouse_events         bool
	hides_on_deactivate          bool
	prevents_app_termination     bool = true
	represented_filename         string
	frame_autosave_name          string
	document_edited              bool
	titlebar_appears_transparent bool
	full_size_content_view       bool
	background_blur              bool
	list_items                   map[string][]string
	tree_nodes                   map[string][]TreeNode
	table_rows                   map[string][][]string
	grid_rows                    map[string][][]string
	grid_headers                 map[string][]string
pub mut:
	ws_client voidptr = unsafe { nil }
}

struct ControlEntry {
mut:
	name             string
	kind             string
	label            string
	value            string
	checked          bool
	number           int
	background_color string
	font_color       string
	width            int
	height           int
	font_size        int
	visible          bool = true
	enabled          bool = true
	initial_value    string
	initial_checked  bool
	initial_number   int
	placeholder      string
	error_text       string
	alignment        string
	expand_fill      bool
}

struct ControlEventHandler {
mut:
	control_name string
	event_name   string
	filter_value string
	string_cb    StringEventCallback = unsafe { nil }
	void_cb      VoidEventCallback   = unsafe { nil }
	file_drop_cb FileDropCallback    = unsafe { nil }
}

// new_simple_window creates and initializes a new SimpleWindow instance.
pub fn new_simple_window(title string, width int, height int) &SimpleWindow {
	mut win := &SimpleWindow{
		width:                        width
		height:                       height
		title:                        title
		responsive_layout:            true
		resizable:                    true
		minimizable:                  true
		maximizable:                  true
		closable:                     true
		has_shadow:                   true
		movable_by_window_background: false
	}
	win.placeholders = map[string]string{}
	win.tooltips = map[string]string{}
	win.errors = map[string]string{}
	win.tree_nodes = map[string][]TreeNode{}
	win.grid_rows = map[string][][]string{}
	win.grid_headers = map[string][]string{}
	win.ensure_window()
	return win
}

// ensure_window performs ensure window.
fn (win &SimpleWindow) ensure_window() {
	if win.window_info == unsafe { nil } {
		params := WindowParams{
			title:                        win.title
			width:                        win.width
			height:                       win.height
			win_ptr:                      win
			padding:                      win.padding
			spacing:                      win.spacing
			always_on_top:                if win.always_on_top { 1 } else { 0 }
			responsive_layout:            if win.responsive_layout { 1 } else { 0 }
			resizable:                    if win.resizable { 1 } else { 0 }
			minimizable:                  if win.minimizable { 1 } else { 0 }
			maximizable:                  if win.maximizable { 1 } else { 0 }
			closable:                     if win.closable { 1 } else { 0 }
			has_shadow:                   if win.has_shadow { 1 } else { 0 }
			movable_by_window_background: if win.movable_by_window_background { 1 } else { 0 }
			titlebar_visible:             if win.titlebar_visible { 1 } else { 0 }
			title_visible:                if win.title_visible { 1 } else { 0 }
		}
		unsafe {
			mut w := &SimpleWindow(win)
			w.window_info = C.window_app_init(&params)
		}
	}
}

// has_control performs has control.
pub fn (win &SimpleWindow) has_control(name string) bool {
	return win.find_control(name) >= 0
}

// list_controls performs list controls.
pub fn (win &SimpleWindow) list_controls() []string {
	mut names := []string{}
	for control in win.controls {
		names << control.name
	}
	return names
}

// get_control_kind returns the kind of the specified control.
pub fn (win &SimpleWindow) get_control_kind(name string) string {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].kind
	}
	return ''
}

// require_control performs require control.
pub fn (win &SimpleWindow) require_control(name string) string {
	if win.has_control(name) {
		return name
	}
	panic('Control "${name}" was not found. Create it first with add_input/add_button/etc.')
}

// find_control performs find control.
fn (win &SimpleWindow) find_control(name string) int {
	for i, control in win.controls {
		if control.name == name {
			return i
		}
	}
	return -1
}

// find_handler performs find handler.
fn (win &SimpleWindow) find_handler(control_name string, event_name string) int {
	for i, handler in win.handlers {
		if handler.control_name == control_name && handler.event_name == event_name
			&& handler.filter_value == '' {
			return i
		}
	}
	return -1
}

// normalize_key_shortcut converts key shortcut strings (e.g. "⌘+⇧+P", "Cmd+Shift+P", "cmd+shift+p") into canonical form "cmd+shift+p".
pub fn normalize_key_shortcut(input string) string {
	if input == '' {
		return ''
	}
	mut s := input.to_lower()
	s = s.replace('⌘', 'cmd+')
	s = s.replace('⇧', 'shift+')
	s = s.replace('⌥', 'opt+')
	s = s.replace('⌃', 'ctrl+')
	s = s.replace('command', 'cmd')
	s = s.replace('control', 'ctrl')
	s = s.replace('option', 'opt')
	s = s.replace('alt', 'opt')
	s = s.replace(' ', '')

	parts := s.split('+')
	mut has_cmd := false
	mut has_ctrl := false
	mut has_opt := false
	mut has_shift := false
	mut key_parts := []string{}

	for part in parts {
		match part {
			'cmd', 'meta' { has_cmd = true }
			'ctrl' { has_ctrl = true }
			'opt' { has_opt = true }
			'shift' { has_shift = true }
			'' {}
			else { key_parts << part }
		}
	}

	mut res := []string{}
	if has_cmd {
		res << 'cmd'
	}
	if has_ctrl {
		res << 'ctrl'
	}
	if has_opt {
		res << 'opt'
	}
	if has_shift {
		res << 'shift'
	}
	if key_parts.len > 0 {
		res << key_parts.join('+')
	}

	return res.join('+')
}

// find_handler_by_filter performs find handler by filter.
fn (win &SimpleWindow) find_handler_by_filter(control_name string, event_name string, filter_value string) int {
	norm_filter := if event_name == 'key' {
		normalize_key_shortcut(filter_value)
	} else {
		filter_value
	}
	// First pass: exact filter match
	for i, handler in win.handlers {
		if handler.control_name == control_name && handler.event_name == event_name {
			h_filter := if event_name == 'key' {
				normalize_key_shortcut(handler.filter_value)
			} else {
				handler.filter_value
			}
			if h_filter != '' && h_filter == norm_filter {
				return i
			}
		}
	}
	// Second pass: wildcard match
	for i, handler in win.handlers {
		if handler.control_name == control_name && handler.event_name == event_name {
			h_filter := if event_name == 'key' {
				normalize_key_shortcut(handler.filter_value)
			} else {
				handler.filter_value
			}
			if h_filter == '' {
				return i
			}
		}
	}
	return -1
}

// auto_name performs auto name.
fn (win &SimpleWindow) auto_name(kind string) string {
	return 'auto_${kind}_${win.controls.len}'
}

// upsert_control performs upsert control.
fn (win &SimpleWindow) upsert_control(name string, kind string, label string, value string, checked bool, number int) {
	idx := win.find_control(name)
	mut entry := ControlEntry{
		name:            name
		kind:            kind
		label:           label
		value:           value
		checked:         checked
		number:          number
		visible:         true
		enabled:         true
		initial_value:   value
		initial_checked: checked
		initial_number:  number
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.last_control = name
		if idx >= 0 {
			entry = w.controls[idx]
			entry.kind = kind
			entry.label = label
			entry.value = value
			entry.checked = checked
			entry.number = number
			entry.background_color = w.controls[idx].background_color
			entry.font_color = w.controls[idx].font_color
			entry.visible = w.controls[idx].visible
			entry.enabled = w.controls[idx].enabled
			w.controls[idx] = entry
		} else {
			w.controls << entry
		}
	}
}

// Control creation methods
pub fn (win &SimpleWindow) add_label(name string, text string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('label')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "label", Value: "${text}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'label', text, text, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_label_control(win.window_info, real_name.str, text.str)
	}
	return win
}

// add_input adds a input control to the window layout.
pub fn (win &SimpleWindow) add_input(name string, value string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('input')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "input", Value: "${value}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'input', '', value, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_input_control(win.window_info, real_name.str, value.str)
	}
	return win
}

// add_password adds a password control to the window layout.
pub fn (win &SimpleWindow) add_password(name string, value string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('password')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "password")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'password', '', value, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_password_control(win.window_info, real_name.str, value.str)
	}
	return win
}

// add_textarea adds a textarea control to the window layout.
pub fn (win &SimpleWindow) add_textarea(name string, value string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('textarea')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "textarea", Value: "${value}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'textarea', '', value, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_textarea_control(win.window_info, real_name.str, value.str)
	}
	return win
}

// add_html_view adds a html view control to the window layout.
pub fn (win &SimpleWindow) add_html_view(name string, html string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('htmlview')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "htmlview")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'htmlview', '', html, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_html_view_control(win.window_info, real_name.str, html.str)
	}
	return win
}

// add_drop_zone adds a drop zone control to the window layout.
pub fn (win &SimpleWindow) add_drop_zone(name string, label string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('dropzone')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "dropzone", Label: "${label}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'dropzone', label, '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_drop_zone_control(win.window_info, real_name.str, label.str)
	}
	return win
}

// add_button adds a button control to the window layout.
pub fn (win &SimpleWindow) add_button(name string, title string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('button')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "button", Title: "${title}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'button', title, '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_button_control(win.window_info, real_name.str, title.str)
	}
	return win
}

// add_link adds a link control to the window layout.
pub fn (win &SimpleWindow) add_link(name string, text string, url string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('link')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "link", Text: "${text}", URL: "${url}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'link', text, url, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_link_control(win.window_info, real_name.str, text.str, url.str)
	}
	return win
}

// add_checkbox adds a checkbox control to the window layout.
pub fn (win &SimpleWindow) add_checkbox(name string, label string, checked bool) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('checkbox')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "checkbox", Label: "${label}", Checked: ${checked})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'checkbox', label, '', checked, 0)
	}
	if win.window_info != unsafe { nil } {
		checked_val := if checked { 1 } else { 0 }
		C.window_add_checkbox_control(win.window_info, real_name.str, label.str, checked_val)
	}
	return win
}

// add_disclosure adds a disclosure control to the window layout.
pub fn (win &SimpleWindow) add_disclosure(name string, title string, open bool) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('disclosure')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "disclosure", Title: "${title}", Open: ${open})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'disclosure', title, '', open, 0)
	}
	if win.window_info != unsafe { nil } {
		open_val := if open { 1 } else { 0 }
		C.window_add_disclosure_control(win.window_info, real_name.str, title.str, open_val)
	}
	return win
}

// add_number adds a number control to the window layout.
pub fn (win &SimpleWindow) add_number(name string, value int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('number')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "number", Value: ${value})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'number', '', '', false, value)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_number_control(win.window_info, real_name.str, value)
	}
	return win
}

// add_slider adds a slider control to the window layout.
pub fn (win &SimpleWindow) add_slider(name string, value int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('slider')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "slider", Value: ${value})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'slider', '', value.str(), false, value)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_slider_control(win.window_info, real_name.str, value)
	}
	return win
}

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

// add_color_well adds a color well control to the window layout.
pub fn (win &SimpleWindow) add_color_well(name string, color string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('color')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "color", Color: "${color}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'color', '', color, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_color_well_control(win.window_info, real_name.str, color.str)
	}
	return win
}

// add_date_picker adds a date picker control to the window layout.
pub fn (win &SimpleWindow) add_date_picker(name string, date string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('date')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "date", Date: "${date}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'date', '', date, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_date_picker_control(win.window_info, real_name.str, date.str)
	}
	return win
}

// add_date_time_picker adds a date-time picker control to the window layout.
pub fn (win &SimpleWindow) add_date_time_picker(name string, datetime string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('datetime')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "datetime", DateTime: "${datetime}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'datetime', '', datetime, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_date_time_picker_control(win.window_info, real_name.str, datetime.str)
	}
	return win
}

// add_mode_control adds a mode control control to the window layout.
pub fn (win &SimpleWindow) add_mode_control(name string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('mode')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "mode", Selected: "${selected}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'mode', '', selected, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_mode_control_control(win.window_info, real_name.str, selected.str)
	}
	return win
}

// add_progress_indicator adds a progress indicator control to the window layout.
pub fn (win &SimpleWindow) add_progress_indicator(name string, value int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('progress')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "progress", Value: ${value})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'progress', '', value.str(), false, value)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_progress_indicator_control(win.window_info, real_name.str, value)
	}
	return win
}

// add_dropdown adds a dropdown control to the window layout.
pub fn (win &SimpleWindow) add_dropdown(name string, items []string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('dropdown')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "dropdown", Selected: "${selected}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'dropdown', selected, selected, false, 0)
	}
	if win.window_info != unsafe { nil } {
		mut c_items := []&u8{}
		for item in items {
			c_items << item.str
		}
		C.window_add_dropdown_control(win.window_info, real_name.str, c_items.data, items.len,
			selected.str)
	}
	return win
}

// add_segmented_control adds a segmented control control to the window layout.
pub fn (win &SimpleWindow) add_segmented_control(name string, items []string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('segmented')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "segmented", Selected: "${selected}")')
	}
	mut sel_idx := -1
	for idx, val in items {
		if val == selected {
			sel_idx = idx
			break
		}
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'segmented', selected, selected, false, sel_idx)
	}
	if win.window_info != unsafe { nil } {
		mut c_items := []&u8{}
		for item in items {
			c_items << item.str
		}
		C.window_add_segmented_control_custom(win.window_info, real_name.str, c_items.data,
			items.len, selected.str)
	}
	return win
}

// add_radio_group adds a radio group control to the window layout.
pub fn (win &SimpleWindow) add_radio_group(name string, items []string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('radiogroup')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "radiogroup", Selected: "${selected}")')
	}
	mut sel_idx := -1
	for idx, val in items {
		if val == selected {
			sel_idx = idx
			break
		}
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'radiogroup', selected, selected, false, sel_idx)
	}
	if win.window_info != unsafe { nil } {
		mut c_items := []&u8{}
		for item in items {
			c_items << item.str
		}
		C.window_add_radio_group_control(win.window_info, real_name.str, c_items.data,
			items.len, selected.str)
	}
	return win
}

// add_switch adds a switch control to the window layout.
pub fn (win &SimpleWindow) add_switch(name string, label string, checked bool) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('switch')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "switch", Label: "${label}", Checked: ${checked})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'switch', label, '', checked, 0)
	}
	if win.window_info != unsafe { nil } {
		checked_val := if checked { 1 } else { 0 }
		C.window_add_switch_control(win.window_info, real_name.str, label.str, checked_val)
	}
	return win
}

// add_search_field adds a search field control to the window layout.
pub fn (win &SimpleWindow) add_search_field(name string, placeholder string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('search')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "search", Placeholder: "${placeholder}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'search', '', '', false, 0)
		w.set_placeholder(real_name, placeholder)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_search_field_control(win.window_info, real_name.str, placeholder.str)
	}
	return win
}

// add_combo_box adds a combo box control to the window layout.
pub fn (win &SimpleWindow) add_combo_box(name string, items []string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('combobox')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "combobox", Selected: "${selected}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'combobox', selected, selected, false, 0)
	}
	if win.window_info != unsafe { nil } {
		mut c_items := []&u8{}
		for item in items {
			c_items << item.str
		}
		C.window_add_combo_box_control(win.window_info, real_name.str, c_items.data, items.len,
			selected.str)
	}
	return win
}

// add_level_indicator adds a level indicator control to the window layout.
pub fn (win &SimpleWindow) add_level_indicator(name string, style int, min_val int, max_val int, value int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('levelindicator')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "levelindicator", Style: ${style}, Min: ${min_val}, Max: ${max_val}, Value: ${value})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'levelindicator', '', value.str(), false, value)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_level_indicator_control(win.window_info, real_name.str, style, min_val,
			max_val, value)
	}
	return win
}

// add_rating adds a rating control to the window layout.
pub fn (win &SimpleWindow) add_rating(name string, value int) &SimpleWindow {
	return win.add_level_indicator(name, 3, 0, 5, value)
}

// add_spinner adds a spinner control to the window layout.
pub fn (win &SimpleWindow) add_spinner(name string, active bool) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('spinner')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "spinner", Active: ${active})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'spinner', '', if active { 'true' } else { 'false' },
			active, 0)
	}
	if win.window_info != unsafe { nil } {
		act_val := if active { 1 } else { 0 }
		C.window_add_spinner_control(win.window_info, real_name.str, act_val)
	}
	return win
}

// add_path_control adds a path control control to the window layout.
pub fn (win &SimpleWindow) add_path_control(name string, path string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('pathcontrol')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "pathcontrol", Path: "${path}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'pathcontrol', '', path, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_path_control(win.window_info, real_name.str, path.str)
	}
	return win
}

// add_token_field adds a token field control to the window layout.
pub fn (win &SimpleWindow) add_token_field(name string, value string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('tokenfield')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "tokenfield", Value: "${value}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'tokenfield', '', value, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_token_field_control(win.window_info, real_name.str, value.str)
	}
	return win
}

// add_console adds a developer-oriented scrollable text console for logs.
pub fn (win &SimpleWindow) add_console(name string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('console')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "console", Height: ${height})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'console', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_console_control(win.window_info, real_name.str, height)
	}
	return win
}

// append_console appends text to a console control and auto-scrolls.
// level: 0 = normal/log, 1 = info (blue), 2 = warning (yellow), 3 = error (red), 4 = success (green)
pub fn (win &SimpleWindow) append_console(name string, text string, level int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_append_console_text(win.window_info, name.str, text.str, level)
	}
	return win
}

// clear_console clears all text in the console control.
pub fn (win &SimpleWindow) clear_console(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_clear_console(win.window_info, name.str)
	}
	return win
}

// add_chart adds a beautiful native line or area chart control.
// chart_type: "line" or "area"
pub fn (win &SimpleWindow) add_chart(name string, chart_type string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('chart')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "chart", Style: "${chart_type}", Height: ${height})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'chart', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_chart_control(win.window_info, real_name.str, chart_type.str, height)
	}
	return win
}

// set_chart_data updates the values drawn in the chart control.
pub fn (win &SimpleWindow) set_chart_data(name string, values []f64) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		if values.len > 0 {
			C.window_set_chart_data(win.window_info, name.str, values.data, values.len)
		}
	}
	return win
}

// add_shortcut_recorder adds a key combination recording control.
// When focused, the user can press a shortcut which triggers the "change" callback.
pub fn (win &SimpleWindow) add_shortcut_recorder(name string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('shortcutrecorder')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "shortcutrecorder")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'shortcutrecorder', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_shortcut_recorder_control(win.window_info, real_name.str)
	}
	return win
}

// add_circular_progress adds a circular progress / gauge indicator control.
pub fn (win &SimpleWindow) add_circular_progress(name string, value int, min_val int, max_val int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('circularprogress')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "circularprogress")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'circularprogress', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_circular_progress_control(win.window_info, real_name.str, f64(value),
			f64(min_val), f64(max_val))
	}
	return win
}

// set_circular_progress updates the value of a circular progress / gauge control.
pub fn (win &SimpleWindow) set_circular_progress(name string, value int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_circular_progress_value(win.window_info, name.str, f64(value))
	}
	return win
}

// add_breadcrumbs adds a breadcrumb / path navigation control.
// The list of segments contains the path elements (e.g. ['Home', 'Projects', 'simplegui']).
// You can handle segment click events by registering an `on_click(name, callback)` event.
pub fn (win &SimpleWindow) add_breadcrumbs(name string, segments []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('breadcrumbs')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "breadcrumbs")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'breadcrumbs', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		mut c_segs := []&u8{}
		for seg in segments {
			c_segs << seg.str
		}
		C.window_add_breadcrumbs_control(win.window_info, real_name.str, c_segs.data,
			c_segs.len)
	}
	return win
}

// set_breadcrumbs updates the segments shown by a breadcrumb control.
pub fn (win &SimpleWindow) set_breadcrumbs(name string, segments []string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		mut c_segs := []&u8{}
		for seg in segments {
			c_segs << seg.str
		}
		C.window_set_breadcrumbs(win.window_info, name.str, c_segs.data, c_segs.len)
	}
	return win
}

// add_property_grid adds a property inspector grid containing key-value rows.
pub fn (win &SimpleWindow) add_property_grid(name string, props map[string]string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('propertygrid')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "propertygrid")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'propertygrid', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		mut keys := []&u8{}
		mut vals := []&u8{}
		for k, v in props {
			keys << k.str
			vals << v.str
		}
		C.window_add_property_grid_control(win.window_info, real_name.str, keys.data,
			vals.data, props.len)
	}
	return win
}

// set_property_grid_value updates a specific property key-value inside the property grid.
pub fn (win &SimpleWindow) set_property_grid_value(name string, key string, value string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_property_grid_value(win.window_info, name.str, key.str, value.str)
	}
	return win
}

// add_color_grid adds an interactive grid of color swatches.
pub fn (win &SimpleWindow) add_color_grid(name string, colors []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('colorgrid')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "colorgrid")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'colorgrid', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		mut c_colors := []&u8{}
		for col in colors {
			c_colors << col.str
		}
		C.window_add_color_grid_control(win.window_info, real_name.str, c_colors.data,
			colors.len)
	}
	return win
}

// set_color_grid_selected selects a color swatch inside the grid by its hex value.
pub fn (win &SimpleWindow) set_color_grid_selected(name string, color string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_color_grid_selected(win.window_info, name.str, color.str)
	}
	return win
}

// add_grid adds a grid control with Excel-like editability and CRUD support.
pub fn (mut win SimpleWindow) add_grid(name string, headers []string, initial_rows [][]string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('grid')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "grid")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'grid', '', '', false, 0)
	}
	win.grid_rows[real_name] = initial_rows.clone()
	win.grid_headers[real_name] = headers.clone()
	if win.window_info != unsafe { nil } {
		mut c_headers := []&u8{}
		for h in headers {
			c_headers << h.str
		}
		C.window_add_grid_control(win.window_info, real_name.str, c_headers.data, headers.len)
		for row in initial_rows {
			mut c_vals := []&u8{}
			for val in row {
				c_vals << val.str
			}
			C.window_grid_add_row(win.window_info, real_name.str, c_vals.data, row.len)
		}
	}
	return &win
}

// grid_add_row appends a row of cell values to the grid.
pub fn (mut win SimpleWindow) grid_add_row(name string, row_values []string) &SimpleWindow {
	mut rows := win.grid_rows[name]
	rows << row_values
	win.grid_rows[name] = rows
	if win.window_info != unsafe { nil } {
		mut c_vals := []&u8{}
		for val in row_values {
			c_vals << val.str
		}
		C.window_grid_add_row(win.window_info, name.str, c_vals.data, row_values.len)
	}
	return &win
}

// grid_delete_row removes the row at index row_idx.
pub fn (mut win SimpleWindow) grid_delete_row(name string, row_idx int) &SimpleWindow {
	mut rows := win.grid_rows[name]
	if row_idx >= 0 && row_idx < rows.len {
		rows.delete(row_idx)
		win.grid_rows[name] = rows
	}
	if win.window_info != unsafe { nil } {
		C.window_grid_delete_row(win.window_info, name.str, row_idx)
	}
	return &win
}

// grid_add_column appends a new column header.
pub fn (mut win SimpleWindow) grid_add_column(name string, header string) &SimpleWindow {
	mut rows := win.grid_rows[name]
	for i in 0 .. rows.len {
		rows[i] << ''
	}
	win.grid_rows[name] = rows
	if win.window_info != unsafe { nil } {
		C.window_grid_add_column(win.window_info, name.str, header.str)
	}
	return &win
}

// grid_delete_column removes a column at index col_idx.
pub fn (mut win SimpleWindow) grid_delete_column(name string, col_idx int) &SimpleWindow {
	mut rows := win.grid_rows[name]
	for i in 0 .. rows.len {
		if col_idx >= 0 && col_idx < rows[i].len {
			rows[i].delete(col_idx)
		}
	}
	win.grid_rows[name] = rows
	if win.window_info != unsafe { nil } {
		C.window_grid_delete_column(win.window_info, name.str, col_idx)
	}
	return &win
}

// grid_set_cell sets the value of cell at row, col.
pub fn (mut win SimpleWindow) grid_set_cell(name string, row int, col int, val string) &SimpleWindow {
	mut rows := win.grid_rows[name]
	if row >= 0 && row < rows.len {
		mut cols := rows[row].clone()
		if col >= 0 && col < cols.len {
			cols[col] = val
			rows[row] = cols
			win.grid_rows[name] = rows
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_grid_set_cell(win.window_info, name.str, row, col, val.str)
	}
	return &win
}

// grid_get_cell returns the string value of cell at row, col.
pub fn (win &SimpleWindow) grid_get_cell(name string, row int, col int) string {
	if win.window_info != unsafe { nil } {
		res := C.window_grid_get_cell(win.window_info, name.str, row, col)
		if res != unsafe { nil } {
			return unsafe { tos_clone(res) }
		}
	}
	rows := win.grid_rows[name]
	if row >= 0 && row < rows.len {
		cols := rows[row]
		if col >= 0 && col < cols.len {
			return cols[col]
		}
	}
	return ''
}

// grid_get_selected_row returns the 0-indexed selected row index, or -1 if none is selected.
pub fn (win &SimpleWindow) grid_get_selected_row(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_grid_get_selected_row(win.window_info, name.str)
	}
	return -1
}

// grid_get_selected_column returns the 0-indexed selected column index, or -1 if none is selected.
pub fn (win &SimpleWindow) grid_get_selected_column(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_grid_get_selected_column(win.window_info, name.str)
	}
	return -1
}

// grid_get_selected_cell returns the currently selected row/column coordinates.
pub fn (win &SimpleWindow) grid_get_selected_cell(name string) (int, int) {
	return win.grid_get_selected_row(name), win.grid_get_selected_column(name)
}

// grid_get_rows returns the current grid data as a [][]string.
pub fn (win &SimpleWindow) grid_get_rows(name string) [][]string {
	return win.grid_rows[name]
}

// grid_set_rows replaces the entire grid data set.
pub fn (mut win SimpleWindow) grid_set_rows(name string, rows [][]string) &SimpleWindow {
	win.grid_rows[name] = rows.clone()
	if win.window_info != unsafe { nil } {
		C.window_grid_clear(win.window_info, name.str)
		for row in rows {
			mut c_vals := []&u8{}
			for val in row {
				c_vals << val.str
			}
			C.window_grid_add_row(win.window_info, name.str, c_vals.data, row.len)
		}
	}
	return &win
}

// grid_get_row returns the current values for a specific row.
pub fn (win &SimpleWindow) grid_get_row(name string, row_idx int) []string {
	rows := win.grid_rows[name]
	if row_idx >= 0 && row_idx < rows.len {
		return rows[row_idx]
	}
	return []string{}
}

// grid_set_row replaces the values for a specific row.
pub fn (mut win SimpleWindow) grid_set_row(name string, row_idx int, values []string) &SimpleWindow {
	mut rows := win.grid_rows[name]
	if row_idx >= 0 && row_idx < rows.len {
		rows[row_idx] = values.clone()
		win.grid_rows[name] = rows
		if win.window_info != unsafe { nil } {
			for idx, value in values {
				win.grid_set_cell(name, row_idx, idx, value)
			}
		}
	}
	return &win
}

// grid_get_column returns the current values for a specific column.
pub fn (win &SimpleWindow) grid_get_column(name string, col_idx int) []string {
	mut values := []string{}
	rows := win.grid_rows[name]
	for row in rows {
		if col_idx >= 0 && col_idx < row.len {
			values << row[col_idx]
		} else {
			values << ''
		}
	}
	return values
}

// grid_set_column replaces the values for a specific column.
pub fn (mut win SimpleWindow) grid_set_column(name string, col_idx int, values []string) &SimpleWindow {
	mut rows := win.grid_rows[name]
	for idx, value in values {
		if idx >= 0 && idx < rows.len {
			mut row_values := rows[idx].clone()
			if col_idx >= 0 && col_idx < row_values.len {
				row_values[col_idx] = value
				rows[idx] = row_values
			}
		}
	}
	win.grid_rows[name] = rows
	if win.window_info != unsafe { nil } {
		for idx, value in values {
			win.grid_set_cell(name, idx, col_idx, value)
		}
	}
	return &win
}

// grid_set_selected_column selects the given column programmatically.
pub fn (mut win SimpleWindow) grid_set_selected_column(name string, col_idx int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_grid_set_selected_column(win.window_info, name.str, col_idx)
	}
	return &win
}

// grid_set_selected_cell selects the given row/column cell programmatically.
pub fn (mut win SimpleWindow) grid_set_selected_cell(name string, row_idx int, col_idx int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_grid_set_selected_cell(win.window_info, name.str, row_idx, col_idx)
	}
	return &win
}

// grid_get_column_editable returns whether a column is editable.
pub fn (win &SimpleWindow) grid_get_column_editable(name string, col_idx int) bool {
	if win.window_info != unsafe { nil } {
		return C.window_grid_get_column_editable(win.window_info, name.str, col_idx) == 1
	}
	return false
}

// grid_get_columns_editable returns editability for a batch of columns.
pub fn (win &SimpleWindow) grid_get_columns_editable(name string, col_idxs []int) map[int]bool {
	mut result := map[int]bool{}
	for col_idx in col_idxs {
		result[col_idx] = win.grid_get_column_editable(name, col_idx)
	}
	return result
}

// grid_set_columns_editable updates editability for a batch of columns.
pub fn (win &SimpleWindow) grid_set_columns_editable(name string, col_idxs []int, editable bool) &SimpleWindow {
	for col_idx in col_idxs {
		win.grid_set_column_editable(name, col_idx, editable)
	}
	return win
}

// grid_get_row_editable returns whether a row is editable.
pub fn (win &SimpleWindow) grid_get_row_editable(name string, row_idx int) bool {
	if win.window_info != unsafe { nil } {
		return C.window_grid_get_row_editable(win.window_info, name.str, row_idx) == 1
	}
	return false
}

// grid_get_rows_editable returns editability for a batch of rows.
pub fn (win &SimpleWindow) grid_get_rows_editable(name string, row_idxs []int) map[int]bool {
	mut result := map[int]bool{}
	for row_idx in row_idxs {
		result[row_idx] = win.grid_get_row_editable(name, row_idx)
	}
	return result
}

// grid_set_rows_editable updates editability for a batch of rows.
pub fn (win &SimpleWindow) grid_set_rows_editable(name string, row_idxs []int, editable bool) &SimpleWindow {
	for row_idx in row_idxs {
		win.grid_set_row_editable(name, row_idx, editable)
	}
	return win
}

// grid_get_cell_editable returns whether a cell is editable.
pub fn (win &SimpleWindow) grid_get_cell_editable(name string, row int, col int) bool {
	if win.window_info != unsafe { nil } {
		return C.window_grid_get_cell_editable(win.window_info, name.str, row, col) == 1
	}
	return false
}

// grid_get_cells_editable returns editability for a batch of cells.
pub fn (win &SimpleWindow) grid_get_cells_editable(name string, cells []string) map[string]bool {
	mut result := map[string]bool{}
	for coord in cells {
		parts := coord.split('_')
		if parts.len == 2 {
			row_idx := parts[0].int()
			col_idx := parts[1].int()
			result[coord] = win.grid_get_cell_editable(name, row_idx, col_idx)
		}
	}
	return result
}

// grid_set_cells_editable updates editability for a batch of cells.
pub fn (win &SimpleWindow) grid_set_cells_editable(name string, cells []string, editable bool) &SimpleWindow {
	for coord in cells {
		parts := coord.split('_')
		if parts.len == 2 {
			row_idx := parts[0].int()
			col_idx := parts[1].int()
			win.grid_set_cell_editable(name, row_idx, col_idx, editable)
		}
	}
	return win
}

// grid_get_column_enabled returns whether a column is enabled.
pub fn (win &SimpleWindow) grid_get_column_enabled(name string, col_idx int) bool {
	if win.window_info != unsafe { nil } {
		return C.window_grid_get_column_enabled(win.window_info, name.str, col_idx) == 1
	}
	return false
}

// grid_get_columns_enabled returns enabled state for a batch of columns.
pub fn (win &SimpleWindow) grid_get_columns_enabled(name string, col_idxs []int) map[int]bool {
	mut result := map[int]bool{}
	for col_idx in col_idxs {
		result[col_idx] = win.grid_get_column_enabled(name, col_idx)
	}
	return result
}

// grid_set_columns_enabled updates enabled state for a batch of columns.
pub fn (win &SimpleWindow) grid_set_columns_enabled(name string, col_idxs []int, enabled bool) &SimpleWindow {
	for col_idx in col_idxs {
		win.grid_set_column_enabled(name, col_idx, enabled)
	}
	return win
}

// grid_get_row_enabled returns whether a row is enabled.
pub fn (win &SimpleWindow) grid_get_row_enabled(name string, row_idx int) bool {
	if win.window_info != unsafe { nil } {
		return C.window_grid_get_row_enabled(win.window_info, name.str, row_idx) == 1
	}
	return false
}

// grid_get_rows_enabled returns enabled state for a batch of rows.
pub fn (win &SimpleWindow) grid_get_rows_enabled(name string, row_idxs []int) map[int]bool {
	mut result := map[int]bool{}
	for row_idx in row_idxs {
		result[row_idx] = win.grid_get_row_enabled(name, row_idx)
	}
	return result
}

// grid_set_rows_enabled updates enabled state for a batch of rows.
pub fn (win &SimpleWindow) grid_set_rows_enabled(name string, row_idxs []int, enabled bool) &SimpleWindow {
	for row_idx in row_idxs {
		win.grid_set_row_enabled(name, row_idx, enabled)
	}
	return win
}

// grid_get_cell_enabled returns whether a cell is enabled.
pub fn (win &SimpleWindow) grid_get_cell_enabled(name string, row int, col int) bool {
	if win.window_info != unsafe { nil } {
		return C.window_grid_get_cell_enabled(win.window_info, name.str, row, col) == 1
	}
	return false
}

// grid_get_cells_enabled returns enabled state for a batch of cells.
pub fn (win &SimpleWindow) grid_get_cells_enabled(name string, cells []string) map[string]bool {
	mut result := map[string]bool{}
	for coord in cells {
		parts := coord.split('_')
		if parts.len == 2 {
			row_idx := parts[0].int()
			col_idx := parts[1].int()
			result[coord] = win.grid_get_cell_enabled(name, row_idx, col_idx)
		}
	}
	return result
}

// grid_set_cells_enabled updates enabled state for a batch of cells.
pub fn (win &SimpleWindow) grid_set_cells_enabled(name string, cells []string, enabled bool) &SimpleWindow {
	for coord in cells {
		parts := coord.split('_')
		if parts.len == 2 {
			row_idx := parts[0].int()
			col_idx := parts[1].int()
			win.grid_set_cell_enabled(name, row_idx, col_idx, enabled)
		}
	}
	return win
}

// grid_get_filter returns the active filter text for a grid.
pub fn (win &SimpleWindow) grid_get_filter(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_grid_get_filter(win.window_info, name.str)
		if res != unsafe { nil } {
			return unsafe { tos_clone(res) }
		}
	}
	return ''
}

// grid_get_row_count returns the current number of rows in a grid.
pub fn (win &SimpleWindow) grid_get_row_count(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_grid_get_row_count(win.window_info, name.str)
	}
	return 0
}

// grid_get_column_count returns the current number of columns in a grid.
pub fn (win &SimpleWindow) grid_get_column_count(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_grid_get_column_count(win.window_info, name.str)
	}
	return 0
}

// grid_get_row_values returns the current values for a row as a []string.
pub fn (win &SimpleWindow) grid_get_row_values(name string, row_idx int) []string {
	mut values := []string{}
	if row_idx >= 0 {
		col_count := win.grid_get_column_count(name)
		for col_idx in 0 .. col_count {
			values << win.grid_get_cell(name, row_idx, col_idx)
		}
	}
	return values
}

// grid_get_column_values returns the current values for a column as a []string.
pub fn (win &SimpleWindow) grid_get_column_values(name string, col_idx int) []string {
	mut values := []string{}
	if col_idx >= 0 {
		row_count := win.grid_get_row_count(name)
		for row_idx in 0 .. row_count {
			values << win.grid_get_cell(name, row_idx, col_idx)
		}
	}
	return values
}

// grid_set_row_values updates every cell in a row from a []string.
pub fn (mut win SimpleWindow) grid_set_row_values(name string, row_idx int, values []string) &SimpleWindow {
	if row_idx >= 0 {
		for idx, value in values {
			win.grid_set_cell(name, row_idx, idx, value)
		}
	}
	return &win
}

// grid_set_column_values updates every cell in a column from a []string.
pub fn (mut win SimpleWindow) grid_set_column_values(name string, col_idx int, values []string) &SimpleWindow {
	if col_idx >= 0 {
		for idx, value in values {
			win.grid_set_cell(name, idx, col_idx, value)
		}
	}
	return &win
}

// grid_set_column_type sets the type of a column (e.g. 'text' or 'checkbox').
pub fn (win &SimpleWindow) grid_set_column_type(name string, col_idx int, col_type string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_grid_set_column_type(win.window_info, name.str, col_idx, col_type.str)
	}
	return win
}

// grid_set_column_width resizes a specific column to a fixed width.
pub fn (win &SimpleWindow) grid_set_column_width(name string, col_idx int, width int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_grid_set_column_width(win.window_info, name.str, col_idx, width)
	}
	return win
}

// grid_set_row_height resizes all rows to a fixed height.
pub fn (win &SimpleWindow) grid_set_row_height(name string, height int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_grid_set_row_height(win.window_info, name.str, height)
	}
	return win
}

// grid_sort_by_column sorts the grid rows by the given column using the current sort direction.
pub fn (win &SimpleWindow) grid_sort_by_column(name string, col_idx int, ascending bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_grid_sort_by_column(win.window_info, name.str, col_idx, if ascending {
			1
		} else {
			0
		})
	}
	return win
}

// grid_set_filter filters visible rows by matching cell contents.
pub fn (win &SimpleWindow) grid_set_filter(name string, query string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_grid_set_filter(win.window_info, name.str, query.str)
	}
	return win
}

// grid_clear_filter removes any active row filter.
pub fn (win &SimpleWindow) grid_clear_filter(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_grid_clear_filter(win.window_info, name.str)
	}
	return win
}

// grid_autosize_columns auto-sizes all columns to fit content.
pub fn (win &SimpleWindow) grid_autosize_columns(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_grid_autosize_columns(win.window_info, name.str)
	}
	return win
}

// grid_set_selected_row sets the selected row index programmatically.
pub fn (win &SimpleWindow) grid_set_selected_row(name string, row_idx int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_grid_set_selected_row(win.window_info, name.str, row_idx)
	}
	return win
}

// grid_clear removes all rows from the grid.
pub fn (win &SimpleWindow) grid_clear(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_grid_clear(win.window_info, name.str)
	}
	return win
}

// grid_set_column_editable enables or disables editing for a column.
pub fn (win &SimpleWindow) grid_set_column_editable(name string, col_idx int, editable bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_grid_set_column_editable(win.window_info, name.str, col_idx, if editable {
			1
		} else {
			0
		})
	}
	return win
}

// grid_set_row_editable enables or disables editing for a row.
pub fn (win &SimpleWindow) grid_set_row_editable(name string, row_idx int, editable bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_grid_set_row_editable(win.window_info, name.str, row_idx, if editable {
			1
		} else {
			0
		})
	}
	return win
}

// grid_set_cell_editable enables or disables editing for a cell.
pub fn (win &SimpleWindow) grid_set_cell_editable(name string, row int, col int, editable bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_grid_set_cell_editable(win.window_info, name.str, row, col, if editable {
			1
		} else {
			0
		})
	}
	return win
}

// grid_set_column_enabled enables or disables a column.
pub fn (win &SimpleWindow) grid_set_column_enabled(name string, col_idx int, enabled bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_grid_set_column_enabled(win.window_info, name.str, col_idx, if enabled {
			1
		} else {
			0
		})
	}
	return win
}

// grid_set_row_enabled enables or disables a row.
pub fn (win &SimpleWindow) grid_set_row_enabled(name string, row_idx int, enabled bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_grid_set_row_enabled(win.window_info, name.str, row_idx, if enabled { 1 } else { 0 })
	}
	return win
}

// grid_set_cell_enabled enables or disables a cell.
pub fn (win &SimpleWindow) grid_set_cell_enabled(name string, row int, col int, enabled bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_grid_set_cell_enabled(win.window_info, name.str, row, col, if enabled {
			1
		} else {
			0
		})
	}
	return win
}

// add_stepper inserts a standalone native NSStepper (up/down arrows) with a live value label.
// Use get_value_int/set_value_int to read or write the current value.
pub fn (win &SimpleWindow) add_stepper(name string, min_val int, max_val int, step int, value int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('stepper')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "stepper", Min: ${min_val}, Max: ${max_val}, Step: ${step}, Value: ${value})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'stepper', '', value.str(), false, value)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_stepper_control(win.window_info, real_name.str, f64(min_val), f64(max_val),
			f64(step), f64(value))
	}
	return win
}

// add_help_button inserts the round native macOS "?" help button (NSBezelStyleHelpButton).
// Attach behavior with .onclick().
pub fn (win &SimpleWindow) add_help_button(name string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('helpbutton')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "helpbutton")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'helpbutton', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_help_button_control(win.window_info, real_name.str)
	}
	return win
}

// add_knob inserts a circular rotary slider (NSSliderTypeCircular) with a live value label.
// Defaults to a 0-100 range; chain .range(min, max) to customize.
pub fn (win &SimpleWindow) add_knob(name string, value int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('knob')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "knob", Value: ${value})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'knob', '', value.str(), false, value)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_knob_control(win.window_info, real_name.str, 0.0, 100.0, f64(value))
	}
	return win
}

// add_pull_down inserts a native pull-down menu button (NSPopUpButton pullsDown:YES).
// The button always shows `title`; choosing an item fires a change event with the item text.
pub fn (win &SimpleWindow) add_pull_down(name string, title string, items []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('pulldown')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "pulldown", Title: "${title}", Items: ${items.len})')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'pulldown', title, '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		mut c_items := []&u8{}
		for item in items {
			c_items << item.str
		}
		C.window_add_pull_down_control(win.window_info, real_name.str, title.str, c_items.data,
			items.len)
	}
	return win
}

// add_image_button inserts a push button decorated with a native SF Symbol image
// (e.g. 'trash', 'gearshape', 'square.and.arrow.up'). Pass an empty title for an icon-only button.
pub fn (win &SimpleWindow) add_image_button(name string, symbol string, title string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('imagebutton')
	}
	if win.debug_mode {
		println('[simplegui DEBUG] Created Control: "${real_name}" (Type: "imagebutton", Symbol: "${symbol}", Title: "${title}")')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'imagebutton', title, symbol, false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_image_button_control(win.window_info, real_name.str, symbol.str,
			title.str)
	}
	return win
}

// configure performs configure.
pub fn (win &SimpleWindow) configure(callback fn (mut cfg WindowConfig)) &SimpleWindow {
	mut cfg := WindowConfig{
		title:                        win.title
		width:                        win.width
		height:                       win.height
		padding:                      win.padding
		spacing:                      win.spacing
		background_color:             win.background_color
		font_color:                   win.font_color
		always_on_top:                win.always_on_top
		responsive_layout:            win.responsive_layout
		resizable:                    win.resizable
		minimizable:                  win.minimizable
		maximizable:                  win.maximizable
		closable:                     win.closable
		has_shadow:                   win.has_shadow
		movable_by_window_background: win.movable_by_window_background
		titlebar_visible:             win.titlebar_visible
		title_visible:                win.title_visible
	}
	callback(mut cfg)
	win.set_title(cfg.title)
	win.set_padding(cfg.padding)
	win.set_spacing(cfg.spacing)
	win.set_background_color(cfg.background_color)
	win.set_font_color(cfg.font_color)
	win.set_always_on_top(cfg.always_on_top)
	win.set_responsive_layout(cfg.responsive_layout)
	win.set_resizable(cfg.resizable)
	win.set_minimizable(cfg.minimizable)
	win.set_maximizable(cfg.maximizable)
	win.set_closable(cfg.closable)
	win.set_has_shadow(cfg.has_shadow)
	win.set_movable_by_window_background(cfg.movable_by_window_background)
	win.set_titlebar_visible(cfg.titlebar_visible)
	win.set_title_visible(cfg.title_visible)
	unsafe {
		mut w := &SimpleWindow(win)
		w.width = cfg.width
		w.height = cfg.height
	}
	return win
}

// form performs form.
pub fn (win &SimpleWindow) form(title string, callback VoidEventCallback) &SimpleWindow {
	win.group('form_${win.controls.len}', title, callback)
	return win
}

// section performs section.
pub fn (win &SimpleWindow) section(title string, callback VoidEventCallback) &SimpleWindow {
	win.group('section_${win.controls.len}', title, callback)
	return win
}

// validate_controls performs validate controls.
pub fn (win &SimpleWindow) validate_controls(validators map[string]ControlValidator) map[string]string {
	mut results := map[string]string{}
	for name, validator in validators {
		if !win.has_control(name) {
			results[name] = ''
			continue
		}
		value := win.get_text(name)
		err := validator(value)
		results[name] = err
		if err != '' {
			win.set_error(name, err)
		} else {
			win.clear_error(name)
		}
	}
	return results
}

// validate_not_empty performs validate not empty.
pub fn validate_not_empty(value string) string {
	if value.trim_space() == '' {
		return 'Required'
	}
	return ''
}

// High-level helpers for common beginner-friendly form building
pub fn (win &SimpleWindow) add_form_field(label string, name string, value string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('field')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_input(real_name, value)
	win.end_row()
	return win
}

// add_form_textarea adds a form field for textarea.
pub fn (win &SimpleWindow) add_form_textarea(label string, name string, value string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('textarea')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_textarea(real_name, value)
	win.end_row()
	return win
}

// add_form_password adds a form field for password.
pub fn (win &SimpleWindow) add_form_password(label string, name string, value string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('password')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_password(real_name, value)
	win.end_row()
	return win
}

// add_form_slider adds a form field for slider.
pub fn (win &SimpleWindow) add_form_slider(label string, name string, value int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('slider')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_slider(real_name, value)
	win.end_row()
	return win
}

// add_form_number adds a form field for number.
pub fn (win &SimpleWindow) add_form_number(label string, name string, value int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('number')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_number(real_name, value)
	win.end_row()
	return win
}

// add_form_dropdown adds a form field for dropdown.
pub fn (win &SimpleWindow) add_form_dropdown(label string, name string, items []string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('dropdown')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_dropdown(real_name, items, selected)
	win.end_row()
	return win
}

// add_form_date_picker adds a form field for date picker.
pub fn (win &SimpleWindow) add_form_date_picker(label string, name string, date string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('date')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_date_picker(real_name, date)
	win.end_row()
	return win
}

// add_form_date_time_picker adds a form field for date-time picker.
pub fn (win &SimpleWindow) add_form_date_time_picker(label string, name string, datetime string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('datetime')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_date_time_picker(real_name, datetime)
	win.end_row()
	return win
}

// add_form_progress adds a form field for progress.
pub fn (win &SimpleWindow) add_form_progress(label string, name string, value int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('progress')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_progress_indicator(real_name, value)
	win.end_row()
	return win
}

// add_form_switch adds a form field for switch.
pub fn (win &SimpleWindow) add_form_switch(label string, name string, switch_label string, checked bool) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('switch')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_switch(real_name, switch_label, checked)
	win.end_row()
	return win
}

// add_form_link adds a form field for link.
pub fn (win &SimpleWindow) add_form_link(label string, name string, link_text string, url string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('link')
	}
	win.begin_row('${real_name}_row')
	win.add_label('${real_name}_label', label)
	win.add_link(real_name, link_text, url)
	win.end_row()
	return win
}

// add_toggle adds a toggle control to the window layout.
pub fn (win &SimpleWindow) add_toggle(name string, label string, checked bool) &SimpleWindow {
	win.add_checkbox(name, label, checked)
	return win
}

// add_number_field adds a number field control to the window layout.
pub fn (win &SimpleWindow) add_number_field(name string, value int) &SimpleWindow {
	win.add_number(name, value)
	return win
}

// add_action adds a action control to the window layout.
pub fn (win &SimpleWindow) add_action(name string, title string, callback VoidEventCallback) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('action')
	}
	win.add_button(real_name, title)
	win.on_click(real_name, callback)
	return win
}

// add_heading adds a heading control to the window layout.
pub fn (win &SimpleWindow) add_heading(title string) &SimpleWindow {
	heading_name := 'heading_${win.controls.len}'
	win.add_label(heading_name, title)
	win.add_separator()
	return win
}

// Value setters and getters calling the generic name-based C bridge
pub fn (win &SimpleWindow) set_debug_mode(enabled bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.debug_mode = enabled
	}
	return win
}

// get_debug_mode retrieves the debug mode of the window or target control.
pub fn (win &SimpleWindow) get_debug_mode() bool {
	return win.debug_mode
}

// set_control_value sets the value of the specified control.
pub fn (win &SimpleWindow) set_control_value(name string, value string) &SimpleWindow {
	if win.debug_mode {
		println('[simplegui DEBUG] set_control_value("${name}", "${value}")')
	}
	win.require_control(name)
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.value = value
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_text_by_name(win.window_info, name.str, value.str)
	}
	return win
}

// Value setters and getters calling the generic name-based C bridge
pub fn (win &SimpleWindow) set_value(name string, value string) &SimpleWindow {
	win.set_control_value(name, value)
	unsafe {
		mut w := &SimpleWindow(win)
		w.dispatch_event(name, 'change', value)
	}
	return win
}

// get_value retrieves the value of the window or target control.
pub fn (win &SimpleWindow) get_value(name string) string {
	win.require_control(name)
	idx := win.find_control(name)
	if idx >= 0 {
		kind := win.controls[idx].kind
		if kind == 'color' {
			return win.controls[idx].value
		}
		if kind in ['checkbox', 'switch', 'spinner'] {
			return if win.controls[idx].checked { 'true' } else { 'false' }
		} else if kind in ['number', 'slider', 'vertical_slider', 'progress', 'levelindicator',
			'stepper', 'knob'] {
			return win.controls[idx].number.str()
		}
	}
	if win.window_info != unsafe { nil } {
		res := C.window_get_control_text_by_name(win.window_info, name.str)
		return unsafe { res.vstring() }
	}
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// set_bool sets the bool of the window or target control.
pub fn (win &SimpleWindow) set_bool(name string, checked bool) &SimpleWindow {
	if win.debug_mode {
		println('[simplegui DEBUG] set_bool("${name}", ${checked})')
	}
	win.require_control(name)
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.checked = checked
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_bool_by_name(win.window_info, name.str, int(checked))
	}
	value := if checked { 'true' } else { 'false' }
	unsafe {
		mut w := &SimpleWindow(win)
		w.dispatch_event(name, 'change', value)
	}
	return win
}

// get_bool retrieves the bool of the window or target control.
pub fn (win &SimpleWindow) get_bool(name string) bool {
	win.require_control(name)
	if win.window_info != unsafe { nil } {
		return C.window_get_control_bool_by_name(win.window_info, name.str) != 0
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].checked
	}
	return false
}

// set_number_value sets the number value of the window or target control.
pub fn (win &SimpleWindow) set_number_value(name string, value int) &SimpleWindow {
	if win.debug_mode {
		println('[simplegui DEBUG] set_number_value("${name}", ${value})')
	}
	win.require_control(name)
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.number = value
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_int_by_name(win.window_info, name.str, value)
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.dispatch_event(name, 'change', value.str())
	}
	return win
}

// get_number_value retrieves the number value of the window or target control.
pub fn (win &SimpleWindow) get_number_value(name string) int {
	win.require_control(name)
	if win.window_info != unsafe { nil } {
		return C.window_get_control_int_by_name(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].number
	}
	return 0
}

// High-level Delphi/VB/C# style properties/helpers
pub fn (win &SimpleWindow) set_text(name string, text string) &SimpleWindow {
	win.set_value(name, text)
	return win
}

// set_html sets the html of the window or target control.
pub fn (win &SimpleWindow) set_html(name string, html string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.value = html
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_text_by_name(win.window_info, name.str, html.str)
	}
	return win
}

// get_text retrieves the text of the window or target control.
pub fn (win &SimpleWindow) get_text(name string) string {
	return win.get_value(name)
}

// set_checked sets the checked of the window or target control.
pub fn (win &SimpleWindow) set_checked(name string, checked bool) &SimpleWindow {
	win.set_bool(name, checked)
	return win
}

// get_checked retrieves the checked of the window or target control.
pub fn (win &SimpleWindow) get_checked(name string) bool {
	return win.get_bool(name)
}

// set_value_int sets the value int of the window or target control.
pub fn (win &SimpleWindow) set_value_int(name string, val int) &SimpleWindow {
	win.set_number_value(name, val)
	return win
}

// get_value_int retrieves the value int of the window or target control.
pub fn (win &SimpleWindow) get_value_int(name string) int {
	return win.get_number_value(name)
}

// Input Control Helper
pub fn (win &SimpleWindow) input(value string) &SimpleWindow {
	win.add_input('default_input', value)
	return win
}

// set_input sets the input of the window or target control.
pub fn (win &SimpleWindow) set_input(value string) &SimpleWindow {
	win.set_value('default_input', value)
	return win
}

// get_input retrieves the input of the window or target control.
pub fn (win &SimpleWindow) get_input() string {
	return win.get_value('default_input')
}

// Textarea Control Helper
pub fn (win &SimpleWindow) textarea(text string) &SimpleWindow {
	win.add_textarea('default_textarea', text)
	return win
}

// set_textarea sets the textarea of the window or target control.
pub fn (win &SimpleWindow) set_textarea(text string) &SimpleWindow {
	win.set_value('default_textarea', text)
	return win
}

// get_textarea retrieves the textarea of the window or target control.
pub fn (win &SimpleWindow) get_textarea() string {
	return win.get_value('default_textarea')
}

// Checkbox Control Helper
pub fn (win &SimpleWindow) checkbox(title string, checked bool) &SimpleWindow {
	win.add_checkbox('default_checkbox', title, checked)
	return win
}

// set_checkbox sets the checkbox of the window or target control.
pub fn (win &SimpleWindow) set_checkbox(checked bool) &SimpleWindow {
	win.set_bool('default_checkbox', checked)
	return win
}

// get_checkbox retrieves the checkbox of the window or target control.
pub fn (win &SimpleWindow) get_checkbox() bool {
	return win.get_bool('default_checkbox')
}

// Number Control Helper
pub fn (win &SimpleWindow) number(value int) &SimpleWindow {
	win.add_number('default_number', value)
	return win
}

// set_number sets the number of the window or target control.
pub fn (win &SimpleWindow) set_number(value int) &SimpleWindow {
	win.set_number_value('default_number', value)
	return win
}

// get_number retrieves the number of the window or target control.
pub fn (win &SimpleWindow) get_number() int {
	return win.get_number_value('default_number')
}

// Button Control Helper
pub fn (win &SimpleWindow) button(title string) &SimpleWindow {
	win.add_button('default_button', title)
	return win
}

// set_button sets the button of the window or target control.
pub fn (win &SimpleWindow) set_button(title string) &SimpleWindow {
	win.set_value('default_button', title)
	return win
}

// slider adds a default slider control to the layout.
pub fn (win &SimpleWindow) slider(value int) &SimpleWindow {
	win.add_slider('default_slider', value)
	return win
}

// color_well adds a default color well control to the layout.
pub fn (win &SimpleWindow) color_well(color string) &SimpleWindow {
	win.add_color_well('default_color_well', color)
	return win
}

// date_picker adds a default date picker control to the layout.
pub fn (win &SimpleWindow) date_picker(date string) &SimpleWindow {
	win.add_date_picker('default_date_picker', date)
	return win
}

// progress_indicator adds a default progress indicator control to the layout.
pub fn (win &SimpleWindow) progress_indicator(value int) &SimpleWindow {
	win.add_progress_indicator('default_progress_indicator', value)
	return win
}

// stepper adds a default stepper control to the layout.
pub fn (win &SimpleWindow) stepper(min_val int, max_val int, step int, value int) &SimpleWindow {
	win.add_stepper('default_stepper', min_val, max_val, step, value)
	return win
}

// help_button adds a default help button control to the layout.
pub fn (win &SimpleWindow) help_button() &SimpleWindow {
	win.add_help_button('default_help_button')
	return win
}

// knob adds a default knob control to the layout.
pub fn (win &SimpleWindow) knob(value int) &SimpleWindow {
	win.add_knob('default_knob', value)
	return win
}

// pull_down adds a default pull down menu control to the layout.
pub fn (win &SimpleWindow) pull_down(title string, items []string) &SimpleWindow {
	win.add_pull_down('default_pull_down', title, items)
	return win
}

// image_button adds a default image button control to the layout.
pub fn (win &SimpleWindow) image_button(symbol string, title string) &SimpleWindow {
	win.add_image_button('default_image_button', symbol, title)
	return win
}

// dropdown adds a default dropdown control to the layout.
pub fn (win &SimpleWindow) dropdown(items []string, selected string) &SimpleWindow {
	win.add_dropdown('default_dropdown', items, selected)
	return win
}

// segmented performs segmented.
pub fn (win &SimpleWindow) segmented(items []string, selected string) &SimpleWindow {
	win.add_segmented_control('default_segmented', items, selected)
	return win
}

// radio_group performs radio group.
pub fn (win &SimpleWindow) radio_group(items []string, selected string) &SimpleWindow {
	win.add_radio_group('default_radiogroup', items, selected)
	return win
}

// toggle_switch performs toggle switch.
pub fn (win &SimpleWindow) toggle_switch(label string, checked bool) &SimpleWindow {
	win.add_switch('default_switch', label, checked)
	return win
}

// search_field performs search field.
pub fn (win &SimpleWindow) search_field(placeholder string) &SimpleWindow {
	win.add_search_field('default_search', placeholder)
	return win
}

// combo_box performs combo box.
pub fn (win &SimpleWindow) combo_box(items []string, selected string) &SimpleWindow {
	win.add_combo_box('default_combobox', items, selected)
	return win
}

// rating performs rating.
pub fn (win &SimpleWindow) rating(value int) &SimpleWindow {
	win.add_rating('default_rating', value)
	return win
}

// spinner performs spinner.
pub fn (win &SimpleWindow) spinner(active bool) &SimpleWindow {
	win.add_spinner('default_spinner', active)
	return win
}

// path_control performs path control.
pub fn (win &SimpleWindow) path_control(path string) &SimpleWindow {
	win.add_path_control('default_pathcontrol', path)
	return win
}

// token_field performs token field.
pub fn (win &SimpleWindow) token_field(value string) &SimpleWindow {
	win.add_token_field('default_tokenfield', value)
	return win
}

// set_responsive_layout sets the responsive layout of the window or target control.
pub fn (win &SimpleWindow) set_responsive_layout(enabled bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.responsive_layout = enabled
	}
	if win.window_info != unsafe { nil } {
		C.window_set_responsive_layout(win.window_info, if enabled { 1 } else { 0 })
	}
	return win
}

// get_responsive_layout retrieves the responsive layout of the window or target control.
pub fn (win &SimpleWindow) get_responsive_layout() bool {
	return win.responsive_layout
}

// set_padding sets the padding of the window or target control.
pub fn (win &SimpleWindow) set_padding(padding int) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.padding = padding
	}
	if win.window_info != unsafe { nil } {
		C.window_set_padding(win.window_info, padding)
	}
	return win
}

// get_padding retrieves the padding of the window or target control.
pub fn (win &SimpleWindow) get_padding() int {
	return win.padding
}

// set_spacing sets the spacing of the window or target control.
pub fn (win &SimpleWindow) set_spacing(spacing int) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.spacing = spacing
	}
	if win.window_info != unsafe { nil } {
		C.window_set_spacing(win.window_info, spacing)
	}
	return win
}

// get_spacing retrieves the spacing of the window or target control.
pub fn (win &SimpleWindow) get_spacing() int {
	return win.spacing
}

// add_group_box adds a group box control to the window layout.
pub fn (win &SimpleWindow) add_group_box(name string, title string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('groupbox')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'groupbox', title, '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_group_box_control(win.window_info, real_name.str, title.str)
	}
	return win
}

// add_tabs adds a tabs control to the window layout.
pub fn (win &SimpleWindow) add_tabs(name string, titles []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('tabs')
	}
	mut joined := ''
	for i, title in titles {
		if i > 0 {
			joined += ','
		}
		joined += title
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'tabs', joined, '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		mut c_titles := []&u8{}
		for title in titles {
			c_titles << title.str
		}
		C.window_add_tabs_control(win.window_info, real_name.str, c_titles.data, titles.len)
	}
	return win
}

// add_scroll_view adds a scroll view control to the window layout.
pub fn (win &SimpleWindow) add_scroll_view(name string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('scrollview')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.upsert_control(real_name, 'scrollview', '', '', false, 0)
	}
	if win.window_info != unsafe { nil } {
		C.window_add_scroll_view_control(win.window_info, real_name.str, height)
	}
	return win
}

// set_focus sets the focus of the window or target control.
pub fn (win &SimpleWindow) set_focus(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_focus_control(win.window_info, name.str)
	}
	return win
}

// clear performs clear.
pub fn (win &SimpleWindow) clear(name string) &SimpleWindow {
	idx := win.find_control(name)
	if idx < 0 {
		return win
	}
	entry := win.controls[idx]
	if entry.kind in ['checkbox', 'switch', 'spinner'] {
		win.set_checked(name, false)
	} else if entry.kind in ['number', 'slider', 'vertical_slider', 'progress', 'levelindicator',
		'stepper', 'knob'] {
		win.set_value_int(name, 0)
	} else if entry.kind in ['input', 'password', 'textarea', 'date', 'datetime', 'mode', 'theme',
		'listbox', 'color', 'search', 'dropdown', 'segmented', 'radiogroup', 'combobox',
		'pathcontrol', 'tokenfield', 'chip_group'] {
		win.set_text(name, '')
	}
	return win
}

// clear_all clears the content of all.
pub fn (win &SimpleWindow) clear_all() &SimpleWindow {
	for control in win.controls {
		win.clear(control.name)
	}
	return win
}

// reset_form performs reset form.
pub fn (win &SimpleWindow) reset_form() &SimpleWindow {
	for i in 0 .. win.controls.len {
		entry := win.controls[i]
		if entry.kind in ['checkbox', 'switch', 'spinner'] {
			win.set_checked(entry.name, entry.initial_checked)
		} else if entry.kind in ['number', 'slider', 'vertical_slider', 'progress', 'levelindicator',
			'stepper', 'knob'] {
			win.set_value_int(entry.name, entry.initial_number)
		} else if entry.kind in ['input', 'password', 'textarea', 'date', 'datetime', 'mode', 'theme',
			'listbox', 'color', 'search', 'dropdown', 'segmented', 'radiogroup', 'combobox',
			'pathcontrol', 'tokenfield', 'chip_group'] {
			win.set_text(entry.name, entry.initial_value)
		}
	}
	return win
}

// set_placeholder sets the placeholder of the window or target control.
pub fn (win &SimpleWindow) set_placeholder(name string, text string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		if w.placeholders.len == 0 {
			w.placeholders = map[string]string{}
		}
		w.placeholders[name] = text
	}
	if win.window_info != unsafe { nil } {
		C.window_set_placeholder_by_name(win.window_info, name.str, text.str)
	}
	return win
}

// get_placeholder retrieves the placeholder of the window or target control.
pub fn (win &SimpleWindow) get_placeholder(name string) string {
	return win.placeholders[name] or { '' }
}

// set_error sets the error of the window or target control.
pub fn (win &SimpleWindow) set_error(name string, text string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		if w.errors.len == 0 {
			w.errors = map[string]string{}
		}
		w.errors[name] = text
	}
	if win.window_info != unsafe { nil } {
		C.window_set_error_by_name(win.window_info, name.str, text.str)
	}
	return win
}

// get_error retrieves the error of the window or target control.
pub fn (win &SimpleWindow) get_error(name string) string {
	return win.errors[name] or { '' }
}

// set_tooltip sets the tooltip of the window or target control.
pub fn (win &SimpleWindow) set_tooltip(name string, text string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		if w.tooltips.len == 0 {
			w.tooltips = map[string]string{}
		}
		w.tooltips[name] = text
	}
	if win.window_info != unsafe { nil } {
		C.window_set_tooltip_by_name(win.window_info, name.str, text.str)
	}
	return win
}

// get_tooltip retrieves the tooltip of the window or target control.
pub fn (win &SimpleWindow) get_tooltip(name string) string {
	return win.tooltips[name] or { '' }
}

// set_default_button sets the default button of the window or target control.
pub fn (win &SimpleWindow) set_default_button(name string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.default_button = name
	}
	if win.window_info != unsafe { nil } {
		C.window_set_default_button_by_name(win.window_info, name.str)
	}
	return win
}

// on_enter registers an event handler for on enter events.
pub fn (win &SimpleWindow) on_enter(name string, callback VoidEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: name
			event_name:   'enter'
			void_cb:      callback
		}
	}
	return win
}

// on_key registers an event handler for on key events.
pub fn (win &SimpleWindow) on_key(key string, callback StringEventCallback) &SimpleWindow {
	norm_key := normalize_key_shortcut(key)
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: 'window'
			event_name:   'key'
			filter_value: norm_key
			string_cb:    callback
		}
	}
	return win
}

// on_shortcut registers a global keyboard shortcut handler.
pub fn (win &SimpleWindow) on_shortcut(shortcut string, callback VoidEventCallback) &SimpleWindow {
	norm_shortcut := normalize_key_shortcut(shortcut)
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: 'window'
			event_name:   'key'
			filter_value: norm_shortcut
			void_cb:      callback
		}
	}
	return win
}

// on_close registers an event handler for on close events.
pub fn (win &SimpleWindow) on_close(callback VoidEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: 'window'
			event_name:   'close'
			void_cb:      callback
		}
	}
	return win
}

// run_after performs run after.
pub fn (win &SimpleWindow) run_after(ms int, callback VoidEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: 'window'
			event_name:   'run_after'
			void_cb:      callback
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_run_after(win.window_info, ms, c'window')
	}
	return win
}

// toast performs toast.
pub fn (win &SimpleWindow) toast(message string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_show_toast(win.window_info, message.str)
	}
	return win
}

// open_url performs open url.
pub fn (win &SimpleWindow) open_url(url string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_open_url(win.window_info, url.str)
	}
	return win
}

// copy_to_clipboard performs copy to clipboard.
pub fn (win &SimpleWindow) copy_to_clipboard(text string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_copy_to_clipboard(win.window_info, text.str)
	}
	return win
}

// clipboard_text returns UTF-8 text from the system clipboard.
pub fn clipboard_text() string {
	res := C.window_get_clipboard_text()
	if res != unsafe { nil } {
		return unsafe { tos3(res) }
	}
	return ''
}

// reveal_in_finder asks Finder to reveal an existing path.
pub fn reveal_in_finder(path string) bool {
	if path == '' {
		return false
	}
	return C.window_reveal_in_finder(path.str) == 1
}

// get_clipboard_text returns UTF-8 text from the system clipboard.
pub fn (win &SimpleWindow) get_clipboard_text() string {
	return clipboard_text()
}

// inspect_controls performs inspect controls.
pub fn (win &SimpleWindow) inspect_controls() string {
	mut names := []string{}
	for control in win.controls {
		names << control.name
	}
	mut joined := ''
	for i, name in names {
		if i > 0 {
			joined += ','
		}
		joined += name
	}
	return joined
}

// dump_values performs dump values.
pub fn (win &SimpleWindow) dump_values() map[string]string {
	return win.get_values()
}

// Window styling
pub fn (win &SimpleWindow) get_title() string {
	return win.title
}

// set_title sets the title of the window or target control.
pub fn (win &SimpleWindow) set_title(text string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.title = text
	}
	if win.window_info != unsafe { nil } {
		C.window_set_title_text(win.window_info, text.str)
	}
	return win
}

// set_always_on_top sets the always on top of the window or target control.
pub fn (win &SimpleWindow) set_always_on_top(enabled bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.always_on_top = enabled
	}
	if win.window_info != unsafe { nil } {
		val := if enabled { 1 } else { 0 }
		C.window_set_always_on_top(win.window_info, val)
	}
	return win
}

// get_always_on_top retrieves the always on top of the window or target control.
pub fn (win &SimpleWindow) get_always_on_top() bool {
	if win.window_info != unsafe { nil } {
		return C.window_get_always_on_top(win.window_info) == 1
	}
	return win.always_on_top
}

// set_min_size sets the min size of the window or target control.
pub fn (win &SimpleWindow) set_min_size(width int, height int) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.min_width = width
		w.min_height = height
	}
	if win.window_info != unsafe { nil } {
		C.window_set_min_size(win.window_info, width, height)
	}
	return win
}

// set_max_size sets the max size of the window or target control.
pub fn (win &SimpleWindow) set_max_size(width int, height int) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.max_width = width
		w.max_height = height
	}
	if win.window_info != unsafe { nil } {
		C.window_set_max_size(win.window_info, width, height)
	}
	return win
}

// get_min_size retrieves the minimum allowed window dimensions (w, h).
pub fn (win &SimpleWindow) get_min_size() (int, int) {
	if win.window_info != unsafe { nil } {
		w := 0
		h := 0
		C.window_get_min_size(win.window_info, &w, &h)
		if w > 0 && h > 0 {
			return w, h
		}
	}
	return win.min_width, win.min_height
}

// get_max_size retrieves the maximum allowed window dimensions (w, h).
pub fn (win &SimpleWindow) get_max_size() (int, int) {
	if win.window_info != unsafe { nil } {
		w := 0
		h := 0
		C.window_get_max_size(win.window_info, &w, &h)
		if w > 0 && h > 0 {
			return w, h
		}
	}
	return win.max_width, win.max_height
}

// set_resizable sets the resizable of the window or target control.
pub fn (win &SimpleWindow) set_resizable(enabled bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.resizable = enabled
	}
	if win.window_info != unsafe { nil } {
		C.window_set_resizable(win.window_info, if enabled { 1 } else { 0 })
	}
	return win
}

// set_minimizable sets the minimizable of the window or target control.
pub fn (win &SimpleWindow) set_minimizable(enabled bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.minimizable = enabled
	}
	if win.window_info != unsafe { nil } {
		C.window_set_minimizable(win.window_info, if enabled { 1 } else { 0 })
	}
	return win
}

// set_maximizable sets the maximizable of the window or target control.
pub fn (win &SimpleWindow) set_maximizable(enabled bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.maximizable = enabled
	}
	if win.window_info != unsafe { nil } {
		C.window_set_maximizable(win.window_info, if enabled { 1 } else { 0 })
	}
	return win
}

// get_resizable retrieves the resizable of the window or target control.
pub fn (win &SimpleWindow) get_resizable() bool {
	return win.resizable
}

// get_minimizable retrieves the minimizable of the window or target control.
pub fn (win &SimpleWindow) get_minimizable() bool {
	return win.minimizable
}

// get_maximizable retrieves the maximizable of the window or target control.
pub fn (win &SimpleWindow) get_maximizable() bool {
	return win.maximizable
}

// close performs close.
pub fn (win &SimpleWindow) close() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_close(win.window_info)
	}
	return win
}

// close_window performs close window.
pub fn (win &SimpleWindow) close_window() &SimpleWindow {
	return win.close()
}

// hide performs hide.
pub fn (win &SimpleWindow) hide() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_hide(win.window_info)
	}
	return win
}

// hide_window performs hide window.
pub fn (win &SimpleWindow) hide_window() &SimpleWindow {
	return win.hide()
}

// center performs center.
pub fn (win &SimpleWindow) center() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_center(win.window_info)
	}
	return win
}

// center_window performs center window.
pub fn (win &SimpleWindow) center_window() &SimpleWindow {
	return win.center()
}

// align performs align.
pub fn (win &SimpleWindow) align(position string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_align(win.window_info, position.str)
	}
	return win
}

// align_window performs align window.
pub fn (win &SimpleWindow) align_window(position string) &SimpleWindow {
	return win.align(position)
}

// set_size sets the size of the window or target control.
pub fn (win &SimpleWindow) set_size(width int, height int) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.width = width
		w.height = height
	}
	if win.window_info != unsafe { nil } {
		C.window_set_size(win.window_info, width, height)
	}
	return win
}

// resize performs resize.
pub fn (win &SimpleWindow) resize(width int, height int) &SimpleWindow {
	return win.set_size(width, height)
}

// get_width retrieves the width of the window or target control.
pub fn (win &SimpleWindow) get_width() int {
	if win.window_info != unsafe { nil } {
		return C.window_get_width(win.window_info)
	}
	return win.width
}

// get_height retrieves the height of the window or target control.
pub fn (win &SimpleWindow) get_height() int {
	if win.window_info != unsafe { nil } {
		return C.window_get_height(win.window_info)
	}
	return win.height
}

// set_position sets the position of the window or target control.
pub fn (win &SimpleWindow) set_position(x int, y int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_position(win.window_info, x, y)
	}
	return win
}

// get_x retrieves the x of the window or target control.
pub fn (win &SimpleWindow) get_x() int {
	if win.window_info != unsafe { nil } {
		return C.window_get_x(win.window_info)
	}
	return 0
}

// get_y retrieves the y of the window or target control.
pub fn (win &SimpleWindow) get_y() int {
	if win.window_info != unsafe { nil } {
		return C.window_get_y(win.window_info)
	}
	return 0
}

// set_opacity sets the opacity of the window or target control.
pub fn (win &SimpleWindow) set_opacity(opacity f64) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_opacity(win.window_info, opacity)
	}
	return win
}

// get_opacity retrieves the opacity of the window or target control.
pub fn (win &SimpleWindow) get_opacity() f64 {
	if win.window_info != unsafe { nil } {
		return C.window_get_opacity(win.window_info)
	}
	return 1.0
}

// toggle_fullscreen performs toggle fullscreen.
pub fn (win &SimpleWindow) toggle_fullscreen() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_toggle_fullscreen(win.window_info)
	}
	return win
}

// minimize performs minimize.
pub fn (win &SimpleWindow) minimize() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_minimize(win.window_info)
	}
	return win
}

// deminimize performs deminimize.
pub fn (win &SimpleWindow) deminimize() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_deminimize(win.window_info)
	}
	return win
}

// maximize performs maximize.
pub fn (win &SimpleWindow) maximize() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_maximize(win.window_info)
	}
	return win
}

// zoom performs zoom.
pub fn (win &SimpleWindow) zoom() &SimpleWindow {
	return win.maximize()
}

// is_minimized checks if the window or control is minimized.
pub fn (win &SimpleWindow) is_minimized() bool {
	if win.window_info != unsafe { nil } {
		return C.window_is_minimized(win.window_info) == 1
	}
	return false
}

// is_maximized checks if the window or control is maximized.
pub fn (win &SimpleWindow) is_maximized() bool {
	if win.window_info != unsafe { nil } {
		return C.window_is_maximized(win.window_info) == 1
	}
	return false
}

// is_fullscreen checks if the window or control is fullscreen.
pub fn (win &SimpleWindow) is_fullscreen() bool {
	if win.window_info != unsafe { nil } {
		return C.window_is_fullscreen(win.window_info) == 1
	}
	return false
}

// is_active checks if the window or control is active.
pub fn (win &SimpleWindow) is_active() bool {
	if win.window_info != unsafe { nil } {
		return C.window_is_active(win.window_info) == 1
	}
	return false
}

// set_titlebar_visible sets the titlebar visible of the window or target control.
pub fn (win &SimpleWindow) set_titlebar_visible(visible bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.titlebar_visible = visible
	}
	if win.window_info != unsafe { nil } {
		C.window_set_titlebar_visible(win.window_info, if visible { 1 } else { 0 })
	}
	return win
}

// request_attention performs request attention.
pub fn (win &SimpleWindow) request_attention(critical bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_request_attention(win.window_info, if critical { 1 } else { 0 })
	}
	return win
}

// bounce_dock performs bounce dock.
pub fn (win &SimpleWindow) bounce_dock(critical bool) &SimpleWindow {
	return win.request_attention(critical)
}

// set_closable sets the closable of the window or target control.
pub fn (win &SimpleWindow) set_closable(enabled bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.closable = enabled
	}
	if win.window_info != unsafe { nil } {
		C.window_set_closable(win.window_info, if enabled { 1 } else { 0 })
	}
	return win
}

// get_closable retrieves the closable of the window or target control.
pub fn (win &SimpleWindow) get_closable() bool {
	if win.window_info != unsafe { nil } {
		return C.window_get_closable(win.window_info) == 1
	}
	return win.closable
}

// set_has_shadow sets the has shadow of the window or target control.
pub fn (win &SimpleWindow) set_has_shadow(enabled bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.has_shadow = enabled
	}
	if win.window_info != unsafe { nil } {
		C.window_set_has_shadow(win.window_info, if enabled { 1 } else { 0 })
	}
	return win
}

// get_has_shadow retrieves the has shadow of the window or target control.
pub fn (win &SimpleWindow) get_has_shadow() bool {
	if win.window_info != unsafe { nil } {
		return C.window_get_has_shadow(win.window_info) == 1
	}
	return win.has_shadow
}

// set_movable_by_window_background sets the movable by window background of the window or target control.
pub fn (win &SimpleWindow) set_movable_by_window_background(enabled bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.movable_by_window_background = enabled
	}
	if win.window_info != unsafe { nil } {
		C.window_set_movable_by_window_background(win.window_info, if enabled { 1 } else { 0 })
	}
	return win
}

// get_movable_by_window_background retrieves the movable by window background of the window or target control.
pub fn (win &SimpleWindow) get_movable_by_window_background() bool {
	if win.window_info != unsafe { nil } {
		return C.window_get_movable_by_window_background(win.window_info) == 1
	}
	return win.movable_by_window_background
}

// is_visible checks if the window or control is visible.
pub fn (win &SimpleWindow) is_visible() bool {
	if win.window_info != unsafe { nil } {
		return C.window_is_visible(win.window_info) == 1
	}
	return false
}

// set_title_visible sets the title visible of the window or target control.
pub fn (win &SimpleWindow) set_title_visible(visible bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.title_visible = visible
	}
	if win.window_info != unsafe { nil } {
		C.window_set_title_visible(win.window_info, if visible { 1 } else { 0 })
	}
	return win
}

// get_title_visible retrieves the title visible of the window or target control.
pub fn (win &SimpleWindow) get_title_visible() bool {
	if win.window_info != unsafe { nil } {
		return C.window_get_title_visible(win.window_info) == 1
	}
	return win.title_visible
}

// is_title_visible checks if the window or control is title visible.
pub fn (win &SimpleWindow) is_title_visible() bool {
	return win.get_title_visible()
}

// get_titlebar_visible retrieves the titlebar visible of the window or target control.
pub fn (win &SimpleWindow) get_titlebar_visible() bool {
	if win.window_info != unsafe { nil } {
		return C.window_get_titlebar_visible(win.window_info) == 1
	}
	return win.titlebar_visible
}

// is_titlebar_visible checks if the window or control is titlebar visible.
pub fn (win &SimpleWindow) is_titlebar_visible() bool {
	return win.get_titlebar_visible()
}

// set_subtitle sets the subtitle text displayed in the window titlebar.
pub fn (win &SimpleWindow) set_subtitle(text string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.subtitle = text
	}
	if win.window_info != unsafe { nil } {
		C.window_set_subtitle(win.window_info, text.str)
	}
	return win
}

// get_subtitle retrieves the subtitle text of the window.
pub fn (win &SimpleWindow) get_subtitle() string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_subtitle(win.window_info)
		if res != unsafe { nil } {
			s := unsafe { tos3(res) }
			if s.len > 0 {
				return s
			}
		}
	}
	return win.subtitle
}

// set_titlebar_appears_transparent sets whether the titlebar appears transparent.
pub fn (win &SimpleWindow) set_titlebar_appears_transparent(transparent bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.titlebar_appears_transparent = transparent
	}
	if win.window_info != unsafe { nil } {
		C.window_set_titlebar_appears_transparent(win.window_info, if transparent { 1 } else { 0 })
	}
	return win
}

// get_titlebar_appears_transparent retrieves whether the titlebar is transparent.
pub fn (win &SimpleWindow) get_titlebar_appears_transparent() bool {
	if win.window_info != unsafe { nil } {
		return C.window_get_titlebar_appears_transparent(win.window_info) == 1
	}
	return win.titlebar_appears_transparent
}

// set_full_size_content_view sets whether content extends under the titlebar.
pub fn (win &SimpleWindow) set_full_size_content_view(enabled bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.full_size_content_view = enabled
	}
	if win.window_info != unsafe { nil } {
		C.window_set_full_size_content_view(win.window_info, if enabled { 1 } else { 0 })
	}
	return win
}

// get_full_size_content_view retrieves whether content extends under the titlebar.
pub fn (win &SimpleWindow) get_full_size_content_view() bool {
	if win.window_info != unsafe { nil } {
		return C.window_get_full_size_content_view(win.window_info) == 1
	}
	return win.full_size_content_view
}

// set_vibrancy sets the NSVisualEffectView material (e.g. "hud", "popover", "sidebar", "header", "titlebar", "menu").
pub fn (win &SimpleWindow) set_vibrancy(material string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.vibrancy_material = material
	}
	if win.window_info != unsafe { nil } {
		C.window_set_vibrancy(win.window_info, material.str)
	}
	return win
}

// set_corner_radius sets the window corner rounding radius.
pub fn (win &SimpleWindow) set_corner_radius(radius f64) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.corner_radius = radius
	}
	if win.window_info != unsafe { nil } {
		C.window_set_corner_radius(win.window_info, radius)
	}
	return win
}

// get_corner_radius retrieves the window corner rounding radius.
pub fn (win &SimpleWindow) get_corner_radius() f64 {
	if win.window_info != unsafe { nil } {
		return C.window_get_corner_radius(win.window_info)
	}
	return win.corner_radius
}

// set_background_blur enables or disables window background blur.
pub fn (win &SimpleWindow) set_background_blur(enabled bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.background_blur = enabled
	}
	if win.window_info != unsafe { nil } {
		C.window_set_background_blur(win.window_info, if enabled { 1 } else { 0 })
	}
	return win
}

// set_window_level sets the window z-level ("normal", "floating", "modal", "mainMenu", "statusBar", "screenSaver").
pub fn (win &SimpleWindow) set_window_level(level string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.window_level = level
	}
	if win.window_info != unsafe { nil } {
		C.window_set_window_level(win.window_info, level.str)
	}
	return win
}

// set_level_type sets the window level type ("normal", "floating", "modal", etc.).
pub fn (win &SimpleWindow) set_level_type(level_type string) &SimpleWindow {
	return win.set_window_level(level_type)
}

// get_window_level retrieves the current window level.
pub fn (win &SimpleWindow) get_window_level() string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_window_level(win.window_info)
		if res != unsafe { nil } {
			s := unsafe { tos3(res) }
			if s.len > 0 {
				return s
			}
		}
	}
	return win.window_level
}

// set_fullscreen toggles full screen mode on or off.
pub fn (win &SimpleWindow) set_fullscreen(enabled bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_fullscreen(win.window_info, if enabled { 1 } else { 0 })
	}
	return win
}

// center_on_active_screen centers the window on the active display containing the mouse cursor.
pub fn (win &SimpleWindow) center_on_active_screen() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_center_on_active_screen(win.window_info)
	}
	return win
}

// snap_to_edge snaps the window to screen edges ("top_left", "top_right", "bottom_left", "bottom_right", "top", "bottom", "left", "right", "center").
pub fn (win &SimpleWindow) snap_to_edge(edge string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_snap_to_edge(win.window_info, edge.str)
	}
	return win
}

// set_bounds sets the window x, y position and width, height bounds in screen coordinates.
pub fn (win &SimpleWindow) set_bounds(x int, y int, width int, height int) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.width = width
		w.height = height
	}
	if win.window_info != unsafe { nil } {
		C.window_set_bounds(win.window_info, x, y, width, height)
	}
	return win
}

// get_bounds retrieves the window x, y position and width, height bounds as a tuple (x, y, w, h).
pub fn (win &SimpleWindow) get_bounds() (int, int, int, int) {
	if win.window_info != unsafe { nil } {
		x := 0
		y := 0
		w := 0
		h := 0
		C.window_get_bounds(win.window_info, &x, &y, &w, &h)
		if w > 0 && h > 0 {
			return x, y, w, h
		}
	}
	return 0, 0, win.width, win.height
}

// move_by shifts window position by delta values in screen coordinates.
pub fn (win &SimpleWindow) move_by(dx int, dy int) &SimpleWindow {
	x, y, _, _ := win.get_bounds()
	return win.set_position(x + dx, y + dy)
}

// resize_by adjusts current window size by delta width and height.
pub fn (win &SimpleWindow) resize_by(dw int, dh int) &SimpleWindow {
	_, _, current_w, current_h := win.get_bounds()
	mut new_w := current_w + dw
	mut new_h := current_h + dh
	if new_w < 1 {
		new_w = 1
	}
	if new_h < 1 {
		new_h = 1
	}
	return win.set_size(new_w, new_h)
}

// get_center returns the window center point as (x, y) in screen coordinates.
pub fn (win &SimpleWindow) get_center() (int, int) {
	x, y, w, h := win.get_bounds()
	return x + (w / 2), y + (h / 2)
}

// set_center positions the window so its center matches the target screen point.
pub fn (win &SimpleWindow) set_center(center_x int, center_y int) &SimpleWindow {
	_, _, w, h := win.get_bounds()
	target_x := center_x - (w / 2)
	target_y := center_y - (h / 2)
	return win.set_position(target_x, target_y)
}

// center_horizontally centers the window on the current screen horizontally, preserving y.
pub fn (win &SimpleWindow) center_horizontally() &SimpleWindow {
	sx, _, sw, _ := win.get_screen_frame()
	_, y, w, _ := win.get_bounds()
	target_x := sx + ((sw - w) / 2)
	return win.set_position(target_x, y)
}

// center_vertically centers the window on the current screen vertically, preserving x.
pub fn (win &SimpleWindow) center_vertically() &SimpleWindow {
	_, sy, _, sh := win.get_screen_frame()
	x, _, _, h := win.get_bounds()
	target_y := sy + ((sh - h) / 2)
	return win.set_position(x, target_y)
}

// fit_to_screen resizes and positions window to the visible screen frame.
pub fn (win &SimpleWindow) fit_to_screen() &SimpleWindow {
	sx, sy, sw, sh := win.get_screen_frame()
	return win.set_bounds(sx, sy, sw, sh)
}

// constrain_to_screen keeps the window fully inside the visible screen frame.
pub fn (win &SimpleWindow) constrain_to_screen() &SimpleWindow {
	sx, sy, sw, sh := win.get_screen_frame()
	x, y, w, h := win.get_bounds()
	mut target_x := x
	mut target_y := y
	mut target_w := w
	mut target_h := h

	if target_w > sw {
		target_w = sw
	}
	if target_h > sh {
		target_h = sh
	}

	if target_x < sx {
		target_x = sx
	}
	if target_y < sy {
		target_y = sy
	}

	max_x := sx + sw - target_w
	max_y := sy + sh - target_h
	if target_x > max_x {
		target_x = max_x
	}
	if target_y > max_y {
		target_y = max_y
	}

	return win.set_bounds(target_x, target_y, target_w, target_h)
}

// set_aspect_ratio constrains the window resizing aspect ratio.
pub fn (win &SimpleWindow) set_aspect_ratio(width_ratio f64, height_ratio f64) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_aspect_ratio(win.window_info, width_ratio, height_ratio)
	}
	return win
}

// reset_aspect_ratio clears any enforced window aspect ratio.
pub fn (win &SimpleWindow) reset_aspect_ratio() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_reset_aspect_ratio(win.window_info)
	}
	return win
}

// has_aspect_ratio checks if an aspect ratio constraint is active.
pub fn (win &SimpleWindow) has_aspect_ratio() bool {
	if win.window_info != unsafe { nil } {
		return C.window_has_aspect_ratio(win.window_info) == 1
	}
	return false
}

// set_movable enables or disables whether the window can be moved by dragging.
pub fn (win &SimpleWindow) set_movable(enabled bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.movable = enabled
	}
	if win.window_info != unsafe { nil } {
		C.window_set_movable(win.window_info, if enabled { 1 } else { 0 })
	}
	return win
}

// get_movable retrieves whether the window can be moved by dragging.
pub fn (win &SimpleWindow) get_movable() bool {
	if win.window_info != unsafe { nil } {
		return C.window_get_movable(win.window_info) == 1
	}
	return win.movable
}

// is_movable returns true if the window can be dragged by the user. Alias for get_movable.
pub fn (win &SimpleWindow) is_movable() bool {
	return win.get_movable()
}

// set_ignores_mouse_events sets whether mouse clicks pass through the window (click-through overlay).
pub fn (win &SimpleWindow) set_ignores_mouse_events(enabled bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.ignores_mouse_events = enabled
	}
	if win.window_info != unsafe { nil } {
		C.window_set_ignores_mouse_events(win.window_info, if enabled { 1 } else { 0 })
	}
	return win
}

// get_ignores_mouse_events checks if mouse events pass through the window.
pub fn (win &SimpleWindow) get_ignores_mouse_events() bool {
	if win.window_info != unsafe { nil } {
		return C.window_get_ignores_mouse_events(win.window_info) == 1
	}
	return win.ignores_mouse_events
}

// set_hides_on_deactivate sets whether the window automatically hides when the app loses focus.
pub fn (win &SimpleWindow) set_hides_on_deactivate(enabled bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.hides_on_deactivate = enabled
	}
	if win.window_info != unsafe { nil } {
		C.window_set_hides_on_deactivate(win.window_info, if enabled { 1 } else { 0 })
	}
	return win
}

// get_hides_on_deactivate checks if the window hides when app loses focus.
pub fn (win &SimpleWindow) get_hides_on_deactivate() bool {
	if win.window_info != unsafe { nil } {
		return C.window_get_hides_on_deactivate(win.window_info) == 1
	}
	return win.hides_on_deactivate
}

// set_prevents_app_termination sets whether closing this window prevents app termination.
pub fn (win &SimpleWindow) set_prevents_app_termination(enabled bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.prevents_app_termination = enabled
	}
	if win.window_info != unsafe { nil } {
		C.window_set_prevents_app_termination(win.window_info, if enabled { 1 } else { 0 })
	}
	return win
}

// get_prevents_app_termination checks if closing this window prevents app termination.
pub fn (win &SimpleWindow) get_prevents_app_termination() bool {
	if win.window_info != unsafe { nil } {
		native_val := C.window_get_prevents_app_termination(win.window_info) == 1
		if native_val != win.prevents_app_termination {
			return win.prevents_app_termination
		}
		return native_val
	}
	return win.prevents_app_termination
}

// set_represented_filename sets a file path to show document icon in window titlebar.
pub fn (win &SimpleWindow) set_represented_filename(filepath string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.represented_filename = filepath
	}
	if win.window_info != unsafe { nil } {
		C.window_set_represented_filename(win.window_info, filepath.str)
	}
	return win
}

// get_represented_filename retrieves the represented file path.
pub fn (win &SimpleWindow) get_represented_filename() string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_represented_filename(win.window_info)
		if res != unsafe { nil } {
			s := unsafe { tos3(res) }
			if s.len > 0 {
				return s
			}
		}
	}
	return win.represented_filename
}

// set_frame_autosave_name enables frame persistence under a stable autosave key.
pub fn (win &SimpleWindow) set_frame_autosave_name(autosave_name string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.frame_autosave_name = autosave_name
	}
	if win.window_info != unsafe { nil } {
		C.window_set_frame_autosave_name(win.window_info, autosave_name.str)
	}
	return win
}

// get_frame_autosave_name returns the active autosave key used for frame persistence.
pub fn (win &SimpleWindow) get_frame_autosave_name() string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_frame_autosave_name(win.window_info)
		if res != unsafe { nil } {
			s := unsafe { tos3(res) }
			if s.len > 0 {
				return s
			}
		}
	}
	return win.frame_autosave_name
}

// save_frame persists current window bounds using the configured autosave key.
pub fn (win &SimpleWindow) save_frame() bool {
	if win.window_info != unsafe { nil } {
		return C.window_save_frame(win.window_info) == 1
	}
	return false
}

// restore_frame restores window bounds previously saved with autosave.
pub fn (win &SimpleWindow) restore_frame() bool {
	if win.window_info != unsafe { nil } {
		return C.window_restore_frame(win.window_info) == 1
	}
	return false
}

// capture_screenshot writes a PNG screenshot of the current window to file_path.
pub fn (win &SimpleWindow) capture_screenshot(file_path string) bool {
	if file_path == '' {
		return false
	}
	if win.window_info != unsafe { nil } {
		return C.window_capture_screenshot(win.window_info, file_path.str) == 1
	}
	return false
}

// set_document_edited sets the unsaved changes dirty indicator in window titlebar close button.
pub fn (win &SimpleWindow) set_document_edited(edited bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.document_edited = edited
	}
	if win.window_info != unsafe { nil } {
		C.window_set_document_edited(win.window_info, if edited { 1 } else { 0 })
	}
	return win
}

// is_document_edited checks if window has unsaved changes dirty indicator.
pub fn (win &SimpleWindow) is_document_edited() bool {
	if win.window_info != unsafe { nil } {
		return C.window_is_document_edited(win.window_info) == 1
	}
	return win.document_edited
}

// flash_frame flashes the window frame to request user attention.
pub fn (win &SimpleWindow) flash_frame(critical bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_flash_frame(win.window_info, if critical { 1 } else { 0 })
	}
	return win
}

// bounce_dock_icon bounces the application dock icon to request attention.
pub fn (win &SimpleWindow) bounce_dock_icon(critical bool) &SimpleWindow {
	C.window_bounce_dock_icon(if critical { 1 } else { 0 })
	return win
}

// order_front brings the window to the front of the window stack.
pub fn (win &SimpleWindow) order_front() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_order_front(win.window_info)
	}
	return win
}

// bring_to_front is an alias for order_front.
pub fn (win &SimpleWindow) bring_to_front() &SimpleWindow {
	return win.order_front()
}

// order_back sends the window behind all other windows.
pub fn (win &SimpleWindow) order_back() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_order_back(win.window_info)
	}
	return win
}

// send_to_back is an alias for order_back.
pub fn (win &SimpleWindow) send_to_back() &SimpleWindow {
	return win.order_back()
}

// toggle_minimize toggles the window minimized state.
pub fn (win &SimpleWindow) toggle_minimize() &SimpleWindow {
	if win.is_minimized() {
		return win.deminimize()
	} else {
		return win.minimize()
	}
}

// toggle_maximize toggles the window maximized state.
pub fn (win &SimpleWindow) toggle_maximize() &SimpleWindow {
	return win.maximize()
}

// toggle_visibility toggles window visibility between shown and hidden.
pub fn (win &SimpleWindow) toggle_visibility() &SimpleWindow {
	if win.is_visible() {
		return win.hide()
	} else {
		if win.window_info != unsafe { nil } {
			C.window_show(win.window_info)
		}
		return win
	}
}

// set_background_color sets the background color of the window or target control.
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

// set_control_width sets the width of the specified control.
pub fn (win &SimpleWindow) set_control_width(name string, width int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.width = width
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_width_by_name(win.window_info, name.str, width)
	}
	return win
}

// get_control_width returns the width of the specified control.
pub fn (win &SimpleWindow) get_control_width(name string) int {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].width
	}
	return 0
}

// set_control_height sets the height of the specified control.
pub fn (win &SimpleWindow) set_control_height(name string, height int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.height = height
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_height_by_name(win.window_info, name.str, height)
	}
	return win
}

// get_control_height returns the height of the specified control.
pub fn (win &SimpleWindow) get_control_height(name string) int {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].height
	}
	return 0
}

// set_control_font_size sets the font size of the specified control.
pub fn (win &SimpleWindow) set_control_font_size(name string, size int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.font_size = size
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_control_font_size_by_name(win.window_info, name.str, size)
	}
	return win
}

// get_control_font_size returns the font size of the specified control.
pub fn (win &SimpleWindow) get_control_font_size(name string) int {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].font_size
	}
	return 0
}

// set_control_font_bold sets the font bold of the specified control.
pub fn (win &SimpleWindow) set_control_font_bold(name string, bold bool) &SimpleWindow {
	win.require_control(name)
	if win.window_info != unsafe { nil } {
		b_val := if bold { 1 } else { 0 }
		C.window_set_control_font_bold_by_name(win.window_info, name.str, b_val)
	}
	return win
}

// set_control_font_name sets the font name of the specified control.
pub fn (win &SimpleWindow) set_control_font_name(name string, font_name string) &SimpleWindow {
	win.require_control(name)
	if win.window_info != unsafe { nil } {
		C.window_set_control_font_name_by_name(win.window_info, name.str, font_name.str)
	}
	return win
}

// Status text
pub fn (win &SimpleWindow) set_status(text string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.status_text = text
	}
	if !win.has_control('status') {
		win.add_label('status', text)
	}
	if win.window_info != unsafe { nil } {
		C.window_set_status_text(win.window_info, text.str)
	}
	return win
}

// get_status retrieves the status of the window or target control.
pub fn (win &SimpleWindow) get_status() string {
	return win.status_text
}

// status performs status.
pub fn (win &SimpleWindow) status(text string) &SimpleWindow {
	win.set_status(text)
	return win
}

// Event registration
pub fn (win &SimpleWindow) on_click(name string, callback VoidEventCallback) &SimpleWindow {
	idx := win.find_handler(name, 'click')
	mut handler := ControlEventHandler{
		control_name: name
		event_name:   'click'
		void_cb:      callback
	}
	unsafe {
		mut w := &SimpleWindow(win)
		if idx >= 0 {
			w.handlers[idx] = handler
		} else {
			w.handlers << handler
		}
	}
	return win
}

// on_change registers an event handler for on change events.
pub fn (win &SimpleWindow) on_change(name string, callback StringEventCallback) &SimpleWindow {
	idx := win.find_handler(name, 'change')
	mut handler := ControlEventHandler{
		control_name: name
		event_name:   'change'
		string_cb:    callback
	}
	unsafe {
		mut w := &SimpleWindow(win)
		if idx >= 0 {
			w.handlers[idx] = handler
		} else {
			w.handlers << handler
		}
	}
	return win
}

// on_column_click registers an event handler for column click events.
pub fn (win &SimpleWindow) on_column_click(name string, callback StringEventCallback) &SimpleWindow {
	idx := win.find_handler(name, 'click_column')
	mut handler := ControlEventHandler{
		control_name: name
		event_name:   'click_column'
		string_cb:    callback
	}
	unsafe {
		mut w := &SimpleWindow(win)
		if idx >= 0 {
			w.handlers[idx] = handler
		} else {
			w.handlers << handler
		}
	}
	return win
}

// on_cell_button_click registers an event handler for cell button click events.
pub fn (win &SimpleWindow) on_cell_button_click(name string, callback StringEventCallback) &SimpleWindow {
	idx := win.find_handler(name, 'click_cell_button')
	mut handler := ControlEventHandler{
		control_name: name
		event_name:   'click_cell_button'
		string_cb:    callback
	}
	unsafe {
		mut w := &SimpleWindow(win)
		if idx >= 0 {
			w.handlers[idx] = handler
		} else {
			w.handlers << handler
		}
	}
	return win
}

// on_change_step registers a callback for wizard stepper step changes.
pub fn (win &SimpleWindow) on_change_step(name string, callback StringEventCallback) &SimpleWindow {
	idx := win.find_handler(name, 'change_step')
	mut handler := ControlEventHandler{
		control_name: name
		event_name:   'change_step'
		string_cb:    callback
	}
	unsafe {
		mut w := &SimpleWindow(win)
		if idx >= 0 {
			w.handlers[idx] = handler
		} else {
			w.handlers << handler
		}
	}
	return win
}

// on_click_tag registers a callback for tag cloud chip clicks.
pub fn (win &SimpleWindow) on_click_tag(name string, callback StringEventCallback) &SimpleWindow {
	idx := win.find_handler(name, 'click_tag')
	mut handler := ControlEventHandler{
		control_name: name
		event_name:   'click_tag'
		string_cb:    callback
	}
	unsafe {
		mut w := &SimpleWindow(win)
		if idx >= 0 {
			w.handlers[idx] = handler
		} else {
			w.handlers << handler
		}
	}
	return win
}

// on_select_item registers a callback for split button menu item selection.
pub fn (win &SimpleWindow) on_select_item(name string, callback StringEventCallback) &SimpleWindow {
	idx := win.find_handler(name, 'select_item')
	mut handler := ControlEventHandler{
		control_name: name
		event_name:   'select_item'
		string_cb:    callback
	}
	unsafe {
		mut w := &SimpleWindow(win)
		if idx >= 0 {
			w.handlers[idx] = handler
		} else {
			w.handlers << handler
		}
	}
	return win
}

// on_select registers a callback for text selection events.
pub fn (win &SimpleWindow) on_select(name string, callback StringEventCallback) &SimpleWindow {
	idx := win.find_handler(name, 'select')
	mut handler := ControlEventHandler{
		control_name: name
		event_name:   'select'
		string_cb:    callback
	}
	unsafe {
		mut w := &SimpleWindow(win)
		if idx >= 0 {
			w.handlers[idx] = handler
		} else {
			w.handlers << handler
		}
	}
	return win
}

// dispatch_event performs dispatch event.
pub fn (win &SimpleWindow) dispatch_event(name string, event_name string, value string) bool {
	if win.debug_mode {
		println('[simplegui DEBUG] Dispatching Event: "${event_name}" on Control: "${name}" (Value: "${value}")')
		win.set_status('[DEBUG] ${event_name} on "${name}" -> "${value}"')
	}
	mut handler_idx := -1
	if event_name == 'file_drop' {
		handler_idx = win.find_handler_by_filter(name, event_name, value)
		if handler_idx < 0 {
			handler_idx = win.find_handler_by_filter('window', event_name, value)
		}
	} else {
		handler_idx = win.find_handler_by_filter(name, event_name, value)
	}
	if handler_idx < 0 {
		return false
	}
	handler := win.handlers[handler_idx]
	if event_name == 'file_drop' {
		files := value.split('|')
		unsafe {
			mut w := &SimpleWindow(win)
			handler.file_drop_cb(mut w, files)
		}
		return true
	} else if handler.void_cb != unsafe { nil } {
		unsafe {
			mut w := &SimpleWindow(win)
			handler.void_cb(mut w)
		}
		return true
	} else if handler.string_cb != unsafe { nil } {
		unsafe {
			mut w := &SimpleWindow(win)
			handler.string_cb(mut w, value)
		}
		return true
	}
	return false
}

// click performs click.
pub fn (win &SimpleWindow) click(name string) bool {
	return win.dispatch_event(name, 'click', '')
}

// run performs run.
pub fn (win &SimpleWindow) run() {
	if win.window_info == unsafe { nil } {
		unsafe {
			mut w := &SimpleWindow(win)
			w.ensure_window()
		}
	}
	C.window_app_run(win.window_info)
}

// Cocoa event dispatcher to V

// vlang_dispatch_event performs vlang dispatch event.
@[export: 'vlang_dispatch_event']
fn vlang_dispatch_event(win_ptr voidptr, name_str &u8, event_str &u8, value_str &u8) {
	mut win := unsafe { &SimpleWindow(win_ptr) }
	name := unsafe { name_str.vstring() }
	event := unsafe { event_str.vstring() }
	value := unsafe { value_str.vstring() }

	// Update V struct state with the new value from Cocoa
	if event == 'change' {
		idx := win.find_control(name)
		if idx >= 0 {
			kind := win.controls[idx].kind
			if kind == 'checkbox' || kind == 'toggle' {
				win.controls[idx].checked = (value == 'true')
			} else if kind in ['number', 'slider', 'vertical_slider', 'progress', 'stepper', 'knob',
				'levelindicator'] {
				win.controls[idx].number = value.int()
			}
			win.controls[idx].value = value
		}
	}

	win.dispatch_event(name, event, value)
}

// begin_row begins a row container in the layout.
pub fn (win &SimpleWindow) begin_row(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_begin_row(win.window_info, name.str)
	}
	return win
}

// end_row ends the current row container layout.
pub fn (win &SimpleWindow) end_row() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_end_row(win.window_info)
	}
	return win
}

// begin_grid begins a multi-column grid layout container with specified column count and item spacing.
pub fn (win &SimpleWindow) begin_grid(name string, columns int, spacing int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_begin_grid(win.window_info, name.str, columns, spacing)
	}
	return win
}

// end_grid ends the current grid layout container.
pub fn (win &SimpleWindow) end_grid() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_end_grid(win.window_info)
	}
	return win
}

// begin_flex_box begins a flexbox container with direction ('row'|'column'), main-axis justification ('start'|'center'|'end'|'space_between'|'space_around'|'fill'), and cross-axis alignment ('start'|'center'|'end'|'stretch').
pub fn (win &SimpleWindow) begin_flex_box(name string, direction string, justify string, align string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_begin_flex_box(win.window_info, name.str, direction.str, justify.str,
			align.str)
	}
	return win
}

// end_flex_box ends the current flexbox container.
pub fn (win &SimpleWindow) end_flex_box() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_end_flex_box(win.window_info)
	}
	return win
}

// Dialogs & Popups
pub fn (win &SimpleWindow) alert(title string, message string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_show_alert(win.window_info, title.str, message.str)
	}
	return win
}

// alert_with_style performs alert with style.
pub fn (win &SimpleWindow) alert_with_style(title string, message string, style string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_show_alert_with_style(win.window_info, title.str, message.str, style.str)
	}
	return win
}

// confirm performs confirm.
pub fn (win &SimpleWindow) confirm(title string, message string) bool {
	if win.window_info != unsafe { nil } {
		return C.window_show_confirm(win.window_info, title.str, message.str) == 1
	}
	return false
}

// prompt performs prompt.
pub fn (win &SimpleWindow) prompt(title string, message string, default_val string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_show_prompt(win.window_info, title.str, message.str, default_val.str)
		return unsafe { res.vstring() }
	}
	return ''
}

// choice_dialog performs choice dialog.
pub fn (win &SimpleWindow) choice_dialog(title string, message string, choices []string) int {
	if win.window_info != unsafe { nil } {
		mut c_choices := []&u8{}
		for choice in choices {
			c_choices << choice.str
		}
		return C.window_show_choice_dialog(win.window_info, title.str, message.str, c_choices.data,
			choices.len)
	}
	return -1
}

// File and Folder Panels
pub fn (win &SimpleWindow) select_file() string {
	if win.window_info != unsafe { nil } {
		res := C.window_select_file(win.window_info)
		return unsafe { res.vstring() }
	}
	return ''
}

// select_file_with_extensions performs select file with extensions.
pub fn (win &SimpleWindow) select_file_with_extensions(extensions string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_select_file_with_extensions(win.window_info, extensions.str)
		return unsafe { res.vstring() }
	}
	return ''
}

// select_folder performs select folder.
pub fn (win &SimpleWindow) select_folder() string {
	if win.window_info != unsafe { nil } {
		res := C.window_select_folder(win.window_info)
		return unsafe { res.vstring() }
	}
	return ''
}

// save_file_picker performs save file picker.
pub fn (win &SimpleWindow) save_file_picker() string {
	if win.window_info != unsafe { nil } {
		res := C.window_save_file_picker(win.window_info)
		return unsafe { res.vstring() }
	}
	return ''
}

// Visibility & Enabled state controls
pub fn (win &SimpleWindow) set_control_visible(name string, visible bool) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.visible = visible
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		vis_val := if visible { 1 } else { 0 }
		C.window_set_control_visible_by_name(win.window_info, name.str, vis_val)
	}
	return win
}

// get_control_visible returns the visible of the specified control.
pub fn (win &SimpleWindow) get_control_visible(name string) bool {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].visible
	}
	if win.window_info != unsafe { nil } {
		return C.window_get_control_visible_by_name(win.window_info, name.str) == 1
	}
	return true
}

// set_control_enabled sets the enabled of the specified control.
pub fn (win &SimpleWindow) set_control_enabled(name string, enabled bool) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.enabled = enabled
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		en_val := if enabled { 1 } else { 0 }
		C.window_set_control_enabled_by_name(win.window_info, name.str, en_val)
	}
	return win
}

// get_control_enabled returns the enabled of the specified control.
pub fn (win &SimpleWindow) get_control_enabled(name string) bool {
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].enabled
	}
	if win.window_info != unsafe { nil } {
		return C.window_get_control_enabled_by_name(win.window_info, name.str) == 1
	}
	return true
}

// Timers
pub fn (win &SimpleWindow) set_interval(timer_name string, ms int, callback VoidEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: timer_name
			event_name:   'timer'
			void_cb:      callback
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_interval(win.window_info, ms, timer_name.str)
	}
	return win
}

// stop_interval performs stop interval.
pub fn (win &SimpleWindow) stop_interval(timer_name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_stop_interval(win.window_info, timer_name.str)
	}
	return win
}

// List Box and Image View Controls
pub fn (win &SimpleWindow) add_list_box(name string, items []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('listbox')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'listbox'
			value: ''
		}
		w.list_items[real_name] = items.clone()
	}
	if win.window_info != unsafe { nil } {
		mut c_items := []&u8{}
		for item in items {
			c_items << item.str
		}
		C.window_add_list_box_control(win.window_info, real_name.str, c_items.data, items.len)
	}
	return win
}

// update_list_items performs update list items.
pub fn (win &SimpleWindow) update_list_items(name string, items []string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.list_items[name] = items.clone()
	}
	if win.window_info != unsafe { nil } {
		mut c_items := []&u8{}
		for item in items {
			c_items << item.str
		}
		C.window_update_list_items(win.window_info, name.str, c_items.data, items.len)
	}
	return win
}

// set_list_selected sets the list selected of the window or target control.
pub fn (win &SimpleWindow) set_list_selected(name string, index int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.number = index
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_list_selected(win.window_info, name.str, index)
	}
	return win
}

// get_list_selected retrieves the list selected of the window or target control.
pub fn (win &SimpleWindow) get_list_selected(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_list_selected(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].number
	}
	return -1
}

// add_image adds a image control to the window layout.
pub fn (win &SimpleWindow) add_image(name string, file_path string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('image')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'image'
			value: file_path
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_image_control(win.window_info, real_name.str, file_path.str)
	}
	return win
}

// set_image_path sets the image path of the window or target control.
pub fn (win &SimpleWindow) set_image_path(name string, file_path string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.value = file_path
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_image_path(win.window_info, name.str, file_path.str)
	}
	return win
}

// Focus & Blur Event Listeners (for text field inputs)
pub fn (win &SimpleWindow) on_focus(name string, callback VoidEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: name
			event_name:   'focus'
			void_cb:      callback
		}
	}
	return win
}

// Focus lost (blur)
pub fn (win &SimpleWindow) on_blur(name string, callback VoidEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: name
			event_name:   'blur'
			void_cb:      callback
		}
	}
	return win
}

// Hover Event Listeners (Mouse Entered & Mouse Exited)
pub fn (win &SimpleWindow) on_hover(name string, callback VoidEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: name
			event_name:   'hover_enter'
			void_cb:      callback
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_enable_hover_events(win.window_info, name.str)
	}
	return win
}

// on_hover_exit registers an event handler for on hover exit events.
pub fn (win &SimpleWindow) on_hover_exit(name string, callback VoidEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: name
			event_name:   'hover_exit'
			void_cb:      callback
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_enable_hover_events(win.window_info, name.str)
	}
	return win
}

// Window Resize Event Listener
pub fn (win &SimpleWindow) on_resize(callback StringEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: 'window'
			event_name:   'resize'
			string_cb:    callback
		}
	}
	return win
}

// Window Focus / Activation Event Listener
pub fn (win &SimpleWindow) on_window_focus(callback VoidEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: 'window'
			event_name:   'window_focus'
			void_cb:      callback
		}
	}
	return win
}

// Window Blur / Deactivation Event Listener
pub fn (win &SimpleWindow) on_window_blur(callback VoidEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: 'window'
			event_name:   'window_blur'
			void_cb:      callback
		}
	}
	return win
}

// Window Minimize Event Listener
pub fn (win &SimpleWindow) on_window_minimize(callback VoidEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: 'window'
			event_name:   'window_minimize'
			void_cb:      callback
		}
	}
	return win
}

// Window Restore (deminimize) Event Listener
pub fn (win &SimpleWindow) on_window_restore(callback VoidEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: 'window'
			event_name:   'window_restore'
			void_cb:      callback
		}
	}
	return win
}

// Custom Menu Items
pub fn (win &SimpleWindow) add_menu_item(menu_name string, item_title string, shortcut string, callback VoidEventCallback) &SimpleWindow {
	handler_name := 'menu_${menu_name}_${item_title}'
	win.on_click(handler_name, callback)
	if win.window_info != unsafe { nil } {
		C.window_add_menu_item(win.window_info, menu_name.str, item_title.str, shortcut.str,
			handler_name.str)
	}
	return win
}

// add_context_menu_item adds a context menu item control to the window layout.
pub fn (win &SimpleWindow) add_context_menu_item(control_name string, item_title string, callback VoidEventCallback) &SimpleWindow {
	handler_name := 'context_${control_name}_${item_title}'
	win.on_click(handler_name, callback)
	if win.window_info != unsafe { nil } {
		C.window_add_context_menu_item(win.window_info, control_name.str, item_title.str,
			handler_name.str)
	}
	return win
}

// add_menu adds a menu control to the window layout.
pub fn (win &SimpleWindow) add_menu(menu_name string, items []MenuItem) &SimpleWindow {
	for item in items {
		win.add_menu_item(menu_name, item.title, item.shortcut, item.callback)
	}
	return win
}

// add_context_menu adds a context menu control to the window layout.
pub fn (win &SimpleWindow) add_context_menu(control_name string, items []MenuItem) &SimpleWindow {
	for item in items {
		win.add_context_menu_item(control_name, item.title, item.callback)
	}
	return win
}

// on_file_drop registers an event handler for on file drop events.
pub fn (win &SimpleWindow) on_file_drop(callback FileDropCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.handlers << ControlEventHandler{
			control_name: 'window'
			event_name:   'file_drop'
			file_drop_cb: callback
		}
	}
	return win
}

// add_vertical_spacer adds a vertical spacer control to the window layout.
pub fn (win &SimpleWindow) add_vertical_spacer(height int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_add_vertical_spacer(win.window_info, height)
	}
	return win
}

// add_horizontal_spacer adds a horizontal spacer control to the window layout.
pub fn (win &SimpleWindow) add_horizontal_spacer(width int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_add_horizontal_spacer(win.window_info, width)
	}
	return win
}

// add_separator adds a separator control to the window layout.
pub fn (win &SimpleWindow) add_separator() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_add_separator(win.window_info)
	}
	return win
}

pub struct TreeNode {
pub mut:
	id        string
	parent_id string
	text      string
}

// tree_node creates a TreeNode with explicit id, parent id, and display text.
pub fn tree_node(id string, parent_id string, text string) TreeNode {
	return TreeNode{
		id:        id
		parent_id: parent_id
		text:      text
	}
}

// tree_root creates a root-level TreeNode (without a parent).
pub fn tree_root(id string, text string) TreeNode {
	return tree_node(id, '', text)
}

// tree_child creates a child TreeNode under the provided parent id.
pub fn tree_child(id string, parent_id string, text string) TreeNode {
	return tree_node(id, parent_id, text)
}

// tree_nodes_from_paths builds flat TreeNode entries from hierarchical path strings.
// Example path: "Company/Engineering/Backend".
pub fn tree_nodes_from_paths(paths []string, separator string) []TreeNode {
	sep := if separator == '' { '/' } else { separator }
	mut nodes := []TreeNode{}
	mut seen := map[string]bool{}

	for raw_path in paths {
		trimmed_path := raw_path.trim_space()
		if trimmed_path == '' {
			continue
		}

		mut parts := []string{}
		for part in trimmed_path.split(sep) {
			trimmed_part := part.trim_space()
			if trimmed_part != '' {
				parts << trimmed_part
			}
		}

		if parts.len == 0 {
			continue
		}

		mut parent_id := ''
		mut path_parts := []string{}
		for part in parts {
			path_parts << part
			node_id := path_parts.join('/')
			if node_id !in seen {
				nodes << TreeNode{
					id:        node_id
					parent_id: parent_id
					text:      part
				}
				seen[node_id] = true
			}
			parent_id = node_id
		}
	}

	return nodes
}

fn clone_tree_nodes(nodes []TreeNode) []TreeNode {
	mut copied := []TreeNode{cap: nodes.len}
	for node in nodes {
		copied << TreeNode{
			id:        node.id
			parent_id: node.parent_id
			text:      node.text
		}
	}
	return copied
}

// add_tree_view adds a tree view control to the window layout.
pub fn (win &SimpleWindow) add_tree_view(name string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('treeview')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'treeview'
			value: ''
		}
		w.tree_nodes[real_name] = []TreeNode{}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_tree_view_control(win.window_info, real_name.str, height)
	}
	return win
}

// set_tree_nodes sets the tree nodes of the window or target control.
pub fn (win &SimpleWindow) set_tree_nodes(name string, nodes []TreeNode) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.tree_nodes[name] = clone_tree_nodes(nodes)
	}
	if win.window_info != unsafe { nil } {
		if nodes.len == 0 {
			C.window_set_tree_nodes(win.window_info, name.str, unsafe { nil }, 0)
			return win
		}
		mut flat := []&u8{}
		for node in nodes {
			flat << node.id.str
			flat << node.parent_id.str
			flat << node.text.str
		}
		C.window_set_tree_nodes(win.window_info, name.str, flat.data, flat.len)
	}
	return win
}

// get_tree_selected retrieves the tree selected of the window or target control.
pub fn (win &SimpleWindow) get_tree_selected(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_tree_selected(win.window_info, name.str)
		selected := unsafe { res.vstring() }
		idx := win.find_control(name)
		if idx >= 0 {
			unsafe {
				mut w := &SimpleWindow(win)
				mut entry := w.controls[idx]
				entry.value = selected
				w.controls[idx] = entry
			}
		}
		return selected
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// set_tree_selected sets the tree selected of the window or target control.
pub fn (win &SimpleWindow) set_tree_selected(name string, node_id string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			mut entry := w.controls[idx]
			entry.value = node_id
			w.controls[idx] = entry
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_tree_selected(win.window_info, name.str, node_id.str)
	}
	return win
}

// expand_tree opens all nodes in the target tree view.
pub fn (win &SimpleWindow) expand_tree(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_tree_expand_all(win.window_info, name.str)
	}
	return win
}

// open_tree is an alias for expand_tree.
pub fn (win &SimpleWindow) open_tree(name string) &SimpleWindow {
	return win.expand_tree(name)
}

// collapse_tree collapses all nodes in the target tree view.
pub fn (win &SimpleWindow) collapse_tree(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_tree_collapse_all(win.window_info, name.str)
	}
	return win
}

// close_tree is an alias for collapse_tree.
pub fn (win &SimpleWindow) close_tree(name string) &SimpleWindow {
	return win.collapse_tree(name)
}

// expand_tree_node expands a single node; optionally expands its descendants.
pub fn (win &SimpleWindow) expand_tree_node(name string, node_id string, expand_children bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		expand_val := if expand_children { 1 } else { 0 }
		C.window_tree_expand_node(win.window_info, name.str, node_id.str, expand_val)
	}
	return win
}

// collapse_tree_node collapses a single node; optionally collapses descendants.
pub fn (win &SimpleWindow) collapse_tree_node(name string, node_id string, collapse_children bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		collapse_val := if collapse_children { 1 } else { 0 }
		C.window_tree_collapse_node(win.window_info, name.str, node_id.str, collapse_val)
	}
	return win
}

// set_tree is an alias for set_tree_nodes.
pub fn (win &SimpleWindow) set_tree(name string, nodes []TreeNode) &SimpleWindow {
	return win.set_tree_nodes(name, nodes)
}

// clear_tree removes all tree nodes and clears the current selection.
pub fn (win &SimpleWindow) clear_tree(name string) &SimpleWindow {
	win.set_tree_selected(name, '')
	return win.set_tree_nodes(name, []TreeNode{})
}

// clear_tree_selection clears selection for the target tree control.
pub fn (win &SimpleWindow) clear_tree_selection(name string) &SimpleWindow {
	return win.set_tree_selected(name, '')
}

// get_tree_nodes returns a copy of all tree nodes registered for a tree control.
pub fn (win &SimpleWindow) get_tree_nodes(name string) []TreeNode {
	if name in win.tree_nodes {
		return clone_tree_nodes(win.tree_nodes[name])
	}
	return []TreeNode{}
}

// has_tree_node checks whether a node id exists in the target tree.
pub fn (win &SimpleWindow) has_tree_node(name string, node_id string) bool {
	for node in win.get_tree_nodes(name) {
		if node.id == node_id {
			return true
		}
	}
	return false
}

// get_tree_node returns a node by id when present.
pub fn (win &SimpleWindow) get_tree_node(name string, node_id string) ?TreeNode {
	for node in win.get_tree_nodes(name) {
		if node.id == node_id {
			return node
		}
	}
	return none
}

// add_tree_node inserts or updates one node and refreshes the control.
pub fn (win &SimpleWindow) add_tree_node(name string, node TreeNode) &SimpleWindow {
	if node.id.trim_space() == '' {
		return win
	}
	mut nodes := win.get_tree_nodes(name)
	mut replaced := false
	for i, existing in nodes {
		if existing.id == node.id {
			nodes[i] = TreeNode{
				id:        node.id
				parent_id: node.parent_id
				text:      node.text
			}
			replaced = true
			break
		}
	}
	if !replaced {
		nodes << node
	}
	return win.set_tree_nodes(name, nodes)
}

// remove_tree_node deletes one node; children can be removed or reparented.
pub fn (win &SimpleWindow) remove_tree_node(name string, node_id string, remove_children bool) &SimpleWindow {
	if node_id == '' {
		return win
	}
	mut nodes := win.get_tree_nodes(name)
	if nodes.len == 0 {
		return win
	}

	mut target_parent := ''
	mut found := false
	for node in nodes {
		if node.id == node_id {
			target_parent = node.parent_id
			found = true
			break
		}
	}
	if !found {
		return win
	}

	mut filtered := []TreeNode{}
	if remove_children {
		mut children_by_parent := map[string][]string{}
		for node in nodes {
			if node.parent_id == '' {
				continue
			}
			if node.parent_id !in children_by_parent {
				children_by_parent[node.parent_id] = []string{}
			}
			mut existing := children_by_parent[node.parent_id]
			existing << node.id
			children_by_parent[node.parent_id] = existing
		}

		mut to_remove := map[string]bool{}
		mut queue := [node_id]
		to_remove[node_id] = true
		for queue.len > 0 {
			current := queue[0]
			queue.delete(0)
			for child_id in children_by_parent[current] or { []string{} } {
				if child_id in to_remove {
					continue
				}
				to_remove[child_id] = true
				queue << child_id
			}
		}

		for node in nodes {
			if node.id in to_remove {
				continue
			}
			filtered << node
		}
	} else {
		for mut node in nodes {
			if node.id == node_id {
				continue
			}
			if node.parent_id == node_id {
				node.parent_id = target_parent
			}
			filtered << node
		}
	}

	if win.get_tree_selected(name) == node_id {
		win.set_tree_selected(name, '')
	}
	return win.set_tree_nodes(name, filtered)
}

// set_tree_node_text updates the display text of a single tree node.
pub fn (win &SimpleWindow) set_tree_node_text(name string, node_id string, text string) &SimpleWindow {
	mut nodes := win.get_tree_nodes(name)
	mut changed := false
	for i, node in nodes {
		if node.id == node_id {
			nodes[i] = TreeNode{
				id:        node.id
				parent_id: node.parent_id
				text:      text
			}
			changed = true
			break
		}
	}
	if !changed {
		return win
	}
	return win.set_tree_nodes(name, nodes)
}

// set_tree_paths builds a tree from slash-delimited path strings.
pub fn (win &SimpleWindow) set_tree_paths(name string, paths []string) &SimpleWindow {
	return win.set_tree_paths_with_separator(name, paths, '/')
}

// set_tree_paths_with_separator builds a tree from path strings using a custom separator.
pub fn (win &SimpleWindow) set_tree_paths_with_separator(name string, paths []string, separator string) &SimpleWindow {
	nodes := tree_nodes_from_paths(paths, separator)
	return win.set_tree_nodes(name, nodes)
}

// add_table adds a table control to the window layout.
pub fn (win &SimpleWindow) add_table(name string, columns []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('table')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'table'
			value: ''
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_cols := []&u8{}
		for col in columns {
			c_cols << col.str
		}
		C.window_add_table_control(win.window_info, real_name.str, c_cols.data, columns.len)
	}
	return win
}

// set_table_rows sets the table rows of the window or target control.
pub fn (win &SimpleWindow) set_table_rows(name string, rows [][]string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.table_rows[name] = rows.map(it.clone())
	}
	if win.window_info != unsafe { nil } {
		if rows.len == 0 {
			C.window_set_table_rows(win.window_info, name.str, unsafe { nil }, 0, 0)
			return win
		}
		cols_count := rows[0].len
		mut flat := []&u8{}
		for row in rows {
			for val in row {
				flat << val.str
			}
		}
		C.window_set_table_rows(win.window_info, name.str, flat.data, flat.len, cols_count)
	}
	return win
}

// load_table_from_structs loads an array of structs into a table control by mapping fields to columns.
pub fn (win &SimpleWindow) load_table_from_structs[T](name string, items []T) &SimpleWindow {
	mut rows := [][]string{}
	for item in items {
		mut row := []string{}
		$for field in T.fields {
			$if field.typ is string {
				row << item.$(field.name)
			} $else $if field.typ is int {
				row << item.$(field.name).str()
			} $else $if field.typ is bool {
				row << item.$(field.name).str()
			}
		}
		rows << row
	}
	win.set_table_rows(name, rows)
	return win
}

// get_values retrieves the values of the window or target control.
pub fn (win &SimpleWindow) get_values() map[string]string {
	mut values := map[string]string{}
	for control in win.controls {
		if control.kind in ['table', 'image', 'progress'] {
			continue
		}
		values[control.name] = win.get_text(control.name)
	}
	return values
}

// set_values sets the values of the window or target control.
pub fn (win &SimpleWindow) set_values(values map[string]string) &SimpleWindow {
	for name, val in values {
		win.set_text(name, val)
	}
	return win
}

// bind_to_struct populates a target struct instance with matching form/control values from the window.
pub fn (win &SimpleWindow) bind_to_struct[T](mut data T) &SimpleWindow {
	$for field in T.fields {
		name := field.name
		$if field.typ is string {
			data.$(field.name) = win.get_text(name)
		} $else $if field.typ is int {
			data.$(field.name) = win.get_value_int(name)
		} $else $if field.typ is bool {
			data.$(field.name) = win.get_checked(name)
		}
	}
	return win
}

// load_from_struct sets window control values from the matching fields of a struct instance.
pub fn (win &SimpleWindow) load_from_struct[T](data T) &SimpleWindow {
	$for field in T.fields {
		name := field.name
		$if field.typ is string {
			win.set_text(name, data.$(field.name))
		} $else $if field.typ is int {
			win.set_value_int(name, data.$(field.name))
		} $else $if field.typ is bool {
			win.set_checked(name, data.$(field.name))
		}
	}
	return win
}

// validate_struct validates that all controls corresponding to fields in struct T pass validation.
pub fn (win &SimpleWindow) validate_struct[T]() bool {
	mut all_valid := true
	$for field in T.fields {
		name := field.name
		mut val := ''
		$if field.typ is string {
			val = win.get_text(name)
		} $else $if field.typ is int {
			val = win.get_value_int(name).str()
		} $else $if field.typ is bool {
			val = win.get_checked(name).str()
		} $else {
			val = win.get_text(name)
		}

		mut err_msg := ''
		for attr in field.attrs {
			if attr == 'required' {
				if val.trim_space() == '' {
					err_msg = 'This field is required'
					break
				}
			} else if attr.starts_with('min_len:') {
				min_len := attr.all_after('min_len:').trim_space().int()
				if val.len < min_len {
					err_msg = 'Must be at least ${min_len} characters'
					break
				}
			} else if attr.starts_with('max_len:') {
				max_len := attr.all_after('max_len:').trim_space().int()
				if val.len > max_len {
					err_msg = 'Must be at most ${max_len} characters'
					break
				}
			} else if attr == 'email' {
				if val.trim_space() != '' {
					email_err := validate_email(val)
					if email_err != '' {
						err_msg = email_err
						break
					}
				}
			} else if attr == 'url' {
				if val.trim_space() != '' {
					url_err := validate_url(val)
					if url_err != '' {
						err_msg = url_err
						break
					}
				}
			} else if attr == 'alphanumeric' {
				if val.trim_space() != '' {
					alpha_err := validate_alphanumeric(val)
					if alpha_err != '' {
						err_msg = alpha_err
						break
					}
				}
			} else if attr.starts_with('min:') {
				$if field.typ is int {
					min_val := attr.all_after('min:').trim_space().int()
					int_val := win.get_value_int(name)
					if int_val < min_val {
						err_msg = 'Must be at least ${min_val}'
						break
					}
				}
			} else if attr.starts_with('max:') {
				$if field.typ is int {
					max_val := attr.all_after('max:').trim_space().int()
					int_val := win.get_value_int(name)
					if int_val > max_val {
						err_msg = 'Must be at most ${max_val}'
						break
					}
				}
			}
		}

		if err_msg != '' {
			win.set_error(name, err_msg)
			all_valid = false
		} else {
			win.clear_error(name)
		}
	}
	return all_valid
}

// Layout Rows and Form Generation Helpers
pub fn (win &SimpleWindow) add_action_row(actions map[string]VoidEventCallback) &SimpleWindow {
	row_name := win.auto_name('action_row')
	win.begin_row(row_name)
	for title, cb in actions {
		btn_name := win.auto_name('btn')
		win.add_action(btn_name, title, cb)
	}
	win.end_row()
	return win
}

// add_fields_row adds a fields row control to the window layout.
pub fn (win &SimpleWindow) add_fields_row(fields map[string]string) &SimpleWindow {
	row_name := win.auto_name('fields_row')
	win.begin_row(row_name)
	for label, name in fields {
		win.add_form_field(label, name, '')
	}
	win.end_row()
	return win
}

// add_form_from_struct dynamically generates a form in the window layout using the fields of struct T.
pub fn (win &SimpleWindow) add_form_from_struct[T](default_data T) &SimpleWindow {
	$for field in T.fields {
		name := field.name
		label := name.capitalize()
		$if field.typ is string {
			val := default_data.$(field.name)
			win.add_form_field(label, name, val)
		} $else $if field.typ is int {
			val := default_data.$(field.name)
			win.begin_row('${name}_row')
			win.add_label('${name}_label', label)
			win.add_number(name, val)
			win.end_row()
		} $else $if field.typ is bool {
			val := default_data.$(field.name)
			win.add_toggle(name, label, val)
		}
	}
	return win
}

// enable_status_bar performs enable status bar.
pub fn (win &SimpleWindow) enable_status_bar(icon_path string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_enable_status_bar(win.window_info, icon_path.str)
	}
	return win
}

// add_toolbar_item adds a toolbar item control to the window layout.
pub fn (win &SimpleWindow) add_toolbar_item(name string, label string, tooltip string, symbol string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_add_toolbar_item(win.window_info, name.str, label.str, tooltip.str, symbol.str)
	}
	return win
}

// add_toolbar_space adds a toolbar space control to the window layout.
pub fn (win &SimpleWindow) add_toolbar_space() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_add_toolbar_space(win.window_info)
	}
	return win
}

// add_toolbar_flexible_space adds a toolbar flexible space control to the window layout.
pub fn (win &SimpleWindow) add_toolbar_flexible_space() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_add_toolbar_flexible_space(win.window_info)
	}
	return win
}

// set_toolbar_style sets the toolbar style of the window or target control.
pub fn (win &SimpleWindow) set_toolbar_style(style string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_toolbar_style(win.window_info, style.str)
	}
	return win
}

// on_toolbar_click registers an event handler for on toolbar click events.
pub fn (win &SimpleWindow) on_toolbar_click(name string, callback VoidEventCallback) &SimpleWindow {
	return win.on_click(name, callback)
}

// show_sheet_alert performs show sheet alert.
pub fn (win &SimpleWindow) show_sheet_alert(title string, message string, style string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_show_sheet_alert(win.window_info, title.str, message.str, style.str)
	}
	return win
}

// add_dock_menu_item adds a dock menu item control to the window layout.
pub fn (win &SimpleWindow) add_dock_menu_item(title string, callback VoidEventCallback) &SimpleWindow {
	handler_name := 'dock_menu_${title.replace(' ', '_').to_lower()}'
	win.on_click(handler_name, callback)
	if win.window_info != unsafe { nil } {
		C.window_add_dock_menu_item(win.window_info, title.str, handler_name.str)
	}
	return win
}

// show_window performs show window.
pub fn (win &SimpleWindow) show_window() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_show(win.window_info)
	}
	return win
}

struct MainThreadCallback {
mut:
	win &SimpleWindow     = unsafe { nil }
	cb  VoidEventCallback = unsafe { nil }
}

// vlang_main_thread_dispatcher performs vlang main thread dispatcher.
fn vlang_main_thread_dispatcher(ctx voidptr) {
	mut data := unsafe { &MainThreadCallback(ctx) }
	cb := data.cb
	mut win := data.win
	cb(mut win)
	unsafe {
		free(data)
	}
}

// run_on_main_thread performs run on main thread.
pub fn (win &SimpleWindow) run_on_main_thread(callback VoidEventCallback) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		data := &MainThreadCallback{
			win: win
			cb:  callback
		}
		C.window_run_on_main_thread(vlang_main_thread_dispatcher, data)
	}
	return win
}

// run_on_main_thread_sync performs run on main thread and waits for completion.
pub fn (win &SimpleWindow) run_on_main_thread_sync(callback VoidEventCallback) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		data := &MainThreadCallback{
			win: win
			cb:  callback
		}
		C.window_run_on_main_thread_sync(vlang_main_thread_dispatcher, data)
	}
	return win
}

// run_async performs run async.
pub fn (win &SimpleWindow) run_async(bg_task fn (), on_complete VoidEventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		spawn fn [mut w, bg_task, on_complete] () {
			bg_task()
			w.run_on_main_thread(on_complete)
		}()
	}
	return win
}

// Closure-based row layout container
pub fn (win &SimpleWindow) row(name string, callback VoidEventCallback) &SimpleWindow {
	win.begin_row(name)
	unsafe {
		mut w := &SimpleWindow(win)
		callback(mut w)
	}
	win.end_row()
	return win
}

// Closure-based grid layout container
pub fn (win &SimpleWindow) grid(name string, columns int, spacing int, callback VoidEventCallback) &SimpleWindow {
	win.begin_grid(name, columns, spacing)
	unsafe {
		mut w := &SimpleWindow(win)
		callback(mut w)
	}
	win.end_grid()
	return win
}

// Closure-based flexbox layout container
pub fn (win &SimpleWindow) flex_box(name string, direction string, justify string, align string, callback VoidEventCallback) &SimpleWindow {
	win.begin_flex_box(name, direction, justify, align)
	unsafe {
		mut w := &SimpleWindow(win)
		callback(mut w)
	}
	win.end_flex_box()
	return win
}

// Theme represents a complete color scheme for SimpleWindow interface styling.
pub struct Theme {
pub:
	name             string
	background_color string
	font_color       string
	accent_color     string
	description      string
	is_dark          bool
}

// list_themes returns all built-in production theme preset names.
pub fn list_themes() []string {
	return [
		'Apple Light',
		'Apple Dark',
		'Midnight Space Gray',
		'Apple Sunset',
		'Sonoma Emerald',
		'Ventura Amber',
		'Soft Pastel',
		'Catppuccin Mocha',
		'Nord',
		'Dracula',
		'Cyberpunk',
		'Solarized Light',
		'Solarized Dark',
		'GitHub Dark',
		'GitHub Light',
		'Navy Blue',
		'Forest Green',
	]
}

// get_theme returns the Theme configuration matching theme_name (case-insensitive, normalized).
// Defaults to 'Apple Light' if the theme name is unknown.
pub fn get_theme(theme_name string) Theme {
	normalized := theme_name.to_lower().replace(' ', '_').replace('-', '_')
	match normalized {
		'apple_light', 'light' {
			return Theme{
				name:             'Apple Light'
				background_color: '#ffffff'
				font_color:       '#1c1c1e'
				accent_color:     '#007aff'
				description:      'Clean macOS Aqua system light interface'
				is_dark:          false
			}
		}
		'apple_dark', 'dark' {
			return Theme{
				name:             'Apple Dark'
				background_color: '#1c1c1e'
				font_color:       '#f2f2f7'
				accent_color:     '#0a84ff'
				description:      'Vibrant macOS Dark Mode surface'
				is_dark:          true
			}
		}
		'midnight_space_gray', 'midnight', 'space_gray' {
			return Theme{
				name:             'Midnight Space Gray'
				background_color: '#161618'
				font_color:       '#ebebf5'
				accent_color:     '#0a84ff'
				description:      'Pro dark titanium space gray theme'
				is_dark:          true
			}
		}
		'apple_sunset', 'sunset', 'mojave' {
			return Theme{
				name:             'Apple Sunset'
				background_color: '#281a24'
				font_color:       '#fdf7f4'
				accent_color:     '#ff6b00'
				description:      'Warm macOS twilight sunset aesthetics'
				is_dark:          true
			}
		}
		'sonoma_emerald', 'sonoma', 'emerald' {
			return Theme{
				name:             'Sonoma Emerald'
				background_color: '#0d1f18'
				font_color:       '#f0fdf4'
				accent_color:     '#30d158'
				description:      'macOS Sonoma dark forest glass palette'
				is_dark:          true
			}
		}
		'ventura_amber', 'ventura', 'amber' {
			return Theme{
				name:             'Ventura Amber'
				background_color: '#211815'
				font_color:       '#fff8f0'
				accent_color:     '#ff9500'
				description:      'macOS Ventura golden sunset dark hues'
				is_dark:          true
			}
		}
		'soft_pastel', 'pastel', 'cupcake' {
			return Theme{
				name:             'Soft Pastel'
				background_color: '#faf6f0'
				font_color:       '#2d2b2a'
				accent_color:     '#e07a5f'
				description:      'Apple Studio warm soft pastel light palette'
				is_dark:          false
			}
		}
		'catppuccin_mocha', 'catppuccin', 'mocha' {
			return Theme{
				name:             'Catppuccin Mocha'
				background_color: '#1e1e2e'
				font_color:       '#cdd6f4'
				accent_color:     '#cba6f7'
				description:      'Soothing lavender catppuccin dark mode'
				is_dark:          true
			}
		}
		'nord' {
			return Theme{
				name:             'Nord'
				background_color: '#2e3440'
				font_color:       '#eceff4'
				accent_color:     '#88c0d0'
				description:      'Arctic frost nord developer theme'
				is_dark:          true
			}
		}
		'dracula' {
			return Theme{
				name:             'Dracula'
				background_color: '#282a36'
				font_color:       '#f8f8f2'
				accent_color:     '#bd93f9'
				description:      'High-contrast vampire purple theme'
				is_dark:          true
			}
		}
		'cyberpunk', 'neon' {
			return Theme{
				name:             'Cyberpunk'
				background_color: '#0d0d15'
				font_color:       '#00f5d4'
				accent_color:     '#ff007f'
				description:      'Neon glow dark contrast palette'
				is_dark:          true
			}
		}
		'solarized_light' {
			return Theme{
				name:             'Solarized Light'
				background_color: '#fdf6e3'
				font_color:       '#657b83'
				accent_color:     '#268bd2'
				description:      'Precision engineered light theme'
				is_dark:          false
			}
		}
		'solarized_dark' {
			return Theme{
				name:             'Solarized Dark'
				background_color: '#002b36'
				font_color:       '#839496'
				accent_color:     '#2aa198'
				description:      'Precision engineered dark theme'
				is_dark:          true
			}
		}
		'github_dark' {
			return Theme{
				name:             'GitHub Dark'
				background_color: '#0d1117'
				font_color:       '#c9d1d9'
				accent_color:     '#58a6ff'
				description:      'Official GitHub dark interface palette'
				is_dark:          true
			}
		}
		'github_light' {
			return Theme{
				name:             'GitHub Light'
				background_color: '#ffffff'
				font_color:       '#24292f'
				accent_color:     '#0969da'
				description:      'Clean GitHub light canvas palette'
				is_dark:          false
			}
		}
		'navy_blue', 'navy' {
			return Theme{
				name:             'Navy Blue'
				background_color: '#0f172a'
				font_color:       '#f8fafc'
				accent_color:     '#38bdf8'
				description:      'Deep navy slate interface'
				is_dark:          true
			}
		}
		'forest_green', 'forest' {
			return Theme{
				name:             'Forest Green'
				background_color: '#14532d'
				font_color:       '#f0fdf4'
				accent_color:     '#4ade80'
				description:      'Rich emerald green dark theme'
				is_dark:          true
			}
		}
		else {
			return Theme{
				name:             'Apple Light'
				background_color: '#f6f6f7'
				font_color:       '#1c1c1e'
				accent_color:     '#007aff'
				description:      'Clean macOS Aqua system light interface'
				is_dark:          false
			}
		}
	}
}

// apply_theme applies a Theme struct configuration to the window.
pub fn (win &SimpleWindow) apply_theme(t Theme) &SimpleWindow {
	win.set_background_color(t.background_color)
	win.set_font_color(t.font_color)
	return win
}

// set_theme sets the window background and font colors based on built-in theme name or preset.
pub fn (win &SimpleWindow) set_theme(theme_name string) &SimpleWindow {
	t := get_theme(theme_name)
	return win.apply_theme(t)
}

// last-control chaining modifiers
pub fn (win &SimpleWindow) width(w int) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_width(win.last_control, w)
	}
	return win
}

// height performs height.
pub fn (win &SimpleWindow) height(h int) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_height(win.last_control, h)
	}
	return win
}

// font_size performs font size.
pub fn (win &SimpleWindow) font_size(size int) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_font_size(win.last_control, size)
	}
	return win
}

// color performs color.
pub fn (win &SimpleWindow) color(hex_color string) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_background_color(win.last_control, hex_color)
	}
	return win
}

// font_color performs font color.
pub fn (win &SimpleWindow) font_color(hex_color string) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_font_color(win.last_control, hex_color)
	}
	return win
}

// bold performs bold.
pub fn (win &SimpleWindow) bold(b bool) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_font_bold(win.last_control, b)
	}
	return win
}

// font_name performs font name.
pub fn (win &SimpleWindow) font_name(font_name string) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_font_name(win.last_control, font_name)
	}
	return win
}

// placeholder performs placeholder.
pub fn (win &SimpleWindow) placeholder(text string) &SimpleWindow {
	if win.last_control != '' {
		win.set_placeholder(win.last_control, text)
	}
	return win
}

// error performs error.
pub fn (win &SimpleWindow) error(text string) &SimpleWindow {
	if win.last_control != '' {
		win.set_error(win.last_control, text)
	}
	return win
}

// tooltip performs tooltip.
pub fn (win &SimpleWindow) tooltip(text string) &SimpleWindow {
	if win.last_control != '' {
		win.set_tooltip(win.last_control, text)
	}
	return win
}

// visible performs visible.
pub fn (win &SimpleWindow) visible(visible bool) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_visible(win.last_control, visible)
	}
	return win
}

// enabled performs enabled.
pub fn (win &SimpleWindow) enabled(enabled bool) &SimpleWindow {
	if win.last_control != '' {
		win.set_control_enabled(win.last_control, enabled)
	}
	return win
}

// set_control_alignment sets explicit layout alignment ('left', 'center', 'right', 'top', 'bottom') for a named control.
pub fn (win &SimpleWindow) set_control_alignment(name string, alignment string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_control_alignment_by_name(win.window_info, name.str, alignment.str)
	}
	for i in 0 .. win.controls.len {
		if win.controls[i].name == name {
			unsafe {
				win.controls[i].alignment = alignment
			}
			break
		}
	}
	return win
}

// get_control_alignment returns the alignment of a named control.
pub fn (win &SimpleWindow) get_control_alignment(name string) string {
	for control in win.controls {
		if control.name == name {
			return control.alignment
		}
	}
	return ''
}

// set_control_expand_fill enables or disables fill expansion for a named control in its container.
pub fn (win &SimpleWindow) set_control_expand_fill(name string, expand bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_control_expand_fill_by_name(win.window_info, name.str, if expand {
			1
		} else {
			0
		})
	}
	for i in 0 .. win.controls.len {
		if win.controls[i].name == name {
			unsafe {
				win.controls[i].expand_fill = expand
			}
			break
		}
	}
	return win
}

// get_control_expand_fill returns true if fill expansion is enabled for a named control.
pub fn (win &SimpleWindow) get_control_expand_fill(name string) bool {
	for control in win.controls {
		if control.name == name {
			return control.expand_fill
		}
	}
	return false
}

// align_left aligns the last created control to the left.
pub fn (win &SimpleWindow) align_left() &SimpleWindow {
	if win.last_control != '' {
		win.set_control_alignment(win.last_control, 'left')
	}
	return win
}

// align_center aligns the last created control to the center.
pub fn (win &SimpleWindow) align_center() &SimpleWindow {
	if win.last_control != '' {
		win.set_control_alignment(win.last_control, 'center')
	}
	return win
}

// align_right aligns the last created control to the right.
pub fn (win &SimpleWindow) align_right() &SimpleWindow {
	if win.last_control != '' {
		win.set_control_alignment(win.last_control, 'right')
	}
	return win
}

// align_top aligns the last created control to the top.
pub fn (win &SimpleWindow) align_top() &SimpleWindow {
	if win.last_control != '' {
		win.set_control_alignment(win.last_control, 'top')
	}
	return win
}

// align_bottom aligns the last created control to the bottom.
pub fn (win &SimpleWindow) align_bottom() &SimpleWindow {
	if win.last_control != '' {
		win.set_control_alignment(win.last_control, 'bottom')
	}
	return win
}

// expand_fill configures the last created control to expand and fill available container space.
pub fn (win &SimpleWindow) expand_fill() &SimpleWindow {
	if win.last_control != '' {
		win.set_control_expand_fill(win.last_control, true)
	}
	return win
}

// Fluent event chaining modifiers (attaching to the last created control)
pub fn (win &SimpleWindow) onclick(callback VoidEventCallback) &SimpleWindow {
	if win.last_control != '' {
		win.on_click(win.last_control, callback)
	}
	return win
}

// onchange registers an event handler for onchange events.
pub fn (win &SimpleWindow) onchange(callback StringEventCallback) &SimpleWindow {
	if win.last_control != '' {
		win.on_change(win.last_control, callback)
	}
	return win
}

// onfocus registers an event handler for onfocus events.
pub fn (win &SimpleWindow) onfocus(callback VoidEventCallback) &SimpleWindow {
	if win.last_control != '' {
		win.on_focus(win.last_control, callback)
	}
	return win
}

// onblur registers an event handler for onblur events.
pub fn (win &SimpleWindow) onblur(callback VoidEventCallback) &SimpleWindow {
	if win.last_control != '' {
		win.on_blur(win.last_control, callback)
	}
	return win
}

// onenter registers an event handler for onenter events.
pub fn (win &SimpleWindow) onenter(callback VoidEventCallback) &SimpleWindow {
	if win.last_control != '' {
		win.on_enter(win.last_control, callback)
	}
	return win
}

// onhover registers an event handler for onhover events.
pub fn (win &SimpleWindow) onhover(callback VoidEventCallback) &SimpleWindow {
	if win.last_control != '' {
		win.on_hover(win.last_control, callback)
	}
	return win
}

// onhover_exit registers an event handler for onhover exit events.
pub fn (win &SimpleWindow) onhover_exit(callback VoidEventCallback) &SimpleWindow {
	if win.last_control != '' {
		win.on_hover_exit(win.last_control, callback)
	}
	return win
}

// Shorthand aliases for value access
pub fn (win &SimpleWindow) get(name string) string {
	return win.get_text(name)
}

// set dynamically sets the value of a control based on the type of the value passed.
pub fn (win &SimpleWindow) set[T](name string, value T) &SimpleWindow {
	$if T is string {
		return win.set_text(name, value)
	} $else $if T is bool {
		return win.set_bool(name, value)
	} $else $if T is int {
		return win.set_number_value(name, value)
	} $else $if T is f64 {
		return win.set_float(name, value)
	} $else {
		return win.set_text(name, value.str())
	}
}

// get_as retrieves and casts the value of a control to the target type T.
pub fn (win &SimpleWindow) get_as[T](name string) T {
	$if T is string {
		return win.get_text(name)
	} $else $if T is bool {
		return win.get_bool(name)
	} $else $if T is int {
		return win.get_int(name)
	} $else $if T is f64 {
		return win.get_float(name)
	} $else {
		return T{}
	}
}

// Clears the validation error state on a single control
pub fn (win &SimpleWindow) clear_error(name string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.errors.delete(name)
	}
	if win.window_info != unsafe { nil } {
		C.window_set_error_by_name(win.window_info, name.str, c'')
	}
	return win
}

// Starts a visual group box, executes the callback for child controls, and returns the window
pub fn (win &SimpleWindow) group(name string, title string, callback VoidEventCallback) &SimpleWindow {
	win.add_group_box(name, title)
	unsafe {
		mut w := &SimpleWindow(win)
		callback(mut w)
	}
	return win
}

// Validation error clearing
pub fn (win &SimpleWindow) clear_errors() &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		for name, _ in w.errors {
			if win.window_info != nil {
				C.window_set_error_by_name(win.window_info, name.str, c'')
			}
		}
		w.errors = map[string]string{}
	}
	return win
}

// Change/Dirty state tracking helpers
pub fn (win &SimpleWindow) is_control_dirty(name string) bool {
	idx := win.find_control(name)
	if idx < 0 {
		return false
	}
	entry := win.controls[idx]
	if entry.kind in ['label', 'button', 'image', 'html_view', 'progress', 'helpbutton',
		'imagebutton', 'stat_card', 'banner', 'section_header'] {
		return false
	}
	if entry.kind in ['checkbox', 'toggle', 'spinner'] {
		return entry.checked != entry.initial_checked
	}
	if entry.kind in ['number', 'slider', 'vertical_slider', 'levelindicator', 'stepper', 'knob'] {
		return entry.number != entry.initial_number
	}
	return entry.value != entry.initial_value
}

// is_dirty checks if the window or control is dirty.
pub fn (win &SimpleWindow) is_dirty() bool {
	for entry in win.controls {
		if win.is_control_dirty(entry.name) {
			return true
		}
	}
	return false
}

// Set current control values as the baseline initial state
pub fn (win &SimpleWindow) commit_changes() &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		for i in 0 .. w.controls.len {
			w.controls[i].initial_value = w.controls[i].value
			w.controls[i].initial_checked = w.controls[i].checked
			w.controls[i].initial_number = w.controls[i].number
		}
	}
	return win
}

// get_dirty_controls retrieves the dirty controls of the window or target control.
pub fn (win &SimpleWindow) get_dirty_controls() []string {
	mut dirty := []string{}
	for entry in win.controls {
		if win.is_control_dirty(entry.name) {
			dirty << entry.name
		}
	}
	return dirty
}

// get_dirty_values retrieves the dirty values of the window or target control.
pub fn (win &SimpleWindow) get_dirty_values() map[string]string {
	mut values := map[string]string{}
	for entry in win.controls {
		if win.is_control_dirty(entry.name) {
			if entry.kind in ['checkbox', 'toggle', 'spinner'] {
				values[entry.name] = win.get_checked(entry.name).str()
			} else if entry.kind in ['number', 'slider', 'vertical_slider', 'levelindicator',
				'stepper', 'knob'] {
				values[entry.name] = win.get_value_int(entry.name).str()
			} else {
				values[entry.name] = win.get_text(entry.name)
			}
		}
	}
	return values
}

// set_status_temp sets the status temp of the window or target control.
pub fn (win &SimpleWindow) set_status_temp(message string, ms int) &SimpleWindow {
	current_status := win.get_status()
	win.set_status(message)
	win.after(ms, fn [current_status] (mut w SimpleWindow) {
		w.set_status(current_status)
	})
	return win
}

// status_temp performs status temp.
pub fn (win &SimpleWindow) status_temp(message string, ms int) &SimpleWindow {
	return win.set_status_temp(message, ms)
}

// style_controls performs style controls.
pub fn (win &SimpleWindow) style_controls(names []string, style_fn fn (name string, mut w SimpleWindow)) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		for name in names {
			style_fn(name, mut w)
		}
	}
	return win
}

// notify performs notify.
pub fn (win &SimpleWindow) notify(title string, message string) &SimpleWindow {
	C.window_deliver_notification(title.str, message.str)
	return win
}

// badge performs badge.
pub fn (win &SimpleWindow) badge(text string) &SimpleWindow {
	C.window_set_dock_badge(text.str)
	return win
}

// set_slider_range sets the slider range of the window or target control.
pub fn (win &SimpleWindow) set_slider_range(name string, min_val f64, max_val f64) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_slider_range(win.window_info, name.str, min_val, max_val)
	}
	return win
}

// range performs range.
pub fn (win &SimpleWindow) range(min_val f64, max_val f64) &SimpleWindow {
	if win.last_control != '' {
		win.set_slider_range(win.last_control, min_val, max_val)
	}
	return win
}

// beep performs beep.
pub fn beep() {
	C.window_beep()
}

// enable_search_history performs enable search history.
pub fn (win &SimpleWindow) enable_search_history(name string, autosave_name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_enable_search_history(win.window_info, name.str, autosave_name.str)
	}
	return win
}

// set_status_bar_icon sets the status bar icon of the window or target control.
pub fn (win &SimpleWindow) set_status_bar_icon(icon_path string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_status_bar_icon(win.window_info, icon_path.str)
	}
	return win
}

// set_status_bar_title sets the status bar title of the window or target control.
pub fn (win &SimpleWindow) set_status_bar_title(title string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_status_bar_title(win.window_info, title.str)
	}
	return win
}

// set_dock_icon sets the dock icon of the window or target control.
pub fn (win &SimpleWindow) set_dock_icon(image_path string) &SimpleWindow {
	C.window_set_dock_icon(image_path.str)
	return win
}

// clear_dock_icon clears the content of dock icon.
pub fn (win &SimpleWindow) clear_dock_icon() &SimpleWindow {
	C.window_set_dock_icon(c'')
	return win
}

// play_sound performs play sound.
pub fn play_sound(sound_name string) {
	C.window_play_system_sound(sound_name.str)
}

// begin_split_view begins a split view container in the layout.
pub fn (win &SimpleWindow) begin_split_view(name string, vertical bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		vert := if vertical { 1 } else { 0 }
		C.window_begin_split_view(win.window_info, name.str, vert)
	}
	return win
}

// split_view_next_pane performs split view next pane.
pub fn (win &SimpleWindow) split_view_next_pane() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_split_view_next_pane(win.window_info)
	}
	return win
}

// end_split_view ends the current split view container layout.
pub fn (win &SimpleWindow) end_split_view() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_end_split_view(win.window_info)
	}
	return win
}

// add_collection_view adds a collection view control to the window layout.
pub fn (win &SimpleWindow) add_collection_view(name string, item_width int, item_height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('collection')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name: real_name
			kind: 'collection'
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_collection_view_control(win.window_info, real_name.str, item_width,
			item_height)
	}
	return win
}

// set_collection_items sets the collection items of the window or target control.
pub fn (win &SimpleWindow) set_collection_items(name string, items []string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		mut c_items := []&u8{}
		for it in items {
			c_items << it.str
		}
		C.window_set_collection_items(win.window_info, name.str, c_items.data, items.len)
	}
	return win
}

// show_popover performs show popover.
pub fn (win &SimpleWindow) show_popover(anchor_name string, title string, message string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_show_popover(win.window_info, anchor_name.str, title.str, message.str)
	}
	return win
}

// add_calendar adds a calendar control to the window layout.
pub fn (win &SimpleWindow) add_calendar(name string, date string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('calendar')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'calendar'
			value: date
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_calendar_control(win.window_info, real_name.str, date.str)
	}
	return win
}

// add_canvas adds a canvas control to the window layout.
pub fn (win &SimpleWindow) add_canvas(name string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('canvas')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name: real_name
			kind: 'canvas'
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_canvas_control(win.window_info, real_name.str, height)
	}
	return win
}

// draw_line draws a line on the specified canvas control.
pub fn (win &SimpleWindow) draw_line(canvas_name string, x1 f64, y1 f64, x2 f64, y2 f64, color string, stroke_width f64) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_draw_line(win.window_info, canvas_name.str, x1, y1, x2, y2, color.str,
			stroke_width)
	}
	return win
}

// draw_rect draws a rect on the specified canvas control.
pub fn (win &SimpleWindow) draw_rect(canvas_name string, x f64, y f64, w f64, h f64, color string, fill bool, stroke_width f64) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		fill_val := if fill { 1 } else { 0 }
		C.window_draw_rect(win.window_info, canvas_name.str, x, y, w, h, color.str, fill_val,
			stroke_width)
	}
	return win
}

// draw_circle draws a circle on the specified canvas control.
pub fn (win &SimpleWindow) draw_circle(canvas_name string, x f64, y f64, r f64, color string, fill bool, stroke_width f64) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		fill_val := if fill { 1 } else { 0 }
		C.window_draw_circle(win.window_info, canvas_name.str, x, y, r, color.str, fill_val,
			stroke_width)
	}
	return win
}

// clear_canvas clears the content of canvas.
pub fn (win &SimpleWindow) clear_canvas(canvas_name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_clear_canvas(win.window_info, canvas_name.str)
	}
	return win
}

// begin_glass_box begins a glass box container in the layout.
pub fn (win &SimpleWindow) begin_glass_box(name string, material string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_begin_glass_box(win.window_info, name.str, material.str)
	}
	return win
}

// end_glass_box ends the current glass box container layout.
pub fn (win &SimpleWindow) end_glass_box() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_end_glass_box(win.window_info)
	}
	return win
}

// add_badge adds a badge control to the window layout.
pub fn (win &SimpleWindow) add_badge(name string, text string, style string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('badge')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'badge'
			value: text
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_badge_control(win.window_info, real_name.str, text.str, style.str)
	}
	return win
}

// add_icon_segments adds a icon segments control to the window layout.
pub fn (win &SimpleWindow) add_icon_segments(name string, symbols []string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('icon_segments')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'icon_segments'
			value: selected
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_symbols := []&u8{}
		for sym in symbols {
			c_symbols << sym.str
		}
		C.window_add_icon_segments_control(win.window_info, real_name.str, c_symbols.data,
			symbols.len, selected.str)
	}
	return win
}

// add_stat_card adds a stat card dashboard widget with custom title, value, trend and trend style.
pub fn (win &SimpleWindow) add_stat_card(name string, title string, value string, trend string, trend_style string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('stat_card')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'stat_card'
			value: value
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_stat_card_control(win.window_info, real_name.str, title.str, value.str,
			trend.str, trend_style.str)
	}
	return win
}

// stat_card inserts an auto-named stat card.
pub fn (win &SimpleWindow) stat_card(title string, value string, trend string, trend_style string) &SimpleWindow {
	return win.add_stat_card('', title, value, trend, trend_style)
}

// add_banner adds a banner callout with a message and style.
pub fn (win &SimpleWindow) add_banner(name string, text string, style string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('banner')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'banner'
			value: text
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_banner_control(win.window_info, real_name.str, text.str, style.str)
	}
	return win
}

// banner inserts an auto-named banner.
pub fn (win &SimpleWindow) banner(text string, style string) &SimpleWindow {
	return win.add_banner('', text, style)
}

// add_section_header adds a styled layout divider with title and optional subtitle.
pub fn (win &SimpleWindow) add_section_header(name string, title string, subtitle string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('section_header')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'section_header'
			value: title
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_section_header_control(win.window_info, real_name.str, title.str,
			subtitle.str)
	}
	return win
}

// section_header inserts an auto-named section header.
pub fn (win &SimpleWindow) section_header(title string, subtitle string) &SimpleWindow {
	return win.add_section_header('', title, subtitle)
}

// add_vertical_slider adds a vertical slider to the layout.
pub fn (win &SimpleWindow) add_vertical_slider(name string, value int, min_val int, max_val int, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('vertical_slider')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:   real_name
			kind:   'vertical_slider'
			value:  value.str()
			number: value
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_vertical_slider_control(win.window_info, real_name.str, value, min_val,
			max_val, height)
	}
	return win
}

// vertical_slider inserts an auto-named vertical slider.
pub fn (win &SimpleWindow) vertical_slider(value int, min_val int, max_val int, height int) &SimpleWindow {
	return win.add_vertical_slider('', value, min_val, max_val, height)
}

// add_chip_group adds a segmented chip group selectors to the layout.
pub fn (win &SimpleWindow) add_chip_group(name string, chips []string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('chip_group')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'chip_group'
			value: selected
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_chips := []&u8{}
		for chip in chips {
			c_chips << chip.str
		}
		C.window_add_chip_group_control(win.window_info, real_name.str, c_chips.data,
			chips.len, selected.str)
	}
	return win
}

// chip_group inserts an auto-named chip group.
pub fn (win &SimpleWindow) chip_group(chips []string, selected string) &SimpleWindow {
	return win.add_chip_group('', chips, selected)
}

// icon_segments inserts an auto-named icon segments control.
pub fn (win &SimpleWindow) icon_segments(symbols []string, selected string) &SimpleWindow {
	return win.add_icon_segments('', symbols, selected)
}

// add_status_indicator adds a LED-styled status indicator light with text label.
pub fn (win &SimpleWindow) add_status_indicator(name string, label string, status string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('status_indicator')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'status_indicator'
			value: status
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_status_indicator_control(win.window_info, real_name.str, label.str,
			status.str)
	}
	return win
}

// status_indicator inserts an auto-named status indicator light.
pub fn (win &SimpleWindow) status_indicator(label string, status string) &SimpleWindow {
	return win.add_status_indicator('', label, status)
}

// add_metric_meter adds a metric meter control with title, fill percentage bar, and right-aligned value label.
pub fn (win &SimpleWindow) add_metric_meter(name string, title string, value int, min_val int, max_val int, unit string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('metric_meter')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:   real_name
			kind:   'metric_meter'
			value:  value.str()
			number: value
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_metric_meter_control(win.window_info, real_name.str, title.str, value,
			min_val, max_val, unit.str)
	}
	return win
}

// metric_meter inserts an auto-named metric meter control.
pub fn (win &SimpleWindow) metric_meter(title string, value int, min_val int, max_val int, unit string) &SimpleWindow {
	return win.add_metric_meter('', title, value, min_val, max_val, unit)
}

// add_avatar_card adds a user profile avatar tile with round initial icon, title, subtitle, and status pill.
pub fn (win &SimpleWindow) add_avatar_card(name string, title string, subtitle string, status string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('avatar_card')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'avatar_card'
			value: title
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_avatar_card_control(win.window_info, real_name.str, title.str, subtitle.str,
			status.str)
	}
	return win
}

// avatar_card inserts an auto-named avatar card.
pub fn (win &SimpleWindow) avatar_card(title string, subtitle string, status string) &SimpleWindow {
	return win.add_avatar_card('', title, subtitle, status)
}

// add_time_picker adds a standalone time picker control (clock/time selector) to the layout.
pub fn (win &SimpleWindow) add_time_picker(name string, time string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('time_picker')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'time_picker'
			value: time
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_time_picker_control(win.window_info, real_name.str, time.str)
	}
	return win
}

// time_picker inserts an auto-named time picker control.
pub fn (win &SimpleWindow) time_picker(time string) &SimpleWindow {
	return win.add_time_picker('', time)
}

// add_tray_icon creates a system menu bar status item / tray icon.
pub fn (win &SimpleWindow) add_tray_icon(name string, symbol string, title string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('tray_icon')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'tray_icon'
			value: title
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_tray_icon_control(win.window_info, real_name.str, symbol.str, title.str)
	}
	return win
}

// tray_icon inserts an auto-named tray icon.
pub fn (win &SimpleWindow) tray_icon(symbol string, title string) &SimpleWindow {
	return win.add_tray_icon('', symbol, title)
}

// add_collapsible_section adds a collapsible accordion container section header.
pub fn (win &SimpleWindow) add_collapsible_section(name string, title string, expanded bool) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('collapsible_section')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:    real_name
			kind:    'collapsible_section'
			value:   title
			checked: expanded
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_collapsible_section_control(win.window_info, real_name.str, title.str,
			if expanded { 1 } else { 0 })
	}
	return win
}

// collapsible_section inserts an auto-named collapsible section header.
pub fn (win &SimpleWindow) collapsible_section(title string, expanded bool) &SimpleWindow {
	return win.add_collapsible_section('', title, expanded)
}

// add_code_editor adds a dark monospaced code editor view.
pub fn (win &SimpleWindow) add_code_editor(name string, code string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('code_editor')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'code_editor'
			value: code
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_code_editor_control(win.window_info, real_name.str, code.str, height)
	}
	return win
}

// code_editor inserts an auto-named code editor view.
pub fn (win &SimpleWindow) code_editor(code string, height int) &SimpleWindow {
	return win.add_code_editor('', code, height)
}

// add_timeline_view adds an activity feed timeline stream widget.
pub fn (win &SimpleWindow) add_timeline_view(name string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('timeline_view')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name: real_name
			kind: 'timeline_view'
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_timeline_view_control(win.window_info, real_name.str, height)
	}
	return win
}

// timeline_view inserts an auto-named timeline view widget.
pub fn (win &SimpleWindow) timeline_view(height int) &SimpleWindow {
	return win.add_timeline_view('', height)
}

// add_star_rating adds an interactive star rating control.
pub fn (win &SimpleWindow) add_star_rating(name string, value int, max_stars int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('rating')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'rating'
			value: value.str()
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_rating_control(win.window_info, real_name.str, value, max_stars)
	}
	return win
}

// star_rating inserts an auto-named star rating widget.
pub fn (win &SimpleWindow) star_rating(value int, max_stars int) &SimpleWindow {
	return win.add_star_rating('', value, max_stars)
}

// set_star_rating_value updates rating value for a control.
pub fn (win &SimpleWindow) set_star_rating_value(name string, value int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_rating_value(win.window_info, name.str, value)
	}
	return win
}

// get_star_rating_value gets selected rating value for a control.
pub fn (win &SimpleWindow) get_star_rating_value(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_rating_value(win.window_info, name.str)
	}
	return 0
}

// add_range_slider adds a dual-thumb range selector slider widget.
pub fn (win &SimpleWindow) add_range_slider(name string, min_val int, max_val int, low_val int, high_val int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('range_slider')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'range_slider'
			value: '${low_val}:${high_val}'
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_range_slider_control(win.window_info, real_name.str, min_val, max_val,
			low_val, high_val)
	}
	return win
}

// range_slider inserts an auto-named range slider widget.
pub fn (win &SimpleWindow) range_slider(min_val int, max_val int, low_val int, high_val int) &SimpleWindow {
	return win.add_range_slider('', min_val, max_val, low_val, high_val)
}

// set_range_slider_values sets the low and high range values for a range slider.
pub fn (win &SimpleWindow) set_range_slider_values(name string, low_val int, high_val int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_range_slider_values(win.window_info, name.str, low_val, high_val)
	}
	return win
}

// get_range_slider_low gets low range boundary.
pub fn (win &SimpleWindow) get_range_slider_low(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_range_slider_low(win.window_info, name.str)
	}
	return 0
}

// get_range_slider_high gets high range boundary.
pub fn (win &SimpleWindow) get_range_slider_high(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_range_slider_high(win.window_info, name.str)
	}
	return 0
}

// add_split_button adds a primary action button paired with a secondary drop-down popup menu.
pub fn (win &SimpleWindow) add_split_button(name string, title string, menu_items []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('split_button')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'split_button'
			value: title
		}
	}
	if win.window_info != unsafe { nil } {
		c_items := menu_items.map(it.str)
		C.window_add_split_button_control(win.window_info, real_name.str, title.str, c_items.data,
			c_items.len)
	}
	return win
}

// split_button inserts an auto-named split button widget.
pub fn (win &SimpleWindow) split_button(title string, menu_items []string) &SimpleWindow {
	return win.add_split_button('', title, menu_items)
}

// add_tag_cloud adds an interactive tag chips list widget.
pub fn (win &SimpleWindow) add_tag_cloud(name string, tags []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('tag_cloud')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'tag_cloud'
			value: tags.join(',')
		}
	}
	if win.window_info != unsafe { nil } {
		c_tags := tags.map(it.str)
		C.window_add_tag_cloud_control(win.window_info, real_name.str, c_tags.data, c_tags.len)
	}
	return win
}

// tag_cloud inserts an auto-named tag cloud widget.
pub fn (win &SimpleWindow) tag_cloud(tags []string) &SimpleWindow {
	return win.add_tag_cloud('', tags)
}

// set_tag_cloud_tags updates the active tag list in a tag cloud control.
pub fn (win &SimpleWindow) set_tag_cloud_tags(name string, tags []string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		c_tags := tags.map(it.str)
		C.window_set_tag_cloud_tags(win.window_info, name.str, c_tags.data, c_tags.len)
	}
	return win
}

// add_wizard_stepper adds a multi-step process flow indicator bar.
pub fn (win &SimpleWindow) add_wizard_stepper(name string, steps []string, current_step int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('wizard_stepper')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'wizard_stepper'
			value: current_step.str()
		}
	}
	if win.window_info != unsafe { nil } {
		c_steps := steps.map(it.str)
		C.window_add_wizard_stepper_control(win.window_info, real_name.str, c_steps.data,
			c_steps.len, current_step)
	}
	return win
}

// wizard_stepper inserts an auto-named wizard stepper widget.
pub fn (win &SimpleWindow) wizard_stepper(steps []string, current_step int) &SimpleWindow {
	return win.add_wizard_stepper('', steps, current_step)
}

// set_wizard_stepper_step updates active step index in a wizard stepper.
pub fn (win &SimpleWindow) set_wizard_stepper_step(name string, step int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_wizard_stepper_step(win.window_info, name.str, step)
	}
	return win
}

// add_gauge adds a progress/level gauge indicator widget.
pub fn (win &SimpleWindow) add_gauge(name string, title string, value int, min_val int, max_val int, unit string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('gauge')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'gauge'
			value: value.str()
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_gauge_control(win.window_info, real_name.str, title.str, value, min_val,
			max_val, unit.str)
	}
	return win
}

// gauge inserts an auto-named gauge widget.
pub fn (win &SimpleWindow) gauge(title string, value int, min_val int, max_val int, unit string) &SimpleWindow {
	return win.add_gauge('', title, value, min_val, max_val, unit)
}

// set_gauge_value updates gauge numeric value.
pub fn (win &SimpleWindow) set_gauge_value(name string, value int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = value.str()
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_gauge_value(win.window_info, name.str, value)
	}
	return win
}

// get_gauge_value retrieves current gauge numeric value.
pub fn (win &SimpleWindow) get_gauge_value(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_gauge_value(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value.int()
	}
	return 0
}

// add_pagination adds a page navigation bar widget.
pub fn (win &SimpleWindow) add_pagination(name string, total_pages int, current_page int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('pagination')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'pagination'
			value: current_page.str()
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_pagination_control(win.window_info, real_name.str, total_pages, current_page)
	}
	return win
}

// pagination inserts an auto-named pagination bar widget.
pub fn (win &SimpleWindow) pagination(total_pages int, current_page int) &SimpleWindow {
	return win.add_pagination('', total_pages, current_page)
}

// set_pagination_page updates active page and total pages in pagination widget.
pub fn (win &SimpleWindow) set_pagination_page(name string, page int, total_pages int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = page.str()
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_pagination_page(win.window_info, name.str, page, total_pages)
	}
	return win
}

// get_pagination_page gets current active page index.
pub fn (win &SimpleWindow) get_pagination_page(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_pagination_page(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value.int()
	}
	return 1
}

// add_activity_feed adds a scrollable activity/event log feed widget.
pub fn (win &SimpleWindow) add_activity_feed(name string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('activity_feed')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'activity_feed'
			value: ''
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_activity_feed_control(win.window_info, real_name.str, height)
	}
	return win
}

// activity_feed inserts an auto-named activity feed widget.
pub fn (win &SimpleWindow) activity_feed(height int) &SimpleWindow {
	return win.add_activity_feed('', height)
}

// add_activity_feed_item appends a log entry item to an activity feed.
pub fn (win &SimpleWindow) add_activity_feed_item(name string, timestamp string, message string, level string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_add_activity_feed_item(win.window_info, name.str, timestamp.str, message.str,
			level.str)
	}
	return win
}

// clear_activity_feed clears all entries from an activity feed widget.
pub fn (win &SimpleWindow) clear_activity_feed(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_clear_activity_feed(win.window_info, name.str)
	}
	return win
}

// add_markdown_view adds a formatted Markdown text viewer widget.
pub fn (win &SimpleWindow) add_markdown_view(name string, markdown_text string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('markdown_view')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'markdown_view'
			value: markdown_text
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_markdown_view_control(win.window_info, real_name.str, markdown_text.str,
			height)
	}
	return win
}

// markdown_view inserts an auto-named markdown view widget.
pub fn (win &SimpleWindow) markdown_view(markdown_text string, height int) &SimpleWindow {
	return win.add_markdown_view('', markdown_text, height)
}

// set_markdown_view_text updates content of a markdown viewer widget.
pub fn (win &SimpleWindow) set_markdown_view_text(name string, markdown_text string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = markdown_text
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_markdown_view_text(win.window_info, name.str, markdown_text.str)
	}
	return win
}

// get_markdown_view_text retrieves raw text from markdown view.
pub fn (win &SimpleWindow) get_markdown_view_text(name string) string {
	if win.window_info != unsafe { nil } {
		unsafe {
			res := C.window_get_markdown_view_text(win.window_info, name.str)
			if res != nil {
				return tos3(res)
			}
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// add_sparkline adds a mini inline sparkline trend chart widget.
pub fn (win &SimpleWindow) add_sparkline(name string, values []f64, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('sparkline')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'sparkline'
			value: ''
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_sparkline_control(win.window_info, real_name.str, values.data, values.len,
			height)
	}
	return win
}

// sparkline inserts an auto-named sparkline chart.
pub fn (win &SimpleWindow) sparkline(values []f64, height int) &SimpleWindow {
	return win.add_sparkline('', values, height)
}

// set_sparkline_data updates data points for sparkline chart.
pub fn (win &SimpleWindow) set_sparkline_data(name string, values []f64) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_sparkline_data(win.window_info, name.str, values.data, values.len)
	}
	return win
}

// add_pin_code adds a digit verification PIN/OTP code input widget.
pub fn (win &SimpleWindow) add_pin_code(name string, digits int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('pin_code')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'pin_code'
			value: ''
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_pin_code_control(win.window_info, real_name.str, digits)
	}
	return win
}

// pin_code inserts an auto-named PIN code input widget.
pub fn (win &SimpleWindow) pin_code(digits int) &SimpleWindow {
	return win.add_pin_code('', digits)
}

// set_pin_code_value updates PIN code value.
pub fn (win &SimpleWindow) set_pin_code_value(name string, code string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = code
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_pin_code_value(win.window_info, name.str, code.str)
	}
	return win
}

// get_pin_code_value retrieves entered PIN code.
pub fn (win &SimpleWindow) get_pin_code_value(name string) string {
	if win.window_info != unsafe { nil } {
		unsafe {
			res := C.window_get_pin_code_value(win.window_info, name.str)
			if res != nil {
				return tos3(res)
			}
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// add_color_palette adds a swatch color palette picker widget.
pub fn (win &SimpleWindow) add_color_palette(name string, hex_colors []string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('color_palette')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'color_palette'
			value: selected
		}
	}
	if win.window_info != unsafe { nil } {
		c_colors := hex_colors.map(it.str)
		C.window_add_color_palette_control(win.window_info, real_name.str, c_colors.data,
			c_colors.len, selected.str)
	}
	return win
}

// color_palette inserts an auto-named color palette widget.
pub fn (win &SimpleWindow) color_palette(hex_colors []string, selected string) &SimpleWindow {
	return win.add_color_palette('', hex_colors, selected)
}

// set_color_palette_selected updates selected color hex in palette.
pub fn (win &SimpleWindow) set_color_palette_selected(name string, hex_color string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = hex_color
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_color_palette_selected(win.window_info, name.str, hex_color.str)
	}
	return win
}

// get_color_palette_selected gets currently selected hex color string.
pub fn (win &SimpleWindow) get_color_palette_selected(name string) string {
	if win.window_info != unsafe { nil } {
		unsafe {
			res := C.window_get_color_palette_selected(win.window_info, name.str)
			if res != nil {
				return tos3(res)
			}
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// add_timeline adds a vertical milestone timeline event list widget.
pub fn (win &SimpleWindow) add_timeline(name string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('timeline')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'timeline'
			value: ''
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_timeline_control(win.window_info, real_name.str, height)
	}
	return win
}

// timeline inserts an auto-named timeline widget.
pub fn (win &SimpleWindow) timeline(height int) &SimpleWindow {
	return win.add_timeline('', height)
}

// add_timeline_item appends a milestone item to a timeline widget.
pub fn (win &SimpleWindow) add_timeline_item(name string, title string, subtitle string, time_str string, status string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_add_timeline_item(win.window_info, name.str, title.str, subtitle.str,
			time_str.str, status.str)
	}
	return win
}

// add_metric_card adds a KPI metric stats card widget.

pub fn (win &SimpleWindow) add_metric_card(name string, title string, value string, change_badge string, subtitle string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('metric_card')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'metric_card'
			value: value
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_metric_card_control(win.window_info, real_name.str, title.str, value.str,
			change_badge.str, subtitle.str)
	}
	return win
}

// metric_card inserts an auto-named metric card widget.
pub fn (win &SimpleWindow) metric_card(title string, value string, change_badge string, subtitle string) &SimpleWindow {
	return win.add_metric_card('', title, value, change_badge, subtitle)
}

// set_metric_card_value updates metric card numeric value and change badge.
pub fn (win &SimpleWindow) set_metric_card_value(name string, value string, change_badge string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = value
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_metric_card_value(win.window_info, name.str, value.str, change_badge.str)
	}
	return win
}

// add_tab_pills adds a pill-styled segmented tab bar widget.
pub fn (win &SimpleWindow) add_tab_pills(name string, items []string, selected string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('tab_pills')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'tab_pills'
			value: selected
		}
	}
	if win.window_info != unsafe { nil } {
		c_items := items.map(it.str)
		C.window_add_tab_pills_control(win.window_info, real_name.str, c_items.data, c_items.len,
			selected.str)
	}
	return win
}

// tab_pills inserts an auto-named tab pills widget.
pub fn (win &SimpleWindow) tab_pills(items []string, selected string) &SimpleWindow {
	return win.add_tab_pills('', items, selected)
}

// set_tab_pills_active updates active tab in tab pills widget.
pub fn (win &SimpleWindow) set_tab_pills_active(name string, selected string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = selected
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_tab_pills_active(win.window_info, name.str, selected.str)
	}
	return win
}

// get_tab_pills_active retrieves currently active tab title.
pub fn (win &SimpleWindow) get_tab_pills_active(name string) string {
	if win.window_info != unsafe { nil } {
		unsafe {
			res := C.window_get_tab_pills_active(win.window_info, name.str)
			if res != nil {
				return tos3(res)
			}
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// add_transfer_list adds a dual-column transfer list widget (single-select mode by default).
pub fn (win &SimpleWindow) add_transfer_list(name string, available []string, selected []string) &SimpleWindow {
	return win.add_transfer_list_opts(name, available, selected, false)
}

// add_transfer_list_opts adds a dual-column transfer list widget with custom multi_select option.
pub fn (win &SimpleWindow) add_transfer_list_opts(name string, available []string, selected []string, multi_select bool) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('transfer_list')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'transfer_list'
			value: ''
		}
	}
	if win.window_info != unsafe { nil } {
		c_avail := available.map(it.str)
		c_sel := selected.map(it.str)
		C.window_add_transfer_list_control(win.window_info, real_name.str, c_avail.data,
			c_avail.len, c_sel.data, c_sel.len, multi_select)
	}
	return win
}

// transfer_list inserts an auto-named transfer list widget.
pub fn (win &SimpleWindow) transfer_list(available []string, selected []string) &SimpleWindow {
	return win.add_transfer_list_opts('', available, selected, false)
}

// transfer_list_opts inserts an auto-named transfer list widget with multi_select option.
pub fn (win &SimpleWindow) transfer_list_opts(available []string, selected []string, multi_select bool) &SimpleWindow {
	return win.add_transfer_list_opts('', available, selected, multi_select)
}

// add_audio_waveform adds an audio sound level amplitude waveform visualizer widget.
pub fn (win &SimpleWindow) add_audio_waveform(name string, amplitudes []f64, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('audio_waveform')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'audio_waveform'
			value: ''
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_audio_waveform_control(win.window_info, real_name.str, amplitudes.data,
			amplitudes.len, height)
	}
	return win
}

// audio_waveform inserts an auto-named audio waveform widget.
pub fn (win &SimpleWindow) audio_waveform(amplitudes []f64, height int) &SimpleWindow {
	return win.add_audio_waveform('', amplitudes, height)
}

// set_audio_waveform_data updates amplitude data points in audio waveform visualizer.
pub fn (win &SimpleWindow) set_audio_waveform_data(name string, amplitudes []f64) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_add_audio_waveform_control(win.window_info, name.str, amplitudes.data,
			amplitudes.len, 60)
	}
	return win
}

// add_rating_breakdown adds a rating summary and percentage breakdown bar view.
pub fn (win &SimpleWindow) add_rating_breakdown(name string, avg_score f64, total_reviews int, star_percentages []f64) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('rating_breakdown')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'rating_breakdown'
			value: avg_score.str()
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_rating_breakdown_control(win.window_info, real_name.str, avg_score,
			total_reviews, star_percentages.data, star_percentages.len)
	}
	return win
}

// rating_breakdown inserts an auto-named rating breakdown widget.
pub fn (win &SimpleWindow) rating_breakdown(avg_score f64, total_reviews int, star_percentages []f64) &SimpleWindow {
	return win.add_rating_breakdown('', avg_score, total_reviews, star_percentages)
}

// set_rating_breakdown_data updates rating score and percentage data.
pub fn (win &SimpleWindow) set_rating_breakdown_data(name string, avg_score f64, total_reviews int, star_percentages []f64) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_rating_breakdown_data(win.window_info, name.str, avg_score, total_reviews,
			star_percentages.data, star_percentages.len)
	}
	return win
}

// add_code_view adds a dark monospaced code snippet viewer with language header.
pub fn (win &SimpleWindow) add_code_view(name string, lang string, code_text string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('code_view')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'code_view'
			value: code_text
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_code_view_control(win.window_info, real_name.str, lang.str, code_text.str,
			height)
	}
	return win
}

// code_view inserts an auto-named code view widget.
pub fn (win &SimpleWindow) code_view(lang string, code_text string, height int) &SimpleWindow {
	return win.add_code_view('', lang, code_text, height)
}

// set_code_view_text updates code content in code viewer widget.
pub fn (win &SimpleWindow) set_code_view_text(name string, code_text string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = code_text
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_code_view_text(win.window_info, name.str, code_text.str)
	}
	return win
}

// get_code_view_text retrieves current raw code text from code viewer.
pub fn (win &SimpleWindow) get_code_view_text(name string) string {
	if win.window_info != unsafe { nil } {
		unsafe {
			res := C.window_get_code_view_text(win.window_info, name.str)
			if res != nil {
				return tos3(res)
			}
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// add_alert_banner adds a dismissible notification banner with icon, title, message, and close button.
pub fn (win &SimpleWindow) add_alert_banner(name string, title string, message string, style string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('alert_banner')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'alert_banner'
			value: title
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_alert_banner_control(win.window_info, real_name.str, title.str, message.str,
			style.str)
	}
	return win
}

// alert_banner adds an auto-named notification banner.
pub fn (win &SimpleWindow) alert_banner(title string, message string, style string) &SimpleWindow {
	return win.add_alert_banner('', title, message, style)
}

// set_alert_banner_value updates alert banner content and makes it visible.
pub fn (win &SimpleWindow) set_alert_banner_value(name string, title string, message string, style string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_alert_banner_value(win.window_info, name.str, title.str, message.str,
			style.str)
	}
	return win
}

// add_step_tracker adds a horizontal process step progress bar with interactive step nodes.
pub fn (win &SimpleWindow) add_step_tracker(name string, steps []string, current_step int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('step_tracker')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'step_tracker'
			value: '${current_step}'
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_steps := []&u8{cap: steps.len}
		for s in steps {
			c_steps << s.str
		}
		C.window_add_step_tracker_control(win.window_info, real_name.str, c_steps.data,
			steps.len, current_step)
	}
	return win
}

// step_tracker adds an auto-named process step tracker widget.
pub fn (win &SimpleWindow) step_tracker(steps []string, current_step int) &SimpleWindow {
	return win.add_step_tracker('', steps, current_step)
}

// set_step_tracker_step updates the currently active step node.
pub fn (win &SimpleWindow) set_step_tracker_step(name string, step int) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = '${step}'
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_step_tracker_step(win.window_info, name.str, step)
	}
	return win
}

// get_step_tracker_step returns the current step index.
pub fn (win &SimpleWindow) get_step_tracker_step(name string) int {
	if win.window_info != unsafe { nil } {
		return C.window_get_step_tracker_step(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value.int()
	}
	return 0
}

// add_filter_chips adds an interactive filter chip tag group with single/multi selection.
pub fn (win &SimpleWindow) add_filter_chips(name string, chips []string, selected []string, multi_select bool) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('filter_chips')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'filter_chips'
			value: selected.join(',')
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_chips := []&u8{cap: chips.len}
		for c in chips {
			c_chips << c.str
		}
		mut c_sel := []&u8{cap: selected.len}
		for s in selected {
			c_sel << s.str
		}
		C.window_add_filter_chips_control(win.window_info, real_name.str, c_chips.data,
			chips.len, c_sel.data, selected.len, multi_select)
	}
	return win
}

// filter_chips adds an auto-named filter chip group.
pub fn (win &SimpleWindow) filter_chips(chips []string, selected []string, multi_select bool) &SimpleWindow {
	return win.add_filter_chips('', chips, selected, multi_select)
}

// set_filter_chips_selected updates active selected chips.
pub fn (win &SimpleWindow) set_filter_chips_selected(name string, selected []string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = selected.join(',')
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_sel := []&u8{cap: selected.len}
		for s in selected {
			c_sel << s.str
		}
		C.window_set_filter_chips_selected(win.window_info, name.str, c_sel.data, selected.len)
	}
	return win
}

// get_filter_chips_selected returns active selected filter chips as comma-separated string.
pub fn (win &SimpleWindow) get_filter_chips_selected(name string) string {
	if win.window_info != unsafe { nil } {
		unsafe {
			res := C.window_get_filter_chips_selected(win.window_info, name.str)
			if res != nil {
				return tos3(res)
			}
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// add_file_picker_field adds a path input with native Cocoa NSOpenPanel file chooser button.
pub fn (win &SimpleWindow) add_file_picker_field(name string, initial_path string, button_title string, folder_only bool) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('file_picker')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'file_picker'
			value: initial_path
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_file_picker_field_control(win.window_info, real_name.str, initial_path.str,
			button_title.str, folder_only)
	}
	return win
}

// file_picker_field adds an auto-named file picker input widget.
pub fn (win &SimpleWindow) file_picker_field(initial_path string, button_title string, folder_only bool) &SimpleWindow {
	return win.add_file_picker_field('', initial_path, button_title, folder_only)
}

// set_file_picker_path updates the displayed file/folder path.
pub fn (win &SimpleWindow) set_file_picker_path(name string, path string) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = path
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_file_picker_path(win.window_info, name.str, path.str)
	}
	return win
}

// get_file_picker_path returns current path string from file picker widget.
pub fn (win &SimpleWindow) get_file_picker_path(name string) string {
	if win.window_info != unsafe { nil } {
		unsafe {
			res := C.window_get_file_picker_path(win.window_info, name.str)
			if res != nil {
				return tos3(res)
			}
		}
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value
	}
	return ''
}

// add_radial_gauge adds a semi-circular dial meter with gradient arc and digital value readout.
pub fn (win &SimpleWindow) add_radial_gauge(name string, title string, value f64, min_val f64, max_val f64, unit string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('radial_gauge')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'radial_gauge'
			value: '${value}'
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_radial_gauge_control(win.window_info, real_name.str, title.str, value,
			min_val, max_val, unit.str)
	}
	return win
}

// radial_gauge adds an auto-named radial gauge dial.
pub fn (win &SimpleWindow) radial_gauge(title string, value f64, min_val f64, max_val f64, unit string) &SimpleWindow {
	return win.add_radial_gauge('', title, value, min_val, max_val, unit)
}

// set_radial_gauge_value updates value displayed on radial gauge dial.
pub fn (win &SimpleWindow) set_radial_gauge_value(name string, value f64) &SimpleWindow {
	idx := win.find_control(name)
	if idx >= 0 {
		unsafe {
			mut w := &SimpleWindow(win)
			w.controls[idx].value = '${value}'
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_set_radial_gauge_value(win.window_info, name.str, value)
	}
	return win
}

// get_radial_gauge_value retrieves current numerical value from radial gauge.
pub fn (win &SimpleWindow) get_radial_gauge_value(name string) f64 {
	if win.window_info != unsafe { nil } {
		return C.window_get_radial_gauge_value(win.window_info, name.str)
	}
	idx := win.find_control(name)
	if idx >= 0 {
		return win.controls[idx].value.f64()
	}
	return 0.0
}

// add_key_value_card adds a structured summary card for displaying key-value data rows.
pub fn (win &SimpleWindow) add_key_value_card(name string, title string, keys []string, values []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('key_value_card')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'key_value_card'
			value: title
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_keys := []&u8{cap: keys.len}
		for k in keys {
			c_keys << k.str
		}
		mut c_vals := []&u8{cap: values.len}
		for v in values {
			c_vals << v.str
		}
		count := if keys.len < values.len { keys.len } else { values.len }
		C.window_add_key_value_card_control(win.window_info, real_name.str, title.str,
			c_keys.data, c_vals.data, count)
	}
	return win
}

// key_value_card adds an auto-named key-value summary card.
pub fn (win &SimpleWindow) key_value_card(title string, keys []string, values []string) &SimpleWindow {
	return win.add_key_value_card('', title, keys, values)
}

// set_key_value_card_data updates key and value row labels in card.
pub fn (win &SimpleWindow) set_key_value_card_data(name string, keys []string, values []string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		mut c_keys := []&u8{cap: keys.len}
		for k in keys {
			c_keys << k.str
		}
		mut c_vals := []&u8{cap: values.len}
		for v in values {
			c_vals << v.str
		}
		count := if keys.len < values.len { keys.len } else { values.len }
		C.window_set_key_value_card_data(win.window_info, name.str, c_keys.data, c_vals.data,
			count)
	}
	return win
}

// add_diff_view adds a side-by-side / unified code diff comparison view widget.
pub fn (win &SimpleWindow) add_diff_view(name string, old_text string, new_text string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('diff_view')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'diff_view'
			value: old_text
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_diff_view_control(win.window_info, real_name.str, old_text.str, new_text.str,
			height)
	}
	return win
}

// diff_view adds an auto-named diff comparison view widget.
pub fn (win &SimpleWindow) diff_view(old_text string, new_text string, height int) &SimpleWindow {
	return win.add_diff_view('', old_text, new_text, height)
}

// set_diff_view updates the compared texts in diff view widget.
pub fn (win &SimpleWindow) set_diff_view(name string, old_text string, new_text string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_diff_view_text(win.window_info, name.str, old_text.str, new_text.str)
	}
	return win
}

// add_json_tree adds a JSON / structured data syntax-highlighted inspector control.
pub fn (win &SimpleWindow) add_json_tree(name string, json_str string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('json_tree')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'json_tree'
			value: json_str
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_json_tree_control(win.window_info, real_name.str, json_str.str, height)
	}
	return win
}

// json_tree adds an auto-named JSON inspector control.
pub fn (win &SimpleWindow) json_tree(json_str string, height int) &SimpleWindow {
	return win.add_json_tree('', json_str, height)
}

// set_json_tree updates the JSON payload string in JSON tree inspector widget.
pub fn (win &SimpleWindow) set_json_tree(name string, json_str string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_json_tree_data(win.window_info, name.str, json_str.str)
	}
	return win
}

// add_http_request_card adds an API / HTTP request status & metric inspector card.
pub fn (win &SimpleWindow) add_http_request_card(name string, method string, url string, status_code int, response_time_ms int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('http_request_card')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'http_request_card'
			value: '${method} ${url}'
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_http_request_card_control(win.window_info, real_name.str, method.str,
			url.str, status_code, response_time_ms)
	}
	return win
}

// http_request_card adds an auto-named HTTP request inspector card.
pub fn (win &SimpleWindow) http_request_card(method string, url string, status_code int, response_time_ms int) &SimpleWindow {
	return win.add_http_request_card('', method, url, status_code, response_time_ms)
}

// set_http_request_card updates metrics and status of HTTP request inspector card.
pub fn (win &SimpleWindow) set_http_request_card(name string, method string, url string, status_code int, response_time_ms int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_http_request_card_data(win.window_info, name.str, method.str, url.str,
			status_code, response_time_ms)
	}
	return win
}

// add_terminal_view adds a shell / terminal command output view widget.
pub fn (win &SimpleWindow) add_terminal_view(name string, prompt_text string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('terminal_view')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'terminal_view'
			value: prompt_text
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_terminal_view_control(win.window_info, real_name.str, prompt_text.str,
			height)
	}
	return win
}

// terminal_view adds an auto-named terminal view widget.
pub fn (win &SimpleWindow) terminal_view(prompt_text string, height int) &SimpleWindow {
	return win.add_terminal_view('', prompt_text, height)
}

// append_terminal_line appends a styled line (0=prompt, 1=stdout, 2=stderr, 3=success) to terminal view.
pub fn (win &SimpleWindow) append_terminal_line(name string, line_text string, line_type int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_append_terminal_line(win.window_info, name.str, line_text.str, line_type)
	}
	return win
}

// clear_terminal clears output in terminal view widget.
pub fn (win &SimpleWindow) clear_terminal(name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_clear_terminal(win.window_info, name.str)
	}
	return win
}

// add_resource_monitor adds a system resource & telemetry monitor dashboard control.
pub fn (win &SimpleWindow) add_resource_monitor(name string, cpu_pct int, mem_pct int, disk_pct int, net_kbps int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('resource_monitor')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name: real_name
			kind: 'resource_monitor'
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_resource_monitor_control(win.window_info, real_name.str, cpu_pct,
			mem_pct, disk_pct, net_kbps)
	}
	return win
}

// resource_monitor adds an auto-named resource monitor dashboard control.
pub fn (win &SimpleWindow) resource_monitor(cpu_pct int, mem_pct int, disk_pct int, net_kbps int) &SimpleWindow {
	return win.add_resource_monitor('', cpu_pct, mem_pct, disk_pct, net_kbps)
}

// set_resource_monitor updates live percentage metrics on resource monitor widget.
pub fn (win &SimpleWindow) set_resource_monitor(name string, cpu_pct int, mem_pct int, disk_pct int, net_kbps int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_resource_monitor_metrics(win.window_info, name.str, cpu_pct, mem_pct,
			disk_pct, net_kbps)
	}
	return win
}

// add_env_vars adds an environment & config variables viewer/editor card.
pub fn (win &SimpleWindow) add_env_vars(name string, title string, keys []string, values []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('env_vars')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'env_vars'
			value: title
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_keys := []&u8{cap: keys.len}
		for k in keys {
			c_keys << k.str
		}
		mut c_vals := []&u8{cap: values.len}
		for v in values {
			c_vals << v.str
		}
		count := if keys.len < values.len { keys.len } else { values.len }
		C.window_add_env_vars_control(win.window_info, real_name.str, title.str, c_keys.data,
			c_vals.data, count)
	}
	return win
}

// env_vars adds an auto-named environment variables card.
pub fn (win &SimpleWindow) env_vars(title string, keys []string, values []string) &SimpleWindow {
	return win.add_env_vars('', title, keys, values)
}

// set_env_vars updates keys and values in environment variables card.
pub fn (win &SimpleWindow) set_env_vars(name string, keys []string, values []string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		mut c_keys := []&u8{cap: keys.len}
		for k in keys {
			c_keys << k.str
		}
		mut c_vals := []&u8{cap: values.len}
		for v in values {
			c_vals << v.str
		}
		count := if keys.len < values.len { keys.len } else { values.len }
		C.window_set_env_vars_data(win.window_info, name.str, c_keys.data, c_vals.data,
			count)
	}
	return win
}

// add_badge_button adds an action button with an attached notification counter badge.
pub fn (win &SimpleWindow) add_badge_button(name string, title string, count int, badge_color string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('badge_button')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'badge_button'
			value: title
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_badge_button_control(win.window_info, real_name.str, title.str, count,
			badge_color.str)
	}
	return win
}

// badge_button adds an auto-named action button with a badge counter.
pub fn (win &SimpleWindow) badge_button(title string, count int, badge_color string) &SimpleWindow {
	return win.add_badge_button('', title, count, badge_color)
}

// set_badge_button_count updates the counter number on badge button widget.
pub fn (win &SimpleWindow) set_badge_button_count(name string, count int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_badge_button_count(win.window_info, name.str, count)
	}
	return win
}

// add_command_palette adds a search / command palette bar with search icon & shortcut hint.
pub fn (win &SimpleWindow) add_command_palette(name string, placeholder string, shortcut_hint string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('command_palette')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'command_palette'
			value: placeholder
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_command_palette_control(win.window_info, real_name.str, placeholder.str,
			shortcut_hint.str)
	}
	return win
}

// command_palette adds an auto-named command palette search bar.
pub fn (win &SimpleWindow) command_palette(placeholder string, shortcut_hint string) &SimpleWindow {
	return win.add_command_palette('', placeholder, shortcut_hint)
}

// set_command_palette_text updates query text in command palette bar.
pub fn (win &SimpleWindow) set_command_palette_text(name string, text string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_command_palette_text(win.window_info, name.str, text.str)
	}
	return win
}

// add_status_banner adds an alert message strip banner with icon and accent border.
pub fn (win &SimpleWindow) add_status_banner(name string, title string, message string, style_type string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('status_banner')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'status_banner'
			value: title
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_status_banner_control(win.window_info, real_name.str, title.str,
			message.str, style_type.str)
	}
	return win
}

// status_banner adds an auto-named status banner alert strip.
pub fn (win &SimpleWindow) status_banner(title string, message string, style_type string) &SimpleWindow {
	return win.add_status_banner('', title, message, style_type)
}

// set_status_banner updates title and message in status banner alert strip.
pub fn (win &SimpleWindow) set_status_banner(name string, title string, message string, style_type string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_status_banner_text(win.window_info, name.str, title.str, message.str,
			style_type.str)
	}
	return win
}

// add_pill_toggle adds a rounded pill segment option toggle bar.
pub fn (win &SimpleWindow) add_pill_toggle(name string, options []string, selected_index int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('pill_toggle')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name: real_name
			kind: 'pill_toggle'
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_opts := []&u8{cap: options.len}
		for o in options {
			c_opts << o.str
		}
		C.window_add_pill_toggle_control(win.window_info, real_name.str, c_opts.data,
			options.len, selected_index)
	}
	return win
}

// pill_toggle adds an auto-named pill segment option toggle bar.
pub fn (win &SimpleWindow) pill_toggle(options []string, selected_index int) &SimpleWindow {
	return win.add_pill_toggle('', options, selected_index)
}

// set_pill_toggle_selected updates active selected option index in pill toggle bar.
pub fn (win &SimpleWindow) set_pill_toggle_selected(name string, selected_index int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_pill_toggle_selected(win.window_info, name.str, selected_index)
	}
	return win
}

// add_color_swatch_panel adds a palette panel with circular color swatches.
pub fn (win &SimpleWindow) add_color_swatch_panel(name string, hex_colors []string, selected_color string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('color_swatch_panel')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'color_swatch_panel'
			value: selected_color
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_hex := []&u8{cap: hex_colors.len}
		for h in hex_colors {
			c_hex << h.str
		}
		C.window_add_color_swatch_panel_control(win.window_info, real_name.str, c_hex.data,
			hex_colors.len, selected_color.str)
	}
	return win
}

// color_swatch_panel adds an auto-named color swatch palette panel.
pub fn (win &SimpleWindow) color_swatch_panel(hex_colors []string, selected_color string) &SimpleWindow {
	return win.add_color_swatch_panel('', hex_colors, selected_color)
}

// set_color_swatch_selected updates selected color hex in swatch panel.
pub fn (win &SimpleWindow) set_color_swatch_selected(name string, hex_color string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_color_swatch_selected(win.window_info, name.str, hex_color.str)
	}
	return win
}

// add_hotkey_badge adds a macOS metallic keycap hotkey display badge with description.
pub fn (win &SimpleWindow) add_hotkey_badge(name string, shortcut_str string, description string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('hotkey_badge')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'hotkey_badge'
			value: shortcut_str
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_hotkey_badge_control(win.window_info, real_name.str, shortcut_str.str,
			description.str)
	}
	return win
}

// hotkey_badge adds an auto-named hotkey badge display.
pub fn (win &SimpleWindow) hotkey_badge(shortcut_str string, description string) &SimpleWindow {
	return win.add_hotkey_badge('', shortcut_str, description)
}

// set_hotkey_badge_shortcut updates keyboard shortcut string and description in hotkey badge.
pub fn (win &SimpleWindow) set_hotkey_badge_shortcut(name string, shortcut_str string, description string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_hotkey_badge_shortcut(win.window_info, name.str, shortcut_str.str,
			description.str)
	}
	return win
}

// add_quick_action_bar adds a quick action bar control with interactive action buttons.
pub fn (win &SimpleWindow) add_quick_action_bar(name string, labels []string, symbols []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('quick_action_bar')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name: real_name
			kind: 'quick_action_bar'
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_labels := []&u8{cap: labels.len}
		for l in labels {
			c_labels << l.str
		}
		mut c_symbols := []&u8{cap: symbols.len}
		for s in symbols {
			c_symbols << s.str
		}
		C.window_add_quick_action_bar_control(win.window_info, real_name.str, c_labels.data,
			c_symbols.data, labels.len)
	}
	return win
}

// quick_action_bar adds an auto-named quick action bar control.
pub fn (win &SimpleWindow) quick_action_bar(labels []string, symbols []string) &SimpleWindow {
	return win.add_quick_action_bar('', labels, symbols)
}

// set_quick_action_enabled sets enabled state for a specific action button inside a quick action bar.
pub fn (win &SimpleWindow) set_quick_action_enabled(name string, index int, enabled bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_quick_action_enabled(win.window_info, name.str, index, if enabled {
			1
		} else {
			0
		})
	}
	return win
}

// add_accordion_group adds a multi-section expandable accordion group widget.
pub fn (win &SimpleWindow) add_accordion_group(name string, section_titles []string, expanded_index int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('accordion_group')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name: real_name
			kind: 'accordion_group'
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_titles := []&u8{cap: section_titles.len}
		for t in section_titles {
			c_titles << t.str
		}
		C.window_add_accordion_group_control(win.window_info, real_name.str, c_titles.data,
			section_titles.len, expanded_index)
	}
	return win
}

// accordion_group adds an auto-named accordion group widget.
pub fn (win &SimpleWindow) accordion_group(section_titles []string, expanded_index int) &SimpleWindow {
	return win.add_accordion_group('', section_titles, expanded_index)
}

// set_accordion_expanded updates expanded/collapsed state for an accordion section by index.
pub fn (win &SimpleWindow) set_accordion_expanded(name string, index int, expanded bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_accordion_expanded(win.window_info, name.str, index, if expanded {
			1
		} else {
			0
		})
	}
	return win
}

// add_segment_distribution_bar adds a proportional segment distribution bar displaying breakdown ratios.
pub fn (win &SimpleWindow) add_segment_distribution_bar(name string, labels []string, values []f64, hex_colors []string, height int) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('segment_distribution_bar')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name: real_name
			kind: 'segment_distribution_bar'
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_labels := []&u8{cap: labels.len}
		for l in labels {
			c_labels << l.str
		}
		mut c_colors := []&u8{cap: hex_colors.len}
		for c in hex_colors {
			c_colors << c.str
		}
		C.window_add_segment_distribution_bar_control(win.window_info, real_name.str,
			c_labels.data, values.data, c_colors.data, values.len, height)
	}
	return win
}

// segment_distribution_bar adds an auto-named segment distribution bar widget.
pub fn (win &SimpleWindow) segment_distribution_bar(labels []string, values []f64, hex_colors []string, height int) &SimpleWindow {
	return win.add_segment_distribution_bar('', labels, values, hex_colors, height)
}

// set_segment_distribution_values updates values of a segment distribution bar.
pub fn (win &SimpleWindow) set_segment_distribution_values(name string, values []f64) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_segment_distribution_values(win.window_info, name.str, values.data,
			values.len)
	}
	return win
}

// add_tag_input_field adds an interactive tag pill field with add/remove capability.
pub fn (win &SimpleWindow) add_tag_input_field(name string, tags []string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('tag_input_field')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name: real_name
			kind: 'tag_input_field'
		}
	}
	if win.window_info != unsafe { nil } {
		mut c_tags := []&u8{cap: tags.len}
		for t in tags {
			c_tags << t.str
		}
		C.window_add_tag_input_field_control(win.window_info, real_name.str, c_tags.data,
			tags.len)
	}
	return win
}

// tag_input_field adds an auto-named tag input field widget.
pub fn (win &SimpleWindow) tag_input_field(tags []string) &SimpleWindow {
	return win.add_tag_input_field('', tags)
}

// set_tag_input_tags updates tags list in a tag input field.
pub fn (win &SimpleWindow) set_tag_input_tags(name string, tags []string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		mut c_tags := []&u8{cap: tags.len}
		for t in tags {
			c_tags << t.str
		}
		C.window_set_tag_input_tags(win.window_info, name.str, c_tags.data, tags.len)
	}
	return win
}

// get_tag_input_tags returns comma-separated tags from a tag input field.
pub fn (win &SimpleWindow) get_tag_input_tags(name string) string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_tag_input_tags(win.window_info, name.str)
		if res != unsafe { nil } {
			return unsafe { tos3(res) }
		}
	}
	return ''
}

// add_status_dock adds a window footer status dock control with status dot, status text, and count badge.
pub fn (win &SimpleWindow) add_status_dock(name string, status_text string, dot_color string, count_text string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('status_dock')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'status_dock'
			value: status_text
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_status_dock_control(win.window_info, real_name.str, status_text.str,
			dot_color.str, count_text.str)
	}
	return win
}

// status_dock adds an auto-named status dock footer widget.
pub fn (win &SimpleWindow) status_dock(status_text string, dot_color string, count_text string) &SimpleWindow {
	return win.add_status_dock('', status_text, dot_color, count_text)
}

// set_status_dock_info updates status text, indicator dot color, and count text in status dock.
pub fn (win &SimpleWindow) set_status_dock_info(name string, status_text string, dot_color string, count_text string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_status_dock_info(win.window_info, name.str, status_text.str, dot_color.str,
			count_text.str)
	}
	return win
}

// add_info_callout adds a styled info/alert callout card with accent border and optional action button.
pub fn (win &SimpleWindow) add_info_callout(name string, title string, message string, style_type string, button_text string) &SimpleWindow {
	mut real_name := name
	if real_name == '' {
		real_name = win.auto_name('info_callout')
	}
	unsafe {
		mut w := &SimpleWindow(win)
		w.controls << ControlEntry{
			name:  real_name
			kind:  'info_callout'
			value: title
		}
	}
	if win.window_info != unsafe { nil } {
		C.window_add_info_callout_control(win.window_info, real_name.str, title.str, message.str,
			style_type.str, button_text.str)
	}
	return win
}

// info_callout adds an auto-named info callout card widget.
pub fn (win &SimpleWindow) info_callout(title string, message string, style_type string, button_text string) &SimpleWindow {
	return win.add_info_callout('', title, message, style_type, button_text)
}

// set_info_callout_text updates title and message text in an info callout card.
pub fn (win &SimpleWindow) set_info_callout_text(name string, title string, message string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_info_callout_text(win.window_info, name.str, title.str, message.str)
	}
	return win
}

// set_alpha sets the window transparency level (0.0 transparent to 1.0 opaque).
pub fn (win &SimpleWindow) set_alpha(alpha f64) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_alpha(win.window_info, alpha)
	}
	return win
}

// get_alpha retrieves the current window transparency level.
pub fn (win &SimpleWindow) get_alpha() f64 {
	if win.window_info != unsafe { nil } {
		return C.window_get_alpha(win.window_info)
	}
	return 1.0
}

// set_collection_behavior configures macOS virtual desktop / Spaces behavior ("can_join_all_spaces", "move_to_active_space", "transient", "full_screen_primary", "full_screen_auxiliary").
pub fn (win &SimpleWindow) set_collection_behavior(behavior string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_collection_behavior(win.window_info, behavior.str)
	}
	return win
}

// set_close_button_enabled enables or disables the titlebar close button.
pub fn (win &SimpleWindow) set_close_button_enabled(enabled bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_close_button_enabled(win.window_info, if enabled { 1 } else { 0 })
	}
	return win
}

// set_minimize_button_enabled enables or disables the titlebar minimize button.
pub fn (win &SimpleWindow) set_minimize_button_enabled(enabled bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_minimize_button_enabled(win.window_info, if enabled { 1 } else { 0 })
	}
	return win
}

// set_zoom_button_enabled enables or disables the titlebar zoom / maximize button.
pub fn (win &SimpleWindow) set_zoom_button_enabled(enabled bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_zoom_button_enabled(win.window_info, if enabled { 1 } else { 0 })
	}
	return win
}

// set_content_insets sets safe area margins/padding (top, left, bottom, right) on the window content view.
pub fn (win &SimpleWindow) set_content_insets(top int, left int, bottom int, right int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_content_insets(win.window_info, top, left, bottom, right)
	}
	return win
}

// set_tabbing_mode configures macOS native window tabbing mode ("automatic", "preferred", "disallowed").
pub fn (win &SimpleWindow) set_tabbing_mode(mode string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_tabbing_mode(win.window_info, mode.str)
	}
	return win
}

// get_tabbing_mode retrieves current macOS native tabbing mode.
pub fn (win &SimpleWindow) get_tabbing_mode() string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_tabbing_mode(win.window_info)
		if res != unsafe { nil } {
			return unsafe { tos3(res) }
		}
	}
	return 'automatic'
}

// set_tabbing_identifier groups windows together under the same macOS tab bar identifier.
pub fn (win &SimpleWindow) set_tabbing_identifier(identifier string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_tabbing_identifier(win.window_info, identifier.str)
	}
	return win
}

// get_tabbing_identifier retrieves the macOS tabbing group identifier.
pub fn (win &SimpleWindow) get_tabbing_identifier() string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_tabbing_identifier(win.window_info)
		if res != unsafe { nil } {
			return unsafe { tos3(res) }
		}
	}
	return ''
}

// toggle_tab_bar toggles the native macOS window tab bar.
pub fn (win &SimpleWindow) toggle_tab_bar() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_toggle_tab_bar(win.window_info)
	}
	return win
}

// select_next_tab switches focus to the next window tab.
pub fn (win &SimpleWindow) select_next_tab() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_select_next_tab(win.window_info)
	}
	return win
}

// select_previous_tab switches focus to the previous window tab.
pub fn (win &SimpleWindow) select_previous_tab() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_select_previous_tab(win.window_info)
	}
	return win
}

// set_sharing_type configures window screen capture sharing access ("none", "read_only", "read_write").
pub fn (win &SimpleWindow) set_sharing_type(sharing string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_sharing_type(win.window_info, sharing.str)
	}
	return win
}

// ── Appearance Override ──────────────────────────────────────────────────────

// set_window_appearance overrides the window appearance to "dark", "light", or "auto" (system default).
// This lets you force dark/light mode on a per-window basis regardless of system preference.
pub fn (win &SimpleWindow) set_window_appearance(appearance string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_window_appearance(win.window_info, appearance.str)
	}
	return win
}

// get_window_appearance returns the current window appearance override: "dark", "light", or "auto".
pub fn (win &SimpleWindow) get_window_appearance() string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_window_appearance(win.window_info)
		if res != unsafe { nil } {
			return unsafe { tos3(res) }
		}
	}
	return 'auto'
}

// is_system_dark_mode returns true if the macOS system is currently in dark mode.
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

// get_screen_full_frame returns the full physical frame of the screen containing this window.
// Returns (x, y, width, height).
pub fn (win &SimpleWindow) get_screen_full_frame() (int, int, int, int) {
	if win.window_info != unsafe { nil } {
		mut x, mut y, mut w, mut h := 0, 0, 0, 0
		C.window_get_screen_full_frame(win.window_info, &x, &y, &w, &h)
		return x, y, w, h
	}
	return 0, 0, 0, 0
}

// get_screen_scale_factor returns the Retina display scale factor (1.0 for standard, 2.0+ for Retina).
pub fn (win &SimpleWindow) get_screen_scale_factor() f64 {
	if win.window_info != unsafe { nil } {
		return C.window_get_screen_scale_factor(win.window_info)
	}
	return 1.0
}

// ── Cursor Control ────────────────────────────────────────────────────────────

// set_cursor_hidden hides or shows the macOS system cursor.
// Note: This is application-wide — be sure to restore visibility when done.
pub fn (win &SimpleWindow) set_cursor_hidden(hidden bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_cursor_hidden(win.window_info, if hidden { 1 } else { 0 })
	}
	return win
}

// set_cursor changes the cursor icon shown over the window content.
// Supported names: 'arrow', 'ibeam'/'text', 'crosshair', 'pointing_hand'/'hand',
// 'open_hand', 'closed_hand', 'resize_left', 'resize_right', 'resize_left_right',
// 'resize_up', 'resize_down', 'resize_up_down', 'drag_copy', 'drag_link',
// 'operation_not_allowed'/'not_allowed', 'context_menu', 'disappearing_item'/'poof',
// 'ibeam_vertical'. The cursor persists while the mouse is over the window.
pub fn (win &SimpleWindow) set_cursor(cursor_name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_cursor(win.window_info, cursor_name.str)
	}
	return win
}

// get_cursor returns the name of the currently active cursor set via set_cursor,
// or 'arrow' if no custom cursor is active.
pub fn (win &SimpleWindow) get_cursor() string {
	if win.window_info != unsafe { nil } {
		res := C.window_get_cursor(win.window_info)
		if res != unsafe { nil } {
			return unsafe { tos3(res) }
		}
	}
	return 'arrow'
}

// set_cursor_size scales the cursor icon (1.0 = system size, 2.0 = double, etc.).
// The scale is clamped to 0.25–8.0 and applies to cursors set via set_cursor,
// push_cursor, and set_control_cursor.
pub fn (win &SimpleWindow) set_cursor_size(scale f64) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_cursor_scale(win.window_info, scale)
	}
	return win
}

// get_cursor_size returns the current cursor scale factor (1.0 = system size).
pub fn (win &SimpleWindow) get_cursor_size() f64 {
	if win.window_info != unsafe { nil } {
		return C.window_get_cursor_scale(win.window_info)
	}
	return 1.0
}

// reset_cursor restores the default arrow cursor at system size and clears
// any cursor icon and scale set via set_cursor / set_cursor_size.
pub fn (win &SimpleWindow) reset_cursor() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_reset_cursor(win.window_info)
	}
	return win
}

// push_cursor temporarily pushes a cursor onto the system cursor stack.
// Use pop_cursor to restore the previous cursor.
pub fn (win &SimpleWindow) push_cursor(cursor_name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_push_cursor(win.window_info, cursor_name.str)
	}
	return win
}

// pop_cursor restores the cursor that was active before the last push_cursor.
pub fn (win &SimpleWindow) pop_cursor() &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_pop_cursor(win.window_info)
	}
	return win
}

// set_control_cursor assigns a cursor icon shown while hovering a specific control.
// Pass '' or 'default' as cursor_name to remove the assignment.
pub fn (win &SimpleWindow) set_control_cursor(name string, cursor_name string) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_control_cursor_by_name(win.window_info, name.str, cursor_name.str)
	}
	return win
}

// get_mouse_location returns the current mouse position in global screen
// coordinates (bottom-left origin, matching window position APIs).
pub fn (win &SimpleWindow) get_mouse_location() (int, int) {
	if win.window_info != unsafe { nil } {
		mut x, mut y := 0, 0
		C.window_get_mouse_location(win.window_info, &x, &y)
		return x, y
	}
	return 0, 0
}

// move_cursor_to warps the mouse cursor to the given global screen coordinates
// (bottom-left origin, same coordinate space as get_mouse_location).
pub fn (win &SimpleWindow) move_cursor_to(x int, y int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_move_cursor_to(win.window_info, x, y)
	}
	return win
}

// ── Resize Indicator ──────────────────────────────────────────────────────────

// set_shows_resize_indicator shows or hides the bottom-right resize grip on the window.
pub fn (win &SimpleWindow) set_shows_resize_indicator(show bool) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_shows_resize_indicator(win.window_info, if show { 1 } else { 0 })
	}
	return win
}

// get_shows_resize_indicator returns true if the resize indicator (grip) is visible.
pub fn (win &SimpleWindow) get_shows_resize_indicator() bool {
	if win.window_info != unsafe { nil } {
		return C.window_get_shows_resize_indicator(win.window_info) == 1
	}
	return true
}

// ── Content Size Constraints ──────────────────────────────────────────────────

// set_content_min_size sets the minimum content area size (excluding titlebar height).
// This is more precise than set_min_size which includes the full window frame.
pub fn (win &SimpleWindow) set_content_min_size(width int, height int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_content_min_size(win.window_info, width, height)
	}
	return win
}

// set_content_max_size sets the maximum content area size. Use 0 for unconstrained.
pub fn (win &SimpleWindow) set_content_max_size(width int, height int) &SimpleWindow {
	if win.window_info != unsafe { nil } {
		C.window_set_content_max_size(win.window_info, width, height)
	}
	return win
}

// get_content_min_size returns the current content area minimum size as (width, height).
pub fn (win &SimpleWindow) get_content_min_size() (int, int) {
	if win.window_info != unsafe { nil } {
		mut w, mut h := 0, 0
		C.window_get_content_min_size(win.window_info, &w, &h)
		return w, h
	}
	return 0, 0
}

// get_content_max_size returns the current content area maximum size as (width, height).
// Returns (0, 0) if unconstrained.
pub fn (win &SimpleWindow) get_content_max_size() (int, int) {
	if win.window_info != unsafe { nil } {
		mut w, mut h := 0, 0
		C.window_get_content_max_size(win.window_info, &w, &h)
		return w, h
	}
	return 0, 0
}

// ── Tab Count ─────────────────────────────────────────────────────────────────

// get_tab_count returns the number of tabs in the current window tab group.
// Returns 1 if the window has no tab group or tabbing is not available.
pub fn (win &SimpleWindow) get_tab_count() int {
	if win.window_info != unsafe { nil } {
		return C.window_get_tab_count(win.window_info)
	}
	return 1
}

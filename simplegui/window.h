#ifndef WINDOW_H
#define WINDOW_H

typedef struct string string;
typedef struct main__WindowParams main__WindowParams;
typedef struct main__WindowInfo main__WindowInfo;

main__WindowInfo *window_app_init(void *params);
void window_app_run(main__WindowInfo *info);
void window_app_exit(main__WindowInfo *info);
void window_set_input_text(main__WindowInfo *info, const char *text);
void window_set_text_area(main__WindowInfo *info, const char *text);
void window_set_status_text(main__WindowInfo *info, const char *text);
void window_set_title_text(main__WindowInfo *info, const char *text);
void window_set_always_on_top(main__WindowInfo *info, int enabled);
int window_get_always_on_top(main__WindowInfo *info);
void window_set_checkbox_state(main__WindowInfo *info, int checked);
void window_set_number_value(main__WindowInfo *info, int value);
void window_set_background_color(main__WindowInfo *info, const char *color);
void window_set_font_color(main__WindowInfo *info, const char *color);
void window_set_control_background_color_by_name(main__WindowInfo *info, const char *name, const char *color);
void window_set_control_font_color_by_name(main__WindowInfo *info, const char *name, const char *color);
void window_set_control_width_by_name(main__WindowInfo *info, const char *name, int width);
void window_set_control_height_by_name(main__WindowInfo *info, const char *name, int height);
void window_set_control_font_size_by_name(main__WindowInfo *info, const char *name, int size);
void window_set_control_font_bold_by_name(main__WindowInfo *info, const char *name, int bold);
void window_set_control_font_name_by_name(main__WindowInfo *info, const char *name, const char *font_name);
int window_show_choice_dialog(main__WindowInfo *info, const char *title, const char *message, const char **choices, int choices_count);
void window_add_context_menu_item(main__WindowInfo *info, const char *control_name, const char *item_title, const char *handler_name);
void window_set_padding(main__WindowInfo *info, int padding);
void window_set_spacing(main__WindowInfo *info, int spacing);
void window_set_responsive_layout(main__WindowInfo *info, int enabled);
void *window_add_group_box_control(main__WindowInfo *info, const char *name, const char *title);
void *window_add_tabs_control(main__WindowInfo *info, const char *name, const char **titles, int titles_count);
void *window_add_scroll_view_control(main__WindowInfo *info, const char *name, int height);
void window_focus_control(main__WindowInfo *info, const char *name);
void window_set_placeholder_by_name(main__WindowInfo *info, const char *name, const char *text);
void window_set_error_by_name(main__WindowInfo *info, const char *name, const char *text);
void window_set_tooltip_by_name(main__WindowInfo *info, const char *name, const char *text);
void window_set_default_button_by_name(main__WindowInfo *info, const char *name);
void window_run_after(main__WindowInfo *info, int ms, const char *handler_name);
void window_show_toast(main__WindowInfo *info, const char *message);
void window_open_url(main__WindowInfo *info, const char *url);
void window_copy_to_clipboard(main__WindowInfo *info, const char *text);

// Name-based generic control accessors
void window_set_control_text_by_name(main__WindowInfo *info, const char *name, const char *text);
char *window_get_control_text_by_name(main__WindowInfo *info, const char *name);
void window_set_control_bool_by_name(main__WindowInfo *info, const char *name, int checked);
int window_get_control_bool_by_name(main__WindowInfo *info, const char *name);
void window_set_control_int_by_name(main__WindowInfo *info, const char *name, int value);
int window_get_control_int_by_name(main__WindowInfo *info, const char *name);

// Dynamic control creation bridges
void *window_add_label_control(main__WindowInfo *info, const char *name, const char *text);
void *window_add_input_control(main__WindowInfo *info, const char *name, const char *value);
void *window_add_password_control(main__WindowInfo *info, const char *name, const char *value);
void *window_add_textarea_control(main__WindowInfo *info, const char *name, const char *value);
void *window_add_html_view_control(main__WindowInfo *info, const char *name, const char *html);
void *window_add_drop_zone_control(main__WindowInfo *info, const char *name, const char *label);
void *window_add_checkbox_control(main__WindowInfo *info, const char *name, const char *text, int checked);
void *window_add_button_control(main__WindowInfo *info, const char *name, const char *text);
void *window_add_number_control(main__WindowInfo *info, const char *name, int value);
void *window_add_slider_control(main__WindowInfo *info, const char *name, int value);
void *window_add_theme_menu_control(main__WindowInfo *info, const char *name, const char *selected);
void *window_add_color_well_control(main__WindowInfo *info, const char *name, const char *color);
void *window_add_date_picker_control(main__WindowInfo *info, const char *name, const char *date);
void *window_add_mode_control_control(main__WindowInfo *info, const char *name, const char *selected);
void *window_add_progress_indicator_control(main__WindowInfo *info, const char *name, int value);

// Layout row groupings
void window_begin_row(main__WindowInfo *info, const char *name);
void window_end_row(main__WindowInfo *info);

// Popups and Dialogs
void window_show_alert(main__WindowInfo *info, const char *title, const char *message);
void window_show_alert_with_style(main__WindowInfo *info, const char *title, const char *message, const char *style);
int window_show_confirm(main__WindowInfo *info, const char *title, const char *message);
char *window_show_prompt(main__WindowInfo *info, const char *title, const char *message, const char *default_val);

// File and Folder Pickers
char *window_select_file(main__WindowInfo *info);
char *window_select_file_with_extensions(main__WindowInfo *info, const char *extensions);
char *window_select_folder(main__WindowInfo *info);
char *window_save_file_picker(main__WindowInfo *info);

// Visibility and Enabled states
void window_set_control_visible_by_name(main__WindowInfo *info, const char *name, int visible);
int window_get_control_visible_by_name(main__WindowInfo *info, const char *name);
void window_set_control_enabled_by_name(main__WindowInfo *info, const char *name, int enabled);
int window_get_control_enabled_by_name(main__WindowInfo *info, const char *name);

// Timers
void window_set_interval(main__WindowInfo *info, int ms, const char *timer_name);
void window_stop_interval(main__WindowInfo *info, const char *timer_name);

// List Box and Image View Controls
void *window_add_list_box_control(main__WindowInfo *info, const char *name, const char **items, int items_count);
void window_update_list_items(main__WindowInfo *info, const char *name, const char **items, int items_count);
void window_set_list_selected(main__WindowInfo *info, const char *name, int index);
int window_get_list_selected(main__WindowInfo *info, const char *name);
void window_set_list_multi_select(main__WindowInfo *info, const char *name, int enabled);
char *window_get_list_selected_indexes(main__WindowInfo *info, const char *name);
void window_set_list_selected_indexes(main__WindowInfo *info, const char *name, const char *csv_indexes);
void window_select_all_list_items(main__WindowInfo *info, const char *name);
void window_clear_list_selection(main__WindowInfo *info, const char *name);
void *window_add_image_control(main__WindowInfo *info, const char *name, const char *file_path);
void window_set_image_path(main__WindowInfo *info, const char *name, const char *file_path);

// Hover Event Tracking
void window_enable_hover_events(main__WindowInfo *info, const char *name);

// Menu Customization
void window_add_menu_item(main__WindowInfo *info, const char *menu_name, const char *item_title, const char *shortcut, const char *handler_name);

// Spacers and Separators
void window_add_vertical_spacer(main__WindowInfo *info, int height);
void window_add_horizontal_spacer(main__WindowInfo *info, int width);
void window_add_separator(main__WindowInfo *info);

// Multi-Column Table Controls
void *window_add_table_control(main__WindowInfo *info, const char *name, const char **columns, int columns_count);
void window_set_table_rows(main__WindowInfo *info, const char *name, const char **flat_items, int total_count, int columns_count);

// Tree View Controls
void *window_add_tree_view_control(main__WindowInfo *info, const char *name, int height);
void window_set_tree_nodes(main__WindowInfo *info, const char *name, const char **flat_items, int total_count);
char *window_get_tree_selected(main__WindowInfo *info, const char *name);
void window_set_tree_selected(main__WindowInfo *info, const char *name, const char *node_id);

// System Menu Bar/Tray App Mode
void window_enable_status_bar(main__WindowInfo *info, const char *icon_path);
void window_show(main__WindowInfo *info);

// Thread Safety Runner
void window_run_on_main_thread(void *callback_fn, void *context);

// New general-purpose controls
void *window_add_dropdown_control(main__WindowInfo *info, const char *name, const char **items, int items_count, const char *selected);
void *window_add_segmented_control_custom(main__WindowInfo *info, const char *name, const char **items, int items_count, const char *selected);
void *window_add_radio_group_control(main__WindowInfo *info, const char *name, const char **items, int items_count, const char *selected);
void *window_add_switch_control(main__WindowInfo *info, const char *name, const char *label, int checked);
void *window_add_search_field_control(main__WindowInfo *info, const char *name, const char *placeholder);
void *window_add_combo_box_control(main__WindowInfo *info, const char *name, const char **items, int items_count, const char *selected);
void *window_add_level_indicator_control(main__WindowInfo *info, const char *name, int style, int min_val, int max_val, int value);
void *window_add_spinner_control(main__WindowInfo *info, const char *name, int active);
void *window_add_path_control(main__WindowInfo *info, const char *name, const char *path);
void *window_add_token_field_control(main__WindowInfo *info, const char *name, const char *value);

// Window constraints and behavior options
void window_set_min_size(main__WindowInfo *info, int width, int height);
void window_set_max_size(main__WindowInfo *info, int width, int height);
void window_set_resizable(main__WindowInfo *info, int enabled);
void window_set_minimizable(main__WindowInfo *info, int enabled);
void window_set_maximizable(main__WindowInfo *info, int enabled);

// Additional Window Operations
void window_close(main__WindowInfo *info);
void window_hide(main__WindowInfo *info);
void window_center(main__WindowInfo *info);
void window_align(main__WindowInfo *info, const char *alignment);
void window_set_size(main__WindowInfo *info, int width, int height);
int window_get_width(main__WindowInfo *info);
int window_get_height(main__WindowInfo *info);
void window_set_position(main__WindowInfo *info, int x, int y);
int window_get_x(main__WindowInfo *info);
int window_get_y(main__WindowInfo *info);
void window_set_opacity(main__WindowInfo *info, double opacity);
double window_get_opacity(main__WindowInfo *info);
void window_toggle_fullscreen(main__WindowInfo *info);
void window_minimize(main__WindowInfo *info);
void window_deminimize(main__WindowInfo *info);
void window_maximize(main__WindowInfo *info);
int window_is_minimized(main__WindowInfo *info);
int window_is_maximized(main__WindowInfo *info);
int window_is_fullscreen(main__WindowInfo *info);
int window_is_active(main__WindowInfo *info);
void window_set_titlebar_visible(main__WindowInfo *info, int visible);
void window_request_attention(main__WindowInfo *info, int critical);

void window_set_closable(main__WindowInfo *info, int enabled);
int window_get_closable(main__WindowInfo *info);
void window_set_has_shadow(main__WindowInfo *info, int enabled);
int window_get_has_shadow(main__WindowInfo *info);
void window_set_movable_by_window_background(main__WindowInfo *info, int enabled);
int window_get_movable_by_window_background(main__WindowInfo *info);
int window_is_visible(main__WindowInfo *info);
void window_set_title_visible(main__WindowInfo *info, int visible);
int window_get_title_visible(main__WindowInfo *info);
int window_get_titlebar_visible(main__WindowInfo *info);

void window_deliver_notification(const char *title, const char *message);
void window_set_dock_badge(const char *text);
void window_set_slider_range(main__WindowInfo *info, const char *name, double min_val, double max_val);
void *window_add_link_control(main__WindowInfo *info, const char *name, const char *text, const char *url);
void window_beep();

void *window_add_disclosure_control(main__WindowInfo *info, const char *name, const char *title, int open);
void window_enable_search_history(main__WindowInfo *info, const char *name, const char *autosave_name);
void window_set_status_bar_icon(main__WindowInfo *info, const char *icon_path);
void window_set_status_bar_title(main__WindowInfo *info, const char *title);
void window_set_dock_icon(const char *image_path);
void window_play_system_sound(const char *sound_name);

void *window_add_stepper_control(main__WindowInfo *info, const char *name, double min_val, double max_val, double step, double value);
void *window_add_help_button_control(main__WindowInfo *info, const char *name);
void *window_add_knob_control(main__WindowInfo *info, const char *name, double min_val, double max_val, double value);
void *window_add_pull_down_control(main__WindowInfo *info, const char *name, const char *title, const char **items, int items_count);
void *window_add_image_button_control(main__WindowInfo *info, const char *name, const char *symbol, const char *title);

// Animations and Transition Helpers
void window_animate_control_opacity(main__WindowInfo *info, const char *name, double opacity, int duration_ms);
void window_animate_opacity(main__WindowInfo *info, double opacity, int duration_ms);
void window_animate_control_shake(main__WindowInfo *info, const char *name);
void window_shake(main__WindowInfo *info);
void window_animate_control_width(main__WindowInfo *info, const char *name, int width, int duration_ms);
void window_animate_control_height(main__WindowInfo *info, const char *name, int height, int duration_ms);
void window_animate_control_size(main__WindowInfo *info, const char *name, int width, int height, int duration_ms);
void window_animate_size(main__WindowInfo *info, int width, int height, int duration_ms);
void window_animate_position(main__WindowInfo *info, int x, int y, int duration_ms);
void window_animate_bounds(main__WindowInfo *info, int x, int y, int width, int height, int duration_ms);

// Native macOS UI extensions
void window_add_toolbar_item(main__WindowInfo *info, const char *name, const char *label, const char *tooltip, const char *symbol);
void window_add_toolbar_space(main__WindowInfo *info);
void window_add_toolbar_flexible_space(main__WindowInfo *info);
void window_set_toolbar_style(main__WindowInfo *info, const char *style);
void window_show_sheet_alert(main__WindowInfo *info, const char *title, const char *message, const char *style);
void window_add_dock_menu_item(main__WindowInfo *info, const char *title, const char *handler_name);

// New controls added in showcase
void window_begin_split_view(main__WindowInfo *info, const char *name, int vertical);
void window_split_view_next_pane(main__WindowInfo *info);
void window_end_split_view(main__WindowInfo *info);
void *window_add_collection_view_control(main__WindowInfo *info, const char *name, int item_width, int item_height);
void window_set_collection_items(main__WindowInfo *info, const char *name, const char **items, int items_count);
void window_show_popover(main__WindowInfo *info, const char *anchor_name, const char *title, const char *message);
void *window_add_calendar_control(main__WindowInfo *info, const char *name, const char *date);
void *window_add_canvas_control(main__WindowInfo *info, const char *name, int height);
void window_draw_line(main__WindowInfo *info, const char *canvas_name, double x1, double y1, double x2, double y2, const char *color_str, double stroke_width);
void window_draw_rect(main__WindowInfo *info, const char *canvas_name, double x, double y, double w, double h, const char *color_str, int fill, double stroke_width);
void window_draw_circle(main__WindowInfo *info, const char *canvas_name, double x, double y, double r, const char *color_str, int fill, double stroke_width);
void window_clear_canvas(main__WindowInfo *info, const char *canvas_name);

#endif


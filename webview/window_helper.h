#ifndef RAD_WINDOW_HELPER_H
#define RAD_WINDOW_HELPER_H

#ifdef __cplusplus
extern "C" {
#endif

void rad_window_set_always_on_top(void* window_handle, int on_top);
void rad_window_toggle_fullscreen(void* window_handle);
void rad_window_set_fullscreen(void* window_handle, int fullscreen);
void rad_window_minimize(void* window_handle);
void rad_window_hide(void* window_handle);
void rad_window_show(void* window_handle);
void rad_window_focus(void* window_handle);
void rad_window_center(void* window_handle);
void rad_window_set_position(void* window_handle, const char* preset);
void rad_window_get_screen_size(int* out_width, int* out_height);
void rad_window_init_shortcuts(void);
void rad_window_quit(void);

// Enhanced low-level window & screen operations (mirroring + exceeding bun_rad_studio)
void rad_window_set_bounds(void* window_handle, int x, int y, int w, int h, int animate);
void rad_window_maximize(void* window_handle);
void rad_window_unmaximize(void* window_handle);
int rad_window_is_maximized(void* window_handle);
int rad_window_is_fullscreen(void* window_handle);
int rad_window_is_always_on_top(void* window_handle);
int rad_window_get_frame(void* window_handle, int* out_x, int* out_y, int* out_w, int* out_h, int* out_maximized, int* out_fullscreen);
int rad_window_get_screens(int* out_x, int* out_y, int* out_w, int* out_h, int* out_wx, int* out_wy, int* out_ww, int* out_wh, int max_screens);
void rad_window_set_appearance(void* window_handle, int dark, int vibrancy, int transparent_titlebar);
void rad_window_silence_key_beep(void* window_handle);
void rad_window_set_opacity(void* window_handle, double opacity);
void rad_window_set_min_size(void* window_handle, int min_w, int min_h);
void rad_window_set_max_size(void* window_handle, int max_w, int max_h);
void rad_window_set_resizable(void* window_handle, int resizable);
void rad_window_set_borderless(void* window_handle, int borderless);

#ifdef __cplusplus
}
#endif

#endif // RAD_WINDOW_HELPER_H

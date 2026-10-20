#include "window_helper.h"
#include <gtk/gtk.h>
#include <string.h>
#include <stdlib.h>

typedef enum {
    RAD_WINDOW_KEEP_ABOVE,
    RAD_WINDOW_TOGGLE_FULLSCREEN,
    RAD_WINDOW_SET_FULLSCREEN,
    RAD_WINDOW_MINIMIZE,
    RAD_WINDOW_HIDE,
    RAD_WINDOW_SHOW,
    RAD_WINDOW_CENTER,
    RAD_WINDOW_SET_POSITION,
    RAD_WINDOW_SET_BOUNDS,
    RAD_WINDOW_MAXIMIZE,
    RAD_WINDOW_UNMAXIMIZE,
    RAD_WINDOW_SET_APPEARANCE,
    RAD_WINDOW_SET_OPACITY,
    RAD_WINDOW_SET_MIN_SIZE,
    RAD_WINDOW_SET_MAX_SIZE,
    RAD_WINDOW_SET_RESIZABLE,
    RAD_WINDOW_SET_BORDERLESS
} RadWindowAction;

typedef struct {
    GtkWindow* window;
    RadWindowAction action;
    int value;
    int x;
    int y;
    int w;
    int h;
    double dval;
    char preset[32];
} RadWindowActionRequest;

static GtkWindow* rad_gtk_window(void* window_handle) {
    if (window_handle == NULL || !GTK_IS_WINDOW(window_handle)) {
        return NULL;
    }
    return GTK_WINDOW(window_handle);
}

static gboolean rad_gtk_is_fullscreen(GtkWindow* window) {
    GdkWindow* gdk_window = gtk_widget_get_window(GTK_WIDGET(window));
    return gdk_window != NULL && (gdk_window_get_state(gdk_window) & GDK_WINDOW_STATE_FULLSCREEN) != 0;
}

static gboolean rad_gtk_is_maximized(GtkWindow* window) {
    GdkWindow* gdk_window = gtk_widget_get_window(GTK_WIDGET(window));
    if (gdk_window != NULL && (gdk_window_get_state(gdk_window) & GDK_WINDOW_STATE_MAXIMIZED) != 0) {
        return TRUE;
    }
    return gtk_window_is_maximized(window);
}

static void rad_monitor_geometry(GtkWindow* window, GdkRectangle* geometry) {
    GdkScreen* screen = gtk_window_get_screen(window);
    gint monitor = gdk_screen_get_monitor_at_window(screen, gtk_widget_get_window(GTK_WIDGET(window)));
    if (monitor < 0) {
        monitor = 0;
    }
    gdk_screen_get_monitor_workarea(screen, monitor, geometry);
}

static void rad_move_to_preset(GtkWindow* window, const char* preset);

static gboolean rad_move_after_unfullscreen(gpointer data) {
    RadWindowActionRequest* request = data;
    if (GTK_IS_WINDOW(request->window)) {
        rad_move_to_preset(request->window, request->preset);
        gtk_window_present(request->window);
        g_object_unref(request->window);
    }
    g_free(request);
    return G_SOURCE_REMOVE;
}

static void rad_move_to_preset(GtkWindow* window, const char* preset) {
    GdkRectangle workarea;
    gint width = 0;
    gint height = 0;
    gint x = 0;
    gint y = 0;
    gtk_window_get_size(window, &width, &height);
    rad_monitor_geometry(window, &workarea);

    x = workarea.x + (workarea.width - width) / 2;
    y = workarea.y + (workarea.height - height) / 2;
    if (strcmp(preset, "upper_left") == 0 || strcmp(preset, "center_left") == 0 || strcmp(preset, "bottom_left") == 0) {
        x = workarea.x;
    } else if (strcmp(preset, "upper_right") == 0 || strcmp(preset, "center_right") == 0 || strcmp(preset, "bottom_right") == 0) {
        x = workarea.x + workarea.width - width;
    }
    if (strcmp(preset, "upper_left") == 0 || strcmp(preset, "top_center") == 0 || strcmp(preset, "upper_right") == 0) {
        y = workarea.y;
    } else if (strcmp(preset, "bottom_left") == 0 || strcmp(preset, "bottom_center") == 0 || strcmp(preset, "bottom_right") == 0) {
        y = workarea.y + workarea.height - height;
    }
    gtk_window_move(window, x, y);
}

static gboolean s_linux_keep_above = FALSE;

static gboolean rad_apply_window_action(gpointer data) {
    RadWindowActionRequest* request = data;
    GtkWindow* window = request->window;
    if (GTK_IS_WINDOW(window)) {
        switch (request->action) {
            case RAD_WINDOW_KEEP_ABOVE:
                s_linux_keep_above = request->value != 0;
                gtk_window_set_keep_above(window, s_linux_keep_above);
                gtk_window_present(window);
                break;
            case RAD_WINDOW_TOGGLE_FULLSCREEN:
                if (rad_gtk_is_fullscreen(window)) {
                    gtk_window_unfullscreen(window);
                } else {
                    gtk_window_fullscreen(window);
                }
                break;
            case RAD_WINDOW_SET_FULLSCREEN:
                if (rad_gtk_is_fullscreen(window) != (request->value != 0)) {
                    if (request->value != 0) {
                        gtk_window_fullscreen(window);
                    } else {
                        gtk_window_unfullscreen(window);
                    }
                }
                break;
            case RAD_WINDOW_MINIMIZE:
                gtk_window_iconify(window);
                break;
            case RAD_WINDOW_HIDE:
                gtk_widget_hide(GTK_WIDGET(window));
                break;
            case RAD_WINDOW_SHOW:
                gtk_widget_show(GTK_WIDGET(window));
                gtk_window_deiconify(window);
                gtk_window_present(window);
                break;
            case RAD_WINDOW_CENTER:
                gtk_window_set_position(window, GTK_WIN_POS_CENTER);
                break;
            case RAD_WINDOW_SET_POSITION:
                if (rad_gtk_is_fullscreen(window)) {
                    gtk_window_unfullscreen(window);
                    g_timeout_add_full(G_PRIORITY_DEFAULT, 150, rad_move_after_unfullscreen, request, NULL);
                    return G_SOURCE_REMOVE;
                }
                rad_move_to_preset(window, request->preset);
                gtk_window_present(window);
                break;
            case RAD_WINDOW_SET_BOUNDS:
                if (rad_gtk_is_fullscreen(window)) {
                    gtk_window_unfullscreen(window);
                }
                if (rad_gtk_is_maximized(window)) {
                    gtk_window_unmaximize(window);
                }
                gtk_window_move(window, request->x, request->y);
                gtk_window_resize(window, request->w, request->h);
                break;
            case RAD_WINDOW_MAXIMIZE:
                if (rad_gtk_is_fullscreen(window)) {
                    gtk_window_unfullscreen(window);
                }
                gtk_window_maximize(window);
                break;
            case RAD_WINDOW_UNMAXIMIZE:
                if (rad_gtk_is_fullscreen(window)) {
                    gtk_window_unfullscreen(window);
                }
                if (rad_gtk_is_maximized(window)) {
                    gtk_window_unmaximize(window);
                }
                break;
            case RAD_WINDOW_SET_APPEARANCE: {
                GtkSettings* settings = gtk_settings_get_default();
                if (settings != NULL) {
                    g_object_set(settings, "gtk-application-prefer-dark-theme", request->value != 0 ? TRUE : FALSE, NULL);
                }
                break;
            }
            case RAD_WINDOW_SET_OPACITY:
                gtk_widget_set_opacity(GTK_WIDGET(window), request->dval);
                break;
            case RAD_WINDOW_SET_MIN_SIZE:
                gtk_widget_set_size_request(GTK_WIDGET(window), request->w, request->h);
                break;
            case RAD_WINDOW_SET_MAX_SIZE: {
                GdkGeometry geom;
                geom.max_width = request->w;
                geom.max_height = request->h;
                gtk_window_set_geometry_hints(window, NULL, &geom, GDK_HINT_MAX_SIZE);
                break;
            }
            case RAD_WINDOW_SET_RESIZABLE:
                gtk_window_set_resizable(window, request->value != 0 ? TRUE : FALSE);
                break;
            case RAD_WINDOW_SET_BORDERLESS:
                gtk_window_set_decorated(window, request->value != 0 ? FALSE : TRUE);
                break;
        }
        g_object_unref(window);
    }
    g_free(request);
    return G_SOURCE_REMOVE;
}

static void rad_queue_window_action(void* window_handle, RadWindowAction action, int value, const char* preset) {
    GtkWindow* window = rad_gtk_window(window_handle);
    if (window == NULL) {
        return;
    }
    RadWindowActionRequest* request = g_new0(RadWindowActionRequest, 1);
    request->window = GTK_WINDOW(g_object_ref(window));
    request->action = action;
    request->value = value;
    if (preset != NULL) {
        g_strlcpy(request->preset, preset, sizeof(request->preset));
    }
    g_main_context_invoke(NULL, rad_apply_window_action, request);
}

void rad_window_set_always_on_top(void* window_handle, int on_top) {
    rad_queue_window_action(window_handle, RAD_WINDOW_KEEP_ABOVE, on_top, NULL);
}

int rad_window_is_always_on_top(void* window_handle) {
    (void)window_handle;
    return s_linux_keep_above ? 1 : 0;
}

void rad_window_toggle_fullscreen(void* window_handle) {
    rad_queue_window_action(window_handle, RAD_WINDOW_TOGGLE_FULLSCREEN, 0, NULL);
}

void rad_window_set_fullscreen(void* window_handle, int fullscreen) {
    rad_queue_window_action(window_handle, RAD_WINDOW_SET_FULLSCREEN, fullscreen, NULL);
}

void rad_window_minimize(void* window_handle) {
    rad_queue_window_action(window_handle, RAD_WINDOW_MINIMIZE, 0, NULL);
}

void rad_window_hide(void* window_handle) {
    rad_queue_window_action(window_handle, RAD_WINDOW_HIDE, 0, NULL);
}

void rad_window_show(void* window_handle) {
    rad_queue_window_action(window_handle, RAD_WINDOW_SHOW, 0, NULL);
}

void rad_window_focus(void* window_handle) {
    rad_window_show(window_handle);
}

void rad_window_center(void* window_handle) {
    rad_queue_window_action(window_handle, RAD_WINDOW_CENTER, 0, NULL);
}

void rad_window_set_position(void* window_handle, const char* preset) {
    rad_queue_window_action(window_handle, RAD_WINDOW_SET_POSITION, 0, preset);
}

void rad_window_get_screen_size(int* out_width, int* out_height) {
    GdkDisplay* display = gdk_display_get_default();
    GdkMonitor* monitor = display == NULL ? NULL : gdk_display_get_primary_monitor(display);
    if (monitor == NULL && display != NULL && gdk_display_get_n_monitors(display) > 0) {
        monitor = gdk_display_get_monitor(display, 0);
    }
    GdkRectangle geometry = {0, 0, 1920, 1080};
    if (monitor != NULL) {
        gdk_monitor_get_geometry(monitor, &geometry);
    }
    if (out_width != NULL) {
        *out_width = geometry.width;
    }
    if (out_height != NULL) {
        *out_height = geometry.height;
    }
}

void rad_window_set_bounds(void* window_handle, int x, int y, int w, int h, int animate) {
    (void)animate;
    GtkWindow* window = rad_gtk_window(window_handle);
    if (window == NULL) return;
    RadWindowActionRequest* request = g_new0(RadWindowActionRequest, 1);
    request->window = GTK_WINDOW(g_object_ref(window));
    request->action = RAD_WINDOW_SET_BOUNDS;
    request->x = x;
    request->y = y;
    request->w = w;
    request->h = h;
    g_main_context_invoke(NULL, rad_apply_window_action, request);
}

void rad_window_maximize(void* window_handle) {
    rad_queue_window_action(window_handle, RAD_WINDOW_MAXIMIZE, 0, NULL);
}

void rad_window_unmaximize(void* window_handle) {
    rad_queue_window_action(window_handle, RAD_WINDOW_UNMAXIMIZE, 0, NULL);
}

int rad_window_is_maximized(void* window_handle) {
    GtkWindow* window = rad_gtk_window(window_handle);
    if (window == NULL) return 0;
    return rad_gtk_is_maximized(window) ? 1 : 0;
}

int rad_window_is_fullscreen(void* window_handle) {
    GtkWindow* window = rad_gtk_window(window_handle);
    if (window == NULL) return 0;
    return rad_gtk_is_fullscreen(window) ? 1 : 0;
}

int rad_window_get_frame(void* window_handle, int* out_x, int* out_y, int* out_w, int* out_h, int* out_maximized, int* out_fullscreen) {
    GtkWindow* window = rad_gtk_window(window_handle);
    if (window == NULL) return 0;
    gint x = 0, y = 0, w = 0, h = 0;
    gtk_window_get_position(window, &x, &y);
    gtk_window_get_size(window, &w, &h);
    if (w <= 0 || h <= 0) return 0;
    if (out_x) *out_x = x;
    if (out_y) *out_y = y;
    if (out_w) *out_w = w;
    if (out_h) *out_h = h;
    if (out_maximized) *out_maximized = rad_gtk_is_maximized(window) ? 1 : 0;
    if (out_fullscreen) *out_fullscreen = rad_gtk_is_fullscreen(window) ? 1 : 0;
    return 1;
}

int rad_window_get_screens(int* out_x, int* out_y, int* out_w, int* out_h, int* out_wx, int* out_wy, int* out_ww, int* out_wh, int max_screens) {
    if (max_screens <= 0) return 0;
    GdkDisplay* display = gdk_display_get_default();
    if (display == NULL) return 0;
    int n = gdk_display_get_n_monitors(display);
    if (n > max_screens) n = max_screens;
    for (int i = 0; i < n; i++) {
        GdkMonitor* mon = gdk_display_get_monitor(display, i);
        GdkRectangle geom = {0, 0, 1920, 1080};
        GdkRectangle work = {0, 0, 1920, 1080};
        if (mon != NULL) {
            gdk_monitor_get_geometry(mon, &geom);
            gdk_monitor_get_workarea(mon, &work);
        }
        if (out_x) out_x[i] = geom.x;
        if (out_y) out_y[i] = geom.y;
        if (out_w) out_w[i] = geom.width;
        if (out_h) out_h[i] = geom.height;
        if (out_wx) out_wx[i] = work.x;
        if (out_wy) out_wy[i] = work.y;
        if (out_ww) out_ww[i] = work.width;
        if (out_wh) out_wh[i] = work.height;
    }
    return n;
}

void rad_window_set_appearance(void* window_handle, int dark, int vibrancy, int transparent_titlebar) {
    (void)vibrancy;
    (void)transparent_titlebar;
    rad_queue_window_action(window_handle, RAD_WINDOW_SET_APPEARANCE, dark, NULL);
}

void rad_window_silence_key_beep(void* window_handle) {
    (void)window_handle;
}

void rad_window_set_opacity(void* window_handle, double opacity) {
    GtkWindow* window = rad_gtk_window(window_handle);
    if (window == NULL) return;
    double clamped = opacity < 0.1 ? 0.1 : (opacity > 1.0 ? 1.0 : opacity);
    RadWindowActionRequest* request = g_new0(RadWindowActionRequest, 1);
    request->window = GTK_WINDOW(g_object_ref(window));
    request->action = RAD_WINDOW_SET_OPACITY;
    request->dval = clamped;
    g_main_context_invoke(NULL, rad_apply_window_action, request);
}

void rad_window_set_min_size(void* window_handle, int min_w, int min_h) {
    GtkWindow* window = rad_gtk_window(window_handle);
    if (window == NULL) return;
    RadWindowActionRequest* request = g_new0(RadWindowActionRequest, 1);
    request->window = GTK_WINDOW(g_object_ref(window));
    request->action = RAD_WINDOW_SET_MIN_SIZE;
    request->w = min_w;
    request->h = min_h;
    g_main_context_invoke(NULL, rad_apply_window_action, request);
}

void rad_window_set_max_size(void* window_handle, int max_w, int max_h) {
    GtkWindow* window = rad_gtk_window(window_handle);
    if (window == NULL) return;
    RadWindowActionRequest* request = g_new0(RadWindowActionRequest, 1);
    request->window = GTK_WINDOW(g_object_ref(window));
    request->action = RAD_WINDOW_SET_MAX_SIZE;
    request->w = max_w;
    request->h = max_h;
    g_main_context_invoke(NULL, rad_apply_window_action, request);
}

void rad_window_set_resizable(void* window_handle, int resizable) {
    rad_queue_window_action(window_handle, RAD_WINDOW_SET_RESIZABLE, resizable, NULL);
}

void rad_window_set_borderless(void* window_handle, int borderless) {
    rad_queue_window_action(window_handle, RAD_WINDOW_SET_BORDERLESS, borderless, NULL);
}

void rad_window_init_shortcuts(void) {
}

static gboolean rad_quit_main_loop(gpointer data) {
    (void)data;
    gtk_main_quit();
    return G_SOURCE_REMOVE;
}

void rad_window_quit(void) {
    g_main_context_invoke(NULL, rad_quit_main_loop, NULL);
}

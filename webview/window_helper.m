#include "window_helper.h"
#include <string.h>
#include <stdlib.h>
#include <math.h>

#if defined(__APPLE__)
#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>
#import <dlfcn.h>

static void rad_run_on_main_async_or_now(void (^block)(void)) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

static void rad_run_on_main_sync(void (^block)(void)) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

static CGFloat rad_primary_screen_height(void) {
    NSArray<NSScreen*>* screens = [NSScreen screens];
    if (screens && [screens count] > 0) {
        return [screens[0] frame].size.height;
    }
    NSScreen* mainScr = [NSScreen mainScreen];
    if (mainScr) {
        return [mainScr frame].size.height;
    }
    return 1080.0;
}

static NSScreen* rad_screen_for_window(NSWindow* window) {
    NSArray<NSScreen*>* screens = [NSScreen screens];
    if (window && screens && [screens count] > 0) {
        NSRect wf = [window frame];
        CGFloat cx = wf.origin.x + wf.size.width / 2.0;
        CGFloat cy = wf.origin.y + wf.size.height / 2.0;
        for (NSScreen* s in screens) {
            NSRect sf = [s frame];
            if (cx >= sf.origin.x && cx < sf.origin.x + sf.size.width &&
                cy >= sf.origin.y && cy < sf.origin.y + sf.size.height) {
                return s;
            }
        }
    }
    if (window && [window screen]) {
        return [window screen];
    }
    if (screens && [screens count] > 0) {
        return screens[0];
    }
    return [NSScreen mainScreen];
}

void rad_window_set_always_on_top(void* window_handle, int on_top) {
    if (!window_handle) return;
    rad_run_on_main_async_or_now(^{
        NSWindow* window = (NSWindow*)window_handle;
        if (on_top) {
            [window setLevel:NSFloatingWindowLevel];
        } else {
            [window setLevel:NSNormalWindowLevel];
        }
    });
}

int rad_window_is_always_on_top(void* window_handle) {
    if (!window_handle) return 0;
    __block int result = 0;
    rad_run_on_main_sync(^{
        NSWindow* window = (NSWindow*)window_handle;
        result = ([window level] >= NSFloatingWindowLevel) ? 1 : 0;
    });
    return result;
}

void rad_window_toggle_fullscreen(void* window_handle) {
    if (!window_handle) return;
    rad_run_on_main_async_or_now(^{
        NSWindow* window = (NSWindow*)window_handle;
        NSWindowStyleMask mask = [window styleMask];
        if (!(mask & NSWindowStyleMaskResizable)) {
            [window setStyleMask:(mask | NSWindowStyleMaskResizable)];
        }
        NSWindowCollectionBehavior cb = [window collectionBehavior];
        if (!(cb & NSWindowCollectionBehaviorFullScreenPrimary)) {
            [window setCollectionBehavior:(cb | NSWindowCollectionBehaviorFullScreenPrimary)];
        }
        [window toggleFullScreen:nil];
    });
}

void rad_window_set_fullscreen(void* window_handle, int fullscreen) {
    if (!window_handle) return;
    void (^apply_fullscreen)(void) = ^{
        NSWindow* window = (NSWindow*)window_handle;
        BOOL is_fs = (([window styleMask] & NSWindowStyleMaskFullScreen) != 0);
        if ((fullscreen && !is_fs) || (!fullscreen && is_fs)) {
            NSWindowStyleMask mask = [window styleMask];
            if (!(mask & NSWindowStyleMaskResizable)) {
                [window setStyleMask:(mask | NSWindowStyleMaskResizable)];
            }
            NSWindowCollectionBehavior cb = [window collectionBehavior];
            if (!(cb & NSWindowCollectionBehaviorFullScreenPrimary)) {
                [window setCollectionBehavior:(cb | NSWindowCollectionBehaviorFullScreenPrimary)];
            }
            [window makeKeyAndOrderFront:nil];
            [window toggleFullScreen:nil];
        }
    };

    rad_run_on_main_async_or_now(apply_fullscreen);

    if (fullscreen) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(150 * NSEC_PER_MSEC)), dispatch_get_main_queue(), apply_fullscreen);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(350 * NSEC_PER_MSEC)), dispatch_get_main_queue(), apply_fullscreen);
    }
}

void rad_window_minimize(void* window_handle) {
    if (!window_handle) return;
    rad_run_on_main_async_or_now(^{
        NSWindow* window = (NSWindow*)window_handle;
        NSWindowStyleMask mask = [window styleMask];
        if (!(mask & NSWindowStyleMaskMiniaturizable)) {
            [window setStyleMask:(mask | NSWindowStyleMaskMiniaturizable)];
        }
        if (mask & NSWindowStyleMaskFullScreen) {
            [window toggleFullScreen:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [window miniaturize:nil];
            });
        } else {
            [window miniaturize:nil];
        }
    });
}

void rad_window_hide(void* window_handle) {
    (void)window_handle;
    rad_run_on_main_async_or_now(^{
        [NSApp hide:nil];
    });
}

void rad_window_show(void* window_handle) {
    if (!window_handle) return;
    rad_run_on_main_async_or_now(^{
        NSWindow* window = (NSWindow*)window_handle;
        [NSApp unhideWithoutActivation];
        if ([window isMiniaturized]) {
            [window deminiaturize:nil];
        }
        [window makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
    });
}

void rad_window_focus(void* window_handle) {
    rad_window_show(window_handle);
}

void rad_window_center(void* window_handle) {
    if (!window_handle) return;
    rad_run_on_main_async_or_now(^{
        NSWindow* window = (NSWindow*)window_handle;
        NSScreen* screen = rad_screen_for_window(window);
        if (screen) {
            NSRect vf = [screen visibleFrame];
            NSRect wf = [window frame];
            CGFloat x = vf.origin.x + (vf.size.width - wf.size.width) / 2.0;
            CGFloat y = vf.origin.y + (vf.size.height - wf.size.height) / 2.0;
            [window setFrameOrigin:NSMakePoint(x, y)];
        } else {
            [window center];
        }
    });
}

void rad_window_set_position(void* window_handle, const char* preset) {
    if (!window_handle || !preset) return;
    NSString* preset_ns = [[NSString alloc] initWithUTF8String:preset];
    rad_run_on_main_async_or_now(^{
        const char* preset_copy = [preset_ns UTF8String];
        NSWindow* window = (NSWindow*)window_handle;
        NSScreen* screen = rad_screen_for_window(window);
        if (!screen || !preset_copy) {
            [preset_ns release];
            return;
        }

        NSRect screen_frame = [screen visibleFrame];
        NSRect win_frame = [window frame];

        CGFloat x = win_frame.origin.x;
        CGFloat y = win_frame.origin.y;

        if (strcmp(preset_copy, "center") == 0) {
            x = screen_frame.origin.x + (screen_frame.size.width - win_frame.size.width) / 2.0;
            y = screen_frame.origin.y + (screen_frame.size.height - win_frame.size.height) / 2.0;
        } else if (strcmp(preset_copy, "upper_left") == 0) {
            x = screen_frame.origin.x;
            y = screen_frame.origin.y + screen_frame.size.height - win_frame.size.height;
        } else if (strcmp(preset_copy, "upper_right") == 0) {
            x = screen_frame.origin.x + screen_frame.size.width - win_frame.size.width;
            y = screen_frame.origin.y + screen_frame.size.height - win_frame.size.height;
        } else if (strcmp(preset_copy, "top_center") == 0) {
            x = screen_frame.origin.x + (screen_frame.size.width - win_frame.size.width) / 2.0;
            y = screen_frame.origin.y + screen_frame.size.height - win_frame.size.height;
        } else if (strcmp(preset_copy, "bottom_left") == 0) {
            x = screen_frame.origin.x;
            y = screen_frame.origin.y;
        } else if (strcmp(preset_copy, "bottom_right") == 0) {
            x = screen_frame.origin.x + screen_frame.size.width - win_frame.size.width;
            y = screen_frame.origin.y;
        } else if (strcmp(preset_copy, "bottom_center") == 0) {
            x = screen_frame.origin.x + (screen_frame.size.width - win_frame.size.width) / 2.0;
            y = screen_frame.origin.y;
        } else if (strcmp(preset_copy, "center_left") == 0) {
            x = screen_frame.origin.x;
            y = screen_frame.origin.y + (screen_frame.size.height - win_frame.size.height) / 2.0;
        } else if (strcmp(preset_copy, "center_right") == 0) {
            x = screen_frame.origin.x + screen_frame.size.width - win_frame.size.width;
            y = screen_frame.origin.y + (screen_frame.size.height - win_frame.size.height) / 2.0;
        }

        [window setFrameOrigin:NSMakePoint(x, y)];
        [preset_ns release];
    });
}

void rad_window_get_screen_size(int* out_width, int* out_height) {
    if (!out_width || !out_height) return;
    __block int w = 1920;
    __block int h = 1080;
    rad_run_on_main_sync(^{
        NSScreen* screen = [NSScreen mainScreen];
        if (!screen) {
            NSArray<NSScreen*>* screens = [NSScreen screens];
            if (screens && [screens count] > 0) screen = screens[0];
        }
        if (screen) {
            NSRect frame = [screen frame];
            w = (int)llround(frame.size.width);
            h = (int)llround(frame.size.height);
        }
    });
    *out_width = w;
    *out_height = h;
}

void rad_window_set_bounds(void* window_handle, int x, int y, int w, int h, int animate) {
    if (!window_handle) return;
    rad_run_on_main_async_or_now(^{
        NSWindow* window = (NSWindow*)window_handle;
        CGFloat primaryH = rad_primary_screen_height();
        CGFloat flippedY = primaryH - (CGFloat)y - (CGFloat)h;
        NSRect rect = NSMakeRect((CGFloat)x, flippedY, (CGFloat)w, (CGFloat)h);
        if (([window styleMask] & NSWindowStyleMaskFullScreen) != 0) {
            [window toggleFullScreen:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(380 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                [window setFrame:rect display:YES animate:(animate ? YES : NO)];
            });
        } else {
            [window setFrame:rect display:YES animate:(animate ? YES : NO)];
        }
    });
}

void rad_window_maximize(void* window_handle) {
    if (!window_handle) return;
    rad_run_on_main_async_or_now(^{
        NSWindow* window = (NSWindow*)window_handle;
        NSScreen* targetScreen = rad_screen_for_window(window);
        if (!targetScreen) return;
        NSRect visible = [targetScreen visibleFrame];
        if (([window styleMask] & NSWindowStyleMaskFullScreen) != 0) {
            [window toggleFullScreen:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(380 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                [window setFrame:visible display:YES animate:YES];
            });
        } else {
            [window setFrame:visible display:YES animate:YES];
        }
    });
}

void rad_window_unmaximize(void* window_handle) {
    if (!window_handle) return;
    rad_run_on_main_async_or_now(^{
        NSWindow* window = (NSWindow*)window_handle;
        if (([window styleMask] & NSWindowStyleMaskFullScreen) != 0) {
            [window toggleFullScreen:nil];
        } else if ([window isZoomed]) {
            [window zoom:nil];
        }
    });
}

int rad_window_is_maximized(void* window_handle) {
    if (!window_handle) return 0;
    __block int res = 0;
    rad_run_on_main_sync(^{
        NSWindow* window = (NSWindow*)window_handle;
        BOOL isFs = (([window styleMask] & NSWindowStyleMaskFullScreen) != 0);
        if (isFs) {
            res = 0;
            return;
        }
        if ([window isZoomed]) {
            res = 1;
            return;
        }
        NSScreen* scr = rad_screen_for_window(window);
        if (scr) {
            NSRect vf = [scr visibleFrame];
            NSRect wf = [window frame];
            if (fabs(wf.origin.x - vf.origin.x) <= 4.0 &&
                fabs(wf.origin.y - vf.origin.y) <= 4.0 &&
                fabs(wf.size.width - vf.size.width) <= 4.0 &&
                fabs(wf.size.height - vf.size.height) <= 4.0) {
                res = 1;
            }
        }
    });
    return res;
}

int rad_window_is_fullscreen(void* window_handle) {
    if (!window_handle) return 0;
    __block int res = 0;
    rad_run_on_main_sync(^{
        NSWindow* window = (NSWindow*)window_handle;
        res = (([window styleMask] & NSWindowStyleMaskFullScreen) != 0) ? 1 : 0;
    });
    return res;
}

int rad_window_get_frame(void* window_handle, int* out_x, int* out_y, int* out_w, int* out_h, int* out_maximized, int* out_fullscreen) {
    if (!window_handle) return 0;
    __block int x = 0, y = 0, w = 0, h = 0, maximized = 0, fullscreen = 0;
    __block int ok = 0;
    rad_run_on_main_sync(^{
        NSWindow* window = (NSWindow*)window_handle;
        NSRect wf = [window frame];
        if (wf.size.width <= 0 || wf.size.height <= 0) {
            ok = 0;
            return;
        }
        CGFloat primaryH = rad_primary_screen_height();
        x = (int)llround(wf.origin.x);
        y = (int)llround(primaryH - (wf.origin.y + wf.size.height));
        w = (int)llround(wf.size.width);
        h = (int)llround(wf.size.height);
        BOOL isFs = (([window styleMask] & NSWindowStyleMaskFullScreen) != 0);
        fullscreen = isFs ? 1 : 0;
        if (!isFs) {
            if ([window isZoomed]) {
                maximized = 1;
            } else {
                NSScreen* scr = rad_screen_for_window(window);
                if (scr) {
                    NSRect vf = [scr visibleFrame];
                    if (fabs(wf.origin.x - vf.origin.x) <= 4.0 &&
                        fabs(wf.origin.y - vf.origin.y) <= 4.0 &&
                        fabs(wf.size.width - vf.size.width) <= 4.0 &&
                        fabs(wf.size.height - vf.size.height) <= 4.0) {
                        maximized = 1;
                    }
                }
            }
        }
        ok = 1;
    });
    if (!ok) return 0;
    if (out_x) *out_x = x;
    if (out_y) *out_y = y;
    if (out_w) *out_w = w;
    if (out_h) *out_h = h;
    if (out_maximized) *out_maximized = maximized;
    if (out_fullscreen) *out_fullscreen = fullscreen;
    return 1;
}

int rad_window_get_screens(int* out_x, int* out_y, int* out_w, int* out_h, int* out_wx, int* out_wy, int* out_ww, int* out_wh, int max_screens) {
    if (max_screens <= 0) return 0;
    __block int count = 0;
    rad_run_on_main_sync(^{
        NSArray<NSScreen*>* screens = [NSScreen screens];
        if (!screens || [screens count] == 0) {
            return;
        }
        CGFloat primaryH = [screens[0] frame].size.height;
        if (primaryH <= 0) primaryH = 1080.0;
        NSUInteger n = [screens count];
        if ((int)n > max_screens) n = (NSUInteger)max_screens;
        for (NSUInteger i = 0; i < n; i++) {
            NSScreen* s = screens[i];
            NSRect f = [s frame];
            NSRect vf = [s visibleFrame];
            if (out_x) out_x[i] = (int)llround(f.origin.x);
            if (out_y) out_y[i] = (int)llround(primaryH - (f.origin.y + f.size.height));
            if (out_w) out_w[i] = (int)llround(f.size.width);
            if (out_h) out_h[i] = (int)llround(f.size.height);
            if (out_wx) out_wx[i] = (int)llround(vf.origin.x);
            if (out_wy) out_wy[i] = (int)llround(primaryH - (vf.origin.y + vf.size.height));
            if (out_ww) out_ww[i] = (int)llround(vf.size.width);
            if (out_wh) out_wh[i] = (int)llround(vf.size.height);
        }
        count = (int)n;
    });
    return count;
}

void rad_window_set_appearance(void* window_handle, int dark, int vibrancy, int transparent_titlebar) {
    if (!window_handle) return;
    rad_run_on_main_async_or_now(^{
        NSWindow* window = (NSWindow*)window_handle;
        NSString* appName = NSAppearanceNameAqua;
        if (dark && vibrancy) {
            appName = NSAppearanceNameVibrantDark;
        } else if (dark) {
            appName = NSAppearanceNameDarkAqua;
        } else if (vibrancy) {
            appName = NSAppearanceNameVibrantLight;
        }
        NSAppearance* appearance = [NSAppearance appearanceNamed:appName];
        if (appearance) {
            [window setAppearance:appearance];
        }
        if (transparent_titlebar) {
            [window setTitlebarAppearsTransparent:YES];
        }
        if (dark) {
            NSColor* bg = [NSColor colorWithSRGBRed:(13.0 / 255.0) green:(17.0 / 255.0) blue:(23.0 / 255.0) alpha:1.0];
            if (bg) [window setBackgroundColor:bg];
        }
        if (vibrancy) {
            [window setOpaque:NO];
        }
    });
}

static void rad_noop_no_responder_for(id self, SEL _cmd, SEL eventSelector) {
    (void)self;
    (void)_cmd;
    (void)eventSelector;
}

typedef int (*rad_cgs_set_symbolic_hotkey_fn)(int hotKey, bool isEnabled);
static rad_cgs_set_symbolic_hotkey_fn s_cgs_hotkey_fn = NULL;
static BOOL s_beep_silenced = NO;

static void rad_restore_symbolic_hotkeys(void) {
    if (s_cgs_hotkey_fn) {
        s_cgs_hotkey_fn(36, true);
        s_cgs_hotkey_fn(37, true);
    }
}

void rad_window_silence_key_beep(void* window_handle) {
    rad_run_on_main_async_or_now(^{
        if (window_handle) {
            Class winCls = [(id)window_handle class];
            SEL sel = @selector(noResponderFor:);
            class_replaceMethod(winCls, sel, (IMP)rad_noop_no_responder_for, "v@::");
        }
        if (!s_beep_silenced) {
            s_beep_silenced = YES;
            Class respCls = [NSResponder class];
            SEL sel = @selector(noResponderFor:);
            class_replaceMethod(respCls, sel, (IMP)rad_noop_no_responder_for, "v@::");

            void* sym = dlsym(RTLD_DEFAULT, "CGSSetSymbolicHotKeyEnabled");
            if (sym) {
                s_cgs_hotkey_fn = (rad_cgs_set_symbolic_hotkey_fn)sym;
                s_cgs_hotkey_fn(36, false);
                s_cgs_hotkey_fn(37, false);
                atexit(rad_restore_symbolic_hotkeys);
            }
        }
    });
}

void rad_window_set_opacity(void* window_handle, double opacity) {
    if (!window_handle) return;
    double clamped = opacity < 0.1 ? 0.1 : (opacity > 1.0 ? 1.0 : opacity);
    rad_run_on_main_async_or_now(^{
        NSWindow* window = (NSWindow*)window_handle;
        [window setOpaque:(clamped >= 1.0 ? YES : NO)];
        [window setAlphaValue:(CGFloat)clamped];
    });
}

void rad_window_set_min_size(void* window_handle, int min_w, int min_h) {
    if (!window_handle) return;
    rad_run_on_main_async_or_now(^{
        NSWindow* window = (NSWindow*)window_handle;
        [window setMinSize:NSMakeSize((CGFloat)min_w, (CGFloat)min_h)];
    });
}

void rad_window_set_max_size(void* window_handle, int max_w, int max_h) {
    if (!window_handle) return;
    rad_run_on_main_async_or_now(^{
        NSWindow* window = (NSWindow*)window_handle;
        [window setMaxSize:NSMakeSize((CGFloat)max_w, (CGFloat)max_h)];
    });
}

void rad_window_set_resizable(void* window_handle, int resizable) {
    if (!window_handle) return;
    rad_run_on_main_async_or_now(^{
        NSWindow* window = (NSWindow*)window_handle;
        NSWindowStyleMask mask = [window styleMask];
        if (resizable) {
            [window setStyleMask:(mask | NSWindowStyleMaskResizable)];
        } else {
            [window setStyleMask:(mask & ~NSWindowStyleMaskResizable)];
        }
    });
}

void rad_window_set_borderless(void* window_handle, int borderless) {
    if (!window_handle) return;
    rad_run_on_main_async_or_now(^{
        NSWindow* window = (NSWindow*)window_handle;
        if (borderless) {
            Class cls = [window class];
            IMP yesImp = imp_implementationWithBlock(^BOOL(id _self) { return YES; });
            class_replaceMethod(cls, @selector(canBecomeKeyWindow), yesImp, "c@:");
            class_replaceMethod(cls, @selector(canBecomeMainWindow), yesImp, "c@:");
            [window setStyleMask:NSWindowStyleMaskBorderless];
            [window makeKeyAndOrderFront:nil];
        } else {
            NSWindowStyleMask mask = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable;
            [window setStyleMask:mask];
            [window makeKeyAndOrderFront:nil];
        }
    });
}

static BOOL s_shortcuts_installed = NO;

void rad_window_init_shortcuts(void) {
    if (s_shortcuts_installed) return;
    s_shortcuts_installed = YES;
    rad_run_on_main_async_or_now(^{
        [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^NSEvent *(NSEvent *event) {
            NSEventModifierFlags flags = [event modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask;
            if (flags == NSEventModifierFlagCommand) {
                NSString *chars = [[event charactersIgnoringModifiers] lowercaseString];
                if ([chars isEqualToString:@"q"]) {
                    [NSApp terminate:nil];
                    exit(0);
                    return nil;
                } else if ([chars isEqualToString:@"w"]) {
                    NSWindow *keyWindow = [NSApp keyWindow];
                    if (keyWindow) {
                        [keyWindow performClose:nil];
                    }
                    return nil;
                }
            }
            return event;
        }];
    });
}

void rad_window_quit(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSApp terminate:nil];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        exit(0);
    });
}

#elif defined(_WIN32)
#include <windows.h>
#include <dwmapi.h>

void rad_window_set_always_on_top(void* window_handle, int on_top) {
    if (!window_handle) return;
    HWND hwnd = (HWND)window_handle;
    HWND insertAfter = on_top ? HWND_TOPMOST : HWND_NOTOPMOST;
    SetWindowPos(hwnd, insertAfter, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
}

int rad_window_is_always_on_top(void* window_handle) {
    if (!window_handle) return 0;
    LONG exStyle = GetWindowLong((HWND)window_handle, GWL_EXSTYLE);
    return (exStyle & WS_EX_TOPMOST) ? 1 : 0;
}

void rad_window_toggle_fullscreen(void* window_handle) {
    if (!window_handle) return;
    HWND hwnd = (HWND)window_handle;
    DWORD style = GetWindowLong(hwnd, GWL_STYLE);
    if (style & WS_OVERLAPPEDWINDOW) {
        MONITORINFO mi = { sizeof(mi) };
        if (GetMonitorInfo(MonitorFromWindow(hwnd, MONITOR_DEFAULTTOPRIMARY), &mi)) {
            SetWindowLong(hwnd, GWL_STYLE, style & ~WS_OVERLAPPEDWINDOW);
            SetWindowPos(hwnd, HWND_TOP, mi.rcMonitor.left, mi.rcMonitor.top,
                         mi.rcMonitor.right - mi.rcMonitor.left,
                         mi.rcMonitor.bottom - mi.rcMonitor.top,
                         SWP_NOOWNERZORDER | SWP_FRAMECHANGED);
        }
    } else {
        SetWindowLong(hwnd, GWL_STYLE, style | WS_OVERLAPPEDWINDOW);
        SetWindowPos(hwnd, NULL, 0, 0, 0, 0,
                     SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED);
    }
}

void rad_window_set_fullscreen(void* window_handle, int fullscreen) {
    if (!window_handle) return;
    HWND hwnd = (HWND)window_handle;
    DWORD style = GetWindowLong(hwnd, GWL_STYLE);
    int is_fs = !(style & WS_OVERLAPPEDWINDOW);
    if ((fullscreen && !is_fs) || (!fullscreen && is_fs)) {
        rad_window_toggle_fullscreen(window_handle);
    }
}

void rad_window_minimize(void* window_handle) {
    if (!window_handle) return;
    ShowWindow((HWND)window_handle, SW_MINIMIZE);
}

void rad_window_hide(void* window_handle) {
    if (!window_handle) return;
    ShowWindow((HWND)window_handle, SW_HIDE);
}

void rad_window_show(void* window_handle) {
    if (!window_handle) return;
    ShowWindow((HWND)window_handle, SW_RESTORE);
    SetForegroundWindow((HWND)window_handle);
}

void rad_window_focus(void* window_handle) {
    rad_window_show(window_handle);
}

void rad_window_center(void* window_handle) {
    if (!window_handle) return;
    HWND hwnd = (HWND)window_handle;
    RECT rc;
    GetWindowRect(hwnd, &rc);
    int win_w = rc.right - rc.left;
    int win_h = rc.bottom - rc.top;
    int scr_w = GetSystemMetrics(SM_CXSCREEN);
    int scr_h = GetSystemMetrics(SM_CYSCREEN);
    int x = (scr_w - win_w) / 2;
    int y = (scr_h - win_h) / 2;
    SetWindowPos(hwnd, NULL, x, y, 0, 0, SWP_NOSIZE | SWP_NOZORDER);
}

void rad_window_set_position(void* window_handle, const char* preset) {
    if (!window_handle || !preset) return;
    HWND hwnd = (HWND)window_handle;
    RECT rc;
    GetWindowRect(hwnd, &rc);
    int win_w = rc.right - rc.left;
    int win_h = rc.bottom - rc.top;
    int scr_w = GetSystemMetrics(SM_CXSCREEN);
    int scr_h = GetSystemMetrics(SM_CYSCREEN);
    int x = rc.left, y = rc.top;

    if (strcmp(preset, "center") == 0) {
        x = (scr_w - win_w) / 2;
        y = (scr_h - win_h) / 2;
    } else if (strcmp(preset, "upper_left") == 0) {
        x = 0; y = 0;
    } else if (strcmp(preset, "upper_right") == 0) {
        x = scr_w - win_w; y = 0;
    } else if (strcmp(preset, "top_center") == 0) {
        x = (scr_w - win_w) / 2; y = 0;
    } else if (strcmp(preset, "bottom_left") == 0) {
        x = 0; y = scr_h - win_h;
    } else if (strcmp(preset, "bottom_right") == 0) {
        x = scr_w - win_w; y = scr_h - win_h;
    } else if (strcmp(preset, "bottom_center") == 0) {
        x = (scr_w - win_w) / 2; y = scr_h - win_h;
    } else if (strcmp(preset, "center_left") == 0) {
        x = 0; y = (scr_h - win_h) / 2;
    } else if (strcmp(preset, "center_right") == 0) {
        x = scr_w - win_w; y = (scr_h - win_h) / 2;
    }

    SetWindowPos(hwnd, NULL, x, y, 0, 0, SWP_NOSIZE | SWP_NOZORDER);
}

void rad_window_get_screen_size(int* out_width, int* out_height) {
    if (!out_width || !out_height) return;
    *out_width = GetSystemMetrics(SM_CXSCREEN);
    *out_height = GetSystemMetrics(SM_CYSCREEN);
}

void rad_window_set_bounds(void* window_handle, int x, int y, int w, int h, int animate) {
    (void)animate;
    if (!window_handle) return;
    SetWindowPos((HWND)window_handle, NULL, x, y, w, h, SWP_NOZORDER | SWP_NOACTIVATE);
}

void rad_window_maximize(void* window_handle) {
    if (!window_handle) return;
    ShowWindow((HWND)window_handle, SW_MAXIMIZE);
}

void rad_window_unmaximize(void* window_handle) {
    if (!window_handle) return;
    ShowWindow((HWND)window_handle, SW_RESTORE);
}

int rad_window_is_maximized(void* window_handle) {
    if (!window_handle) return 0;
    return IsZoomed((HWND)window_handle) ? 1 : 0;
}

int rad_window_is_fullscreen(void* window_handle) {
    if (!window_handle) return 0;
    DWORD style = GetWindowLong((HWND)window_handle, GWL_STYLE);
    return !(style & WS_OVERLAPPEDWINDOW) ? 1 : 0;
}

int rad_window_get_frame(void* window_handle, int* out_x, int* out_y, int* out_w, int* out_h, int* out_maximized, int* out_fullscreen) {
    if (!window_handle) return 0;
    HWND hwnd = (HWND)window_handle;
    RECT rc;
    if (!GetWindowRect(hwnd, &rc)) return 0;
    int w = rc.right - rc.left;
    int h = rc.bottom - rc.top;
    if (w <= 0 || h <= 0) return 0;
    if (out_x) *out_x = rc.left;
    if (out_y) *out_y = rc.top;
    if (out_w) *out_w = w;
    if (out_h) *out_h = h;
    if (out_maximized) *out_maximized = IsZoomed(hwnd) ? 1 : 0;
    if (out_fullscreen) {
        DWORD style = GetWindowLong(hwnd, GWL_STYLE);
        *out_fullscreen = !(style & WS_OVERLAPPEDWINDOW) ? 1 : 0;
    }
    return 1;
}

typedef struct {
    int* out_x;
    int* out_y;
    int* out_w;
    int* out_h;
    int* out_wx;
    int* out_wy;
    int* out_ww;
    int* out_wh;
    int max_screens;
    int count;
} WinScreenEnumCtx;

static BOOL CALLBACK rad_enum_monitors_proc(HMONITOR hMonitor, HDC hdcMonitor, LPRECT lprcMonitor, LPARAM dwData) {
    (void)hdcMonitor;
    (void)lprcMonitor;
    WinScreenEnumCtx* ctx = (WinScreenEnumCtx*)dwData;
    if (ctx->count >= ctx->max_screens) return FALSE;
    MONITORINFO mi;
    mi.cbSize = sizeof(mi);
    if (GetMonitorInfo(hMonitor, &mi)) {
        int i = ctx->count++;
        if (ctx->out_x) ctx->out_x[i] = mi.rcMonitor.left;
        if (ctx->out_y) ctx->out_y[i] = mi.rcMonitor.top;
        if (ctx->out_w) ctx->out_w[i] = mi.rcMonitor.right - mi.rcMonitor.left;
        if (ctx->out_h) ctx->out_h[i] = mi.rcMonitor.bottom - mi.rcMonitor.top;
        if (ctx->out_wx) ctx->out_wx[i] = mi.rcWork.left;
        if (ctx->out_wy) ctx->out_wy[i] = mi.rcWork.top;
        if (ctx->out_ww) ctx->out_ww[i] = mi.rcWork.right - mi.rcWork.left;
        if (ctx->out_wh) ctx->out_wh[i] = mi.rcWork.bottom - mi.rcWork.top;
    }
    return TRUE;
}

int rad_window_get_screens(int* out_x, int* out_y, int* out_w, int* out_h, int* out_wx, int* out_wy, int* out_ww, int* out_wh, int max_screens) {
    if (max_screens <= 0) return 0;
    WinScreenEnumCtx ctx = { out_x, out_y, out_w, out_h, out_wx, out_wy, out_ww, out_wh, max_screens, 0 };
    EnumDisplayMonitors(NULL, NULL, rad_enum_monitors_proc, (LPARAM)&ctx);
    return ctx.count;
}

void rad_window_set_appearance(void* window_handle, int dark, int vibrancy, int transparent_titlebar) {
    (void)transparent_titlebar;
    if (!window_handle) return;
    HWND hwnd = (HWND)window_handle;
    HMODULE dwm = LoadLibraryA("dwmapi.dll");
    if (!dwm) return;
    typedef HRESULT (WINAPI *DwmSetWindowAttributeFn)(HWND, DWORD, LPCVOID, DWORD);
    DwmSetWindowAttributeFn setAttr = (DwmSetWindowAttributeFn)GetProcAddress(dwm, "DwmSetWindowAttribute");
    if (setAttr) {
        BOOL useDark = dark ? TRUE : FALSE;
        if (FAILED(setAttr(hwnd, 20, &useDark, sizeof(useDark)))) {
            setAttr(hwnd, 19, &useDark, sizeof(useDark));
        }
        int cornerPref = 2; // DWMWCP_ROUND
        setAttr(hwnd, 33, &cornerPref, sizeof(cornerPref));
        if (vibrancy) {
            int backdropType = 2; // DWMSBT_MAINWINDOW (Mica)
            setAttr(hwnd, 38, &backdropType, sizeof(backdropType));
        }
    }
    FreeLibrary(dwm);
}

void rad_window_silence_key_beep(void* window_handle) {
    (void)window_handle;
}

void rad_window_set_opacity(void* window_handle, double opacity) {
    if (!window_handle) return;
    HWND hwnd = (HWND)window_handle;
    double clamped = opacity < 0.1 ? 0.1 : (opacity > 1.0 ? 1.0 : opacity);
    LONG ex = GetWindowLong(hwnd, GWL_EXSTYLE);
    SetWindowLong(hwnd, GWL_EXSTYLE, ex | WS_EX_LAYERED);
    SetLayeredWindowAttributes(hwnd, 0, (BYTE)(clamped * 255.0), LWA_ALPHA);
}

void rad_window_set_min_size(void* window_handle, int min_w, int min_h) {
    (void)window_handle; (void)min_w; (void)min_h;
}

void rad_window_set_max_size(void* window_handle, int max_w, int max_h) {
    (void)window_handle; (void)max_w; (void)max_h;
}

void rad_window_set_resizable(void* window_handle, int resizable) {
    if (!window_handle) return;
    HWND hwnd = (HWND)window_handle;
    LONG style = GetWindowLong(hwnd, GWL_STYLE);
    if (resizable) style |= (WS_THICKFRAME | WS_MAXIMIZEBOX);
    else style &= ~(WS_THICKFRAME | WS_MAXIMIZEBOX);
    SetWindowLong(hwnd, GWL_STYLE, style);
}

void rad_window_set_borderless(void* window_handle, int borderless) {
    if (!window_handle) return;
    HWND hwnd = (HWND)window_handle;
    LONG style = GetWindowLong(hwnd, GWL_STYLE);
    if (borderless) style &= ~WS_OVERLAPPEDWINDOW;
    else style |= WS_OVERLAPPEDWINDOW;
    SetWindowLong(hwnd, GWL_STYLE, style);
    SetWindowPos(hwnd, NULL, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED);
}

void rad_window_init_shortcuts(void) {}

void rad_window_quit(void) {
    PostQuitMessage(0);
    ExitProcess(0);
}

#else

void rad_window_set_always_on_top(void* window_handle, int on_top) { (void)window_handle; (void)on_top; }
int rad_window_is_always_on_top(void* window_handle) { (void)window_handle; return 0; }
void rad_window_toggle_fullscreen(void* window_handle) { (void)window_handle; }
void rad_window_set_fullscreen(void* window_handle, int fullscreen) { (void)window_handle; (void)fullscreen; }
void rad_window_minimize(void* window_handle) { (void)window_handle; }
void rad_window_hide(void* window_handle) { (void)window_handle; }
void rad_window_show(void* window_handle) { (void)window_handle; }
void rad_window_focus(void* window_handle) { (void)window_handle; }
void rad_window_center(void* window_handle) { (void)window_handle; }
void rad_window_set_position(void* window_handle, const char* preset) { (void)window_handle; (void)preset; }
void rad_window_get_screen_size(int* out_width, int* out_height) {
    if (out_width) *out_width = 1920;
    if (out_height) *out_height = 1080;
}
void rad_window_set_bounds(void* window_handle, int x, int y, int w, int h, int animate) {
    (void)window_handle; (void)x; (void)y; (void)w; (void)h; (void)animate;
}
void rad_window_maximize(void* window_handle) { (void)window_handle; }
void rad_window_unmaximize(void* window_handle) { (void)window_handle; }
int rad_window_is_maximized(void* window_handle) { (void)window_handle; return 0; }
int rad_window_is_fullscreen(void* window_handle) { (void)window_handle; return 0; }
int rad_window_get_frame(void* window_handle, int* out_x, int* out_y, int* out_w, int* out_h, int* out_maximized, int* out_fullscreen) {
    (void)window_handle; (void)out_x; (void)out_y; (void)out_w; (void)out_h; (void)out_maximized; (void)out_fullscreen;
    return 0;
}
int rad_window_get_screens(int* out_x, int* out_y, int* out_w, int* out_h, int* out_wx, int* out_wy, int* out_ww, int* out_wh, int max_screens) {
    (void)out_x; (void)out_y; (void)out_w; (void)out_h; (void)out_wx; (void)out_wy; (void)out_ww; (void)out_wh; (void)max_screens;
    return 0;
}
void rad_window_set_appearance(void* window_handle, int dark, int vibrancy, int transparent_titlebar) {
    (void)window_handle; (void)dark; (void)vibrancy; (void)transparent_titlebar;
}
void rad_window_silence_key_beep(void* window_handle) { (void)window_handle; }
void rad_window_set_opacity(void* window_handle, double opacity) { (void)window_handle; (void)opacity; }
void rad_window_set_min_size(void* window_handle, int min_w, int min_h) { (void)window_handle; (void)min_w; (void)min_h; }
void rad_window_set_max_size(void* window_handle, int max_w, int max_h) { (void)window_handle; (void)max_w; (void)max_h; }
void rad_window_set_resizable(void* window_handle, int resizable) { (void)window_handle; (void)resizable; }
void rad_window_set_borderless(void* window_handle, int borderless) { (void)window_handle; (void)borderless; }
void rad_window_init_shortcuts(void) {}
void rad_window_quit(void) { exit(0); }

#endif

#import <Cocoa/Cocoa.h>
#import <CoreGraphics/CoreGraphics.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
        NSArray *windows = (__bridge NSArray *)windowList;
        for (NSDictionary *info in windows) {
            NSNumber *pid = info[(id)kCGWindowOwnerPID];
            NSString *owner = info[(id)kCGWindowOwnerName];
            NSString *name = info[(id)kCGWindowName] ? info[(id)kCGWindowName] : @"";
            NSDictionary *bounds = info[(id)kCGWindowBounds];
            NSNumber *wid = info[(id)kCGWindowNumber];
            if (bounds) {
                double x = [bounds[@"X"] doubleValue];
                double y = [bounds[@"Y"] doubleValue];
                double w = [bounds[@"Width"] doubleValue];
                double h = [bounds[@"Height"] doubleValue];
                if (w > 100 && h > 100) {  // Only actual windows
                    printf("PID: %d | Owner: %s | Window: %s | ID: %d | Rect: %d,%d,%d,%d\n",
                           [pid intValue], [owner UTF8String], [name UTF8String], [wid intValue], (int)x, (int)y, (int)w, (int)h);
                }
            }
        }
        CFRelease(windowList);
    }
    return 0;
}

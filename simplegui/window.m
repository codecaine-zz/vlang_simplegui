#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <QuartzCore/QuartzCore.h>
#import <string.h>
#import <stdlib.h>
#import "window.h"

typedef struct string {
  char *str;
  int len;
  int is_lit;
} string;

typedef struct main__WindowParams {
  string title;
  int width;
  int height;
  void *win_ptr;
  int padding;
  int spacing;
  int always_on_top;
  int responsive_layout;
  int resizable;
  int minimizable;
  int maximizable;
  int closable;
  int has_shadow;
  int movable_by_window_background;
  int titlebar_visible;
  int title_visible;
} main__WindowParams;

typedef struct main__WindowInfo {
  void *app;
  void *app_delegate;
} main__WindowInfo;

static NSString *nsstring(const char *s) {
  if (!s) {
    s = "";
  }
  return [[NSString alloc] initWithBytes:s length:strlen(s) encoding:NSUTF8StringEncoding];
}

static NSLayoutConstraint *findWidthConstraint(NSView *view) {
  if (!view) return nil;
  for (NSLayoutConstraint *constraint in view.constraints) {
    if (constraint.firstAttribute == NSLayoutAttributeWidth && constraint.relation == NSLayoutRelationEqual) {
      if (constraint.firstItem == view && [constraint isMemberOfClass:[NSLayoutConstraint class]]) {
        return constraint;
      }
    }
  }
  if (view.superview) {
    for (NSLayoutConstraint *constraint in view.superview.constraints) {
      if (constraint.firstAttribute == NSLayoutAttributeWidth && constraint.relation == NSLayoutRelationEqual) {
        if (constraint.firstItem == view && [constraint isMemberOfClass:[NSLayoutConstraint class]]) {
          return constraint;
        }
      }
    }
  }
  return nil;
}

static NSLayoutConstraint *findHeightConstraint(NSView *view) {
  if (!view) return nil;
  for (NSLayoutConstraint *constraint in view.constraints) {
    if (constraint.firstAttribute == NSLayoutAttributeHeight && constraint.relation == NSLayoutRelationEqual) {
      if (constraint.firstItem == view && [constraint isMemberOfClass:[NSLayoutConstraint class]]) {
        return constraint;
      }
    }
  }
  if (view.superview) {
    for (NSLayoutConstraint *constraint in view.superview.constraints) {
      if (constraint.firstAttribute == NSLayoutAttributeHeight && constraint.relation == NSLayoutRelationEqual) {
        if (constraint.firstItem == view && [constraint isMemberOfClass:[NSLayoutConstraint class]]) {
          return constraint;
        }
      }
    }
  }
  return nil;
}

static NSVisualEffectMaterial materialFromString(NSString *materialStr);

@interface SimpleCollectionItem : NSCollectionViewItem
@property (nonatomic, strong) NSImageView *customImageView;
@property (nonatomic, strong) NSTextField *customLabel;
@end

@implementation SimpleCollectionItem
- (void)loadView {
  self.view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 100, 100)];
  self.view.wantsLayer = YES;
  self.view.layer.cornerRadius = 8.0;
  self.view.layer.borderWidth = 1.0;
  self.view.layer.borderColor = [[NSColor separatorColor] CGColor];
  self.view.layer.backgroundColor = [[NSColor controlBackgroundColor] CGColor];
  
  CGFloat w = self.view.bounds.size.width;
  CGFloat h = self.view.bounds.size.height;
  
  self.customImageView = [[NSImageView alloc] initWithFrame:NSMakeRect(5, 25, w - 10, h - 30)];
  [self.customImageView setImageScaling:NSImageScaleProportionallyUpOrDown];
  [self.view addSubview:self.customImageView];
  
  self.customLabel = [NSTextField labelWithString:@""];
  [self.customLabel setFrame:NSMakeRect(2, 2, w - 4, 20)];
  [self.customLabel setAlignment:NSTextAlignmentCenter];
  [self.customLabel setFont:[NSFont systemFontOfSize:11]];
  [self.view addSubview:self.customLabel];
}
@end

@interface DrawingCommand : NSObject
@property (nonatomic, assign) int type; // 0 = line, 1 = rect, 2 = circle
@property (nonatomic, assign) double x1, y1, x2, y2;
@property (nonatomic, strong) NSColor *color;
@property (nonatomic, assign) double strokeWidth;
@property (nonatomic, assign) BOOL fill;
@end

@implementation DrawingCommand
@end

@interface CanvasView : NSView
@property (nonatomic, strong) NSMutableArray<DrawingCommand *> *commands;
@end

@implementation CanvasView
- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    _commands = [[NSMutableArray alloc] init];
  }
  return self;
}
- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
  [[NSColor textBackgroundColor] setFill];
  NSRectFill(self.bounds);
  
  [[NSColor separatorColor] setStroke];
  NSBezierPath *borderPath = [NSBezierPath bezierPathWithRect:self.bounds];
  [borderPath setLineWidth:1.0];
  [borderPath stroke];
  
  for (DrawingCommand *cmd in self.commands) {
    if (cmd.type == 0) { // Line
      [cmd.color setStroke];
      NSBezierPath *path = [NSBezierPath bezierPath];
      [path moveToPoint:NSMakePoint(cmd.x1, cmd.y1)];
      [path lineToPoint:NSMakePoint(cmd.x2, cmd.y2)];
      [path setLineWidth:cmd.strokeWidth];
      [path stroke];
    } else if (cmd.type == 1) { // Rect
      NSRect r = NSMakeRect(cmd.x1, cmd.y1, cmd.x2, cmd.y2);
      if (cmd.fill) {
        [cmd.color setFill];
        NSRectFill(r);
      } else {
        [cmd.color setStroke];
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:r];
        [path setLineWidth:cmd.strokeWidth];
        [path stroke];
      }
    } else if (cmd.type == 2) { // Circle
      NSRect r = NSMakeRect(cmd.x1 - cmd.x2, cmd.y1 - cmd.x2, cmd.x2 * 2, cmd.x2 * 2);
      if (cmd.fill) {
        [cmd.color setFill];
        [[NSBezierPath bezierPathWithOvalInRect:r] fill];
      } else {
        [cmd.color setStroke];
        NSBezierPath *path = [NSBezierPath bezierPathWithOvalInRect:r];
        [path setLineWidth:cmd.strokeWidth];
        [path stroke];
      }
    }
  }
}
@end

@interface FlippedStackView : NSStackView
@end

extern void vlang_dispatch_event(void *win_ptr, const char *name, const char *event, const char *value);

@implementation FlippedStackView
- (BOOL)isFlipped {
  return YES;
}
@end

@interface DropZoneView : NSBox
@property (nonatomic, assign) void *win_ptr;
@property (nonatomic, copy) NSString *controlName;
@end

@implementation DropZoneView
- (void)awakeFromNib {
  [super awakeFromNib];
  [self registerForDraggedTypes:@[NSPasteboardTypeFileURL]];
}

- (void)updateTrackingAreas {
  [super updateTrackingAreas];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
  NSPasteboard *pboard = [sender draggingPasteboard];
  if ([[pboard types] containsObject:NSPasteboardTypeFileURL]) {
    return NSDragOperationCopy;
  }
  return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
  NSPasteboard *pboard = [sender draggingPasteboard];
  if ([[pboard types] containsObject:NSPasteboardTypeFileURL]) {
    NSArray *urls = [pboard readObjectsForClasses:@[[NSURL class]] options:nil];
    NSMutableArray *paths = [NSMutableArray array];
    for (NSURL *url in urls) {
      [paths addObject:[url path]];
    }
    if (self.win_ptr && self.controlName) {
      NSString *joinedPaths = [paths componentsJoinedByString:@"|"];
      vlang_dispatch_event(self.win_ptr, [self.controlName UTF8String], "file_drop", [joinedPaths UTF8String]);
    }
    return YES;
  }
  return NO;
}
@end

@interface ModernTextFieldCell : NSTextFieldCell
@end

@implementation ModernTextFieldCell
- (NSRect)drawingRectForBounds:(NSRect)rect {
  NSRect titleRect = [super drawingRectForBounds:rect];
  CGFloat horizontalPadding = 10.0;
  CGFloat verticalPadding = (titleRect.size.height - 18.0) / 2.0;
  if (verticalPadding < 0) verticalPadding = 2.0;
  return NSMakeRect(titleRect.origin.x + horizontalPadding,
                    titleRect.origin.y + verticalPadding,
                    titleRect.size.width - (horizontalPadding * 2.0),
                    titleRect.size.height - (verticalPadding * 2.0));
}
- (void)selectWithFrame:(NSRect)rect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {
  NSRect textFrame = [self drawingRectForBounds:rect];
  [super selectWithFrame:textFrame inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
}
- (void)editWithFrame:(NSRect)rect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent {
  NSRect textFrame = [self drawingRectForBounds:rect];
  [super editWithFrame:textFrame inView:controlView editor:textObj delegate:anObject event:theEvent];
}
@end

@interface ModernSecureTextFieldCell : NSSecureTextFieldCell
@end

@implementation ModernSecureTextFieldCell
- (NSRect)drawingRectForBounds:(NSRect)rect {
  NSRect titleRect = [super drawingRectForBounds:rect];
  CGFloat horizontalPadding = 10.0;
  CGFloat verticalPadding = (titleRect.size.height - 18.0) / 2.0;
  if (verticalPadding < 0) verticalPadding = 2.0;
  return NSMakeRect(titleRect.origin.x + horizontalPadding,
                    titleRect.origin.y + verticalPadding,
                    titleRect.size.width - (horizontalPadding * 2.0),
                    titleRect.size.height - (verticalPadding * 2.0));
}
- (void)selectWithFrame:(NSRect)rect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {
  NSRect textFrame = [self drawingRectForBounds:rect];
  [super selectWithFrame:textFrame inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
}
- (void)editWithFrame:(NSRect)rect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent {
  NSRect textFrame = [self drawingRectForBounds:rect];
  [super editWithFrame:textFrame inView:controlView editor:textObj delegate:anObject event:theEvent];
}
@end

@interface ModernTextField : NSTextField
@end

@implementation ModernTextField
- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    ModernTextFieldCell *cell = [[ModernTextFieldCell alloc] init];
    [cell setEditable:YES];
    [cell setSelectable:YES];
    [cell setScrollable:YES];
    [cell setDrawsBackground:YES];
    self.cell = cell;
    self.wantsLayer = YES;
    self.layer.cornerRadius = 8.0;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [NSColor separatorColor].CGColor;
    self.focusRingType = NSFocusRingTypeNone;
  }
  return self;
}
- (void)layout {
  [super layout];
  NSColor *bgColor = self.backgroundColor ?: [NSColor textBackgroundColor];
  self.layer.backgroundColor = bgColor.CGColor;
  BOOL hasFocus = NO;
  if (self.window && self.window.firstResponder) {
    id responder = self.window.firstResponder;
    if ([responder isKindOfClass:[NSView class]] && [(NSView *)responder isDescendantOf:self]) {
      hasFocus = YES;
    }
  }
  if (hasFocus) {
    self.layer.borderColor = [NSColor controlAccentColor].CGColor;
    self.layer.borderWidth = 1.5;
    self.layer.shadowColor = [NSColor controlAccentColor].CGColor;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowRadius = 3.0;
    self.layer.shadowOpacity = 0.35;
    self.layer.masksToBounds = NO;
  } else {
    self.layer.borderColor = [NSColor separatorColor].CGColor;
    self.layer.borderWidth = 1.0;
    self.layer.shadowColor = nil;
    self.layer.shadowOpacity = 0.0;
  }
}
- (BOOL)becomeFirstResponder {
  BOOL result = [super becomeFirstResponder];
  [self setNeedsLayout:YES];
  return result;
}
- (BOOL)resignFirstResponder {
  BOOL result = [super resignFirstResponder];
  [self setNeedsLayout:YES];
  return result;
}
@end

@interface ModernSecureTextField : NSSecureTextField
@end

@implementation ModernSecureTextField
- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    ModernSecureTextFieldCell *cell = [[ModernSecureTextFieldCell alloc] init];
    [cell setEditable:YES];
    [cell setSelectable:YES];
    [cell setScrollable:YES];
    [cell setDrawsBackground:YES];
    self.cell = cell;
    self.wantsLayer = YES;
    self.layer.cornerRadius = 8.0;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [NSColor separatorColor].CGColor;
    self.focusRingType = NSFocusRingTypeNone;
  }
  return self;
}
- (void)layout {
  [super layout];
  NSColor *bgColor = self.backgroundColor ?: [NSColor textBackgroundColor];
  self.layer.backgroundColor = bgColor.CGColor;
  BOOL hasFocus = NO;
  if (self.window && self.window.firstResponder) {
    id responder = self.window.firstResponder;
    if ([responder isKindOfClass:[NSView class]] && [(NSView *)responder isDescendantOf:self]) {
      hasFocus = YES;
    }
  }
  if (hasFocus) {
    self.layer.borderColor = [NSColor controlAccentColor].CGColor;
    self.layer.borderWidth = 1.5;
    self.layer.shadowColor = [NSColor controlAccentColor].CGColor;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowRadius = 3.0;
    self.layer.shadowOpacity = 0.35;
    self.layer.masksToBounds = NO;
  } else {
    self.layer.borderColor = [NSColor separatorColor].CGColor;
    self.layer.borderWidth = 1.0;
    self.layer.shadowColor = nil;
    self.layer.shadowOpacity = 0.0;
  }
}
- (BOOL)becomeFirstResponder {
  BOOL result = [super becomeFirstResponder];
  [self setNeedsLayout:YES];
  return result;
}
- (BOOL)resignFirstResponder {
  BOOL result = [super resignFirstResponder];
  [self setNeedsLayout:YES];
  return result;
}
@end

@interface ModernSearchFieldCell : NSSearchFieldCell
@end

@implementation ModernSearchFieldCell
- (NSRect)drawingRectForBounds:(NSRect)rect {
  NSRect titleRect = [super drawingRectForBounds:rect];
  CGFloat horizontalPadding = 0.0;
  CGFloat verticalPadding = (titleRect.size.height - 18.0) / 2.0;
  if (verticalPadding < 0) verticalPadding = 2.0;
  return NSMakeRect(titleRect.origin.x + horizontalPadding,
                    titleRect.origin.y + verticalPadding,
                    titleRect.size.width - (horizontalPadding * 2.0),
                    titleRect.size.height - (verticalPadding * 2.0));
}
- (void)selectWithFrame:(NSRect)rect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength {
  NSRect textFrame = [self drawingRectForBounds:rect];
  [super selectWithFrame:textFrame inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
}
- (void)editWithFrame:(NSRect)rect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent {
  NSRect textFrame = [self drawingRectForBounds:rect];
  [super editWithFrame:textFrame inView:controlView editor:textObj delegate:anObject event:theEvent];
}
@end

@interface ModernSearchField : NSSearchField
@end

@implementation ModernSearchField
- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    ModernSearchFieldCell *cell = [[ModernSearchFieldCell alloc] init];
    [cell setEditable:YES];
    [cell setSelectable:YES];
    [cell setScrollable:YES];
    [cell setDrawsBackground:YES];
    self.cell = cell;
    self.wantsLayer = YES;
    self.layer.cornerRadius = 8.0;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [NSColor separatorColor].CGColor;
    self.focusRingType = NSFocusRingTypeNone;
    
    // Bind the clear/cancel button cell to trigger the event action
    NSButtonCell *cancelButtonCell = [cell cancelButtonCell];
    [cancelButtonCell setTarget:self];
    [cancelButtonCell setAction:@selector(handleCancelButtonClicked:)];
  }
  return self;
}

- (void)handleCancelButtonClicked:(id)sender {
  [self setStringValue:@""];
  [self resignFirstResponder];
  if (self.target && self.action) {
    [self sendAction:self.action to:self.target];
  }
}

- (void)layout {
  [super layout];
  NSColor *bgColor = self.backgroundColor ?: [NSColor textBackgroundColor];
  self.layer.backgroundColor = bgColor.CGColor;
  BOOL hasFocus = NO;
  if (self.window && self.window.firstResponder) {
    id responder = self.window.firstResponder;
    if ([responder isKindOfClass:[NSView class]] && [(NSView *)responder isDescendantOf:self]) {
      hasFocus = YES;
    }
  }
  if (hasFocus) {
    self.layer.borderColor = [NSColor controlAccentColor].CGColor;
    self.layer.borderWidth = 1.5;
    self.layer.shadowColor = [NSColor controlAccentColor].CGColor;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowRadius = 3.0;
    self.layer.shadowOpacity = 0.35;
    self.layer.masksToBounds = NO;
  } else {
    self.layer.borderColor = [NSColor separatorColor].CGColor;
    self.layer.borderWidth = 1.0;
    self.layer.shadowColor = nil;
    self.layer.shadowOpacity = 0.0;
  }
}
- (BOOL)becomeFirstResponder {
  BOOL result = [super becomeFirstResponder];
  [self setNeedsLayout:YES];
  return result;
}
- (BOOL)resignFirstResponder {
  BOOL result = [super resignFirstResponder];
  [self setNeedsLayout:YES];
  return result;
}
@end

@interface TreeItem : NSObject
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) TreeItem *parent;
@property (nonatomic, retain) NSMutableArray<TreeItem *> *children;
@end

@implementation TreeItem
- (instancetype)init {
  self = [super init];
  if (self) {
    _children = [[NSMutableArray alloc] init];
  }
  return self;
}
- (void)dealloc {
  [_itemId release];
  [_text release];
  [_children release];
  [super dealloc];
}
@end
@class AppDelegate;

@interface ShortcutRecorder : NSTextField
@property (nonatomic, retain) NSString *shortcutString;
@property (nonatomic, retain) NSString *displayString;
@property (nonatomic, assign) id appDelegate;
@end
@interface ChartView : NSView
@property (nonatomic, retain) NSMutableArray *dataPoints;
@property (nonatomic, retain) NSColor *lineColor;
@property (nonatomic, copy) NSString *chartType;
@end

@interface CircularProgressView : NSView
@property (nonatomic, assign) double value;
@property (nonatomic, assign) double minValue;
@property (nonatomic, assign) double maxValue;
@property (nonatomic, retain) NSColor *progressColor;
@end

@interface ColorGridView : NSView
@property (nonatomic, retain) NSArray *colors;
@property (nonatomic, retain) NSArray *colorHexStrings;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) NSInteger hoveredIndex;
@property (nonatomic, assign) id appDelegate;
@end

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, NSTextFieldDelegate, NSTextViewDelegate, NSTableViewDataSource, NSTableViewDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate, NSTabViewDelegate, NSToolbarDelegate, NSCollectionViewDataSource, NSCollectionViewDelegate>
@property (nonatomic, assign) main__WindowParams params;
@property (nonatomic, assign) void *win_ptr;
@property (nonatomic, strong) NSWindow *window;
@property (nonatomic, strong) NSWindowController *windowController;
@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) NSStackView *mainStackView;
@property (nonatomic, strong) NSStackView *currentRowStack;
@property (nonatomic, strong) NSMutableDictionary *controlsByName;
@property (nonatomic, strong) NSMutableDictionary *listItemsByName;
@property (nonatomic, strong) NSMutableDictionary *tableItemsByName;
@property (nonatomic, strong) NSMutableDictionary *gridItemsByName;
@property (nonatomic, strong) NSMutableDictionary *gridHeadersByName;
@property (nonatomic, strong) NSMutableDictionary *gridColumnTypesByName;
@property (nonatomic, strong) NSMutableDictionary *gridVisibleRowIndexesByName;
@property (nonatomic, strong) NSMutableDictionary *gridSelectionByName;
@property (nonatomic, strong) NSMutableDictionary *gridSortDescriptorsByName;
@property (nonatomic, strong) NSMutableDictionary *gridReadOnlyCellsByName;
@property (nonatomic, strong) NSMutableDictionary *gridReadOnlyRowsByName;
@property (nonatomic, strong) NSMutableDictionary *gridReadOnlyColsByName;
@property (nonatomic, strong) NSMutableDictionary *gridDisabledCellsByName;
@property (nonatomic, strong) NSMutableDictionary *gridDisabledRowsByName;
@property (nonatomic, strong) NSMutableDictionary *gridDisabledColsByName;
@property (nonatomic, strong) NSMutableDictionary *gridRowHeightsByName;
@property (nonatomic, strong) NSMutableDictionary *gridFiltersByName;
@property (nonatomic, strong) NSMutableDictionary *treeItemsByName;
@property (nonatomic, strong) NSMutableDictionary *linkUrls;
@property (nonatomic, strong) NSColor *currentBackgroundColor;
@property (nonatomic, strong) NSColor *currentFontColor;
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) NSMenu *statusBarMenu;
@property (nonatomic, assign) BOOL responsiveLayoutEnabled;
@property (nonatomic, strong) NSMutableDictionary *toolbarItems;
@property (nonatomic, strong) NSMutableArray *toolbarOrder;
@property (nonatomic, strong) NSMenu *dockMenu;

// Split View, Collection Grid, Canvas properties
@property (nonatomic, strong) NSSplitView *currentSplitView;
@property (nonatomic, strong) NSStackView *currentSplitPane;
@property (nonatomic, strong) NSMutableArray<NSStackView *> *splitPanes;
@property (nonatomic, assign) int activeSplitPaneIndex;
@property (nonatomic, strong) NSMutableDictionary *collectionItemsByName;
@property (nonatomic, strong) NSStackView *currentGlassBoxStack;

- (void)beginSplitViewWithName:(NSString *)name vertical:(BOOL)vertical;
- (void)splitViewNextPane;
- (void)endSplitView;
- (NSView *)makeCollectionViewWithName:(NSString *)name itemWidth:(int)itemWidth itemHeight:(int)itemHeight;
- (NSView *)makeCalendarWithName:(NSString *)name date:(NSString *)dateString;
- (NSView *)makeCanvasWithName:(NSString *)name height:(int)height;
- (void)beginGlassBoxWithName:(NSString *)name material:(NSString *)material;
- (void)endGlassBox;
- (NSView *)makeBadgeWithName:(NSString *)name text:(NSString *)text style:(NSString *)style;
- (NSView *)makeIconSegmentsWithName:(NSString *)name symbols:(NSArray<NSString *> *)symbols selected:(NSString *)selected;
- (NSView *)makeConsoleWithName:(NSString *)name height:(int)height;
- (NSView *)makeChartViewWithName:(NSString *)name chartType:(NSString *)chartType height:(int)height;
- (NSView *)makeShortcutRecorderWithName:(NSString *)name;
- (NSView *)makeCircularProgressWithName:(NSString *)name value:(double)value minVal:(double)minVal maxVal:(double)maxVal;
- (NSView *)makeBreadcrumbsWithName:(NSString *)name segments:(NSArray<NSString *> *)segments;
- (void)handleBreadcrumbClicked:(id)sender;
- (NSView *)makePropertyGridWithName:(NSString *)name keys:(NSArray<NSString *> *)keys values:(NSArray<NSString *> *)values;
- (NSView *)makeColorGridWithName:(NSString *)name colors:(NSArray<NSString *> *)colors;


- (void)setupToolbar;
- (void)handleToolbarItemClicked:(id)sender;
- (TreeItem *)findTreeItemWithId:(NSString *)targetId inItems:(NSArray<TreeItem *> *)items;
- (NSString *)nameForControl:(NSView *)control;
- (void)addControlToLayout:(NSView *)view;
- (void)beginRowWithName:(NSString *)name;
- (void)endRow;
- (void)applyColorsRecursively:(NSView *)view backgroundColor:(NSColor *)backgroundColor fontColor:(NSColor *)fontColor;
- (NSView *)makeLabelWithName:(NSString *)name text:(NSString *)text;
- (NSView *)makeTextFieldWithName:(NSString *)name value:(NSString *)value;
- (NSView *)makePasswordFieldWithName:(NSString *)name value:(NSString *)value;
- (NSView *)makeTextAreaWithName:(NSString *)name value:(NSString *)value;
- (NSView *)makeHtmlViewWithName:(NSString *)name html:(NSString *)html;
- (NSView *)makeDropZoneWithName:(NSString *)name label:(NSString *)label;
- (NSView *)makeButtonWithName:(NSString *)name title:(NSString *)title;
- (NSView *)makeLinkWithName:(NSString *)name text:(NSString *)text url:(NSString *)urlStr;
- (NSView *)makeCheckboxWithName:(NSString *)name label:(NSString *)label checked:(BOOL)checked;
- (NSView *)makeDisclosureButtonWithName:(NSString *)name title:(NSString *)title state:(BOOL)open;
- (NSView *)makeNumberFieldWithName:(NSString *)name value:(int)value;
- (NSView *)makeSliderWithName:(NSString *)name value:(int)value;
- (NSView *)makePopUpButtonWithName:(NSString *)name selected:(NSString *)selected;
- (NSView *)makeColorWellWithName:(NSString *)name color:(NSString *)colorString;
- (NSView *)makeDatePickerWithName:(NSString *)name date:(NSString *)dateString;
- (NSView *)makeSegmentedControlWithName:(NSString *)name selected:(NSString *)selected;
- (NSView *)makeProgressIndicatorWithName:(NSString *)name value:(int)value;
- (NSView *)makeDropdownWithName:(NSString *)name items:(NSArray<NSString *> *)items selected:(NSString *)selected;
- (NSView *)makeSegmentedControlWithName:(NSString *)name items:(NSArray<NSString *> *)items selected:(NSString *)selected;
- (NSView *)makeRadioGroupWithName:(NSString *)name items:(NSArray<NSString *> *)items selected:(NSString *)selected;
- (NSView *)makeSwitchWithName:(NSString *)name label:(NSString *)label checked:(BOOL)checked;
- (NSView *)makeSearchFieldWithName:(NSString *)name placeholder:(NSString *)placeholder;
- (NSView *)makeComboBoxWithName:(NSString *)name items:(NSArray<NSString *> *)items selected:(NSString *)selected;
- (NSView *)makeLevelIndicatorWithName:(NSString *)name style:(int)style minValue:(double)minValue maxValue:(double)maxValue value:(double)value;
- (NSView *)makeSpinnerWithName:(NSString *)name active:(BOOL)active;
- (NSView *)makePathControlWithName:(NSString *)name path:(NSString *)pathString;
- (NSView *)makeTokenFieldWithName:(NSString *)name value:(NSString *)value;
- (NSView *)makeStepperWithName:(NSString *)name minValue:(double)minValue maxValue:(double)maxValue step:(double)step value:(double)value;
- (NSView *)makeHelpButtonWithName:(NSString *)name;
- (NSView *)makeKnobWithName:(NSString *)name minValue:(double)minValue maxValue:(double)maxValue value:(double)value;
- (NSView *)makePullDownWithName:(NSString *)name title:(NSString *)title items:(NSArray<NSString *> *)items;
- (NSView *)makeImageButtonWithName:(NSString *)name symbol:(NSString *)symbolName title:(NSString *)title;
- (void)handleRadioChanged:(id)sender;
- (void)handleSwitchChanged:(id)sender;
- (void)handleListDoubleClick:(id)sender;
- (void)setupMenuBar;
- (NSMenu *)findOrCreateMenuWithName:(NSString *)menuName;
- (void)handleMenuItemClicked:(id)sender;
@end

@implementation ShortcutRecorder
- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    ModernTextFieldCell *cell = [[ModernTextFieldCell alloc] init];
    [cell setEditable:NO];
    [cell setSelectable:NO];
    [cell setScrollable:YES];
    [cell setDrawsBackground:YES];
    self.cell = cell;
    [cell release];
    self.wantsLayer = YES;
    self.layer.cornerRadius = 8.0;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [NSColor separatorColor].CGColor;
    self.focusRingType = NSFocusRingTypeNone;
    
    _shortcutString = [[NSString alloc] initWithString:@""];
    _displayString = [[NSString alloc] initWithString:@"Press shortcut..."];
    [self setStringValue:_displayString];
    [self setAlignment:NSTextAlignmentCenter];
  }
  return self;
}
- (void)dealloc {
  [_shortcutString release];
  [_displayString release];
  [super dealloc];
}
- (void)layout {
  [super layout];
  NSColor *bgColor = self.backgroundColor ?: [NSColor textBackgroundColor];
  self.layer.backgroundColor = bgColor.CGColor;
  BOOL hasFocus = NO;
  if (self.window && self.window.firstResponder) {
    id responder = self.window.firstResponder;
    if (responder == self) {
      hasFocus = YES;
    }
  }
  if (hasFocus) {
    self.layer.borderColor = [NSColor controlAccentColor].CGColor;
    self.layer.borderWidth = 1.5;
    self.layer.shadowColor = [NSColor controlAccentColor].CGColor;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowRadius = 3.0;
    self.layer.shadowOpacity = 0.35;
    self.layer.masksToBounds = NO;
  } else {
    self.layer.borderColor = [NSColor separatorColor].CGColor;
    self.layer.borderWidth = 1.0;
    self.layer.shadowColor = nil;
    self.layer.shadowOpacity = 0.0;
  }
}
- (BOOL)becomeFirstResponder {
  BOOL result = [super becomeFirstResponder];
  [self setNeedsLayout:YES];
  if (result) {
    self.displayString = @"Press keys...";
    [self setStringValue:self.displayString];
  }
  return result;
}
- (BOOL)resignFirstResponder {
  BOOL result = [super resignFirstResponder];
  [self setNeedsLayout:YES];
  if (self.shortcutString.length == 0) {
    self.displayString = @"Press shortcut...";
    [self setStringValue:self.displayString];
  } else {
    [self setStringValue:self.displayString];
  }
  return result;
}
- (BOOL)acceptsFirstResponder {
  return YES;
}
- (void)keyDown:(NSEvent *)event {
  NSEventModifierFlags flags = [event modifierFlags];
  unsigned short keyCode = [event keyCode];
  NSString *chars = [event charactersIgnoringModifiers];
  
  if (keyCode == 53) { // Escape
    self.shortcutString = @"";
    self.displayString = @"Press shortcut...";
    [self setStringValue:self.displayString];
    [self dispatchChangeEvent];
    [self.window makeFirstResponder:nil];
    return;
  }
  if (keyCode == 48 || keyCode == 49 || keyCode == 51 ||
      keyCode == 54 || keyCode == 55 || keyCode == 56 || keyCode == 57 ||
      keyCode == 58 || keyCode == 59 || keyCode == 60 || keyCode == 61 || keyCode == 62 || keyCode == 63) {
    return;
  }
  NSMutableString *disp = [NSMutableString string];
  NSMutableString *code = [NSMutableString string];
  if (flags & NSEventModifierFlagControl) {
    [disp appendString:@"⌃"];
    [code appendString:@"ctrl+"];
  }
  if (flags & NSEventModifierFlagOption) {
    [disp appendString:@"⌥"];
    [code appendString:@"opt+"];
  }
  if (flags & NSEventModifierFlagShift) {
    [disp appendString:@"⇧"];
    [code appendString:@"shift+"];
  }
  if (flags & NSEventModifierFlagCommand) {
    [disp appendString:@"⌘"];
    [code appendString:@"cmd+"];
  }
  NSString *keyChar = [chars uppercaseString];
  if (keyChar.length > 0) {
    [disp appendString:keyChar];
    [code appendString:[chars lowercaseString]];
    self.shortcutString = code;
    self.displayString = disp;
    [self setStringValue:self.displayString];
    [self dispatchChangeEvent];
    [self.window makeFirstResponder:nil];
  }
}
- (void)dispatchChangeEvent {
  AppDelegate *del = (AppDelegate *)self.appDelegate;
  NSString *name = [del nameForControl:self];
  if (name && del.win_ptr) {
    vlang_dispatch_event(del.win_ptr, [name UTF8String], "change", [self.shortcutString UTF8String]);
  }
}
- (BOOL)performKeyEquivalent:(NSEvent *)event {
  [self keyDown:event];
  return YES;
}
@end

@implementation ChartView
- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    _dataPoints = [[NSMutableArray alloc] init];
    _lineColor = [[NSColor colorWithRed:0.0 green:0.6 blue:1.0 alpha:1.0] retain];
    _chartType = [[NSString alloc] initWithString:@"line"];
  }
  return self;
}
- (void)dealloc {
  [_dataPoints release];
  [_lineColor release];
  [_chartType release];
  [super dealloc];
}
- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
  [[NSColor colorWithRed:0.08 green:0.08 blue:0.1 alpha:1.0] setFill];
  NSBezierPath *bgPath = [NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:8.0 yRadius:8.0];
  [bgPath fill];
  [[NSColor colorWithWhite:1.0 alpha:0.1] setStroke];
  [bgPath setLineWidth:1.0];
  [bgPath stroke];
  if (self.dataPoints.count < 2) {
    return;
  }
  NSRect bounds = NSInsetRect(self.bounds, 10, 10);
  CGFloat width = bounds.size.width;
  CGFloat height = bounds.size.height;
  CGFloat xMin = bounds.origin.x;
  CGFloat yMin = bounds.origin.y;
  int gridCount = 4;
  [[NSColor colorWithWhite:1.0 alpha:0.07] setStroke];
  for (int i = 0; i <= gridCount; i++) {
    CGFloat y = yMin + (height / gridCount) * i;
    NSBezierPath *gridPath = [NSBezierPath bezierPath];
    [gridPath moveToPoint:NSMakePoint(xMin, y)];
    [gridPath lineToPoint:NSMakePoint(xMin + width, y)];
    [gridPath setLineWidth:1.0];
    [gridPath stroke];
  }
  double minVal = [[self.dataPoints firstObject] doubleValue];
  double maxVal = minVal;
  for (NSNumber *num in self.dataPoints) {
    double v = [num doubleValue];
    if (v < minVal) minVal = v;
    if (v > maxVal) maxVal = v;
  }
  if (maxVal == minVal) {
    maxVal += 1.0;
    minVal -= 1.0;
  }
  double range = maxVal - minVal;
  int count = (int)self.dataPoints.count;
  NSPoint *points = malloc(sizeof(NSPoint) * count);
  for (int i = 0; i < count; i++) {
    double val = [self.dataPoints[i] doubleValue];
    CGFloat x = xMin + (width / (count - 1)) * i;
    CGFloat y = yMin + ((val - minVal) / range) * height;
    points[i] = NSMakePoint(x, y);
  }
  NSBezierPath *chartPath = [NSBezierPath bezierPath];
  [chartPath moveToPoint:points[0]];
  for (int i = 1; i < count; i++) {
    [chartPath lineToPoint:points[i]];
  }
  NSColor *strokeColor = self.lineColor;
  if ([self.chartType isEqualToString:@"area"]) {
    NSBezierPath *areaPath = [chartPath copy];
    [areaPath lineToPoint:NSMakePoint(points[count - 1].x, yMin)];
    [areaPath lineToPoint:NSMakePoint(points[0].x, yMin)];
    [areaPath closePath];
    NSColor *startColor = [strokeColor colorWithAlphaComponent:0.4];
    NSColor *endColor = [strokeColor colorWithAlphaComponent:0.0];
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor];
    [gradient drawInBezierPath:areaPath angle:270.0];
    [gradient release];
    [areaPath release];
  }
  [strokeColor setStroke];
  [chartPath setLineWidth:2.0];
  [chartPath setLineJoinStyle:NSLineJoinStyleRound];
  [chartPath stroke];
  free(points);
}
@end

@implementation CircularProgressView
- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    _value = 0.0;
    _minValue = 0.0;
    _maxValue = 100.0;
    _progressColor = [[NSColor colorWithRed:0.0 green:0.6 blue:1.0 alpha:1.0] retain];
  }
  return self;
}
- (void)dealloc {
  [_progressColor release];
  [super dealloc];
}
- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
  [[NSColor clearColor] setFill];
  NSRectFill(self.bounds);
  
  NSRect bounds = self.bounds;
  CGFloat size = MIN(bounds.size.width, bounds.size.height);
  CGFloat strokeWidth = 8.0;
  CGFloat radius = (size - strokeWidth) / 2.0 - 4.0;
  NSPoint center = NSMakePoint(bounds.origin.x + bounds.size.width / 2.0, bounds.origin.y + bounds.size.height / 2.0);
  
  [[NSColor colorWithWhite:1.0 alpha:0.1] setStroke];
  NSBezierPath *trackPath = [NSBezierPath bezierPath];
  [trackPath appendBezierPathWithArcWithCenter:center radius:radius startAngle:0 endAngle:360];
  [trackPath setLineWidth:strokeWidth];
  [trackPath stroke];
  
  double percent = (self.maxValue > self.minValue) ? (self.value - self.minValue) / (self.maxValue - self.minValue) : 0.0;
  if (percent < 0.0) percent = 0.0;
  if (percent > 1.0) percent = 1.0;
  
  if (percent > 0.0) {
    [self.progressColor setStroke];
    NSBezierPath *progressPath = [NSBezierPath bezierPath];
    CGFloat startAngle = 90.0;
    CGFloat endAngle = 90.0 - (percent * 360.0);
    [progressPath appendBezierPathWithArcWithCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [progressPath setLineWidth:strokeWidth];
    [progressPath setLineCapStyle:NSLineCapStyleRound];
    [progressPath stroke];
  }
  
  int displayPercent = (int)(percent * 100.0);
  NSString *text = [NSString stringWithFormat:@"%d%%", displayPercent];
  NSDictionary *attrs = @{
    NSFontAttributeName: [NSFont fontWithName:@"Menlo-Bold" size:radius * 0.5] ?: [NSFont boldSystemFontOfSize:radius * 0.5],
    NSForegroundColorAttributeName: [NSColor textColor]
  };
  NSSize textSize = [text sizeWithAttributes:attrs];
  NSPoint textPos = NSMakePoint(center.x - textSize.width / 2.0, center.y - textSize.height / 2.0);
  [text drawAtPoint:textPos withAttributes:attrs];
}
@end

static NSColor *colorFromHexString(NSString *hexString) {
  NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
  if (cleanString.length == 3) {
    cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                   [cleanString substringWithRange:NSMakeRange(0, 1)], [cleanString substringWithRange:NSMakeRange(0, 1)],
                   [cleanString substringWithRange:NSMakeRange(1, 1)], [cleanString substringWithRange:NSMakeRange(1, 1)],
                   [cleanString substringWithRange:NSMakeRange(2, 1)], [cleanString substringWithRange:NSMakeRange(2, 1)]];
  }
  if (cleanString.length == 6) {
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 16) & 0xFF) / 255.0f;
    float green = ((baseValue >> 8) & 0xFF) / 255.0f;
    float blue = (baseValue & 0xFF) / 255.0f;
    
    return [NSColor colorWithRed:red green:green blue:blue alpha:1.0f];
  }
  return [NSColor grayColor];
}

@implementation ColorGridView
- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    _colors = [[NSArray alloc] init];
    _colorHexStrings = [[NSArray alloc] init];
    _selectedIndex = -1;
    _hoveredIndex = -1;
  }
  return self;
}
- (void)dealloc {
  [_colors release];
  [_colorHexStrings release];
  [super dealloc];
}
- (void)updateTrackingAreas {
  [super updateTrackingAreas];
  for (NSTrackingArea *area in self.trackingAreas) {
    [self removeTrackingArea:area];
  }
  NSTrackingAreaOptions options = NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingInVisibleRect;
  NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:self.bounds options:options owner:self userInfo:nil];
  [self addTrackingArea:area];
  [area release];
}
- (NSInteger)colorIndexAtPoint:(NSPoint)point {
  CGFloat boxSize = 32.0;
  CGFloat spacing = 8.0;
  CGFloat step = boxSize + spacing;
  CGFloat width = self.bounds.size.width;
  int cols = (int)floor((width + spacing) / step);
  if (cols < 1) cols = 1;
  
  CGFloat yFromTop = self.bounds.size.height - point.y;
  int col = (int)floor(point.x / step);
  int row = (int)floor(yFromTop / step);
  
  CGFloat localX = point.x - col * step;
  CGFloat localY = yFromTop - row * step;
  
  if (localX >= 0 && localX <= boxSize && localY >= 0 && localY <= boxSize) {
    NSInteger index = row * cols + col;
    if (index >= 0 && index < self.colorHexStrings.count) {
      return index;
    }
  }
  return -1;
}
- (void)mouseMoved:(NSEvent *)event {
  NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
  NSInteger index = [self colorIndexAtPoint:point];
  if (index != self.hoveredIndex) {
    self.hoveredIndex = index;
    [self setNeedsDisplay:YES];
  }
}
- (void)mouseExited:(NSEvent *)event {
  if (self.hoveredIndex != -1) {
    self.hoveredIndex = -1;
    [self setNeedsDisplay:YES];
  }
}
- (void)mouseDown:(NSEvent *)event {
  NSPoint point = [self convertPoint:[event locationInWindow] fromView:nil];
  NSInteger index = [self colorIndexAtPoint:point];
  if (index >= 0 && index < self.colorHexStrings.count) {
    self.selectedIndex = index;
    [self setNeedsDisplay:YES];
    
    AppDelegate *del = (AppDelegate *)self.appDelegate;
    NSString *name = [del nameForControl:self];
    if (name && del.win_ptr) {
      NSString *hex = self.colorHexStrings[index];
      vlang_dispatch_event(del.win_ptr, [name UTF8String], "change", [hex UTF8String]);
    }
  }
}
- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
  
  [[NSColor clearColor] setFill];
  NSRectFill(self.bounds);
  
  CGFloat boxSize = 32.0;
  CGFloat spacing = 8.0;
  CGFloat step = boxSize + spacing;
  CGFloat width = self.bounds.size.width;
  int cols = (int)floor((width + spacing) / step);
  if (cols < 1) cols = 1;
  
  for (NSUInteger i = 0; i < self.colors.count; i++) {
    int row = (int)(i / cols);
    int col = (int)(i % cols);
    
    CGFloat x = col * step;
    CGFloat y = self.bounds.size.height - (row + 1) * step + spacing;
    
    NSRect boxRect = NSMakeRect(x, y, boxSize, boxSize);
    
    NSColor *color = self.colors[i];
    [color setFill];
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:boxRect xRadius:6.0 yRadius:6.0];
    [path fill];
    
    [[NSColor colorWithWhite:1.0 alpha:0.15] setStroke];
    [path setLineWidth:1.0];
    [path stroke];
    
    if (self.selectedIndex == i) {
      [[NSColor controlAccentColor] setStroke];
      NSBezierPath *selPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(boxRect, -2.5, -2.5) xRadius:8.0 yRadius:8.0];
      [selPath setLineWidth:2.0];
      [selPath stroke];
    } else if (self.hoveredIndex == i) {
      [[NSColor colorWithWhite:1.0 alpha:0.4] setStroke];
      NSBezierPath *hovPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(boxRect, -1.5, -1.5) xRadius:7.5 yRadius:7.5];
      [hovPath setLineWidth:1.5];
      [hovPath stroke];
    }
  }
}
@end

@interface CustomWindow : NSWindow
@end

@implementation CustomWindow
- (BOOL)performKeyEquivalent:(NSEvent *)event {
  NSEventModifierFlags flags = [event modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask;
  NSString *chars = [event charactersIgnoringModifiers];
  
  AppDelegate *delegate = (AppDelegate *)[self delegate];
  if (delegate && delegate.win_ptr) {
    NSMutableString *keyStr = [NSMutableString string];
    if (flags & NSEventModifierFlagCommand) [keyStr appendString:@"cmd+"];
    if (flags & NSEventModifierFlagControl) [keyStr appendString:@"ctrl+"];
    if (flags & NSEventModifierFlagOption) [keyStr appendString:@"opt+"];
    if (flags & NSEventModifierFlagShift) [keyStr appendString:@"shift+"];
    [keyStr appendString:[chars lowercaseString]];
    
    vlang_dispatch_event(delegate.win_ptr, "window", "key", [keyStr UTF8String]);
  }

  if (flags == NSEventModifierFlagCommand) {
    if ([chars isEqualToString:@"q"]) {
      [NSApp terminate:self];
      return YES;
    } else if ([chars isEqualToString:@"f"]) {
      [self toggleFullScreen:nil];
      return YES;
    }
  }
  return [super performKeyEquivalent:event];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
  NSPasteboard *pboard = [sender draggingPasteboard];
  if ([[pboard types] containsObject:NSPasteboardTypeFileURL]) {
    return NSDragOperationCopy;
  }
  return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
  NSPasteboard *pboard = [sender draggingPasteboard];
  if ([[pboard types] containsObject:NSPasteboardTypeFileURL]) {
    NSArray *urls = [pboard readObjectsForClasses:@[[NSURL class]] options:nil];
    NSMutableArray *paths = [NSMutableArray array];
    for (NSURL *url in urls) {
      [paths addObject:[url path]];
    }
    AppDelegate *delegate = (AppDelegate *)self.delegate;
    if (delegate && delegate.win_ptr) {
      NSString *joinedPaths = [paths componentsJoinedByString:@"|"];
      vlang_dispatch_event(delegate.win_ptr, "window", "file_drop", [joinedPaths UTF8String]);
    }
    return YES;
  }
  return NO;
}
@end

static NSColor *colorFromString(const char *colorString) {
  if (!colorString || !*colorString) {
    return [NSColor controlAccentColor];
  }

  NSString *value = nsstring(colorString);
  NSString *normalized = [[value lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

  if ([normalized isEqualToString:@"black"]) return [NSColor blackColor];
  if ([normalized isEqualToString:@"white"]) return [NSColor whiteColor];
  if ([normalized isEqualToString:@"red"]) return [NSColor systemRedColor];
  if ([normalized isEqualToString:@"green"]) return [NSColor systemGreenColor];
  if ([normalized isEqualToString:@"blue"]) return [NSColor systemBlueColor];
  if ([normalized isEqualToString:@"yellow"]) return [NSColor systemYellowColor];
  if ([normalized isEqualToString:@"orange"]) return [NSColor systemOrangeColor];
  if ([normalized isEqualToString:@"purple"]) return [NSColor systemPurpleColor];
  if ([normalized isEqualToString:@"gray"] || [normalized isEqualToString:@"grey"]) return [NSColor grayColor];
  if ([normalized isEqualToString:@"cyan"]) return [NSColor cyanColor];
  if ([normalized isEqualToString:@"magenta"]) return [NSColor magentaColor];

  if ([normalized hasPrefix:@"#"]) {
    NSString *hex = [normalized substringFromIndex:1];
    if ([hex length] == 3) {
      NSMutableString *expanded = [NSMutableString stringWithCapacity:6];
      for (NSUInteger i = 0; i < [hex length]; i++) {
        unichar ch = [hex characterAtIndex:i];
        [expanded appendFormat:@"%C%C", ch, ch];
      }
      hex = expanded;
    } else if ([hex length] == 4) {
      NSMutableString *expanded = [NSMutableString stringWithCapacity:8];
      for (NSUInteger i = 0; i < [hex length]; i++) {
        unichar ch = [hex characterAtIndex:i];
        [expanded appendFormat:@"%C%C", ch, ch];
      }
      hex = expanded;
    }
    if ([hex length] == 6) {
      const char *hexChars = [hex UTF8String];
      char *end = NULL;
      unsigned long value = strtoul(hexChars, &end, 16);
      if (end && *end == '\0') {
        CGFloat r = ((value >> 16) & 0xFF) / 255.0;
        CGFloat g = ((value >> 8) & 0xFF) / 255.0;
        CGFloat b = (value & 0xFF) / 255.0;
        return [NSColor colorWithCalibratedRed:r green:g blue:b alpha:1.0];
      }
    } else if ([hex length] == 8) {
      const char *hexChars = [hex UTF8String];
      char *end = NULL;
      unsigned long value = strtoul(hexChars, &end, 16);
      if (end && *end == '\0') {
        CGFloat r = ((value >> 24) & 0xFF) / 255.0;
        CGFloat g = ((value >> 16) & 0xFF) / 255.0;
        CGFloat b = ((value >> 8) & 0xFF) / 255.0;
        CGFloat a = (value & 0xFF) / 255.0;
        return [NSColor colorWithCalibratedRed:r green:g blue:b alpha:a];
      }
    }
  }

  return [NSColor controlAccentColor];
}

static BOOL isDarkColor(NSColor *color);
static NSColor *getContrastColor(NSColor *color);

static NSColor *primaryButtonColor(void) {
  if (@available(macOS 10.14, *)) {
    return [NSColor controlAccentColor];
  }
  return [NSColor systemBlueColor];
}

static NSColor *modernAccentColor(void) {
  return primaryButtonColor();
}

static NSColor *modernSurfaceColor(void) {
  NSAppearance *appearance = [NSApp effectiveAppearance];
  if ([appearance bestMatchFromAppearancesWithNames:@[NSAppearanceNameDarkAqua, NSAppearanceNameAqua]] == NSAppearanceNameDarkAqua) {
    return [NSColor colorWithSRGBRed:0.095 green:0.10 blue:0.13 alpha:0.85];
  }
  return [NSColor colorWithSRGBRed:0.97 green:0.97 blue:0.985 alpha:0.85];
}

static BOOL isSystemDark(void) {
  NSAppearance *appearance = [NSApp effectiveAppearance];
  return [appearance bestMatchFromAppearancesWithNames:@[NSAppearanceNameDarkAqua, NSAppearanceNameAqua]] == NSAppearanceNameDarkAqua;
}

static NSColor *modernElevatedSurfaceColorWithDark(BOOL isDark) {
  if (isDark) {
    return [NSColor colorWithSRGBRed:0.18 green:0.18 blue:0.22 alpha:0.6];
  }
  return [NSColor colorWithSRGBRed:0.95 green:0.95 blue:0.97 alpha:0.7];
}

static NSColor *modernElevatedSurfaceColor(void) {
  return modernElevatedSurfaceColorWithDark(isSystemDark());
}

static NSColor *modernCardColorWithDark(BOOL isDark) {
  if (isDark) {
    return [NSColor colorWithSRGBRed:1.0 green:1.0 blue:1.0 alpha:0.04];
  }
  return [NSColor colorWithSRGBRed:0.0 green:0.0 blue:0.0 alpha:0.03];
}

static NSColor *modernCardColor(void) {
  return modernCardColorWithDark(isSystemDark());
}

static NSColor *modernBorderColorWithDark(BOOL isDark) {
  if (isDark) {
    return [NSColor colorWithSRGBRed:0.25 green:0.25 blue:0.28 alpha:0.4];
  }
  return [NSColor colorWithSRGBRed:0.75 green:0.75 blue:0.75 alpha:0.4];
}

static NSColor *modernBorderColor(void) {
  return modernBorderColorWithDark(isSystemDark());
}

static NSColor *modernTextColor(void) {
  return [NSColor labelColor];
}

static void setButtonTitleColor(NSButton *button, NSColor *color) {
  if (!button || !color) return;
  NSString *title = button.title;
  if (!title) title = @"";
  
  NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
  [style setAlignment:button.alignment];
  
  NSDictionary *attrs = @{
    NSForegroundColorAttributeName: color,
    NSFontAttributeName: button.font ?: [NSFont systemFontOfSize:12],
    NSParagraphStyleAttributeName: style
  };
  
  NSAttributedString *attrTitle = [[NSAttributedString alloc] initWithString:title attributes:attrs];
  [button setAttributedTitle:attrTitle];
}

static NSColor *adjustColorBrightness(NSColor *color, CGFloat factor) {
  NSColor *rgbColor = [color colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
  if (!rgbColor) return color;
  CGFloat r=0, g=0, b=0, a=0;
  [rgbColor getRed:&r green:&g blue:&b alpha:&a];
  r = MIN(MAX(r * factor, 0.0), 1.0);
  g = MIN(MAX(g * factor, 0.0), 1.0);
  b = MIN(MAX(b * factor, 0.0), 1.0);
  return [NSColor colorWithDeviceRed:r green:g blue:b alpha:a];
}

static NSColor *hoverColor(NSColor *color) {
  if (isDarkColor(color)) {
    return adjustColorBrightness(color, 1.25);
  }
  return adjustColorBrightness(color, 0.90);
}

static NSColor *activeColor(NSColor *color) {
  if (isDarkColor(color)) {
    return adjustColorBrightness(color, 0.85);
  }
  return adjustColorBrightness(color, 1.15);
}

@interface ModernButton : NSButton
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, assign) BOOL isHovered;
@property (nonatomic, assign) BOOL isPressed;
@property (nonatomic, strong) NSColor *baseBackgroundColor;
@property (nonatomic, strong) NSColor *baseTextColor;
@end

@implementation ModernButton
- (void)updateTrackingAreas {
  [super updateTrackingAreas];
  if (self.trackingArea != nil) {
    [self removeTrackingArea:self.trackingArea];
  }
  int opts = NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways;
  self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:opts owner:self userInfo:nil];
  [self addTrackingArea:self.trackingArea];
}

- (void)mouseEntered:(NSEvent *)event {
  self.isHovered = YES;
  [self updateVisuals];
}

- (void)mouseExited:(NSEvent *)event {
  self.isHovered = NO;
  [self updateVisuals];
}

- (void)mouseDown:(NSEvent *)event {
  self.isPressed = YES;
  [self updateVisuals];
  [super mouseDown:event];
  self.isPressed = NO;
  [self updateVisuals];
}

- (void)updateVisuals {
  if (!self.layer) return;
  [CATransaction begin];
  [CATransaction setAnimationDuration:0.15];
  
  NSColor *bgColor = self.baseBackgroundColor ?: [NSColor controlColor];
  NSColor *fgColor = self.baseTextColor ?: [NSColor controlTextColor];
  
  if (self.isPressed) {
    self.layer.backgroundColor = activeColor(bgColor).CGColor;
  } else if (self.isHovered) {
    self.layer.backgroundColor = hoverColor(bgColor).CGColor;
  } else {
    self.layer.backgroundColor = bgColor.CGColor;
  }
  
  setButtonTitleColor(self, fgColor);
  
  [CATransaction commit];
}

- (void)layout {
  [super layout];
  [self updateVisuals];
}
@end

static NSColor *currentFontColorForView(NSView *view) {
  if (!view) {
    return nil;
  }
  if ([view isKindOfClass:[NSTextField class]]) {
    return [(NSTextField *)view textColor];
  }
  if ([view isKindOfClass:[NSTextView class]]) {
    return [(NSTextView *)view textColor];
  }
  if ([view isKindOfClass:[NSButton class]]) {
    return [(NSButton *)view contentTintColor];
  }
  return nil;
}

static NSColor *currentBackgroundColorForView(NSView *view) {
  if (!view) {
    return nil;
  }
  if ([view isKindOfClass:[NSTextField class]]) {
    return [(NSTextField *)view backgroundColor];
  }
  if ([view isKindOfClass:[NSTextView class]]) {
    return [(NSTextView *)view backgroundColor];
  }
  return nil;
}

static void applyStyleToView(NSView *view, NSColor *backgroundColor, NSColor *fontColor) {
  if (!view) {
    return;
  }

  NSColor *effectiveBackground = backgroundColor ?: ([view isKindOfClass:[NSTextField class]] || [view isKindOfClass:[NSTextView class]] || [view isKindOfClass:[NSDatePicker class]] || [view isKindOfClass:[NSPopUpButton class]]) ? [NSColor textBackgroundColor] : [NSColor clearColor];
  NSString *controlName = [view.identifier lowercaseString];
  BOOL isStatus = [controlName isEqualToString:@"status"];
  NSColor *effectiveFont = fontColor;
  if (!effectiveFont) {
    effectiveFont = isStatus ? [NSColor secondaryLabelColor] : modernTextColor();
  }

  if ([view isKindOfClass:[ChartView class]]) {
    ChartView *cv = (ChartView *)view;
    if (fontColor) {
      cv.lineColor = fontColor;
    }
    [cv setNeedsDisplay:YES];
    return;
  }
  if ([view isKindOfClass:[ShortcutRecorder class]]) {
    ShortcutRecorder *sr = (ShortcutRecorder *)view;
    sr.backgroundColor = effectiveBackground;
    sr.textColor = effectiveFont;
    sr.layer.backgroundColor = effectiveBackground.CGColor;
    return;
  }

  if ([view isKindOfClass:[NSTextField class]]) {
    NSTextField *field = (NSTextField *)view;
    if (!field.isEditable) {
      [field setDrawsBackground:NO];
      [field setBordered:NO];
      [field setBezeled:NO];
      [field setTextColor:effectiveFont];
    } else {
      NSFont *currFont = field.font;
      CGFloat fSize = currFont ? currFont.pointSize : 13.0;
      [field setFont:[NSFont systemFontOfSize:fSize weight:NSFontWeightRegular]];
      [field setControlSize:NSControlSizeRegular];
      [field setFocusRingType:NSFocusRingTypeNone];
      [field setBordered:NO];
      [field setBezeled:NO];
      [field setWantsLayer:YES];
      [field setDrawsBackground:NO];
      [field setBackgroundColor:effectiveBackground];
      [field setTextColor:effectiveFont];
      field.layer.cornerRadius = 8.0;
      field.layer.backgroundColor = effectiveBackground.CGColor;
      
      BOOL hasFocus = NO;
      if (field.window && field.window.firstResponder) {
        id responder = field.window.firstResponder;
        if ([responder isKindOfClass:[NSView class]] && [(NSView *)responder isDescendantOf:field]) {
          hasFocus = YES;
        }
      }
      if (hasFocus) {
        field.layer.borderColor = [NSColor controlAccentColor].CGColor;
        field.layer.borderWidth = 1.5;
      } else {
        field.layer.borderColor = [NSColor separatorColor].CGColor;
        field.layer.borderWidth = 1.0;
      }
    }
  } else if ([view isKindOfClass:[NSTextView class]]) {
    NSTextView *textView = (NSTextView *)view;
    [textView setFont:[NSFont systemFontOfSize:13]];
    [textView setDrawsBackground:YES];
    [textView setBackgroundColor:effectiveBackground];
    [textView setTextColor:effectiveFont];
    [textView setWantsLayer:YES];
  } else if ([view isKindOfClass:[NSButton class]]) {
    NSButton *button = (NSButton *)view;
    NSFont *currFont = button.font;
    CGFloat fSize = currFont ? currFont.pointSize : 13.0;
    [button setFont:[NSFont systemFontOfSize:fSize weight:NSFontWeightRegular]];
    [button setControlSize:NSControlSizeRegular];

    BOOL isCheckboxOrRadio = ![button isBordered] && button.bezelStyle != NSBezelStyleInline;
    BOOL isLinkButton = button.bezelStyle == NSBezelStyleInline;
    BOOL isDefaultButton = [button.keyEquivalent isEqualToString:@"\r"];
    
    if (isCheckboxOrRadio && !isLinkButton) {
      [button setBezelStyle:NSBezelStyleRounded];
      [button setWantsLayer:YES];
      [button setBordered:NO];
      [button setContentTintColor:fontColor ?: modernAccentColor()];
      setButtonTitleColor(button, effectiveFont);
    } else {
      [button setBezelStyle:NSBezelStyleRounded];
      [button setWantsLayer:YES];
      if (isLinkButton) {
        [button setBordered:NO];
        [button setContentTintColor:fontColor ?: [NSColor linkColor]];
        setButtonTitleColor(button, fontColor ?: [NSColor linkColor]);
      } else if ([button isKindOfClass:[ModernButton class]]) {
        ModernButton *modButton = (ModernButton *)button;
        [modButton setBordered:NO];
        modButton.layer.cornerRadius = 8.0;
        
        NSColor *winBg = button.window ? button.window.backgroundColor : nil;
        BOOL isDark = YES;
        if (winBg && ![winBg isEqual:[NSColor clearColor]]) {
          isDark = isDarkColor(winBg);
        } else {
          isDark = isSystemDark();
        }
        
        if (isDefaultButton) {
          modButton.baseBackgroundColor = primaryButtonColor();
          modButton.baseTextColor = getContrastColor(primaryButtonColor());
          modButton.layer.borderWidth = 0.0;
        } else if (backgroundColor && ![backgroundColor isEqual:[NSColor clearColor]]) {
          modButton.baseBackgroundColor = backgroundColor;
          modButton.baseTextColor = fontColor ?: (isDark ? [NSColor whiteColor] : [NSColor labelColor]);
          modButton.layer.borderWidth = 1.0;
          modButton.layer.borderColor = modernBorderColorWithDark(isDark).CGColor;
        } else {
          modButton.baseBackgroundColor = modernElevatedSurfaceColorWithDark(isDark);
          modButton.baseTextColor = fontColor ?: (isDark ? [NSColor whiteColor] : [NSColor labelColor]);
          modButton.layer.borderWidth = 1.0;
          modButton.layer.borderColor = modernBorderColorWithDark(isDark).CGColor;
        }
        [modButton updateVisuals];
      } else {
        [button setBordered:NO];
        button.layer.cornerRadius = 8.0;
        
        NSColor *winBg = button.window ? button.window.backgroundColor : nil;
        BOOL isDark = YES;
        if (winBg && ![winBg isEqual:[NSColor clearColor]]) {
          isDark = isDarkColor(winBg);
        } else {
          isDark = isSystemDark();
        }
        
        if (isDefaultButton) {
          button.layer.backgroundColor = primaryButtonColor().CGColor;
          button.layer.borderWidth = 0.0;
          setButtonTitleColor(button, getContrastColor(primaryButtonColor()));
        } else if (backgroundColor && ![backgroundColor isEqual:[NSColor clearColor]]) {
          button.layer.backgroundColor = backgroundColor.CGColor;
          button.layer.borderWidth = 1.0;
          button.layer.borderColor = modernBorderColorWithDark(isDark).CGColor;
          setButtonTitleColor(button, fontColor ?: (isDark ? [NSColor whiteColor] : [NSColor labelColor]));
        } else {
          button.layer.backgroundColor = [modernElevatedSurfaceColorWithDark(isDark) CGColor];
          button.layer.borderWidth = 1.0;
          button.layer.borderColor = modernBorderColorWithDark(isDark).CGColor;
          setButtonTitleColor(button, fontColor ?: (isDark ? [NSColor whiteColor] : [NSColor labelColor]));
        }
      }
    }
  } else if ([view isKindOfClass:[NSPopUpButton class]]) {
    NSPopUpButton *popup = (NSPopUpButton *)view;
    [popup setFont:[NSFont systemFontOfSize:12 weight:NSFontWeightRegular]];
    [popup setControlSize:NSControlSizeRegular];
    [popup setBezelStyle:NSBezelStyleRounded];
    [popup setWantsLayer:YES];
    popup.layer.cornerRadius = 8.0;
    popup.layer.borderWidth = 1.0;
    popup.layer.borderColor = [NSColor separatorColor].CGColor;
    popup.layer.backgroundColor = (backgroundColor ?: modernElevatedSurfaceColor()).CGColor;
    if ([popup respondsToSelector:@selector(setContentTintColor:)]) {
      [popup setContentTintColor:effectiveFont];
    }
  } else if ([view isKindOfClass:[NSSegmentedControl class]]) {
    NSSegmentedControl *segment = (NSSegmentedControl *)view;
    if (@available(macOS 10.15, *)) {
      [segment setSegmentStyle:NSSegmentStyleAutomatic];
    } else {
      [segment setSegmentStyle:NSSegmentStyleRounded];
    }
    [segment setControlSize:NSControlSizeRegular];
    [segment setFont:[NSFont systemFontOfSize:12 weight:NSFontWeightRegular]];
    [segment setWantsLayer:YES];
    segment.layer.cornerRadius = 8.0;
    if ([segment respondsToSelector:@selector(setContentTintColor:)]) {
      [segment setContentTintColor:fontColor ?: modernAccentColor()];
    }
  } else if ([view isKindOfClass:[NSSlider class]]) {
    NSSlider *slider = (NSSlider *)view;
    [slider setControlSize:NSControlSizeRegular];
    [slider setWantsLayer:YES];
    [slider setFocusRingType:NSFocusRingTypeNone];
    slider.layer.cornerRadius = 8.0;
    if (fontColor && [slider respondsToSelector:@selector(setContentTintColor:)]) {
      [slider setContentTintColor:fontColor];
    }
  } else if ([view isKindOfClass:[NSDatePicker class]]) {
    NSDatePicker *picker = (NSDatePicker *)view;
    [picker setControlSize:NSControlSizeRegular];
    [picker setWantsLayer:YES];
    picker.layer.cornerRadius = 8.0;
    picker.layer.borderWidth = 1.0;
    picker.layer.borderColor = [NSColor separatorColor].CGColor;
    picker.layer.backgroundColor = (backgroundColor ?: modernElevatedSurfaceColor()).CGColor;
  } else if ([view isKindOfClass:[NSStepper class]]) {
    NSStepper *stepper = (NSStepper *)view;
    [stepper setControlSize:NSControlSizeRegular];
    [stepper setWantsLayer:YES];
    stepper.layer.cornerRadius = 8.0;
    stepper.layer.borderWidth = 1.0;
    stepper.layer.borderColor = [NSColor separatorColor].CGColor;
    if ([stepper respondsToSelector:@selector(setContentTintColor:)]) {
      [stepper setContentTintColor:fontColor ?: modernAccentColor()];
    }
  } else if ([view isKindOfClass:[NSColorWell class]]) {
    NSColorWell *well = (NSColorWell *)view;
    [well setWantsLayer:YES];
    well.layer.cornerRadius = 8.0;
    well.layer.borderWidth = 1.0;
    well.layer.borderColor = [NSColor separatorColor].CGColor;
    if (backgroundColor) {
      well.layer.backgroundColor = backgroundColor.CGColor;
    }
  } else if ([view isKindOfClass:[NSProgressIndicator class]]) {
    NSProgressIndicator *indicator = (NSProgressIndicator *)view;
    [indicator setWantsLayer:YES];
    indicator.layer.cornerRadius = 6.0;
  } else if ([view isKindOfClass:[NSScrollView class]]) {
    [view setWantsLayer:YES];
    [view.layer setCornerRadius:10.0];
    [view.layer setBorderWidth:1.0];
    [view.layer setBorderColor:[modernBorderColor() CGColor]];
    [view.layer setBackgroundColor:(backgroundColor ?: modernElevatedSurfaceColor()).CGColor];
  } else {
    if (backgroundColor) {
      [view setWantsLayer:YES];
      [view.layer setBackgroundColor:backgroundColor.CGColor];
    }
  }
}

@implementation AppDelegate
- (instancetype)initWithParams:(main__WindowParams)params {
  self = [super init];
  if (self) {
    _params = params;
    _win_ptr = params.win_ptr;
    _responsiveLayoutEnabled = params.responsive_layout != 0;
    [self setupWindow];
  }
  return self;
}

- (void)setupWindow {
  if (self.window) {
    return;
  }

  NSRect frame = NSMakeRect(100, 100, self.params.width, self.params.height);
  NSUInteger style = NSWindowStyleMaskTitled | NSWindowStyleMaskFullSizeContentView;
  if (self.params.closable) {
    style |= NSWindowStyleMaskClosable;
  }
  if (self.params.resizable) {
    style |= NSWindowStyleMaskResizable;
  }
  if (self.params.minimizable) {
    style |= NSWindowStyleMaskMiniaturizable;
  }
  self.window = [[CustomWindow alloc] initWithContentRect:frame
                                             styleMask:style
                                               backing:NSBackingStoreBuffered
                                                 defer:NO];
  const char *title = self.params.title.str ? self.params.title.str : "";
  [self.window setTitle:nsstring(title)];
  BOOL titlebarVisible = self.params.titlebar_visible != 0;
  BOOL titleVisible = self.params.title_visible != 0;
  [self.window setTitlebarAppearsTransparent:YES];
  [self.window setTitleVisibility:(titlebarVisible && titleVisible) ? NSWindowTitleVisible : NSWindowTitleHidden];
  
  if ([self.window respondsToSelector:@selector(setTitlebarSeparatorStyle:)]) {
    // NSTitlebarSeparatorStyleNone (0) removes standard divider lines for unified macOS Sonoma/Tahoe sidebar look
    [self.window setTitlebarSeparatorStyle:0];
  }
  
  [self.window setToolbar:nil];
  [self.window setShowsToolbarButton:NO];
  [self.window setBackgroundColor:[NSColor clearColor]];
  [self.window setOpaque:NO];
  [self.window setLevel:self.params.always_on_top ? NSFloatingWindowLevel : NSNormalWindowLevel];
  [self.window setDelegate:self];
  [self.window setReleasedWhenClosed:NO];
  [self.window setHasShadow:self.params.has_shadow != 0];
  [self.window setMovableByWindowBackground:self.params.movable_by_window_background != 0];
  [self.window registerForDraggedTypes:@[NSPasteboardTypeFileURL]];
  
  // Apply maximizable setting
  NSButton *zoomButton = [self.window standardWindowButton:NSWindowZoomButton];
  if (zoomButton) {
    [zoomButton setEnabled:self.params.maximizable != 0];
  }
  
  [self buildUI];
  [self.window center];
  self.windowController = [[NSWindowController alloc] initWithWindow:self.window];
}

- (void)setupToolbar {
  NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"SimpleGUIToolbar"];
  [toolbar setDelegate:self];
  [toolbar setAllowsUserCustomization:NO];
  [toolbar setAutosavesConfiguration:NO];
  [toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
  [self.window setToolbar:toolbar];
}

- (void)handleToolbarItemClicked:(id)sender {
  NSToolbarItem *item = (NSToolbarItem *)sender;
  NSString *name = item.itemIdentifier;
  if (name && self.win_ptr) {
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "click", "");
  }
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
  return self.toolbarItems[itemIdentifier];
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
  NSMutableArray *defaults = [NSMutableArray array];
  for (NSString *name in self.toolbarOrder) {
    if ([name isEqualToString:@"space"]) {
      [defaults addObject:NSToolbarSpaceItemIdentifier];
    } else if ([name isEqualToString:@"flexible_space"]) {
      [defaults addObject:NSToolbarFlexibleSpaceItemIdentifier];
    } else {
      [defaults addObject:name];
    }
  }
  return defaults;
}

- (NSArray<NSToolbarItemIdentifier> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
  return [self toolbarDefaultItemIdentifiers:toolbar];
}

- (NSMenu *)applicationDockMenu:(NSApplication *)sender {
  return self.dockMenu;
}

- (NSView *)viewForControlName:(NSString *)name {
  if (!name) {
    return nil;
  }
  NSString *normalized = [[name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  return self.controlsByName[normalized];
}

- (NSString *)nameForControl:(NSView *)control {
  for (NSString *key in self.controlsByName) {
    if (self.controlsByName[key] == control) {
      return key;
    }
  }
  // NSTextField focus notifications may arrive from the shared field editor.
  if ([control isKindOfClass:[NSTextView class]]) {
    for (NSString *key in self.controlsByName) {
      NSView *candidate = self.controlsByName[key];
      if ([candidate isKindOfClass:[NSTextField class]] && [(NSTextField *)candidate currentEditor] == control) {
        return key;
      }
    }
  }
  // Scroll view wrappers (like for notes view)
  if ([control isKindOfClass:[NSTextView class]]) {
    NSView *clip = control.superview;
    if (clip) {
      NSView *scroll = clip.superview;
      if ([scroll isKindOfClass:[NSScrollView class]]) {
        for (NSString *key in self.controlsByName) {
          if (self.controlsByName[key] == scroll) {
            return key;
          }
        }
      }
    }
  }
  return nil;
}

- (void)applyStyleToControlNamed:(NSString *)name backgroundColor:(NSColor *)backgroundColor fontColor:(NSColor *)fontColor {
  NSView *view = [self viewForControlName:name];
  if (!view) {
    return;
  }
  NSColor *effectiveBackgroundColor = backgroundColor ?: currentBackgroundColorForView(view) ?: [NSColor clearColor];
  NSColor *effectiveFontColor = fontColor ?: currentFontColorForView(view) ?: [NSColor labelColor];
  applyStyleToView(view, effectiveBackgroundColor, effectiveFontColor);
}

- (void)applyColorsRecursively:(NSView *)view backgroundColor:(NSColor *)backgroundColor fontColor:(NSColor *)fontColor {
  if (!view) {
    return;
  }

  NSColor *effBg = nil;
  if ([view isKindOfClass:[NSTextField class]]) {
    NSTextField *field = (NSTextField *)view;
    if (field.isEditable) {
      effBg = backgroundColor ?: [NSColor textBackgroundColor];
    }
  }
  applyStyleToView(view, effBg, fontColor);

  if ([view isKindOfClass:[NSScrollView class]]) {
    NSScrollView *scroll = (NSScrollView *)view;
    NSView *doc = [scroll documentView];
    if (doc) {
      if ([doc isKindOfClass:[NSTextView class]]) {
        [(NSTextView *)doc setTextColor:fontColor];
        [(NSTextView *)doc setBackgroundColor:backgroundColor ?: [NSColor textBackgroundColor]];
        [(NSTextView *)doc setDrawsBackground:YES];
      } else if ([doc isKindOfClass:[NSTableView class]]) {
        NSTableView *tv = (NSTableView *)doc;
        [tv setBackgroundColor:backgroundColor ?: [NSColor controlBackgroundColor]];
        [tv reloadData];
      } else {
        [self applyColorsRecursively:doc backgroundColor:backgroundColor fontColor:fontColor];
      }
    }
  } else if ([view isKindOfClass:[NSStackView class]]) {
    for (NSView *subview in [(NSStackView *)view arrangedSubviews]) {
      [self applyColorsRecursively:subview backgroundColor:backgroundColor fontColor:fontColor];
    }
  } else if ([view isKindOfClass:[NSBox class]]) {
    NSBox *box = (NSBox *)view;
    if (box.contentView) {
      [self applyColorsRecursively:box.contentView backgroundColor:backgroundColor fontColor:fontColor];
    }
  }

  for (NSView *subview in view.subviews) {
    if ([view isKindOfClass:[NSStackView class]] && [[(NSStackView *)view arrangedSubviews] containsObject:subview]) {
      continue;
    }
    if ([view isKindOfClass:[NSScrollView class]] && subview == [(NSScrollView *)view documentView]) {
      continue;
    }
    [self applyColorsRecursively:subview backgroundColor:backgroundColor fontColor:fontColor];
  }
}

- (void)applyColors:(NSColor *)backgroundColor fontColor:(NSColor *)fontColor {
  self.currentBackgroundColor = backgroundColor;
  self.currentFontColor = fontColor;

  if (self.window) {
    if (backgroundColor) {
      NSColor *rgbBg = [backgroundColor colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
      if (rgbBg) {
        CGFloat r=0, g=0, b=0, a=0;
        [rgbBg getRed:&r green:&g blue:&b alpha:&a];
        double luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
        if (luminance < 0.5) {
          if (@available(macOS 10.14, *)) {
            self.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
          } else {
            self.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
          }
        } else {
          if (@available(macOS 10.14, *)) {
            self.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
          } else {
            self.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
          }
        }
      }
    }

    BOOL isDefaultBg = NO;
    NSColor *defaultBg = modernSurfaceColor();
    if (backgroundColor && [backgroundColor isEqual:defaultBg]) {
      isDefaultBg = YES;
    }

    if (backgroundColor.alphaComponent < 1.0 || isDefaultBg) {
      [self.window setBackgroundColor:[NSColor clearColor]];
      [self.window setOpaque:NO];
    } else {
      [self.window setBackgroundColor:backgroundColor];
    }
    if (self.window.contentView) {
      [self.window.contentView setWantsLayer:YES];
      [self.window.contentView.layer setBorderWidth:0.5];
      NSAppearance *appearance = [NSApp effectiveAppearance];
      if ([appearance bestMatchFromAppearancesWithNames:@[NSAppearanceNameDarkAqua, NSAppearanceNameAqua]] == NSAppearanceNameDarkAqua) {
        [self.window.contentView.layer setBorderColor:[[NSColor colorWithCalibratedWhite:1.0 alpha:0.15] CGColor]];
      } else {
        [self.window.contentView.layer setBorderColor:[[NSColor colorWithCalibratedWhite:0.0 alpha:0.10] CGColor]];
      }
      if (isDefaultBg) {
        [self.window.contentView.layer setBackgroundColor:[NSColor clearColor].CGColor];
      } else {
        [self.window.contentView.layer setBackgroundColor:backgroundColor.CGColor];
      }
    }
  }
  if (self.scrollView) {
    [self.scrollView setBackgroundColor:[NSColor clearColor]];
  }
  if (self.mainStackView) {
    [self.mainStackView setWantsLayer:YES];
    [self.mainStackView.layer setBackgroundColor:[NSColor clearColor].CGColor];
  }
  
  if (self.mainStackView) {
    [self applyColorsRecursively:self.mainStackView backgroundColor:backgroundColor fontColor:fontColor];
  }
}

- (void)makeStretchableView:(NSView *)view minimumWidth:(CGFloat)minimumWidth {
  [view setTranslatesAutoresizingMaskIntoConstraints:NO];
  if (!self.responsiveLayoutEnabled) {
    [view setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
    [view setContentCompressionResistancePriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
    return;
  }
  [view setContentHuggingPriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationHorizontal];
  [view setContentCompressionResistancePriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
  [view.widthAnchor constraintGreaterThanOrEqualToConstant:minimumWidth].active = YES;
}

- (void)configureRowStack:(NSStackView *)row {
  [row setTranslatesAutoresizingMaskIntoConstraints:NO];
  [row setDistribution:NSStackViewDistributionFill];
  [row setAlignment:NSLayoutAttributeCenterY];
}

- (void)buildUI {
  NSLog(@"buildUI called");
  self.controlsByName = [NSMutableDictionary dictionary];
  self.treeItemsByName = [NSMutableDictionary dictionary];
  self.linkUrls = [NSMutableDictionary dictionary];

  NSVisualEffectView *backgroundView = [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(0, 0, self.params.width, self.params.height)];
  [backgroundView setMaterial:NSVisualEffectMaterialWindowBackground];
  [backgroundView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
  [backgroundView setState:NSVisualEffectStateActive];
  [backgroundView setWantsLayer:YES];
  [backgroundView.layer setCornerRadius:12.0];
  [backgroundView.layer setMasksToBounds:YES];
  [backgroundView.layer setBorderWidth:0.5];
  NSAppearance *appearance = [NSApp effectiveAppearance];
  if ([appearance bestMatchFromAppearancesWithNames:@[NSAppearanceNameDarkAqua, NSAppearanceNameAqua]] == NSAppearanceNameDarkAqua) {
    [backgroundView.layer setBorderColor:[[NSColor colorWithCalibratedWhite:1.0 alpha:0.15] CGColor]];
  } else {
    [backgroundView.layer setBorderColor:[[NSColor colorWithCalibratedWhite:0.0 alpha:0.10] CGColor]];
  }

  self.scrollView = [[NSScrollView alloc] initWithFrame:NSZeroRect];
  [self.scrollView setHasVerticalScroller:YES];
  [self.scrollView setHasHorizontalScroller:NO];
  [self.scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
  [self.scrollView setDrawsBackground:NO];
  [self.scrollView setBackgroundColor:[NSColor clearColor]];

  self.mainStackView = [[FlippedStackView alloc] init];
  [self.mainStackView setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [self.mainStackView setAlignment:NSLayoutAttributeLeading];
  [self.mainStackView setDistribution:NSStackViewDistributionFill];
  double spacingVal = self.params.spacing > 0 ? (double)self.params.spacing : 14.0;
  [self.mainStackView setSpacing:spacingVal];
  double paddingVal = self.params.padding > 0 ? (double)self.params.padding : 20.0;
  [self.mainStackView setEdgeInsets:NSEdgeInsetsMake(paddingVal, paddingVal, paddingVal, paddingVal)];
  [self.mainStackView setWantsLayer:YES];
  [self.mainStackView setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  [self.scrollView setDocumentView:self.mainStackView];
  [backgroundView addSubview:self.scrollView];
  [self.window setContentView:backgroundView];
  
  // High-precision modern AutoLayout constraints to clear transparent titlebar area
  [NSLayoutConstraint activateConstraints:@[
    [self.scrollView.topAnchor constraintEqualToAnchor:backgroundView.topAnchor constant:40.0],
    [self.scrollView.leadingAnchor constraintEqualToAnchor:backgroundView.leadingAnchor constant:8.0],
    [self.scrollView.trailingAnchor constraintEqualToAnchor:backgroundView.trailingAnchor constant:-8.0],
    [self.scrollView.bottomAnchor constraintEqualToAnchor:backgroundView.bottomAnchor constant:-8.0]
  ]];
  
  NSView *clipView = self.scrollView.contentView;
  [self.mainStackView.topAnchor constraintEqualToAnchor:clipView.topAnchor].active = YES;
  [self.mainStackView.leadingAnchor constraintEqualToAnchor:clipView.leadingAnchor].active = YES;
  [self.mainStackView.trailingAnchor constraintEqualToAnchor:clipView.trailingAnchor].active = YES;
  [self.mainStackView.widthAnchor constraintEqualToAnchor:clipView.widthAnchor].active = YES;

  [self applyColors:modernSurfaceColor() fontColor:modernTextColor()];
}

- (void)addControlToLayout:(NSView *)view {
  if (self.currentRowStack) {
    [self.currentRowStack addArrangedSubview:view];
  } else if (self.currentGlassBoxStack) {
    [self.currentGlassBoxStack addArrangedSubview:view];
  } else if (self.currentSplitPane) {
    [self.currentSplitPane addArrangedSubview:view];
  } else {
    [self.mainStackView addArrangedSubview:view];
  }
}

- (void)beginRowWithName:(NSString *)name {
  NSStackView *row = [[NSStackView alloc] init];
  [row setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [row setAlignment:NSLayoutAttributeCenterY];
  [row setDistribution:NSStackViewDistributionFill];
  [row setSpacing:12.0];
  [row setWantsLayer:YES];
  [row setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  [self addControlToLayout:row];
  self.currentRowStack = row;
  self.controlsByName[[name lowercaseString]] = row;
}

- (void)endRow {
  self.currentRowStack = nil;
}

// Control creation methods
- (NSView *)makeLabelWithName:(NSString *)name text:(NSString *)text {
  NSTextField *label = [NSTextField labelWithString:text];
  [label setLineBreakMode:NSLineBreakByWordWrapping];
  [label setWantsLayer:YES];
  
  if ([name hasPrefix:@"heading_"]) {
    [label setFont:[NSFont systemFontOfSize:17.0 weight:NSFontWeightBold]];
    [label setTextColor:self.currentFontColor ?: [NSColor labelColor]];
  } else if ([name isEqualToString:@"status"]) {
    [label setFont:[NSFont systemFontOfSize:11.0 weight:NSFontWeightRegular]];
    [label setTextColor:self.currentFontColor ?: [NSColor secondaryLabelColor]];
  } else {
    [label setFont:[NSFont systemFontOfSize:13.0 weight:NSFontWeightRegular]];
    [label setTextColor:self.currentFontColor ?: [NSColor labelColor]];
  }
  
  self.controlsByName[[name lowercaseString]] = label;
  [self addControlToLayout:label];
  return label;
}

- (NSView *)makeTextFieldWithName:(NSString *)name value:(NSString *)value {
  ModernTextField *textField = [[ModernTextField alloc] initWithFrame:NSZeroRect];
  [textField setIdentifier:name];
  [textField setStringValue:value];
  [textField setPlaceholderString:@"Type here..."];
  [textField setDelegate:self];
  [textField setTarget:self];
  [textField setAction:@selector(handleInputChanged:)];
  [self makeStretchableView:textField minimumWidth:220];
  [textField.heightAnchor constraintEqualToConstant:34.0].active = YES;
  
  applyStyleToView(textField, self.currentBackgroundColor, self.currentFontColor);
  
  self.controlsByName[[name lowercaseString]] = textField;
  [self addControlToLayout:textField];
  return textField;
}

- (NSView *)makePasswordFieldWithName:(NSString *)name value:(NSString *)value {
  ModernSecureTextField *passwordField = [[ModernSecureTextField alloc] initWithFrame:NSZeroRect];
  [passwordField setIdentifier:name];
  [passwordField setStringValue:value];
  [passwordField setPlaceholderString:@"Password..."];
  [passwordField setDelegate:self];
  [passwordField setTarget:self];
  [passwordField setAction:@selector(handleInputChanged:)];
  [self makeStretchableView:passwordField minimumWidth:220];
  [passwordField.heightAnchor constraintEqualToConstant:34.0].active = YES;
  
  applyStyleToView(passwordField, self.currentBackgroundColor, self.currentFontColor);
  
  self.controlsByName[[name lowercaseString]] = passwordField;
  [self addControlToLayout:passwordField];
  return passwordField;
}

- (NSView *)makeHtmlViewWithName:(NSString *)name html:(NSString *)html {
  WKWebView *webView = [[WKWebView alloc] initWithFrame:NSZeroRect configuration:[[WKWebViewConfiguration alloc] init]];
  [self makeStretchableView:webView minimumWidth:320];
  [webView.heightAnchor constraintEqualToConstant:180].active = YES;
  [webView setWantsLayer:YES];
  webView.layer.cornerRadius = 8.0;
  webView.layer.masksToBounds = YES;
  webView.layer.borderWidth = 1.0;
  webView.layer.borderColor = [modernBorderColor() CGColor];
  
  // Make WKWebView background transparent to blend in beautifully with dark/light themes
  if ([webView respondsToSelector:@selector(setValue:forKey:)]) {
    [webView setValue:@NO forKey:@"drawsBackground"];
  }
  
  [webView loadHTMLString:html baseURL:nil];
  [self addControlToLayout:webView];
  self.controlsByName[[name lowercaseString]] = webView;
  return webView;
}

- (NSView *)makeDropZoneWithName:(NSString *)name label:(NSString *)label {
  DropZoneView *box = [[DropZoneView alloc] initWithFrame:NSZeroRect];
  [box setBoxType:NSBoxCustom];
  [box setBorderType:NSLineBorder];
  [box setContentViewMargins:NSMakeSize(12, 12)];
  [box setTitle:@""];
  [box setWantsLayer:YES];
  [self makeStretchableView:box minimumWidth:320];
  [box.heightAnchor constraintEqualToConstant:96].active = YES;
  [box.layer setCornerRadius:10.0];
  [box.layer setBorderWidth:1.0];
  [box.layer setBorderColor:[modernBorderColor() CGColor]];
  box.layer.backgroundColor = [modernElevatedSurfaceColor() CGColor];
  [box registerForDraggedTypes:@[NSPasteboardTypeFileURL]];
  box.win_ptr = self.win_ptr;
  box.controlName = [name lowercaseString];

  NSTextField *labelField = [NSTextField labelWithString:label ?: @"Drop files here"];
  [labelField setAlignment:NSTextAlignmentCenter];
  [labelField setFont:[NSFont systemFontOfSize:11 weight:NSFontWeightMedium]];
  [labelField setTextColor:[NSColor secondaryLabelColor]];
  [labelField setTranslatesAutoresizingMaskIntoConstraints:NO];
  [box addSubview:labelField];
  [NSLayoutConstraint activateConstraints:@[
    [labelField.centerXAnchor constraintEqualToAnchor:box.centerXAnchor],
    [labelField.centerYAnchor constraintEqualToAnchor:box.centerYAnchor]
  ]];

  [self addControlToLayout:box];
  self.controlsByName[[name lowercaseString]] = box;
  return box;
}

- (NSView *)makeTextAreaWithName:(NSString *)name value:(NSString *)value {
  NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSZeroRect];
  [scroll setIdentifier:name];
  [scroll setHasVerticalScroller:YES];
  [scroll setHasHorizontalScroller:NO];
  [scroll setBorderType:NSNoBorder];
  [scroll setWantsLayer:YES];
  scroll.layer.cornerRadius = 8.0;
  scroll.layer.borderWidth = 1.0;
  scroll.layer.borderColor = [modernBorderColor() CGColor];
  [self makeStretchableView:scroll minimumWidth:320];
  [scroll.heightAnchor constraintEqualToConstant:120].active = YES;
  
  NSTextView *textView = [[NSTextView alloc] initWithFrame:NSZeroRect];
  [textView setIdentifier:name];
  [textView setMinSize:NSMakeSize(0.0, 120.0)];
  [textView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
  [textView setVerticallyResizable:YES];
  [textView setHorizontallyResizable:NO];
  [textView setAutoresizingMask:NSViewWidthSizable];
  [textView setString:value];
  [textView setDelegate:self];
  [textView setWantsLayer:YES];
  [textView setTextContainerInset:NSMakeSize(8.0, 8.0)];
  
  [scroll setDocumentView:textView];
  
  applyStyleToView(scroll, self.currentBackgroundColor ?: [NSColor textBackgroundColor], self.currentFontColor);
  
  [textView setTextColor:self.currentFontColor ?: modernTextColor()];
  [textView setBackgroundColor:self.currentBackgroundColor ?: [NSColor textBackgroundColor]];
  [textView setDrawsBackground:YES];
  
  self.controlsByName[[name lowercaseString]] = scroll;
  [self addControlToLayout:scroll];
  return scroll;
}

- (NSView *)makeButtonWithName:(NSString *)name title:(NSString *)title {
  ModernButton *button = [ModernButton buttonWithTitle:title target:self action:@selector(handleButtonClicked:)];
  [button setIdentifier:name];
  [button setBezelStyle:NSBezelStyleRounded];
  [self makeStretchableView:button minimumWidth:120];
  [button.heightAnchor constraintGreaterThanOrEqualToConstant:30.0].active = YES;
  applyStyleToView(button, self.currentBackgroundColor, self.currentFontColor);
  
  self.controlsByName[[name lowercaseString]] = button;
  [self addControlToLayout:button];
  return button;
}

- (NSView *)makeLinkWithName:(NSString *)name text:(NSString *)text url:(NSString *)urlStr {
  NSButton *button = [NSButton buttonWithTitle:text target:self action:@selector(handleLinkClicked:)];
  [button setBezelStyle:NSBezelStyleInline];
  [button setBordered:NO];
  [button setWantsLayer:YES];
  
  applyStyleToView(button, nil, self.currentFontColor ?: [NSColor linkColor]);
  
  NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:text];
  NSRange range = NSMakeRange(0, [text length]);
  [attrTitle addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
  [attrTitle addAttribute:NSForegroundColorAttributeName value:[NSColor linkColor] range:range];
  [attrTitle addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:[NSFont systemFontSize]] range:range];
  [button setAttributedTitle:attrTitle];
  
  self.linkUrls[[name lowercaseString]] = urlStr;
  self.controlsByName[[name lowercaseString]] = button;
  [self addControlToLayout:button];
  return button;
}

- (NSView *)makeCheckboxWithName:(NSString *)name label:(NSString *)label checked:(BOOL)checked {
  NSButton *checkbox = [NSButton checkboxWithTitle:label target:self action:@selector(handleCheckboxClicked:)];
  [checkbox setIdentifier:name];
  [checkbox setState:checked ? NSOnState : NSOffState];
  [checkbox setWantsLayer:YES];
  
  applyStyleToView(checkbox, nil, self.currentFontColor ?: modernTextColor());
  
  self.controlsByName[[name lowercaseString]] = checkbox;
  [self addControlToLayout:checkbox];
  return checkbox;
}

- (NSView *)makeDisclosureButtonWithName:(NSString *)name title:(NSString *)title state:(BOOL)open {
  NSButton *disclosure = [[NSButton alloc] initWithFrame:NSZeroRect];
  [disclosure setButtonType:NSButtonTypeOnOff];
  [disclosure setBezelStyle:NSBezelStyleDisclosure];
  [disclosure setTitle:title];
  [disclosure setState:open ? NSOnState : NSOffState];
  [disclosure setTarget:self];
  [disclosure setAction:@selector(handleDisclosureClicked:)];
  [disclosure setWantsLayer:YES];
  
  applyStyleToView(disclosure, nil, self.currentFontColor ?: modernTextColor());
  
  self.controlsByName[[name lowercaseString]] = disclosure;
  [self addControlToLayout:disclosure];
  return disclosure;
}

- (NSView *)makeNumberFieldWithName:(NSString *)name value:(int)value {
  NSStackView *row = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [row setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [row setSpacing:8.0];
  [self configureRowStack:row];
  
  ModernTextField *numField = [[ModernTextField alloc] initWithFrame:NSZeroRect];
  [numField setStringValue:[NSString stringWithFormat:@"%d", value]];
  [self makeStretchableView:numField minimumWidth:70];
  [numField setTarget:self];
  [numField setAction:@selector(handleNumberChanged:)];
  [numField.heightAnchor constraintEqualToConstant:34.0].active = YES;
  
  NSStepper *stepper = [[NSStepper alloc] initWithFrame:NSZeroRect];
  [stepper setMinValue:0];
  [stepper setMaxValue:1000];
  [stepper setDoubleValue:(double)value];
  [stepper setTarget:self];
  [stepper setAction:@selector(handleNumberChanged:)];
  [stepper setWantsLayer:YES];
  applyStyleToView(stepper, self.currentBackgroundColor, self.currentFontColor);
  
  [row addArrangedSubview:numField];
  [row addArrangedSubview:stepper];
  
  applyStyleToView(numField, self.currentBackgroundColor, self.currentFontColor);
  
  self.controlsByName[[name lowercaseString]] = numField;
  [self addControlToLayout:row];
  return numField;
}

- (NSView *)makeSliderWithName:(NSString *)name value:(int)value {
  NSStackView *row = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [row setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [row setSpacing:10.0];
  [self configureRowStack:row];
  
  NSSlider *slider = [[NSSlider alloc] initWithFrame:NSZeroRect];
  [slider setMinValue:0];
  [slider setMaxValue:100];
  [slider setDoubleValue:(double)value];
  [self makeStretchableView:slider minimumWidth:200];
  [slider setTarget:self];
  [slider setAction:@selector(handleSliderChanged:)];
  [slider setWantsLayer:YES];
  applyStyleToView(slider, self.currentBackgroundColor, self.currentFontColor);
  
  NSTextField *label = [NSTextField labelWithString:[NSString stringWithFormat:@"Value: %d", value]];
  [label.widthAnchor constraintEqualToConstant:100].active = YES;
  [label setWantsLayer:YES];
  
  if (self.currentFontColor) {
    [label setTextColor:self.currentFontColor];
  }
  
  [row addArrangedSubview:slider];
  [row addArrangedSubview:label];
  
  self.controlsByName[[name lowercaseString]] = slider;
  [self addControlToLayout:row];
  return slider;
}

- (NSView *)makePopUpButtonWithName:(NSString *)name selected:(NSString *)selected {
  NSPopUpButton *popup = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
  [popup addItemWithTitle:@"Light"];
  [popup addItemWithTitle:@"Dark"];
  [popup addItemWithTitle:@"System"];
  [popup selectItemWithTitle:selected];
  [popup setTarget:self];
  [popup setAction:@selector(handlePopUpChanged:)];
  [self makeStretchableView:popup minimumWidth:180];
  [popup setWantsLayer:YES];
  applyStyleToView(popup, self.currentBackgroundColor, self.currentFontColor);
  
  self.controlsByName[[name lowercaseString]] = popup;
  [self addControlToLayout:popup];
  return popup;
}

- (NSView *)makeColorWellWithName:(NSString *)name color:(NSString *)colorString {
  NSColorWell *well = [[NSColorWell alloc] initWithFrame:NSMakeRect(0, 0, 60, 30)];
  [well setColor:colorFromString([colorString UTF8String])];
  [well setTarget:self];
  [well setAction:@selector(handleColorWellChanged:)];
  [well.widthAnchor constraintEqualToConstant:60].active = YES;
  [well.heightAnchor constraintEqualToConstant:30].active = YES;
  [well setWantsLayer:YES];
  well.layer.cornerRadius = 6.0;
  applyStyleToView(well, self.currentBackgroundColor, self.currentFontColor);
  
  if ([well respondsToSelector:@selector(setColorWellStyle:)]) {
    // 1 is NSColorWellStyleMinimal, which looks incredibly slick and modern (like the Safari web inspector / system settings circles)
    [well setColorWellStyle:1];
  }
  
  self.controlsByName[[name lowercaseString]] = well;
  [self addControlToLayout:well];
  return well;
}

- (NSView *)makeDatePickerWithName:(NSString *)name date:(NSString *)dateString {
  NSDatePicker *picker = [[NSDatePicker alloc] initWithFrame:NSZeroRect];
  [picker setDatePickerStyle:NSDatePickerStyleTextField];
  [picker setDatePickerMode:NSDatePickerModeSingle];
  
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd"];
  NSDate *date = [formatter dateFromString:dateString] ?: [NSDate date];
  [picker setDateValue:date];
  [picker setTarget:self];
  [picker setAction:@selector(handleDatePickerChanged:)];
  [self makeStretchableView:picker minimumWidth:160];
  [picker setWantsLayer:YES];
  
  applyStyleToView(picker, self.currentBackgroundColor, self.currentFontColor);
  
  self.controlsByName[[name lowercaseString]] = picker;
  [self addControlToLayout:picker];
  return picker;
}

- (NSView *)makeSegmentedControlWithName:(NSString *)name selected:(NSString *)selected {
  NSSegmentedControl *seg = [[NSSegmentedControl alloc] initWithFrame:NSZeroRect];
  [seg setSegmentCount:3];
  [seg setLabel:@"Simple" forSegment:0];
  [seg setLabel:@"Advanced" forSegment:1];
  [seg setLabel:@"Expert" forSegment:2];
  
  [seg setSelectedSegment:0];
  for (NSInteger i = 0; i < [seg segmentCount]; i++) {
    if ([[seg labelForSegment:i] isEqualToString:selected]) {
      [seg setSelectedSegment:i];
      break;
    }
  }
  [seg setTarget:self];
  [seg setAction:@selector(handleSegmentedChanged:)];
  [self makeStretchableView:seg minimumWidth:220];
  [seg setWantsLayer:YES];
  
  applyStyleToView(seg, self.currentBackgroundColor, self.currentFontColor);
  
  self.controlsByName[[name lowercaseString]] = seg;
  [self addControlToLayout:seg];
  return seg;
}

- (NSView *)makeProgressIndicatorWithName:(NSString *)name value:(int)value {
  NSProgressIndicator *progress = [[NSProgressIndicator alloc] initWithFrame:NSZeroRect];
  [progress setStyle:NSProgressIndicatorStyleBar];
  [progress setMinValue:0];
  [progress setMaxValue:100];
  [progress setDoubleValue:(double)value];
  [progress setIndeterminate:NO];
  [self makeStretchableView:progress minimumWidth:260];
  [progress setWantsLayer:YES];
  applyStyleToView(progress, self.currentBackgroundColor, self.currentFontColor);
  
  self.controlsByName[[name lowercaseString]] = progress;
  [self addControlToLayout:progress];
  return progress;
}

- (NSView *)makeDropdownWithName:(NSString *)name items:(NSArray<NSString *> *)items selected:(NSString *)selected {
  NSPopUpButton *popup = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
  for (NSString *item in items) {
    [popup addItemWithTitle:item];
  }
  [popup selectItemWithTitle:selected];
  [popup setTarget:self];
  [popup setAction:@selector(handlePopUpChanged:)];
  [self makeStretchableView:popup minimumWidth:180];
  [popup setWantsLayer:YES];
  
  if (self.currentFontColor || self.currentBackgroundColor) {
    applyStyleToView(popup, self.currentBackgroundColor, self.currentFontColor);
  }
  
  self.controlsByName[[name lowercaseString]] = popup;
  [self addControlToLayout:popup];
  return popup;
}

- (NSView *)makeSegmentedControlWithName:(NSString *)name items:(NSArray<NSString *> *)items selected:(NSString *)selected {
  NSSegmentedControl *seg = [[NSSegmentedControl alloc] initWithFrame:NSZeroRect];
  [seg setSegmentCount:items.count];
  for (NSInteger i = 0; i < items.count; i++) {
    [seg setLabel:items[i] forSegment:i];
  }
  [seg setSelectedSegment:-1];
  for (NSInteger i = 0; i < items.count; i++) {
    if ([items[i] isEqualToString:selected]) {
      [seg setSelectedSegment:i];
      break;
    }
  }
  [seg setTarget:self];
  [seg setAction:@selector(handleSegmentedChanged:)];
  [self makeStretchableView:seg minimumWidth:220];
  [seg setWantsLayer:YES];
  
  if (self.currentFontColor) {
    applyStyleToView(seg, nil, self.currentFontColor);
  }
  
  self.controlsByName[[name lowercaseString]] = seg;
  [self addControlToLayout:seg];
  return seg;
}

- (NSView *)makeRadioGroupWithName:(NSString *)name items:(NSArray<NSString *> *)items selected:(NSString *)selected {
  NSStackView *radioStack = [[NSStackView alloc] init];
  [radioStack setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [radioStack setAlignment:NSLayoutAttributeLeading];
  [radioStack setSpacing:6.0];
  [radioStack setWantsLayer:YES];
  [radioStack setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  for (NSInteger i = 0; i < items.count; i++) {
    NSButton *radio = [NSButton radioButtonWithTitle:items[i] target:self action:@selector(handleRadioChanged:)];
    if ([items[i] isEqualToString:selected]) {
      [radio setState:NSControlStateValueOn];
    } else {
      [radio setState:NSControlStateValueOff];
    }
    [radio setIdentifier:[NSString stringWithFormat:@"%@_radio_%ld", name, (long)i]];
    if (self.currentFontColor) {
      applyStyleToView(radio, nil, self.currentFontColor);
    }
    [radioStack addArrangedSubview:radio];
  }
  
  self.controlsByName[[name lowercaseString]] = radioStack;
  [self addControlToLayout:radioStack];
  return radioStack;
}

- (void)handleRadioChanged:(id)sender {
  NSButton *clickedRadio = (NSButton *)sender;
  NSStackView *radioStack = (NSStackView *)[clickedRadio superview];
  if ([radioStack isKindOfClass:[NSStackView class]]) {
    for (NSView *subview in [radioStack arrangedSubviews]) {
      if ([subview isKindOfClass:[NSButton class]]) {
        NSButton *btn = (NSButton *)subview;
        if (btn != clickedRadio) {
          [btn setState:NSControlStateValueOff];
        } else {
          [btn setState:NSControlStateValueOn];
        }
      }
    }
    NSString *name = [self nameForControl:radioStack];
    if (name && self.win_ptr) {
      NSString *choice = [clickedRadio title];
      vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [choice UTF8String]);
    }
  }
}

- (NSView *)makeSwitchWithName:(NSString *)name label:(NSString *)labelText checked:(BOOL)checked {
  NSStackView *row = [[NSStackView alloc] init];
  [row setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [row setAlignment:NSLayoutAttributeCenterY];
  [row setSpacing:8.0];
  [row setTranslatesAutoresizingMaskIntoConstraints:NO];

  NSTextField *label = [NSTextField labelWithString:labelText];
  [label setFont:[NSFont systemFontOfSize:13]];
  if (self.currentFontColor) {
    applyStyleToView(label, nil, self.currentFontColor);
  }
  
  NSSwitch *sw = [[NSSwitch alloc] init];
  [sw setState:checked ? NSControlStateValueOn : NSControlStateValueOff];
  [sw setTarget:self];
  [sw setAction:@selector(handleSwitchChanged:)];
  
  [row addArrangedSubview:label];
  [row addArrangedSubview:sw];

  self.controlsByName[[name lowercaseString]] = sw;
  [self addControlToLayout:row];
  return sw;
}

- (void)handleSwitchChanged:(id)sender {
  NSSwitch *sw = (NSSwitch *)sender;
  int checked = (sw.state == NSControlStateValueOn) ? 1 : 0;
  NSString *name = [self nameForControl:sw];
  if (name && self.win_ptr) {
    NSString *valStr = checked ? @"true" : @"false";
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [valStr UTF8String]);
  }
}

- (NSView *)makeSearchFieldWithName:(NSString *)name placeholder:(NSString *)placeholder {
  ModernSearchField *searchField = [[ModernSearchField alloc] initWithFrame:NSZeroRect];
  [[searchField cell] setPlaceholderString:placeholder];
  [searchField setDelegate:self];
  [searchField setTarget:self];
  [searchField setAction:@selector(handleInputChanged:)];
  [self makeStretchableView:searchField minimumWidth:180];
  [searchField.heightAnchor constraintEqualToConstant:34.0].active = YES;
  
  applyStyleToView(searchField, self.currentBackgroundColor, self.currentFontColor);
  
  self.controlsByName[[name lowercaseString]] = searchField;
  [self addControlToLayout:searchField];
  return searchField;
}

- (NSView *)makeComboBoxWithName:(NSString *)name items:(NSArray<NSString *> *)items selected:(NSString *)selected {
  NSComboBox *combo = [[NSComboBox alloc] initWithFrame:NSZeroRect];
  [combo addItemsWithObjectValues:items];
  [combo setStringValue:selected ?: @""];
  [combo setDelegate:self];
  [combo setTarget:self];
  [combo setAction:@selector(handleInputChanged:)];
  [self makeStretchableView:combo minimumWidth:180];
  [combo.heightAnchor constraintEqualToConstant:34.0].active = YES;
  
  applyStyleToView(combo, self.currentBackgroundColor, self.currentFontColor);
  
  self.controlsByName[[name lowercaseString]] = combo;
  [self addControlToLayout:combo];
  return combo;
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification {
  NSComboBox *combo = (NSComboBox *)notification.object;
  NSString *name = [self nameForControl:combo];
  if (name && self.win_ptr) {
    NSInteger selectedIdx = [combo indexOfSelectedItem];
    if (selectedIdx >= 0) {
      NSString *val = [combo itemObjectValueAtIndex:selectedIdx];
      vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [val UTF8String]);
    }
  }
}

- (NSView *)makeLevelIndicatorWithName:(NSString *)name style:(int)style minValue:(double)minValue maxValue:(double)maxValue value:(double)value {
  NSLevelIndicator *indicator = [[NSLevelIndicator alloc] initWithFrame:NSZeroRect];
  
  if (@available(macOS 10.13, *)) {
    indicator.levelIndicatorStyle = style;
  }
  
  indicator.minValue = minValue;
  indicator.maxValue = maxValue;
  indicator.doubleValue = value;
  indicator.editable = YES;
  indicator.target = self;
  indicator.action = @selector(handleLevelIndicatorChanged:);
  
  if ([indicator respondsToSelector:@selector(setContentTintColor:)]) {
    [indicator setContentTintColor:modernAccentColor()];
  }
  
  [self makeStretchableView:indicator minimumWidth:120];
  [indicator.heightAnchor constraintEqualToConstant:24.0].active = YES;
  
  self.controlsByName[[name lowercaseString]] = indicator;
  [self addControlToLayout:indicator];
  return indicator;
}

- (void)handleLevelIndicatorChanged:(id)sender {
  NSLevelIndicator *indicator = (NSLevelIndicator *)sender;
  NSString *name = [self nameForControl:indicator];
  if (name && self.win_ptr) {
    double value = [indicator doubleValue];
    NSString *valStr = [NSString stringWithFormat:@"%.1f", value];
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [valStr UTF8String]);
  }
}

- (NSView *)makeSpinnerWithName:(NSString *)name active:(BOOL)active {
  NSProgressIndicator *spinner = [[NSProgressIndicator alloc] initWithFrame:NSZeroRect];
  [spinner setStyle:NSProgressIndicatorStyleSpinning];
  [spinner setControlSize:NSControlSizeRegular];
  [spinner setIndeterminate:YES];
  if (active) {
    [spinner startAnimation:nil];
  } else {
    [spinner stopAnimation:nil];
  }
  [spinner setHidden:!active];
  
  [spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
  [spinner.widthAnchor constraintEqualToConstant:32.0].active = YES;
  [spinner.heightAnchor constraintEqualToConstant:32.0].active = YES;
  
  self.controlsByName[[name lowercaseString]] = spinner;
  [self addControlToLayout:spinner];
  return spinner;
}

- (NSView *)makePathControlWithName:(NSString *)name path:(NSString *)pathString {
  NSPathControl *pathControl = [[NSPathControl alloc] initWithFrame:NSZeroRect];
  [pathControl setPathStyle:NSPathStyleStandard];
  if (pathString && pathString.length > 0) {
    [pathControl setURL:[NSURL fileURLWithPath:pathString]];
  }
  [pathControl setEditable:YES];
  [pathControl setTarget:self];
  [pathControl setAction:@selector(handlePathControlChanged:)];
  
  [self makeStretchableView:pathControl minimumWidth:240];
  [pathControl.heightAnchor constraintEqualToConstant:28.0].active = YES;
  
  self.controlsByName[[name lowercaseString]] = pathControl;
  [self addControlToLayout:pathControl];
  return pathControl;
}

- (void)handlePathControlChanged:(id)sender {
  NSPathControl *pathControl = (NSPathControl *)sender;
  NSString *name = [self nameForControl:pathControl];
  if (name && self.win_ptr) {
    NSURL *url = [pathControl URL];
    NSString *path = url ? [url path] : @"";
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [path UTF8String]);
  }
}

- (NSView *)makeTokenFieldWithName:(NSString *)name value:(NSString *)value {
  NSTokenField *tokenField = [[NSTokenField alloc] initWithFrame:NSZeroRect];
  [tokenField setStringValue:value ?: @""];
  [tokenField setDelegate:self];
  [tokenField setTarget:self];
  [tokenField setAction:@selector(handleInputChanged:)];
  
  [tokenField setTokenizingCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
  
  [self makeStretchableView:tokenField minimumWidth:220];
  [tokenField.heightAnchor constraintEqualToConstant:34.0].active = YES;
  
  applyStyleToView(tokenField, self.currentBackgroundColor, self.currentFontColor);
  
  self.controlsByName[[name lowercaseString]] = tokenField;
  [self addControlToLayout:tokenField];
  return tokenField;
}

- (NSView *)makeStepperWithName:(NSString *)name minValue:(double)minValue maxValue:(double)maxValue step:(double)step value:(double)value {
  NSStackView *row = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [row setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [row setSpacing:8.0];
  [self configureRowStack:row];
  
  NSStepper *stepper = [[NSStepper alloc] initWithFrame:NSZeroRect];
  [stepper setMinValue:minValue];
  [stepper setMaxValue:maxValue];
  [stepper setIncrement:step > 0 ? step : 1];
  [stepper setDoubleValue:value];
  [stepper setValueWraps:NO];
  [stepper setAutorepeat:YES];
  [stepper setTarget:self];
  [stepper setAction:@selector(handleStandaloneStepperChanged:)];
  [stepper setWantsLayer:YES];
  
  NSTextField *label = [NSTextField labelWithString:[NSString stringWithFormat:@"%.0f", value]];
  [label.widthAnchor constraintGreaterThanOrEqualToConstant:40].active = YES;
  [label setWantsLayer:YES];
  if (self.currentFontColor) {
    [label setTextColor:self.currentFontColor];
  }
  
  [row addArrangedSubview:stepper];
  [row addArrangedSubview:label];
  
  self.controlsByName[[name lowercaseString]] = stepper;
  [self addControlToLayout:row];
  return stepper;
}

- (void)handleStandaloneStepperChanged:(id)sender {
  NSStepper *stepper = (NSStepper *)sender;
  NSView *parent = stepper.superview;
  if ([parent isKindOfClass:[NSStackView class]]) {
    NSStackView *row = (NSStackView *)parent;
    if (row.arrangedSubviews.count > 1 && [row.arrangedSubviews[1] isKindOfClass:[NSTextField class]]) {
      NSTextField *label = (NSTextField *)row.arrangedSubviews[1];
      [label setStringValue:[NSString stringWithFormat:@"%.0f", [stepper doubleValue]]];
    }
  }
  NSString *name = [self nameForControl:stepper];
  if (name && self.win_ptr) {
    NSString *valStr = [NSString stringWithFormat:@"%.0f", [stepper doubleValue]];
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [valStr UTF8String]);
  }
}

- (NSView *)makeHelpButtonWithName:(NSString *)name {
  NSButton *button = [NSButton buttonWithTitle:@"" target:self action:@selector(handleButtonClicked:)];
  [button setBezelStyle:NSBezelStyleHelpButton];
  [button setTranslatesAutoresizingMaskIntoConstraints:NO];
  [button.widthAnchor constraintEqualToConstant:24.0].active = YES;
  [button.heightAnchor constraintEqualToConstant:24.0].active = YES;
  [button setWantsLayer:NO];
  
  self.controlsByName[[name lowercaseString]] = button;
  [self addControlToLayout:button];
  return button;
}

- (NSView *)makeKnobWithName:(NSString *)name minValue:(double)minValue maxValue:(double)maxValue value:(double)value {
  NSStackView *row = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [row setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [row setSpacing:10.0];
  [self configureRowStack:row];
  
  NSSlider *knob = [[NSSlider alloc] initWithFrame:NSZeroRect];
  [knob setSliderType:NSSliderTypeCircular];
  [knob setMinValue:minValue];
  [knob setMaxValue:maxValue];
  [knob setDoubleValue:value];
  [knob setTarget:self];
  [knob setAction:@selector(handleSliderChanged:)];
  [knob setTranslatesAutoresizingMaskIntoConstraints:NO];
  [knob.widthAnchor constraintEqualToConstant:36.0].active = YES;
  [knob.heightAnchor constraintEqualToConstant:36.0].active = YES;
  [knob setWantsLayer:YES];
  
  NSTextField *label = [NSTextField labelWithString:[NSString stringWithFormat:@"Value: %d", (int)value]];
  [label.widthAnchor constraintEqualToConstant:100].active = YES;
  [label setWantsLayer:YES];
  if (self.currentFontColor) {
    [label setTextColor:self.currentFontColor];
  }
  
  [row addArrangedSubview:knob];
  [row addArrangedSubview:label];
  
  self.controlsByName[[name lowercaseString]] = knob;
  [self addControlToLayout:row];
  return knob;
}

- (NSView *)makePullDownWithName:(NSString *)name title:(NSString *)title items:(NSArray<NSString *> *)items {
  NSPopUpButton *popup = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:YES];
  [popup addItemWithTitle:title ?: @""];
  for (NSString *item in items) {
    [popup addItemWithTitle:item];
  }
  [popup setTarget:self];
  [popup setAction:@selector(handlePullDownChanged:)];
  [self makeStretchableView:popup minimumWidth:180];
  [popup setWantsLayer:YES];
  
  self.controlsByName[[name lowercaseString]] = popup;
  [self addControlToLayout:popup];
  return popup;
}

- (void)handlePullDownChanged:(id)sender {
  NSPopUpButton *popup = (NSPopUpButton *)sender;
  NSString *choice = [popup titleOfSelectedItem] ?: @"";
  NSString *name = [self nameForControl:popup];
  if (name && self.win_ptr) {
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [choice UTF8String]);
  }
}

- (NSView *)makeImageButtonWithName:(NSString *)name symbol:(NSString *)symbolName title:(NSString *)title {
  ModernButton *button = [ModernButton buttonWithTitle:title ?: @"" target:self action:@selector(handleButtonClicked:)];
  [button setIdentifier:name];
  [button setBezelStyle:NSBezelStyleRounded];
  if (@available(macOS 11.0, *)) {
    NSImage *img = [NSImage imageWithSystemSymbolName:symbolName accessibilityDescription:(title.length > 0 ? title : symbolName)];
    if (img) {
      [button setImage:img];
      [button setImagePosition:(title.length > 0 ? NSImageLeading : NSImageOnly)];
    }
  }
  [self makeStretchableView:button minimumWidth:60];
  applyStyleToView(button, self.currentBackgroundColor, self.currentFontColor);
  
  self.controlsByName[[name lowercaseString]] = button;
  [self addControlToLayout:button];
  return button;
}

- (void)handleInputChanged:(id)sender {
  NSString *name = [self nameForControl:sender];
  if (name && self.win_ptr) {
    NSString *value = [(NSTextField *)sender stringValue];
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [value UTF8String]);
  }
}

- (void)controlTextDidChange:(NSNotification *)notification {
  NSView *control = (NSView *)notification.object;
  NSString *name = [self nameForControl:control];
  if (name && self.win_ptr) {
    NSString *value = [(NSTextField *)control stringValue];
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [value UTF8String]);
  }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector {
  if (commandSelector == @selector(insertNewline:)) {
    NSString *name = [self nameForControl:(NSView *)control];
    if (name && self.win_ptr) {
      NSString *value = [control respondsToSelector:@selector(stringValue)] ? [(NSTextField *)control stringValue] : @"";
      vlang_dispatch_event(self.win_ptr, [name UTF8String], "enter", [value UTF8String]);
    }
  }
  return NO;
}

- (void)textDidChange:(NSNotification *)notification {
  NSView *control = (NSView *)notification.object;
  NSString *name = [self nameForControl:control];
  if (name && self.win_ptr) {
    NSString *value = [(NSTextView *)control string];
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [value UTF8String]);
  }
}

- (BOOL)gridRowMatchesQuery:(NSArray *)row query:(NSString *)query {
  if (!query || query.length == 0) return YES;
  NSString *needle = [query lowercaseString];
  for (id cell in row) {
    NSString *value = [NSString stringWithFormat:@"%@", cell ?: @""];
    if ([value.lowercaseString containsString:needle]) {
      return YES;
    }
  }
  return NO;
}

- (NSArray *)visibleRowsForGridName:(NSString *)name {
  NSString *key = [[name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if (!self.gridItemsByName || !self.gridItemsByName[key]) {
    return @[];
  }

  NSArray *allRows = self.gridItemsByName[key];
  NSMutableArray *visibleRows = [NSMutableArray array];
  NSMutableArray *visibleIndexes = [NSMutableArray array];
  NSString *query = self.gridFiltersByName[key];

  for (NSUInteger i = 0; i < allRows.count; i++) {
    NSArray *row = allRows[i];
    if ([self gridRowMatchesQuery:row query:query]) {
      [visibleRows addObject:row];
      [visibleIndexes addObject:@(i)];
    }
  }

  if (!self.gridVisibleRowIndexesByName) {
    self.gridVisibleRowIndexesByName = [NSMutableDictionary dictionary];
  }
  self.gridVisibleRowIndexesByName[key] = visibleIndexes;
  return visibleRows;
}

// NSTableViewDataSource methods
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  NSString *name = tableView.identifier;
  if (!name) return 0;
  NSString *key = [[name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  if (self.gridItemsByName && self.gridItemsByName[key]) {
    NSArray *rows = [self visibleRowsForGridName:name];
    return rows.count;
  }
  
  if (self.tableItemsByName && self.tableItemsByName[key]) {
    NSArray *rows = self.tableItemsByName[key];
    return rows.count;
  }
  
  NSArray *items = self.listItemsByName[key];
  return items ? items.count : 0;
}

- (BOOL)isGridCellEditableWithName:(NSString *)name row:(NSInteger)row col:(NSInteger)col {
  NSString *key = [[name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  if (self.gridColumnTypesByName && self.gridColumnTypesByName[key]) {
    NSArray *types = self.gridColumnTypesByName[key];
    if (col >= 0 && col < types.count) {
      if ([types[col] isEqualToString:@"readonly"]) {
        return NO;
      }
    }
  }
  
  if (self.gridReadOnlyColsByName && self.gridReadOnlyColsByName[key]) {
    NSSet *cols = self.gridReadOnlyColsByName[key];
    if ([cols containsObject:@(col)]) {
      return NO;
    }
  }
  
  if (self.gridReadOnlyRowsByName && self.gridReadOnlyRowsByName[key]) {
    NSSet *rows = self.gridReadOnlyRowsByName[key];
    if ([rows containsObject:@(row)]) {
      return NO;
    }
  }
  
  if (self.gridReadOnlyCellsByName && self.gridReadOnlyCellsByName[key]) {
    NSSet *cells = self.gridReadOnlyCellsByName[key];
    NSString *cellCoord = [NSString stringWithFormat:@"%ld_%ld", (long)row, (long)col];
    if ([cells containsObject:cellCoord]) {
      return NO;
    }
  }
  
  return YES;
}

- (BOOL)isGridCellEnabledWithName:(NSString *)name row:(NSInteger)row col:(NSInteger)col {
  NSString *key = [[name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  if (self.gridDisabledColsByName && self.gridDisabledColsByName[key]) {
    NSSet *cols = self.gridDisabledColsByName[key];
    if ([cols containsObject:@(col)]) {
      return NO;
    }
  }
  
  if (self.gridDisabledRowsByName && self.gridDisabledRowsByName[key]) {
    NSSet *rows = self.gridDisabledRowsByName[key];
    if ([rows containsObject:@(row)]) {
      return NO;
    }
  }
  
  if (self.gridDisabledCellsByName && self.gridDisabledCellsByName[key]) {
    NSSet *cells = self.gridDisabledCellsByName[key];
    NSString *cellCoord = [NSString stringWithFormat:@"%ld_%ld", (long)row, (long)col];
    if ([cells containsObject:cellCoord]) {
      return NO;
    }
  }
  
  return YES;
}

// NSTableViewDelegate methods
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  NSString *name = tableView.identifier;
  if (!name) return nil;
  NSString *key = [[name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  if (self.gridItemsByName && self.gridItemsByName[key]) {
    NSArray *rows = [self visibleRowsForGridName:name];
    if (row < 0 || row >= rows.count) return nil;
    NSArray *cols = rows[row];
    
    NSArray *visibleIndexes = self.gridVisibleRowIndexesByName[key];
    NSInteger originalRow = (visibleIndexes && row < visibleIndexes.count) ? [visibleIndexes[row] integerValue] : row;
    
    NSString *colId = tableColumn.identifier;
    int colIdx = 0;
    if ([colId hasPrefix:@"Col_"]) {
      colIdx = [[colId substringFromIndex:4] intValue];
    }
    if (colIdx < 0 || colIdx >= cols.count) return nil;
    
    BOOL isCheckbox = NO;
    BOOL isButton = NO;
    if (self.gridColumnTypesByName && self.gridColumnTypesByName[key]) {
      NSArray *types = self.gridColumnTypesByName[key];
      if (colIdx >= 0 && colIdx < types.count) {
        if ([types[colIdx] isEqualToString:@"checkbox"]) {
          isCheckbox = YES;
        } else if ([types[colIdx] isEqualToString:@"button"]) {
          isButton = YES;
        }
      }
    }
    
    if (isButton) {
      NSTableCellView *cell = [tableView makeViewWithIdentifier:@"GridButtonCell" owner:self];
      NSButton *btn = nil;
      if (!cell) {
        cell = [[NSTableCellView alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)];
        btn = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)];
        [btn setBezelStyle:NSBezelStyleRounded];
        [btn setTarget:self];
        [btn setAction:@selector(handleGridButtonClicked:)];
        [cell addSubview:btn];
        
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
          [btn.leadingAnchor constraintEqualToAnchor:cell.leadingAnchor constant:4],
          [btn.trailingAnchor constraintEqualToAnchor:cell.trailingAnchor constant:-4],
          [btn.centerYAnchor constraintEqualToAnchor:cell.centerYAnchor]
        ]];
        
        btn.tag = 998;
        [btn release];
      } else {
        btn = [cell viewWithTag:998];
      }
      
      BOOL isCellEnabled = [self isGridCellEnabledWithName:name row:row col:colIdx];
      [btn setIdentifier:[NSString stringWithFormat:@"%ld_%d", (long)row, colIdx]];
      [btn setTitle:cols[colIdx]];
      [btn setEnabled:isCellEnabled];
      return cell;
    }
    
    if (isCheckbox) {
      NSTableCellView *cell = [tableView makeViewWithIdentifier:@"GridCheckboxCell" owner:self];
      NSButton *checkbox = nil;
      if (!cell) {
        cell = [[NSTableCellView alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)];
        checkbox = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)];
        [checkbox setButtonType:NSButtonTypeSwitch];
        [checkbox setTitle:@""];
        [checkbox setTarget:self];
        [checkbox setAction:@selector(handleGridCheckboxClicked:)];
        [cell addSubview:checkbox];
        
        checkbox.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[
          [checkbox.centerXAnchor constraintEqualToAnchor:cell.centerXAnchor],
          [checkbox.centerYAnchor constraintEqualToAnchor:cell.centerYAnchor]
        ]];
        
        checkbox.tag = 999;
        [checkbox release];
      } else {
        checkbox = [cell viewWithTag:999];
      }
      
      [checkbox setIdentifier:[NSString stringWithFormat:@"%ld_%d", (long)row, colIdx]];
      NSString *val = cols[colIdx];
      if ([val isEqualToString:@"true"] || [val isEqualToString:@"1"] || [val isEqualToString:@"yes"]) {
        [checkbox setState:NSControlStateValueOn];
      } else {
        [checkbox setState:NSControlStateValueOff];
      }
      BOOL isCellEnabled = [self isGridCellEnabledWithName:name row:row col:colIdx];
      [checkbox setEnabled:isCellEnabled];
      return cell;
    }
    
    BOOL isCellEnabled = [self isGridCellEnabledWithName:name row:row col:colIdx];
    BOOL isEditable = isCellEnabled && [self isGridCellEditableWithName:name row:row col:colIdx];
    
    NSTableCellView *cell = [tableView makeViewWithIdentifier:@"GridCell" owner:self];
    if (!cell) {
      cell = [[NSTableCellView alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)];
      NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)];
      [textField setBezeled:NO];
      [textField setDrawsBackground:NO];
      [textField setEditable:YES];
      [textField setSelectable:YES];
      [textField setDelegate:self];
      [cell addSubview:textField];
      cell.textField = textField;
      
      textField.translatesAutoresizingMaskIntoConstraints = NO;
      [NSLayoutConstraint activateConstraints:@[
        [textField.leadingAnchor constraintEqualToAnchor:cell.leadingAnchor constant:4],
        [textField.trailingAnchor constraintEqualToAnchor:cell.trailingAnchor constant:-4],
        [textField.topAnchor constraintEqualToAnchor:cell.topAnchor constant:2],
        [textField.bottomAnchor constraintEqualToAnchor:cell.bottomAnchor constant:-2]
      ]];
    }
    [cell.textField setIdentifier:[NSString stringWithFormat:@"%ld_%d", (long)originalRow, colIdx]];
    [cell.textField setStringValue:cols[colIdx]];
    [cell.textField setEditable:isEditable];
    [cell.textField setSelectable:YES];
    [cell.textField setWantsLayer:YES];
    [cell.textField setDrawsBackground:NO];
    NSString *cellCoord = [NSString stringWithFormat:@"%ld_%d", (long)originalRow, colIdx];
    NSString *selectedCoord = self.gridSelectionByName[key];
    NSInteger selectedRow = -1;
    NSInteger selectedCol = -1;
    if (selectedCoord) {
      NSArray *parts = [selectedCoord componentsSeparatedByString:@"_"];
      if (parts.count >= 1) {
        selectedRow = [parts[0] integerValue];
      }
      if (parts.count >= 2) {
        selectedCol = [parts[1] integerValue];
      }
    }
    BOOL isSelectedCell = (selectedRow == originalRow && selectedCol == colIdx);
    BOOL isSelectedRow = (selectedRow == originalRow && selectedCol < 0);
    BOOL isSelectedColumn = (selectedCol == colIdx && selectedRow < 0);
    if (isSelectedCell) {
      [cell.textField setDrawsBackground:YES];
      [cell.textField setBackgroundColor:[NSColor selectedControlColor]];
      [cell.textField.layer setBorderWidth:1.2];
      [cell.textField.layer setBorderColor:[[NSColor controlAccentColor] CGColor]];
    } else if (isSelectedRow || isSelectedColumn) {
      [cell.textField setDrawsBackground:YES];
      [cell.textField setBackgroundColor:[[NSColor controlAccentColor] colorWithAlphaComponent:0.14]];
      [cell.textField.layer setBorderWidth:0.8];
      [cell.textField.layer setBorderColor:[[NSColor controlAccentColor] colorWithAlphaComponent:0.5].CGColor];
    } else {
      [cell.textField setDrawsBackground:NO];
      [cell.textField setBackgroundColor:[NSColor clearColor]];
      [cell.textField.layer setBorderWidth:0.0];
    }
    if (isCellEnabled) {
      if (self.currentFontColor) {
        [cell.textField setTextColor:self.currentFontColor];
      } else {
        [cell.textField setTextColor:[NSColor controlTextColor]];
      }
    } else {
      [cell.textField setTextColor:[NSColor disabledControlTextColor]];
    }
    return cell;
  }
  
  if (self.tableItemsByName && self.tableItemsByName[key]) {
    NSArray *rows = self.tableItemsByName[key];
    if (row < 0 || row >= rows.count) return nil;
    NSArray *cols = rows[row];
    
    NSString *colId = tableColumn.identifier;
    int colIdx = 0;
    if ([colId hasPrefix:@"Col_"]) {
      colIdx = [[colId substringFromIndex:4] intValue];
    }
    if (colIdx < 0 || colIdx >= cols.count) return nil;
    
    NSTableCellView *cell = [tableView makeViewWithIdentifier:@"TableCell" owner:self];
    if (!cell) {
      cell = [[NSTableCellView alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)];
      NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)];
      [textField setBezeled:NO];
      [textField setDrawsBackground:NO];
      [textField setEditable:NO];
      [textField setSelectable:NO];
      [cell addSubview:textField];
      cell.textField = textField;
      
      textField.translatesAutoresizingMaskIntoConstraints = NO;
      [NSLayoutConstraint activateConstraints:@[
        [textField.leadingAnchor constraintEqualToAnchor:cell.leadingAnchor constant:4],
        [textField.trailingAnchor constraintEqualToAnchor:cell.trailingAnchor constant:-4],
        [textField.topAnchor constraintEqualToAnchor:cell.topAnchor constant:2],
        [textField.bottomAnchor constraintEqualToAnchor:cell.bottomAnchor constant:-2]
      ]];
    }
    [cell.textField setStringValue:cols[colIdx]];
    if (self.currentFontColor) {
      [cell.textField setTextColor:self.currentFontColor];
    }
    return cell;
  }
  
  NSArray *items = self.listItemsByName[key];
  if (!items || row < 0 || row >= items.count) return nil;
  
  NSTableCellView *cell = [tableView makeViewWithIdentifier:@"ListCell" owner:self];
  if (!cell) {
    cell = [[NSTableCellView alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)];
    NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)];
    [textField setBezeled:NO];
    [textField setDrawsBackground:NO];
    [textField setEditable:NO];
    [textField setSelectable:NO];
    [cell addSubview:textField];
    cell.textField = textField;
    
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
      [textField.leadingAnchor constraintEqualToAnchor:cell.leadingAnchor constant:4],
      [textField.trailingAnchor constraintEqualToAnchor:cell.trailingAnchor constant:-4],
      [textField.topAnchor constraintEqualToAnchor:cell.topAnchor constant:2],
      [textField.bottomAnchor constraintEqualToAnchor:cell.bottomAnchor constant:-2]
    ]];
  }
  [cell.textField setStringValue:items[row]];
  [cell.textField setTextColor:self.currentFontColor ?: [NSColor labelColor]];
  [cell.textField setFont:[NSFont systemFontOfSize:13]];
  [cell.textField setDrawsBackground:NO];
  [cell.textField setBackgroundColor:[NSColor clearColor]];
  [cell setBackgroundStyle:NSBackgroundStyleNormal];
  return cell;
}

- (void)updateGridSelectionHighlightForTableView:(NSTableView *)tableView row:(NSInteger)row col:(NSInteger)col {
  NSString *name = tableView.identifier;
  if (!name) return;
  NSString *key = [[name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if (!self.gridSelectionByName) {
    self.gridSelectionByName = [NSMutableDictionary dictionary];
  }
  if (row >= 0 || col >= 0) {
    self.gridSelectionByName[key] = [NSString stringWithFormat:@"%ld_%ld", (long)row, (long)col];
  } else {
    [self.gridSelectionByName removeObjectForKey:key];
  }
  [tableView reloadData];
}

- (NSComparisonResult)compareGridValue:(NSString *)aValue withValue:(NSString *)bValue ascending:(BOOL)ascending {
  NSString *left = aValue ?: @"";
  NSString *right = bValue ?: @"";

  NSNumber *leftNumber = [NSNumber numberWithDouble:[left doubleValue]];
  NSNumber *rightNumber = [NSNumber numberWithDouble:[right doubleValue]];
  if ([leftNumber doubleValue] != 0.0 || [rightNumber doubleValue] != 0.0 || [left isEqualToString:@"0"] || [right isEqualToString:@"0"]) {
    BOOL leftNumeric = [left rangeOfString:@"[^0-9.+-]" options:NSRegularExpressionSearch].location == NSNotFound;
    BOOL rightNumeric = [right rangeOfString:@"[^0-9.+-]" options:NSRegularExpressionSearch].location == NSNotFound;
    if (leftNumeric && rightNumeric) {
      double leftDouble = [left doubleValue];
      double rightDouble = [right doubleValue];
      if (leftDouble < rightDouble) {
        return ascending ? NSOrderedAscending : NSOrderedDescending;
      }
      if (leftDouble > rightDouble) {
        return ascending ? NSOrderedDescending : NSOrderedAscending;
      }
      return NSOrderedSame;
    }
  }

  NSComparisonResult result = [left localizedCaseInsensitiveCompare:right];
  if (result != NSOrderedSame) {
    return ascending ? result : (result == NSOrderedAscending ? NSOrderedDescending : NSOrderedAscending);
  }
  return NSOrderedSame;
}

- (void)applyGridSortForTableView:(NSTableView *)tableView descriptors:(NSArray *)descriptors {
  NSString *name = tableView.identifier;
  if (!name) return;
  NSString *key = [[name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if (!self.gridItemsByName || !self.gridItemsByName[key]) return;

  NSMutableArray *rows = self.gridItemsByName[key];
  if (!rows || rows.count == 0) return;

  NSMutableArray *sortedRows = [rows mutableCopy];
  [sortedRows sortUsingComparator:^NSComparisonResult(NSArray *rowA, NSArray *rowB) {
    for (NSDictionary *descriptor in descriptors) {
      NSInteger colIdx = [descriptor[@"column"] integerValue];
      BOOL ascending = [descriptor[@"ascending"] boolValue];
      NSString *aValue = (colIdx >= 0 && colIdx < rowA.count) ? [rowA[colIdx] description] : @"";
      NSString *bValue = (colIdx >= 0 && colIdx < rowB.count) ? [rowB[colIdx] description] : @"";
      NSComparisonResult result = [self compareGridValue:aValue withValue:bValue ascending:ascending];
      if (result != NSOrderedSame) {
        return result;
      }
    }
    return NSOrderedSame;
  }];

  self.gridItemsByName[key] = sortedRows;
  [tableView reloadData];
}

- (void)refreshGridHeaderTitlesForTableView:(NSTableView *)tableView {
  NSString *name = tableView.identifier;
  if (!name) return;
  NSString *key = [[name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if (!self.gridHeadersByName || !self.gridHeadersByName[key]) return;

  if (!self.gridSortDescriptorsByName) {
    self.gridSortDescriptorsByName = [NSMutableDictionary dictionary];
  }

  NSArray *headers = self.gridHeadersByName[key];
  NSArray *descriptors = self.gridSortDescriptorsByName[key] ?: @[];
  for (NSUInteger i = 0; i < tableView.tableColumns.count; i++) {
    NSTableColumn *column = tableView.tableColumns[i];
    NSString *baseTitle = (i < headers.count) ? headers[i] : column.title;
    if ([baseTitle hasSuffix:@" ▲"] || [baseTitle hasSuffix:@" ▼"]) {
      baseTitle = [baseTitle substringToIndex:baseTitle.length - 2];
    }
    NSString *suffix = @"";
    for (NSDictionary *descriptor in descriptors) {
      if ([descriptor[@"column"] integerValue] == (NSInteger)i) {
        suffix = [descriptor[@"ascending"] boolValue] ? @" ▲" : @" ▼";
        break;
      }
    }
    [column setTitle:[NSString stringWithFormat:@"%@%@", baseTitle, suffix]];
  }

  if (tableView.headerView) {
    [tableView.headerView setNeedsDisplay:YES];
  }
  [tableView setNeedsDisplay:YES];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  NSTableView *tableView = notification.object;
  NSString *name = tableView.identifier;
  if (name && self.win_ptr) {
    if ([tableView isKindOfClass:[NSOutlineView class]]) {
      return; // Handled by outlineViewSelectionDidChange
    }
    NSInteger selectedRow = [tableView selectedRow];
    NSInteger selectedCol = [tableView selectedColumn];
    if (selectedRow >= 0 && selectedCol >= 0) {
      [self updateGridSelectionHighlightForTableView:tableView row:selectedRow col:selectedCol];
    } else {
      [self updateGridSelectionHighlightForTableView:tableView row:-1 col:-1];
    }
    NSString *value = [NSString stringWithFormat:@"%ld", (long)selectedRow];
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [value UTF8String]);
  }
}

- (void)handleListDoubleClick:(id)sender {
  if (![sender isKindOfClass:[NSTableView class]]) return;
  NSTableView *tableView = (NSTableView *)sender;
  NSString *name = tableView.identifier;
  if (name && self.win_ptr) {
    NSInteger row = [tableView clickedRow];
    if (row < 0) row = [tableView selectedRow];
    if (row < 0) return;
    NSString *value = [NSString stringWithFormat:@"%ld", (long)row];
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "dblclick", [value UTF8String]);
  }
}

- (TreeItem *)findTreeItemWithId:(NSString *)targetId inItems:(NSArray<TreeItem *> *)items {
  for (TreeItem *item in items) {
    if ([item.itemId isEqualToString:targetId]) {
      return item;
    }
    TreeItem *found = [self findTreeItemWithId:targetId inItems:item.children];
    if (found) {
      return found;
    }
  }
  return nil;
}

// NSOutlineViewDataSource methods
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
  NSString *name = outlineView.identifier;
  if (!name) return 0;
  NSString *key = [[name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  if (item == nil) {
    NSArray<TreeItem *> *roots = self.treeItemsByName[key];
    return roots ? roots.count : 0;
  } else {
    TreeItem *treeItem = (TreeItem *)item;
    return treeItem.children.count;
  }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
  NSString *name = outlineView.identifier;
  if (!name) return nil;
  NSString *key = [[name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  if (item == nil) {
    NSArray<TreeItem *> *roots = self.treeItemsByName[key];
    return (roots && index >= 0 && index < roots.count) ? roots[index] : nil;
  } else {
    TreeItem *treeItem = (TreeItem *)item;
    return (index >= 0 && index < treeItem.children.count) ? treeItem.children[index] : nil;
  }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
  if (item == nil) {
    return YES;
  }
  TreeItem *treeItem = (TreeItem *)item;
  return treeItem.children.count > 0;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
  TreeItem *treeItem = (TreeItem *)item;
  return treeItem.text;
}

// NSOutlineViewDelegate methods
- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
  NSTableCellView *cell = [outlineView makeViewWithIdentifier:@"TreeCell" owner:self];
  if (!cell) {
    cell = [[NSTableCellView alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)];
    NSTextField *textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 100, 20)];
    [textField setBezeled:NO];
    [textField setDrawsBackground:NO];
    [textField setEditable:NO];
    [textField setSelectable:NO];
    [cell addSubview:textField];
    cell.textField = textField;
    
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
      [textField.leadingAnchor constraintEqualToAnchor:cell.leadingAnchor constant:4],
      [textField.trailingAnchor constraintEqualToAnchor:cell.trailingAnchor constant:-4],
      [textField.topAnchor constraintEqualToAnchor:cell.topAnchor constant:2],
      [textField.bottomAnchor constraintEqualToAnchor:cell.bottomAnchor constant:-2]
    ]];
  }
  
  TreeItem *treeItem = (TreeItem *)item;
  [cell.textField setStringValue:treeItem.text];
  [cell.textField setTextColor:self.currentFontColor ?: [NSColor labelColor]];
  [cell.textField setFont:[NSFont systemFontOfSize:13]];
  [cell.textField setDrawsBackground:NO];
  [cell.textField setBackgroundColor:[NSColor clearColor]];
  [cell setBackgroundStyle:NSBackgroundStyleNormal];
  return cell;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
  NSOutlineView *outlineView = notification.object;
  NSString *name = outlineView.identifier;
  if (name && self.win_ptr) {
    NSInteger selectedRow = [outlineView selectedRow];
    TreeItem *item = [outlineView itemAtRow:selectedRow];
    NSString *value = item ? item.itemId : @"";
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [value UTF8String]);
  }
}

// NSTextFieldDelegate Focus Gained & Lost
- (void)controlTextDidBeginEditing:(NSNotification *)notification {
  NSView *control = (NSView *)notification.object;
  NSString *name = [self nameForControl:control];
  if (name && self.win_ptr) {
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "focus", "");
  }
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
  NSView *control = (NSView *)notification.object;
  NSString *name = [self nameForControl:control];
  if (name && self.win_ptr) {
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "blur", "");
  } else if ([control isKindOfClass:[NSTextField class]]) {
    NSTextField *tf = (NSTextField *)control;
    NSString *key = tf.identifier;
    
    NSView *v = tf;
    while (v && ![v isKindOfClass:[NSTableView class]]) {
      v = v.superview;
    }
    if (v) {
      NSTableView *tv = (NSTableView *)v;
      NSString *gridName = tv.identifier;
      NSString *gridKey = [[gridName lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      if (gridName && self.gridItemsByName && self.gridItemsByName[gridKey]) {
        NSString *coords = tf.identifier;
        NSArray *parts = [coords componentsSeparatedByString:@"_"];
        if (parts.count == 2) {
          int rowIdx = [parts[0] intValue];
          int colIdx = [parts[1] intValue];
          
          NSMutableArray *rows = self.gridItemsByName[gridKey];
          if (rowIdx >= 0 && rowIdx < rows.count) {
            NSMutableArray *cols = [rows[rowIdx] mutableCopy];
            if (colIdx >= 0 && colIdx < cols.count) {
              cols[colIdx] = tf.stringValue;
              rows[rowIdx] = cols;
            }
            [cols release];
          }
          
          NSString *eventVal = [NSString stringWithFormat:@"%d:%d:%@", rowIdx, colIdx, tf.stringValue];
          vlang_dispatch_event(self.win_ptr, [gridName UTF8String], "change", [eventVal UTF8String]);
        }
      }
    } else if (tf.superview && tf.superview.superview && [tf.superview.superview isKindOfClass:[NSStackView class]]) {
      NSStackView *grid = (NSStackView *)tf.superview.superview;
      NSString *gridName = [self nameForControl:grid];
      if (gridName && self.win_ptr && key) {
        NSString *eventVal = [NSString stringWithFormat:@"%@:%@", key, tf.stringValue];
        vlang_dispatch_event(self.win_ptr, [gridName UTF8String], "change", [eventVal UTF8String]);
      }
    }
  }
}

// NSWindowDelegate Window Resized
- (void)windowDidResize:(NSNotification *)notification {
  if (self.win_ptr && self.window) {
    NSRect frame = [self.window contentRectForFrameRect:self.window.frame];
    NSString *sizeStr = [NSString stringWithFormat:@"%.0fx%.0f", frame.size.width, frame.size.height];
    vlang_dispatch_event(self.win_ptr, "window", "resize", [sizeStr UTF8String]);
  }
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
  if (self.win_ptr) {
    vlang_dispatch_event(self.win_ptr, "window", "window_focus", "");
  }
}

- (void)windowDidResignKey:(NSNotification *)notification {
  if (self.win_ptr) {
    vlang_dispatch_event(self.win_ptr, "window", "window_blur", "");
  }
}

- (void)windowDidMiniaturize:(NSNotification *)notification {
  if (self.win_ptr) {
    vlang_dispatch_event(self.win_ptr, "window", "window_minimize", "");
  }
}

- (void)windowDidDeminiaturize:(NSNotification *)notification {
  if (self.win_ptr) {
    vlang_dispatch_event(self.win_ptr, "window", "window_restore", "");
  }
}

// Hover Event Tracking Delegates
- (void)mouseEntered:(NSEvent *)event {
  NSTrackingArea *area = [event trackingArea];
  if (area) {
    NSDictionary *userInfo = [area userInfo];
    NSString *name = userInfo[@"name"];
    if (name && self.win_ptr) {
      vlang_dispatch_event(self.win_ptr, [name UTF8String], "hover_enter", "");
    }
  }
}

- (void)mouseExited:(NSEvent *)event {
  NSTrackingArea *area = [event trackingArea];
  if (area) {
    NSDictionary *userInfo = [area userInfo];
    NSString *name = userInfo[@"name"];
    if (name && self.win_ptr) {
      vlang_dispatch_event(self.win_ptr, [name UTF8String], "hover_exit", "");
    }
  }
}

- (void)handleButtonClicked:(id)sender {
  NSString *name = [self nameForControl:sender];
  if (name && self.win_ptr) {
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "click", "");
  }
}

- (void)handleLinkClicked:(id)sender {
  NSString *name = [self nameForControl:sender];
  if (name) {
    NSString *url = self.linkUrls[[name lowercaseString]];
    if (url) {
      [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
    }
    if (self.win_ptr) {
      vlang_dispatch_event(self.win_ptr, [name UTF8String], "click", "");
    }
  }
}

- (void)handleCheckboxClicked:(id)sender {
  NSString *name = [self nameForControl:sender];
  BOOL checked = [(NSButton *)sender state] == NSOnState;
  if (name && self.win_ptr) {
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", checked ? "true" : "false");
  }
}

- (void)handleDisclosureClicked:(id)sender {
  NSString *name = [self nameForControl:sender];
  BOOL open = [(NSButton *)sender state] == NSOnState;
  if (name && self.win_ptr) {
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", open ? "true" : "false");
  }
}

- (void)handleNumberChanged:(id)sender {
  NSTextField *field = nil;
  NSStepper *stepper = nil;
  if ([sender isKindOfClass:[NSStepper class]]) {
    stepper = (NSStepper *)sender;
    NSStackView *row = (NSStackView *)stepper.superview;
    field = (NSTextField *)row.arrangedSubviews[0];
    [field setDoubleValue:[stepper doubleValue]];
  } else {
    field = (NSTextField *)sender;
    NSStackView *row = (NSStackView *)field.superview;
    stepper = (NSStepper *)row.arrangedSubviews[1];
    [stepper setDoubleValue:[field doubleValue]];
  }
  NSString *name = [self nameForControl:field];
  if (name && self.win_ptr) {
    NSString *valStr = [NSString stringWithFormat:@"%.0f", [field doubleValue]];
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [valStr UTF8String]);
  }
}

- (void)handleSliderChanged:(id)sender {
  NSSlider *slider = (NSSlider *)sender;
  NSStackView *row = (NSStackView *)slider.superview;
  NSTextField *label = (NSTextField *)row.arrangedSubviews[1];
  int val = [slider intValue];
  [label setStringValue:[NSString stringWithFormat:@"Value: %d", val]];
  
  NSString *name = [self nameForControl:slider];
  if (name && self.win_ptr) {
    NSString *valStr = [NSString stringWithFormat:@"%d", val];
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [valStr UTF8String]);
  }
}

- (void)handlePopUpChanged:(id)sender {
  NSPopUpButton *popup = (NSPopUpButton *)sender;
  NSString *choice = [popup titleOfSelectedItem];
  NSString *name = [self nameForControl:popup];
  if (name && self.win_ptr) {
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [choice UTF8String]);
  }
}

- (void)handleColorWellChanged:(id)sender {
  NSColorWell *well = (NSColorWell *)sender;
  NSColor *color = [well color];
  CGFloat r=0, g=0, b=0, a=0;
  NSColor *rgbColor = [color colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
  if (rgbColor) {
    [rgbColor getRed:&r green:&g blue:&b alpha:&a];
  } else {
    [color getRed:&r green:&g blue:&b alpha:&a];
  }
  NSString *colorStr = [NSString stringWithFormat:@"#%02X%02X%02X", (int)(r * 255.99), (int)(g * 255.99), (int)(b * 255.99)];
  NSString *name = [self nameForControl:well];
  if (name && self.win_ptr) {
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [colorStr UTF8String]);
  }
}

- (void)handleDatePickerChanged:(id)sender {
  NSDatePicker *picker = (NSDatePicker *)sender;
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd"];
  NSString *dateText = [formatter stringFromDate:[picker dateValue]];
  NSString *name = [self nameForControl:picker];
  if (name && self.win_ptr) {
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [dateText UTF8String]);
  }
}

- (void)handleSegmentedChanged:(id)sender {
  NSSegmentedControl *seg = (NSSegmentedControl *)sender;
  NSInteger index = [seg selectedSegment];
  NSString *label = [seg labelForSegment:index];
  if (!label || label.length == 0) {
    label = [NSString stringWithFormat:@"%ld", (long)index];
  }
  NSString *name = [self nameForControl:seg];
  if (name && self.win_ptr) {
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [label UTF8String]);
  }
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
  NSString *name = [self nameForControl:tabView];
  NSString *label = [tabViewItem label];
  if (name && self.win_ptr) {
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [label UTF8String]);
  }
}

- (void)setupMenuBar {
  NSMenu *mainMenu = [NSApp mainMenu];
  if (!mainMenu) {
    mainMenu = [[NSMenu alloc] init];
    [NSApp setMainMenu:mainMenu];
  }
  
  NSString *appName = nil;
  if (self.params.title.str && strlen(self.params.title.str) > 0) {
    appName = nsstring(self.params.title.str);
  } else {
    appName = [[NSProcessInfo processInfo] processName];
  }
  
  NSMenuItem *appMenuItem = nil;
  for (NSMenuItem *item in mainMenu.itemArray) {
    if (item.submenu && [[item.submenu title] isEqualToString:@"App"]) {
      appMenuItem = item;
      break;
    }
  }
  if (!appMenuItem) {
    appMenuItem = [[NSMenuItem alloc] init];
    [mainMenu addItem:appMenuItem];
  }
  NSMenu *appMenu = appMenuItem.submenu;
  if (!appMenu) {
    appMenu = [[NSMenu alloc] initWithTitle:@"App"];
    [appMenuItem setSubmenu:appMenu];
  }
  if (appMenu.itemArray.count == 0) {
    NSString *aboutTitle = [NSString stringWithFormat:@"About %@", appName];
    [appMenu addItemWithTitle:aboutTitle action:@selector(orderFrontStandardAboutPanel:) keyEquivalent:@""];
    
    [appMenu addItem:[NSMenuItem separatorItem]];
    
    NSString *hideTitle = [NSString stringWithFormat:@"Hide %@", appName];
    [appMenu addItemWithTitle:hideTitle action:@selector(hide:) keyEquivalent:@"h"];
    
    NSMenuItem *hideOthersItem = [appMenu addItemWithTitle:@"Hide Others" action:@selector(hideOtherApplications:) keyEquivalent:@"h"];
    [hideOthersItem setKeyEquivalentModifierMask:NSEventModifierFlagCommand | NSEventModifierFlagOption];
    
    [appMenu addItemWithTitle:@"Show All" action:@selector(unhideAllApplications:) keyEquivalent:@""];
    
    [appMenu addItem:[NSMenuItem separatorItem]];
    
    NSString *quitTitle = [NSString stringWithFormat:@"Quit %@", appName];
    [appMenu addItemWithTitle:quitTitle action:@selector(terminate:) keyEquivalent:@"q"];
  }
  
  NSMenuItem *editMenuItem = nil;
  for (NSMenuItem *item in mainMenu.itemArray) {
    if (item.submenu && [[item.submenu title] isEqualToString:@"Edit"]) {
      editMenuItem = item;
      break;
    }
  }
  if (!editMenuItem) {
    editMenuItem = [[NSMenuItem alloc] init];
    [mainMenu addItem:editMenuItem];
  }
  NSMenu *editMenu = editMenuItem.submenu;
  if (!editMenu) {
    editMenu = [[NSMenu alloc] initWithTitle:@"Edit"];
    [editMenuItem setSubmenu:editMenu];
  }
  if (editMenu.itemArray.count == 0) {
    [editMenu addItemWithTitle:@"Undo" action:@selector(undo:) keyEquivalent:@"z"];
    [editMenu addItemWithTitle:@"Redo" action:@selector(redo:) keyEquivalent:@"Z"];
    [editMenu addItem:[NSMenuItem separatorItem]];
    [editMenu addItemWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@"x"];
    [editMenu addItemWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:@"c"];
    [editMenu addItemWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:@"v"];
    [editMenu addItemWithTitle:@"Select All" action:@selector(selectAll:) keyEquivalent:@"a"];
  }
  
  NSMenuItem *windowMenuItem = nil;
  for (NSMenuItem *item in mainMenu.itemArray) {
    if (item.submenu && [[item.submenu title] isEqualToString:@"Window"]) {
      windowMenuItem = item;
      break;
    }
  }
  if (!windowMenuItem) {
    windowMenuItem = [[NSMenuItem alloc] init];
    [mainMenu addItem:windowMenuItem];
  }
  NSMenu *windowMenu = windowMenuItem.submenu;
  if (!windowMenu) {
    windowMenu = [[NSMenu alloc] initWithTitle:@"Window"];
    [windowMenuItem setSubmenu:windowMenu];
  }
  if (windowMenu.itemArray.count == 0) {
    [windowMenu addItemWithTitle:@"Minimize" action:@selector(performMiniaturize:) keyEquivalent:@"m"];
    [windowMenu addItemWithTitle:@"Zoom" action:@selector(performZoom:) keyEquivalent:@""];
  }
  
  [NSApp setMainMenu:mainMenu];
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
  (void)notification;
  NSLog(@"applicationWillFinishLaunching");
  [self setupWindow];
  [self setupMenuBar];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  (void)notification;
  NSLog(@"applicationDidFinishLaunching");
  [self setupWindow];
  
  // Auto-fit the window to the actual content while keeping it within the visible screen.
  [self.mainStackView layoutSubtreeIfNeeded];
  NSSize fitSize = [self.mainStackView fittingSize];
  NSRect screenFrame = [[NSScreen mainScreen] visibleFrame];
  CGFloat targetWidth = self.params.width > 0 ? MAX(fitSize.width + 60.0, (CGFloat)self.params.width) : MAX(fitSize.width + 60.0, 320.0);
  CGFloat targetHeight = self.params.height > 0 ? MAX(fitSize.height + 48.0, (CGFloat)self.params.height) : MAX(fitSize.height + 48.0, 180.0);
  
  if (targetWidth > screenFrame.size.width * 0.9) {
    targetWidth = screenFrame.size.width * 0.9;
  }
  if (targetHeight > screenFrame.size.height * 0.85) {
    targetHeight = screenFrame.size.height * 0.85;
  }
  
  [self.window setContentSize:NSMakeSize(targetWidth, targetHeight)];
  [self.window center];
  
  [self.windowController showWindow:nil];
  [self.window makeKeyAndOrderFront:nil];
  [self.window orderFrontRegardless];
  [self.window makeMainWindow];
  [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
  [[NSApplication sharedApplication] arrangeInFront:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
  (void)sender;
  return YES;
}

- (BOOL)windowShouldClose:(id)sender {
  (void)sender;
  [NSApp terminate:self];
  return YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
  (void)notification;
}

- (NSMenu *)findOrCreateMenuWithName:(NSString *)menuName {
  NSMenu *mainMenu = [NSApp mainMenu];
  if (!mainMenu) {
    mainMenu = [[NSMenu alloc] init];
    [NSApp setMainMenu:mainMenu];
  }
  
  // Search existing submenus
  for (NSMenuItem *item in mainMenu.itemArray) {
    if (item.submenu && [[item.submenu title] isEqualToString:menuName]) {
      return item.submenu;
    }
  }
  
  NSInteger insertionIndex = 0;
  for (NSMenuItem *item in mainMenu.itemArray) {
    if (item.submenu && [[item.submenu title] isEqualToString:@"Edit"]) {
      insertionIndex = [mainMenu.itemArray indexOfObject:item];
      break;
    }
    if (item.submenu && [[item.submenu title] isEqualToString:@"Window"]) {
      insertionIndex = [mainMenu.itemArray indexOfObject:item];
      break;
    }
  }
  
  // Create a new top-level menu near the front so custom menus appear before the standard ones.
  NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:menuName action:nil keyEquivalent:@""];
  NSMenu *submenu = [[NSMenu alloc] initWithTitle:menuName];
  [menuItem setSubmenu:submenu];
  [mainMenu insertItem:menuItem atIndex:insertionIndex];
  return submenu;
}

- (void)handleMenuItemClicked:(id)sender {
  NSMenuItem *item = (NSMenuItem *)sender;
  NSString *name = item.representedObject;
  if (name && self.win_ptr) {
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "click", "");
  }
}

// Split View implementation
- (void)beginSplitViewWithName:(NSString *)name vertical:(BOOL)vertical {
  NSSplitView *split = [[NSSplitView alloc] initWithFrame:NSZeroRect];
  [split setVertical:vertical];
  [split setDividerStyle:NSSplitViewDividerStyleThin];
  [split setTranslatesAutoresizingMaskIntoConstraints:NO];
  [split setWantsLayer:YES];
  
  NSStackView *pane1 = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [pane1 setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [pane1 setSpacing:10.0];
  [pane1 setEdgeInsets:NSEdgeInsetsMake(8, 8, 8, 8)];
  [pane1 setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  NSStackView *pane2 = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [pane2 setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [pane2 setSpacing:10.0];
  [pane2 setEdgeInsets:NSEdgeInsetsMake(8, 8, 8, 8)];
  [pane2 setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  [split addSubview:pane1];
  [split addSubview:pane2];
  
  [self addControlToLayout:split];
  
  self.currentSplitView = split;
  self.splitPanes = [NSMutableArray arrayWithObjects:pane1, pane2, nil];
  self.activeSplitPaneIndex = 0;
  self.currentSplitPane = pane1;
  
  self.controlsByName[[name lowercaseString]] = split;
}

- (void)splitViewNextPane {
  if (self.splitPanes && self.splitPanes.count > 1) {
    self.activeSplitPaneIndex = 1;
    self.currentSplitPane = self.splitPanes[1];
  }
}

- (void)endSplitView {
  self.currentSplitView = nil;
  self.currentSplitPane = nil;
  self.splitPanes = nil;
  self.activeSplitPaneIndex = 0;
}

// Collection Grid implementation
- (NSView *)makeCollectionViewWithName:(NSString *)name itemWidth:(int)itemWidth itemHeight:(int)itemHeight {
  NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSZeroRect];
  [scroll setHasVerticalScroller:YES];
  [scroll setHasHorizontalScroller:NO];
  [scroll setBorderType:NSNoBorder];
  [scroll setWantsLayer:YES];
  scroll.layer.cornerRadius = 8.0;
  scroll.layer.borderWidth = 1.0;
  scroll.layer.borderColor = [modernBorderColor() CGColor];
  
  [scroll.heightAnchor constraintEqualToConstant:250].active = YES;
  
  NSCollectionViewFlowLayout *layout = [[NSCollectionViewFlowLayout alloc] init];
  [layout setItemSize:NSMakeSize(itemWidth > 0 ? itemWidth : 100, itemHeight > 0 ? itemHeight : 100)];
  [layout setMinimumInteritemSpacing:10];
  [layout setMinimumLineSpacing:10];
  [layout setSectionInset:NSEdgeInsetsMake(10, 10, 10, 10)];
  
  NSCollectionView *collectionView = [[NSCollectionView alloc] initWithFrame:NSZeroRect];
  [collectionView setCollectionViewLayout:layout];
  [collectionView setIdentifier:name];
  [collectionView setDataSource:self];
  [collectionView setDelegate:self];
  [collectionView setSelectable:YES];
  [collectionView setAllowsMultipleSelection:NO];
  
  [collectionView registerClass:[SimpleCollectionItem class] forItemWithIdentifier:@"SimpleCollectionItem"];
  
  [scroll setDocumentView:collectionView];
  
  applyStyleToView(scroll, self.currentBackgroundColor, self.currentFontColor);
  
  NSString *key = [[name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  [self addControlToLayout:scroll];
  self.controlsByName[key] = collectionView;
  return scroll;
}

// Collection View Datasource / Delegate
- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView {
  return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  NSString *key = [[collectionView identifier] lowercaseString];
  if (self.collectionItemsByName && self.collectionItemsByName[key]) {
    return [self.collectionItemsByName[key] count];
  }
  return 0;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath {
  SimpleCollectionItem *item = [collectionView makeItemWithIdentifier:@"SimpleCollectionItem" forIndexPath:indexPath];
  
  NSString *key = [[collectionView identifier] lowercaseString];
  if (self.collectionItemsByName && self.collectionItemsByName[key]) {
    NSString *rawVal = self.collectionItemsByName[key][indexPath.item];
    NSArray *parts = [rawVal componentsSeparatedByString:@"|"];
    NSString *labelVal = parts.firstObject;
    NSString *imageVal = parts.count > 1 ? parts[1] : nil;
    
    item.customLabel.stringValue = labelVal;
    if (imageVal && imageVal.length > 0) {
      NSImage *img = [[NSImage alloc] initWithContentsOfFile:imageVal];
      item.customImageView.image = img;
    } else {
      item.customImageView.image = nil;
    }
  }
  return item;
}

- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths {
  NSIndexPath *path = [indexPaths anyObject];
  if (path && self.win_ptr) {
    NSString *key = [[collectionView identifier] lowercaseString];
    NSString *val = [NSString stringWithFormat:@"%ld", (long)path.item];
    vlang_dispatch_event(self.win_ptr, [key UTF8String], "click", [val UTF8String]);
  }
}

// Calendar View implementation
- (NSView *)makeCalendarWithName:(NSString *)name date:(NSString *)dateString {
  NSDatePicker *picker = [[NSDatePicker alloc] initWithFrame:NSZeroRect];
  [picker setDatePickerStyle:NSDatePickerStyleClockAndCalendar];
  [picker setDatePickerMode:NSDatePickerModeSingle];
  
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd"];
  NSDate *date = [formatter dateFromString:dateString] ?: [NSDate date];
  [picker setDateValue:date];
  [picker setTarget:self];
  [picker setAction:@selector(handleDatePickerChanged:)];
  [picker setWantsLayer:YES];
  
  applyStyleToView(picker, self.currentBackgroundColor, self.currentFontColor);
  
  self.controlsByName[[name lowercaseString]] = picker;
  [self addControlToLayout:picker];
  return picker;
}

// Canvas implementation
- (NSView *)makeCanvasWithName:(NSString *)name height:(int)height {
  CanvasView *canvas = [[CanvasView alloc] initWithFrame:NSZeroRect];
  [canvas setTranslatesAutoresizingMaskIntoConstraints:NO];
  [canvas.heightAnchor constraintEqualToConstant:height > 0 ? height : 200].active = YES;
  [canvas setWantsLayer:YES];
  
  self.controlsByName[[name lowercaseString]] = canvas;
  [self addControlToLayout:canvas];
  return canvas;
}
// Glass Box container
- (void)beginGlassBoxWithName:(NSString *)name material:(NSString *)materialStr {
  NSVisualEffectView *glass = [[NSVisualEffectView alloc] initWithFrame:NSZeroRect];
  [glass setMaterial:materialFromString(materialStr)];
  [glass setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
  [glass setState:NSVisualEffectStateActive];
  [glass setWantsLayer:YES];
  glass.layer.cornerRadius = 12.0;
  glass.layer.masksToBounds = YES;
  glass.layer.borderWidth = 1.0;
  glass.layer.borderColor = [modernBorderColor() CGColor];
  
  NSStackView *contentStack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [contentStack setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [contentStack setSpacing:10.0];
  [contentStack setEdgeInsets:NSEdgeInsetsMake(12, 12, 12, 12)];
  [contentStack setTranslatesAutoresizingMaskIntoConstraints:NO];
  [glass addSubview:contentStack];
  
  [contentStack.topAnchor constraintEqualToAnchor:glass.topAnchor].active = YES;
  [contentStack.bottomAnchor constraintEqualToAnchor:glass.bottomAnchor].active = YES;
  [contentStack.leadingAnchor constraintEqualToAnchor:glass.leadingAnchor].active = YES;
  [contentStack.trailingAnchor constraintEqualToAnchor:glass.trailingAnchor].active = YES;
  
  [self addControlToLayout:glass];
  
  self.currentGlassBoxStack = contentStack;
  self.controlsByName[[name lowercaseString]] = glass;
}

- (void)endGlassBox {
  self.currentGlassBoxStack = nil;
}

// Badge View container
- (NSView *)makeBadgeWithName:(NSString *)name text:(NSString *)text style:(NSString *)styleStr {
  NSBox *box = [[NSBox alloc] initWithFrame:NSZeroRect];
  [box setBoxType:NSBoxCustom];
  [box setBorderType:NSNoBorder];
  [box setContentViewMargins:NSMakeSize(8, 4)];
  [box setWantsLayer:YES];
  box.layer.cornerRadius = 10.0;
  
  NSTextField *label = [NSTextField labelWithString:text];
  [label setFont:[NSFont boldSystemFontOfSize:11.0]];
  
  NSColor *bgColor = nil;
  NSColor *textColor = nil;
  
  NSString *style = [styleStr lowercaseString];
  if ([style isEqualToString:@"success"]) {
    bgColor = [NSColor colorWithCalibratedRed:0.18 green:0.49 blue:0.20 alpha:0.15];
    textColor = [NSColor systemGreenColor];
  } else if ([style isEqualToString:@"error"]) {
    bgColor = [NSColor colorWithCalibratedRed:0.83 green:0.18 blue:0.18 alpha:0.15];
    textColor = [NSColor systemRedColor];
  } else if ([style isEqualToString:@"warning"]) {
    bgColor = [NSColor colorWithCalibratedRed:0.95 green:0.60 blue:0.00 alpha:0.15];
    textColor = [NSColor systemOrangeColor];
  } else if ([style isEqualToString:@"info"]) {
    bgColor = [NSColor colorWithCalibratedRed:0.12 green:0.45 blue:0.74 alpha:0.15];
    textColor = [NSColor systemBlueColor];
  } else {
    bgColor = [NSColor colorWithCalibratedWhite:0.5 alpha:0.15];
    textColor = [NSColor secondaryLabelColor];
  }
  
  box.layer.backgroundColor = [bgColor CGColor];
  [label setTextColor:textColor];
  [box setContentView:label];
  
  [box.widthAnchor constraintEqualToAnchor:label.widthAnchor constant:16].active = YES;
  [box.heightAnchor constraintEqualToAnchor:label.heightAnchor constant:8].active = YES;
  
  self.controlsByName[[name lowercaseString]] = box;
  [self addControlToLayout:box];
  return box;
}

// Icon Segments container
- (NSView *)makeIconSegmentsWithName:(NSString *)name symbols:(NSArray<NSString *> *)symbols selected:(NSString *)selected {
  NSSegmentedControl *seg = [[NSSegmentedControl alloc] initWithFrame:NSZeroRect];
  [seg setSegmentCount:symbols.count];
  [seg setSegmentStyle:NSSegmentStyleRoundRect];
  [seg setTarget:self];
  [seg setAction:@selector(handleSegmentedChanged:)];
  [seg setWantsLayer:YES];
  
  NSInteger selectedIndex = -1;
  
  for (NSUInteger i = 0; i < symbols.count; i++) {
    NSString *sym = symbols[i];
    if (@available(macOS 11.0, *)) {
      NSImage *img = [NSImage imageWithSystemSymbolName:sym accessibilityDescription:nil];
      if (img) {
        [seg setImage:img forSegment:i];
      } else {
        [seg setLabel:sym forSegment:i];
      }
    } else {
      [seg setLabel:sym forSegment:i];
    }
    if ([sym isEqualToString:selected]) {
      selectedIndex = i;
    }
  }
  
  if (selectedIndex >= 0) {
    [seg setSelectedSegment:selectedIndex];
  }
  
  self.controlsByName[[name lowercaseString]] = seg;
  [self addControlToLayout:seg];
  return seg;
}

- (NSView *)makeConsoleWithName:(NSString *)name height:(int)height {
  NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSZeroRect];
  [scroll setIdentifier:name];
  [scroll setHasVerticalScroller:YES];
  [scroll setHasHorizontalScroller:YES];
  [scroll setBorderType:NSNoBorder];
  [scroll setWantsLayer:YES];
  scroll.layer.cornerRadius = 8.0;
  scroll.layer.borderWidth = 1.0;
  scroll.layer.borderColor = [[NSColor darkGrayColor] CGColor];
  [self makeStretchableView:scroll minimumWidth:320];
  [scroll.heightAnchor constraintEqualToConstant:height > 0 ? height : 150].active = YES;
  
  NSTextView *textView = [[NSTextView alloc] initWithFrame:NSZeroRect];
  [textView setIdentifier:name];
  [textView setMinSize:NSMakeSize(0.0, height > 0 ? height : 150.0)];
  [textView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
  [textView setVerticallyResizable:YES];
  [textView setHorizontallyResizable:YES];
  [textView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [textView setEditable:NO];
  [textView setSelectable:YES];
  [textView setWantsLayer:YES];
  [textView setTextContainerInset:NSMakeSize(8.0, 8.0)];
  
  [textView setFont:[NSFont fontWithName:@"Menlo" size:11.0] ?: [NSFont userFixedPitchFontOfSize:11.0]];
  [scroll setBackgroundColor:[NSColor colorWithRed:0.08 green:0.08 blue:0.1 alpha:1.0]];
  [textView setBackgroundColor:[NSColor colorWithRed:0.08 green:0.08 blue:0.1 alpha:1.0]];
  [textView setTextColor:[NSColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
  
  [scroll setDocumentView:textView];
  [textView release];
  
  self.controlsByName[[name lowercaseString]] = scroll;
  [self addControlToLayout:scroll];
  return scroll;
}

- (NSView *)makeChartViewWithName:(NSString *)name chartType:(NSString *)chartType height:(int)height {
  ChartView *chart = [[ChartView alloc] initWithFrame:NSZeroRect];
  [chart setIdentifier:name];
  chart.chartType = chartType;
  [self makeStretchableView:chart minimumWidth:250];
  [chart.heightAnchor constraintEqualToConstant:height > 0 ? height : 150].active = YES;
  [chart setWantsLayer:YES];
  
  self.controlsByName[[name lowercaseString]] = chart;
  [self addControlToLayout:chart];
  return chart;
}

- (NSView *)makeShortcutRecorderWithName:(NSString *)name {
  ShortcutRecorder *recorder = [[ShortcutRecorder alloc] initWithFrame:NSZeroRect];
  [recorder setIdentifier:name];
  recorder.appDelegate = self;
  [self makeStretchableView:recorder minimumWidth:180];
  [recorder.heightAnchor constraintEqualToConstant:30].active = YES;
  [recorder setWantsLayer:YES];
  
  self.controlsByName[[name lowercaseString]] = recorder;
  [self addControlToLayout:recorder];
  return recorder;
}

- (NSView *)makeCircularProgressWithName:(NSString *)name value:(double)value minVal:(double)minVal maxVal:(double)maxVal {
  CircularProgressView *cp = [[CircularProgressView alloc] initWithFrame:NSZeroRect];
  [cp setIdentifier:name];
  cp.value = value;
  cp.minValue = minVal;
  cp.maxValue = maxVal;
  [self makeStretchableView:cp minimumWidth:80];
  [cp.heightAnchor constraintEqualToConstant:100].active = YES;
  [cp setWantsLayer:YES];
  
  self.controlsByName[[name lowercaseString]] = cp;
  [self addControlToLayout:cp];
  return cp;
}

- (NSView *)makeBreadcrumbsWithName:(NSString *)name segments:(NSArray<NSString *> *)segments {
  NSStackView *stack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [stack setIdentifier:name];
  [stack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [stack setSpacing:6.0];
  [stack setAlignment:NSLayoutAttributeCenterY];
  
  for (NSUInteger i = 0; i < segments.count; i++) {
    NSString *segText = segments[i];
    NSButton *btn = [[NSButton alloc] initWithFrame:NSZeroRect];
    [btn setButtonType:NSButtonTypeMomentaryPushIn];
    [btn setBordered:NO];
    [btn setTitle:segText];
    [btn setTarget:self];
    [btn setAction:@selector(handleBreadcrumbClicked:)];
    [btn setIdentifier:segText];
    [btn setFont:[NSFont systemFontOfSize:12 weight:NSFontWeightMedium]];
    [btn setWantsLayer:YES];
    applyStyleToView(btn, nil, self.currentFontColor ?: [NSColor controlAccentColor]);
    [stack addArrangedSubview:btn];
    [btn release];
    
    if (i < segments.count - 1) {
      NSTextField *chevron = [NSTextField labelWithString:@"›"];
      [chevron setFont:[NSFont systemFontOfSize:12 weight:NSFontWeightBold]];
      [chevron setTextColor:[NSColor secondaryLabelColor]];
      [stack addArrangedSubview:chevron];
    }
  }
  
  self.controlsByName[[name lowercaseString]] = stack;
  [self addControlToLayout:stack];
  return stack;
}

- (void)handleBreadcrumbClicked:(id)sender {
  NSButton *button = (NSButton *)sender;
  NSString *segment = button.identifier;
  NSString *name = [self nameForControl:button.superview];
  if (name && self.win_ptr) {
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [segment UTF8String]);
  }
}

- (void)handleGridDoubleClicked:(id)sender {
  NSTableView *tableView = (NSTableView *)sender;
  NSInteger row = tableView.clickedRow;
  NSInteger column = tableView.clickedColumn;
  if (row != -1 && column != -1) {
    if (![self isGridCellEnabledWithName:tableView.identifier row:row col:column] ||
        ![self isGridCellEditableWithName:tableView.identifier row:row col:column]) {
      return;
    }

    NSView *view = [tableView viewAtColumn:column row:row makeIfNecessary:YES];
    if ([view isKindOfClass:[NSTableCellView class]]) {
      NSTableCellView *cellView = (NSTableCellView *)view;
      if (cellView.textField) {
        [cellView.window makeFirstResponder:cellView.textField];
      }
    }
  }
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
  NSString *name = tableView.identifier;
  if (!name) return YES;
  NSString *key = [[name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if (self.gridItemsByName && self.gridItemsByName[key]) {
    NSArray *rows = [self visibleRowsForGridName:name];
    if (row >= 0 && row < rows.count) {
      NSInteger selectedCol = [tableView clickedColumn];
      if (selectedCol < 0) {
        selectedCol = -1;
      }
      [self updateGridSelectionHighlightForTableView:tableView row:row col:selectedCol];
    }
  }
  return YES;
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn {
  NSString *name = tableView.identifier;
  if (!name) return;
  NSString *key = [[name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  if (self.gridItemsByName && self.gridItemsByName[key]) {
    NSArray *cols = tableView.tableColumns;
    NSInteger colIdx = [cols indexOfObject:tableColumn];
    if (colIdx != NSNotFound) {
      [self updateGridSelectionHighlightForTableView:tableView row:-1 col:colIdx];

      if (self.win_ptr) {
        NSString *eventVal = [NSString stringWithFormat:@"%ld", (long)colIdx];
        vlang_dispatch_event(self.win_ptr, [name UTF8String], "click_column", [eventVal UTF8String]);
      }
    }
  }
}

- (void)handleGridCheckboxClicked:(id)sender {
  NSButton *checkbox = (NSButton *)sender;
  NSString *coords = checkbox.identifier;
  NSArray *parts = [coords componentsSeparatedByString:@"_"];
  if (parts.count == 2) {
    int rowIdx = [parts[0] intValue];
    int colIdx = [parts[1] intValue];
    
    NSView *v = checkbox;
    while (v && ![v isKindOfClass:[NSTableView class]]) {
      v = v.superview;
    }
    if (v) {
      NSTableView *tv = (NSTableView *)v;
      NSString *gridName = tv.identifier;
      if (![self isGridCellEnabledWithName:gridName row:rowIdx col:colIdx] ||
          ![self isGridCellEditableWithName:gridName row:rowIdx col:colIdx]) {
        [checkbox setState:(checkbox.state == NSControlStateValueOn ? NSControlStateValueOff : NSControlStateValueOn)];
        return;
      }
      NSString *gridKey = [[gridName lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      
      NSMutableArray *rows = self.gridItemsByName[gridKey];
      if (rowIdx >= 0 && rowIdx < rows.count) {
        NSMutableArray *cols = [rows[rowIdx] mutableCopy];
        if (colIdx >= 0 && colIdx < cols.count) {
          BOOL isOn = (checkbox.state == NSControlStateValueOn);
          NSString *newVal = isOn ? @"true" : @"false";
          cols[colIdx] = newVal;
          rows[rowIdx] = cols;
          
          NSString *eventVal = [NSString stringWithFormat:@"%d:%d:%@", rowIdx, colIdx, newVal];
          vlang_dispatch_event(self.win_ptr, [gridName UTF8String], "change", [eventVal UTF8String]);
        }
        [cols release];
      }
      [tv reloadData];
    }
  }
}

- (void)handleGridButtonClicked:(id)sender {
  NSButton *btn = (NSButton *)sender;
  NSString *coords = btn.identifier;
  NSArray *parts = [coords componentsSeparatedByString:@"_"];
  if (parts.count == 2) {
    int rowIdx = [parts[0] intValue];
    int colIdx = [parts[1] intValue];
    
    NSView *v = btn;
    while (v && ![v isKindOfClass:[NSTableView class]]) {
      v = v.superview;
    }
    if (v) {
      NSTableView *tv = (NSTableView *)v;
      NSString *gridName = tv.identifier;
      if (![self isGridCellEnabledWithName:gridName row:rowIdx col:colIdx]) {
        return;
      }
      if (self.win_ptr) {
        NSString *eventVal = [NSString stringWithFormat:@"%d:%d", rowIdx, colIdx];
        vlang_dispatch_event(self.win_ptr, [gridName UTF8String], "click_cell_button", [eventVal UTF8String]);
      }
    }
  }
}

- (NSView *)makePropertyGridWithName:(NSString *)name keys:(NSArray<NSString *> *)keys values:(NSArray<NSString *> *)values {
  NSStackView *grid = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [grid setIdentifier:name];
  [grid setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [grid setSpacing:6.0];
  [grid setAlignment:NSLayoutAttributeLeading];
  
  for (NSUInteger i = 0; i < keys.count; i++) {
    NSString *key = keys[i];
    NSString *val = (i < values.count) ? values[i] : @"";
    
    NSStackView *row = [[NSStackView alloc] initWithFrame:NSZeroRect];
    [row setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
    [row setSpacing:8.0];
    [row setAlignment:NSLayoutAttributeCenterY];
    
    NSTextField *label = [NSTextField labelWithString:[NSString stringWithFormat:@"%@:", key]];
    [label setFont:[NSFont boldSystemFontOfSize:12]];
    [label setTextColor:[NSColor secondaryLabelColor]];
    [label.widthAnchor constraintEqualToConstant:120].active = YES;
    [row addArrangedSubview:label];
    
    NSTextField *valueField = [[NSTextField alloc] initWithFrame:NSZeroRect];
    [valueField setStringValue:val];
    [valueField setFont:[NSFont systemFontOfSize:12]];
    [valueField setBezeled:YES];
    [valueField setBezelStyle:NSTextFieldSquareBezel];
    [valueField setDelegate:self];
    [valueField setIdentifier:key];
    [valueField.widthAnchor constraintEqualToConstant:150].active = YES;
    [row addArrangedSubview:valueField];
    [valueField release];
    
    [grid addArrangedSubview:row];
    [row release];
  }
  
  self.controlsByName[[name lowercaseString]] = grid;
  [self addControlToLayout:grid];
  return grid;
}

- (NSView *)makeColorGridWithName:(NSString *)name colors:(NSArray<NSString *> *)colors {
  ColorGridView *cg = [[ColorGridView alloc] initWithFrame:NSZeroRect];
  [cg setIdentifier:name];
  cg.appDelegate = self;
  cg.colorHexStrings = colors;
  
  NSMutableArray *parsedColors = [NSMutableArray array];
  for (NSString *hex in colors) {
    [parsedColors addObject:colorFromHexString(hex)];
  }
  cg.colors = parsedColors;
  
  [self makeStretchableView:cg minimumWidth:200];
  
  int count = (int)colors.count;
  int cols = 6;
  int rows = (count + cols - 1) / cols;
  CGFloat calculatedHeight = rows * 40.0 + 8.0;
  [cg.heightAnchor constraintEqualToConstant:calculatedHeight].active = YES;
  
  self.controlsByName[[name lowercaseString]] = cg;
  [self addControlToLayout:cg];
  return cg;
}

- (NSView *)makeGridWithName:(NSString *)name headers:(NSArray<NSString *> *)headers {
  NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:NSZeroRect];
  [scrollView setHasVerticalScroller:YES];
  [scrollView setHasHorizontalScroller:YES];
  [scrollView setBorderType:NSNoBorder];
  [scrollView setWantsLayer:YES];
  scrollView.layer.cornerRadius = 8.0;
  scrollView.layer.borderWidth = 1.0;
  scrollView.layer.borderColor = [modernBorderColor() CGColor];
  
  [scrollView.widthAnchor constraintEqualToConstant:450].active = YES;
  [scrollView.heightAnchor constraintEqualToConstant:200].active = YES;
  
  NSTableView *tableView = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, 450, 200)];
  [tableView setAllowsMultipleSelection:NO];
  [tableView setIdentifier:name];
  [tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleNone];
  [tableView setGridStyleMask:NSTableViewSolidHorizontalGridLineMask | NSTableViewSolidVerticalGridLineMask];
  [tableView setRowHeight:26];
  [tableView setAllowsColumnResizing:YES];
  [tableView setTarget:self];
  [tableView setDoubleAction:@selector(handleGridDoubleClicked:)];
  
  if (@available(macOS 11.0, *)) {
    [tableView setStyle:NSTableViewStyleFullWidth];
  }
  
  for (NSUInteger i = 0; i < headers.count; i++) {
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"Col_%lu", (unsigned long)i]];
    [column setTitle:headers[i]];
    [column setWidth:100.0];
    [column setEditable:YES];
    [column setResizingMask:NSTableColumnUserResizingMask | NSTableColumnAutoresizingMask];
    [tableView addTableColumn:column];
    [column release];
  }
  
  [tableView setDataSource:self];
  [tableView setDelegate:self];
  [scrollView setDocumentView:tableView];
  [tableView release];
  
  self.controlsByName[[name lowercaseString]] = scrollView;
  [self addControlToLayout:scrollView];
  return scrollView;
}
@end

// C Bridge functions
static NSVisualEffectMaterial materialFromString(NSString *materialStr) {
  NSString *norm = [materialStr lowercaseString];
  if ([norm isEqualToString:@"sidebar"]) return NSVisualEffectMaterialSidebar;
  if ([norm isEqualToString:@"header"]) return NSVisualEffectMaterialHeaderView;
  if ([norm isEqualToString:@"titlebar"]) return NSVisualEffectMaterialTitlebar;
  if ([norm isEqualToString:@"selection"]) return NSVisualEffectMaterialSelection;
  if ([norm isEqualToString:@"menu"]) return NSVisualEffectMaterialMenu;
  if ([norm isEqualToString:@"hud"] || [norm isEqualToString:@"hudwindow"]) return NSVisualEffectMaterialHUDWindow;
  return NSVisualEffectMaterialWindowBackground;
}

void window_begin_glass_box(main__WindowInfo *info, const char *name, const char *material) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate beginGlassBoxWithName:nsstring(name) material:nsstring(material)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_end_glass_box(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate endGlassBox];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void *window_add_badge_control(main__WindowInfo *info, const char *name, const char *text, const char *style) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *badge = nil;
  void (^runBlock)(void) = ^{
    badge = [delegate makeBadgeWithName:nsstring(name) text:nsstring(text) style:nsstring(style)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)badge;
}

void *window_add_icon_segments_control(main__WindowInfo *info, const char *name, const char **symbols, int symbols_count, const char *selected) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *seg = nil;
  void (^runBlock)(void) = ^{
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < symbols_count; i++) {
      [arr addObject:nsstring(symbols[i])];
    }
    seg = [delegate makeIconSegmentsWithName:nsstring(name) symbols:arr selected:nsstring(selected)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)seg;
}
void window_begin_split_view(main__WindowInfo *info, const char *name, int vertical) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate beginSplitViewWithName:nsstring(name) vertical:vertical == 1];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_split_view_next_pane(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate splitViewNextPane];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_end_split_view(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate endSplitView];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void *window_add_collection_view_control(main__WindowInfo *info, const char *name, int item_width, int item_height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *scroll = nil;
  void (^runBlock)(void) = ^{
    scroll = [delegate makeCollectionViewWithName:nsstring(name) itemWidth:item_width itemHeight:item_height];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)scroll;
}

void window_set_collection_items(main__WindowInfo *info, const char *name, const char **items, int items_count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  void (^runBlock)(void) = ^{
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < items_count; i++) {
      [arr addObject:nsstring(items[i])];
    }
    
    if (!delegate.collectionItemsByName) {
      delegate.collectionItemsByName = [NSMutableDictionary dictionary];
    }
    delegate.collectionItemsByName[key] = arr;
    
    id ctrl = delegate.controlsByName[key];
    if ([ctrl isKindOfClass:[NSCollectionView class]]) {
      [(NSCollectionView *)ctrl reloadData];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_show_popover(main__WindowInfo *info, const char *anchor_name, const char *title, const char *message) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *anchorName = [[nsstring(anchor_name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSString *titleStr = nsstring(title);
  NSString *msgStr = nsstring(message);
  
  void (^runBlock)(void) = ^{
    NSView *anchorView = delegate.controlsByName[anchorName];
    if (!anchorView) return;
    
    NSPopover *popover = [[NSPopover alloc] init];
    [popover setBehavior:NSPopoverBehaviorTransient];
    
    NSViewController *vc = [[NSViewController alloc] init];
    NSView *popView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 240, 90)];
    [popView setWantsLayer:YES];
    
    NSTextField *titleLbl = [NSTextField labelWithString:titleStr];
    [titleLbl setFont:[NSFont systemFontOfSize:13 weight:NSFontWeightBold]];
    [titleLbl setFrame:NSMakeRect(10, 60, 220, 20)];
    if (delegate.currentFontColor) {
      [titleLbl setTextColor:delegate.currentFontColor];
    }
    [popView addSubview:titleLbl];
    
    NSTextField *msgLbl = [NSTextField labelWithString:msgStr];
    [msgLbl setFont:[NSFont systemFontOfSize:11]];
    [msgLbl setFrame:NSMakeRect(10, 5, 220, 50)];
    [msgLbl setLineBreakMode:NSLineBreakByWordWrapping];
    if (delegate.currentFontColor) {
      [msgLbl setTextColor:delegate.currentFontColor];
    }
    [popView addSubview:msgLbl];
    
    [vc setView:popView];
    [popover setContentViewController:vc];
    
    [popover showRelativeToRect:anchorView.bounds ofView:anchorView preferredEdge:NSRectEdgeMaxY];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_async(dispatch_get_main_queue(), runBlock);
  }
}

void *window_add_calendar_control(main__WindowInfo *info, const char *name, const char *date) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *picker = nil;
  void (^runBlock)(void) = ^{
    picker = [delegate makeCalendarWithName:nsstring(name) date:nsstring(date)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)picker;
}

void *window_add_canvas_control(main__WindowInfo *info, const char *name, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *canvas = nil;
  void (^runBlock)(void) = ^{
    canvas = [delegate makeCanvasWithName:nsstring(name) height:height];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)canvas;
}

void window_draw_line(main__WindowInfo *info, const char *canvas_name, double x1, double y1, double x2, double y2, const char *color_str, double stroke_width) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(canvas_name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSColor *color = colorFromString(color_str);
  
  void (^runBlock)(void) = ^{
    id view = delegate.controlsByName[key];
    if ([view isKindOfClass:[CanvasView class]]) {
      CanvasView *canvas = (CanvasView *)view;
      DrawingCommand *cmd = [[DrawingCommand alloc] init];
      cmd.type = 0;
      cmd.x1 = x1;
      cmd.y1 = y1;
      cmd.x2 = x2;
      cmd.y2 = y2;
      cmd.color = color;
      cmd.strokeWidth = stroke_width;
      [canvas.commands addObject:cmd];
      [canvas setNeedsDisplay:YES];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_async(dispatch_get_main_queue(), runBlock);
  }
}

void window_draw_rect(main__WindowInfo *info, const char *canvas_name, double x, double y, double w, double h, const char *color_str, int fill, double stroke_width) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(canvas_name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSColor *color = colorFromString(color_str);
  
  void (^runBlock)(void) = ^{
    id view = delegate.controlsByName[key];
    if ([view isKindOfClass:[CanvasView class]]) {
      CanvasView *canvas = (CanvasView *)view;
      DrawingCommand *cmd = [[DrawingCommand alloc] init];
      cmd.type = 1;
      cmd.x1 = x;
      cmd.y1 = y;
      cmd.x2 = w;
      cmd.y2 = h;
      cmd.color = color;
      cmd.fill = fill == 1;
      cmd.strokeWidth = stroke_width;
      [canvas.commands addObject:cmd];
      [canvas setNeedsDisplay:YES];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_async(dispatch_get_main_queue(), runBlock);
  }
}

void window_draw_circle(main__WindowInfo *info, const char *canvas_name, double x, double y, double r, const char *color_str, int fill, double stroke_width) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(canvas_name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSColor *color = colorFromString(color_str);
  
  void (^runBlock)(void) = ^{
    id view = delegate.controlsByName[key];
    if ([view isKindOfClass:[CanvasView class]]) {
      CanvasView *canvas = (CanvasView *)view;
      DrawingCommand *cmd = [[DrawingCommand alloc] init];
      cmd.type = 2;
      cmd.x1 = x;
      cmd.y1 = y;
      cmd.x2 = r;
      cmd.color = color;
      cmd.fill = fill == 1;
      cmd.strokeWidth = stroke_width;
      [canvas.commands addObject:cmd];
      [canvas setNeedsDisplay:YES];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_async(dispatch_get_main_queue(), runBlock);
  }
}

void window_clear_canvas(main__WindowInfo *info, const char *canvas_name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(canvas_name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  void (^runBlock)(void) = ^{
    id view = delegate.controlsByName[key];
    if ([view isKindOfClass:[CanvasView class]]) {
      CanvasView *canvas = (CanvasView *)view;
      [canvas.commands removeAllObjects];
      [canvas setNeedsDisplay:YES];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_async(dispatch_get_main_queue(), runBlock);
  }
}

static NSString *normalizeMenuShortcut(NSString *shortcut, NSEventModifierFlags *modifierMask) {
  if (!shortcut || shortcut.length == 0) {
    if (modifierMask) *modifierMask = 0;
    return @"";
  }

  NSArray<NSString *> *parts = [shortcut componentsSeparatedByString:@"+"];
  NSEventModifierFlags mask = 0;
  NSString *key = @"";

  for (NSString *part in parts) {
    NSString *token = [[part lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([token isEqualToString:@""] || [token isEqualToString:@"cmd"] || [token isEqualToString:@"command"]) {
      mask |= NSEventModifierFlagCommand;
    } else if ([token isEqualToString:@"ctrl"] || [token isEqualToString:@"control"]) {
      mask |= NSEventModifierFlagControl;
    } else if ([token isEqualToString:@"opt"] || [token isEqualToString:@"option"] || [token isEqualToString:@"alt"]) {
      mask |= NSEventModifierFlagOption;
    } else if ([token isEqualToString:@"shift"]) {
      mask |= NSEventModifierFlagShift;
    } else {
      key = token;
    }
  }

  if (modifierMask) *modifierMask = mask;

  if ([key isEqualToString:@"return"] || [key isEqualToString:@"enter"]) {
    return @"\r";
  }
  if ([key isEqualToString:@"escape"] || [key isEqualToString:@"esc"]) {
    return @"\033";
  }
  if ([key isEqualToString:@"space"]) {
    return @" ";
  }

  return key;
}

void window_add_menu_item(main__WindowInfo *info, const char *menu_name, const char *item_title, const char *shortcut, const char *handler_name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *menuName = nsstring(menu_name);
  NSString *itemTitle = nsstring(item_title);
  NSString *shortcutText = nsstring(shortcut);
  NSString *handlerName = nsstring(handler_name);
  
  dispatch_async(dispatch_get_main_queue(), ^{
    if (delegate.statusBarMenu) {
      if ([itemTitle isEqualToString:@"-"]) {
        [delegate.statusBarMenu addItem:[NSMenuItem separatorItem]];
      } else {
        NSEventModifierFlags modifierMask = 0;
        NSString *keyEquivalent = normalizeMenuShortcut(shortcutText, &modifierMask);
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:itemTitle action:@selector(handleMenuItemClicked:) keyEquivalent:keyEquivalent];
        [item setKeyEquivalentModifierMask:modifierMask];
        [item setTarget:delegate];
        [item setRepresentedObject:handlerName];
        [delegate.statusBarMenu addItem:item];
      }
    } else {
      NSMenu *submenu = [delegate findOrCreateMenuWithName:menuName];
      if (submenu) {
        if ([itemTitle isEqualToString:@"-"]) {
          [submenu addItem:[NSMenuItem separatorItem]];
        } else {
          NSEventModifierFlags modifierMask = 0;
          NSString *keyEquivalent = normalizeMenuShortcut(shortcutText, &modifierMask);
          NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:itemTitle action:@selector(handleMenuItemClicked:) keyEquivalent:keyEquivalent];
          [item setKeyEquivalentModifierMask:modifierMask];
          [item setTarget:delegate];
          [item setRepresentedObject:handlerName];
          [submenu addItem:item];
        }
      }
    }
  });
}

void window_add_context_menu_item(main__WindowInfo *info, const char *control_name, const char *item_title, const char *handler_name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *controlName = nsstring(control_name);
  NSString *itemTitle = nsstring(item_title);
  NSString *handlerName = nsstring(handler_name);
  
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = nil;
    if ([controlName isEqualToString:@"window"]) {
      view = delegate.window.contentView;
    } else {
      view = [delegate viewForControlName:controlName];
    }
    
    if (view) {
      if (!view.menu) {
        view.menu = [[NSMenu alloc] init];
      }
      if ([itemTitle isEqualToString:@"-"]) {
        [view.menu addItem:[NSMenuItem separatorItem]];
      } else {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:itemTitle action:@selector(handleMenuItemClicked:) keyEquivalent:@""];
        [item setTarget:delegate];
        [item setRepresentedObject:handlerName];
        [view.menu addItem:item];
      }
    }
  });
}

main__WindowInfo *window_app_init(void *params) {
  main__WindowParams window_params = {0};
  if (params) {
    window_params = *(main__WindowParams *)params;
  }

  NSApplication *app = [NSApplication sharedApplication];
  AppDelegate *delegate = [[AppDelegate alloc] initWithParams:window_params];
  [app setActivationPolicy:NSApplicationActivationPolicyRegular];
  [app setDelegate:delegate];

  main__WindowInfo *info = malloc(sizeof(main__WindowInfo));
  info->app = app;
  info->app_delegate = delegate;
  return info;
}

void window_app_run(main__WindowInfo *info) {
  NSApplication *app = (NSApplication *)info->app;
  [app run];
}

void window_app_exit(main__WindowInfo *info) {
  NSApplication *app = (NSApplication *)info->app;
  [app terminate:app];
}

void window_set_input_text(main__WindowInfo *info, const char *text) {
  window_set_control_text_by_name(info, "name", text);
}

char *window_get_input_text(main__WindowInfo *info) {
  return window_get_control_text_by_name(info, "name");
}

void window_set_text_area(main__WindowInfo *info, const char *text) {
  window_set_control_text_by_name(info, "notes", text);
}

char *window_get_text_area(main__WindowInfo *info) {
  return window_get_control_text_by_name(info, "notes");
}

void window_set_status_text(main__WindowInfo *info, const char *text) {
  window_set_control_text_by_name(info, "status", text);
}

void window_set_title_text(main__WindowInfo *info, const char *text) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  [delegate.window setTitle:nsstring(text)];
}

void window_set_always_on_top(main__WindowInfo *info, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  if (!delegate.window) {
    return;
  }
  [delegate.window setLevel:enabled ? NSFloatingWindowLevel : NSNormalWindowLevel];
}

int window_get_always_on_top(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  if (!delegate.window) {
    return 0;
  }
  return delegate.window.level == NSFloatingWindowLevel ? 1 : 0;
}

void window_set_button_title(main__WindowInfo *info, const char *text) {
  window_set_control_text_by_name(info, "run", text);
}

void window_set_checkbox_text(main__WindowInfo *info, const char *text) {
  window_set_control_text_by_name(info, "ready", text);
}

void window_set_checkbox_state(main__WindowInfo *info, int checked) {
  window_set_control_bool_by_name(info, "ready", checked);
}

int window_get_checkbox_state(main__WindowInfo *info) {
  return window_get_control_bool_by_name(info, "ready");
}

void window_set_number_value(main__WindowInfo *info, int value) {
  window_set_control_int_by_name(info, "number", value);
}

int window_get_number_value(main__WindowInfo *info) {
  return window_get_control_int_by_name(info, "number");
}

static BOOL isDarkColor(NSColor *color) {
  if (!color) return YES;
  NSColor *rgbColor = [color colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
  if (!rgbColor) return YES;
  CGFloat r=0, g=0, b=0, a=0;
  [rgbColor getRed:&r green:&g blue:&b alpha:&a];
  double luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
  return luminance < 0.5;
}

static NSColor *getContrastColor(NSColor *color) {
  return isDarkColor(color) ? [NSColor whiteColor] : [NSColor blackColor];
}

void window_set_background_color(main__WindowInfo *info, const char *color) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSColor *backgroundColor = colorFromString(color);
  NSColor *fontColor = delegate.currentFontColor;
  if (!fontColor) {
    fontColor = getContrastColor(backgroundColor);
  } else {
    NSColor *rgbBg = [backgroundColor colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
    NSColor *rgbFg = [fontColor colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
    if (rgbBg && rgbFg) {
      CGFloat r1=0, g1=0, b1=0, a1=0;
      CGFloat r2=0, g2=0, b2=0, a2=0;
      [rgbBg getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
      [rgbFg getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
      double lum1 = 0.2126 * r1 + 0.7152 * g1 + 0.0722 * b1;
      double lum2 = 0.2126 * r2 + 0.7152 * g2 + 0.0722 * b2;
      if (fabs(lum1 - lum2) < 0.25) {
        fontColor = getContrastColor(backgroundColor);
      }
    }
  }
  [delegate applyColors:backgroundColor fontColor:fontColor];
}

void window_set_font_color(main__WindowInfo *info, const char *color) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSColor *fontColor = colorFromString(color);
  NSColor *backgroundColor = delegate.currentBackgroundColor ?: [NSColor colorWithCalibratedWhite:0.12 alpha:1.0];
  
  NSColor *rgbBg = [backgroundColor colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
  NSColor *rgbFg = [fontColor colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
  if (rgbBg && rgbFg) {
    CGFloat r1=0, g1=0, b1=0, a1=0;
    CGFloat r2=0, g2=0, b2=0, a2=0;
    [rgbBg getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [rgbFg getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    double lum1 = 0.2126 * r1 + 0.7152 * g1 + 0.0722 * b1;
    double lum2 = 0.2126 * r2 + 0.7152 * g2 + 0.0722 * b2;
    if (fabs(lum1 - lum2) < 0.25) {
      fontColor = getContrastColor(backgroundColor);
    }
  }
  [delegate applyColors:backgroundColor fontColor:fontColor];
}

void window_set_control_background_color_by_name(main__WindowInfo *info, const char *name, const char *color) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSColor *backgroundColor = colorFromString(color);
  [delegate applyStyleToControlNamed:nsstring(name) backgroundColor:backgroundColor fontColor:nil];
}

void window_set_control_font_color_by_name(main__WindowInfo *info, const char *name, const char *color) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSColor *fontColor = colorFromString(color);
  [delegate applyStyleToControlNamed:nsstring(name) backgroundColor:nil fontColor:fontColor];
}

void window_set_control_width_by_name(main__WindowInfo *info, const char *name, int width) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSView *view = [delegate viewForControlName:nsstring(name)];
  if (!view) return;
  
  NSLayoutConstraint *found = findWidthConstraint(view);
  if (found) {
    found.constant = width;
  } else {
    [view.widthAnchor constraintEqualToConstant:width].active = YES;
  }
  [view setNeedsLayout:YES];
}

void window_set_control_height_by_name(main__WindowInfo *info, const char *name, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSView *view = [delegate viewForControlName:nsstring(name)];
  if (!view) return;
  
  NSLayoutConstraint *found = findHeightConstraint(view);
  if (found) {
    found.constant = height;
  } else {
    [view.heightAnchor constraintEqualToConstant:height].active = YES;
  }
  [view setNeedsLayout:YES];
}

void window_set_control_font_size_by_name(main__WindowInfo *info, const char *name, int size) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSView *view = [delegate viewForControlName:nsstring(name)];
  if (!view) return;
  
  void (^applyFont)(id) = ^(id target) {
    if ([target respondsToSelector:@selector(setFont:)]) {
      NSFont *oldFont = [target font];
      NSFont *newFont = nil;
      if (oldFont) {
        newFont = [[NSFontManager sharedFontManager] convertFont:oldFont toSize:size];
      } else {
        newFont = [NSFont systemFontOfSize:size];
      }
      [target setFont:newFont];
    }
  };

  if ([view isKindOfClass:[NSScrollView class]]) {
    NSScrollView *scroll = (NSScrollView *)view;
    if ([scroll.documentView isKindOfClass:[NSTextView class]]) {
      applyFont(scroll.documentView);
    }
  } else {
    applyFont(view);
  }
}

void window_set_control_font_bold_by_name(main__WindowInfo *info, const char *name, int bold) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSView *view = [delegate viewForControlName:nsstring(name)];
  if (!view) return;
  
  void (^applyFontBold)(id) = ^(id target) {
    if ([target respondsToSelector:@selector(setFont:)]) {
      NSFont *oldFont = [target font] ?: [NSFont systemFontOfSize:13];
      NSFont *newFont = nil;
      if (bold) {
        newFont = [[NSFontManager sharedFontManager] convertFont:oldFont toHaveTrait:NSBoldFontMask];
      } else {
        newFont = [[NSFontManager sharedFontManager] convertFont:oldFont toNotHaveTrait:NSBoldFontMask];
      }
      if (newFont) {
        [target setFont:newFont];
      }
    }
  };

  if ([view isKindOfClass:[NSScrollView class]]) {
    NSScrollView *scroll = (NSScrollView *)view;
    if ([scroll.documentView isKindOfClass:[NSTextView class]]) {
      applyFontBold(scroll.documentView);
    }
  } else {
    applyFontBold(view);
  }
}

void window_set_control_font_name_by_name(main__WindowInfo *info, const char *name, const char *font_name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSView *view = [delegate viewForControlName:nsstring(name)];
  if (!view) return;
  NSString *fontName = nsstring(font_name);
  
  void (^applyFontName)(id) = ^(id target) {
    if ([target respondsToSelector:@selector(setFont:)]) {
      NSFont *oldFont = [target font] ?: [NSFont systemFontOfSize:13];
      CGFloat size = oldFont ? [oldFont pointSize] : 13;
      NSFont *newFont = [NSFont fontWithName:fontName size:size];
      if (!newFont) {
        newFont = [NSFont systemFontOfSize:size];
      }
      [target setFont:newFont];
    }
  };

  if ([view isKindOfClass:[NSScrollView class]]) {
    NSScrollView *scroll = (NSScrollView *)view;
    if ([scroll.documentView isKindOfClass:[NSTextView class]]) {
      applyFontName(scroll.documentView);
    }
  } else {
    applyFontName(view);
  }
}

void window_set_padding(main__WindowInfo *info, int padding) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    if (delegate.mainStackView) {
      [delegate.mainStackView setEdgeInsets:NSEdgeInsetsMake(padding, padding, padding, padding)];
      [delegate.mainStackView setNeedsLayout:YES];
    }
  });
}

void window_set_spacing(main__WindowInfo *info, int spacing) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    if (delegate.mainStackView) {
      [delegate.mainStackView setSpacing:(double)spacing];
      [delegate.mainStackView setNeedsLayout:YES];
    }
  });
}

void window_set_responsive_layout(main__WindowInfo *info, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  if (!delegate) return;
  delegate.responsiveLayoutEnabled = enabled != 0;
  dispatch_async(dispatch_get_main_queue(), ^{
    if (delegate.mainStackView) {
      [delegate.mainStackView setNeedsLayout:YES];
    }
  });
}

void *window_add_group_box_control(main__WindowInfo *info, const char *name, const char *title) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSBox *box = nil;
  void (^runBlock)(void) = ^{
    box = [[NSBox alloc] initWithFrame:NSZeroRect];
    [box setTitle:nsstring(title)];
    [box setBorderType:NSLineBorder];
    [box setBoxType:NSBoxCustom];
    [box setContentViewMargins:NSMakeSize(12, 12)];
    [box setWantsLayer:YES];
    box.layer.cornerRadius = 12.0;
    box.layer.borderWidth = 1.0;
    box.layer.borderColor = [modernBorderColor() CGColor];
    box.layer.backgroundColor = (delegate.currentBackgroundColor ?: modernCardColor()).CGColor;
    
    [delegate addControlToLayout:box];
    NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    delegate.controlsByName[key] = box;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)box;
}

void *window_add_tabs_control(main__WindowInfo *info, const char *name, const char **titles, int titles_count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSTabView *tabs = nil;
  void (^runBlock)(void) = ^{
    tabs = [[NSTabView alloc] initWithFrame:NSZeroRect];
    [tabs setTabViewType:NSTopTabsBezelBorder];
    [tabs setControlSize:NSSmallControlSize];
    [tabs setFont:[NSFont systemFontOfSize:12]];
    [tabs setTranslatesAutoresizingMaskIntoConstraints:NO];
    [tabs.widthAnchor constraintLessThanOrEqualToConstant:420].active = YES;
    [tabs.heightAnchor constraintEqualToConstant:32].active = YES;
    for (int i = 0; i < titles_count; i++) {
      NSTabViewItem *item = [[NSTabViewItem alloc] initWithIdentifier:[NSString stringWithFormat:@"tab_%d", i]];
      [item setLabel:nsstring(titles[i])];
      [tabs addTabViewItem:item];
    }
    [tabs setDelegate:delegate];
    [delegate addControlToLayout:tabs];
    NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    delegate.controlsByName[key] = tabs;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)tabs;
}

void *window_add_scroll_view_control(main__WindowInfo *info, const char *name, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSScrollView *scroll = nil;
  void (^runBlock)(void) = ^{
    scroll = [[NSScrollView alloc] initWithFrame:NSZeroRect];
    [scroll setHasVerticalScroller:YES];
    [scroll setHasHorizontalScroller:NO];
    [scroll.heightAnchor constraintEqualToConstant:height].active = YES;
    NSView *content = [[NSView alloc] initWithFrame:NSZeroRect];
    [content setFrameSize:NSMakeSize(300, height)];
    [scroll setDocumentView:content];
    [delegate addControlToLayout:scroll];
    NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    delegate.controlsByName[key] = scroll;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)scroll;
}

void window_focus_control(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = [delegate viewForControlName:nsstring(name)];
    if (view) {
      [delegate.window makeFirstResponder:view];
    }
  });
}

void window_set_placeholder_by_name(main__WindowInfo *info, const char *name, const char *text) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = [delegate viewForControlName:nsstring(name)];
    if ([view isKindOfClass:[NSTextField class]]) {
      [(NSTextField *)view setPlaceholderString:nsstring(text)];
    }
  });
}

void window_set_error_by_name(main__WindowInfo *info, const char *name, const char *text) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = [delegate viewForControlName:nsstring(name)];
    if (view) {
      [view setToolTip:nsstring(text)];
      [view setWantsLayer:YES];
      if (text && *text) {
        view.layer.borderWidth = 1.2;
        view.layer.borderColor = [[NSColor systemRedColor] CGColor];
        view.layer.cornerRadius = 8.0;
      } else {
        view.layer.borderWidth = 0.0;
        view.layer.borderColor = nil;
      }
    }
  });
}

void window_set_tooltip_by_name(main__WindowInfo *info, const char *name, const char *text) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = [delegate viewForControlName:nsstring(name)];
    if (view) {
      [view setToolTip:nsstring(text)];
    }
  });
}

void window_set_default_button_by_name(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = [delegate viewForControlName:nsstring(name)];
    if ([view isKindOfClass:[NSButton class]]) {
      NSButton *button = (NSButton *)view;
      [button setKeyEquivalent:@"\r"];
      applyStyleToView(button, delegate.currentBackgroundColor, delegate.currentFontColor);
    }
  });
}

void window_run_after(main__WindowInfo *info, int ms, const char *handler_name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *handler = nsstring(handler_name);
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)ms * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
    vlang_dispatch_event(delegate.win_ptr, [handler UTF8String], "run_after", "");
  });
}

void window_show_toast(main__WindowInfo *info, const char *message) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSWindow *parentWindow = (delegate && delegate.window) ? delegate.window : nil;
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Notice"];
    [alert setInformativeText:nsstring(message)];
    [alert addButtonWithTitle:@"OK"];
    [alert setAlertStyle:NSAlertStyleInformational];
    
    if (parentWindow) {
      [parentWindow addChildWindow:[alert window] ordered:NSWindowAbove];
    }
    [alert runModal];
    if (parentWindow) {
      [parentWindow removeChildWindow:[alert window]];
    }
  });
}

void window_open_url(main__WindowInfo *info, const char *url) {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:nsstring(url)]];
  });
}

void window_copy_to_clipboard(main__WindowInfo *info, const char *text) {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard clearContents];
    [pasteboard setString:nsstring(text) forType:NSPasteboardTypeString];
  });
}

// C creation bridges calling AppDelegate make methods
void *window_add_label_control(main__WindowInfo *info, const char *name, const char *text) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  return [delegate makeLabelWithName:nsstring(name) text:nsstring(text)];
}

void *window_add_input_control(main__WindowInfo *info, const char *name, const char *value) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  return [delegate makeTextFieldWithName:nsstring(name) value:nsstring(value)];
}

void *window_add_password_control(main__WindowInfo *info, const char *name, const char *value) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  return [delegate makePasswordFieldWithName:nsstring(name) value:nsstring(value)];
}

void *window_add_textarea_control(main__WindowInfo *info, const char *name, const char *value) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  return [delegate makeTextAreaWithName:nsstring(name) value:nsstring(value)];
}

void *window_add_html_view_control(main__WindowInfo *info, const char *name, const char *html) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  return [delegate makeHtmlViewWithName:nsstring(name) html:nsstring(html)];
}

void *window_add_drop_zone_control(main__WindowInfo *info, const char *name, const char *label) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  return [delegate makeDropZoneWithName:nsstring(name) label:nsstring(label)];
}

void *window_add_checkbox_control(main__WindowInfo *info, const char *name, const char *text, int checked) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  return [delegate makeCheckboxWithName:nsstring(name) label:nsstring(text) checked:checked == 1];
}

void *window_add_button_control(main__WindowInfo *info, const char *name, const char *text) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  return [delegate makeButtonWithName:nsstring(name) title:nsstring(text)];
}

void *window_add_number_control(main__WindowInfo *info, const char *name, int value) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  return [delegate makeNumberFieldWithName:nsstring(name) value:value];
}

void *window_add_slider_control(main__WindowInfo *info, const char *name, int value) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  return [delegate makeSliderWithName:nsstring(name) value:value];
}

void *window_add_theme_menu_control(main__WindowInfo *info, const char *name, const char *selected) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  return [delegate makePopUpButtonWithName:nsstring(name) selected:nsstring(selected)];
}

void *window_add_color_well_control(main__WindowInfo *info, const char *name, const char *color) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  return [delegate makeColorWellWithName:nsstring(name) color:nsstring(color)];
}

void *window_add_date_picker_control(main__WindowInfo *info, const char *name, const char *date) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  return [delegate makeDatePickerWithName:nsstring(name) date:nsstring(date)];
}

void *window_add_mode_control_control(main__WindowInfo *info, const char *name, const char *selected) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  return [delegate makeSegmentedControlWithName:nsstring(name) selected:nsstring(selected)];
}

void *window_add_progress_indicator_control(main__WindowInfo *info, const char *name, int value) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  return [delegate makeProgressIndicatorWithName:nsstring(name) value:value];
}

// Generic control styling and access
void window_set_control_text(void *control, const char *text) {
  NSView *view = (NSView *)control;
  NSString *nsText = nsstring(text);
  if ([view isKindOfClass:[NSScrollView class]]) {
    NSView *doc = [(NSScrollView *)view documentView];
    if ([doc isKindOfClass:[NSTextView class]]) {
      view = doc;
    } else if ([doc isKindOfClass:[NSTableView class]]) {
      NSTableView *tableView = (NSTableView *)doc;
      NSInteger index = [nsText integerValue];
      if (index >= 0 && index < [tableView numberOfRows]) {
        [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
        [tableView scrollRowToVisible:index];
      } else {
        [tableView deselectAll:nil];
      }
      return;
    }
  }
  
  if ([view isKindOfClass:[ShortcutRecorder class]]) {
    ShortcutRecorder *sr = (ShortcutRecorder *)view;
    sr.shortcutString = nsText;
    NSMutableString *disp = [NSMutableString string];
    NSArray *parts = [nsText componentsSeparatedByString:@"+"];
    for (NSString *part in parts) {
      NSString *p = [part lowercaseString];
      if ([p isEqualToString:@"ctrl"]) {
        [disp appendString:@"⌃"];
      } else if ([p isEqualToString:@"opt"]) {
        [disp appendString:@"⌥"];
      } else if ([p isEqualToString:@"shift"]) {
        [disp appendString:@"⇧"];
      } else if ([p isEqualToString:@"cmd"]) {
        [disp appendString:@"⌘"];
      } else {
        [disp appendString:[part uppercaseString]];
      }
    }
    if (disp.length == 0) {
      disp = [NSMutableString stringWithString:@"Press shortcut..."];
    }
    sr.displayString = disp;
    [sr setStringValue:disp];
  } else if ([view isKindOfClass:[NSTextField class]]) {
    [(NSTextField *)view setStringValue:nsText];
  } else if ([view isKindOfClass:[NSTextView class]]) {
    [(NSTextView *)view setString:nsText];
  } else if ([view isKindOfClass:[WKWebView class]]) {
    [(WKWebView *)view loadHTMLString:nsText baseURL:nil];
  } else if ([view isKindOfClass:[NSButton class]]) {
    [(NSButton *)view setTitle:nsText];
  } else if ([view isKindOfClass:[NSSlider class]]) {
    [(NSSlider *)view setDoubleValue:[nsText doubleValue]];
  } else if ([view isKindOfClass:[NSStepper class]]) {
    [(NSStepper *)view setDoubleValue:[nsText doubleValue]];
  } else if ([view isKindOfClass:[NSColorWell class]]) {
    [(NSColorWell *)view setColor:colorFromString(text)];
  } else if ([view isKindOfClass:[NSDatePicker class]]) {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:nsText];
    if (date) {
      [(NSDatePicker *)view setDateValue:date];
    } else {
      [formatter setDateStyle:NSDateFormatterMediumStyle];
      date = [formatter dateFromString:nsText];
      if (date) {
        [(NSDatePicker *)view setDateValue:date];
      }
    }
  } else if ([view isKindOfClass:[NSPopUpButton class]]) {
    [(NSPopUpButton *)view selectItemWithTitle:nsText];
  } else if ([view isKindOfClass:[NSSegmentedControl class]]) {
    NSSegmentedControl *seg = (NSSegmentedControl *)view;
    for (NSInteger i = 0; i < [seg segmentCount]; i++) {
      if ([[seg labelForSegment:i] isEqualToString:nsText]) {
        [seg setSelectedSegment:i];
        break;
      }
    }
  } else if ([view isKindOfClass:[NSProgressIndicator class]]) {
    [(NSProgressIndicator *)view setDoubleValue:[nsText doubleValue]];
  } else if ([view isKindOfClass:[NSLevelIndicator class]]) {
    [(NSLevelIndicator *)view setDoubleValue:[nsText doubleValue]];
  } else if ([view isKindOfClass:[NSPathControl class]]) {
    if (nsText.length > 0) {
      [(NSPathControl *)view setURL:[NSURL fileURLWithPath:nsText]];
    } else {
      [(NSPathControl *)view setURL:nil];
    }
  } else if ([view isKindOfClass:[NSSwitch class]]) {
    [(NSSwitch *)view setState:[nsText isEqualToString:@"true"] || [nsText isEqualToString:@"1"] ? NSControlStateValueOn : NSControlStateValueOff];
  } else if ([view isKindOfClass:[NSStackView class]]) {
    NSStackView *radioStack = (NSStackView *)view;
    for (NSView *subview in [radioStack arrangedSubviews]) {
      if ([subview isKindOfClass:[NSButton class]]) {
        NSButton *btn = (NSButton *)subview;
        if ([[btn title] isEqualToString:nsText]) {
          [btn setState:NSControlStateValueOn];
        } else {
          [btn setState:NSControlStateValueOff];
        }
      }
    }
  }
}

char *window_get_control_text(void *control) {
  NSView *view = (NSView *)control;
  if ([view isKindOfClass:[NSScrollView class]]) {
    NSView *doc = [(NSScrollView *)view documentView];
    if ([doc isKindOfClass:[NSTextView class]]) {
      view = doc;
    } else if ([doc isKindOfClass:[NSOutlineView class]]) {
      view = doc;
    } else if ([doc isKindOfClass:[NSTableView class]]) {
      NSTableView *tableView = (NSTableView *)doc;
      NSInteger selectedRow = [tableView selectedRow];
      return strdup([[NSString stringWithFormat:@"%ld", (long)selectedRow] UTF8String]);
    }
  }
  
  NSString *result = @"";
  if ([view isKindOfClass:[ShortcutRecorder class]]) {
    result = [(ShortcutRecorder *)view shortcutString];
  } else if ([view isKindOfClass:[NSTextField class]]) {
    result = [(NSTextField *)view stringValue];
  } else if ([view isKindOfClass:[NSTextView class]]) {
    result = [(NSTextView *)view string];
  } else if ([view isKindOfClass:[NSButton class]]) {
    if ([view isKindOfClass:[NSSwitch class]]) {
      result = [(NSSwitch *)view state] == NSControlStateValueOn ? @"true" : @"false";
    } else {
      result = [(NSButton *)view title];
    }
  } else if ([view isKindOfClass:[NSSlider class]]) {
    result = [NSString stringWithFormat:@"%.0f", [(NSSlider *)view doubleValue]];
  } else if ([view isKindOfClass:[NSStepper class]]) {
    result = [NSString stringWithFormat:@"%.0f", [(NSStepper *)view doubleValue]];
  } else if ([view isKindOfClass:[NSColorWell class]]) {
    NSColor *color = [(NSColorWell *)view color];
    CGFloat r=0, g=0, b=0, a=0;
    NSColor *rgbColor = [color colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
    if (rgbColor) {
      [rgbColor getRed:&r green:&g blue:&b alpha:&a];
    } else {
      [color getRed:&r green:&g blue:&b alpha:&a];
    }
    result = [NSString stringWithFormat:@"#%02X%02X%02X", (int)(r * 255.99), (int)(g * 255.99), (int)(b * 255.99)];
  } else if ([view isKindOfClass:[NSDatePicker class]]) {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    result = [formatter stringFromDate:[(NSDatePicker *)view dateValue]];
  } else if ([view isKindOfClass:[NSPopUpButton class]]) {
    result = [(NSPopUpButton *)view titleOfSelectedItem] ?: @"";
  } else if ([view isKindOfClass:[NSSegmentedControl class]]) {
    NSSegmentedControl *seg = (NSSegmentedControl *)view;
    NSInteger sel = [seg selectedSegment];
    if (sel >= 0 && sel < [seg segmentCount]) {
      result = [seg labelForSegment:sel];
    }
  } else if ([view isKindOfClass:[NSProgressIndicator class]]) {
    result = [NSString stringWithFormat:@"%.0f", [(NSProgressIndicator *)view doubleValue]];
  } else if ([view isKindOfClass:[NSLevelIndicator class]]) {
    result = [NSString stringWithFormat:@"%.1f", [(NSLevelIndicator *)view doubleValue]];
  } else if ([view isKindOfClass:[NSPathControl class]]) {
    NSURL *url = [(NSPathControl *)view URL];
    result = url ? [url path] : @"";
  } else if ([view isKindOfClass:[NSOutlineView class]]) {
    NSOutlineView *outlineView = (NSOutlineView *)view;
    NSInteger selectedRow = [outlineView selectedRow];
    if (selectedRow != -1) {
      TreeItem *item = [outlineView itemAtRow:selectedRow];
      if (item) {
        result = item.itemId;
      }
    }
  } else if ([view isKindOfClass:[NSTableView class]]) {
    NSTableView *tableView = (NSTableView *)view;
    AppDelegate *delegate = (AppDelegate *)tableView.delegate;
    NSString *key = [tableView.identifier lowercaseString];
    NSArray *items = delegate.listItemsByName[key];
    NSInteger selectedRow = [tableView selectedRow];
    if (items && selectedRow >= 0 && selectedRow < items.count) {
      result = items[selectedRow];
    }
  } else if ([view isKindOfClass:[NSSwitch class]]) {
    result = [(NSSwitch *)view state] == NSControlStateValueOn ? @"true" : @"false";
  } else if ([view isKindOfClass:[NSStackView class]]) {
    NSStackView *radioStack = (NSStackView *)view;
    for (NSView *subview in [radioStack arrangedSubviews]) {
      if ([subview isKindOfClass:[NSButton class]]) {
        NSButton *btn = (NSButton *)subview;
        if ([btn state] == NSControlStateValueOn) {
          result = [btn title];
          break;
        }
      }
    }
  }
  const char *utf8 = [result UTF8String];
  return utf8 ? strdup(utf8) : strdup("");
}

void window_set_control_bool(void *control, int checked) {
  NSView *view = (NSView *)control;
  if ([view isKindOfClass:[NSButton class]]) {
    [(NSButton *)view setState:checked ? NSOnState : NSOffState];
  } else if ([view isKindOfClass:[NSSwitch class]]) {
    [(NSSwitch *)view setState:checked ? NSControlStateValueOn : NSControlStateValueOff];
  } else if ([view isKindOfClass:[NSProgressIndicator class]]) {
    NSProgressIndicator *prog = (NSProgressIndicator *)view;
    if (prog.style == NSProgressIndicatorStyleSpinning) {
      if (checked) {
        [prog startAnimation:nil];
        [prog setHidden:NO];
      } else {
        [prog stopAnimation:nil];
        [prog setHidden:YES];
      }
    }
  }
}

int window_get_control_bool(void *control) {
  NSView *view = (NSView *)control;
  if ([view isKindOfClass:[NSButton class]]) {
    return [(NSButton *)view state] == NSOnState ? 1 : 0;
  } else if ([view isKindOfClass:[NSSwitch class]]) {
    return [(NSSwitch *)view state] == NSControlStateValueOn ? 1 : 0;
  } else if ([view isKindOfClass:[NSProgressIndicator class]]) {
    NSProgressIndicator *prog = (NSProgressIndicator *)view;
    if (prog.style == NSProgressIndicatorStyleSpinning) {
      return [prog isHidden] ? 0 : 1;
    }
  }
  return 0;
}

void window_set_control_int(void *control, int value) {
  NSView *view = (NSView *)control;
  if ([view isKindOfClass:[NSTextField class]]) {
    [(NSTextField *)view setIntValue:value];
  } else if ([view isKindOfClass:[NSSlider class]]) {
    [(NSSlider *)view setIntValue:value];
  } else if ([view isKindOfClass:[NSSegmentedControl class]]) {
    [(NSSegmentedControl *)view setSelectedSegment:value];
  } else if ([view isKindOfClass:[NSProgressIndicator class]]) {
    [(NSProgressIndicator *)view setDoubleValue:(double)value];
  } else if ([view isKindOfClass:[NSLevelIndicator class]]) {
    [(NSLevelIndicator *)view setIntValue:value];
  } else if ([view isKindOfClass:[NSStepper class]]) {
    [(NSStepper *)view setIntValue:value];
  } else if ([view isKindOfClass:[NSStackView class]]) {
    NSStackView *radioStack = (NSStackView *)view;
    NSInteger idx = 0;
    for (NSView *subview in [radioStack arrangedSubviews]) {
      if ([subview isKindOfClass:[NSButton class]]) {
        NSButton *btn = (NSButton *)subview;
        if (idx == value) {
          [btn setState:NSControlStateValueOn];
        } else {
          [btn setState:NSControlStateValueOff];
        }
        idx++;
      }
    }
  }
}

int window_get_control_int(void *control) {
  NSView *view = (NSView *)control;
  if ([view isKindOfClass:[NSTextField class]]) {
    return [(NSTextField *)view intValue];
  } else if ([view isKindOfClass:[NSSlider class]]) {
    return [(NSSlider *)view intValue];
  } else if ([view isKindOfClass:[NSSegmentedControl class]]) {
    return (int)[(NSSegmentedControl *)view selectedSegment];
  } else if ([view isKindOfClass:[NSProgressIndicator class]]) {
    return (int)[(NSProgressIndicator *)view doubleValue];
  } else if ([view isKindOfClass:[NSLevelIndicator class]]) {
    return (int)[(NSLevelIndicator *)view intValue];
  } else if ([view isKindOfClass:[NSStepper class]]) {
    return [(NSStepper *)view intValue];
  } else if ([view isKindOfClass:[NSStackView class]]) {
    NSStackView *radioStack = (NSStackView *)view;
    NSInteger idx = 0;
    for (NSView *subview in [radioStack arrangedSubviews]) {
      if ([subview isKindOfClass:[NSButton class]]) {
        NSButton *btn = (NSButton *)subview;
        if ([btn state] == NSControlStateValueOn) {
          return (int)idx;
        }
        idx++;
      }
    }
    return -1;
  }
  return 0;
}

void window_set_control_text_by_name(main__WindowInfo *info, const char *name, const char *text) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSView *view = [delegate viewForControlName:nsstring(name)];
  if (view) {
    window_set_control_text(view, text);
    // Extra row-specific updates if needed (e.g. number stepper text or slider label value)
    if ([view isKindOfClass:[NSTextField class]]) {
      NSView *parent = view.superview;
      if ([parent isKindOfClass:[NSStackView class]]) {
        NSStackView *row = (NSStackView *)parent;
        if (row.arrangedSubviews.count > 1 && [row.arrangedSubviews[1] isKindOfClass:[NSStepper class]]) {
          NSStepper *stepper = (NSStepper *)row.arrangedSubviews[1];
          [stepper setDoubleValue:[nsstring(text) doubleValue]];
        }
      }
    } else if ([view isKindOfClass:[NSSlider class]]) {
      NSView *parent = view.superview;
      if ([parent isKindOfClass:[NSStackView class]]) {
        NSStackView *row = (NSStackView *)parent;
        if (row.arrangedSubviews.count > 1 && [row.arrangedSubviews[1] isKindOfClass:[NSTextField class]]) {
          NSTextField *label = (NSTextField *)row.arrangedSubviews[1];
          [label setStringValue:[NSString stringWithFormat:@"Value: %d", [nsstring(text) intValue]]];
        }
      }
    }
  }
}

char *window_get_control_text_by_name(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSView *view = [delegate viewForControlName:nsstring(name)];
  if (view) {
    return window_get_control_text(view);
  }
  return strdup("");
}

void window_set_control_bool_by_name(main__WindowInfo *info, const char *name, int checked) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSView *view = [delegate viewForControlName:nsstring(name)];
  if (view) {
    window_set_control_bool(view, checked);
  }
}

int window_get_control_bool_by_name(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSView *view = [delegate viewForControlName:nsstring(name)];
  if (view) {
    return window_get_control_bool(view);
  }
  return 0;
}

void window_set_control_int_by_name(main__WindowInfo *info, const char *name, int value) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSView *view = [delegate viewForControlName:nsstring(name)];
  if (view) {
    window_set_control_int(view, value);
    if ([view isKindOfClass:[NSTextField class]]) {
      NSView *parent = view.superview;
      if ([parent isKindOfClass:[NSStackView class]]) {
        NSStackView *row = (NSStackView *)parent;
        if (row.arrangedSubviews.count > 1 && [row.arrangedSubviews[1] isKindOfClass:[NSStepper class]]) {
          NSStepper *stepper = (NSStepper *)row.arrangedSubviews[1];
          [stepper setDoubleValue:(double)value];
        }
      }
    } else if ([view isKindOfClass:[NSSlider class]]) {
      NSView *parent = view.superview;
      if ([parent isKindOfClass:[NSStackView class]]) {
        NSStackView *row = (NSStackView *)parent;
        if (row.arrangedSubviews.count > 1 && [row.arrangedSubviews[1] isKindOfClass:[NSTextField class]]) {
          NSTextField *label = (NSTextField *)row.arrangedSubviews[1];
          [label setStringValue:[NSString stringWithFormat:@"Value: %d", value]];
        }
      }
    } else if ([view isKindOfClass:[NSStepper class]]) {
      NSView *parent = view.superview;
      if ([parent isKindOfClass:[NSStackView class]]) {
        NSStackView *row = (NSStackView *)parent;
        if (row.arrangedSubviews.count > 1 && [row.arrangedSubviews[1] isKindOfClass:[NSTextField class]]) {
          NSTextField *label = (NSTextField *)row.arrangedSubviews[1];
          [label setStringValue:[NSString stringWithFormat:@"%d", value]];
        }
      }
    }
  }
}

int window_get_control_int_by_name(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSView *view = [delegate viewForControlName:nsstring(name)];
  if (view) {
    return window_get_control_int(view);
  }
  return 0;
}

void window_begin_row(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  [delegate beginRowWithName:nsstring(name)];
}

void window_end_row(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  [delegate endRow];
}

void window_show_alert(main__WindowInfo *info, const char *title, const char *message) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSWindow *parentWindow = (delegate && delegate.window) ? delegate.window : nil;
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:nsstring(title)];
    [alert setInformativeText:nsstring(message)];
    [alert addButtonWithTitle:@"OK"];
    [alert setAlertStyle:NSAlertStyleInformational];
    if (parentWindow) {
      [parentWindow addChildWindow:[alert window] ordered:NSWindowAbove];
    }
    [alert runModal];
    if (parentWindow) {
      [parentWindow removeChildWindow:[alert window]];
    }
  });
}

void window_show_alert_with_style(main__WindowInfo *info, const char *title, const char *message, const char *style) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *alertStyle = [[nsstring(style) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  dispatch_async(dispatch_get_main_queue(), ^{
    NSWindow *parentWindow = (delegate && delegate.window) ? delegate.window : nil;
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:nsstring(title)];
    [alert setInformativeText:nsstring(message)];
    [alert addButtonWithTitle:@"OK"];
    
    if ([alertStyle isEqualToString:@"error"] || [alertStyle isEqualToString:@"critical"]) {
      [alert setAlertStyle:NSAlertStyleCritical];
    } else if ([alertStyle isEqualToString:@"warning"]) {
      [alert setAlertStyle:NSAlertStyleWarning];
    } else {
      [alert setAlertStyle:NSAlertStyleInformational];
    }
    
    if (parentWindow) {
      [parentWindow addChildWindow:[alert window] ordered:NSWindowAbove];
    }
    [alert runModal];
    if (parentWindow) {
      [parentWindow removeChildWindow:[alert window]];
    }
  });
}

int window_show_confirm(main__WindowInfo *info, const char *title, const char *message) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSModalResponse response;
  
  void (^runBlock)(void) = ^{
    NSWindow *parentWindow = (delegate && delegate.window) ? delegate.window : nil;
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:nsstring(title)];
    [alert setInformativeText:nsstring(message)];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    [alert setAlertStyle:NSAlertStyleWarning];
    
    if (parentWindow) {
      [parentWindow addChildWindow:[alert window] ordered:NSWindowAbove];
    }
    response = [alert runModal];
    if (parentWindow) {
      [parentWindow removeChildWindow:[alert window]];
    }
  };

  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (response == NSAlertFirstButtonReturn) ? 1 : 0;
}

int window_show_choice_dialog(main__WindowInfo *info, const char *title, const char *message, const char **choices, int choices_count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSModalResponse response;
  
  void (^runBlock)(void) = ^{
    NSWindow *parentWindow = (delegate && delegate.window) ? delegate.window : nil;
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:nsstring(title)];
    [alert setInformativeText:nsstring(message)];
    [alert setAlertStyle:NSAlertStyleInformational];
    
    for (int i = 0; i < choices_count; i++) {
      [alert addButtonWithTitle:nsstring(choices[i])];
    }
    
    if (parentWindow) {
      [parentWindow addChildWindow:[alert window] ordered:NSWindowAbove];
    }
    response = [alert runModal];
    if (parentWindow) {
      [parentWindow removeChildWindow:[alert window]];
    }
  };
  
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  
  return (int)(response - NSAlertFirstButtonReturn);
}

char *window_show_prompt(main__WindowInfo *info, const char *title, const char *message, const char *default_val) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSString *inputString = nil;
  void (^runPrompt)(void) = ^{
    NSWindow *parentWindow = (delegate && delegate.window) ? delegate.window : nil;
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:nsstring(title)];
    [alert setInformativeText:nsstring(message)];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 240, 24)];
    [input setStringValue:nsstring(default_val)];
    [alert setAccessoryView:input];
    
    if (parentWindow) {
      [parentWindow addChildWindow:[alert window] ordered:NSWindowAbove];
    }
    NSModalResponse response = [alert runModal];
    if (response == NSAlertFirstButtonReturn) {
      [input validateEditing];
      inputString = [input stringValue];
    }
    if (parentWindow) {
      [parentWindow removeChildWindow:[alert window]];
    }
  };
  
  if ([NSThread isMainThread]) {
    runPrompt();
  } else {
    dispatch_sync(dispatch_get_main_queue(), ^{
      runPrompt();
    });
  }
  
  if (inputString) {
    return strdup([inputString UTF8String]);
  }
  return strdup("");
}

char *window_select_file(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSString *filePath = nil;
  void (^runPanel)(void) = ^{
    NSWindow *parentWindow = (delegate && delegate.window) ? delegate.window : nil;
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    
    if (parentWindow) {
      [parentWindow addChildWindow:panel ordered:NSWindowAbove];
    }
    if ([panel runModal] == NSModalResponseOK) {
      filePath = [[panel URL] path];
    }
    if (parentWindow) {
      [parentWindow removeChildWindow:panel];
    }
  };
  
  if ([NSThread isMainThread]) {
    runPanel();
  } else {
    dispatch_sync(dispatch_get_main_queue(), ^{
      runPanel();
    });
  }
  
  if (filePath) {
    return strdup([filePath UTF8String]);
  }
  return strdup("");
}

char *window_select_file_with_extensions(main__WindowInfo *info, const char *extensions) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSString *filePath = nil;
  NSString *extsString = nsstring(extensions);
  void (^runPanel)(void) = ^{
    NSWindow *parentWindow = (delegate && delegate.window) ? delegate.window : nil;
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    
    if (extsString.length > 0) {
      NSArray *exts = [extsString componentsSeparatedByString:@","];
      NSMutableArray *trimmedExts = [NSMutableArray array];
      for (NSString *ext in exts) {
        NSString *trimmed = [[ext stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByReplacingOccurrencesOfString:@"*" withString:@""];
        trimmed = [trimmed stringByReplacingOccurrencesOfString:@"." withString:@""];
        if (trimmed.length > 0) {
          [trimmedExts addObject:trimmed];
        }
      }
      if (trimmedExts.count > 0) {
        [panel setAllowedFileTypes:trimmedExts];
      }
    }
    
    if (parentWindow) {
      [parentWindow addChildWindow:panel ordered:NSWindowAbove];
    }
    if ([panel runModal] == NSModalResponseOK) {
      filePath = [[panel URL] path];
    }
    if (parentWindow) {
      [parentWindow removeChildWindow:panel];
    }
  };
  
  if ([NSThread isMainThread]) {
    runPanel();
  } else {
    dispatch_sync(dispatch_get_main_queue(), ^{
      runPanel();
    });
  }
  
  if (filePath) {
    return strdup([filePath UTF8String]);
  }
  return strdup("");
}

char *window_select_folder(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSString *folderPath = nil;
  void (^runPanel)(void) = ^{
    NSWindow *parentWindow = (delegate && delegate.window) ? delegate.window : nil;
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    
    if (parentWindow) {
      [parentWindow addChildWindow:panel ordered:NSWindowAbove];
    }
    if ([panel runModal] == NSModalResponseOK) {
      folderPath = [[panel URL] path];
    }
    if (parentWindow) {
      [parentWindow removeChildWindow:panel];
    }
  };
  
  if ([NSThread isMainThread]) {
    runPanel();
  } else {
    dispatch_sync(dispatch_get_main_queue(), ^{
      runPanel();
    });
  }
  
  if (folderPath) {
    return strdup([folderPath UTF8String]);
  }
  return strdup("");
}

char *window_save_file_picker(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSString *savePath = nil;
  void (^runPanel)(void) = ^{
    NSWindow *parentWindow = (delegate && delegate.window) ? delegate.window : nil;
    NSSavePanel *panel = [NSSavePanel savePanel];
    
    if (parentWindow) {
      [parentWindow addChildWindow:panel ordered:NSWindowAbove];
    }
    if ([panel runModal] == NSModalResponseOK) {
      savePath = [[panel URL] path];
    }
    if (parentWindow) {
      [parentWindow removeChildWindow:panel];
    }
  };
  
  if ([NSThread isMainThread]) {
    runPanel();
  } else {
    dispatch_sync(dispatch_get_main_queue(), ^{
      runPanel();
    });
  }
  
  if (savePath) {
    return strdup([savePath UTF8String]);
  }
  return strdup("");
}

void window_set_control_visible_by_name(main__WindowInfo *info, const char *name, int visible) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSView *view = [delegate viewForControlName:nsstring(name)];
  if (!view) return;
  
  NSView *targetView = view;
  if ([view.superview isKindOfClass:[NSStackView class]] && view.superview != delegate.mainStackView && view.superview != delegate.currentRowStack) {
    targetView = view.superview;
  }
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [targetView setHidden:!visible];
    [delegate.mainStackView setNeedsLayout:YES];
  });
}

int window_get_control_visible_by_name(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSView *view = [delegate viewForControlName:nsstring(name)];
  if (!view) return 0;
  
  NSView *targetView = view;
  if ([view.superview isKindOfClass:[NSStackView class]] && view.superview != delegate.mainStackView && view.superview != delegate.currentRowStack) {
    targetView = view.superview;
  }
  return [targetView isHidden] ? 0 : 1;
}

void window_set_control_enabled_by_name(main__WindowInfo *info, const char *name, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSView *view = [delegate viewForControlName:nsstring(name)];
  if (!view) return;
  
  dispatch_async(dispatch_get_main_queue(), ^{
    if ([view respondsToSelector:@selector(setEnabled:)]) {
      [(id)view setEnabled:enabled];
    }
  });
}

int window_get_control_enabled_by_name(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSView *view = [delegate viewForControlName:nsstring(name)];
  if (!view) return 0;
  
  if ([view respondsToSelector:@selector(isEnabled)]) {
    return [(id)view isEnabled] ? 1 : 0;
  }
  return 1;
}

void window_set_interval(main__WindowInfo *info, int ms, const char *timer_name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  double seconds = (double)ms / 1000.0;
  NSString *timerName = nsstring(timer_name);
  
  dispatch_async(dispatch_get_main_queue(), ^{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:seconds repeats:YES block:^(NSTimer * _Nonnull t) {
      vlang_dispatch_event(delegate.win_ptr, [timerName UTF8String], "timer", "");
    }];
    
    NSString *key = [NSString stringWithFormat:@"timer_%@", timerName];
    delegate.controlsByName[key] = timer;
  });
}

void window_stop_interval(main__WindowInfo *info, const char *timer_name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [NSString stringWithFormat:@"timer_%@", nsstring(timer_name)];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    NSTimer *timer = delegate.controlsByName[key];
    if (timer) {
      [timer invalidate];
      [delegate.controlsByName removeObjectForKey:key];
    }
  });
}

void *window_add_list_box_control(main__WindowInfo *info, const char *name, const char **items, int items_count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  
  __block NSScrollView *scrollView = nil;
  void (^runBlock)(void) = ^{
    scrollView = [[NSScrollView alloc] initWithFrame:NSZeroRect];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setHasHorizontalScroller:NO];
    [scrollView setBorderType:NSNoBorder];
    [scrollView setWantsLayer:YES];
    scrollView.layer.cornerRadius = 8.0;
    scrollView.layer.borderWidth = 1.0;
    scrollView.layer.borderColor = [modernBorderColor() CGColor];
    
    // Add default Auto Layout sizing constraints
    [scrollView.widthAnchor constraintEqualToConstant:350].active = YES;
    [scrollView.heightAnchor constraintEqualToConstant:140].active = YES;
    
    NSTableView *tableView = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, 350, 140)];
    [tableView setHeaderView:nil];
    [tableView setAllowsMultipleSelection:NO];
    [tableView setIdentifier:nsstring(name)];
    [tableView setBackgroundColor:[NSColor textBackgroundColor]];
    [tableView setRowSizeStyle:NSTableViewRowSizeStyleDefault];
    [tableView setIntercellSpacing:NSMakeSize(0, 0)];
    [tableView setRowHeight:26];
    [tableView setSelectionHighlightStyle:NSTableViewSelectionHighlightStyleRegular];
    [tableView setUsesAlternatingRowBackgroundColors:NO];
    
    if (@available(macOS 11.0, *)) {
      [tableView setStyle:NSTableViewStyleFullWidth];
    }
    
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"ListColumn"];
    [column setResizingMask:NSTableColumnAutoresizingMask];
    [column setWidth:330];
    [tableView addTableColumn:column];
    
    [tableView setDataSource:delegate];
    [tableView setDelegate:delegate];
    [tableView setTarget:delegate];
    [tableView setDoubleAction:@selector(handleListDoubleClick:)];
    
    [scrollView setDocumentView:tableView];
    
    NSMutableArray *itemsArray = [NSMutableArray array];
    for (int i = 0; i < items_count; i++) {
      [itemsArray addObject:nsstring(items[i])];
    }
    
    if (!delegate.listItemsByName) {
      delegate.listItemsByName = [NSMutableDictionary dictionary];
    }
    NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    delegate.listItemsByName[key] = itemsArray;
    [tableView reloadData];
    
    applyStyleToView(scrollView, delegate.currentBackgroundColor, delegate.currentFontColor);
    
    [delegate addControlToLayout:scrollView];
    delegate.controlsByName[key] = scrollView;
  };
  
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)scrollView;
}

void window_update_list_items(main__WindowInfo *info, const char *name, const char **items, int items_count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = delegate.controlsByName[key];
    if ([view isKindOfClass:[NSScrollView class]]) {
      NSScrollView *scroll = (NSScrollView *)view;
      if ([scroll.documentView isKindOfClass:[NSTableView class]]) {
        NSTableView *tableView = (NSTableView *)scroll.documentView;
        NSMutableArray *itemsArray = [NSMutableArray array];
        for (int i = 0; i < items_count; i++) {
          [itemsArray addObject:nsstring(items[i])];
        }
        delegate.listItemsByName[key] = itemsArray;
        [tableView reloadData];
      }
    }
  });
}

void window_set_list_selected(main__WindowInfo *info, const char *name, int index) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = delegate.controlsByName[key];
    if ([view isKindOfClass:[NSScrollView class]]) {
      NSScrollView *scroll = (NSScrollView *)view;
      if ([scroll.documentView isKindOfClass:[NSTableView class]]) {
        NSTableView *tableView = (NSTableView *)scroll.documentView;
        if (index >= 0 && index < [tableView numberOfRows]) {
          [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
          [tableView scrollRowToVisible:index];
        } else {
          [tableView deselectAll:nil];
        }
      }
    }
  });
}

int window_get_list_selected(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  __block int result = -1;
  void (^runBlock)(void) = ^{
    NSView *view = delegate.controlsByName[key];
    if ([view isKindOfClass:[NSScrollView class]]) {
      NSScrollView *scroll = (NSScrollView *)view;
      if ([scroll.documentView isKindOfClass:[NSTableView class]]) {
        NSTableView *tableView = (NSTableView *)scroll.documentView;
        result = (int)[tableView selectedRow];
      }
    }
  };
  
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return result;
}

static NSTableView *listTableViewForKey(AppDelegate *delegate, NSString *key) {
  NSView *view = delegate.controlsByName[key];
  if ([view isKindOfClass:[NSScrollView class]]) {
    NSScrollView *scroll = (NSScrollView *)view;
    if ([scroll.documentView isKindOfClass:[NSTableView class]]) {
      return (NSTableView *)scroll.documentView;
    }
  }
  return nil;
}

void window_set_list_multi_select(main__WindowInfo *info, const char *name, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    NSTableView *tableView = listTableViewForKey(delegate, key);
    if (tableView) {
      [tableView setAllowsMultipleSelection:enabled ? YES : NO];
    }
  });
}

char *window_get_list_selected_indexes(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  __block char *result = NULL;
  void (^runBlock)(void) = ^{
    NSTableView *tableView = listTableViewForKey(delegate, key);
    if (tableView) {
      NSMutableArray *parts = [NSMutableArray array];
      NSIndexSet *indexes = [tableView selectedRowIndexes];
      [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [parts addObject:[NSString stringWithFormat:@"%lu", (unsigned long)idx]];
      }];
      result = strdup([[parts componentsJoinedByString:@","] UTF8String]);
    }
  };
  
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return result ? result : strdup("");
}

void window_set_list_selected_indexes(main__WindowInfo *info, const char *name, const char *csv_indexes) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSString *csv = nsstring(csv_indexes);
  
  dispatch_async(dispatch_get_main_queue(), ^{
    NSTableView *tableView = listTableViewForKey(delegate, key);
    if (!tableView) return;
    NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
    for (NSString *part in [csv componentsSeparatedByString:@","]) {
      NSString *trimmed = [part stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      if (trimmed.length == 0) continue;
      NSInteger idx = [trimmed integerValue];
      if (idx >= 0 && idx < [tableView numberOfRows]) {
        [indexes addIndex:(NSUInteger)idx];
      }
    }
    if (indexes.count == 0) {
      [tableView deselectAll:nil];
    } else {
      [tableView selectRowIndexes:indexes byExtendingSelection:NO];
      [tableView scrollRowToVisible:(NSInteger)[indexes firstIndex]];
    }
  });
}

void window_select_all_list_items(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    NSTableView *tableView = listTableViewForKey(delegate, key);
    if (tableView) {
      [tableView selectAll:nil];
    }
  });
}

void window_clear_list_selection(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    NSTableView *tableView = listTableViewForKey(delegate, key);
    if (tableView) {
      [tableView deselectAll:nil];
    }
  });
}

void *window_add_image_control(main__WindowInfo *info, const char *name, const char *file_path) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  
  __block NSImageView *imageView = nil;
  void (^runBlock)(void) = ^{
    imageView = [[NSImageView alloc] initWithFrame:NSZeroRect];
    [imageView setImageScaling:NSImageScaleProportionallyDown];
    [imageView setImageFrameStyle:NSImageFrameNone];
    
    // Add default Auto Layout constraints
    [imageView.widthAnchor constraintEqualToConstant:200].active = YES;
    [imageView.heightAnchor constraintEqualToConstant:200].active = YES;
    
    NSString *path = nsstring(file_path);
    if (path.length > 0) {
      NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
      if (image) {
        [imageView setImage:image];
      }
    }
    
    [delegate addControlToLayout:imageView];
    NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    delegate.controlsByName[key] = imageView;
  };
  
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)imageView;
}

void window_set_image_path(main__WindowInfo *info, const char *name, const char *file_path) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = delegate.controlsByName[key];
    if ([view isKindOfClass:[NSImageView class]]) {
      NSImageView *imageView = (NSImageView *)view;
      NSString *path = nsstring(file_path);
      if (path.length > 0) {
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:path];
        [imageView setImage:image];
      } else {
        [imageView setImage:nil];
      }
    }
  });
}

void window_enable_hover_events(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = delegate.controlsByName[key];
    if (!view) return;
    
    // Check if NSTrackingArea already exists to prevent duplicate area attachments
    for (NSTrackingArea *existingArea in view.trackingAreas) {
      if ([existingArea.userInfo[@"name"] isEqualToString:key]) {
        return; // Already registered
      }
    }
    
    NSTrackingAreaOptions options = NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways | NSTrackingInVisibleRect;
    NSTrackingArea *area = [[NSTrackingArea alloc] initWithRect:view.bounds
                                                        options:options
                                                          owner:delegate
                                                       userInfo:@{@"name": key}];
    [view addTrackingArea:area];
  });
}

void window_add_vertical_spacer(main__WindowInfo *info, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *spacer = [[NSView alloc] initWithFrame:NSZeroRect];
    spacer.translatesAutoresizingMaskIntoConstraints = NO;
    [spacer.heightAnchor constraintEqualToConstant:height].active = YES;
    [delegate addControlToLayout:spacer];
  });
}

void window_add_horizontal_spacer(main__WindowInfo *info, int width) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *spacer = [[NSView alloc] initWithFrame:NSZeroRect];
    spacer.translatesAutoresizingMaskIntoConstraints = NO;
    [spacer.widthAnchor constraintEqualToConstant:width].active = YES;
    [delegate addControlToLayout:spacer];
  });
}

void window_add_separator(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSBox *separator = [[NSBox alloc] initWithFrame:NSZeroRect];
    [separator setBoxType:NSBoxCustom];
    [separator setBorderType:NSLineBorder];
    [separator setBorderWidth:1.0];
    [separator setBorderColor:modernBorderColor()];
    [separator setWantsLayer:YES];
    separator.translatesAutoresizingMaskIntoConstraints = NO;
    [separator.heightAnchor constraintEqualToConstant:1.0].active = YES;
    [delegate addControlToLayout:separator];
  });
}

void *window_add_table_control(main__WindowInfo *info, const char *name, const char **columns, int columns_count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSScrollView *scrollView = nil;
  void (^runBlock)(void) = ^{
    scrollView = [[NSScrollView alloc] initWithFrame:NSZeroRect];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setHasHorizontalScroller:YES];
    [scrollView setBorderType:NSNoBorder];
    [scrollView setWantsLayer:YES];
    scrollView.layer.cornerRadius = 8.0;
    scrollView.layer.borderWidth = 1.0;
    scrollView.layer.borderColor = [modernBorderColor() CGColor];
    
    [scrollView.widthAnchor constraintEqualToConstant:450].active = YES;
    [scrollView.heightAnchor constraintEqualToConstant:200].active = YES;
    
    NSTableView *tableView = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, 450, 200)];
    [tableView setAllowsMultipleSelection:NO];
    [tableView setIdentifier:nsstring(name)];
    [tableView setGridStyleMask:NSTableViewSolidHorizontalGridLineMask];
    [tableView setRowHeight:26];
    
    if (@available(macOS 11.0, *)) {
      [tableView setStyle:NSTableViewStyleFullWidth];
    }
    
    for (int i = 0; i < columns_count; i++) {
      NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"Col_%d", i]];
      [column setTitle:nsstring(columns[i])];
      [column setWidth:100.0];
      [column setResizingMask:NSTableColumnAutoresizingMask];
      [tableView addTableColumn:column];
    }
    
    [tableView setDataSource:delegate];
    [tableView setDelegate:delegate];
    [tableView setTarget:delegate];
    [tableView setDoubleAction:@selector(handleListDoubleClick:)];
    
    [scrollView setDocumentView:tableView];
    
    applyStyleToView(scrollView, delegate.currentBackgroundColor, delegate.currentFontColor);
    
    NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [delegate addControlToLayout:scrollView];
    delegate.controlsByName[key] = scrollView;
  };
  
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)scrollView;
}

void window_set_table_rows(main__WindowInfo *info, const char *name, const char **flat_items, int total_count, int columns_count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  void (^runBlock)(void) = ^{
    NSMutableArray *rowsArray = [NSMutableArray array];
    if (flat_items && total_count > 0 && columns_count > 0) {
      int row_count = total_count / columns_count;
      for (int r = 0; r < row_count; r++) {
        NSMutableArray *colsArray = [NSMutableArray array];
        for (int c = 0; c < columns_count; c++) {
          int idx = r * columns_count + c;
          const char *value = flat_items[idx];
          [colsArray addObject:(value != NULL) ? nsstring(value) : @""];
        }
        [rowsArray addObject:colsArray];
      }
    }
    
    if (!delegate.tableItemsByName) {
      delegate.tableItemsByName = [NSMutableDictionary dictionary];
    }
    delegate.tableItemsByName[key] = rowsArray;
    
    NSView *view = delegate.controlsByName[key];
    if ([view isKindOfClass:[NSScrollView class]]) {
      NSScrollView *scroll = (NSScrollView *)view;
      if ([scroll.documentView isKindOfClass:[NSTableView class]]) {
        NSTableView *tableView = (NSTableView *)scroll.documentView;
        [tableView reloadData];
      }
    }
  };
  
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void *window_add_tree_view_control(main__WindowInfo *info, const char *name, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSScrollView *scrollView = nil;
  void (^runBlock)(void) = ^{
    scrollView = [[NSScrollView alloc] initWithFrame:NSZeroRect];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setHasHorizontalScroller:YES];
    [scrollView setBorderType:NSNoBorder];
    [scrollView setWantsLayer:YES];
    scrollView.layer.cornerRadius = 8.0;
    scrollView.layer.borderWidth = 1.0;
    scrollView.layer.borderColor = [modernBorderColor() CGColor];
    
    [scrollView.widthAnchor constraintEqualToConstant:350].active = YES;
    [scrollView.heightAnchor constraintEqualToConstant:height].active = YES;
    
    NSOutlineView *outlineView = [[NSOutlineView alloc] initWithFrame:NSMakeRect(0, 0, 350, height)];
    [outlineView setAllowsMultipleSelection:NO];
    [outlineView setIdentifier:nsstring(name)];
    [outlineView setRowHeight:26];
    [outlineView setHeaderView:nil];
    
    if (@available(macOS 11.0, *)) {
      [outlineView setStyle:NSTableViewStyleFullWidth];
    }
    
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"OutlineColumn"];
    [column setResizingMask:NSTableColumnAutoresizingMask];
    [column setWidth:330.0];
    [outlineView addTableColumn:column];
    [outlineView setOutlineTableColumn:column];
    
    [outlineView setDataSource:delegate];
    [outlineView setDelegate:delegate];
    
    [scrollView setDocumentView:outlineView];
    
    applyStyleToView(scrollView, delegate.currentBackgroundColor, delegate.currentFontColor);
    
    NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [delegate addControlToLayout:scrollView];
    delegate.controlsByName[key] = scrollView;
  };
  
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)scrollView;
}

void window_set_tree_nodes(main__WindowInfo *info, const char *name, const char **flat_items, int total_count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    NSMutableDictionary<NSString *, TreeItem *> *nodesById = [NSMutableDictionary dictionary];
    NSMutableArray<TreeItem *> *roots = [NSMutableArray array];
    
    if (flat_items && total_count > 0) {
      int item_count = total_count / 3;
      // First pass: create all TreeItem instances
      for (int i = 0; i < item_count; i++) {
        NSString *itemId = nsstring(flat_items[i * 3]);
        NSString *parentId = nsstring(flat_items[i * 3 + 1]);
        NSString *text = nsstring(flat_items[i * 3 + 2]);
        
        TreeItem *item = [[[TreeItem alloc] init] autorelease];
        item.itemId = itemId;
        item.text = text;
        
        nodesById[itemId] = item;
      }
      
      // Second pass: establish hierarchy
      for (int i = 0; i < item_count; i++) {
        NSString *itemId = nsstring(flat_items[i * 3]);
        NSString *parentId = nsstring(flat_items[i * 3 + 1]);
        
        TreeItem *item = nodesById[itemId];
        if (parentId.length == 0) {
          [roots addObject:item];
        } else {
          TreeItem *parent = nodesById[parentId];
          if (parent) {
            item.parent = parent;
            [parent.children addObject:item];
          } else {
            [roots addObject:item];
          }
        }
      }
    }
    
    delegate.treeItemsByName[key] = roots;
    
    NSView *view = delegate.controlsByName[key];
    if ([view isKindOfClass:[NSScrollView class]]) {
      NSScrollView *scroll = (NSScrollView *)view;
      if ([scroll.documentView isKindOfClass:[NSOutlineView class]]) {
        NSOutlineView *outlineView = (NSOutlineView *)scroll.documentView;
        [outlineView reloadData];
        [outlineView expandItem:nil expandChildren:YES];
      }
    }
  });
}

char *window_get_tree_selected(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  __block NSString *result = nil;
  void (^runBlock)(void) = ^{
    NSView *view = delegate.controlsByName[key];
    if ([view isKindOfClass:[NSScrollView class]]) {
      NSScrollView *scroll = (NSScrollView *)view;
      if ([scroll.documentView isKindOfClass:[NSOutlineView class]]) {
        NSOutlineView *outlineView = (NSOutlineView *)scroll.documentView;
        NSInteger selectedRow = [outlineView selectedRow];
        if (selectedRow != -1) {
          TreeItem *item = [outlineView itemAtRow:selectedRow];
          if (item) {
            result = item.itemId;
          }
        }
      }
    }
  };
  
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return result ? strdup([result UTF8String]) : strdup("");
}

void window_set_tree_selected(main__WindowInfo *info, const char *name, const char *node_id) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSString *targetId = nsstring(node_id);
  
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = delegate.controlsByName[key];
    if ([view isKindOfClass:[NSScrollView class]]) {
      NSScrollView *scroll = (NSScrollView *)view;
      if ([scroll.documentView isKindOfClass:[NSOutlineView class]]) {
        NSOutlineView *outlineView = (NSOutlineView *)scroll.documentView;
        NSArray<TreeItem *> *roots = delegate.treeItemsByName[key];
        TreeItem *item = [delegate findTreeItemWithId:targetId inItems:roots];
        if (item) {
          TreeItem *parent = item.parent;
          NSMutableArray<TreeItem *> *parentsToExpand = [NSMutableArray array];
          while (parent) {
            [parentsToExpand insertObject:parent atIndex:0];
            parent = parent.parent;
          }
          for (TreeItem *p in parentsToExpand) {
            [outlineView expandItem:p];
          }
          
          NSInteger row = [outlineView rowForItem:item];
          if (row != -1) {
            [outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
            [outlineView scrollRowToVisible:row];
          }
        }
      }
    }
  });
}

void window_enable_status_bar(main__WindowInfo *info, const char *icon_path) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    
    delegate.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    if (icon_path && strlen(icon_path) > 0) {
      NSImage *image = [[NSImage alloc] initWithContentsOfFile:nsstring(icon_path)];
      if (image) {
        [image setSize:NSMakeSize(18, 18)];
        [image setTemplate:YES];
        delegate.statusItem.button.image = image;
      } else {
        delegate.statusItem.button.title = delegate.window.title;
      }
    } else {
      delegate.statusItem.button.title = delegate.window.title;
    }
    
    delegate.statusBarMenu = [[NSMenu alloc] init];
    delegate.statusItem.menu = delegate.statusBarMenu;
    
    [delegate.window orderOut:nil];
  });
}

void window_show(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    [delegate.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
  });
}

void window_run_on_main_thread(void *callback_fn, void *context) {
  void (*cb)(void *) = (void (*)(void *))callback_fn;
  dispatch_async(dispatch_get_main_queue(), ^{
    cb(context);
  });
}

void *window_add_dropdown_control(main__WindowInfo *info, const char *name, const char **items, int items_count, const char *selected) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < items_count; i++) {
      [arr addObject:nsstring(items[i])];
    }
    control = [delegate makeDropdownWithName:nsstring(name) items:arr selected:nsstring(selected)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void *window_add_segmented_control_custom(main__WindowInfo *info, const char *name, const char **items, int items_count, const char *selected) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < items_count; i++) {
      [arr addObject:nsstring(items[i])];
    }
    control = [delegate makeSegmentedControlWithName:nsstring(name) items:arr selected:nsstring(selected)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void *window_add_radio_group_control(main__WindowInfo *info, const char *name, const char **items, int items_count, const char *selected) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < items_count; i++) {
      [arr addObject:nsstring(items[i])];
    }
    control = [delegate makeRadioGroupWithName:nsstring(name) items:arr selected:nsstring(selected)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void *window_add_switch_control(main__WindowInfo *info, const char *name, const char *label, int checked) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeSwitchWithName:nsstring(name) label:nsstring(label) checked:checked != 0];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void *window_add_search_field_control(main__WindowInfo *info, const char *name, const char *placeholder) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeSearchFieldWithName:nsstring(name) placeholder:nsstring(placeholder)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void *window_add_combo_box_control(main__WindowInfo *info, const char *name, const char **items, int items_count, const char *selected) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < items_count; i++) {
      [arr addObject:nsstring(items[i])];
    }
    control = [delegate makeComboBoxWithName:nsstring(name) items:arr selected:nsstring(selected)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void *window_add_level_indicator_control(main__WindowInfo *info, const char *name, int style, int min_val, int max_val, int value) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeLevelIndicatorWithName:nsstring(name) style:style minValue:(double)min_val maxValue:(double)max_val value:(double)value];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void *window_add_spinner_control(main__WindowInfo *info, const char *name, int active) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeSpinnerWithName:nsstring(name) active:active != 0];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void *window_add_path_control(main__WindowInfo *info, const char *name, const char *path) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makePathControlWithName:nsstring(name) path:nsstring(path)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void *window_add_token_field_control(main__WindowInfo *info, const char *name, const char *value) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeTokenFieldWithName:nsstring(name) value:nsstring(value)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void window_set_min_size(main__WindowInfo *info, int width, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate.window setMinSize:NSMakeSize(width, height)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_set_max_size(main__WindowInfo *info, int width, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate.window setMaxSize:NSMakeSize(width, height)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_set_resizable(main__WindowInfo *info, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    NSWindowStyleMask mask = [delegate.window styleMask];
    if (enabled) {
      mask |= NSWindowStyleMaskResizable;
    } else {
      mask &= ~NSWindowStyleMaskResizable;
    }
    [delegate.window setStyleMask:mask];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_set_minimizable(main__WindowInfo *info, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    NSWindowStyleMask mask = [delegate.window styleMask];
    if (enabled) {
      mask |= NSWindowStyleMaskMiniaturizable;
    } else {
      mask &= ~NSWindowStyleMaskMiniaturizable;
    }
    [delegate.window setStyleMask:mask];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_set_maximizable(main__WindowInfo *info, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    NSButton *zoomButton = [delegate.window standardWindowButton:NSWindowZoomButton];
    if (zoomButton) {
      [zoomButton setEnabled:enabled];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_close(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate.window close];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_async(dispatch_get_main_queue(), runBlock);
  }
}

void window_hide(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate.window orderOut:nil];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_async(dispatch_get_main_queue(), runBlock);
  }
}

void window_center(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate.window center];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_async(dispatch_get_main_queue(), runBlock);
  }
}

void window_align(main__WindowInfo *info, const char *alignment) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *alignStr = [[[NSString stringWithUTF8String:alignment] lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    NSScreen *screen = [delegate.window screen];
    if (!screen) {
      screen = [NSScreen mainScreen];
    }
    NSRect screenFrame = [screen visibleFrame];
    NSRect windowFrame = [delegate.window frame];
    
    CGFloat sw = screenFrame.size.width;
    CGFloat sh = screenFrame.size.height;
    CGFloat sx = screenFrame.origin.x;
    CGFloat sy = screenFrame.origin.y;
    CGFloat ww = windowFrame.size.width;
    CGFloat wh = windowFrame.size.height;
    
    // Default to center
    CGFloat x = sx + (sw - ww) / 2.0;
    CGFloat y = sy + (sh - wh) / 2.0;
    
    // Parse horizontal
    if ([alignStr rangeOfString:@"left"].location != NSNotFound) {
      x = sx;
    } else if ([alignStr rangeOfString:@"right"].location != NSNotFound) {
      x = sx + sw - ww;
    }
    
    // Parse vertical
    if ([alignStr rangeOfString:@"top"].location != NSNotFound) {
      y = sy + sh - wh;
    } else if ([alignStr rangeOfString:@"bottom"].location != NSNotFound) {
      y = sy;
    }
    
    [delegate.window setFrameOrigin:NSMakePoint(x, y)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_async(dispatch_get_main_queue(), runBlock);
  }
}

void window_set_size(main__WindowInfo *info, int width, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate.window setContentSize:NSMakeSize(width, height)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

int window_get_width(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int result = 0;
  void (^runBlock)(void) = ^{
    result = (int)delegate.window.frame.size.width;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return result;
}

int window_get_height(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int result = 0;
  void (^runBlock)(void) = ^{
    result = (int)delegate.window.frame.size.height;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return result;
}

void window_set_position(main__WindowInfo *info, int x, int y) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    NSRect frame = delegate.window.frame;
    NSRect screenFrame = [[NSScreen mainScreen] frame];
    CGFloat flippedY = screenFrame.size.height - y - frame.size.height;
    [delegate.window setFrameOrigin:NSMakePoint(x, flippedY)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_async(dispatch_get_main_queue(), runBlock);
  }
}

int window_get_x(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int result = 0;
  void (^runBlock)(void) = ^{
    result = (int)delegate.window.frame.origin.x;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return result;
}

int window_get_y(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int result = 0;
  void (^runBlock)(void) = ^{
    NSRect screenFrame = [[NSScreen mainScreen] frame];
    result = (int)(screenFrame.size.height - delegate.window.frame.origin.y - delegate.window.frame.size.height);
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return result;
}

void window_set_opacity(main__WindowInfo *info, double opacity) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate.window setAlphaValue:opacity];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

double window_get_opacity(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block double result = 1.0;
  void (^runBlock)(void) = ^{
    result = (double)delegate.window.alphaValue;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return result;
}

void window_toggle_fullscreen(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate.window toggleFullScreen:nil];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_async(dispatch_get_main_queue(), runBlock);
  }
}

void window_minimize(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate.window miniaturize:nil];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_async(dispatch_get_main_queue(), runBlock);
  }
}

void window_deminimize(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate.window deminiaturize:nil];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_async(dispatch_get_main_queue(), runBlock);
  }
}

void window_maximize(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate.window zoom:nil];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_async(dispatch_get_main_queue(), runBlock);
  }
}

int window_is_minimized(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int result = 0;
  void (^runBlock)(void) = ^{
    result = delegate.window.isMiniaturized ? 1 : 0;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return result;
}

int window_is_maximized(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int result = 0;
  void (^runBlock)(void) = ^{
    result = delegate.window.isZoomed ? 1 : 0;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return result;
}

int window_is_fullscreen(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int result = 0;
  void (^runBlock)(void) = ^{
    result = (delegate.window.styleMask & NSWindowStyleMaskFullScreen) ? 1 : 0;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return result;
}

int window_is_active(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int result = 0;
  void (^runBlock)(void) = ^{
    result = delegate.window.isKeyWindow ? 1 : 0;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return result;
}

void window_set_titlebar_visible(main__WindowInfo *info, int visible) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (visible) {
      [delegate.window setTitlebarAppearsTransparent:NO];
      [delegate.window setTitleVisibility:NSWindowTitleVisible];
    } else {
      [delegate.window setTitlebarAppearsTransparent:YES];
      [delegate.window setTitleVisibility:NSWindowTitleHidden];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_async(dispatch_get_main_queue(), runBlock);
  }
}

void window_request_attention(main__WindowInfo *info, int critical) {
  (void)info;
  dispatch_async(dispatch_get_main_queue(), ^{
    [NSApp requestUserAttention:critical ? NSCriticalRequest : NSInformationalRequest];
  });
}

void window_set_closable(main__WindowInfo *info, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    NSWindowStyleMask mask = [delegate.window styleMask];
    if (enabled) {
      mask |= NSWindowStyleMaskClosable;
    } else {
      mask &= ~NSWindowStyleMaskClosable;
    }
    [delegate.window setStyleMask:mask];
    NSButton *closeButton = [delegate.window standardWindowButton:NSWindowCloseButton];
    if (closeButton) {
      [closeButton setEnabled:enabled];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

int window_get_closable(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int result = 0;
  void (^runBlock)(void) = ^{
    result = (delegate.window.styleMask & NSWindowStyleMaskClosable) ? 1 : 0;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return result;
}

void window_set_has_shadow(main__WindowInfo *info, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate.window setHasShadow:enabled != 0];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

int window_get_has_shadow(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int result = 0;
  void (^runBlock)(void) = ^{
    result = delegate.window.hasShadow ? 1 : 0;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return result;
}

void window_set_movable_by_window_background(main__WindowInfo *info, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate.window setMovableByWindowBackground:enabled != 0];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

int window_get_movable_by_window_background(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int result = 0;
  void (^runBlock)(void) = ^{
    result = delegate.window.movableByWindowBackground ? 1 : 0;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return result;
}

int window_is_visible(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int result = 0;
  void (^runBlock)(void) = ^{
    result = delegate.window.isVisible ? 1 : 0;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return result;
}

void window_set_title_visible(main__WindowInfo *info, int visible) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate.window setTitleVisibility:visible ? NSWindowTitleVisible : NSWindowTitleHidden];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

int window_get_title_visible(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int result = 0;
  void (^runBlock)(void) = ^{
    result = (delegate.window.titleVisibility == NSWindowTitleVisible) ? 1 : 0;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return result;
}

int window_get_titlebar_visible(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int result = 0;
  void (^runBlock)(void) = ^{
    result = (delegate.window.titleVisibility == NSWindowTitleVisible) ? 1 : 0;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return result;
}

void window_deliver_notification(const char *title, const char *message) {
  NSString *titleStr = nsstring(title);
  NSString *msgStr = nsstring(message);
  dispatch_async(dispatch_get_main_queue(), ^{
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    [notification setTitle:titleStr];
    [notification setInformativeText:msgStr];
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
  });
}

void window_set_dock_badge(const char *text) {
  NSString *badge = nsstring(text);
  dispatch_async(dispatch_get_main_queue(), ^{
    [[NSApp dockTile] setBadgeLabel:badge];
  });
}

void window_set_slider_range(main__WindowInfo *info, const char *name, double min_val, double max_val) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *controlName = nsstring(name);
  void (^runBlock)(void) = ^{
    NSView *view = [delegate viewForControlName:controlName];
    if ([view isKindOfClass:[NSSlider class]]) {
      NSSlider *slider = (NSSlider *)view;
      [slider setMinValue:min_val];
      [slider setMaxValue:max_val];
    } else if ([view isKindOfClass:[NSLevelIndicator class]]) {
      NSLevelIndicator *indicator = (NSLevelIndicator *)view;
      [indicator setMinValue:min_val];
      [indicator setMaxValue:max_val];
    } else if ([view isKindOfClass:[NSStepper class]]) {
      NSStepper *stepper = (NSStepper *)view;
      [stepper setMinValue:min_val];
      [stepper setMaxValue:max_val];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_async(dispatch_get_main_queue(), runBlock);
  }
}

void *window_add_link_control(main__WindowInfo *info, const char *name, const char *text, const char *url) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeLinkWithName:nsstring(name) text:nsstring(text) url:nsstring(url)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void window_beep() {
  NSBeep();
}

void *window_add_disclosure_control(main__WindowInfo *info, const char *name, const char *title, int open) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeDisclosureButtonWithName:nsstring(name) title:nsstring(title) state:open == 1];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void window_enable_search_history(main__WindowInfo *info, const char *name, const char *autosave_name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *controlName = nsstring(name);
  NSString *autosave = nsstring(autosave_name);
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = [delegate viewForControlName:controlName];
    if ([view isKindOfClass:[NSSearchField class]]) {
      NSSearchField *searchField = (NSSearchField *)view;
      [searchField setRecentsAutosaveName:autosave];
    }
  });
}

void *window_add_stepper_control(main__WindowInfo *info, const char *name, double min_val, double max_val, double step, double value) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeStepperWithName:nsstring(name) minValue:min_val maxValue:max_val step:step value:value];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void *window_add_help_button_control(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeHelpButtonWithName:nsstring(name)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void *window_add_knob_control(main__WindowInfo *info, const char *name, double min_val, double max_val, double value) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeKnobWithName:nsstring(name) minValue:min_val maxValue:max_val value:value];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void *window_add_pull_down_control(main__WindowInfo *info, const char *name, const char *title, const char **items, int items_count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < items_count; i++) {
      [arr addObject:nsstring(items[i])];
    }
    control = [delegate makePullDownWithName:nsstring(name) title:nsstring(title) items:arr];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void *window_add_image_button_control(main__WindowInfo *info, const char *name, const char *symbol, const char *title) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeImageButtonWithName:nsstring(name) symbol:nsstring(symbol) title:nsstring(title)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void window_set_status_bar_icon(main__WindowInfo *info, const char *icon_path) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    if (delegate.statusItem) {
      if (icon_path && strlen(icon_path) > 0) {
        NSImage *image = [[NSImage alloc] initWithContentsOfFile:nsstring(icon_path)];
        if (image) {
          [image setSize:NSMakeSize(18, 18)];
          [image setTemplate:YES];
          delegate.statusItem.button.image = image;
          delegate.statusItem.button.title = @"";
        }
      }
    }
  });
}

void window_set_status_bar_title(main__WindowInfo *info, const char *title) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *titleStr = nsstring(title);
  dispatch_async(dispatch_get_main_queue(), ^{
    if (delegate.statusItem) {
      delegate.statusItem.button.title = titleStr;
      delegate.statusItem.button.image = nil;
    }
  });
}

void window_set_dock_icon(const char *image_path) {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (image_path && strlen(image_path) > 0) {
      NSImage *image = [[NSImage alloc] initWithContentsOfFile:nsstring(image_path)];
      if (image) {
        [NSApp setApplicationIconImage:image];
      }
    } else {
      [NSApp setApplicationIconImage:nil];
    }
  });
}

void window_play_system_sound(const char *sound_name) {
  NSString *name = nsstring(sound_name);
  dispatch_async(dispatch_get_main_queue(), ^{
    NSSound *sound = [NSSound soundNamed:name];
    [sound play];
  });
}

// Animations and Transition Helpers
void window_animate_control_opacity(main__WindowInfo *info, const char *name, double opacity, int duration_ms) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSView *view = [delegate viewForControlName:nsstring(name)];
  if (!view) return;
  dispatch_async(dispatch_get_main_queue(), ^{
    view.wantsLayer = YES;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      context.duration = (double)duration_ms / 1000.0;
      context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
      [[view animator] setAlphaValue:opacity];
    } completionHandler:^{
    }];
  });
}

void window_animate_opacity(main__WindowInfo *info, double opacity, int duration_ms) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  if (!delegate || !delegate.window) return;
  dispatch_async(dispatch_get_main_queue(), ^{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      context.duration = (double)duration_ms / 1000.0;
      context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
      [[delegate.window animator] setAlphaValue:opacity];
    } completionHandler:^{
    }];
  });
}

void window_animate_control_shake(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSView *view = [delegate viewForControlName:nsstring(name)];
  if (!view) return;
  dispatch_async(dispatch_get_main_queue(), ^{
    view.wantsLayer = YES;
    CAKeyframeAnimation *shake = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    shake.duration = 0.4;
    shake.values = @[@0, @-10, @10, @-10, @10, @-5, @5, @-2, @2, @0];
    [view.layer addAnimation:shake forKey:@"shake"];
  });
}

void window_shake(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  if (!delegate || !delegate.window) return;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSRect frame = [delegate.window frame];
    CAKeyframeAnimation *shake = [CAKeyframeAnimation animationWithKeyPath:@"frameOrigin"];
    shake.duration = 0.4;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithPoint:NSMakePoint(frame.origin.x, frame.origin.y)]];
    for (int i = 0; i < 4; i++) {
      [values addObject:[NSValue valueWithPoint:NSMakePoint(frame.origin.x - 10, frame.origin.y)]];
      [values addObject:[NSValue valueWithPoint:NSMakePoint(frame.origin.x + 10, frame.origin.y)]];
    }
    [values addObject:[NSValue valueWithPoint:NSMakePoint(frame.origin.x, frame.origin.y)]];
    
    shake.values = values;
    [delegate.window setAnimations:@{@"frameOrigin": shake}];
    [[delegate.window animator] setFrameOrigin:frame.origin];
  });
}

void window_animate_control_width(main__WindowInfo *info, const char *name, int width, int duration_ms) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSView *view = [delegate viewForControlName:nsstring(name)];
  if (!view) return;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSLayoutConstraint *found = findWidthConstraint(view);
    if (!found) {
      // Pin the current width first so the change animates from the live value.
      found = [view.widthAnchor constraintEqualToConstant:view.frame.size.width];
      found.active = YES;
      [view.window.contentView layoutSubtreeIfNeeded];
    }
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      context.duration = (double)duration_ms / 1000.0;
      context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
      context.allowsImplicitAnimation = YES;
      [[found animator] setConstant:width];
      [view.window.contentView layoutSubtreeIfNeeded];
    } completionHandler:^{
    }];
  });
}

void window_animate_control_height(main__WindowInfo *info, const char *name, int height, int duration_ms) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSView *view = [delegate viewForControlName:nsstring(name)];
  if (!view) return;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSLayoutConstraint *found = findHeightConstraint(view);
    if (!found) {
      found = [view.heightAnchor constraintEqualToConstant:view.frame.size.height];
      found.active = YES;
      [view.window.contentView layoutSubtreeIfNeeded];
    }
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      context.duration = (double)duration_ms / 1000.0;
      context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
      context.allowsImplicitAnimation = YES;
      [[found animator] setConstant:height];
      [view.window.contentView layoutSubtreeIfNeeded];
    } completionHandler:^{
    }];
  });
}

void window_animate_control_size(main__WindowInfo *info, const char *name, int width, int height, int duration_ms) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSView *view = [delegate viewForControlName:nsstring(name)];
  if (!view) return;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSLayoutConstraint *foundW = findWidthConstraint(view);
    NSLayoutConstraint *foundH = findHeightConstraint(view);
    BOOL needsInitialLayout = NO;
    if (!foundW) {
      foundW = [view.widthAnchor constraintEqualToConstant:view.frame.size.width];
      foundW.active = YES;
      needsInitialLayout = YES;
    }
    if (!foundH) {
      foundH = [view.heightAnchor constraintEqualToConstant:view.frame.size.height];
      foundH.active = YES;
      needsInitialLayout = YES;
    }
    if (needsInitialLayout) {
      [view.window.contentView layoutSubtreeIfNeeded];
    }
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      context.duration = (double)duration_ms / 1000.0;
      context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
      context.allowsImplicitAnimation = YES;
      [[foundW animator] setConstant:width];
      [[foundH animator] setConstant:height];
      [view.window.contentView layoutSubtreeIfNeeded];
    } completionHandler:^{
    }];
  });
}

void window_animate_size(main__WindowInfo *info, int width, int height, int duration_ms) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  if (!delegate || !delegate.window) return;
  dispatch_async(dispatch_get_main_queue(), ^{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      context.duration = (double)duration_ms / 1000.0;
      context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
      
      NSRect frame = delegate.window.frame;
      CGFloat diffHeight = height - frame.size.height;
      NSRect targetFrame = NSMakeRect(frame.origin.x, frame.origin.y - diffHeight, width, height);
      [[delegate.window animator] setFrame:targetFrame display:YES];
    } completionHandler:^{
    }];
  });
}

void window_animate_position(main__WindowInfo *info, int x, int y, int duration_ms) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  if (!delegate || !delegate.window) return;
  dispatch_async(dispatch_get_main_queue(), ^{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      context.duration = (double)duration_ms / 1000.0;
      context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
      
      NSRect frame = delegate.window.frame;
      NSRect screenFrame = [[NSScreen mainScreen] frame];
      CGFloat flippedY = screenFrame.size.height - y - frame.size.height;
      NSRect targetFrame = NSMakeRect(x, flippedY, frame.size.width, frame.size.height);
      [[delegate.window animator] setFrame:targetFrame display:YES];
    } completionHandler:^{
    }];
  });
}

void window_animate_bounds(main__WindowInfo *info, int x, int y, int width, int height, int duration_ms) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  if (!delegate || !delegate.window) return;
  dispatch_async(dispatch_get_main_queue(), ^{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      context.duration = (double)duration_ms / 1000.0;
      context.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
      
      NSRect screenFrame = [[NSScreen mainScreen] frame];
      CGFloat flippedY = screenFrame.size.height - y - height;
      NSRect targetFrame = NSMakeRect(x, flippedY, width, height);
      [[delegate.window animator] setFrame:targetFrame display:YES];
    } completionHandler:^{
    }];
  });
}

void window_add_toolbar_item(main__WindowInfo *info, const char *name, const char *label, const char *tooltip, const char *symbol) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  if (!delegate) return;
  NSString *itemName = nsstring(name);
  NSString *itemLabel = nsstring(label);
  NSString *itemTooltip = nsstring(tooltip);
  NSString *icon = nsstring(symbol);
  dispatch_async(dispatch_get_main_queue(), ^{
    if (!delegate.toolbarItems) {
      delegate.toolbarItems = [NSMutableDictionary dictionary];
      delegate.toolbarOrder = [NSMutableArray array];
    }
    
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemName];
    [item setLabel:itemLabel];
    [item setPaletteLabel:itemLabel];
    [item setToolTip:itemTooltip];
    
    if (icon && icon.length > 0) {
      NSImage *image = nil;
      if (@available(macOS 11.0, *)) {
        image = [NSImage imageWithSystemSymbolName:icon accessibilityDescription:nil];
      }
      if (!image) {
        image = [NSImage imageNamed:icon];
      }
      if (!image) {
        image = [[NSImage alloc] initWithContentsOfFile:icon];
      }
      if (image) {
        [item setImage:image];
      }
    }
    
    [item setTarget:delegate];
    [item setAction:@selector(handleToolbarItemClicked:)];
    
    delegate.toolbarItems[itemName] = item;
    [delegate.toolbarOrder addObject:itemName];
    
    if (!delegate.window.toolbar) {
      [delegate setupToolbar];
    } else {
      NSToolbar *toolbar = delegate.window.toolbar;
      [delegate.window setToolbar:nil];
      [delegate.window setToolbar:toolbar];
    }
  });
}

void window_add_toolbar_space(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  if (!delegate) return;
  dispatch_async(dispatch_get_main_queue(), ^{
    if (!delegate.toolbarItems) {
      delegate.toolbarItems = [NSMutableDictionary dictionary];
      delegate.toolbarOrder = [NSMutableArray array];
    }
    [delegate.toolbarOrder addObject:@"space"];
    
    if (!delegate.window.toolbar) {
      [delegate setupToolbar];
    } else {
      NSToolbar *toolbar = delegate.window.toolbar;
      [delegate.window setToolbar:nil];
      [delegate.window setToolbar:toolbar];
    }
  });
}

void window_add_toolbar_flexible_space(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  if (!delegate) return;
  dispatch_async(dispatch_get_main_queue(), ^{
    if (!delegate.toolbarItems) {
      delegate.toolbarItems = [NSMutableDictionary dictionary];
      delegate.toolbarOrder = [NSMutableArray array];
    }
    [delegate.toolbarOrder addObject:@"flexible_space"];
    
    if (!delegate.window.toolbar) {
      [delegate setupToolbar];
    } else {
      NSToolbar *toolbar = delegate.window.toolbar;
      [delegate.window setToolbar:nil];
      [delegate.window setToolbar:toolbar];
    }
  });
}

void window_set_toolbar_style(main__WindowInfo *info, const char *style) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  if (!delegate || !delegate.window) return;
  NSString *styleStr = nsstring(style);
  dispatch_async(dispatch_get_main_queue(), ^{
    if (@available(macOS 11.0, *)) {
      if ([styleStr isEqualToString:@"expanded"]) {
        [delegate.window setToolbarStyle:NSWindowToolbarStyleExpanded];
      } else if ([styleStr isEqualToString:@"preference"]) {
        [delegate.window setToolbarStyle:NSWindowToolbarStylePreference];
      } else if ([styleStr isEqualToString:@"unified"]) {
        [delegate.window setToolbarStyle:NSWindowToolbarStyleUnified];
      } else if ([styleStr isEqualToString:@"unified_compact"]) {
        [delegate.window setToolbarStyle:NSWindowToolbarStyleUnifiedCompact];
      } else {
        [delegate.window setToolbarStyle:NSWindowToolbarStyleAutomatic];
      }
    }
  });
}

void window_show_sheet_alert(main__WindowInfo *info, const char *title, const char *message, const char *style) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  if (!delegate || !delegate.window) return;
  NSString *titleStr = nsstring(title);
  NSString *messageStr = nsstring(message);
  NSString *styleStr = nsstring(style);
  dispatch_async(dispatch_get_main_queue(), ^{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:titleStr];
    [alert setInformativeText:messageStr];
    if ([styleStr isEqualToString:@"warning"]) {
      [alert setAlertStyle:NSAlertStyleWarning];
    } else if ([styleStr isEqualToString:@"critical"]) {
      [alert setAlertStyle:NSAlertStyleCritical];
    } else {
      [alert setAlertStyle:NSAlertStyleInformational];
    }
    [alert beginSheetModalForWindow:delegate.window completionHandler:nil];
  });
}

void window_add_dock_menu_item(main__WindowInfo *info, const char *title, const char *handler_name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  if (!delegate) return;
  NSString *titleStr = nsstring(title);
  NSString *handler = nsstring(handler_name);
  dispatch_async(dispatch_get_main_queue(), ^{
    if (!delegate.dockMenu) {
      delegate.dockMenu = [[NSMenu alloc] initWithTitle:@"DockMenu"];
    }
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:titleStr action:@selector(handleMenuItemClicked:) keyEquivalent:@""];
    [item setTarget:delegate];
    [item setRepresentedObject:handler];
    [delegate.dockMenu addItem:item];
  });
}

void *window_add_console_control(main__WindowInfo *info, const char *name, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *scroll = nil;
  void (^runBlock)(void) = ^{
    scroll = [delegate makeConsoleWithName:nsstring(name) height:height];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)scroll;
}

void window_append_console_text(main__WindowInfo *info, const char *name, const char *text, int level) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSString *nsText = nsstring(text);
  void (^runBlock)(void) = ^{
    id view = delegate.controlsByName[key];
    if ([view isKindOfClass:[NSScrollView class]]) {
      NSView *doc = [(NSScrollView *)view documentView];
      if ([doc isKindOfClass:[NSTextView class]]) {
        NSTextView *tv = (NSTextView *)doc;
        
        NSColor *color = [NSColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
        if (level == 1) {
          color = [NSColor colorWithRed:0.4 green:0.7 blue:1.0 alpha:1.0];
        } else if (level == 2) {
          color = [NSColor colorWithRed:1.0 green:0.8 blue:0.2 alpha:1.0];
        } else if (level == 3) {
          color = [NSColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:1.0];
        } else if (level == 4) {
          color = [NSColor colorWithRed:0.3 green:0.8 blue:0.4 alpha:1.0];
        }
        
        NSDictionary *attrs = @{
          NSForegroundColorAttributeName: color,
          NSFontAttributeName: tv.font ?: [NSFont fontWithName:@"Menlo" size:11.0] ?: [NSFont userFixedPitchFontOfSize:11.0]
        };
        
        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:nsText attributes:attrs];
        [[tv textStorage] appendAttributedString:attrStr];
        [tv scrollRangeToVisible:NSMakeRange([[tv textStorage] length], 0)];
        [attrStr release];
      }
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_clear_console(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    id view = delegate.controlsByName[key];
    if ([view isKindOfClass:[NSScrollView class]]) {
      NSView *doc = [(NSScrollView *)view documentView];
      if ([doc isKindOfClass:[NSTextView class]]) {
        NSTextView *tv = (NSTextView *)doc;
        [tv setString:@""];
      }
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void *window_add_chart_control(main__WindowInfo *info, const char *name, const char *chart_type, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *chart = nil;
  void (^runBlock)(void) = ^{
    chart = [delegate makeChartViewWithName:nsstring(name) chartType:nsstring(chart_type) height:height];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)chart;
}

void window_set_chart_data(main__WindowInfo *info, const char *name, const double *values, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    id view = delegate.controlsByName[key];
    if ([view isKindOfClass:[ChartView class]]) {
      ChartView *cv = (ChartView *)view;
      [cv.dataPoints removeAllObjects];
      for (int i = 0; i < count; i++) {
        [cv.dataPoints addObject:@(values[i])];
      }
      [cv setNeedsDisplay:YES];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void *window_add_shortcut_recorder_control(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *recorder = nil;
  void (^runBlock)(void) = ^{
    recorder = [delegate makeShortcutRecorderWithName:nsstring(name)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)recorder;
}

void *window_add_circular_progress_control(main__WindowInfo *info, const char *name, double value, double min_val, double max_val) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *cp = nil;
  void (^runBlock)(void) = ^{
    cp = [delegate makeCircularProgressWithName:nsstring(name) value:value minVal:min_val maxVal:max_val];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)cp;
}

void window_set_circular_progress_value(main__WindowInfo *info, const char *name, double value) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    id view = delegate.controlsByName[key];
    if ([view isKindOfClass:[CircularProgressView class]]) {
      CircularProgressView *cp = (CircularProgressView *)view;
      cp.value = value;
      [cp setNeedsDisplay:YES];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void *window_add_breadcrumbs_control(main__WindowInfo *info, const char *name, const char **segments, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *stack = nil;
  void (^runBlock)(void) = ^{
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
      [arr addObject:nsstring(segments[i])];
    }
    stack = [delegate makeBreadcrumbsWithName:nsstring(name) segments:arr];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)stack;
}

void window_set_breadcrumbs(main__WindowInfo *info, const char *name, const char **segments, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    id view = delegate.controlsByName[key];
    if ([view isKindOfClass:[NSStackView class]]) {
      NSStackView *stack = (NSStackView *)view;
      NSArray *subviews = [stack.arrangedSubviews copy];
      for (NSView *v in subviews) {
        [stack removeArrangedSubview:v];
        [v removeFromSuperview];
      }
      [subviews release];
      
      for (int i = 0; i < count; i++) {
        NSString *segText = nsstring(segments[i]);
        NSButton *btn = [[NSButton alloc] initWithFrame:NSZeroRect];
        [btn setButtonType:NSButtonTypeMomentaryPushIn];
        [btn setBordered:NO];
        [btn setTitle:segText];
        [btn setTarget:delegate];
        [btn setAction:@selector(handleBreadcrumbClicked:)];
        [btn setIdentifier:segText];
        [btn setFont:[NSFont systemFontOfSize:12 weight:NSFontWeightMedium]];
        [btn setWantsLayer:YES];
        applyStyleToView(btn, nil, delegate.currentFontColor ?: [NSColor controlAccentColor]);
        [stack addArrangedSubview:btn];
        [btn release];
        
        if (i < count - 1) {
          NSTextField *chevron = [NSTextField labelWithString:@"›"];
          [chevron setFont:[NSFont systemFontOfSize:12 weight:NSFontWeightBold]];
          [chevron setTextColor:[NSColor secondaryLabelColor]];
          [stack addArrangedSubview:chevron];
        }
      }
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void *window_add_property_grid_control(main__WindowInfo *info, const char *name, const char **keys, const char **values, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *grid = nil;
  void (^runBlock)(void) = ^{
    NSMutableArray *kArr = [NSMutableArray array];
    NSMutableArray *vArr = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
      [kArr addObject:nsstring(keys[i])];
      [vArr addObject:nsstring(values[i])];
    }
    grid = [delegate makePropertyGridWithName:nsstring(name) keys:kArr values:vArr];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)grid;
}

void window_set_property_grid_value(main__WindowInfo *info, const char *name, const char *key, const char *value) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *gKey = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSString *pKey = nsstring(key);
  NSString *pVal = nsstring(value);
  void (^runBlock)(void) = ^{
    id view = delegate.controlsByName[gKey];
    if ([view isKindOfClass:[NSStackView class]]) {
      NSStackView *grid = (NSStackView *)view;
      for (NSView *row in grid.arrangedSubviews) {
        if ([row isKindOfClass:[NSStackView class]]) {
          NSStackView *rowStack = (NSStackView *)row;
          for (NSView *sub in rowStack.arrangedSubviews) {
            if ([sub isKindOfClass:[NSTextField class]] && [sub.identifier isEqualToString:pKey]) {
              [(NSTextField *)sub setStringValue:pVal];
              break;
            }
          }
        }
      }
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void *window_add_color_grid_control(main__WindowInfo *info, const char *name, const char **colors, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *cg = nil;
  void (^runBlock)(void) = ^{
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
      [arr addObject:nsstring(colors[i])];
    }
    cg = [delegate makeColorGridWithName:nsstring(name) colors:arr];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)cg;
}

void window_set_color_grid_selected(main__WindowInfo *info, const char *name, const char *color) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *gKey = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSString *cStr = nsstring(color);
  void (^runBlock)(void) = ^{
    id view = delegate.controlsByName[gKey];
    if ([view isKindOfClass:[ColorGridView class]]) {
      ColorGridView *cg = (ColorGridView *)view;
      NSInteger index = -1;
      for (NSUInteger i = 0; i < cg.colorHexStrings.count; i++) {
        if ([cg.colorHexStrings[i] isEqualToString:cStr]) {
          index = i;
          break;
        }
      }
      cg.selectedIndex = index;
      [cg setNeedsDisplay:YES];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void *window_add_grid_control(main__WindowInfo *info, const char *name, const char **headers, int headers_count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSScrollView *scrollView = nil;
  void (^runBlock)(void) = ^{
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < headers_count; i++) {
      [arr addObject:nsstring(headers[i])];
    }
    
    NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!delegate.gridItemsByName) {
      delegate.gridItemsByName = [NSMutableDictionary dictionary];
    }
    if (!delegate.gridHeadersByName) {
      delegate.gridHeadersByName = [NSMutableDictionary dictionary];
    }
    delegate.gridItemsByName[key] = [NSMutableArray array];
    delegate.gridHeadersByName[key] = arr;
    
    scrollView = (NSScrollView *)[delegate makeGridWithName:nsstring(name) headers:arr];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)scrollView;
}

static NSTableView *gridTableViewForKey(AppDelegate *delegate, NSString *key) {
  id view = delegate.controlsByName[key];
  if ([view isKindOfClass:[NSScrollView class]]) {
    NSScrollView *scroll = (NSScrollView *)view;
    if ([scroll.documentView isKindOfClass:[NSTableView class]]) {
      return (NSTableView *)scroll.documentView;
    }
  }
  return nil;
}

void window_grid_add_row(main__WindowInfo *info, const char *name, const char **values, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    if (!delegate.gridItemsByName) {
      delegate.gridItemsByName = [NSMutableDictionary dictionary];
    }
    NSMutableArray *rows = delegate.gridItemsByName[key];
    if (!rows) {
      rows = [NSMutableArray array];
      delegate.gridItemsByName[key] = rows;
    }
    
    NSMutableArray *row = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
      [row addObject:nsstring(values[i])];
    }
    [rows addObject:row];
    
    NSTableView *tv = gridTableViewForKey(delegate, key);
    [tv reloadData];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_grid_delete_row(main__WindowInfo *info, const char *name, int row_idx) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    NSMutableArray *rows = delegate.gridItemsByName[key];
    if (rows && row_idx >= 0 && row_idx < rows.count) {
      [rows removeObjectAtIndex:row_idx];
      NSTableView *tv = gridTableViewForKey(delegate, key);
      [tv reloadData];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_grid_add_column(main__WindowInfo *info, const char *name, const char *header) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSString *head = nsstring(header);
  void (^runBlock)(void) = ^{
    NSMutableArray *headers = delegate.gridHeadersByName[key];
    if (!headers) {
      headers = [NSMutableArray array];
      delegate.gridHeadersByName[key] = headers;
    }
    [headers addObject:head];
    
    NSTableView *tv = gridTableViewForKey(delegate, key);
    if (tv) {
      NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:[NSString stringWithFormat:@"Col_%lu", (unsigned long)(headers.count - 1)]];
      [column setTitle:head];
      [column setWidth:100.0];
      [column setEditable:YES];
      [column setResizingMask:NSTableColumnAutoresizingMask];
      [tv addTableColumn:column];
      [column release];
      
      NSMutableArray *rows = delegate.gridItemsByName[key];
      for (NSUInteger i = 0; i < rows.count; i++) {
        NSMutableArray *cols = [rows[i] mutableCopy];
        [cols addObject:@""];
        rows[i] = cols;
        [cols release];
      }
      
      [tv reloadData];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_grid_delete_column(main__WindowInfo *info, const char *name, int col_idx) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    NSMutableArray *headers = delegate.gridHeadersByName[key];
    if (headers && col_idx >= 0 && col_idx < headers.count) {
      [headers removeObjectAtIndex:col_idx];
      
      NSTableView *tv = gridTableViewForKey(delegate, key);
      if (tv) {
        NSArray *cols = [tv.tableColumns copy];
        if (col_idx < cols.count) {
          [tv removeTableColumn:cols[col_idx]];
        }
        [cols release];
        
        NSArray *updatedCols = tv.tableColumns;
        for (NSUInteger i = 0; i < updatedCols.count; i++) {
          [(NSTableColumn *)updatedCols[i] setIdentifier:[NSString stringWithFormat:@"Col_%lu", (unsigned long)i]];
        }
        
        NSMutableArray *rows = delegate.gridItemsByName[key];
        for (NSUInteger i = 0; i < rows.count; i++) {
          NSMutableArray *colsArray = [rows[i] mutableCopy];
          if (col_idx < colsArray.count) {
            [colsArray removeObjectAtIndex:col_idx];
          }
          rows[i] = colsArray;
          [colsArray release];
        }
        
        [tv reloadData];
      }
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_grid_set_cell(main__WindowInfo *info, const char *name, int row, int col, const char *value) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSString *val = nsstring(value);
  void (^runBlock)(void) = ^{
    NSMutableArray *rows = delegate.gridItemsByName[key];
    if (rows && row >= 0 && row < rows.count) {
      NSMutableArray *cols = [rows[row] mutableCopy];
      if (col >= 0 && col < cols.count) {
        cols[col] = val;
        rows[row] = cols;
        
        NSTableView *tv = gridTableViewForKey(delegate, key);
        [tv reloadData];
      }
      [cols release];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

const char *window_grid_get_cell(main__WindowInfo *info, const char *name, int row, int col) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  __block NSString *result = @"";
  void (^runBlock)(void) = ^{
    NSArray *rows = delegate.gridItemsByName[key];
    if (rows && row >= 0 && row < rows.count) {
      NSArray *cols = rows[row];
      if (col >= 0 && col < cols.count) {
        result = [cols[col] retain];
      }
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return [result autorelease].UTF8String;
}

int window_grid_get_selected_row(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  __block int row = -1;
  void (^runBlock)(void) = ^{
    NSString *selectedCoord = delegate.gridSelectionByName[key];
    if (selectedCoord) {
      NSArray *parts = [selectedCoord componentsSeparatedByString:@"_"];
      if (parts.count >= 1) {
        row = [parts[0] intValue];
      }
    } else {
      NSTableView *tv = gridTableViewForKey(delegate, key);
      if (tv) {
        row = (int)tv.selectedRow;
      }
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return row;
}

int window_grid_get_selected_column(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  __block int col = -1;
  void (^runBlock)(void) = ^{
    NSString *selectedCoord = delegate.gridSelectionByName[key];
    if (selectedCoord) {
      NSArray *parts = [selectedCoord componentsSeparatedByString:@"_"];
      if (parts.count >= 2) {
        col = [parts[1] intValue];
      }
    } else {
      NSTableView *tv = gridTableViewForKey(delegate, key);
      if (tv) {
        col = (int)tv.selectedColumn;
      }
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return col;
}

void window_grid_set_selected_column(main__WindowInfo *info, const char *name, int col_idx) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    NSTableView *tv = gridTableViewForKey(delegate, key);
    if (!delegate.gridSelectionByName) {
      delegate.gridSelectionByName = [NSMutableDictionary dictionary];
    }
    if (tv) {
      NSInteger resolvedCol = col_idx;
      if (resolvedCol >= 0 && resolvedCol < tv.tableColumns.count) {
        delegate.gridSelectionByName[key] = [NSString stringWithFormat:@"-1_%ld", (long)resolvedCol];
      } else {
        [delegate.gridSelectionByName removeObjectForKey:key];
      }
      [tv reloadData];
    } else if (col_idx >= 0) {
      delegate.gridSelectionByName[key] = [NSString stringWithFormat:@"-1_%d", col_idx];
    } else {
      [delegate.gridSelectionByName removeObjectForKey:key];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_grid_set_selected_cell(main__WindowInfo *info, const char *name, int row_idx, int col_idx) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    NSTableView *tv = gridTableViewForKey(delegate, key);
    if (!delegate.gridSelectionByName) {
      delegate.gridSelectionByName = [NSMutableDictionary dictionary];
    }
    if (tv) {
      NSInteger resolvedRow = row_idx;
      NSInteger resolvedCol = col_idx;
      if (resolvedRow >= 0 && resolvedRow < tv.numberOfRows) {
        delegate.gridSelectionByName[key] = [NSString stringWithFormat:@"%ld_%ld", (long)resolvedRow, (long)resolvedCol];
      } else {
        [delegate.gridSelectionByName removeObjectForKey:key];
      }
      [tv reloadData];
    } else if (row_idx >= 0 || col_idx >= 0) {
      delegate.gridSelectionByName[key] = [NSString stringWithFormat:@"%d_%d", row_idx, col_idx];
    } else {
      [delegate.gridSelectionByName removeObjectForKey:key];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

int window_grid_get_column_editable(main__WindowInfo *info, const char *name, int col_idx) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  __block int editable = 1;
  void (^runBlock)(void) = ^{
    NSMutableSet *cols = delegate.gridReadOnlyColsByName[key];
    editable = (cols && [cols containsObject:@(col_idx)]) ? 0 : 1;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return editable;
}

int window_grid_get_row_editable(main__WindowInfo *info, const char *name, int row_idx) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  __block int editable = 1;
  void (^runBlock)(void) = ^{
    NSMutableSet *rows = delegate.gridReadOnlyRowsByName[key];
    editable = (rows && [rows containsObject:@(row_idx)]) ? 0 : 1;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return editable;
}

int window_grid_get_cell_editable(main__WindowInfo *info, const char *name, int row, int col) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  __block int editable = 1;
  void (^runBlock)(void) = ^{
    NSMutableSet *cells = delegate.gridReadOnlyCellsByName[key];
    NSString *coord = [NSString stringWithFormat:@"%d_%d", row, col];
    editable = (cells && [cells containsObject:coord]) ? 0 : 1;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return editable;
}

int window_grid_get_column_enabled(main__WindowInfo *info, const char *name, int col_idx) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  __block int enabled = 1;
  void (^runBlock)(void) = ^{
    NSMutableSet *cols = delegate.gridDisabledColsByName[key];
    enabled = (cols && [cols containsObject:@(col_idx)]) ? 0 : 1;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return enabled;
}

int window_grid_get_row_enabled(main__WindowInfo *info, const char *name, int row_idx) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  __block int enabled = 1;
  void (^runBlock)(void) = ^{
    NSMutableSet *rows = delegate.gridDisabledRowsByName[key];
    enabled = (rows && [rows containsObject:@(row_idx)]) ? 0 : 1;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return enabled;
}

int window_grid_get_cell_enabled(main__WindowInfo *info, const char *name, int row, int col) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  __block int enabled = 1;
  void (^runBlock)(void) = ^{
    NSMutableSet *cells = delegate.gridDisabledCellsByName[key];
    NSString *coord = [NSString stringWithFormat:@"%d_%d", row, col];
    enabled = (cells && [cells containsObject:coord]) ? 0 : 1;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return enabled;
}

const char *window_grid_get_filter(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  __block NSString *result = @"";
  void (^runBlock)(void) = ^{
    if (delegate.gridFiltersByName) {
      result = delegate.gridFiltersByName[key] ?: @"";
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return [result autorelease].UTF8String;
}

int window_grid_get_row_count(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  __block int count = 0;
  void (^runBlock)(void) = ^{
    NSArray *rows = delegate.gridItemsByName[key];
    count = (int)rows.count;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return count;
}

int window_grid_get_column_count(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  __block int count = 0;
  void (^runBlock)(void) = ^{
    NSArray *headers = delegate.gridHeadersByName[key];
    count = (int)headers.count;
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return count;
}

int window_grid_get_row_values(main__WindowInfo *info, const char *name, int row_idx, const char **values, int capacity) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  __block int count = 0;
  __block NSMutableArray *resultValues = [NSMutableArray array];
  void (^runBlock)(void) = ^{
    NSArray *rows = delegate.gridItemsByName[key];
    if (rows && row_idx >= 0 && row_idx < rows.count) {
      NSArray *cols = rows[row_idx];
      for (NSInteger i = 0; i < cols.count; i++) {
        if (capacity > 0 && i >= capacity) {
          break;
        }
        [resultValues addObject:[cols[i] description]];
      }
      count = (int)cols.count;
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }

  for (int i = 0; i < count && i < capacity; i++) {
    values[i] = [resultValues[i] UTF8String];
  }
  return count;
}

void window_grid_set_column_type(main__WindowInfo *info, const char *name, int col_idx, const char *col_type) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSString *type = nsstring(col_type);
  void (^runBlock)(void) = ^{
    if (!delegate.gridColumnTypesByName) {
      delegate.gridColumnTypesByName = [NSMutableDictionary dictionary];
    }
    NSMutableArray *types = delegate.gridColumnTypesByName[key];
    if (!types) {
      types = [NSMutableArray array];
      delegate.gridColumnTypesByName[key] = types;
    }
    
    while (types.count <= col_idx) {
      [types addObject:@"text"];
    }
    types[col_idx] = type;
    
    NSTableView *tv = gridTableViewForKey(delegate, key);
    [tv reloadData];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_grid_set_column_width(main__WindowInfo *info, const char *name, int col_idx, int width) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    NSTableView *tv = gridTableViewForKey(delegate, key);
    if (tv && col_idx >= 0 && col_idx < tv.tableColumns.count) {
      NSTableColumn *column = tv.tableColumns[col_idx];
      [column setWidth:(CGFloat)width];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_grid_set_row_height(main__WindowInfo *info, const char *name, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    if (!delegate.gridRowHeightsByName) {
      delegate.gridRowHeightsByName = [NSMutableDictionary dictionary];
    }
    delegate.gridRowHeightsByName[key] = @(height);

    NSTableView *tv = gridTableViewForKey(delegate, key);
    if (tv) {
      [tv setRowHeight:(CGFloat)height];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_grid_sort_by_column(main__WindowInfo *info, const char *name, int col_idx, int ascending) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    if (!delegate.gridSortDescriptorsByName) {
      delegate.gridSortDescriptorsByName = [NSMutableDictionary dictionary];
    }

    NSArray *updatedDescriptors = @[@{ @"column": @(col_idx), @"ascending": @(ascending == 1) }];
    delegate.gridSortDescriptorsByName[key] = updatedDescriptors;

    NSTableView *tv = gridTableViewForKey(delegate, key);
    if (tv) {
      [delegate applyGridSortForTableView:tv descriptors:updatedDescriptors];
      [delegate refreshGridHeaderTitlesForTableView:tv];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_grid_set_filter(main__WindowInfo *info, const char *name, const char *query) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  NSString *filter = nsstring(query);
  void (^runBlock)(void) = ^{
    if (!delegate.gridFiltersByName) {
      delegate.gridFiltersByName = [NSMutableDictionary dictionary];
    }
    delegate.gridFiltersByName[key] = filter;

    NSTableView *tv = gridTableViewForKey(delegate, key);
    if (tv) {
      [tv reloadData];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_grid_clear_filter(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    if (delegate.gridFiltersByName) {
      [delegate.gridFiltersByName removeObjectForKey:key];
    }

    NSTableView *tv = gridTableViewForKey(delegate, key);
    if (tv) {
      [tv reloadData];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_grid_autosize_columns(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    NSTableView *tv = gridTableViewForKey(delegate, key);
    if (tv) {
      [tv sizeToFit];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_grid_set_selected_row(main__WindowInfo *info, const char *name, int row_idx) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    if (!delegate.gridSelectionByName) {
      delegate.gridSelectionByName = [NSMutableDictionary dictionary];
    }
    NSTableView *tv = gridTableViewForKey(delegate, key);
    if (tv) {
      [tv reloadData];
      NSArray *visibleIndexes = delegate.gridVisibleRowIndexesByName[key];
      NSInteger resolvedRow = row_idx;
      if (visibleIndexes && row_idx >= 0 && row_idx < visibleIndexes.count) {
        resolvedRow = [visibleIndexes[row_idx] integerValue];
      }
      if (resolvedRow >= 0 && resolvedRow < tv.numberOfRows) {
        [tv selectRowIndexes:[NSIndexSet indexSetWithIndex:resolvedRow] byExtendingSelection:NO];
        delegate.gridSelectionByName[key] = [NSString stringWithFormat:@"%ld_0", (long)resolvedRow];
      } else {
        [tv selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
        [delegate.gridSelectionByName removeObjectForKey:key];
      }
    } else {
      if (row_idx >= 0) {
        delegate.gridSelectionByName[key] = [NSString stringWithFormat:@"%d_0", row_idx];
      } else {
        [delegate.gridSelectionByName removeObjectForKey:key];
      }
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_grid_clear(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    NSMutableArray *rows = delegate.gridItemsByName[key];
    if (rows) {
      [rows removeAllObjects];
      NSTableView *tv = gridTableViewForKey(delegate, key);
      [tv reloadData];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_grid_set_column_editable(main__WindowInfo *info, const char *name, int col_idx, int editable) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    if (!delegate.gridReadOnlyColsByName) {
      delegate.gridReadOnlyColsByName = [NSMutableDictionary dictionary];
    }
    NSMutableSet *cols = delegate.gridReadOnlyColsByName[key];
    if (!cols) {
      cols = [NSMutableSet set];
      delegate.gridReadOnlyColsByName[key] = cols;
    }
    
    if (editable) {
      [cols removeObject:@(col_idx)];
    } else {
      [cols addObject:@(col_idx)];
    }
    
    NSTableView *tv = gridTableViewForKey(delegate, key);
    [tv reloadData];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_grid_set_row_editable(main__WindowInfo *info, const char *name, int row_idx, int editable) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    if (!delegate.gridReadOnlyRowsByName) {
      delegate.gridReadOnlyRowsByName = [NSMutableDictionary dictionary];
    }
    NSMutableSet *rows = delegate.gridReadOnlyRowsByName[key];
    if (!rows) {
      rows = [NSMutableSet set];
      delegate.gridReadOnlyRowsByName[key] = rows;
    }
    
    if (editable) {
      [rows removeObject:@(row_idx)];
    } else {
      [rows addObject:@(row_idx)];
    }
    
    NSTableView *tv = gridTableViewForKey(delegate, key);
    [tv reloadData];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_grid_set_cell_editable(main__WindowInfo *info, const char *name, int row, int col, int editable) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    if (!delegate.gridReadOnlyCellsByName) {
      delegate.gridReadOnlyCellsByName = [NSMutableDictionary dictionary];
    }
    NSMutableSet *cells = delegate.gridReadOnlyCellsByName[key];
    if (!cells) {
      cells = [NSMutableSet set];
      delegate.gridReadOnlyCellsByName[key] = cells;
    }
    
    NSString *cellCoord = [NSString stringWithFormat:@"%d_%d", row, col];
    if (editable) {
      [cells removeObject:cellCoord];
    } else {
      [cells addObject:cellCoord];
    }
    
    NSTableView *tv = gridTableViewForKey(delegate, key);
    [tv reloadData];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_grid_set_column_enabled(main__WindowInfo *info, const char *name, int col_idx, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    if (!delegate.gridDisabledColsByName) {
      delegate.gridDisabledColsByName = [NSMutableDictionary dictionary];
    }
    NSMutableSet *cols = delegate.gridDisabledColsByName[key];
    if (!cols) {
      cols = [NSMutableSet set];
      delegate.gridDisabledColsByName[key] = cols;
    }
    
    if (enabled) {
      [cols removeObject:@(col_idx)];
    } else {
      [cols addObject:@(col_idx)];
    }
    
    NSTableView *tv = gridTableViewForKey(delegate, key);
    [tv reloadData];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_grid_set_row_enabled(main__WindowInfo *info, const char *name, int row_idx, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    if (!delegate.gridDisabledRowsByName) {
      delegate.gridDisabledRowsByName = [NSMutableDictionary dictionary];
    }
    NSMutableSet *rows = delegate.gridDisabledRowsByName[key];
    if (!rows) {
      rows = [NSMutableSet set];
      delegate.gridDisabledRowsByName[key] = rows;
    }
    
    if (enabled) {
      [rows removeObject:@(row_idx)];
    } else {
      [rows addObject:@(row_idx)];
    }
    
    NSTableView *tv = gridTableViewForKey(delegate, key);
    [tv reloadData];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_grid_set_cell_enabled(main__WindowInfo *info, const char *name, int row, int col, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  void (^runBlock)(void) = ^{
    if (!delegate.gridDisabledCellsByName) {
      delegate.gridDisabledCellsByName = [NSMutableDictionary dictionary];
    }
    NSMutableSet *cells = delegate.gridDisabledCellsByName[key];
    if (!cells) {
      cells = [NSMutableSet set];
      delegate.gridDisabledCellsByName[key] = cells;
    }
    
    NSString *cellCoord = [NSString stringWithFormat:@"%d_%d", row, col];
    if (enabled) {
      [cells removeObject:cellCoord];
    } else {
      [cells addObject:cellCoord];
    }
    
    NSTableView *tv = gridTableViewForKey(delegate, key);
    [tv reloadData];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

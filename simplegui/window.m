#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
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

extern BOOL vlang_dispatch_event(void *win_ptr, const char *name, const char *event, const char *value);

@implementation FlippedStackView
- (BOOL)isFlipped {
  return YES;
}
@end

@interface GridContainerView : NSView
@property (nonatomic, assign) NSInteger columns;
@property (nonatomic, assign) CGFloat spacing;
@property (nonatomic, strong) NSStackView *verticalStack;
@property (nonatomic, strong) NSMutableArray<NSStackView *> *rowStacks;
@property (nonatomic, assign) NSInteger currentChildCount;
- (instancetype)initWithColumns:(NSInteger)cols spacing:(CGFloat)spc;
- (void)addControlView:(NSView *)view;
@end

@implementation GridContainerView
- (instancetype)initWithColumns:(NSInteger)cols spacing:(CGFloat)spc {
  self = [super initWithFrame:NSZeroRect];
  if (self) {
    _columns = (cols > 0) ? cols : 1;
    _spacing = spc;
    _currentChildCount = 0;
    _rowStacks = [NSMutableArray array];
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setWantsLayer:YES];
    
    _verticalStack = [[NSStackView alloc] init];
    [_verticalStack setOrientation:NSUserInterfaceLayoutOrientationVertical];
    [_verticalStack setAlignment:NSLayoutAttributeLeading];
    [_verticalStack setDistribution:NSStackViewDistributionFill];
    [_verticalStack setSpacing:spc];
    [_verticalStack setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_verticalStack setWantsLayer:YES];
    
    [self addSubview:_verticalStack];
    [NSLayoutConstraint activateConstraints:@[
      [_verticalStack.topAnchor constraintEqualToAnchor:self.topAnchor],
      [_verticalStack.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
      [_verticalStack.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
      [_verticalStack.trailingAnchor constraintEqualToAnchor:self.trailingAnchor]
    ]];
  }
  return self;
}

- (void)addControlView:(NSView *)view {
  NSStackView *currentRowStack = nil;
  if (self.currentChildCount % self.columns == 0) {
    currentRowStack = [[NSStackView alloc] init];
    [currentRowStack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
    [currentRowStack setAlignment:NSLayoutAttributeCenterY];
    [currentRowStack setDistribution:NSStackViewDistributionFillEqually];
    [currentRowStack setSpacing:self.spacing];
    [currentRowStack setTranslatesAutoresizingMaskIntoConstraints:NO];
    [currentRowStack setWantsLayer:YES];
    [self.verticalStack addArrangedSubview:currentRowStack];
    [self.rowStacks addObject:currentRowStack];
    [currentRowStack.widthAnchor constraintEqualToAnchor:self.verticalStack.widthAnchor].active = YES;
  } else {
    currentRowStack = [self.rowStacks lastObject];
  }
  [currentRowStack addArrangedSubview:view];
  self.currentChildCount++;
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

@interface SparklineView : NSView
@property (nonatomic, retain) NSArray<NSNumber *> *values;
@property (nonatomic, retain) NSColor *lineColor;
@property (nonatomic, retain) NSColor *fillColor;
@end

@interface AudioWaveformView : NSView
@property (nonatomic, retain) NSArray<NSNumber *> *amplitudes;
@property (nonatomic, retain) NSColor *barColor;
@property (nonatomic, retain) NSColor *activeBarColor;
@property (nonatomic, assign) double progress;
@end

@interface StarBarView : NSView
@property (nonatomic, assign) double percentage;
@property (nonatomic, assign) BOOL isSelected;
@end

@interface RadialGaugeView : NSView
@property (nonatomic, assign) double value;
@property (nonatomic, assign) double minVal;
@property (nonatomic, assign) double maxVal;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *unit;
@end

@interface FlippedView : NSView
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
@property (nonatomic, strong) NSMutableArray<NSView *> *containerStack;

- (void)beginGridWithName:(NSString *)name columns:(int)columns spacing:(int)spacing;
- (void)endGrid;
- (void)beginFlexBoxWithName:(NSString *)name direction:(NSString *)direction justify:(NSString *)justify align:(NSString *)align;
- (void)endFlexBox;
- (void)setControlAlignment:(NSString *)alignment forName:(NSString *)name;
- (void)setControlExpandFill:(BOOL)expand forName:(NSString *)name;

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
- (NSView *)makeStatCardWithName:(NSString *)name title:(NSString *)title value:(NSString *)value trend:(NSString *)trend trendStyle:(NSString *)trendStyle;
- (NSView *)makeBannerWithName:(NSString *)name text:(NSString *)text style:(NSString *)style;
- (NSView *)makeSectionHeaderWithName:(NSString *)name title:(NSString *)title subtitle:(NSString *)subtitle;
- (NSView *)makeVerticalSliderWithName:(NSString *)name value:(int)value minValue:(int)minValue maxValue:(int)maxValue height:(int)height;
- (NSView *)makeChipGroupWithName:(NSString *)name chips:(NSArray<NSString *> *)chips selected:(NSString *)selected;
- (NSView *)makeConsoleWithName:(NSString *)name height:(int)height;
- (NSView *)makeChartViewWithName:(NSString *)name chartType:(NSString *)chartType height:(int)height;
- (NSView *)makeShortcutRecorderWithName:(NSString *)name;
- (NSView *)makeCircularProgressWithName:(NSString *)name value:(double)value minVal:(double)minVal maxVal:(double)maxVal;
@property (nonatomic, strong) NSMutableDictionary *trayIconsByName;

- (NSView *)makeBreadcrumbsWithName:(NSString *)name segments:(NSArray<NSString *> *)segments;
- (void)handleBreadcrumbClicked:(id)sender;
- (NSView *)makePropertyGridWithName:(NSString *)name keys:(NSArray<NSString *> *)keys values:(NSArray<NSString *> *)values;
- (NSView *)makeColorGridWithName:(NSString *)name colors:(NSArray<NSString *> *)colors;
- (NSView *)makeStatusIndicatorWithName:(NSString *)name label:(NSString *)label status:(NSString *)status;
- (NSView *)makeMetricMeterWithName:(NSString *)name title:(NSString *)title value:(double)val minVal:(double)minVal maxVal:(double)maxVal unit:(NSString *)unit;
- (NSView *)makeAvatarCardWithName:(NSString *)name title:(NSString *)title subtitle:(NSString *)subtitle status:(NSString *)status;
- (NSView *)makeTimePickerWithName:(NSString *)name time:(NSString *)timeString;
- (void)makeTrayIconWithName:(NSString *)name symbol:(NSString *)symbolName title:(NSString *)title;
- (NSView *)makeCollapsibleSectionWithName:(NSString *)name title:(NSString *)title expanded:(BOOL)expanded;
- (NSView *)makeCodeEditorWithName:(NSString *)name code:(NSString *)code height:(int)height;
- (NSView *)makeTimelineViewWithName:(NSString *)name height:(int)height;
- (void)addTimelineEntryToName:(NSString *)name time:(NSString *)timeStr title:(NSString *)title detail:(NSString *)detail style:(NSString *)style;
- (void)clearTimelineName:(NSString *)name;
- (void)addToolbarItemWithIdentifier:(NSString *)identifier label:(NSString *)label symbol:(NSString *)symbol;

- (NSView *)makeRatingWithName:(NSString *)name value:(int)value maxStars:(int)maxStars;
- (void)setRatingValue:(int)value forName:(NSString *)name;
- (int)ratingValueForName:(NSString *)name;
- (NSView *)makeRangeSliderWithName:(NSString *)name min:(int)minVal max:(int)maxVal low:(int)lowVal high:(int)highVal;
- (void)setRangeSliderLow:(int)lowVal high:(int)highVal forName:(NSString *)name;
- (int)rangeSliderLowForName:(NSString *)name;
- (int)rangeSliderHighForName:(NSString *)name;
- (NSView *)makeSplitButtonWithName:(NSString *)name title:(NSString *)title menuItems:(NSArray<NSString *> *)menuItems;
- (NSView *)makeTagCloudWithName:(NSString *)name tags:(NSArray<NSString *> *)tags;
- (void)setTagCloudTags:(NSArray<NSString *> *)tags forName:(NSString *)name;
- (NSView *)makeWizardStepperWithName:(NSString *)name steps:(NSArray<NSString *> *)steps currentStep:(int)currentStep;
- (void)setWizardStepperStep:(int)step forName:(NSString *)name;

- (NSView *)makeGaugeWithName:(NSString *)name title:(NSString *)title value:(int)val minVal:(int)minVal maxVal:(int)maxVal unit:(NSString *)unit;
- (void)setGaugeValue:(int)val forName:(NSString *)name;
- (int)gaugeValueForName:(NSString *)name;
- (NSView *)makePaginationWithName:(NSString *)name totalPages:(int)totalPages currentPage:(int)currentPage;
- (void)setPaginationPage:(int)page totalPages:(int)totalPages forName:(NSString *)name;
- (int)paginationPageForName:(NSString *)name;
- (NSView *)makeActivityFeedWithName:(NSString *)name height:(int)height;
- (void)addActivityFeedItemToName:(NSString *)name timestamp:(NSString *)timestamp message:(NSString *)message level:(NSString *)level;
- (void)clearActivityFeedName:(NSString *)name;
- (NSView *)makeMarkdownViewWithName:(NSString *)name markdownText:(NSString *)markdownText height:(int)height;
- (void)setMarkdownViewText:(NSString *)markdownText forName:(NSString *)name;
- (NSString *)markdownViewTextForName:(NSString *)name;
- (NSView *)makeSparklineWithName:(NSString *)name values:(NSArray<NSNumber *> *)values height:(int)height;
- (void)setSparklineValues:(NSArray<NSNumber *> *)values forName:(NSString *)name;
- (NSView *)makePinCodeWithName:(NSString *)name digits:(int)digits;
- (void)setPinCodeValue:(NSString *)code forName:(NSString *)name;
- (NSString *)pinCodeValueForName:(NSString *)name;
- (NSView *)makeColorPaletteWithName:(NSString *)name colors:(NSArray<NSString *> *)colors selected:(NSString *)selected;
- (void)setColorPaletteSelected:(NSString *)hex forName:(NSString *)name;
- (NSString *)colorPaletteSelectedForName:(NSString *)name;

- (NSView *)makeTimelineWithName:(NSString *)name height:(int)height;
- (void)addTimelineItemToName:(NSString *)name title:(NSString *)title subtitle:(NSString *)subtitle timeStr:(NSString *)timeStr status:(NSString *)status;

- (NSView *)makeMetricCardWithName:(NSString *)name title:(NSString *)title value:(NSString *)value changeBadge:(NSString *)changeBadge subtitle:(NSString *)subtitle;

- (void)setMetricCardValue:(NSString *)value changeBadge:(NSString *)changeBadge forName:(NSString *)name;

- (NSView *)makeTabPillsWithName:(NSString *)name items:(NSArray<NSString *> *)items selected:(NSString *)selected;
- (void)setTabPillsActive:(NSString *)selected forName:(NSString *)name;
- (NSString *)tabPillsActiveForName:(NSString *)name;

- (NSView *)makeTransferListWithName:(NSString *)name available:(NSArray<NSString *> *)available selected:(NSArray<NSString *> *)selected multiSelect:(BOOL)multiSelect;
- (void)handleTransferItemClicked:(id)sender;


- (NSArray<NSString *> *)transferListSelectedForName:(NSString *)name;

- (NSView *)makeAudioWaveformWithName:(NSString *)name amplitudes:(NSArray<NSNumber *> *)amplitudes height:(int)height;
- (void)setAudioWaveformAmplitudes:(NSArray<NSNumber *> *)amplitudes forName:(NSString *)name;

- (NSView *)makeRatingBreakdownWithName:(NSString *)name avgScore:(double)avgScore totalReviews:(int)totalReviews starPercentages:(NSArray<NSNumber *> *)starPercentages;
- (void)setRatingBreakdownData:(double)avgScore totalReviews:(int)totalReviews starPercentages:(NSArray<NSNumber *> *)starPercentages forName:(NSString *)name;

- (NSView *)makeCodeViewWithName:(NSString *)name lang:(NSString *)lang codeText:(NSString *)codeText height:(int)height;
- (void)setCodeViewText:(NSString *)codeText forName:(NSString *)name;
- (NSString *)codeViewTextForName:(NSString *)name;

- (NSView *)makeAlertBannerWithName:(NSString *)name title:(NSString *)title message:(NSString *)message style:(NSString *)style;
- (void)setAlertBannerValueForName:(NSString *)name title:(NSString *)title message:(NSString *)message style:(NSString *)style;

- (NSView *)makeStepTrackerWithName:(NSString *)name steps:(NSArray<NSString *> *)steps currentStep:(int)currentStep;
- (void)setStepTrackerStep:(int)step forName:(NSString *)name;
- (int)stepTrackerStepForName:(NSString *)name;

- (NSView *)makeFilterChipsWithName:(NSString *)name chips:(NSArray<NSString *> *)chips selected:(NSArray<NSString *> *)selected multiSelect:(BOOL)multiSelect;
- (void)setFilterChipsSelected:(NSArray<NSString *> *)selected forName:(NSString *)name;
- (NSString *)filterChipsSelectedForName:(NSString *)name;

- (NSView *)makeFilePickerFieldWithName:(NSString *)name initialPath:(NSString *)initialPath buttonTitle:(NSString *)buttonTitle folderOnly:(BOOL)folderOnly;
- (void)setFilePickerPath:(NSString *)path forName:(NSString *)name;
- (NSString *)filePickerPathForName:(NSString *)name;

- (NSView *)makeRadialGaugeWithName:(NSString *)name title:(NSString *)title value:(double)value minVal:(double)minVal maxVal:(double)maxVal unit:(NSString *)unit;
- (void)setRadialGaugeValue:(double)value forName:(NSString *)name;
- (double)radialGaugeValueForName:(NSString *)name;

- (NSView *)makeKeyValueCardWithName:(NSString *)name title:(NSString *)title keys:(NSArray<NSString *> *)keys values:(NSArray<NSString *> *)values;
- (void)setKeyValueCardDataForName:(NSString *)name keys:(NSArray<NSString *> *)keys values:(NSArray<NSString *> *)values;

- (NSView *)makeDiffViewWithName:(NSString *)name oldText:(NSString *)oldText newText:(NSString *)newText height:(int)height;
- (void)setDiffViewTextForName:(NSString *)name oldText:(NSString *)oldText newText:(NSString *)newText;

- (NSView *)makeJsonTreeWithName:(NSString *)name jsonStr:(NSString *)jsonStr height:(int)height;
- (void)setJsonTreeDataForName:(NSString *)name jsonStr:(NSString *)jsonStr;

- (NSView *)makeHttpRequestCardWithName:(NSString *)name method:(NSString *)method url:(NSString *)url statusCode:(int)statusCode responseTimeMs:(int)responseTimeMs;
- (void)setHttpRequestCardDataForName:(NSString *)name method:(NSString *)method url:(NSString *)url statusCode:(int)statusCode responseTimeMs:(int)responseTimeMs;

- (NSView *)makeTerminalViewWithName:(NSString *)name promptText:(NSString *)promptText height:(int)height;
- (void)appendTerminalLine:(NSString *)lineText lineType:(int)lineType forName:(NSString *)name;
- (void)clearTerminalForName:(NSString *)name;

- (NSView *)makeResourceMonitorWithName:(NSString *)name cpuPct:(int)cpuPct memPct:(int)memPct diskPct:(int)diskPct netKbps:(int)netKbps;
- (void)setResourceMonitorMetricsForName:(NSString *)name cpuPct:(int)cpuPct memPct:(int)memPct diskPct:(int)diskPct netKbps:(int)netKbps;

- (NSView *)makeEnvVarsWithName:(NSString *)name title:(NSString *)title keys:(NSArray<NSString *> *)keys values:(NSArray<NSString *> *)values;
- (void)setEnvVarsDataForName:(NSString *)name keys:(NSArray<NSString *> *)keys values:(NSArray<NSString *> *)values;

- (NSView *)makeBadgeButtonWithName:(NSString *)name title:(NSString *)title count:(int)count badgeColor:(NSString *)badgeColor;
- (void)setBadgeButtonCount:(int)count forName:(NSString *)name;

- (NSView *)makeCommandPaletteWithName:(NSString *)name placeholder:(NSString *)placeholder shortcutHint:(NSString *)shortcutHint;
- (void)setCommandPaletteText:(NSString *)text forName:(NSString *)name;

- (NSView *)makeStatusBannerWithName:(NSString *)name title:(NSString *)title message:(NSString *)message styleType:(NSString *)styleType;
- (void)setStatusBannerTextForName:(NSString *)name title:(NSString *)title message:(NSString *)message styleType:(NSString *)styleType;

- (NSView *)makePillToggleWithName:(NSString *)name options:(NSArray<NSString *> *)options selectedIndex:(int)selectedIndex;
- (void)setPillToggleSelected:(int)selectedIndex forName:(NSString *)name;

- (NSView *)makeColorSwatchPanelWithName:(NSString *)name hexColors:(NSArray<NSString *> *)hexColors selectedColor:(NSString *)selectedColor;
- (void)setColorSwatchSelected:(NSString *)hexColor forName:(NSString *)name;

- (NSView *)makeHotkeyBadgeWithName:(NSString *)name shortcutStr:(NSString *)shortcutStr description:(NSString *)description;
- (void)setHotkeyBadgeShortcutForName:(NSString *)name shortcutStr:(NSString *)shortcutStr description:(NSString *)description;

- (NSView *)makeQuickActionBarWithName:(NSString *)name labels:(NSArray<NSString *> *)labels symbols:(NSArray<NSString *> *)symbols;
- (void)setQuickActionEnabled:(BOOL)enabled index:(int)index forName:(NSString *)name;

- (NSView *)makeAccordionGroupWithName:(NSString *)name sectionTitles:(NSArray<NSString *> *)sectionTitles expandedIndex:(int)expandedIndex;
- (void)setAccordionExpanded:(BOOL)expanded index:(int)index forName:(NSString *)name;

- (NSView *)makeSegmentDistributionBarWithName:(NSString *)name labels:(NSArray<NSString *> *)labels values:(NSArray<NSNumber *> *)values hexColors:(NSArray<NSString *> *)hexColors height:(int)height;
- (void)setSegmentDistributionValues:(NSArray<NSNumber *> *)values forName:(NSString *)name;

- (NSView *)makeTagInputFieldWithName:(NSString *)name tags:(NSArray<NSString *> *)tags;
- (void)setTagInputTags:(NSArray<NSString *> *)tags forName:(NSString *)name;
- (NSString *)getTagInputTagsForName:(NSString *)name;

- (NSView *)makeStatusDockWithName:(NSString *)name statusText:(NSString *)statusText dotColor:(NSString *)dotColor countText:(NSString *)countText;
- (void)setStatusDockInfoForName:(NSString *)name statusText:(NSString *)statusText dotColor:(NSString *)dotColor countText:(NSString *)countText;

- (NSView *)makeInfoCalloutWithName:(NSString *)name title:(NSString *)title message:(NSString *)message styleType:(NSString *)styleType buttonText:(NSString *)buttonText;
- (void)setInfoCalloutTextForName:(NSString *)name title:(NSString *)title message:(NSString *)message;

- (void)setWindowVibrancy:(NSString *)materialStr;
- (void)setWindowCornerRadius:(double)radius;
- (void)setWindowBackgroundBlur:(BOOL)enabled;
- (void)flashWindowFrame:(BOOL)critical;
- (void)centerWindowOnActiveScreen;
- (void)setWindowLevelType:(NSString *)levelType;






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
- (NSView *)makeDateTimePickerWithName:(NSString *)name dateTime:(NSString *)dateTimeString;
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

@implementation SparklineView
- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    _values = [[NSMutableArray alloc] init];
    _lineColor = [NSColor colorWithRed:0.2 green:0.55 blue:0.95 alpha:1.0];
    _fillColor = [NSColor colorWithRed:0.2 green:0.55 blue:0.95 alpha:0.15];
  }
  return self;
}

- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
  if (!_values || _values.count < 2) return;

  NSRect bounds = [self bounds];
  CGFloat w = bounds.size.width;
  CGFloat h = bounds.size.height;
  CGFloat padding = 4.0;
  CGFloat drawW = w - padding * 2.0;
  CGFloat drawH = h - padding * 2.0;

  double minVal = [_values[0] doubleValue];
  double maxVal = minVal;
  for (NSNumber *num in _values) {
    double v = [num doubleValue];
    if (v < minVal) minVal = v;
    if (v > maxVal) maxVal = v;
  }
  if (maxVal == minVal) { maxVal = minVal + 1.0; }

  NSBezierPath *path = [NSBezierPath bezierPath];
  NSBezierPath *areaPath = [NSBezierPath bezierPath];

  for (NSUInteger i = 0; i < _values.count; i++) {
    double v = [_values[i] doubleValue];
    CGFloat x = padding + (drawW * i / (CGFloat)(_values.count - 1));
    CGFloat y = padding + (drawH * (v - minVal) / (maxVal - minVal));

    if (i == 0) {
      [path moveToPoint:NSMakePoint(x, y)];
      [areaPath moveToPoint:NSMakePoint(x, padding)];
      [areaPath lineToPoint:NSMakePoint(x, y)];
    } else {
      [path lineToPoint:NSMakePoint(x, y)];
      [areaPath lineToPoint:NSMakePoint(x, y)];
    }
    if (i == _values.count - 1) {
      [areaPath lineToPoint:NSMakePoint(x, padding)];
      [areaPath closePath];
    }
  }

  [_fillColor setFill];
  [areaPath fill];

  [_lineColor setStroke];
  [path setLineWidth:2.0];
  [path stroke];
}
@end

@implementation RadialGaugeView
- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    _value = 50.0;
    _minVal = 0.0;
    _maxVal = 100.0;
    _title = [@"Gauge" retain];
    _unit = [@"%" retain];
  }
  return self;
}

- (void)dealloc {
  [_title release];
  [_unit release];
  [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
  NSRect bounds = [self bounds];
  CGFloat w = bounds.size.width;
  CGFloat h = bounds.size.height;

  NSPoint center = NSMakePoint(w / 2.0, h / 2.0 - 5.0);
  CGFloat radius = MIN(w / 2.0 - 12.0, h / 2.0 - 12.0);
  if (radius < 10.0) return;

  // Background Arc
  NSBezierPath *bgPath = [NSBezierPath bezierPath];
  [bgPath appendBezierPathWithArcWithCenter:center radius:radius startAngle:180.0 endAngle:0.0 clockwise:YES];
  [bgPath setLineWidth:8.0];
  [[NSColor colorWithRed:0.2 green:0.25 blue:0.35 alpha:0.4] setStroke];
  [bgPath stroke];

  // Value Arc
  double pct = MAX(0.0, MIN(1.0, (_value - _minVal) / (_maxVal - _minVal > 0 ? _maxVal - _minVal : 1.0)));
  CGFloat endAngle = 180.0 - (180.0 * pct);
  if (pct > 0.001) {
    NSBezierPath *valPath = [NSBezierPath bezierPath];
    [valPath appendBezierPathWithArcWithCenter:center radius:radius startAngle:180.0 endAngle:endAngle clockwise:YES];
    [valPath setLineWidth:8.0];

    NSColor *gaugeColor = (pct > 0.8) ? [NSColor systemRedColor] : ((pct > 0.5) ? [NSColor systemOrangeColor] : [NSColor systemBlueColor]);
    [gaugeColor setStroke];
    [valPath stroke];
  }

  // Draw Value Text in center
  NSString *valStr = [NSString stringWithFormat:@"%.1f %@", _value, _unit ? _unit : @""];
  NSDictionary *valAttrs = @{
    NSFontAttributeName: [NSFont boldSystemFontOfSize:13.0],
    NSForegroundColorAttributeName: [NSColor whiteColor]
  };
  NSSize valSize = [valStr sizeWithAttributes:valAttrs];
  [valStr drawAtPoint:NSMakePoint(center.x - valSize.width / 2.0, center.y - 2.0) withAttributes:valAttrs];

  // Draw Title Text below
  if (_title) {
    NSDictionary *titleAttrs = @{
      NSFontAttributeName: [NSFont systemFontOfSize:10.0],
      NSForegroundColorAttributeName: [NSColor colorWithWhite:0.7 alpha:1.0]
    };
    NSSize titleSize = [_title sizeWithAttributes:titleAttrs];
    [_title drawAtPoint:NSMakePoint(center.x - titleSize.width / 2.0, center.y - 18.0) withAttributes:titleAttrs];
  }
}
@end

@implementation AudioWaveformView
- (instancetype)initWithFrame:(NSRect)frameRect {
  self = [super initWithFrame:frameRect];
  if (self) {
    _amplitudes = [[NSMutableArray alloc] init];
    _barColor = [[NSColor colorWithRed:0.2 green:0.55 blue:0.95 alpha:0.35] retain];
    _activeBarColor = [[NSColor colorWithRed:0.2 green:0.55 blue:0.95 alpha:1.0] retain];
    _progress = 0.6;
  }
  return self;
}

- (void)dealloc {
  [_amplitudes release];
  [_barColor release];
  [_activeBarColor release];
  [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
  if (!_amplitudes || _amplitudes.count == 0) return;

  NSRect bounds = [self bounds];
  CGFloat w = bounds.size.width;
  CGFloat h = bounds.size.height;
  NSUInteger count = _amplitudes.count;
  CGFloat gap = 3.0;
  CGFloat barWidth = MAX(2.0, (w - (gap * (count - 1))) / (CGFloat)count);

  for (NSUInteger i = 0; i < count; i++) {
    double amp = MAX(0.08, MIN(1.0, [_amplitudes[i] doubleValue]));
    CGFloat barH = MAX(4.0, h * amp);
    CGFloat x = i * (barWidth + gap);
    CGFloat y = (h - barH) / 2.0;
    NSRect barRect = NSMakeRect(x, y, barWidth, barH);
    NSBezierPath *barPath = [NSBezierPath bezierPathWithRoundedRect:barRect xRadius:barWidth/2.0 yRadius:barWidth/2.0];
    
    if ((CGFloat)i / (CGFloat)count <= _progress) {
      [_activeBarColor setFill];
    } else {
      [_barColor setFill];
    }
    [barPath fill];
  }
}

- (void)mouseDown:(NSEvent *)event {
  NSPoint pt = [self convertPoint:[event locationInWindow] fromView:nil];
  self.progress = MAX(0.0, MIN(1.0, pt.x / MAX(1.0, self.bounds.size.width)));
  [self setNeedsDisplay:YES];
  if (self.identifier) {
    AppDelegate *del = (AppDelegate *)[NSApp delegate];
    if (del && del.win_ptr) {
      vlang_dispatch_event(del.win_ptr, [self.identifier UTF8String], "change", [[NSString stringWithFormat:@"%.2f", self.progress] UTF8String]);
    }
  }
}

- (void)mouseDragged:(NSEvent *)event {
  [self mouseDown:event];
}
@end

@implementation StarBarView
- (void)drawRect:(NSRect)dirtyRect {
  [super drawRect:dirtyRect];
  NSRect bounds = [self bounds];

  NSBezierPath *track = [NSBezierPath bezierPathWithRoundedRect:bounds xRadius:4.0 yRadius:4.0];
  [[NSColor colorWithWhite:1.0 alpha:0.12] setFill];
  [track fill];

  CGFloat fillWidth = bounds.size.width * MAX(0.0, MIN(1.0, _percentage / 100.0));
  if (fillWidth > 0) {
    NSRect fillRect = NSMakeRect(0, 0, fillWidth, bounds.size.height);
    NSBezierPath *fillPath = [NSBezierPath bezierPathWithRoundedRect:fillRect xRadius:4.0 yRadius:4.0];
    if (_isSelected) {
      [[NSColor colorWithRed:1.0 green:0.78 blue:0.0 alpha:1.0] setFill];
    } else {
      [[NSColor colorWithRed:0.95 green:0.65 blue:0.1 alpha:0.8] setFill];
    }
    [fillPath fill];
  }
}
@end

@implementation FlippedView
- (BOOL)isFlipped {
  return YES;
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
    
    BOOL handled = vlang_dispatch_event(delegate.win_ptr, "window", "key", [keyStr UTF8String]);
    if (handled) return YES;
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

- (void)keyDown:(NSEvent *)event {
  AppDelegate *delegate = (AppDelegate *)[self delegate];
  if (delegate && delegate.win_ptr) {
    NSEventModifierFlags flags = [event modifierFlags] & NSEventModifierFlagDeviceIndependentFlagsMask;
    NSString *chars = [event charactersIgnoringModifiers];
    unsigned short keyCode = [event keyCode];
    
    NSMutableString *keyStr = [NSMutableString string];
    if (flags & NSEventModifierFlagCommand) [keyStr appendString:@"cmd+"];
    if (flags & NSEventModifierFlagControl) [keyStr appendString:@"ctrl+"];
    if (flags & NSEventModifierFlagOption) [keyStr appendString:@"opt+"];
    if (flags & NSEventModifierFlagShift) [keyStr appendString:@"shift+"];
    
    if (keyCode == 53) {
      [keyStr appendString:@"escape"];
    } else if (keyCode == 36 || keyCode == 76) {
      [keyStr appendString:@"enter"];
    } else if (keyCode == 49) {
      [keyStr appendString:@"space"];
    } else if (keyCode == 48) {
      [keyStr appendString:@"tab"];
    } else if (keyCode == 123) {
      [keyStr appendString:@"left"];
    } else if (keyCode == 124) {
      [keyStr appendString:@"right"];
    } else if (keyCode == 125) {
      [keyStr appendString:@"down"];
    } else if (keyCode == 126) {
      [keyStr appendString:@"up"];
    } else if (chars.length > 0) {
      [keyStr appendString:[chars lowercaseString]];
    }
    
    BOOL handled = vlang_dispatch_event(delegate.win_ptr, "window", "key", [keyStr UTF8String]);
    if (handled) return;
  }
  [super keyDown:event];
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
  } else if ([view isKindOfClass:[NSButton class]] && ![view isKindOfClass:[NSPopUpButton class]]) {
    NSButton *button = (NSButton *)view;
    NSFont *currFont = button.font;
    CGFloat fSize = currFont ? currFont.pointSize : 13.0;
    [button setFont:[NSFont systemFontOfSize:fSize weight:NSFontWeightMedium]];
    [button setControlSize:NSControlSizeRegular];

    // Classify by the first styling pass and remember it: styling a push
    // button sets bordered=NO, which previously made every subsequent pass
    // misclassify it as a checkbox and skip its background entirely
    // (buttons then kept stale creation-time colors).
    BOOL isCheckboxOrRadio;
    NSNumber *storedKind = objc_getAssociatedObject(button, "sg_is_checkbox_like");
    if (storedKind) {
      isCheckboxOrRadio = [storedKind boolValue];
    } else {
      isCheckboxOrRadio = ![button isBordered] && button.bezelStyle != NSBezelStyleInline;
      objc_setAssociatedObject(button, "sg_is_checkbox_like", @(isCheckboxOrRadio), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    BOOL isLinkButton = button.bezelStyle == NSBezelStyleInline;
    BOOL isDefaultButton = [button.keyEquivalent isEqualToString:@"\r"];
    
    NSColor *winBg = button.window ? button.window.backgroundColor : nil;
    BOOL isDark = YES;
    // Prefer the actual window background (set by themes) so that control
    // styling follows the applied theme even when the system appearance
    // differs (e.g. light theme on a Dark Mode Mac).
    if (winBg && ![winBg isEqual:[NSColor clearColor]] && winBg.alphaComponent > 0.01) {
      isDark = isDarkColor(winBg);
    } else {
      BOOL resolvedFromAppearance = NO;
      if (@available(macOS 10.14, *)) {
        NSAppearance *appearance = button.effectiveAppearance ?: (button.window ? button.window.appearance : nil);
        if (appearance) {
          NSAppearanceName best = [appearance bestMatchFromAppearancesWithNames:@[NSAppearanceNameDarkAqua, NSAppearanceNameAqua]];
          if ([best isEqualToString:NSAppearanceNameDarkAqua]) {
            isDark = YES;
            resolvedFromAppearance = YES;
          } else if ([best isEqualToString:NSAppearanceNameAqua]) {
            isDark = NO;
            resolvedFromAppearance = YES;
          }
        }
      }
      if (!resolvedFromAppearance) {
        isDark = isSystemDark();
      }
    }

    if (isCheckboxOrRadio && !isLinkButton) {
      [button setBezelStyle:NSBezelStyleRounded];
      [button setWantsLayer:YES];
      [button setBordered:NO];
      [button setContentTintColor:fontColor ?: modernAccentColor()];
      setButtonTitleColor(button, fontColor ?: (isDark ? [NSColor whiteColor] : [NSColor colorWithSRGBRed:0.10 green:0.10 blue:0.12 alpha:1.0]));
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
        
        if (isDefaultButton) {
          modButton.baseBackgroundColor = primaryButtonColor();
          modButton.baseTextColor = getContrastColor(primaryButtonColor());
          modButton.layer.borderWidth = 0.0;
        } else {
          if (backgroundColor) {
            modButton.baseBackgroundColor = backgroundColor;
            modButton.baseTextColor = fontColor ?: getContrastColor(backgroundColor);
            modButton.layer.borderWidth = 1.0;
            modButton.layer.borderColor = [NSColor separatorColor].CGColor;
          } else if (isDark) {
            modButton.baseBackgroundColor = [NSColor colorWithSRGBRed:0.22 green:0.22 blue:0.25 alpha:1.0];
            modButton.baseTextColor = fontColor ?: [NSColor colorWithSRGBRed:0.95 green:0.95 blue:0.97 alpha:1.0];
            modButton.layer.borderWidth = 1.0;
            modButton.layer.borderColor = [NSColor colorWithSRGBRed:0.35 green:0.35 blue:0.38 alpha:1.0].CGColor;
          } else {
            modButton.baseBackgroundColor = [NSColor colorWithSRGBRed:0.90 green:0.90 blue:0.93 alpha:1.0];
            modButton.baseTextColor = fontColor ?: [NSColor colorWithSRGBRed:0.10 green:0.10 blue:0.12 alpha:1.0];
            modButton.layer.borderWidth = 1.0;
            modButton.layer.borderColor = [NSColor colorWithSRGBRed:0.75 green:0.75 blue:0.78 alpha:1.0].CGColor;
          }
        }
        [modButton updateVisuals];
      } else {
        [button setBordered:NO];
        button.layer.cornerRadius = 8.0;
        
        if (isDefaultButton) {
          button.layer.backgroundColor = primaryButtonColor().CGColor;
          button.layer.borderWidth = 0.0;
          setButtonTitleColor(button, getContrastColor(primaryButtonColor()));
        } else {
          if (backgroundColor) {
            button.layer.backgroundColor = backgroundColor.CGColor;
            button.layer.borderWidth = 1.0;
            button.layer.borderColor = [NSColor separatorColor].CGColor;
            setButtonTitleColor(button, fontColor ?: getContrastColor(backgroundColor));
          } else if (isDark) {
            button.layer.backgroundColor = [NSColor colorWithSRGBRed:0.22 green:0.22 blue:0.25 alpha:1.0].CGColor;
            button.layer.borderWidth = 1.0;
            button.layer.borderColor = [NSColor colorWithSRGBRed:0.35 green:0.35 blue:0.38 alpha:1.0].CGColor;
            setButtonTitleColor(button, fontColor ?: [NSColor whiteColor]);
          } else {
            button.layer.backgroundColor = [NSColor colorWithSRGBRed:0.90 green:0.90 blue:0.93 alpha:1.0].CGColor;
            button.layer.borderWidth = 1.0;
            button.layer.borderColor = [NSColor colorWithSRGBRed:0.75 green:0.75 blue:0.78 alpha:1.0].CGColor;
            setButtonTitleColor(button, fontColor ?: [NSColor colorWithSRGBRed:0.10 green:0.10 blue:0.12 alpha:1.0]);
          }
        }
      }
    }
  } else if ([view isKindOfClass:[NSPopUpButton class]]) {
    NSPopUpButton *popup = (NSPopUpButton *)view;
    NSColor *winBg = popup.window ? popup.window.backgroundColor : nil;
    BOOL isDark = YES;
    if (winBg && ![winBg isEqual:[NSColor clearColor]] && winBg.alphaComponent > 0.01) {
      isDark = isDarkColor(winBg);
    } else {
      BOOL resolvedFromAppearance = NO;
      if (@available(macOS 10.14, *)) {
        NSAppearance *appearance = popup.effectiveAppearance ?: (popup.window ? popup.window.appearance : nil);
        if (appearance) {
          NSAppearanceName best = [appearance bestMatchFromAppearancesWithNames:@[NSAppearanceNameDarkAqua, NSAppearanceNameAqua]];
          if ([best isEqualToString:NSAppearanceNameDarkAqua]) {
            isDark = YES;
            resolvedFromAppearance = YES;
          } else if ([best isEqualToString:NSAppearanceNameAqua]) {
            isDark = NO;
            resolvedFromAppearance = YES;
          }
        }
      }
      if (!resolvedFromAppearance) {
        isDark = isSystemDark();
      }
    }
    [popup setBordered:NO];
    [popup setFont:[NSFont systemFontOfSize:12 weight:NSFontWeightMedium]];
    [popup setControlSize:NSControlSizeRegular];
    [popup setBezelStyle:NSBezelStyleRounded];
    [popup setWantsLayer:YES];
    popup.layer.cornerRadius = 8.0;
    popup.layer.borderWidth = 1.0;
    if (backgroundColor) {
      popup.layer.backgroundColor = backgroundColor.CGColor;
      popup.layer.borderColor = [NSColor separatorColor].CGColor;
      if ([popup respondsToSelector:@selector(setContentTintColor:)]) {
        [popup setContentTintColor:fontColor ?: getContrastColor(backgroundColor)];
      }
    } else if (isDark) {
      popup.layer.backgroundColor = [NSColor colorWithSRGBRed:0.22 green:0.22 blue:0.25 alpha:1.0].CGColor;
      popup.layer.borderColor = [NSColor colorWithSRGBRed:0.35 green:0.35 blue:0.38 alpha:1.0].CGColor;
      if ([popup respondsToSelector:@selector(setContentTintColor:)]) {
        [popup setContentTintColor:fontColor ?: [NSColor whiteColor]];
      }
    } else {
      popup.layer.backgroundColor = [NSColor colorWithSRGBRed:0.90 green:0.90 blue:0.93 alpha:1.0].CGColor;
      popup.layer.borderColor = [NSColor colorWithSRGBRed:0.75 green:0.75 blue:0.78 alpha:1.0].CGColor;
      if ([popup respondsToSelector:@selector(setContentTintColor:)]) {
        [popup setContentTintColor:fontColor ?: [NSColor colorWithSRGBRed:0.10 green:0.10 blue:0.12 alpha:1.0]];
      }
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
    self.trayIconsByName = [NSMutableDictionary dictionary];
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
  if (!control) return nil;
  NSString *assoc = objc_getAssociatedObject(control, "parentControlName");
  if (assoc) return assoc;
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
  // Remember explicitly requested colors so that setting only one of
  // background/font later does not wipe out the other (e.g. a font-color-only
  // call must not reset an explicitly set button background to clear).
  if (backgroundColor) {
    objc_setAssociatedObject(view, "sg_explicit_bg", backgroundColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  if (fontColor) {
    objc_setAssociatedObject(view, "sg_explicit_font", fontColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
  NSColor *effectiveBackgroundColor = backgroundColor ?: objc_getAssociatedObject(view, "sg_explicit_bg") ?: currentBackgroundColorForView(view);
  NSColor *effectiveFontColor = fontColor ?: objc_getAssociatedObject(view, "sg_explicit_font") ?: currentFontColorForView(view) ?: [NSColor labelColor];
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
    NSColor *srgbBg = backgroundColor ? ([backgroundColor colorUsingColorSpace:[NSColorSpace sRGBColorSpace]] ?: backgroundColor) : nil;
    if (srgbBg) {
      CGFloat r=0, g=0, b=0, a=0;
      [srgbBg getRed:&r green:&g blue:&b alpha:&a];
      double luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b;
      NSAppearance *targetAppearance = nil;
      if (luminance < 0.5) {
        if (@available(macOS 10.14, *)) {
          targetAppearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
        } else {
          targetAppearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
        }
      } else {
        if (@available(macOS 10.14, *)) {
          targetAppearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
        } else {
          targetAppearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
        }
      }
      self.window.appearance = targetAppearance;
      if (self.window.contentView) {
        self.window.contentView.appearance = targetAppearance;
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
      [self.window setBackgroundColor:srgbBg];
      [self.window setOpaque:YES];
    }
    if (self.window.contentView) {
      [self.window.contentView setWantsLayer:YES];
      [self.window.contentView.layer setBorderWidth:0.5];
      NSAppearance *appearance = self.window.appearance ?: [NSApp effectiveAppearance];
      if ([appearance bestMatchFromAppearancesWithNames:@[NSAppearanceNameDarkAqua, NSAppearanceNameAqua]] == NSAppearanceNameDarkAqua) {
        [self.window.contentView.layer setBorderColor:[[NSColor colorWithCalibratedWhite:1.0 alpha:0.15] CGColor]];
      } else {
        [self.window.contentView.layer setBorderColor:[[NSColor colorWithCalibratedWhite:0.0 alpha:0.10] CGColor]];
      }

      if ([self.window.contentView isKindOfClass:[NSVisualEffectView class]]) {
        NSVisualEffectView *vev = (NSVisualEffectView *)self.window.contentView;
        if (isDefaultBg) {
          [vev setState:NSVisualEffectStateActive];
          [vev.layer setBackgroundColor:[NSColor clearColor].CGColor];
        } else {
          [vev setState:NSVisualEffectStateInactive];
          [vev.layer setBackgroundColor:srgbBg.CGColor];
        }
      } else {
        if (isDefaultBg) {
          [self.window.contentView.layer setBackgroundColor:[NSColor clearColor].CGColor];
        } else {
          [self.window.contentView.layer setBackgroundColor:srgbBg.CGColor];
        }
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
  if (self.containerStack && self.containerStack.count > 0) {
    NSView *currentContainer = [self.containerStack lastObject];
    if ([currentContainer isKindOfClass:[NSStackView class]]) {
      [(NSStackView *)currentContainer addArrangedSubview:view];
    } else if ([currentContainer isKindOfClass:[GridContainerView class]]) {
      [(GridContainerView *)currentContainer addControlView:view];
    } else {
      [currentContainer addSubview:view];
    }
  } else if (self.currentRowStack) {
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
  if (!self.containerStack) {
    self.containerStack = [NSMutableArray array];
  }
  NSStackView *row = [[NSStackView alloc] init];
  [row setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [row setAlignment:NSLayoutAttributeCenterY];
  [row setDistribution:NSStackViewDistributionFill];
  [row setSpacing:12.0];
  [row setWantsLayer:YES];
  [row setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  [self addControlToLayout:row];
  [self.containerStack addObject:row];
  self.currentRowStack = row;
  self.controlsByName[[name lowercaseString]] = row;
}

- (void)endRow {
  if (self.containerStack && self.containerStack.count > 0) {
    [self.containerStack removeLastObject];
  }
  self.currentRowStack = nil;
}

- (void)beginGridWithName:(NSString *)name columns:(int)columns spacing:(int)spacing {
  if (!self.containerStack) {
    self.containerStack = [NSMutableArray array];
  }
  GridContainerView *grid = [[GridContainerView alloc] initWithColumns:columns spacing:(CGFloat)spacing];
  [self addControlToLayout:grid];
  
  NSView *parentContainer = (self.containerStack && self.containerStack.count > 0) ? [self.containerStack lastObject] : self.mainStackView;
  if (parentContainer) {
    [grid.widthAnchor constraintEqualToAnchor:parentContainer.widthAnchor].active = YES;
  }
  
  [self.containerStack addObject:grid];
  self.controlsByName[[name lowercaseString]] = grid;
}

- (void)endGrid {
  if (self.containerStack && self.containerStack.count > 0) {
    [self.containerStack removeLastObject];
  }
}

- (void)beginFlexBoxWithName:(NSString *)name direction:(NSString *)direction justify:(NSString *)justify align:(NSString *)align {
  if (!self.containerStack) {
    self.containerStack = [NSMutableArray array];
  }
  NSStackView *flex = [[NSStackView alloc] init];
  [flex setWantsLayer:YES];
  [flex setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  NSString *dirStr = [direction lowercaseString];
  if ([dirStr isEqualToString:@"column"] || [dirStr isEqualToString:@"vertical"]) {
    [flex setOrientation:NSUserInterfaceLayoutOrientationVertical];
  } else {
    [flex setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  }
  
  NSString *justStr = [justify lowercaseString];
  if ([justStr isEqualToString:@"center"]) {
    [flex setDistribution:NSStackViewDistributionGravityAreas];
  } else if ([justStr isEqualToString:@"space_between"] || [justStr isEqualToString:@"space-between"]) {
    [flex setDistribution:NSStackViewDistributionEqualSpacing];
  } else if ([justStr isEqualToString:@"space_around"] || [justStr isEqualToString:@"space_evenly"] || [justStr isEqualToString:@"space-around"]) {
    [flex setDistribution:NSStackViewDistributionEqualCentering];
  } else if ([justStr isEqualToString:@"fill"] || [justStr isEqualToString:@"stretch"] || [justStr isEqualToString:@"fill_equally"]) {
    [flex setDistribution:NSStackViewDistributionFillEqually];
  } else {
    [flex setDistribution:NSStackViewDistributionFill];
  }
  
  NSString *alignStr = [align lowercaseString];
  if ([dirStr isEqualToString:@"column"] || [dirStr isEqualToString:@"vertical"]) {
    if ([alignStr isEqualToString:@"center"]) {
      [flex setAlignment:NSLayoutAttributeCenterX];
    } else if ([alignStr isEqualToString:@"end"] || [alignStr isEqualToString:@"right"] || [alignStr isEqualToString:@"trailing"]) {
      [flex setAlignment:NSLayoutAttributeTrailing];
    } else {
      [flex setAlignment:NSLayoutAttributeLeading];
    }
  } else {
    if ([alignStr isEqualToString:@"center"]) {
      [flex setAlignment:NSLayoutAttributeCenterY];
    } else if ([alignStr isEqualToString:@"end"] || [alignStr isEqualToString:@"bottom"] || [alignStr isEqualToString:@"trailing"]) {
      [flex setAlignment:NSLayoutAttributeBottom];
    } else {
      [flex setAlignment:NSLayoutAttributeTop];
    }
  }
  
  [flex setSpacing:12.0];
  [self addControlToLayout:flex];
  
  NSView *parentContainer = (self.containerStack && self.containerStack.count > 0) ? [self.containerStack lastObject] : self.mainStackView;
  if (parentContainer) {
    [flex.widthAnchor constraintEqualToAnchor:parentContainer.widthAnchor].active = YES;
  }
  
  [self.containerStack addObject:flex];
  self.controlsByName[[name lowercaseString]] = flex;
}

- (void)endFlexBox {
  if (self.containerStack && self.containerStack.count > 0) {
    [self.containerStack removeLastObject];
  }
}

- (void)setControlAlignment:(NSString *)alignment forName:(NSString *)name {
  NSView *view = self.controlsByName[[name lowercaseString]];
  if (!view) return;
  
  NSString *alignStr = [alignment lowercaseString];
  if ([view isKindOfClass:[NSTextField class]]) {
    NSTextField *tf = (NSTextField *)view;
    if ([alignStr rangeOfString:@"center"].location != NSNotFound) {
      [tf setAlignment:NSTextAlignmentCenter];
    } else if ([alignStr rangeOfString:@"right"].location != NSNotFound || [alignStr rangeOfString:@"trailing"].location != NSNotFound) {
      [tf setAlignment:NSTextAlignmentRight];
    } else {
      [tf setAlignment:NSTextAlignmentLeft];
    }
  } else if ([view respondsToSelector:@selector(setAlignment:)]) {
    if ([alignStr rangeOfString:@"center"].location != NSNotFound) {
      [(id)view setAlignment:NSTextAlignmentCenter];
    } else if ([alignStr rangeOfString:@"right"].location != NSNotFound || [alignStr rangeOfString:@"trailing"].location != NSNotFound) {
      [(id)view setAlignment:NSTextAlignmentRight];
    } else {
      [(id)view setAlignment:NSTextAlignmentLeft];
    }
  }
}

- (void)setControlExpandFill:(BOOL)expand forName:(NSString *)name {
  NSView *view = self.controlsByName[[name lowercaseString]];
  if (!view) return;
  
  if (expand) {
    [view setContentHuggingPriority:1.0 forOrientation:NSLayoutConstraintOrientationHorizontal];
    [view setContentHuggingPriority:1.0 forOrientation:NSLayoutConstraintOrientationVertical];
    [view setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationHorizontal];
    if ([view.superview isKindOfClass:[NSStackView class]]) {
      NSStackView *parentStack = (NSStackView *)view.superview;
      if (parentStack.orientation == NSUserInterfaceLayoutOrientationHorizontal) {
        [parentStack setVisibilityPriority:NSStackViewVisibilityPriorityMustHold forView:view];
      }
    }
  }
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
  [picker setDatePickerElements:NSYearMonthDayDatePickerElementFlag];
  
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

- (NSView *)makeDateTimePickerWithName:(NSString *)name dateTime:(NSString *)dateTimeString {
  NSDatePicker *picker = [[NSDatePicker alloc] initWithFrame:NSZeroRect];
  [picker setDatePickerStyle:NSDatePickerStyleTextFieldAndStepper];
  [picker setDatePickerMode:NSDatePickerModeSingle];
  [picker setDatePickerElements:NSYearMonthDayDatePickerElementFlag | NSHourMinuteDatePickerElementFlag];
  [picker setPresentsCalendarOverlay:YES];
  
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
  NSDate *date = [formatter dateFromString:dateTimeString] ?: [NSDate date];
  [picker setDateValue:date];
  [picker setTarget:self];
  [picker setAction:@selector(handleDatePickerChanged:)];
  [self makeStretchableView:picker minimumWidth:200];
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

- (void)textViewDidChangeSelection:(NSNotification *)notification {
  NSTextView *textView = (NSTextView *)notification.object;
  NSString *name = [self nameForControl:textView];
  if (!name) {
    name = objc_getAssociatedObject(textView, "parentControlName");
  }
  if (name && self.win_ptr) {
    NSRange sel = [textView selectedRange];
    if (sel.length > 0 && (sel.location + sel.length) <= [textView string].length) {
      NSString *selectedText = [[textView string] substringWithRange:sel];
      vlang_dispatch_event(self.win_ptr, [name UTF8String], "select", [selectedText UTF8String]);
    }
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
    NSString *key = [[name lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger selectedRow = [tableView selectedRow];
    
    if (self.gridItemsByName && self.gridItemsByName[key]) {
      NSInteger selectedCol = [tableView selectedColumn];
      if (selectedRow >= 0 && selectedCol >= 0) {
        [self updateGridSelectionHighlightForTableView:tableView row:selectedRow col:selectedCol];
      } else {
        [self updateGridSelectionHighlightForTableView:tableView row:-1 col:-1];
      }
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
  NSString *colorStr = [NSString stringWithFormat:@"#%02x%02x%02x", (int)(r * 255.99), (int)(g * 255.99), (int)(b * 255.99)];
  NSString *name = [self nameForControl:well];
  if (name && self.win_ptr) {
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [colorStr UTF8String]);
  }
}

- (void)handleDatePickerChanged:(id)sender {
  NSDatePicker *picker = (NSDatePicker *)sender;
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  NSDatePickerElementFlags elements = [picker datePickerElements];
  BOOL hasDate = (elements & NSYearMonthDayDatePickerElementFlag) != 0;
  BOOL hasTime = (elements & (NSHourMinuteDatePickerElementFlag | NSHourMinuteSecondDatePickerElementFlag)) != 0;
  BOOL hasSeconds = (elements & NSHourMinuteSecondDatePickerElementFlag) != 0;
  
  if (hasDate && hasTime) {
    if (hasSeconds) {
      [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    } else {
      [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
  } else if (hasDate) {
    [formatter setDateFormat:@"yyyy-MM-dd"];
  } else if (hasTime) {
    if (hasSeconds) {
      [formatter setDateFormat:@"HH:mm:ss"];
    } else {
      [formatter setDateFormat:@"HH:mm"];
    }
  } else {
    [formatter setDateFormat:@"yyyy-MM-dd"];
  }
  
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
  
  // Ensure the menu bar is available even before the window shows.
  [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
  
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
  [self setupMenuBar];
  [self setupWindow];
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
  
  // The first item of the main menu is always the application menu on macOS;
  // its title is never displayed. Make sure the standard menus (App/Edit/Window)
  // exist first so custom menus never occupy that reserved slot.
  if (mainMenu.itemArray.count == 0) {
    [self setupMenuBar];
    mainMenu = [NSApp mainMenu];
  }
  
  // Search existing submenus
  for (NSMenuItem *item in mainMenu.itemArray) {
    if (item.submenu && [[item.submenu title] isEqualToString:menuName]) {
      return item.submenu;
    }
  }
  
  // Insert after the app menu (index >= 1), before Edit/Window when present.
  NSInteger insertionIndex = MIN(1, (NSInteger)mainMenu.itemArray.count);
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
  if (insertionIndex < 1 && mainMenu.itemArray.count >= 1) {
    insertionIndex = 1;
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

- (NSView *)makeStatCardWithName:(NSString *)name title:(NSString *)title value:(NSString *)value trend:(NSString *)trend trendStyle:(NSString *)trendStyle {
  NSBox *box = [[NSBox alloc] initWithFrame:NSZeroRect];
  [box setBoxType:NSBoxCustom];
  [box setBorderType:NSLineBorder];
  [box setBorderWidth:1.0];
  [box setBorderColor:[NSColor colorWithCalibratedWhite:0.5 alpha:0.2]];
  [box setContentViewMargins:NSMakeSize(12, 10)];
  [box setWantsLayer:YES];
  box.layer.cornerRadius = 8.0;
  
  if (self.currentBackgroundColor) {
    box.layer.backgroundColor = [[self.currentBackgroundColor colorWithAlphaComponent:0.1] CGColor];
  } else {
    box.layer.backgroundColor = [[NSColor colorWithCalibratedWhite:0.5 alpha:0.05] CGColor];
  }
  
  NSStackView *stack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [stack setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [stack setSpacing:4.0];
  [stack setAlignment:NSLayoutAttributeLeading];
  
  NSTextField *titleLabel = [NSTextField labelWithString:[title uppercaseString]];
  [titleLabel setFont:[NSFont systemFontOfSize:10.0 weight:NSFontWeightMedium]];
  [titleLabel setTextColor:[NSColor secondaryLabelColor]];
  
  NSTextField *valueLabel = [NSTextField labelWithString:value];
  [valueLabel setFont:[NSFont systemFontOfSize:24.0 weight:NSFontWeightBold]];
  if (self.currentFontColor) {
    [valueLabel setTextColor:self.currentFontColor];
  }
  
  NSTextField *trendLabel = [NSTextField labelWithString:trend];
  [trendLabel setFont:[NSFont systemFontOfSize:11.0 weight:NSFontWeightRegular]];
  
  NSColor *trendColor = [NSColor secondaryLabelColor];
  NSString *style = [trendStyle lowercaseString];
  if ([style isEqualToString:@"success"]) {
    trendColor = [NSColor systemGreenColor];
  } else if ([style isEqualToString:@"error"]) {
    trendColor = [NSColor systemRedColor];
  } else if ([style isEqualToString:@"warning"]) {
    trendColor = [NSColor systemOrangeColor];
  } else if ([style isEqualToString:@"info"]) {
    trendColor = [NSColor systemBlueColor];
  }
  [trendLabel setTextColor:trendColor];
  
  [stack addArrangedSubview:titleLabel];
  [stack addArrangedSubview:valueLabel];
  [stack addArrangedSubview:trendLabel];
  
  [box setContentView:stack];
  
  valueLabel.tag = 101;
  trendLabel.tag = 102;
  
  self.controlsByName[[name lowercaseString]] = box;
  [self addControlToLayout:box];
  return box;
}

- (NSView *)makeBannerWithName:(NSString *)name text:(NSString *)text style:(NSString *)styleStr {
  NSBox *box = [[NSBox alloc] initWithFrame:NSZeroRect];
  [box setBoxType:NSBoxCustom];
  [box setBorderType:NSLineBorder];
  [box setBorderWidth:1.0];
  [box setContentViewMargins:NSMakeSize(12, 10)];
  [box setWantsLayer:YES];
  box.layer.cornerRadius = 6.0;
  
  NSTextField *label = [NSTextField labelWithString:text];
  [label setFont:[NSFont systemFontOfSize:12.0]];
  [[label cell] setWraps:YES];
  [label setTextColor:[NSColor labelColor]];
  
  NSColor *bgColor = nil;
  NSColor *borderColor = nil;
  
  NSString *style = [styleStr lowercaseString];
  if ([style isEqualToString:@"success"]) {
    bgColor = [NSColor colorWithCalibratedRed:0.18 green:0.49 blue:0.20 alpha:0.12];
    borderColor = [NSColor systemGreenColor];
  } else if ([style isEqualToString:@"error"]) {
    bgColor = [NSColor colorWithCalibratedRed:0.83 green:0.18 blue:0.18 alpha:0.12];
    borderColor = [NSColor systemRedColor];
  } else if ([style isEqualToString:@"warning"]) {
    bgColor = [NSColor colorWithCalibratedRed:0.95 green:0.60 blue:0.00 alpha:0.12];
    borderColor = [NSColor systemOrangeColor];
  } else if ([style isEqualToString:@"info"]) {
    bgColor = [NSColor colorWithCalibratedRed:0.12 green:0.45 blue:0.74 alpha:0.12];
    borderColor = [NSColor systemBlueColor];
  } else {
    bgColor = [NSColor colorWithCalibratedWhite:0.5 alpha:0.1];
    borderColor = [NSColor colorWithCalibratedWhite:0.5 alpha:0.3];
  }
  
  box.layer.backgroundColor = [bgColor CGColor];
  [box setBorderColor:borderColor];
  [box setContentView:label];
  
  label.tag = 201;
  
  self.controlsByName[[name lowercaseString]] = box;
  [self addControlToLayout:box];
  return box;
}

- (NSView *)makeSectionHeaderWithName:(NSString *)name title:(NSString *)title subtitle:(NSString *)subtitle {
  NSStackView *stack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [stack setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [stack setSpacing:4.0];
  [stack setAlignment:NSLayoutAttributeLeading];
  
  NSTextField *titleLabel = [NSTextField labelWithString:title];
  [titleLabel setFont:[NSFont systemFontOfSize:16.0 weight:NSFontWeightBold]];
  if (self.currentFontColor) {
    [titleLabel setTextColor:self.currentFontColor];
  }
  [stack addArrangedSubview:titleLabel];
  
  if (subtitle && subtitle.length > 0) {
    NSTextField *subLabel = [NSTextField labelWithString:subtitle];
    [subLabel setFont:[NSFont systemFontOfSize:11.0]];
    [subLabel setTextColor:[NSColor secondaryLabelColor]];
    [stack addArrangedSubview:subLabel];
  }
  
  NSBox *line = [[NSBox alloc] initWithFrame:NSZeroRect];
  [line setBoxType:NSBoxCustom];
  [line setBorderType:NSLineBorder];
  [line setBorderWidth:1.0];
  [line setBorderColor:modernBorderColor()];
  [line setWantsLayer:YES];
  [line.heightAnchor constraintEqualToConstant:1.0].active = YES;
  [stack addArrangedSubview:line];
  
  self.controlsByName[[name lowercaseString]] = stack;
  [self addControlToLayout:stack];
  return stack;
}

- (NSView *)makeVerticalSliderWithName:(NSString *)name value:(int)value minValue:(int)minValue maxValue:(int)maxValue height:(int)height {
  NSStackView *col = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [col setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [col setSpacing:6.0];
  [col setAlignment:NSLayoutAttributeCenterX];
  
  NSSlider *slider = [[NSSlider alloc] initWithFrame:NSZeroRect];
  [slider setMinValue:minValue];
  [slider setMaxValue:maxValue];
  [slider setIntValue:value];
  [slider setVertical:YES];
  [slider setTarget:self];
  [slider setAction:@selector(handleSliderChanged:)];
  [slider setWantsLayer:YES];
  
  int sliderHeight = height > 0 ? height : 150;
  [slider.heightAnchor constraintEqualToConstant:sliderHeight].active = YES;
  
  NSTextField *label = [NSTextField labelWithString:[NSString stringWithFormat:@"Value: %d", value]];
  [label setFont:[NSFont systemFontOfSize:11.0]];
  [label setAlignment:NSTextAlignmentCenter];
  if (self.currentFontColor) {
    [label setTextColor:self.currentFontColor];
  }
  
  [col addArrangedSubview:slider];
  [col addArrangedSubview:label];
  
  self.controlsByName[[name lowercaseString]] = slider;
  [self addControlToLayout:col];
  return slider;
}

- (NSView *)makeChipGroupWithName:(NSString *)name chips:(NSArray<NSString *> *)chips selected:(NSString *)selected {
  NSSegmentedControl *seg = [[NSSegmentedControl alloc] initWithFrame:NSZeroRect];
  [seg setSegmentCount:chips.count];
  [seg setSegmentStyle:NSSegmentStyleRoundRect];
  [seg setTarget:self];
  [seg setAction:@selector(handleSegmentedChanged:)];
  [seg setWantsLayer:YES];
  
  NSInteger selectedIndex = -1;
  for (NSUInteger i = 0; i < chips.count; i++) {
    NSString *chip = chips[i];
    [seg setLabel:chip forSegment:i];
    if ([chip isEqualToString:selected]) {
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

// Status Indicator control
- (NSView *)makeStatusIndicatorWithName:(NSString *)name label:(NSString *)labelText status:(NSString *)statusStr {
  NSStackView *stack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [stack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [stack setSpacing:8.0];
  [stack setAlignment:NSLayoutAttributeCenterY];
  
  NSBox *dot = [[NSBox alloc] initWithFrame:NSZeroRect];
  [dot setBoxType:NSBoxCustom];
  [dot setBorderType:NSNoBorder];
  [dot setWantsLayer:YES];
  dot.layer.cornerRadius = 5.0;
  [dot.widthAnchor constraintEqualToConstant:10.0].active = YES;
  [dot.heightAnchor constraintEqualToConstant:10.0].active = YES;
  
  NSColor *dotColor = [NSColor secondaryLabelColor];
  NSString *st = [statusStr lowercaseString];
  if ([st isEqualToString:@"active"] || [st isEqualToString:@"online"] || [st isEqualToString:@"success"]) {
    dotColor = [NSColor systemGreenColor];
  } else if ([st isEqualToString:@"warning"] || [st isEqualToString:@"busy"]) {
    dotColor = [NSColor systemOrangeColor];
  } else if ([st isEqualToString:@"error"] || [st isEqualToString:@"offline"]) {
    dotColor = [NSColor systemRedColor];
  }
  dot.layer.backgroundColor = [dotColor CGColor];
  [dot setIdentifier:@"101"];
  
  NSTextField *label = [NSTextField labelWithString:labelText];
  [label setFont:[NSFont systemFontOfSize:12.0 weight:NSFontWeightMedium]];
  if (self.currentFontColor) {
    [label setTextColor:self.currentFontColor];
  }
  [label setTag:102];
  
  [stack addArrangedSubview:dot];
  [stack addArrangedSubview:label];
  
  self.controlsByName[[name lowercaseString]] = stack;
  [self addControlToLayout:stack];
  return stack;
}

// Metric Meter control
- (NSView *)makeMetricMeterWithName:(NSString *)name title:(NSString *)titleStr value:(double)val minVal:(double)minVal maxVal:(double)maxVal unit:(NSString *)unitStr {
  NSBox *box = [[NSBox alloc] initWithFrame:NSZeroRect];
  [box setBoxType:NSBoxCustom];
  [box setBorderType:NSLineBorder];
  [box setBorderWidth:1.0];
  [box setBorderColor:[NSColor colorWithCalibratedWhite:0.5 alpha:0.2]];
  [box setContentViewMargins:NSMakeSize(12, 10)];
  [box setWantsLayer:YES];
  box.layer.cornerRadius = 8.0;
  box.layer.backgroundColor = [[NSColor colorWithCalibratedWhite:0.5 alpha:0.05] CGColor];
  
  NSStackView *vstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [vstack setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [vstack setSpacing:6.0];
  [vstack setAlignment:NSLayoutAttributeLeading];
  
  NSStackView *hstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hstack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hstack setDistribution:NSStackViewDistributionFill];
  [hstack setAlignment:NSLayoutAttributeCenterY];
  
  NSTextField *titleLabel = [NSTextField labelWithString:titleStr];
  [titleLabel setFont:[NSFont systemFontOfSize:12.0 weight:NSFontWeightBold]];
  if (self.currentFontColor) {
    [titleLabel setTextColor:self.currentFontColor];
  }
  
  NSString *valText = [NSString stringWithFormat:@"%.0f%@", val, unitStr ? unitStr : @""];
  NSTextField *valLabel = [NSTextField labelWithString:valText];
  [valLabel setFont:[NSFont systemFontOfSize:12.0 weight:NSFontWeightMedium]];
  [valLabel setTextColor:[NSColor secondaryLabelColor]];
  [valLabel setTag:101];
  
  [hstack addArrangedSubview:titleLabel];
  [hstack addArrangedSubview:valLabel];
  
  NSProgressIndicator *bar = [[NSProgressIndicator alloc] initWithFrame:NSZeroRect];
  [bar setIndeterminate:NO];
  [bar setMinValue:minVal];
  [bar setMaxValue:maxVal];
  [bar setDoubleValue:val];
  [bar setStyle:NSProgressIndicatorStyleBar];
  [bar.heightAnchor constraintEqualToConstant:8.0].active = YES;
  [bar setIdentifier:@"102"];
  
  [vstack addArrangedSubview:hstack];
  [vstack addArrangedSubview:bar];
  
  [box setContentView:vstack];
  
  self.controlsByName[[name lowercaseString]] = box;
  [self addControlToLayout:box];
  return box;
}

// Avatar Card control
- (NSView *)makeAvatarCardWithName:(NSString *)name title:(NSString *)titleStr subtitle:(NSString *)subStr status:(NSString *)statusStr {
  NSBox *box = [[NSBox alloc] initWithFrame:NSZeroRect];
  [box setBoxType:NSBoxCustom];
  [box setBorderType:NSLineBorder];
  [box setBorderWidth:1.0];
  [box setBorderColor:[NSColor colorWithCalibratedWhite:0.5 alpha:0.2]];
  [box setContentViewMargins:NSMakeSize(12, 10)];
  [box setWantsLayer:YES];
  box.layer.cornerRadius = 10.0;
  box.layer.backgroundColor = [[NSColor colorWithCalibratedWhite:0.5 alpha:0.05] CGColor];
  
  NSStackView *hstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hstack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hstack setSpacing:12.0];
  [hstack setAlignment:NSLayoutAttributeCenterY];
  
  NSBox *avatar = [[NSBox alloc] initWithFrame:NSZeroRect];
  [avatar setBoxType:NSBoxCustom];
  [avatar setBorderType:NSNoBorder];
  [avatar setWantsLayer:YES];
  avatar.layer.cornerRadius = 18.0;
  avatar.layer.backgroundColor = [[NSColor systemBlueColor] CGColor];
  [avatar.widthAnchor constraintEqualToConstant:36.0].active = YES;
  [avatar.heightAnchor constraintEqualToConstant:36.0].active = YES;
  
  NSString *initial = titleStr.length > 0 ? [[titleStr substringToIndex:1] uppercaseString] : @"A";
  NSTextField *initialLabel = [NSTextField labelWithString:initial];
  [initialLabel setFont:[NSFont boldSystemFontOfSize:16.0]];
  [initialLabel setTextColor:[NSColor whiteColor]];
  [initialLabel setAlignment:NSTextAlignmentCenter];
  [avatar setContentView:initialLabel];
  
  NSStackView *vstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [vstack setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [vstack setSpacing:2.0];
  [vstack setAlignment:NSLayoutAttributeLeading];
  
  NSTextField *titleLabel = [NSTextField labelWithString:titleStr];
  [titleLabel setFont:[NSFont systemFontOfSize:13.0 weight:NSFontWeightBold]];
  if (self.currentFontColor) {
    [titleLabel setTextColor:self.currentFontColor];
  }
  [titleLabel setTag:101];
  
  NSTextField *subLabel = [NSTextField labelWithString:subStr];
  [subLabel setFont:[NSFont systemFontOfSize:11.0 weight:NSFontWeightRegular]];
  [subLabel setTextColor:[NSColor secondaryLabelColor]];
  [subLabel setTag:102];
  
  [vstack addArrangedSubview:titleLabel];
  [vstack addArrangedSubview:subLabel];
  
  NSBox *badge = [[NSBox alloc] initWithFrame:NSZeroRect];
  [badge setBoxType:NSBoxCustom];
  [badge setBorderType:NSNoBorder];
  [badge setContentViewMargins:NSMakeSize(8, 3)];
  [badge setWantsLayer:YES];
  badge.layer.cornerRadius = 8.0;
  
  NSTextField *badgeLabel = [NSTextField labelWithString:statusStr];
  [badgeLabel setFont:[NSFont boldSystemFontOfSize:10.0]];
  [badgeLabel setTag:103];
  
  NSColor *bColor = [NSColor colorWithCalibratedWhite:0.5 alpha:0.15];
  NSColor *tColor = [NSColor secondaryLabelColor];
  NSString *st = [statusStr lowercaseString];
  if ([st isEqualToString:@"online"] || [st isEqualToString:@"active"] || [st isEqualToString:@"success"]) {
    bColor = [NSColor colorWithCalibratedRed:0.18 green:0.49 blue:0.20 alpha:0.15];
    tColor = [NSColor systemGreenColor];
  } else if ([st isEqualToString:@"busy"] || [st isEqualToString:@"warning"]) {
    bColor = [NSColor colorWithCalibratedRed:0.95 green:0.60 blue:0.00 alpha:0.15];
    tColor = [NSColor systemOrangeColor];
  } else if ([st isEqualToString:@"offline"] || [st isEqualToString:@"error"]) {
    bColor = [NSColor colorWithCalibratedRed:0.83 green:0.18 blue:0.18 alpha:0.15];
    tColor = [NSColor systemRedColor];
  }
  badge.layer.backgroundColor = [bColor CGColor];
  [badgeLabel setTextColor:tColor];
  [badge setContentView:badgeLabel];
  [badge setIdentifier:@"104"];

  
  [hstack addArrangedSubview:avatar];
  [hstack addArrangedSubview:vstack];
  [hstack addArrangedSubview:badge];
  
  [box setContentView:hstack];
  
  self.controlsByName[[name lowercaseString]] = box;
  [self addControlToLayout:box];
  return box;
}

- (NSView *)makeTimePickerWithName:(NSString *)name time:(NSString *)timeString {
  NSDatePicker *picker = [[NSDatePicker alloc] initWithFrame:NSZeroRect];
  [picker setDatePickerStyle:NSDatePickerStyleTextFieldAndStepper];
  [picker setDatePickerMode:NSDatePickerModeSingle];
  [picker setDatePickerElements:NSDatePickerElementFlagHourMinuteSecond];
  [picker setTarget:self];
  [picker setAction:@selector(handleInputChanged:)];
  [picker setWantsLayer:YES];
  
  if (timeString && timeString.length > 0) {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSDate *date = [formatter dateFromString:timeString];
    if (!date) {
      [formatter setDateFormat:@"HH:mm"];
      date = [formatter dateFromString:timeString];
    }
    if (date) {
      [picker setDateValue:date];
    }
    [formatter release];
  }
  
  self.controlsByName[[name lowercaseString]] = picker;
  [self addControlToLayout:picker];
  return picker;
}

- (void)makeTrayIconWithName:(NSString *)name symbol:(NSString *)symbolName title:(NSString *)title {
  NSStatusItem *item = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
  if (@available(macOS 11.0, *)) {
    if (symbolName && symbolName.length > 0) {
      NSImage *img = [NSImage imageWithSystemSymbolName:symbolName accessibilityDescription:nil];
      if (img) {
        item.button.image = img;
      }
    }
  }
  if (title && title.length > 0) {
    item.button.title = title;
  }
  if (!self.trayIconsByName) {
    self.trayIconsByName = [NSMutableDictionary dictionary];
  }
  self.trayIconsByName[[name lowercaseString]] = item;
}

- (NSView *)makeCollapsibleSectionWithName:(NSString *)name title:(NSString *)title expanded:(BOOL)expanded {
  NSBox *box = [[NSBox alloc] initWithFrame:NSZeroRect];
  [box setBoxType:NSBoxCustom];
  [box setBorderType:NSLineBorder];
  [box setBorderWidth:1.0];
  [box setBorderColor:[NSColor colorWithCalibratedWhite:0.5 alpha:0.2]];
  [box setContentViewMargins:NSMakeSize(12, 10)];
  [box setWantsLayer:YES];
  box.layer.cornerRadius = 8.0;
  box.layer.backgroundColor = [[NSColor colorWithCalibratedWhite:0.5 alpha:0.05] CGColor];
  
  NSStackView *hstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hstack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hstack setSpacing:8.0];
  [hstack setAlignment:NSLayoutAttributeCenterY];
  
  NSButton *toggle = [NSButton buttonWithTitle:@"" target:self action:@selector(handleDisclosureClicked:)];
  [toggle setBezelStyle:NSBezelStyleDisclosure];
  [toggle setButtonType:NSButtonTypePushOnPushOff];
  [toggle setState:expanded ? NSControlStateValueOn : NSControlStateValueOff];
  [toggle setIdentifier:@"101"];
  
  NSTextField *label = [NSTextField labelWithString:title];
  [label setFont:[NSFont systemFontOfSize:13.0 weight:NSFontWeightBold]];
  if (self.currentFontColor) {
    [label setTextColor:self.currentFontColor];
  }
  [label setTag:102];
  
  [hstack addArrangedSubview:toggle];
  [hstack addArrangedSubview:label];
  
  [box setContentView:hstack];
  
  self.controlsByName[[name lowercaseString]] = box;
  [self addControlToLayout:box];
  return box;
}

- (NSView *)makeCodeEditorWithName:(NSString *)name code:(NSString *)codeString height:(int)height {
  NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:NSZeroRect];
  [scrollView setHasVerticalScroller:YES];
  [scrollView setHasHorizontalScroller:YES];
  [scrollView setBorderType:NSNoBorder];
  [scrollView setWantsLayer:YES];
  scrollView.layer.cornerRadius = 8.0;
  scrollView.layer.borderWidth = 1.0;
  scrollView.layer.borderColor = [[NSColor colorWithCalibratedWhite:0.5 alpha:0.2] CGColor];
  
  [scrollView.widthAnchor constraintGreaterThanOrEqualToConstant:200].active = YES;
  if (height > 0) {
    [scrollView.heightAnchor constraintEqualToConstant:(CGFloat)height].active = YES;
  } else {
    [scrollView.heightAnchor constraintEqualToConstant:200.0].active = YES;
  }
  
  NSTextView *textView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 400, height > 0 ? height : 200)];
  [textView setHorizontallyResizable:YES];
  [textView setVerticallyResizable:YES];
  [textView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [textView setRichText:NO];
  [textView setImportsGraphics:NO];
  [textView setAutomaticQuoteSubstitutionEnabled:NO];
  [textView setAutomaticDashSubstitutionEnabled:NO];
  [textView setAutomaticTextReplacementEnabled:NO];
  [textView setFont:[NSFont monospacedSystemFontOfSize:12.0 weight:NSFontWeightRegular]];
  [textView setBackgroundColor:[NSColor colorWithCalibratedRed:0.09 green:0.12 blue:0.18 alpha:1.0]];
  [textView setTextColor:[NSColor colorWithCalibratedRed:0.95 green:0.96 blue:0.98 alpha:1.0]];
  [textView setInsertionPointColor:[NSColor whiteColor]];
  
  if (codeString) {
    [textView setString:codeString];
  }
  [textView setDelegate:self];
  
  [scrollView setDocumentView:textView];
  [textView release];
  
  self.controlsByName[[name lowercaseString]] = scrollView;
  [self addControlToLayout:scrollView];
  return scrollView;
}

- (NSView *)makeTimelineViewWithName:(NSString *)name height:(int)height {
  NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:NSZeroRect];
  [scrollView setHasVerticalScroller:YES];
  [scrollView setHasHorizontalScroller:NO];
  [scrollView setBorderType:NSNoBorder];
  [scrollView setWantsLayer:YES];
  scrollView.layer.cornerRadius = 8.0;
  scrollView.layer.borderWidth = 1.0;
  scrollView.layer.borderColor = [[NSColor colorWithCalibratedWhite:0.5 alpha:0.2] CGColor];
  
  [scrollView.widthAnchor constraintGreaterThanOrEqualToConstant:200].active = YES;
  if (height > 0) {
    [scrollView.heightAnchor constraintEqualToConstant:(CGFloat)height].active = YES;
  } else {
    [scrollView.heightAnchor constraintEqualToConstant:180.0].active = YES;
  }
  
  NSStackView *vstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [vstack setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [vstack setSpacing:8.0];
  [vstack setAlignment:NSLayoutAttributeLeading];
  [vstack setEdgeInsets:NSEdgeInsetsMake(10, 12, 10, 12)];
  
  [scrollView setDocumentView:vstack];
  [vstack release];
  
  self.controlsByName[[name lowercaseString]] = scrollView;
  [self addControlToLayout:scrollView];
  return scrollView;
}

- (void)addTimelineEntryToName:(NSString *)name time:(NSString *)timeStr title:(NSString *)titleStr detail:(NSString *)detailStr style:(NSString *)styleStr {
  NSView *view = [self viewForControlName:name];
  if ([view isKindOfClass:[NSScrollView class]]) {
    NSScrollView *scroll = (NSScrollView *)view;
    NSView *doc = [scroll documentView];
    if ([doc isKindOfClass:[NSStackView class]]) {
      NSStackView *vstack = (NSStackView *)doc;
      
      NSStackView *row = [[NSStackView alloc] initWithFrame:NSZeroRect];
      [row setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
      [row setSpacing:10.0];
      [row setAlignment:NSLayoutAttributeCenterY];
      
      NSBox *dot = [[NSBox alloc] initWithFrame:NSZeroRect];
      [dot setBoxType:NSBoxCustom];
      [dot setBorderType:NSNoBorder];
      [dot setWantsLayer:YES];
      dot.layer.cornerRadius = 4.0;
      [dot.widthAnchor constraintEqualToConstant:8.0].active = YES;
      [dot.heightAnchor constraintEqualToConstant:8.0].active = YES;
      
      NSColor *dotColor = [NSColor secondaryLabelColor];
      NSString *st = [styleStr lowercaseString];
      if ([st isEqualToString:@"active"] || [st isEqualToString:@"online"] || [st isEqualToString:@"success"]) {
        dotColor = [NSColor systemGreenColor];
      } else if ([st isEqualToString:@"warning"] || [st isEqualToString:@"busy"]) {
        dotColor = [NSColor systemOrangeColor];
      } else if ([st isEqualToString:@"error"] || [st isEqualToString:@"offline"]) {
        dotColor = [NSColor systemRedColor];
      } else if ([st isEqualToString:@"info"]) {
        dotColor = [NSColor systemBlueColor];
      }
      dot.layer.backgroundColor = [dotColor CGColor];
      
      NSTextField *timeLabel = [NSTextField labelWithString:timeStr];
      [timeLabel setFont:[NSFont monospacedSystemFontOfSize:11.0 weight:NSFontWeightMedium]];
      [timeLabel setTextColor:[NSColor secondaryLabelColor]];
      
      NSTextField *titleLabel = [NSTextField labelWithString:titleStr];
      [titleLabel setFont:[NSFont systemFontOfSize:12.0 weight:NSFontWeightBold]];
      if (self.currentFontColor) {
        [titleLabel setTextColor:self.currentFontColor];
      }
      
      NSTextField *detailLabel = [NSTextField labelWithString:detailStr];
      [detailLabel setFont:[NSFont systemFontOfSize:11.0 weight:NSFontWeightRegular]];
      [detailLabel setTextColor:[NSColor secondaryLabelColor]];
      
      [row addArrangedSubview:dot];
      [row addArrangedSubview:timeLabel];
      [row addArrangedSubview:titleLabel];
      [row addArrangedSubview:detailLabel];
      
      [vstack addArrangedSubview:row];
    }
  }
}

- (void)clearTimelineName:(NSString *)name {
  NSView *view = [self viewForControlName:name];
  if ([view isKindOfClass:[NSScrollView class]]) {
    NSScrollView *scroll = (NSScrollView *)view;
    NSView *doc = [scroll documentView];
    if ([doc isKindOfClass:[NSStackView class]]) {
      NSStackView *vstack = (NSStackView *)doc;
      for (NSView *sub in [vstack.arrangedSubviews copy]) {
        [vstack removeArrangedSubview:sub];
        [sub removeFromSuperview];
      }
    }
  }
}

- (void)addToolbarItemWithIdentifier:(NSString *)identifier label:(NSString *)labelStr symbol:(NSString *)symbolName {
  if (!self.toolbarItems) {
    self.toolbarItems = [NSMutableDictionary dictionary];
  }
  if (!self.toolbarOrder) {
    self.toolbarOrder = [NSMutableArray array];
  }
  
  NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
  [item setLabel:labelStr];
  [item setPaletteLabel:labelStr];

  if (@available(macOS 11.0, *)) {
    if (symbolName && symbolName.length > 0) {
      NSImage *img = [NSImage imageWithSystemSymbolName:symbolName accessibilityDescription:nil];
      if (img) {
        [item setImage:img];
      }
    }
  }
  [item setTarget:self];
  [item setAction:@selector(handleToolbarItemClicked:)];
  
  self.toolbarItems[identifier] = item;
  [self.toolbarOrder addObject:identifier];
  
  [self setupToolbar];
}

- (NSView *)makeRatingWithName:(NSString *)name value:(int)val maxStars:(int)maxStars {
  if (maxStars <= 0) maxStars = 5;
  NSStackView *stack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [stack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [stack setSpacing:4.0];
  [stack setAlignment:NSLayoutAttributeCenterY];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = stack;

  int currentVal = (val < 0) ? 0 : ((val > maxStars) ? maxStars : val);
  objc_setAssociatedObject(stack, "ratingValue", @(currentVal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(stack, "maxStars", @(maxStars), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self rebuildRatingStack:stack name:name];
  [self addControlToLayout:stack];
  return stack;
}

- (void)rebuildRatingStack:(NSStackView *)stack name:(NSString *)name {
  for (NSView *v in [stack.arrangedSubviews copy]) {
    [stack removeArrangedSubview:v];
    [v removeFromSuperview];
  }
  int currentVal = [objc_getAssociatedObject(stack, "ratingValue") intValue];
  int maxStars = [objc_getAssociatedObject(stack, "maxStars") intValue];

  for (int i = 1; i <= maxStars; i++) {
    NSButton *btn = [NSButton buttonWithTitle:(i <= currentVal ? @"★" : @"☆") target:self action:@selector(handleRatingStarClicked:)];
    [btn setBordered:NO];
    [btn setFont:[NSFont systemFontOfSize:18.0 weight:NSFontWeightBold]];
    [btn setButtonType:NSButtonTypeMomentaryPushIn];
    btn.identifier = [NSString stringWithFormat:@"%@_%d", name, i];
    [stack addArrangedSubview:btn];
  }
}

- (void)handleRatingStarClicked:(id)sender {
  NSButton *btn = (NSButton *)sender;
  NSString *ident = btn.identifier;
  NSRange range = [ident rangeOfString:@"_" options:NSBackwardsSearch];
  if (range.location != NSNotFound) {
    NSString *name = [ident substringToIndex:range.location];
    int starIdx = [[ident substringFromIndex:range.location + 1] intValue];
    NSStackView *stack = (NSStackView *)self.controlsByName[[name lowercaseString]];
    if (stack) {
      objc_setAssociatedObject(stack, "ratingValue", @(starIdx), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
      [self rebuildRatingStack:stack name:name];
      vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [[NSString stringWithFormat:@"%d", starIdx] UTF8String]);
    }
  }
}

- (void)setRatingValue:(int)val forName:(NSString *)name {
  NSStackView *stack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (stack) {
    int maxStars = [objc_getAssociatedObject(stack, "maxStars") intValue];
    if (maxStars <= 0) maxStars = 5;
    int currentVal = (val < 0) ? 0 : ((val > maxStars) ? maxStars : val);
    objc_setAssociatedObject(stack, "ratingValue", @(currentVal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self rebuildRatingStack:stack name:name];
  }
}

- (int)ratingValueForName:(NSString *)name {
  NSStackView *stack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (stack) {
    return [objc_getAssociatedObject(stack, "ratingValue") intValue];
  }
  return 0;
}

- (NSView *)makeRangeSliderWithName:(NSString *)name min:(int)minVal max:(int)maxVal low:(int)lowVal high:(int)highVal {
  NSStackView *stack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [stack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [stack setSpacing:8.0];
  [stack setAlignment:NSLayoutAttributeCenterY];

  NSSlider *sliderLow = [NSSlider sliderWithValue:lowVal minValue:minVal maxValue:maxVal target:self action:@selector(handleRangeSliderChanged:)];
  sliderLow.identifier = [NSString stringWithFormat:@"%@_low", name];
  NSSlider *sliderHigh = [NSSlider sliderWithValue:highVal minValue:minVal maxValue:maxVal target:self action:@selector(handleRangeSliderChanged:)];
  sliderHigh.identifier = [NSString stringWithFormat:@"%@_high", name];

  NSTextField *label = [NSTextField labelWithString:[NSString stringWithFormat:@"%d - %d", lowVal, highVal]];
  [label setFont:[NSFont monospacedDigitSystemFontOfSize:12.0 weight:NSFontWeightMedium]];
  label.identifier = [NSString stringWithFormat:@"%@_lbl", name];

  [stack addArrangedSubview:sliderLow];
  [stack addArrangedSubview:sliderHigh];
  [stack addArrangedSubview:label];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = stack;

  objc_setAssociatedObject(stack, "lowVal", @(lowVal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(stack, "highVal", @(highVal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(stack, "sliderLow", sliderLow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(stack, "sliderHigh", sliderHigh, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(stack, "rangeLabel", label, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:stack];
  return stack;
}

- (void)handleRangeSliderChanged:(id)sender {
  NSSlider *slider = (NSSlider *)sender;
  NSString *ident = slider.identifier;
  BOOL isLow = [ident hasSuffix:@"_low"];
  NSString *name = [ident substringToIndex:ident.length - (isLow ? 4 : 5)];

  NSStackView *stack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (stack) {
    NSSlider *sliderLow = objc_getAssociatedObject(stack, "sliderLow");
    NSSlider *sliderHigh = objc_getAssociatedObject(stack, "sliderHigh");
    NSTextField *label = objc_getAssociatedObject(stack, "rangeLabel");

    int lowVal = [sliderLow integerValue];
    int highVal = [sliderHigh integerValue];

    if (lowVal > highVal) {
      if (isLow) { highVal = lowVal; [sliderHigh setIntegerValue:highVal]; }
      else { lowVal = highVal; [sliderLow setIntegerValue:lowVal]; }
    }

    objc_setAssociatedObject(stack, "lowVal", @(lowVal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(stack, "highVal", @(highVal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [label setStringValue:[NSString stringWithFormat:@"%d - %d", lowVal, highVal]];

    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [[NSString stringWithFormat:@"%d:%d", lowVal, highVal] UTF8String]);
  }
}

- (void)setRangeSliderLow:(int)lowVal high:(int)highVal forName:(NSString *)name {
  NSStackView *stack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (stack) {
    NSSlider *sliderLow = objc_getAssociatedObject(stack, "sliderLow");
    NSSlider *sliderHigh = objc_getAssociatedObject(stack, "sliderHigh");
    NSTextField *label = objc_getAssociatedObject(stack, "rangeLabel");

    [sliderLow setIntegerValue:lowVal];
    [sliderHigh setIntegerValue:highVal];
    objc_setAssociatedObject(stack, "lowVal", @(lowVal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(stack, "highVal", @(highVal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [label setStringValue:[NSString stringWithFormat:@"%d - %d", lowVal, highVal]];
  }
}

- (int)rangeSliderLowForName:(NSString *)name {
  NSStackView *stack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (stack) { return [objc_getAssociatedObject(stack, "lowVal") intValue]; }
  return 0;
}

- (int)rangeSliderHighForName:(NSString *)name {
  NSStackView *stack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (stack) { return [objc_getAssociatedObject(stack, "highVal") intValue]; }
  return 0;
}

- (NSView *)makeSplitButtonWithName:(NSString *)name title:(NSString *)title menuItems:(NSArray<NSString *> *)menuItems {
  NSStackView *stack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [stack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [stack setSpacing:1.0];
  [stack setAlignment:NSLayoutAttributeCenterY];

  NSButton *mainBtn = [NSButton buttonWithTitle:title target:self action:@selector(handleSplitButtonMainClicked:)];
  [mainBtn setBezelStyle:NSBezelStyleRounded];
  mainBtn.identifier = name;

  NSPopUpButton *menuBtn = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:YES];
  [menuBtn setBezelStyle:NSBezelStyleRounded];
  [menuBtn addItemWithTitle:@""];

  for (NSString *item in menuItems) {
    [menuBtn addItemWithTitle:item];
  }
  menuBtn.identifier = [NSString stringWithFormat:@"%@_popup", name];
  [menuBtn setTarget:self];
  [menuBtn setAction:@selector(handleSplitButtonPopupChanged:)];

  [stack addArrangedSubview:mainBtn];
  [stack addArrangedSubview:menuBtn];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = stack;

  [self addControlToLayout:stack];
  return stack;
}

- (void)handleSplitButtonMainClicked:(id)sender {
  NSButton *btn = (NSButton *)sender;
  vlang_dispatch_event(self.win_ptr, [btn.identifier UTF8String], "click", "");
}

- (void)handleSplitButtonPopupChanged:(id)sender {
  NSPopUpButton *menuBtn = (NSPopUpButton *)sender;
  NSString *ident = menuBtn.identifier;
  if ([ident hasSuffix:@"_popup"]) {
    NSString *name = [ident substringToIndex:ident.length - 6];
    NSString *choice = [menuBtn titleOfSelectedItem] ?: @"";
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "select_item", [choice UTF8String]);
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [choice UTF8String]);
  }
}

- (NSView *)makeTagCloudWithName:(NSString *)name tags:(NSArray<NSString *> *)tags {
  NSStackView *stack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [stack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [stack setSpacing:6.0];
  [stack setAlignment:NSLayoutAttributeCenterY];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = stack;

  [self rebuildTagCloud:stack name:name tags:tags];
  [self addControlToLayout:stack];
  return stack;
}

- (void)rebuildTagCloud:(NSStackView *)stack name:(NSString *)name tags:(NSArray<NSString *> *)tags {
  for (NSView *v in [stack.arrangedSubviews copy]) {
    [stack removeArrangedSubview:v];
    [v removeFromSuperview];
  }

  for (NSString *tag in tags) {
    NSButton *btn = [NSButton buttonWithTitle:[NSString stringWithFormat:@"%@  ✕", tag] target:self action:@selector(handleTagClicked:)];
    [btn setBezelStyle:NSBezelStyleInline];
    [btn setFont:[NSFont systemFontOfSize:11.0 weight:NSFontWeightMedium]];
    btn.identifier = [NSString stringWithFormat:@"%@___%@", name, tag];
    [stack addArrangedSubview:btn];
  }
}

- (void)handleTagClicked:(id)sender {
  NSButton *btn = (NSButton *)sender;
  NSString *ident = btn.identifier;
  NSRange range = [ident rangeOfString:@"___"];
  if (range.location != NSNotFound) {
    NSString *name = [ident substringToIndex:range.location];
    NSString *tag = [ident substringFromIndex:range.location + 3];
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "click_tag", [tag UTF8String]);
  }
}

- (void)setTagCloudTags:(NSArray<NSString *> *)tags forName:(NSString *)name {
  NSStackView *stack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (stack) {
    [self rebuildTagCloud:stack name:name tags:tags];
  }
}

- (NSView *)makeWizardStepperWithName:(NSString *)name steps:(NSArray<NSString *> *)steps currentStep:(int)currentStep {
  NSStackView *stack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [stack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [stack setSpacing:12.0];
  [stack setAlignment:NSLayoutAttributeCenterY];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = stack;

  objc_setAssociatedObject(stack, "wizardSteps", steps, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(stack, "currentStep", @(currentStep), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self rebuildWizardStepper:stack name:name];
  [self addControlToLayout:stack];
  return stack;
}

- (void)rebuildWizardStepper:(NSStackView *)stack name:(NSString *)name {
  for (NSView *v in [stack.arrangedSubviews copy]) {
    [stack removeArrangedSubview:v];
    [v removeFromSuperview];
  }
  NSArray<NSString *> *steps = objc_getAssociatedObject(stack, "wizardSteps");
  int currentStep = [objc_getAssociatedObject(stack, "currentStep") intValue];

  for (int i = 0; i < steps.count; i++) {
    NSString *symbol = (i < currentStep) ? @"✓" : [NSString stringWithFormat:@"%d", i + 1];
    NSString *stepText = [NSString stringWithFormat:@"%@ %@", symbol, steps[i]];
    NSButton *btn = [NSButton buttonWithTitle:stepText target:self action:@selector(handleWizardStepClicked:)];
    [btn setBezelStyle:NSBezelStyleInline];
    [btn setFont:[NSFont systemFontOfSize:11.0 weight:(i == currentStep ? NSFontWeightBold : NSFontWeightRegular)]];
    btn.identifier = [NSString stringWithFormat:@"%@_%d", name, i];
    [stack addArrangedSubview:btn];

    if (i < steps.count - 1) {
      NSTextField *sep = [NSTextField labelWithString:@"→"];
      [sep setTextColor:[NSColor tertiaryLabelColor]];
      [stack addArrangedSubview:sep];
    }
  }
}

- (void)handleWizardStepClicked:(id)sender {
  NSButton *btn = (NSButton *)sender;
  NSString *ident = btn.identifier;
  NSRange range = [ident rangeOfString:@"_" options:NSBackwardsSearch];
  if (range.location != NSNotFound) {
    NSString *name = [ident substringToIndex:range.location];
    int stepIdx = [[ident substringFromIndex:range.location + 1] intValue];
    NSStackView *stack = (NSStackView *)self.controlsByName[[name lowercaseString]];
    if (stack) {
      objc_setAssociatedObject(stack, "currentStep", @(stepIdx), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
      [self rebuildWizardStepper:stack name:name];
      vlang_dispatch_event(self.win_ptr, [name UTF8String], "change_step", [[NSString stringWithFormat:@"%d", stepIdx] UTF8String]);
    }
  }
}

- (void)setWizardStepperStep:(int)step forName:(NSString *)name {
  NSStackView *stack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (stack) {
    objc_setAssociatedObject(stack, "currentStep", @(step), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self rebuildWizardStepper:stack name:name];
  }
}

- (NSView *)makeGaugeWithName:(NSString *)name title:(NSString *)title value:(int)val minVal:(int)minVal maxVal:(int)maxVal unit:(NSString *)unit {
  if (maxVal <= minVal) maxVal = minVal + 100;
  int currentVal = (val < minVal) ? minVal : ((val > maxVal) ? maxVal : val);
  NSString *unitStr = (unit && unit.length > 0) ? unit : @"%";

  NSBox *box = [[NSBox alloc] initWithFrame:NSZeroRect];
  [box setBoxType:NSBoxCustom];
  [box setBorderType:NSLineBorder];
  [box setCornerRadius:8.0];
  [box setBorderColor:[NSColor colorWithCalibratedWhite:0.75 alpha:0.4]];
  [box setFillColor:[NSColor colorWithCalibratedWhite:0.96 alpha:1.0]];

  NSStackView *vstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [vstack setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [vstack setSpacing:4.0];
  [vstack setEdgeInsets:NSEdgeInsetsMake(8, 12, 8, 12)];
  [vstack setAlignment:NSLayoutAttributeLeading];

  NSTextField *titleLbl = [NSTextField labelWithString:title ? title : @"Gauge"];
  [titleLbl setFont:[NSFont systemFontOfSize:12.0 weight:NSFontWeightBold]];
  [titleLbl setTextColor:[NSColor labelColor]];
  [vstack addArrangedSubview:titleLbl];

  NSStackView *hstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hstack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hstack setSpacing:10.0];
  [hstack setAlignment:NSLayoutAttributeCenterY];

  NSProgressIndicator *indicator = [[NSProgressIndicator alloc] initWithFrame:NSZeroRect];
  [indicator setIndeterminate:NO];
  [indicator setMinValue:(double)minVal];
  [indicator setMaxValue:(double)maxVal];
  [indicator setDoubleValue:(double)currentVal];
  [indicator setStyle:NSProgressIndicatorStyleBar];
  [indicator.widthAnchor constraintEqualToConstant:140].active = YES;
  [hstack addArrangedSubview:indicator];

  NSTextField *valLbl = [NSTextField labelWithString:[NSString stringWithFormat:@"%d %@", currentVal, unitStr]];
  [valLbl setFont:[NSFont systemFontOfSize:12.0 weight:NSFontWeightMedium]];
  [valLbl setTextColor:[NSColor secondaryLabelColor]];
  [hstack addArrangedSubview:valLbl];

  [vstack addArrangedSubview:hstack];
  [box setContentView:vstack];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = box;

  objc_setAssociatedObject(box, "gaugeValue", @(currentVal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(box, "gaugeMin", @(minVal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(box, "gaugeMax", @(maxVal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(box, "gaugeUnit", unitStr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(box, "gaugeIndicator", indicator, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(box, "gaugeValueLabel", valLbl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:box];
  return box;
}

- (void)setGaugeValue:(int)val forName:(NSString *)name {
  NSView *box = self.controlsByName[[name lowercaseString]];
  if (box) {
    int minVal = [objc_getAssociatedObject(box, "gaugeMin") intValue];
    int maxVal = [objc_getAssociatedObject(box, "gaugeMax") intValue];
    NSString *unitStr = objc_getAssociatedObject(box, "gaugeUnit");
    int currentVal = (val < minVal) ? minVal : ((val > maxVal) ? maxVal : val);

    NSProgressIndicator *indicator = objc_getAssociatedObject(box, "gaugeIndicator");
    NSTextField *valLbl = objc_getAssociatedObject(box, "gaugeValueLabel");

    if (indicator) [indicator setDoubleValue:(double)currentVal];
    if (valLbl) [valLbl setStringValue:[NSString stringWithFormat:@"%d %@", currentVal, unitStr ? unitStr : @"%"]];
    objc_setAssociatedObject(box, "gaugeValue", @(currentVal), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
}

- (int)gaugeValueForName:(NSString *)name {
  NSView *box = self.controlsByName[[name lowercaseString]];
  if (box) {
    return [objc_getAssociatedObject(box, "gaugeValue") intValue];
  }
  return 0;
}

- (NSView *)makePaginationWithName:(NSString *)name totalPages:(int)totalPages currentPage:(int)currentPage {
  if (totalPages <= 0) totalPages = 1;
  int page = (currentPage < 1) ? 1 : ((currentPage > totalPages) ? totalPages : currentPage);

  NSStackView *hstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hstack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hstack setSpacing:8.0];
  [hstack setAlignment:NSLayoutAttributeCenterY];

  NSButton *prevBtn = [NSButton buttonWithTitle:@"‹ Prev" target:self action:@selector(handlePaginationPrevClicked:)];
  [prevBtn setBezelStyle:NSBezelStyleRounded];
  prevBtn.identifier = [NSString stringWithFormat:@"%@_prev", name];
  [prevBtn setEnabled:(page > 1)];

  NSTextField *lbl = [NSTextField labelWithString:[NSString stringWithFormat:@"Page %d of %d", page, totalPages]];
  [lbl setFont:[NSFont systemFontOfSize:12.0 weight:NSFontWeightMedium]];

  NSButton *nextBtn = [NSButton buttonWithTitle:@"Next ›" target:self action:@selector(handlePaginationNextClicked:)];
  [nextBtn setBezelStyle:NSBezelStyleRounded];
  nextBtn.identifier = [NSString stringWithFormat:@"%@_next", name];
  [nextBtn setEnabled:(page < totalPages)];

  [hstack addArrangedSubview:prevBtn];
  [hstack addArrangedSubview:lbl];
  [hstack addArrangedSubview:nextBtn];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = hstack;

  objc_setAssociatedObject(hstack, "currentPage", @(page), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "totalPages", @(totalPages), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "prevButton", prevBtn, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "nextButton", nextBtn, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "pageLabel", lbl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:hstack];
  return hstack;
}

- (void)handlePaginationPrevClicked:(id)sender {
  NSButton *btn = (NSButton *)sender;
  NSString *ident = btn.identifier;
  NSRange range = [ident rangeOfString:@"_prev"];
  if (range.location != NSNotFound) {
    NSString *name = [ident substringToIndex:range.location];
    NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
    if (hstack) {
      int page = [objc_getAssociatedObject(hstack, "currentPage") intValue];
      int total = [objc_getAssociatedObject(hstack, "totalPages") intValue];
      if (page > 1) {
        page--;
        [self setPaginationPage:page totalPages:total forName:name];
        vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [[NSString stringWithFormat:@"%d", page] UTF8String]);
      }
    }
  }
}

- (void)handlePaginationNextClicked:(id)sender {
  NSButton *btn = (NSButton *)sender;
  NSString *ident = btn.identifier;
  NSRange range = [ident rangeOfString:@"_next"];
  if (range.location != NSNotFound) {
    NSString *name = [ident substringToIndex:range.location];
    NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
    if (hstack) {
      int page = [objc_getAssociatedObject(hstack, "currentPage") intValue];
      int total = [objc_getAssociatedObject(hstack, "totalPages") intValue];
      if (page < total) {
        page++;
        [self setPaginationPage:page totalPages:total forName:name];
        vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [[NSString stringWithFormat:@"%d", page] UTF8String]);
      }
    }
  }
}

- (void)setPaginationPage:(int)page totalPages:(int)totalPages forName:(NSString *)name {
  NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (hstack) {
    if (totalPages <= 0) totalPages = [objc_getAssociatedObject(hstack, "totalPages") intValue];
    if (totalPages <= 0) totalPages = 1;
    int resolvedPage = (page < 1) ? 1 : ((page > totalPages) ? totalPages : page);

    NSButton *prevBtn = objc_getAssociatedObject(hstack, "prevButton");
    NSButton *nextBtn = objc_getAssociatedObject(hstack, "nextButton");
    NSTextField *lbl = objc_getAssociatedObject(hstack, "pageLabel");

    if (prevBtn) [prevBtn setEnabled:(resolvedPage > 1)];
    if (nextBtn) [nextBtn setEnabled:(resolvedPage < totalPages)];
    if (lbl) [lbl setStringValue:[NSString stringWithFormat:@"Page %d of %d", resolvedPage, totalPages]];

    objc_setAssociatedObject(hstack, "currentPage", @(resolvedPage), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(hstack, "totalPages", @(totalPages), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  }
}

- (int)paginationPageForName:(NSString *)name {
  NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (hstack) {
    return [objc_getAssociatedObject(hstack, "currentPage") intValue];
  }
  return 1;
}

- (NSView *)makeActivityFeedWithName:(NSString *)name height:(int)h {
  if (h <= 0) h = 160;
  NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 300, h)];
  [scroll setHasVerticalScroller:YES];
  [scroll setHasHorizontalScroller:NO];
  [scroll setAutohidesScrollers:YES];
  [scroll setBorderType:NSBezelBorder];

  FlippedStackView *stack = [[FlippedStackView alloc] initWithFrame:NSMakeRect(0, 0, 300, h)];
  [stack setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [stack setSpacing:4.0];
  [stack setEdgeInsets:NSEdgeInsetsMake(6, 6, 6, 6)];
  [stack setAlignment:NSLayoutAttributeWidth];

  [scroll setDocumentView:stack];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = scroll;

  [self addControlToLayout:scroll];
  return scroll;
}

- (void)addActivityFeedItemToName:(NSString *)name timestamp:(NSString *)timestamp message:(NSString *)message level:(NSString *)level {
  NSScrollView *scroll = (NSScrollView *)self.controlsByName[[name lowercaseString]];
  if (scroll && [scroll isKindOfClass:[NSScrollView class]]) {
    FlippedStackView *stack = (FlippedStackView *)[scroll documentView];
    if ([stack isKindOfClass:[NSStackView class]]) {
      NSStackView *row = [[NSStackView alloc] initWithFrame:NSZeroRect];
      [row setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
      [row setSpacing:6.0];
      [row setAlignment:NSLayoutAttributeCenterY];

      NSString *lvlStr = level ? [level lowercaseString] : @"info";
      NSColor *badgeColor = [NSColor systemBlueColor];
      if ([lvlStr isEqualToString:@"success"]) badgeColor = [NSColor systemGreenColor];
      else if ([lvlStr isEqualToString:@"warning"]) badgeColor = [NSColor systemOrangeColor];
      else if ([lvlStr isEqualToString:@"error"]) badgeColor = [NSColor systemRedColor];

      NSBox *pill = [[NSBox alloc] initWithFrame:NSZeroRect];
      [pill setBoxType:NSBoxCustom];
      [pill setCornerRadius:4.0];
      [pill setBorderType:NSNoBorder];
      [pill setFillColor:badgeColor];
      [pill.widthAnchor constraintEqualToConstant:8].active = YES;
      [pill.heightAnchor constraintEqualToConstant:8].active = YES;

      NSTextField *timeLbl = [NSTextField labelWithString:timestamp ? timestamp : @""];
      [timeLbl setFont:[NSFont monospacedDigitSystemFontOfSize:11.0 weight:NSFontWeightRegular]];
      [timeLbl setTextColor:[NSColor secondaryLabelColor]];

      NSTextField *msgLbl = [NSTextField labelWithString:message ? message : @""];
      [msgLbl setFont:[NSFont systemFontOfSize:12.0 weight:NSFontWeightRegular]];
      [msgLbl setTextColor:[NSColor labelColor]];

      [row addArrangedSubview:pill];
      [row addArrangedSubview:timeLbl];
      [row addArrangedSubview:msgLbl];

      [stack addArrangedSubview:row];
    }
  }
}

- (void)clearActivityFeedName:(NSString *)name {
  NSScrollView *scroll = (NSScrollView *)self.controlsByName[[name lowercaseString]];
  if (scroll && [scroll isKindOfClass:[NSScrollView class]]) {
    FlippedStackView *stack = (FlippedStackView *)[scroll documentView];
    if ([stack isKindOfClass:[NSStackView class]]) {
      for (NSView *v in [stack.arrangedSubviews copy]) {
        [stack removeArrangedSubview:v];
        [v removeFromSuperview];
      }
    }
  }
}

- (NSView *)makeMarkdownViewWithName:(NSString *)name markdownText:(NSString *)markdownText height:(int)h {
  if (h <= 0) h = 180;
  NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 300, h)];
  [scroll setHasVerticalScroller:YES];
  [scroll setHasHorizontalScroller:NO];
  [scroll setAutohidesScrollers:YES];
  [scroll setBorderType:NSBezelBorder];

  NSTextView *tv = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 300, h)];
  [tv setEditable:NO];
  [tv setSelectable:YES];
  [tv setVerticallyResizable:YES];
  [tv setHorizontallyResizable:NO];
  [tv setAutoresizingMask:NSViewWidthSizable];

  [scroll setDocumentView:tv];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = scroll;

  [self setMarkdownViewText:markdownText forName:name];
  [self addControlToLayout:scroll];
  return scroll;
}

- (void)setMarkdownViewText:(NSString *)markdownText forName:(NSString *)name {
  NSScrollView *scroll = (NSScrollView *)self.controlsByName[[name lowercaseString]];
  if (scroll && [scroll isKindOfClass:[NSScrollView class]]) {
    NSTextView *tv = (NSTextView *)[scroll documentView];
    if ([tv isKindOfClass:[NSTextView class]]) {
      NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
      NSString *raw = markdownText ? markdownText : @"";
      NSArray *lines = [raw componentsSeparatedByString:@"\n"];

      for (NSUInteger i = 0; i < lines.count; i++) {
        NSString *line = lines[i];
        NSFont *font = [NSFont systemFontOfSize:13.0 weight:NSFontWeightRegular];
        NSColor *color = [NSColor labelColor];

        if ([line hasPrefix:@"# "]) {
          font = [NSFont systemFontOfSize:20.0 weight:NSFontWeightBold];
          line = [line substringFromIndex:2];
        } else if ([line hasPrefix:@"## "]) {
          font = [NSFont systemFontOfSize:16.0 weight:NSFontWeightBold];
          line = [line substringFromIndex:3];
        } else if ([line hasPrefix:@"### "]) {
          font = [NSFont systemFontOfSize:14.0 weight:NSFontWeightBold];
          line = [line substringFromIndex:4];
        } else if ([line hasPrefix:@"- "]) {
          line = [NSString stringWithFormat:@"  •  %@", [line substringFromIndex:2]];
        }

        NSDictionary *attrs = @{ NSFontAttributeName: font, NSForegroundColorAttributeName: color };
        NSAttributedString *lineAttr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", line] attributes:attrs];
        [attrStr appendAttributedString:lineAttr];
      }

      [[tv textStorage] setAttributedString:attrStr];
      objc_setAssociatedObject(scroll, "markdownRawText", raw, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
  }
}

- (NSString *)markdownViewTextForName:(NSString *)name {
  NSScrollView *scroll = (NSScrollView *)self.controlsByName[[name lowercaseString]];
  if (scroll && [scroll isKindOfClass:[NSScrollView class]]) {
    NSString *raw = objc_getAssociatedObject(scroll, "markdownRawText");
    if (raw) return raw;
  }
  return @"";
}

- (NSView *)makeSparklineWithName:(NSString *)name values:(NSArray<NSNumber *> *)values height:(int)h {
  if (h <= 0) h = 40;
  SparklineView *spark = [[SparklineView alloc] initWithFrame:NSMakeRect(0, 0, 200, h)];
  if (values) spark.values = values;

  [spark.heightAnchor constraintEqualToConstant:h].active = YES;

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = spark;

  [self addControlToLayout:spark];
  return spark;
}

- (void)setSparklineValues:(NSArray<NSNumber *> *)values forName:(NSString *)name {
  SparklineView *spark = (SparklineView *)self.controlsByName[[name lowercaseString]];
  if (spark && [spark isKindOfClass:[SparklineView class]]) {
    spark.values = values;
    [spark setNeedsDisplay:YES];
  }
}

- (NSView *)makePinCodeWithName:(NSString *)name digits:(int)digits {
  if (digits <= 0) digits = 4;
  if (digits > 8) digits = 8;

  NSStackView *hstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hstack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hstack setSpacing:6.0];
  [hstack setAlignment:NSLayoutAttributeCenterY];

  NSMutableArray *fields = [NSMutableArray arrayWithCapacity:digits];
  for (int i = 0; i < digits; i++) {
    ModernTextField *tf = [[ModernTextField alloc] initWithFrame:NSZeroRect];
    [tf setAlignment:NSTextAlignmentCenter];
    [tf setFont:[NSFont systemFontOfSize:18.0 weight:NSFontWeightBold]];
    [tf.widthAnchor constraintEqualToConstant:36].active = YES;
    [tf.heightAnchor constraintEqualToConstant:40].active = YES;
    tf.delegate = self;
    tf.identifier = [NSString stringWithFormat:@"%@_pin_%d", name, i];
    [hstack addArrangedSubview:tf];
    [fields addObject:tf];
  }

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = hstack;

  objc_setAssociatedObject(hstack, "pinFields", fields, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "pinName", name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:hstack];
  return hstack;
}

- (void)setPinCodeValue:(NSString *)code forName:(NSString *)name {
  NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (hstack) {
    NSArray *fields = objc_getAssociatedObject(hstack, "pinFields");
    if (fields) {
      NSString *clean = code ? code : @"";
      for (NSUInteger i = 0; i < fields.count; i++) {
        ModernTextField *tf = fields[i];
        if (i < clean.length) {
          [tf setStringValue:[clean substringWithRange:NSMakeRange(i, 1)]];
        } else {
          [tf setStringValue:@""];
        }
      }
    }
  }
}

- (NSString *)pinCodeValueForName:(NSString *)name {
  NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (hstack) {
    NSArray *fields = objc_getAssociatedObject(hstack, "pinFields");
    if (fields) {
      NSMutableString *res = [NSMutableString string];
      for (ModernTextField *tf in fields) {
        [res appendString:[tf stringValue]];
      }
      return res;
    }
  }
  return @"";
}

- (NSView *)makeColorPaletteWithName:(NSString *)name colors:(NSArray<NSString *> *)colors selected:(NSString *)selected {
  NSStackView *hstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hstack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hstack setSpacing:6.0];
  [hstack setAlignment:NSLayoutAttributeCenterY];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = hstack;

  objc_setAssociatedObject(hstack, "paletteColors", colors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "paletteSelected", selected ? selected : (colors.count > 0 ? colors[0] : @"#000000"), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self rebuildColorPaletteStack:hstack name:name];
  [self addControlToLayout:hstack];
  return hstack;
}

- (void)rebuildColorPaletteStack:(NSStackView *)stack name:(NSString *)name {
  for (NSView *v in [stack.arrangedSubviews copy]) {
    [stack removeArrangedSubview:v];
    [v removeFromSuperview];
  }
  NSArray *colors = objc_getAssociatedObject(stack, "paletteColors");
  NSString *selHex = objc_getAssociatedObject(stack, "paletteSelected");

  for (NSUInteger i = 0; i < colors.count; i++) {
    NSString *hex = colors[i];
    NSColor *c = colorFromHexString(hex);
    BOOL isSel = [hex caseInsensitiveCompare:selHex] == NSOrderedSame;


    NSBox *swatch = [[NSBox alloc] initWithFrame:NSZeroRect];
    [swatch setBoxType:NSBoxCustom];
    [swatch setCornerRadius:12.0];
    [swatch setBorderType:isSel ? NSLineBorder : NSNoBorder];
    [swatch setBorderColor:[NSColor labelColor]];
    [swatch setFillColor:c];
    [swatch.widthAnchor constraintEqualToConstant:24].active = YES;
    [swatch.heightAnchor constraintEqualToConstant:24].active = YES;

    NSButton *btn = [NSButton buttonWithTitle:@"" target:self action:@selector(handleColorPaletteClicked:)];
    [btn setTransparent:YES];
    btn.identifier = [NSString stringWithFormat:@"%@_pal_%@", name, hex];
    [swatch addSubview:btn];
    btn.frame = NSMakeRect(0, 0, 24, 24);

    [stack addArrangedSubview:swatch];
  }
}

- (void)handleColorPaletteClicked:(id)sender {
  NSButton *btn = (NSButton *)sender;
  NSString *ident = btn.identifier;
  NSRange range = [ident rangeOfString:@"_pal_"];
  if (range.location != NSNotFound) {
    NSString *name = [ident substringToIndex:range.location];
    NSString *hex = [ident substringFromIndex:range.location + 5];
    NSStackView *stack = (NSStackView *)self.controlsByName[[name lowercaseString]];
    if (stack) {
      objc_setAssociatedObject(stack, "paletteSelected", hex, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
      [self rebuildColorPaletteStack:stack name:name];
      vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [hex UTF8String]);
    }
  }
}

- (void)setColorPaletteSelected:(NSString *)hex forName:(NSString *)name {
  NSStackView *stack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (stack) {
    objc_setAssociatedObject(stack, "paletteSelected", hex ? hex : @"", OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self rebuildColorPaletteStack:stack name:name];
  }
}

- (NSString *)colorPaletteSelectedForName:(NSString *)name {
  NSStackView *stack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (stack) {
    return objc_getAssociatedObject(stack, "paletteSelected");
  }
  return @"";
}

// 1. Timeline / Milestone Flow Control
- (NSView *)makeTimelineWithName:(NSString *)name height:(int)height {
  NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 300, height > 0 ? height : 180)];
  [scroll setHasVerticalScroller:YES];
  [scroll setHasHorizontalScroller:NO];
  [scroll setBorderType:NSLineBorder];
  [scroll setDrawsBackground:NO];

  NSStackView *stack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [stack setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [stack setAlignment:NSLayoutAttributeLeading];
  [stack setSpacing:10.0];
  [stack setEdgeInsets:NSEdgeInsetsMake(8, 12, 8, 12)];

  [scroll setDocumentView:stack];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = scroll;
  objc_setAssociatedObject(scroll, "timelineStack", stack, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:scroll];
  return scroll;
}

- (void)addTimelineItemToName:(NSString *)name title:(NSString *)title subtitle:(NSString *)subtitle timeStr:(NSString *)timeStr status:(NSString *)status {
  NSScrollView *scroll = (NSScrollView *)self.controlsByName[[name lowercaseString]];
  if (scroll) {
    NSStackView *stack = objc_getAssociatedObject(scroll, "timelineStack");
    if (stack) {
      NSBox *card = [[NSBox alloc] initWithFrame:NSZeroRect];
      [card setBoxType:NSBoxCustom];
      [card setCornerRadius:6.0];
      [card setFillColor:[NSColor colorWithWhite:1.0 alpha:0.04]];
      [card setBorderColor:[NSColor colorWithWhite:1.0 alpha:0.1]];

      NSStackView *row = [[NSStackView alloc] initWithFrame:NSZeroRect];
      [row setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
      [row setAlignment:NSLayoutAttributeCenterY];
      [row setSpacing:8.0];
      [row setEdgeInsets:NSEdgeInsetsMake(6, 8, 6, 8)];

      // Status indicator dot
      NSBox *dot = [[NSBox alloc] initWithFrame:NSMakeRect(0, 0, 10, 10)];
      [dot setBoxType:NSBoxCustom];
      [dot setCornerRadius:5.0];
      NSString *normSt = [status lowercaseString];
      if ([normSt containsString:@"success"] || [normSt containsString:@"done"] || [normSt containsString:@"complete"]) {
        [dot setFillColor:[NSColor systemGreenColor]];
      } else if ([normSt containsString:@"warn"] || [normSt containsString:@"prog"]) {
        [dot setFillColor:[NSColor systemOrangeColor]];
      } else if ([normSt containsString:@"err"] || [normSt containsString:@"fail"]) {
        [dot setFillColor:[NSColor systemRedColor]];
      } else {
        [dot setFillColor:[NSColor systemBlueColor]];
      }
      [dot setBorderColor:[NSColor clearColor]];
      [row addArrangedSubview:dot];

      NSStackView *textCol = [[NSStackView alloc] initWithFrame:NSZeroRect];
      [textCol setOrientation:NSUserInterfaceLayoutOrientationVertical];
      [textCol setAlignment:NSLayoutAttributeLeading];
      [textCol setSpacing:2.0];

      NSTextField *titleLbl = [NSTextField labelWithString:title ? title : @""];
      [titleLbl setFont:[NSFont boldSystemFontOfSize:12.0]];
      [textCol addArrangedSubview:titleLbl];

      if (subtitle && subtitle.length > 0) {
        NSTextField *subLbl = [NSTextField labelWithString:subtitle];
        [subLbl setFont:[NSFont systemFontOfSize:11.0]];
        [subLbl setTextColor:[NSColor secondaryLabelColor]];
        [textCol addArrangedSubview:subLbl];
      }
      [row addArrangedSubview:textCol];

      if (timeStr && timeStr.length > 0) {
        NSTextField *timeLbl = [NSTextField labelWithString:timeStr];
        [timeLbl setFont:[NSFont systemFontOfSize:10.0]];
        [timeLbl setTextColor:[NSColor tertiaryLabelColor]];
        [row addArrangedSubview:timeLbl];
      }

      [card setContentView:row];
      [stack addArrangedSubview:card];
    }
  }
}

// 2. Metric / KPI Card Control

- (NSView *)makeMetricCardWithName:(NSString *)name title:(NSString *)title value:(NSString *)value changeBadge:(NSString *)changeBadge subtitle:(NSString *)subtitle {
  NSBox *card = [[NSBox alloc] initWithFrame:NSZeroRect];
  [card setBoxType:NSBoxCustom];
  [card setCornerRadius:10.0];
  [card setFillColor:[NSColor colorWithWhite:1.0 alpha:0.05]];
  [card setBorderColor:[NSColor colorWithWhite:1.0 alpha:0.12]];

  NSStackView *col = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [col setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [col setAlignment:NSLayoutAttributeLeading];
  [col setSpacing:4.0];
  [col setEdgeInsets:NSEdgeInsetsMake(10, 12, 10, 12)];

  NSTextField *tLbl = [NSTextField labelWithString:title ? title : @""];
  [tLbl setFont:[NSFont systemFontOfSize:11.0 weight:NSFontWeightMedium]];
  [tLbl setTextColor:[NSColor secondaryLabelColor]];
  [col addArrangedSubview:tLbl];

  NSStackView *valRow = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [valRow setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [valRow setAlignment:NSLayoutAttributeFirstBaseline];
  [valRow setSpacing:8.0];

  NSTextField *vLbl = [NSTextField labelWithString:value ? value : @"0"];
  [vLbl setFont:[NSFont systemFontOfSize:22.0 weight:NSFontWeightBold]];
  [valRow addArrangedSubview:vLbl];

  if (changeBadge && changeBadge.length > 0) {
    NSTextField *bLbl = [NSTextField labelWithString:changeBadge];
    [bLbl setFont:[NSFont boldSystemFontOfSize:11.0]];
    if ([changeBadge hasPrefix:@"+"]) {
      [bLbl setTextColor:[NSColor systemGreenColor]];
    } else if ([changeBadge hasPrefix:@"-"]) {
      [bLbl setTextColor:[NSColor systemRedColor]];
    } else {
      [bLbl setTextColor:[NSColor secondaryLabelColor]];
    }
    [valRow addArrangedSubview:bLbl];
  }
  [col addArrangedSubview:valRow];

  if (subtitle && subtitle.length > 0) {
    NSTextField *sLbl = [NSTextField labelWithString:subtitle];
    [sLbl setFont:[NSFont systemFontOfSize:10.0]];
    [sLbl setTextColor:[NSColor tertiaryLabelColor]];
    [col addArrangedSubview:sLbl];
  }

  [card setContentView:col];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = card;
  objc_setAssociatedObject(card, "metricValLabel", vLbl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:card];
  return card;
}

- (void)setMetricCardValue:(NSString *)value changeBadge:(NSString *)changeBadge forName:(NSString *)name {
  NSBox *card = (NSBox *)self.controlsByName[[name lowercaseString]];
  if (card) {
    NSTextField *vLbl = objc_getAssociatedObject(card, "metricValLabel");
    if (vLbl) {
      [vLbl setStringValue:value ? value : @""];
    }
  }
}

// 3. Tab Pills Control
- (NSView *)makeTabPillsWithName:(NSString *)name items:(NSArray<NSString *> *)items selected:(NSString *)selected {
  NSSegmentedControl *seg = [NSSegmentedControl segmentedControlWithLabels:items trackingMode:NSSegmentSwitchTrackingSelectOne target:self action:@selector(handleTabPillClicked:)];
  [seg setSegmentStyle:NSSegmentStyleCapsule];
  seg.identifier = name;

  NSString *sel = selected ? selected : (items.count > 0 ? items[0] : @"");
  NSUInteger idx = [items indexOfObject:sel];
  if (idx != NSNotFound) {
    [seg setSelectedSegment:idx];
  }

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = seg;
  objc_setAssociatedObject(seg, "tabItems", items, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:seg];
  return seg;
}

- (void)handleTabPillClicked:(id)sender {
  NSSegmentedControl *seg = (NSSegmentedControl *)sender;
  NSString *name = seg.identifier;
  NSInteger selIdx = [seg selectedSegment];
  NSArray *items = objc_getAssociatedObject(seg, "tabItems");
  if (items && selIdx >= 0 && selIdx < items.count) {
    NSString *val = items[selIdx];
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [val UTF8String]);
  }
}

- (void)setTabPillsActive:(NSString *)selected forName:(NSString *)name {
  NSSegmentedControl *seg = (NSSegmentedControl *)self.controlsByName[[name lowercaseString]];
  if (seg) {
    NSArray *items = objc_getAssociatedObject(seg, "tabItems");
    if (items && selected) {
      NSUInteger idx = [items indexOfObject:selected];
      if (idx != NSNotFound) {
        [seg setSelectedSegment:idx];
      }
    }
  }
}

- (NSString *)tabPillsActiveForName:(NSString *)name {
  NSSegmentedControl *seg = (NSSegmentedControl *)self.controlsByName[[name lowercaseString]];
  if (seg) {
    NSInteger selIdx = [seg selectedSegment];
    NSArray *items = objc_getAssociatedObject(seg, "tabItems");
    if (items && selIdx >= 0 && selIdx < items.count) {
      return items[selIdx];
    }
  }
  return @"";
}

// 4. Transfer List Control
- (NSView *)makeTransferListWithName:(NSString *)name available:(NSArray<NSString *> *)available selected:(NSArray<NSString *> *)selected multiSelect:(BOOL)multiSelect {
  NSStackView *hstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hstack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hstack setAlignment:NSLayoutAttributeCenterY];
  [hstack setSpacing:10.0];

  // Left Column (Available)
  NSStackView *leftCol = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [leftCol setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [leftCol setAlignment:NSLayoutAttributeLeading];
  [leftCol setSpacing:4.0];

  NSTextField *leftHeader = [NSTextField labelWithString:@"Available (0)"];
  [leftHeader setFont:[NSFont boldSystemFontOfSize:11.0]];
  [leftHeader setTextColor:[NSColor secondaryLabelColor]];
  [leftCol addArrangedSubview:leftHeader];

  NSScrollView *leftScroll = [[NSScrollView alloc] initWithFrame:NSZeroRect];
  leftScroll.translatesAutoresizingMaskIntoConstraints = NO;
  [leftScroll setHasVerticalScroller:YES];
  [leftScroll setBorderType:NSLineBorder];
  [leftScroll.widthAnchor constraintEqualToConstant:130.0].active = YES;
  [leftScroll.heightAnchor constraintEqualToConstant:120.0].active = YES;
  [leftCol addArrangedSubview:leftScroll];

  // Buttons Column
  NSStackView *btnCol = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [btnCol setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [btnCol setSpacing:6.0];

  NSButton *btnAdd = [NSButton buttonWithTitle:@">" target:self action:@selector(handleTransferAddClicked:)];
  btnAdd.identifier = name;
  [btnAdd setBezelStyle:NSBezelStyleRounded];

  NSButton *btnRemove = [NSButton buttonWithTitle:@"<" target:self action:@selector(handleTransferRemoveClicked:)];
  btnRemove.identifier = name;
  [btnRemove setBezelStyle:NSBezelStyleRounded];

  [btnCol addArrangedSubview:btnAdd];
  [btnCol addArrangedSubview:btnRemove];

  // Right Column (Selected)
  NSStackView *rightCol = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [rightCol setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [rightCol setAlignment:NSLayoutAttributeLeading];
  [rightCol setSpacing:4.0];

  NSTextField *rightHeader = [NSTextField labelWithString:@"Selected (0)"];
  [rightHeader setFont:[NSFont boldSystemFontOfSize:11.0]];
  [rightHeader setTextColor:[NSColor secondaryLabelColor]];
  [rightCol addArrangedSubview:rightHeader];

  NSScrollView *rightScroll = [[NSScrollView alloc] initWithFrame:NSZeroRect];
  rightScroll.translatesAutoresizingMaskIntoConstraints = NO;
  [rightScroll setHasVerticalScroller:YES];
  [rightScroll setBorderType:NSLineBorder];
  [rightScroll.widthAnchor constraintEqualToConstant:130.0].active = YES;
  [rightScroll.heightAnchor constraintEqualToConstant:120.0].active = YES;
  [rightCol addArrangedSubview:rightScroll];

  [hstack addArrangedSubview:leftCol];
  [hstack addArrangedSubview:btnCol];
  [hstack addArrangedSubview:rightCol];

  NSMutableArray *availArr = [NSMutableArray arrayWithArray:available ? available : @[]];
  NSMutableArray *selArr = [NSMutableArray arrayWithArray:selected ? selected : @[]];

  objc_setAssociatedObject(hstack, "transferAvail", availArr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "transferSel", selArr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "leftScroll", leftScroll, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "rightScroll", rightScroll, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "leftHeader", leftHeader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "rightHeader", rightHeader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "transferMultiSelect", @(multiSelect), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "selectedAvailSet", [NSMutableSet set], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "selectedSelSet", [NSMutableSet set], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = hstack;

  [self rebuildTransferList:hstack name:name];
  [self addControlToLayout:hstack];
  return hstack;
}

- (void)rebuildTransferList:(NSStackView *)hstack name:(NSString *)name {
  NSScrollView *leftScroll = objc_getAssociatedObject(hstack, "leftScroll");
  NSScrollView *rightScroll = objc_getAssociatedObject(hstack, "rightScroll");
  NSTextField *leftHeader = objc_getAssociatedObject(hstack, "leftHeader");
  NSTextField *rightHeader = objc_getAssociatedObject(hstack, "rightHeader");
  NSMutableArray *availArr = objc_getAssociatedObject(hstack, "transferAvail");
  NSMutableArray *selArr = objc_getAssociatedObject(hstack, "transferSel");
  NSMutableSet *availSet = objc_getAssociatedObject(hstack, "selectedAvailSet");
  NSMutableSet *selSet = objc_getAssociatedObject(hstack, "selectedSelSet");

  if (leftHeader && availArr) {
    [leftHeader setStringValue:[NSString stringWithFormat:@"Available (%lu)", (unsigned long)availArr.count]];
  }

  if (rightHeader && selArr) {
    [rightHeader setStringValue:[NSString stringWithFormat:@"Selected (%lu)", (unsigned long)selArr.count]];
  }

  if (leftScroll && availArr) {
    CGFloat docH = MAX(120.0, availArr.count * 24.0 + 8.0);
    FlippedView *leftDoc = [[FlippedView alloc] initWithFrame:NSMakeRect(0, 0, 128.0, docH)];
    for (NSUInteger i = 0; i < availArr.count; i++) {
      NSButton *itemBtn = [NSButton buttonWithTitle:[NSString stringWithFormat:@"• %@", availArr[i]] target:self action:@selector(handleTransferItemClicked:)];
      itemBtn.identifier = [NSString stringWithFormat:@"%@_avail_%lu", name, (unsigned long)i];
      [itemBtn setBezelStyle:NSBezelStyleInline];
      [itemBtn setBordered:NO];
      [itemBtn setFrame:NSMakeRect(4.0, i * 24.0 + 4.0, 120.0, 20.0)];

      NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"• %@", availArr[i]]];
      if (availSet && [availSet containsObject:@(i)]) {
        [attr addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0] range:NSMakeRange(0, attr.length)];
        [attr addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:11.0] range:NSMakeRange(0, attr.length)];
      } else {
        [attr addAttribute:NSForegroundColorAttributeName value:[NSColor labelColor] range:NSMakeRange(0, attr.length)];
        [attr addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:11.0] range:NSMakeRange(0, attr.length)];
      }
      [itemBtn setAttributedTitle:attr];
      [leftDoc addSubview:itemBtn];
    }
    [leftScroll setDocumentView:leftDoc];
  }

  if (rightScroll && selArr) {
    CGFloat docH = MAX(120.0, selArr.count * 24.0 + 8.0);
    FlippedView *rightDoc = [[FlippedView alloc] initWithFrame:NSMakeRect(0, 0, 128.0, docH)];
    for (NSUInteger i = 0; i < selArr.count; i++) {
      NSButton *itemBtn = [NSButton buttonWithTitle:[NSString stringWithFormat:@"✓ %@", selArr[i]] target:self action:@selector(handleTransferItemClicked:)];
      itemBtn.identifier = [NSString stringWithFormat:@"%@_sel_%lu", name, (unsigned long)i];
      [itemBtn setBezelStyle:NSBezelStyleInline];
      [itemBtn setBordered:NO];
      [itemBtn setFrame:NSMakeRect(4.0, i * 24.0 + 4.0, 120.0, 20.0)];

      NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"✓ %@", selArr[i]]];
      if (selSet && [selSet containsObject:@(i)]) {
        [attr addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0] range:NSMakeRange(0, attr.length)];
        [attr addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:11.0] range:NSMakeRange(0, attr.length)];
      } else {
        [attr addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:0.2 green:0.8 blue:0.4 alpha:1.0] range:NSMakeRange(0, attr.length)];
        [attr addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:11.0] range:NSMakeRange(0, attr.length)];
      }
      [itemBtn setAttributedTitle:attr];
      [rightDoc addSubview:itemBtn];
    }
    [rightScroll setDocumentView:rightDoc];
  }

  [leftScroll setNeedsDisplay:YES];
  [rightScroll setNeedsDisplay:YES];
  [hstack setNeedsDisplay:YES];
}

- (void)handleTransferItemClicked:(id)sender {
  NSButton *btn = (NSButton *)sender;
  NSString *ident = btn.identifier;

  NSRange availRange = [ident rangeOfString:@"_avail_"];
  NSRange selRange = [ident rangeOfString:@"_sel_"];

  if (availRange.location != NSNotFound) {
    NSString *name = [ident substringToIndex:availRange.location];
    NSUInteger idx = [[ident substringFromIndex:availRange.location + availRange.length] integerValue];
    NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
    if (hstack) {
      BOOL multi = [objc_getAssociatedObject(hstack, "transferMultiSelect") boolValue];
      NSMutableSet *availSet = objc_getAssociatedObject(hstack, "selectedAvailSet");
      NSMutableSet *selSet = objc_getAssociatedObject(hstack, "selectedSelSet");
      [selSet removeAllObjects];

      NSNumber *num = @(idx);
      if (multi) {
        if ([availSet containsObject:num]) {
          [availSet removeObject:num];
        } else {
          [availSet addObject:num];
        }
      } else {
        [availSet removeAllObjects];
        [availSet addObject:num];
      }
      [self rebuildTransferList:hstack name:name];
    }
  } else if (selRange.location != NSNotFound) {
    NSString *name = [ident substringToIndex:selRange.location];
    NSUInteger idx = [[ident substringFromIndex:selRange.location + selRange.length] integerValue];
    NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
    if (hstack) {
      BOOL multi = [objc_getAssociatedObject(hstack, "transferMultiSelect") boolValue];
      NSMutableSet *availSet = objc_getAssociatedObject(hstack, "selectedAvailSet");
      NSMutableSet *selSet = objc_getAssociatedObject(hstack, "selectedSelSet");
      [availSet removeAllObjects];

      NSNumber *num = @(idx);
      if (multi) {
        if ([selSet containsObject:num]) {
          [selSet removeObject:num];
        } else {
          [selSet addObject:num];
        }
      } else {
        [selSet removeAllObjects];
        [selSet addObject:num];
      }
      [self rebuildTransferList:hstack name:name];
    }
  }
}

- (void)handleTransferAddClicked:(id)sender {
  NSButton *btn = (NSButton *)sender;
  NSString *name = btn.identifier;
  NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (hstack) {
    NSMutableArray *availArr = objc_getAssociatedObject(hstack, "transferAvail");
    NSMutableArray *selArr = objc_getAssociatedObject(hstack, "transferSel");
    NSMutableSet *availSet = objc_getAssociatedObject(hstack, "selectedAvailSet");

    if (availSet.count > 0) {
      NSArray *sorted = [[availSet allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj2 compare:obj1]; // Descending
      }];
      NSMutableArray *movedItems = [NSMutableArray array];
      for (NSNumber *num in sorted) {
        NSUInteger idx = [num unsignedIntegerValue];
        if (idx < availArr.count) {
          NSString *item = availArr[idx];
          [movedItems addObject:item];
          [availArr removeObjectAtIndex:idx];
        }
      }
      for (NSString *item in [movedItems reverseObjectEnumerator]) {
        [selArr addObject:item];
      }
      [availSet removeAllObjects];
      [self rebuildTransferList:hstack name:name];
      vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [[movedItems componentsJoinedByString:@", "] UTF8String]);
    } else if (availArr.count > 0) {
      NSString *item = availArr[0];
      [availArr removeObjectAtIndex:0];
      [selArr addObject:item];
      [self rebuildTransferList:hstack name:name];
      vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [item UTF8String]);
    }
  }
}

- (void)handleTransferRemoveClicked:(id)sender {
  NSButton *btn = (NSButton *)sender;
  NSString *name = btn.identifier;
  NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (hstack) {
    NSMutableArray *availArr = objc_getAssociatedObject(hstack, "transferAvail");
    NSMutableArray *selArr = objc_getAssociatedObject(hstack, "transferSel");
    NSMutableSet *selSet = objc_getAssociatedObject(hstack, "selectedSelSet");

    if (selSet.count > 0) {
      NSArray *sorted = [[selSet allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj2 compare:obj1]; // Descending
      }];
      NSMutableArray *movedItems = [NSMutableArray array];
      for (NSNumber *num in sorted) {
        NSUInteger idx = [num unsignedIntegerValue];
        if (idx < selArr.count) {
          NSString *item = selArr[idx];
          [movedItems addObject:item];
          [selArr removeObjectAtIndex:idx];
        }
      }
      for (NSString *item in [movedItems reverseObjectEnumerator]) {
        [availArr addObject:item];
      }
      [selSet removeAllObjects];
      [self rebuildTransferList:hstack name:name];
      vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [[movedItems componentsJoinedByString:@", "] UTF8String]);
    } else if (selArr.count > 0) {
      NSString *item = selArr[selArr.count - 1];
      [selArr removeLastObject];
      [availArr addObject:item];
      [self rebuildTransferList:hstack name:name];
      vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [item UTF8String]);
    }
  }
}




- (NSArray<NSString *> *)transferListSelectedForName:(NSString *)name {
  NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (hstack) {
    return objc_getAssociatedObject(hstack, "transferSel");
  }
  return @[];
}

// 5. Audio Waveform Control
- (NSView *)makeAudioWaveformWithName:(NSString *)name amplitudes:(NSArray<NSNumber *> *)amplitudes height:(int)height {
  int h = height > 0 ? height : 50;
  AudioWaveformView *wave = [[AudioWaveformView alloc] initWithFrame:NSMakeRect(0, 0, 320, h)];
  wave.identifier = name;
  wave.translatesAutoresizingMaskIntoConstraints = NO;
  [wave.widthAnchor constraintGreaterThanOrEqualToConstant:280.0].active = YES;
  [wave.heightAnchor constraintEqualToConstant:(CGFloat)h].active = YES;

  if (amplitudes) {
    wave.amplitudes = amplitudes;
  }

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = wave;

  [self addControlToLayout:wave];
  return wave;
}


- (void)setAudioWaveformAmplitudes:(NSArray<NSNumber *> *)amplitudes forName:(NSString *)name {
  AudioWaveformView *wave = (AudioWaveformView *)self.controlsByName[[name lowercaseString]];
  if (wave && [wave isKindOfClass:[AudioWaveformView class]]) {
    wave.amplitudes = amplitudes;
    [wave setNeedsDisplay:YES];
  }
}

// 6. Rating Breakdown Control
- (NSView *)makeRatingBreakdownWithName:(NSString *)name avgScore:(double)avgScore totalReviews:(int)totalReviews starPercentages:(NSArray<NSNumber *> *)starPercentages {
  NSStackView *hstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hstack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hstack setAlignment:NSLayoutAttributeCenterY];
  [hstack setSpacing:14.0];

  // Score Box
  NSStackView *scoreCol = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [scoreCol setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [scoreCol setAlignment:NSLayoutAttributeCenterX];
  [scoreCol setSpacing:2.0];

  NSTextField *scoreLbl = [NSTextField labelWithString:[NSString stringWithFormat:@"%.1f", avgScore]];
  [scoreLbl setFont:[NSFont systemFontOfSize:28.0 weight:NSFontWeightBold]];
  [scoreCol addArrangedSubview:scoreLbl];

  NSTextField *revLbl = [NSTextField labelWithString:[NSString stringWithFormat:@"%d reviews", totalReviews]];
  [revLbl setFont:[NSFont systemFontOfSize:10.0]];
  [revLbl setTextColor:[NSColor secondaryLabelColor]];
  [scoreCol addArrangedSubview:revLbl];

  [hstack addArrangedSubview:scoreCol];

  // Bars Column
  NSStackView *barsCol = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [barsCol setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [barsCol setAlignment:NSLayoutAttributeLeading];
  [barsCol setSpacing:4.0];

  NSMutableArray<StarBarView *> *barArr = [NSMutableArray arrayWithCapacity:5];
  NSMutableArray<NSButton *> *starButtons = [NSMutableArray arrayWithCapacity:5];

  for (int s = 5; s >= 1; s--) {
    NSButton *starBtn = [NSButton buttonWithTitle:[NSString stringWithFormat:@"%d★", s] target:self action:@selector(handleStarRowClicked:)];
    starBtn.identifier = [NSString stringWithFormat:@"%@_star_%d", name, s];
    [starBtn setBezelStyle:NSBezelStyleInline];
    [starBtn setBordered:NO];
    [starButtons addObject:starBtn];

    StarBarView *bar = [[StarBarView alloc] initWithFrame:NSMakeRect(0, 0, 100, 10)];
    int idx = 5 - s;
    double pct = (starPercentages && idx < starPercentages.count) ? [starPercentages[idx] doubleValue] : 0.0;
    bar.percentage = pct;
    [barArr addObject:bar];

    NSStackView *starRow = [[NSStackView alloc] initWithFrame:NSZeroRect];
    [starRow setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
    [starRow setAlignment:NSLayoutAttributeCenterY];
    [starRow setSpacing:6.0];
    [starRow addArrangedSubview:starBtn];
    [starRow addArrangedSubview:bar];

    [barsCol addArrangedSubview:starRow];
  }
  [hstack addArrangedSubview:barsCol];

  objc_setAssociatedObject(hstack, "scoreLabel", scoreLbl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "reviewLabel", revLbl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "barArray", barArr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "starButtons", starButtons, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = hstack;

  [self addControlToLayout:hstack];
  return hstack;
}

- (void)handleStarRowClicked:(id)sender {
  NSButton *btn = (NSButton *)sender;
  NSString *ident = btn.identifier;
  NSRange range = [ident rangeOfString:@"_star_"];
  if (range.location != NSNotFound) {
    NSString *name = [ident substringToIndex:range.location];
    NSString *starNum = [ident substringFromIndex:range.location + range.length];
    int starVal = [starNum intValue];

    NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
    if (hstack) {
      NSArray<NSButton *> *starButtons = objc_getAssociatedObject(hstack, "starButtons");
      NSArray<StarBarView *> *barArr = objc_getAssociatedObject(hstack, "barArray");
      for (int s = 5; s >= 1; s--) {
        int idx = 5 - s;
        if (idx < starButtons.count && idx < barArr.count) {
          BOOL sel = (s <= starVal);
          NSButton *sb = starButtons[idx];
          StarBarView *bar = barArr[idx];
          bar.isSelected = sel;
          [bar setNeedsDisplay:YES];
          if (sel) {
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d★", s]];
            [attr addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:1.0 green:0.8 blue:0.1 alpha:1.0] range:NSMakeRange(0, attr.length)];
            [attr addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:12.0] range:NSMakeRange(0, attr.length)];
            [sb setAttributedTitle:attr];
          } else {
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d★", s]];
            [attr addAttribute:NSForegroundColorAttributeName value:[NSColor secondaryLabelColor] range:NSMakeRange(0, attr.length)];
            [attr addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:11.0] range:NSMakeRange(0, attr.length)];
            [sb setAttributedTitle:attr];
          }
        }
      }
    }


    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [starNum UTF8String]);
  }
}

- (void)setRatingBreakdownData:(double)avgScore totalReviews:(int)totalReviews starPercentages:(NSArray<NSNumber *> *)starPercentages forName:(NSString *)name {
  NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (hstack) {
    NSTextField *scoreLbl = objc_getAssociatedObject(hstack, "scoreLabel");
    if (scoreLbl) {
      [scoreLbl setStringValue:[NSString stringWithFormat:@"%.1f", avgScore]];
    }
    NSTextField *revLbl = objc_getAssociatedObject(hstack, "reviewLabel");
    if (revLbl) {
      [revLbl setStringValue:[NSString stringWithFormat:@"%d reviews", totalReviews]];
    }
    NSArray<StarBarView *> *barArr = objc_getAssociatedObject(hstack, "barArray");
    if (barArr && starPercentages) {
      for (int s = 5; s >= 1; s--) {
        int idx = 5 - s;
        if (idx < barArr.count && idx < starPercentages.count) {
          barArr[idx].percentage = [starPercentages[idx] doubleValue];
          [barArr[idx] setNeedsDisplay:YES];
        }
      }
    }
    [hstack setNeedsDisplay:YES];
  }
}



// 7. Code View Control
- (NSView *)makeCodeViewWithName:(NSString *)name lang:(NSString *)lang codeText:(NSString *)codeText height:(int)height {
  NSBox *container = [[NSBox alloc] initWithFrame:NSZeroRect];
  [container setBoxType:NSBoxCustom];
  [container setCornerRadius:8.0];
  [container setFillColor:[NSColor colorWithRed:0.1 green:0.1 blue:0.12 alpha:1.0]];
  [container setBorderColor:[NSColor colorWithWhite:1.0 alpha:0.15]];

  NSStackView *vcol = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [vcol setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [vcol setAlignment:NSLayoutAttributeLeading];
  [vcol setSpacing:4.0];
  [vcol setEdgeInsets:NSEdgeInsetsMake(6, 8, 6, 8)];

  // Header tag row
  NSStackView *hdr = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hdr setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hdr setAlignment:NSLayoutAttributeCenterY];
  [hdr setSpacing:8.0];

  NSTextField *tagLbl = [NSTextField labelWithString:lang ? [lang uppercaseString] : @"CODE"];
  [tagLbl setFont:[NSFont boldSystemFontOfSize:10.0]];
  [tagLbl setTextColor:[NSColor systemBlueColor]];
  [hdr addArrangedSubview:tagLbl];

  [vcol addArrangedSubview:hdr];

  // Code Text ScrollView
  NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(0, 0, 360, height > 0 ? height : 140)];
  [scroll setHasVerticalScroller:YES];
  [scroll setHasHorizontalScroller:YES];
  [scroll setDrawsBackground:NO];

  NSTextView *tv = [[NSTextView alloc] initWithFrame:scroll.bounds];
  [tv setFont:[NSFont fontWithName:@"Menlo" size:11.0] ?: [NSFont userFixedPitchFontOfSize:11.0]];
  [tv setTextColor:[NSColor colorWithRed:0.9 green:0.9 blue:0.95 alpha:1.0]];
  [tv setBackgroundColor:[NSColor clearColor]];
  [tv setString:codeText ? codeText : @""];
  [tv setEditable:NO];

  [scroll setDocumentView:tv];
  [vcol addArrangedSubview:scroll];

  [container setContentView:vcol];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = container;
  objc_setAssociatedObject(container, "codeTextView", tv, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:container];
  return container;
}

- (void)setCodeViewText:(NSString *)codeText forName:(NSString *)name {
  NSBox *container = (NSBox *)self.controlsByName[[name lowercaseString]];
  if (container) {
    NSTextView *tv = objc_getAssociatedObject(container, "codeTextView");
    if (tv) {
      [tv setString:codeText ? codeText : @""];
    }
  }
}

- (NSString *)codeViewTextForName:(NSString *)name {
  NSBox *container = (NSBox *)self.controlsByName[[name lowercaseString]];
  if (container) {
    NSTextView *tv = objc_getAssociatedObject(container, "codeTextView");
    if (tv) {
      return [tv string];
    }
  }
  return @"";
}

// 1. Alert Banner Control
- (NSView *)makeAlertBannerWithName:(NSString *)name title:(NSString *)title message:(NSString *)message style:(NSString *)style {
  NSBox *banner = [[NSBox alloc] initWithFrame:NSZeroRect];
  [banner setBoxType:NSBoxCustom];
  [banner setCornerRadius:8.0];

  NSString *st = style ? [style lowercaseString] : @"info";
  NSColor *bgColor = [NSColor colorWithRed:0.12 green:0.18 blue:0.28 alpha:0.9];
  NSColor *accentColor = [NSColor systemBlueColor];
  NSString *iconSymbol = @"ℹ️";

  if ([st isEqualToString:@"success"]) {
    bgColor = [NSColor colorWithRed:0.12 green:0.25 blue:0.18 alpha:0.9];
    accentColor = [NSColor systemGreenColor];
    iconSymbol = @"✓";
  } else if ([st isEqualToString:@"warning"]) {
    bgColor = [NSColor colorWithRed:0.28 green:0.22 blue:0.12 alpha:0.9];
    accentColor = [NSColor systemOrangeColor];
    iconSymbol = @"⚠️";
  } else if ([st isEqualToString:@"error"]) {
    bgColor = [NSColor colorWithRed:0.28 green:0.14 blue:0.14 alpha:0.9];
    accentColor = [NSColor systemRedColor];
    iconSymbol = @"❌";
  }

  [banner setFillColor:bgColor];
  [banner setBorderColor:accentColor];

  NSStackView *hstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hstack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hstack setAlignment:NSLayoutAttributeCenterY];
  [hstack setSpacing:10.0];
  [hstack setEdgeInsets:NSEdgeInsetsMake(8, 12, 8, 12)];

  NSTextField *iconLbl = [NSTextField labelWithString:iconSymbol];
  [iconLbl setFont:[NSFont boldSystemFontOfSize:14.0]];
  [hstack addArrangedSubview:iconLbl];

  NSStackView *vtext = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [vtext setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [vtext setAlignment:NSLayoutAttributeLeading];
  [vtext setSpacing:2.0];

  NSTextField *titleLbl = [NSTextField labelWithString:title ? title : @"Alert"];
  [titleLbl setFont:[NSFont boldSystemFontOfSize:12.0]];
  [titleLbl setTextColor:[NSColor whiteColor]];
  [vtext addArrangedSubview:titleLbl];

  if (message && message.length > 0) {
    NSTextField *msgLbl = [NSTextField labelWithString:message];
    [msgLbl setFont:[NSFont systemFontOfSize:11.0]];
    [msgLbl setTextColor:[NSColor colorWithWhite:0.8 alpha:1.0]];
    [vtext addArrangedSubview:msgLbl];
  }
  [hstack addArrangedSubview:vtext];

  NSButton *closeBtn = [NSButton buttonWithTitle:@"✕" target:self action:@selector(handleAlertBannerDismiss:)];
  [closeBtn setBezelStyle:NSBezelStyleInline];
  [closeBtn setBordered:NO];
  [closeBtn setFont:[NSFont boldSystemFontOfSize:12.0]];
  [closeBtn setContentTintColor:[NSColor colorWithWhite:0.7 alpha:1.0]];
  objc_setAssociatedObject(closeBtn, "controlName", name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(closeBtn, "bannerBox", banner, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  [hstack addArrangedSubview:closeBtn];

  [banner setContentView:hstack];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = banner;
  [self addControlToLayout:banner];
  return banner;
}

- (void)handleAlertBannerDismiss:(NSButton *)sender {
  NSString *name = objc_getAssociatedObject(sender, "controlName");
  NSBox *banner = objc_getAssociatedObject(sender, "bannerBox");
  if (banner) {
    [banner setHidden:YES];
  }
  if (name) {
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", "close");
  }
}

- (void)setAlertBannerValueForName:(NSString *)name title:(NSString *)title message:(NSString *)message style:(NSString *)style {
  NSBox *banner = (NSBox *)self.controlsByName[[name lowercaseString]];
  if (banner) {
    [banner setHidden:NO];
  }
}

// 2. Step Process Tracker Control
- (NSView *)makeStepTrackerWithName:(NSString *)name steps:(NSArray<NSString *> *)steps currentStep:(int)currentStep {
  NSStackView *hstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hstack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hstack setAlignment:NSLayoutAttributeCenterY];
  [hstack setSpacing:6.0];
  [hstack setEdgeInsets:NSEdgeInsetsMake(6, 8, 6, 8)];

  NSMutableArray *buttons = [NSMutableArray array];

  for (int i = 0; i < (int)steps.count; i++) {
    BOOL isDone = i < currentStep;
    BOOL isCurrent = i == currentStep;
    NSString *numStr = isDone ? @"✓" : [NSString stringWithFormat:@"%d", i + 1];

    NSButton *stepBtn = [NSButton buttonWithTitle:[NSString stringWithFormat:@"%@  %@", numStr, steps[i]] target:self action:@selector(handleStepTrackerClicked:)];
    [stepBtn setBezelStyle:NSBezelStyleInline];
    [stepBtn setFont:[NSFont boldSystemFontOfSize:11.0]];
    if (isCurrent) {
      [stepBtn setContentTintColor:[NSColor systemBlueColor]];
    } else if (isDone) {
      [stepBtn setContentTintColor:[NSColor systemGreenColor]];
    } else {
      [stepBtn setContentTintColor:[NSColor colorWithWhite:0.6 alpha:1.0]];
    }
    objc_setAssociatedObject(stepBtn, "controlName", name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(stepBtn, "stepIndex", @(i), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [buttons addObject:stepBtn];
    [hstack addArrangedSubview:stepBtn];

    if (i < (int)steps.count - 1) {
      NSTextField *arrow = [NSTextField labelWithString:@"→"];
      [arrow setTextColor:[NSColor colorWithWhite:0.4 alpha:1.0]];
      [arrow setFont:[NSFont systemFontOfSize:11.0]];
      [hstack addArrangedSubview:arrow];
    }
  }

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = hstack;
  objc_setAssociatedObject(hstack, "stepButtons", buttons, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "stepList", steps, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "currentStep", @(currentStep), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:hstack];
  return hstack;
}

- (void)handleStepTrackerClicked:(NSButton *)sender {
  NSString *name = objc_getAssociatedObject(sender, "controlName");
  NSNumber *idxNum = objc_getAssociatedObject(sender, "stepIndex");
  if (name && idxNum) {
    int idx = [idxNum intValue];
    [self setStepTrackerStep:idx forName:name];
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [[NSString stringWithFormat:@"%d", idx] UTF8String]);
  }
}

- (void)setStepTrackerStep:(int)step forName:(NSString *)name {
  NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (hstack) {
    NSArray *buttons = objc_getAssociatedObject(hstack, "stepButtons");
    NSArray *steps = objc_getAssociatedObject(hstack, "stepList");
    objc_setAssociatedObject(hstack, "currentStep", @(step), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    for (int i = 0; i < (int)buttons.count; i++) {
      NSButton *btn = buttons[i];
      BOOL isDone = i < step;
      BOOL isCurrent = i == step;
      NSString *numStr = isDone ? @"✓" : [NSString stringWithFormat:@"%d", i + 1];
      [btn setTitle:[NSString stringWithFormat:@"%@  %@", numStr, steps[i]]];
      if (isCurrent) {
        [btn setContentTintColor:[NSColor systemBlueColor]];
      } else if (isDone) {
        [btn setContentTintColor:[NSColor systemGreenColor]];
      } else {
        [btn setContentTintColor:[NSColor colorWithWhite:0.6 alpha:1.0]];
      }
    }
  }
}

- (int)stepTrackerStepForName:(NSString *)name {
  NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (hstack) {
    NSNumber *num = objc_getAssociatedObject(hstack, "currentStep");
    if (num) return [num intValue];
  }
  return 0;
}

// 3. Filter Chips Control
- (NSView *)makeFilterChipsWithName:(NSString *)name chips:(NSArray<NSString *> *)chips selected:(NSArray<NSString *> *)selected multiSelect:(BOOL)multiSelect {
  NSStackView *hstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hstack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hstack setAlignment:NSLayoutAttributeCenterY];
  [hstack setSpacing:8.0];

  NSMutableArray *buttons = [NSMutableArray array];
  NSMutableSet *selSet = [NSMutableSet setWithArray:selected ? selected : @[]];

  for (NSString *chip in chips) {
    BOOL isSel = [selSet containsObject:chip];
    NSButton *btn = [NSButton buttonWithTitle:[NSString stringWithFormat:@"%@ %@", isSel ? @"✓" : @"", chip] target:self action:@selector(handleFilterChipClicked:)];
    [btn setBezelStyle:NSBezelStyleInline];
    [btn setFont:[NSFont systemFontOfSize:11.0 weight:NSFontWeightMedium]];
    if (isSel) {
      [btn setContentTintColor:[NSColor systemPurpleColor]];
    } else {
      [btn setContentTintColor:[NSColor colorWithWhite:0.7 alpha:1.0]];
    }
    objc_setAssociatedObject(btn, "controlName", name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(btn, "chipTitle", chip, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [buttons addObject:btn];
    [hstack addArrangedSubview:btn];
  }

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = hstack;
  objc_setAssociatedObject(hstack, "chipButtons", buttons, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "chipList", chips, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "selectedSet", selSet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "multiSelect", @(multiSelect), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:hstack];
  return hstack;
}

- (void)handleFilterChipClicked:(NSButton *)sender {
  NSString *name = objc_getAssociatedObject(sender, "controlName");
  NSString *chip = objc_getAssociatedObject(sender, "chipTitle");
  if (!name || !chip) return;

  NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (!hstack) return;

  NSMutableSet *selSet = objc_getAssociatedObject(hstack, "selectedSet");
  NSNumber *multiNum = objc_getAssociatedObject(hstack, "multiSelect");
  BOOL multi = [multiNum boolValue];

  if (multi) {
    if ([selSet containsObject:chip]) {
      [selSet removeObject:chip];
    } else {
      [selSet addObject:chip];
    }
  } else {
    [selSet removeAllObjects];
    [selSet addObject:chip];
  }

  NSArray *buttons = objc_getAssociatedObject(hstack, "chipButtons");
  for (NSButton *btn in buttons) {
    NSString *cTitle = objc_getAssociatedObject(btn, "chipTitle");
    BOOL isSel = [selSet containsObject:cTitle];
    [btn setTitle:[NSString stringWithFormat:@"%@ %@", isSel ? @"✓" : @"", cTitle]];
    if (isSel) {
      [btn setContentTintColor:[NSColor systemPurpleColor]];
    } else {
      [btn setContentTintColor:[NSColor colorWithWhite:0.7 alpha:1.0]];
    }
  }

  NSString *csv = [[selSet allObjects] componentsJoinedByString:@","];
  vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [csv UTF8String]);
}

- (void)setFilterChipsSelected:(NSArray<NSString *> *)selected forName:(NSString *)name {
  NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (hstack) {
    NSMutableSet *selSet = [NSMutableSet setWithArray:selected ? selected : @[]];
    objc_setAssociatedObject(hstack, "selectedSet", selSet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSArray *buttons = objc_getAssociatedObject(hstack, "chipButtons");
    for (NSButton *btn in buttons) {
      NSString *cTitle = objc_getAssociatedObject(btn, "chipTitle");
      BOOL isSel = [selSet containsObject:cTitle];
      [btn setTitle:[NSString stringWithFormat:@"%@ %@", isSel ? @"✓" : @"", cTitle]];
      if (isSel) {
        [btn setContentTintColor:[NSColor systemPurpleColor]];
      } else {
        [btn setContentTintColor:[NSColor colorWithWhite:0.7 alpha:1.0]];
      }
    }
  }
}

- (NSString *)filterChipsSelectedForName:(NSString *)name {
  NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (hstack) {
    NSMutableSet *selSet = objc_getAssociatedObject(hstack, "selectedSet");
    if (selSet) {
      return [[selSet allObjects] componentsJoinedByString:@","];
    }
  }
  return @"";
}

// 4. Native File Picker Field Control
- (NSView *)makeFilePickerFieldWithName:(NSString *)name initialPath:(NSString *)initialPath buttonTitle:(NSString *)buttonTitle folderOnly:(BOOL)folderOnly {
  NSStackView *hstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hstack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hstack setAlignment:NSLayoutAttributeCenterY];
  [hstack setSpacing:8.0];

  ModernTextField *tf = [[ModernTextField alloc] initWithFrame:NSZeroRect];
  [tf setStringValue:initialPath ? initialPath : @""];
  [tf setPlaceholderString:@"No file selected..."];
  [tf.heightAnchor constraintEqualToConstant:34.0].active = YES;
  [self makeStretchableView:tf minimumWidth:220];
  [hstack addArrangedSubview:tf];

  ModernButton *browseBtn = [ModernButton buttonWithTitle:buttonTitle ? buttonTitle : @"Browse..." target:self action:@selector(handleFilePickerBrowseClicked:)];
  [browseBtn.heightAnchor constraintEqualToConstant:34.0].active = YES;
  objc_setAssociatedObject(browseBtn, "controlName", name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(browseBtn, "targetTextField", tf, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(browseBtn, "folderOnly", @(folderOnly), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  [hstack addArrangedSubview:browseBtn];

  [hstack.heightAnchor constraintEqualToConstant:34.0].active = YES;

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = hstack;
  objc_setAssociatedObject(hstack, "pathTextField", tf, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:hstack];
  return hstack;
}

- (void)handleFilePickerBrowseClicked:(NSButton *)sender {
  NSString *name = objc_getAssociatedObject(sender, "controlName");
  ModernTextField *tf = objc_getAssociatedObject(sender, "targetTextField");
  NSNumber *folderNum = objc_getAssociatedObject(sender, "folderOnly");
  BOOL folderOnly = [folderNum boolValue];

  NSOpenPanel *panel = [NSOpenPanel openPanel];
  [panel setCanChooseFiles:!folderOnly];
  [panel setCanChooseDirectories:YES];
  [panel setAllowsMultipleSelection:NO];

  [panel beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse result) {
    if (result == NSModalResponseOK) {
      NSURL *url = [panel URL];
      if (url) {
        NSString *path = [url path];
        if (tf) [tf setStringValue:path];
        if (name) vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [path UTF8String]);
      }
    }
  }];
}

- (void)setFilePickerPath:(NSString *)path forName:(NSString *)name {
  NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (hstack) {
    ModernTextField *tf = objc_getAssociatedObject(hstack, "pathTextField");
    if (tf) [tf setStringValue:path ? path : @""];
  }
}

- (NSString *)filePickerPathForName:(NSString *)name {
  NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (hstack) {
    ModernTextField *tf = objc_getAssociatedObject(hstack, "pathTextField");
    if (tf) return [tf stringValue];
  }
  return @"";
}

// 5. Radial Gauge Control
- (NSView *)makeRadialGaugeWithName:(NSString *)name title:(NSString *)title value:(double)value minVal:(double)minVal maxVal:(double)maxVal unit:(NSString *)unit {
  RadialGaugeView *gauge = [[RadialGaugeView alloc] initWithFrame:NSMakeRect(0, 0, 140, 100)];
  gauge.value = value;
  gauge.minVal = minVal;
  gauge.maxVal = maxVal;
  gauge.title = title ? title : @"Gauge";
  gauge.unit = unit ? unit : @"%";

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = gauge;
  [self addControlToLayout:gauge];
  return gauge;
}

- (void)setRadialGaugeValue:(double)value forName:(NSString *)name {
  RadialGaugeView *gauge = (RadialGaugeView *)self.controlsByName[[name lowercaseString]];
  if (gauge && [gauge isKindOfClass:[RadialGaugeView class]]) {
    gauge.value = value;
    [gauge setNeedsDisplay:YES];
  }
}

- (double)radialGaugeValueForName:(NSString *)name {
  RadialGaugeView *gauge = (RadialGaugeView *)self.controlsByName[[name lowercaseString]];
  if (gauge && [gauge isKindOfClass:[RadialGaugeView class]]) {
    return gauge.value;
  }
  return 0.0;
}

// 6. Key Value Card Control
- (NSView *)makeKeyValueCardWithName:(NSString *)name title:(NSString *)title keys:(NSArray<NSString *> *)keys values:(NSArray<NSString *> *)values {
  NSBox *card = [[NSBox alloc] initWithFrame:NSZeroRect];
  [card setBoxType:NSBoxCustom];
  [card setCornerRadius:8.0];
  [card setFillColor:[NSColor colorWithRed:0.12 green:0.14 blue:0.18 alpha:0.85]];
  [card setBorderColor:[NSColor colorWithWhite:1.0 alpha:0.12]];

  NSStackView *vbox = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [vbox setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [vbox setAlignment:NSLayoutAttributeLeading];
  [vbox setSpacing:6.0];
  [vbox setEdgeInsets:NSEdgeInsetsMake(8, 12, 8, 12)];

  if (title && title.length > 0) {
    NSTextField *titleLbl = [NSTextField labelWithString:title];
    [titleLbl setFont:[NSFont boldSystemFontOfSize:12.0]];
    [titleLbl setTextColor:[NSColor systemBlueColor]];
    [vbox addArrangedSubview:titleLbl];
  }

  NSMutableArray *keyLabels = [NSMutableArray array];
  NSMutableArray *valLabels = [NSMutableArray array];

  int count = (int)MIN(keys.count, values.count);
  for (int i = 0; i < count; i++) {
    NSStackView *row = [[NSStackView alloc] initWithFrame:NSZeroRect];
    [row setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
    [row setAlignment:NSLayoutAttributeCenterY];
    [row setSpacing:12.0];

    NSTextField *kLbl = [NSTextField labelWithString:keys[i]];
    [kLbl setFont:[NSFont systemFontOfSize:11.0]];
    [kLbl setTextColor:[NSColor colorWithWhite:0.6 alpha:1.0]];
    [kLbl setFrameSize:NSMakeSize(90, 16)];

    NSTextField *vLbl = [NSTextField labelWithString:values[i]];
    [vLbl setFont:[NSFont boldSystemFontOfSize:11.0]];
    [vLbl setTextColor:[NSColor whiteColor]];

    [row addArrangedSubview:kLbl];
    [row addArrangedSubview:vLbl];
    [vbox addArrangedSubview:row];

    [keyLabels addObject:kLbl];
    [valLabels addObject:vLbl];
  }

  [card setContentView:vbox];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = card;
  objc_setAssociatedObject(card, "keyLabels", keyLabels, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(card, "valLabels", valLabels, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:card];
  return card;
}

- (void)setKeyValueCardDataForName:(NSString *)name keys:(NSArray<NSString *> *)keys values:(NSArray<NSString *> *)values {
  NSBox *card = (NSBox *)self.controlsByName[[name lowercaseString]];
  if (card) {
    NSArray *kLabels = objc_getAssociatedObject(card, "keyLabels");
    NSArray *vLabels = objc_getAssociatedObject(card, "valLabels");
    int count = (int)MIN(MIN(keys.count, values.count), MIN(kLabels.count, vLabels.count));
    for (int i = 0; i < count; i++) {
      NSTextField *kLbl = kLabels[i];
      NSTextField *vLbl = vLabels[i];
      [kLbl setStringValue:keys[i]];
      [vLbl setStringValue:values[i]];
    }
  }
}

// Helper for Diff View formatting
static NSAttributedString *formatDiffText(NSString *oldText, NSString *newText) {
  NSMutableAttributedString *result = [[NSMutableAttributedString alloc] init];
  NSArray *oldLines = oldText ? [oldText componentsSeparatedByString:@"\n"] : @[];
  NSArray *newLines = newText ? [newText componentsSeparatedByString:@"\n"] : @[];

  NSDictionary *removedAttrs = @{
    NSForegroundColorAttributeName: [NSColor colorWithRed:1.0 green:0.4 blue:0.4 alpha:1.0],
    NSBackgroundColorAttributeName: [NSColor colorWithRed:0.3 green:0.1 blue:0.1 alpha:0.6],
    NSFontAttributeName: [NSFont userFixedPitchFontOfSize:11.5]
  };
  NSDictionary *addedAttrs = @{
    NSForegroundColorAttributeName: [NSColor colorWithRed:0.4 green:0.9 blue:0.4 alpha:1.0],
    NSBackgroundColorAttributeName: [NSColor colorWithRed:0.1 green:0.3 blue:0.1 alpha:0.6],
    NSFontAttributeName: [NSFont userFixedPitchFontOfSize:11.5]
  };
  NSDictionary *normalAttrs = @{
    NSForegroundColorAttributeName: [NSColor colorWithWhite:0.75 alpha:1.0],
    NSFontAttributeName: [NSFont userFixedPitchFontOfSize:11.5]
  };

  NSSet *newSet = [NSSet setWithArray:newLines];
  for (NSString *line in oldLines) {
    if (![newSet containsObject:line] && line.length > 0) {
      NSString *formatted = [NSString stringWithFormat:@"- %@\n", line];
      [result appendAttributedString:[[NSAttributedString alloc] initWithString:formatted attributes:removedAttrs]];
    }
  }

  NSSet *oldSet = [NSSet setWithArray:oldLines];
  for (NSString *line in newLines) {
    if (![oldSet containsObject:line] && line.length > 0) {
      NSString *formatted = [NSString stringWithFormat:@"+ %@\n", line];
      [result appendAttributedString:[[NSAttributedString alloc] initWithString:formatted attributes:addedAttrs]];
    } else {
      NSString *formatted = [NSString stringWithFormat:@"  %@\n", line];
      [result appendAttributedString:[[NSAttributedString alloc] initWithString:formatted attributes:normalAttrs]];
    }
  }

  return result;
}

// 7. Code Diff View Control
- (NSView *)makeDiffViewWithName:(NSString *)name oldText:(NSString *)oldText newText:(NSString *)newText height:(int)height {
  NSBox *box = [[NSBox alloc] initWithFrame:NSZeroRect];
  [box setBoxType:NSBoxCustom];
  [box setCornerRadius:8.0];
  [box setFillColor:[NSColor colorWithRed:0.11 green:0.12 blue:0.14 alpha:0.95]];
  [box setBorderColor:[NSColor colorWithWhite:1.0 alpha:0.15]];

  NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSZeroRect];
  [scroll setHasVerticalScroller:YES];
  [scroll setHasHorizontalScroller:YES];
  [scroll setAutohidesScrollers:YES];
  [scroll setDrawsBackground:NO];

  NSTextView *textView = [[NSTextView alloc] initWithFrame:NSZeroRect];
  [textView setEditable:NO];
  [textView setSelectable:YES];
  [textView setDelegate:self];
  [textView setBackgroundColor:[NSColor colorWithRed:0.11 green:0.12 blue:0.14 alpha:1.0]];
  [textView setMinSize:NSMakeSize(0.0, 100.0)];
  [textView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
  [textView setVerticallyResizable:YES];
  [textView setHorizontallyResizable:NO];
  [textView setAutoresizingMask:NSViewWidthSizable];
  [textView setWantsLayer:YES];
  [textView textContainer].widthTracksTextView = YES;

  NSAttributedString *attrStr = formatDiffText(oldText, newText);
  [[textView textStorage] setAttributedString:attrStr];

  [scroll setDocumentView:textView];
  [scroll.heightAnchor constraintEqualToConstant:height > 0 ? height : 140].active = YES;

  [box setContentView:scroll];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = box;
  objc_setAssociatedObject(box, "diffTextView", textView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(textView, "parentControlName", name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:box];
  return box;
}

- (void)setDiffViewTextForName:(NSString *)name oldText:(NSString *)oldText newText:(NSString *)newText {
  NSBox *box = (NSBox *)self.controlsByName[[name lowercaseString]];
  if (box) {
    NSTextView *textView = objc_getAssociatedObject(box, "diffTextView");
    if (textView) {
      NSAttributedString *attrStr = formatDiffText(oldText, newText);
      [textView insertText:attrStr replacementRange:NSMakeRange(0, textView.string.length)];
      [textView scrollRangeToVisible:NSMakeRange(0, 0)];
      if (self.win_ptr) vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [newText UTF8String]);
    }
  }
}

// Helper for JSON Syntax Highlighting
static NSAttributedString *formatJsonText(NSString *jsonStr) {
  if (!jsonStr) jsonStr = @"{}";
  NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithString:jsonStr attributes:@{
    NSForegroundColorAttributeName: [NSColor colorWithRed:0.8 green:0.82 blue:0.86 alpha:1.0],
    NSFontAttributeName: [NSFont userFixedPitchFontOfSize:11.5]
  }];

  NSRegularExpression *keyRegex = [NSRegularExpression regularExpressionWithPattern:@"\"([^\"]+)\"\\s*:" options:0 error:nil];
  NSRegularExpression *strRegex = [NSRegularExpression regularExpressionWithPattern:@":\\s*\"([^\"]*)\"" options:0 error:nil];
  NSRegularExpression *numRegex = [NSRegularExpression regularExpressionWithPattern:@"\\b(-?\\d+(\\.\\d+)?)\\b" options:0 error:nil];
  NSRegularExpression *boolRegex = [NSRegularExpression regularExpressionWithPattern:@"\\b(true|false|null)\\b" options:0 error:nil];

  NSArray *matches = [keyRegex matchesInString:jsonStr options:0 range:NSMakeRange(0, jsonStr.length)];
  for (NSTextCheckingResult *m in matches) {
    [result addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:0.35 green:0.72 blue:0.76 alpha:1.0] range:[m rangeAtIndex:1]];
  }

  matches = [strRegex matchesInString:jsonStr options:0 range:NSMakeRange(0, jsonStr.length)];
  for (NSTextCheckingResult *m in matches) {
    if ([m numberOfRanges] > 1) {
      [result addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:0.60 green:0.77 blue:0.47 alpha:1.0] range:[m rangeAtIndex:1]];
    }
  }

  matches = [numRegex matchesInString:jsonStr options:0 range:NSMakeRange(0, jsonStr.length)];
  for (NSTextCheckingResult *m in matches) {
    [result addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:0.82 green:0.60 blue:0.40 alpha:1.0] range:m.range];
  }

  matches = [boolRegex matchesInString:jsonStr options:0 range:NSMakeRange(0, jsonStr.length)];
  for (NSTextCheckingResult *m in matches) {
    [result addAttribute:NSForegroundColorAttributeName value:[NSColor colorWithRed:0.78 green:0.47 blue:0.87 alpha:1.0] range:m.range];
  }

  return result;
}

// 8. JSON Tree / Inspector Control
- (NSView *)makeJsonTreeWithName:(NSString *)name jsonStr:(NSString *)jsonStr height:(int)height {
  NSBox *box = [[NSBox alloc] initWithFrame:NSZeroRect];
  [box setBoxType:NSBoxCustom];
  [box setCornerRadius:8.0];
  [box setFillColor:[NSColor colorWithRed:0.09 green:0.10 blue:0.12 alpha:0.95]];
  [box setBorderColor:[NSColor colorWithWhite:1.0 alpha:0.15]];

  NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSZeroRect];
  [scroll setHasVerticalScroller:YES];
  [scroll setHasHorizontalScroller:YES];
  [scroll setAutohidesScrollers:YES];
  [scroll setDrawsBackground:NO];

  NSTextView *textView = [[NSTextView alloc] initWithFrame:NSZeroRect];
  [textView setEditable:NO];
  [textView setSelectable:YES];
  [textView setDelegate:self];
  [textView setBackgroundColor:[NSColor colorWithRed:0.09 green:0.10 blue:0.12 alpha:1.0]];
  [textView setMinSize:NSMakeSize(0.0, 100.0)];
  [textView setMaxSize:NSMakeSize(FLT_MAX, FLT_MAX)];
  [textView setVerticallyResizable:YES];
  [textView setHorizontallyResizable:NO];
  [textView setAutoresizingMask:NSViewWidthSizable];
  [textView setWantsLayer:YES];
  [textView textContainer].widthTracksTextView = YES;

  NSAttributedString *attrStr = formatJsonText(jsonStr);
  [[textView textStorage] setAttributedString:attrStr];

  [scroll setDocumentView:textView];
  [scroll.heightAnchor constraintEqualToConstant:height > 0 ? height : 140].active = YES;

  [box setContentView:scroll];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = box;
  objc_setAssociatedObject(box, "jsonTextView", textView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(textView, "parentControlName", name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:box];
  return box;
}

- (void)setJsonTreeDataForName:(NSString *)name jsonStr:(NSString *)jsonStr {
  NSBox *box = (NSBox *)self.controlsByName[[name lowercaseString]];
  if (box) {
    NSTextView *textView = objc_getAssociatedObject(box, "jsonTextView");
    if (textView) {
      NSAttributedString *attrStr = formatJsonText(jsonStr);
      [textView insertText:attrStr replacementRange:NSMakeRange(0, textView.string.length)];
      [textView scrollRangeToVisible:NSMakeRange(0, 0)];
      if (self.win_ptr) vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [jsonStr UTF8String]);
    }
  }
}

// 9. HTTP Request Inspector Card Control
- (NSView *)makeHttpRequestCardWithName:(NSString *)name method:(NSString *)method url:(NSString *)url statusCode:(int)statusCode responseTimeMs:(int)responseTimeMs {
  NSBox *card = [[NSBox alloc] initWithFrame:NSZeroRect];
  [card setBoxType:NSBoxCustom];
  [card setCornerRadius:8.0];
  [card setFillColor:[NSColor colorWithRed:0.11 green:0.13 blue:0.17 alpha:0.9]];
  [card setBorderColor:[NSColor colorWithWhite:1.0 alpha:0.15]];

  NSStackView *vbox = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [vbox setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [vbox setAlignment:NSLayoutAttributeLeading];
  [vbox setSpacing:8.0];
  [vbox setEdgeInsets:NSEdgeInsetsMake(10, 12, 10, 12)];

  // Top Row: Method Badge + URL
  NSStackView *topRow = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [topRow setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [topRow setAlignment:NSLayoutAttributeCenterY];
  [topRow setSpacing:10.0];

  NSBox *methodBadge = [[NSBox alloc] initWithFrame:NSZeroRect];
  [methodBadge setBoxType:NSBoxCustom];
  [methodBadge setCornerRadius:4.0];

  NSString *mUpper = [method uppercaseString];
  if ([mUpper isEqualToString:@"GET"]) {
    [methodBadge setFillColor:[NSColor colorWithRed:0.12 green:0.43 blue:0.92 alpha:1.0]];
  } else if ([mUpper isEqualToString:@"POST"]) {
    [methodBadge setFillColor:[NSColor colorWithRed:0.14 green:0.53 blue:0.21 alpha:1.0]];
  } else if ([mUpper isEqualToString:@"PUT"]) {
    [methodBadge setFillColor:[NSColor colorWithRed:0.85 green:0.47 blue:0.02 alpha:1.0]];
  } else {
    [methodBadge setFillColor:[NSColor colorWithRed:0.85 green:0.21 blue:0.20 alpha:1.0]];
  }

  NSTextField *methodLbl = [NSTextField labelWithString:mUpper];
  [methodLbl setFont:[NSFont boldSystemFontOfSize:11.0]];
  [methodLbl setTextColor:[NSColor whiteColor]];
  [methodBadge setContentView:methodLbl];

  NSTextField *urlLbl = [NSTextField labelWithString:url];
  [urlLbl setFont:[NSFont userFixedPitchFontOfSize:12.0]];
  [urlLbl setTextColor:[NSColor colorWithWhite:0.95 alpha:1.0]];

  [topRow addArrangedSubview:methodBadge];
  [topRow addArrangedSubview:urlLbl];

  // Bottom Row: Status Badge + Response Time
  NSStackView *btmRow = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [btmRow setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [btmRow setAlignment:NSLayoutAttributeCenterY];
  [btmRow setSpacing:12.0];

  NSBox *statusBadge = [[NSBox alloc] initWithFrame:NSZeroRect];
  [statusBadge setBoxType:NSBoxCustom];
  [statusBadge setCornerRadius:4.0];
  if (statusCode >= 200 && statusCode < 300) {
    [statusBadge setFillColor:[NSColor colorWithRed:0.14 green:0.53 blue:0.21 alpha:1.0]];
  } else {
    [statusBadge setFillColor:[NSColor colorWithRed:0.85 green:0.21 blue:0.20 alpha:1.0]];
  }

  NSTextField *statusLbl = [NSTextField labelWithString:[NSString stringWithFormat:@" %d OK ", statusCode]];
  [statusLbl setFont:[NSFont boldSystemFontOfSize:10.0]];
  [statusLbl setTextColor:[NSColor whiteColor]];
  [statusBadge setContentView:statusLbl];

  NSTextField *timeLbl = [NSTextField labelWithString:[NSString stringWithFormat:@"⚡ %d ms", responseTimeMs]];
  [timeLbl setFont:[NSFont systemFontOfSize:11.0]];
  [timeLbl setTextColor:[NSColor colorWithRed:0.6 green:0.65 blue:0.7 alpha:1.0]];

  [btmRow addArrangedSubview:statusBadge];
  [btmRow addArrangedSubview:timeLbl];

  [vbox addArrangedSubview:topRow];
  [vbox addArrangedSubview:btmRow];

  [card setContentView:vbox];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = card;
  objc_setAssociatedObject(card, "methodBadge", methodBadge, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(card, "methodLbl", methodLbl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(card, "urlLbl", urlLbl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(card, "statusBadge", statusBadge, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(card, "statusLbl", statusLbl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(card, "timeLbl", timeLbl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:card];
  return card;
}

- (void)setHttpRequestCardDataForName:(NSString *)name method:(NSString *)method url:(NSString *)url statusCode:(int)statusCode responseTimeMs:(int)responseTimeMs {
  NSBox *card = (NSBox *)self.controlsByName[[name lowercaseString]];
  if (card) {
    NSTextField *methodLbl = objc_getAssociatedObject(card, "methodLbl");
    NSTextField *urlLbl = objc_getAssociatedObject(card, "urlLbl");
    NSTextField *statusLbl = objc_getAssociatedObject(card, "statusLbl");
    NSTextField *timeLbl = objc_getAssociatedObject(card, "timeLbl");
    NSBox *methodBadge = objc_getAssociatedObject(card, "methodBadge");
    NSBox *statusBadge = objc_getAssociatedObject(card, "statusBadge");

    NSString *mUpper = [method uppercaseString];
    if (methodLbl) [methodLbl setStringValue:mUpper];
    if (urlLbl) [urlLbl setStringValue:url];
    if (statusLbl) [statusLbl setStringValue:[NSString stringWithFormat:@" %d ", statusCode]];
    if (timeLbl) [timeLbl setStringValue:[NSString stringWithFormat:@"⚡ %d ms", responseTimeMs]];

    if (methodBadge) {
      if ([mUpper isEqualToString:@"GET"]) [methodBadge setFillColor:[NSColor colorWithRed:0.12 green:0.43 blue:0.92 alpha:1.0]];
      else if ([mUpper isEqualToString:@"POST"]) [methodBadge setFillColor:[NSColor colorWithRed:0.14 green:0.53 blue:0.21 alpha:1.0]];
      else if ([mUpper isEqualToString:@"PUT"]) [methodBadge setFillColor:[NSColor colorWithRed:0.85 green:0.47 blue:0.02 alpha:1.0]];
      else [methodBadge setFillColor:[NSColor colorWithRed:0.85 green:0.21 blue:0.20 alpha:1.0]];
    }

    if (statusBadge) {
      if (statusCode >= 200 && statusCode < 300) [statusBadge setFillColor:[NSColor colorWithRed:0.14 green:0.53 blue:0.21 alpha:1.0]];
      else [statusBadge setFillColor:[NSColor colorWithRed:0.85 green:0.21 blue:0.20 alpha:1.0]];
    }
  }
}

// 10. Terminal / Command Output View Control
- (NSView *)makeTerminalViewWithName:(NSString *)name promptText:(NSString *)promptText height:(int)height {
  NSBox *box = [[NSBox alloc] initWithFrame:NSZeroRect];
  [box setBoxType:NSBoxCustom];
  [box setCornerRadius:8.0];
  [box setFillColor:[NSColor colorWithRed:0.05 green:0.07 blue:0.09 alpha:0.98]];
  [box setBorderColor:[NSColor colorWithWhite:1.0 alpha:0.15]];

  NSStackView *vbox = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [vbox setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [vbox setAlignment:NSLayoutAttributeLeading];
  [vbox setSpacing:4.0];
  [vbox setEdgeInsets:NSEdgeInsetsMake(6, 8, 6, 8)];

  // Terminal title bar
  NSStackView *dotRow = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [dotRow setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [dotRow setSpacing:6.0];

  for (NSColor *c in @[[NSColor colorWithRed:0.95 green:0.35 blue:0.35 alpha:1.0], [NSColor colorWithRed:0.95 green:0.75 blue:0.25 alpha:1.0], [NSColor colorWithRed:0.25 green:0.85 blue:0.45 alpha:1.0]]) {
    NSBox *dot = [[NSBox alloc] initWithFrame:NSMakeRect(0, 0, 10, 10)];
    [dot setBoxType:NSBoxCustom];
    [dot setCornerRadius:5.0];
    [dot setFillColor:c];
    [dot.widthAnchor constraintEqualToConstant:10].active = YES;
    [dot.heightAnchor constraintEqualToConstant:10].active = YES;
    [dotRow addArrangedSubview:dot];
  }

  NSTextField *titleLbl = [NSTextField labelWithString:@"Terminal / Shell Emulator"];
  [titleLbl setFont:[NSFont boldSystemFontOfSize:11.0]];
  [titleLbl setTextColor:[NSColor colorWithWhite:0.6 alpha:1.0]];
  [dotRow addArrangedSubview:titleLbl];

  NSScrollView *scroll = [[NSScrollView alloc] initWithFrame:NSZeroRect];
  [scroll setHasVerticalScroller:YES];
  [scroll setHasHorizontalScroller:YES];
  [scroll setAutohidesScrollers:YES];
  [scroll setDrawsBackground:NO];

  NSTextView *textView = [[NSTextView alloc] initWithFrame:NSZeroRect];
  [textView setEditable:NO];
  [textView setSelectable:YES];
  [textView setBackgroundColor:[NSColor colorWithRed:0.05 green:0.07 blue:0.09 alpha:1.0]];

  NSString *initText = [NSString stringWithFormat:@"%@\n", promptText ? promptText : @"$ bash -l"];
  NSAttributedString *initAttr = [[NSAttributedString alloc] initWithString:initText attributes:@{
    NSForegroundColorAttributeName: [NSColor colorWithRed:0.22 green:0.74 blue:0.97 alpha:1.0],
    NSFontAttributeName: [NSFont userFixedPitchFontOfSize:11.0]
  }];
  [[textView textStorage] setAttributedString:initAttr];

  [scroll setDocumentView:textView];
  [scroll.heightAnchor constraintEqualToConstant:height > 0 ? height : 130].active = YES;

  [vbox addArrangedSubview:dotRow];
  [vbox addArrangedSubview:scroll];

  [box setContentView:vbox];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = box;
  objc_setAssociatedObject(box, "termTextView", textView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:box];
  return box;
}

- (void)appendTerminalLine:(NSString *)lineText lineType:(int)lineType forName:(NSString *)name {
  NSBox *box = (NSBox *)self.controlsByName[[name lowercaseString]];
  if (box) {
    NSTextView *textView = objc_getAssociatedObject(box, "termTextView");
    if (textView) {
      NSColor *color = [NSColor whiteColor];
      if (lineType == 0) color = [NSColor colorWithRed:0.22 green:0.74 blue:0.97 alpha:1.0]; // prompt
      else if (lineType == 1) color = [NSColor colorWithRed:0.89 green:0.91 blue:0.94 alpha:1.0]; // stdout
      else if (lineType == 2) color = [NSColor colorWithRed:0.97 green:0.44 blue:0.44 alpha:1.0]; // stderr
      else if (lineType == 3) color = [NSColor colorWithRed:0.29 green:0.87 blue:0.50 alpha:1.0]; // success

      NSAttributedString *attrLine = [[NSAttributedString alloc] initWithString:lineText attributes:@{
        NSForegroundColorAttributeName: color,
        NSFontAttributeName: [NSFont userFixedPitchFontOfSize:11.0]
      }];
      [[textView textStorage] appendAttributedString:attrLine];
      [textView scrollToEndOfDocument:nil];
    }
  }
}

- (void)clearTerminalForName:(NSString *)name {
  NSBox *box = (NSBox *)self.controlsByName[[name lowercaseString]];
  if (box) {
    NSTextView *textView = objc_getAssociatedObject(box, "termTextView");
    if (textView) {
      [[textView textStorage] setAttributedString:[[NSAttributedString alloc] initWithString:@""]];
    }
  }
}

// 11. Resource & Telemetry Monitor Control
- (NSView *)makeResourceMonitorWithName:(NSString *)name cpuPct:(int)cpuPct memPct:(int)memPct diskPct:(int)diskPct netKbps:(int)netKbps {
  NSBox *card = [[NSBox alloc] initWithFrame:NSZeroRect];
  [card setBoxType:NSBoxCustom];
  [card setCornerRadius:8.0];
  [card setFillColor:[NSColor colorWithRed:0.10 green:0.12 blue:0.16 alpha:0.9]];
  [card setBorderColor:[NSColor colorWithWhite:1.0 alpha:0.15]];

  NSStackView *vbox = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [vbox setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [vbox setAlignment:NSLayoutAttributeLeading];
  [vbox setSpacing:6.0];
  [vbox setEdgeInsets:NSEdgeInsetsMake(8, 12, 8, 12)];

  NSTextField *titleLbl = [NSTextField labelWithString:@"⚡ Resource & System Performance Monitor"];
  [titleLbl setFont:[NSFont boldSystemFontOfSize:12.0]];
  [titleLbl setTextColor:[NSColor systemCyanColor]];
  [vbox addArrangedSubview:titleLbl];

  NSArray *metricNames = @[@"CPU Usage", @"Memory (RAM)", @"Disk Storage", @"Network NetIO"];
  NSArray *values = @[@(cpuPct), @(memPct), @(diskPct), @(netKbps)];
  NSMutableArray *valLabels = [NSMutableArray array];
  NSMutableArray *indicators = [NSMutableArray array];

  for (int i = 0; i < 4; i++) {
    NSStackView *row = [[NSStackView alloc] initWithFrame:NSZeroRect];
    [row setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
    [row setAlignment:NSLayoutAttributeCenterY];
    [row setSpacing:8.0];

    NSTextField *nameLbl = [NSTextField labelWithString:metricNames[i]];
    [nameLbl setFont:[NSFont systemFontOfSize:11.0]];
    [nameLbl setTextColor:[NSColor colorWithWhite:0.7 alpha:1.0]];
    [nameLbl.widthAnchor constraintEqualToConstant:100].active = YES;

    NSProgressIndicator *prog = [[NSProgressIndicator alloc] initWithFrame:NSZeroRect];
    [prog setIndeterminate:NO];
    [prog setMinValue:0];
    [prog setMaxValue:100];
    [prog setDoubleValue:[values[i] doubleValue]];
    [prog.widthAnchor constraintEqualToConstant:140].active = YES;

    int val = [values[i] intValue];
    NSString *valStr = (i == 3) ? [NSString stringWithFormat:@"%d KB/s", val] : [NSString stringWithFormat:@"%d%%", val];
    NSTextField *vLbl = [NSTextField labelWithString:valStr];
    [vLbl setFont:[NSFont boldSystemFontOfSize:11.0]];
    [vLbl setTextColor:[NSColor whiteColor]];

    [row addArrangedSubview:nameLbl];
    [row addArrangedSubview:prog];
    [row addArrangedSubview:vLbl];

    [vbox addArrangedSubview:row];

    [valLabels addObject:vLbl];
    [indicators addObject:prog];
  }

  [card setContentView:vbox];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = card;
  objc_setAssociatedObject(card, "resValLabels", valLabels, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(card, "resIndicators", indicators, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:card];
  return card;
}

- (void)setResourceMonitorMetricsForName:(NSString *)name cpuPct:(int)cpuPct memPct:(int)memPct diskPct:(int)diskPct netKbps:(int)netKbps {
  NSBox *card = (NSBox *)self.controlsByName[[name lowercaseString]];
  if (card) {
    NSArray *valLabels = objc_getAssociatedObject(card, "resValLabels");
    NSArray *indicators = objc_getAssociatedObject(card, "resIndicators");
    if (valLabels.count >= 4 && indicators.count >= 4) {
      int vals[4] = {cpuPct, memPct, diskPct, netKbps};
      for (int i = 0; i < 4; i++) {
        NSProgressIndicator *prog = indicators[i];
        NSTextField *vLbl = valLabels[i];
        [prog setDoubleValue:vals[i]];
        NSString *valStr = (i == 3) ? [NSString stringWithFormat:@"%d KB/s", vals[i]] : [NSString stringWithFormat:@"%d%%", vals[i]];
        [vLbl setStringValue:valStr];
      }
    }
  }
}

// 12. Environment & Config Variables Editor Control
- (NSView *)makeEnvVarsWithName:(NSString *)name title:(NSString *)title keys:(NSArray<NSString *> *)keys values:(NSArray<NSString *> *)values {
  NSBox *card = [[NSBox alloc] initWithFrame:NSZeroRect];
  [card setBoxType:NSBoxCustom];
  [card setCornerRadius:8.0];
  [card setFillColor:[NSColor colorWithRed:0.12 green:0.14 blue:0.18 alpha:0.9]];
  [card setBorderColor:[NSColor colorWithWhite:1.0 alpha:0.15]];

  NSStackView *vbox = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [vbox setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [vbox setAlignment:NSLayoutAttributeLeading];
  [vbox setSpacing:6.0];
  [vbox setEdgeInsets:NSEdgeInsetsMake(8, 12, 8, 12)];

  if (title && title.length > 0) {
    NSTextField *titleLbl = [NSTextField labelWithString:title];
    [titleLbl setFont:[NSFont boldSystemFontOfSize:12.0]];
    [titleLbl setTextColor:[NSColor systemGreenColor]];
    [vbox addArrangedSubview:titleLbl];
  }

  NSMutableArray *kLabels = [NSMutableArray array];
  NSMutableArray *vLabels = [NSMutableArray array];

  int count = (int)MIN(keys.count, values.count);
  for (int i = 0; i < count; i++) {
    NSStackView *row = [[NSStackView alloc] initWithFrame:NSZeroRect];
    [row setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
    [row setAlignment:NSLayoutAttributeCenterY];
    [row setSpacing:8.0];

    NSTextField *kLbl = [NSTextField labelWithString:keys[i]];
    [kLbl setFont:[NSFont userFixedPitchFontOfSize:11.0]];
    [kLbl setTextColor:[NSColor colorWithRed:0.22 green:0.74 blue:0.97 alpha:1.0]];
    [kLbl.widthAnchor constraintEqualToConstant:130].active = YES;

    NSTextField *eqLbl = [NSTextField labelWithString:@"="];
    [eqLbl setFont:[NSFont boldSystemFontOfSize:11.0]];
    [eqLbl setTextColor:[NSColor colorWithWhite:0.5 alpha:1.0]];

    NSTextField *vLbl = [NSTextField labelWithString:values[i]];
    [vLbl setFont:[NSFont userFixedPitchFontOfSize:11.0]];
    [vLbl setTextColor:[NSColor colorWithWhite:0.9 alpha:1.0]];

    [row addArrangedSubview:kLbl];
    [row addArrangedSubview:eqLbl];
    [row addArrangedSubview:vLbl];

    [vbox addArrangedSubview:row];

    [kLabels addObject:kLbl];
    [vLabels addObject:vLbl];
  }

  [card setContentView:vbox];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = card;
  objc_setAssociatedObject(card, "envKeyLabels", kLabels, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(card, "envValLabels", vLabels, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:card];
  return card;
}

- (void)setEnvVarsDataForName:(NSString *)name keys:(NSArray<NSString *> *)keys values:(NSArray<NSString *> *)values {
  NSBox *card = (NSBox *)self.controlsByName[[name lowercaseString]];
  if (card) {
    NSArray *kLabels = objc_getAssociatedObject(card, "envKeyLabels");
    NSArray *vLabels = objc_getAssociatedObject(card, "envValLabels");
    int count = (int)MIN(MIN(keys.count, values.count), MIN(kLabels.count, vLabels.count));
    for (int i = 0; i < count; i++) {
      NSTextField *kLbl = kLabels[i];
      NSTextField *vLbl = vLabels[i];
      [kLbl setStringValue:keys[i]];
      [vLbl setStringValue:values[i]];
    }
  }
}

// 13. Badge Button Control
- (NSView *)makeBadgeButtonWithName:(NSString *)name title:(NSString *)title count:(int)count badgeColor:(NSString *)badgeColor {
  NSStackView *row = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [row setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [row setAlignment:NSLayoutAttributeCenterY];
  [row setSpacing:6.0];

  ModernButton *btn = [ModernButton buttonWithTitle:title target:self action:@selector(handleButtonClicked:)];
  objc_setAssociatedObject(btn, "controlName", name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  [btn.heightAnchor constraintEqualToConstant:34.0].active = YES;
  [row addArrangedSubview:btn];

  NSBox *badge = [[NSBox alloc] initWithFrame:NSZeroRect];
  [badge setBoxType:NSBoxCustom];
  [badge setCornerRadius:10.0];
  [badge setFillColor:[NSColor colorWithRed:0.94 green:0.27 blue:0.27 alpha:1.0]];

  NSTextField *countLbl = [NSTextField labelWithString:[NSString stringWithFormat:@" %d ", count]];
  [countLbl setFont:[NSFont boldSystemFontOfSize:11.0]];
  [countLbl setTextColor:[NSColor whiteColor]];
  [badge setContentView:countLbl];

  [row addArrangedSubview:badge];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = row;
  objc_setAssociatedObject(row, "badgeCountLbl", countLbl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(row, "badgeBox", badge, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:row];
  return row;
}

- (void)setBadgeButtonCount:(int)count forName:(NSString *)name {
  NSStackView *row = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (row) {
    NSTextField *countLbl = objc_getAssociatedObject(row, "badgeCountLbl");
    NSBox *badgeBox = objc_getAssociatedObject(row, "badgeBox");
    if (countLbl) [countLbl setStringValue:[NSString stringWithFormat:@" %d ", count]];
    if (badgeBox) [badgeBox setHidden:(count <= 0)];
  }
}

// 14. Command Palette Input Bar Control
- (NSView *)makeCommandPaletteWithName:(NSString *)name placeholder:(NSString *)placeholder shortcutHint:(NSString *)shortcutHint {
  NSBox *box = [[NSBox alloc] initWithFrame:NSZeroRect];
  [box setBoxType:NSBoxCustom];
  [box setCornerRadius:8.0];
  [box setFillColor:[NSColor colorWithRed:0.12 green:0.14 blue:0.18 alpha:0.95]];
  [box setBorderColor:[NSColor colorWithWhite:1.0 alpha:0.15]];

  NSStackView *hstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hstack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hstack setAlignment:NSLayoutAttributeCenterY];
  [hstack setSpacing:8.0];
  [hstack setEdgeInsets:NSEdgeInsetsMake(6, 12, 6, 12)];

  NSTextField *iconLbl = [NSTextField labelWithString:@"🔍"];
  [iconLbl setFont:[NSFont systemFontOfSize:13.0]];
  [hstack addArrangedSubview:iconLbl];

  ModernTextField *tf = [[ModernTextField alloc] initWithFrame:NSZeroRect];
  [tf setPlaceholderString:placeholder ? placeholder : @"Type a command or search..."];
  [tf setDelegate:self];
  [tf setTarget:self];
  [tf setAction:@selector(handleInputChanged:)];
  [tf.heightAnchor constraintEqualToConstant:30.0].active = YES;
  [self makeStretchableView:tf minimumWidth:240];
  [hstack addArrangedSubview:tf];

  if (shortcutHint && shortcutHint.length > 0) {
    NSBox *keyBadge = [[NSBox alloc] initWithFrame:NSZeroRect];
    [keyBadge setBoxType:NSBoxCustom];
    [keyBadge setCornerRadius:4.0];
    [keyBadge setFillColor:[NSColor colorWithWhite:1.0 alpha:0.1]];

    NSTextField *hintLbl = [NSTextField labelWithString:shortcutHint];
    [hintLbl setFont:[NSFont userFixedPitchFontOfSize:11.0]];
    [hintLbl setTextColor:[NSColor colorWithWhite:0.7 alpha:1.0]];
    [keyBadge setContentView:hintLbl];
    [hstack addArrangedSubview:keyBadge];
  }

  [box setContentView:hstack];
  [box.heightAnchor constraintEqualToConstant:44.0].active = YES;

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = box;
  objc_setAssociatedObject(box, "cmdTextField", tf, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:box];
  return box;
}

- (void)setCommandPaletteText:(NSString *)text forName:(NSString *)name {
  NSBox *box = (NSBox *)self.controlsByName[[name lowercaseString]];
  if (box) {
    ModernTextField *tf = objc_getAssociatedObject(box, "cmdTextField");
    if (tf) [tf setStringValue:text ? text : @""];
  }
}

// 15. Status Banner Alert Strip Control
- (NSView *)makeStatusBannerWithName:(NSString *)name title:(NSString *)title message:(NSString *)message styleType:(NSString *)styleType {
  NSBox *banner = [[NSBox alloc] initWithFrame:NSZeroRect];
  [banner setBoxType:NSBoxCustom];
  [banner setCornerRadius:8.0];

  NSString *st = [styleType lowercaseString];
  NSColor *accentColor = [NSColor systemBlueColor];
  NSColor *bgColor = [NSColor colorWithRed:0.11 green:0.15 blue:0.22 alpha:0.9];
  NSString *icon = @"ℹ️";

  if ([st isEqualToString:@"success"]) {
    accentColor = [NSColor colorWithRed:0.2 green:0.8 blue:0.4 alpha:1.0];
    bgColor = [NSColor colorWithRed:0.09 green:0.18 blue:0.12 alpha:0.9];
    icon = @"✅";
  } else if ([st isEqualToString:@"warning"]) {
    accentColor = [NSColor colorWithRed:0.95 green:0.75 blue:0.2 alpha:1.0];
    bgColor = [NSColor colorWithRed:0.22 green:0.18 blue:0.08 alpha:0.9];
    icon = @"⚠️";
  } else if ([st isEqualToString:@"error"]) {
    accentColor = [NSColor colorWithRed:0.95 green:0.3 blue:0.3 alpha:1.0];
    bgColor = [NSColor colorWithRed:0.22 green:0.09 blue:0.09 alpha:0.9];
    icon = @"❌";
  }

  [banner setFillColor:bgColor];
  [banner setBorderColor:accentColor];

  NSStackView *hstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hstack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hstack setAlignment:NSLayoutAttributeCenterY];
  [hstack setSpacing:10.0];
  [hstack setEdgeInsets:NSEdgeInsetsMake(8, 12, 8, 12)];

  NSTextField *iconLbl = [NSTextField labelWithString:icon];
  [iconLbl setFont:[NSFont systemFontOfSize:14.0]];
  [hstack addArrangedSubview:iconLbl];

  NSStackView *vbox = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [vbox setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [vbox setAlignment:NSLayoutAttributeLeading];
  [vbox setSpacing:2.0];

  NSTextField *tLbl = [NSTextField labelWithString:title ? title : @""];
  [tLbl setFont:[NSFont boldSystemFontOfSize:12.0]];
  [tLbl setTextColor:[NSColor whiteColor]];

  NSTextField *mLbl = [NSTextField labelWithString:message ? message : @""];
  [mLbl setFont:[NSFont systemFontOfSize:11.0]];
  [mLbl setTextColor:[NSColor colorWithWhite:0.8 alpha:1.0]];

  [vbox addArrangedSubview:tLbl];
  [vbox addArrangedSubview:mLbl];
  [hstack addArrangedSubview:vbox];

  [banner setContentView:hstack];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = banner;
  objc_setAssociatedObject(banner, "bannerTitleLbl", tLbl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(banner, "bannerMsgLbl", mLbl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:banner];
  return banner;
}

- (void)setStatusBannerTextForName:(NSString *)name title:(NSString *)title message:(NSString *)message styleType:(NSString *)styleType {
  NSBox *banner = (NSBox *)self.controlsByName[[name lowercaseString]];
  if (banner) {
    NSTextField *tLbl = objc_getAssociatedObject(banner, "bannerTitleLbl");
    NSTextField *mLbl = objc_getAssociatedObject(banner, "bannerMsgLbl");
    if (tLbl) [tLbl setStringValue:title ? title : @""];
    if (mLbl) [mLbl setStringValue:message ? message : @""];
  }
}

// 16. Pill Toggle Switch Control
- (NSView *)makePillToggleWithName:(NSString *)name options:(NSArray<NSString *> *)options selectedIndex:(int)selectedIndex {
  NSBox *pillBox = [[NSBox alloc] initWithFrame:NSZeroRect];
  [pillBox setBoxType:NSBoxCustom];
  [pillBox setCornerRadius:14.0];
  [pillBox setFillColor:[NSColor colorWithRed:0.12 green:0.14 blue:0.18 alpha:0.95]];
  [pillBox setBorderColor:[NSColor colorWithWhite:1.0 alpha:0.15]];

  NSStackView *hstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hstack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hstack setAlignment:NSLayoutAttributeCenterY];
  [hstack setSpacing:4.0];
  [hstack setEdgeInsets:NSEdgeInsetsMake(3, 4, 3, 4)];

  NSMutableArray *buttons = [NSMutableArray array];

  for (int i = 0; i < (int)options.count; i++) {
    NSButton *btn = [NSButton buttonWithTitle:options[i] target:self action:@selector(handlePillToggleClicked:)];
    [btn setButtonType:NSButtonTypeMomentaryPushIn];
    [btn setBezelStyle:NSBezelStyleInline];

    BOOL isSel = (i == selectedIndex);
    if (isSel) {
      [btn setContentTintColor:[NSColor whiteColor]];
    } else {
      [btn setContentTintColor:[NSColor colorWithWhite:0.6 alpha:1.0]];
    }

    objc_setAssociatedObject(btn, "pillControlName", name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(btn, "pillIndex", @(i), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [hstack addArrangedSubview:btn];
    [buttons addObject:btn];
  }

  [pillBox setContentView:hstack];
  [pillBox.heightAnchor constraintEqualToConstant:32.0].active = YES;

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = pillBox;
  objc_setAssociatedObject(pillBox, "pillButtons", buttons, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:pillBox];
  return pillBox;
}

- (void)handlePillToggleClicked:(NSButton *)sender {
  NSString *name = objc_getAssociatedObject(sender, "pillControlName");
  NSNumber *idxNum = objc_getAssociatedObject(sender, "pillIndex");
  if (name && idxNum) {
    int idx = [idxNum intValue];
    [self setPillToggleSelected:idx forName:name];
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "change", [[NSString stringWithFormat:@"%d", idx] UTF8String]);
  }
}

- (void)setPillToggleSelected:(int)selectedIndex forName:(NSString *)name {
  NSBox *pillBox = (NSBox *)self.controlsByName[[name lowercaseString]];
  if (pillBox) {
    NSArray *buttons = objc_getAssociatedObject(pillBox, "pillButtons");
    for (int i = 0; i < (int)buttons.count; i++) {
      NSButton *btn = buttons[i];
      if (i == selectedIndex) {
        [btn setContentTintColor:[NSColor systemBlueColor]];
      } else {
        [btn setContentTintColor:[NSColor colorWithWhite:0.6 alpha:1.0]];
      }
    }
  }
}

// 17. Color Swatch Panel Control
- (NSView *)makeColorSwatchPanelWithName:(NSString *)name hexColors:(NSArray<NSString *> *)hexColors selectedColor:(NSString *)selectedColor {
  NSBox *box = [[NSBox alloc] initWithFrame:NSZeroRect];
  [box setBoxType:NSBoxCustom];
  [box setCornerRadius:8.0];
  [box setFillColor:[NSColor colorWithRed:0.12 green:0.14 blue:0.18 alpha:0.9]];
  [box setBorderColor:[NSColor colorWithWhite:1.0 alpha:0.15]];

  NSStackView *hstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hstack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hstack setAlignment:NSLayoutAttributeCenterY];
  [hstack setSpacing:8.0];
  [hstack setEdgeInsets:NSEdgeInsetsMake(6, 8, 6, 8)];

  NSMutableArray *swatches = [NSMutableArray array];

  for (NSString *hex in hexColors) {
    NSBox *swatch = [[NSBox alloc] initWithFrame:NSMakeRect(0, 0, 24, 24)];
    [swatch setBoxType:NSBoxCustom];
    [swatch setCornerRadius:12.0];
    [swatch setFillColor:colorFromHexString(hex)];

    BOOL isSel = [hex isEqualToString:selectedColor];
    [swatch setBorderColor:isSel ? [NSColor whiteColor] : [NSColor clearColor]];

    [swatch.widthAnchor constraintEqualToConstant:24].active = YES;
    [swatch.heightAnchor constraintEqualToConstant:24].active = YES;

    [hstack addArrangedSubview:swatch];
    [swatches addObject:swatch];
  }

  [box setContentView:hstack];
  [box.heightAnchor constraintEqualToConstant:38.0].active = YES;

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = box;

  [self addControlToLayout:box];
  return box;
}

- (void)setColorSwatchSelected:(NSString *)hexColor forName:(NSString *)name {
  // Color swatch selection handler
}

// 18. Hotkey / Key Combo Badge Display Control
- (NSView *)makeHotkeyBadgeWithName:(NSString *)name shortcutStr:(NSString *)shortcutStr description:(NSString *)description {
  NSStackView *hstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hstack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hstack setAlignment:NSLayoutAttributeCenterY];
  [hstack setSpacing:10.0];

  NSBox *keyBox = [[NSBox alloc] initWithFrame:NSZeroRect];
  [keyBox setBoxType:NSBoxCustom];
  [keyBox setCornerRadius:6.0];
  [keyBox setFillColor:[NSColor colorWithRed:0.2 green:0.22 blue:0.26 alpha:1.0]];
  [keyBox setBorderColor:[NSColor colorWithWhite:1.0 alpha:0.25]];

  NSTextField *kLbl = [NSTextField labelWithString:shortcutStr ? shortcutStr : @"⌘K"];
  [kLbl setFont:[NSFont boldSystemFontOfSize:11.0]];
  [kLbl setTextColor:[NSColor whiteColor]];
  [keyBox setContentView:kLbl];

  NSTextField *dLbl = [NSTextField labelWithString:description ? description : @""];
  [dLbl setFont:[NSFont systemFontOfSize:12.0]];
  [dLbl setTextColor:[NSColor colorWithWhite:0.8 alpha:1.0]];

  [hstack addArrangedSubview:keyBox];
  [hstack addArrangedSubview:dLbl];

  [hstack.heightAnchor constraintEqualToConstant:28.0].active = YES;

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = hstack;
  objc_setAssociatedObject(hstack, "hotkeyLbl", kLbl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(hstack, "hotkeyDescLbl", dLbl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:hstack];
  return hstack;
}

- (void)setHotkeyBadgeShortcutForName:(NSString *)name shortcutStr:(NSString *)shortcutStr description:(NSString *)description {
  NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (hstack) {
    NSTextField *kLbl = objc_getAssociatedObject(hstack, "hotkeyLbl");
    NSTextField *dLbl = objc_getAssociatedObject(hstack, "hotkeyDescLbl");
    if (kLbl) [kLbl setStringValue:shortcutStr ? shortcutStr : @""];
    if (dLbl) [dLbl setStringValue:description ? description : @""];
  }
}

// 19. Quick Action Bar Control
- (NSView *)makeQuickActionBarWithName:(NSString *)name labels:(NSArray<NSString *> *)labels symbols:(NSArray<NSString *> *)symbols {
  NSStackView *hstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hstack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hstack setAlignment:NSLayoutAttributeCenterY];
  [hstack setSpacing:8.0];

  NSMutableArray<NSButton *> *buttons = [NSMutableArray array];
  NSUInteger count = labels.count;
  for (NSUInteger i = 0; i < count; i++) {
    NSString *label = labels[i];
    NSString *symbol = (i < symbols.count) ? symbols[i] : @"⚡";
    NSString *titleStr = [NSString stringWithFormat:@"%@ %@", symbol, label];
    NSButton *btn = [NSButton buttonWithTitle:titleStr target:self action:@selector(handleQuickActionBtnClicked:)];
    [btn setBezelStyle:NSBezelStyleRounded];
    [btn setFont:[NSFont systemFontOfSize:12.0 weight:NSFontWeightMedium]];
    btn.identifier = [NSString stringWithFormat:@"%@___%d", name, (int)i];
    [hstack addArrangedSubview:btn];
    [buttons addObject:btn];
  }

  [hstack.heightAnchor constraintEqualToConstant:32.0].active = YES;

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = hstack;
  objc_setAssociatedObject(hstack, "quickActionBtns", buttons, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:hstack];
  return hstack;
}

- (void)handleQuickActionBtnClicked:(id)sender {
  NSButton *btn = (NSButton *)sender;
  NSString *ident = btn.identifier;
  NSRange range = [ident rangeOfString:@"___"];
  if (range.location != NSNotFound) {
    NSString *name = [ident substringToIndex:range.location];
    NSString *idxStr = [ident substringFromIndex:range.location + 3];
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "click_action", [idxStr UTF8String]);
  }
}

- (void)setQuickActionEnabled:(BOOL)enabled index:(int)index forName:(NSString *)name {
  NSStackView *hstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (hstack) {
    NSArray<NSButton *> *buttons = objc_getAssociatedObject(hstack, "quickActionBtns");
    if (buttons && index >= 0 && index < (int)buttons.count) {
      [buttons[index] setEnabled:enabled];
    }
  }
}

// 20. Accordion Multi-Section Group Control
- (NSView *)makeAccordionGroupWithName:(NSString *)name sectionTitles:(NSArray<NSString *> *)sectionTitles expandedIndex:(int)expandedIndex {
  NSStackView *vstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [vstack setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [vstack setAlignment:NSLayoutAttributeLeading];
  [vstack setSpacing:6.0];

  NSMutableArray<NSButton *> *headers = [NSMutableArray array];
  NSMutableArray<NSBox *> *panels = [NSMutableArray array];

  for (NSUInteger i = 0; i < sectionTitles.count; i++) {
    NSString *stitle = sectionTitles[i];
    BOOL isExp = ((int)i == expandedIndex);

    NSButton *hdrBtn = [NSButton buttonWithTitle:[NSString stringWithFormat:@"%@  %@", isExp ? @"▼" : @"▶", stitle] target:self action:@selector(handleAccordionHeaderClicked:)];
    [hdrBtn setBezelStyle:NSBezelStyleInline];
    [hdrBtn setFont:[NSFont boldSystemFontOfSize:12.0]];
    hdrBtn.identifier = [NSString stringWithFormat:@"%@___%d", name, (int)i];
    [vstack addArrangedSubview:hdrBtn];
    [headers addObject:hdrBtn];

    NSBox *panelBox = [[NSBox alloc] initWithFrame:NSZeroRect];
    [panelBox setBoxType:NSBoxCustom];
    [panelBox setCornerRadius:6.0];
    [panelBox setFillColor:[NSColor colorWithWhite:0.15 alpha:1.0]];
    [panelBox setBorderColor:[NSColor colorWithWhite:0.3 alpha:0.5]];

    NSTextField *panelText = [NSTextField labelWithString:[NSString stringWithFormat:@"Content for Section #%d (%@)", (int)i + 1, stitle]];
    [panelText setFont:[NSFont systemFontOfSize:11.0]];
    [panelText setTextColor:[NSColor colorWithWhite:0.8 alpha:1.0]];
    [panelBox setContentView:panelText];
    [panelBox setHidden:!isExp];

    [vstack addArrangedSubview:panelBox];
    [panels addObject:panelBox];
  }

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = vstack;
  objc_setAssociatedObject(vstack, "accordionHeaders", headers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(vstack, "accordionPanels", panels, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(vstack, "accordionTitles", sectionTitles, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:vstack];
  return vstack;
}

- (void)handleAccordionHeaderClicked:(id)sender {
  NSButton *btn = (NSButton *)sender;
  NSString *ident = btn.identifier;
  NSRange range = [ident rangeOfString:@"___"];
  if (range.location != NSNotFound) {
    NSString *name = [ident substringToIndex:range.location];
    int idx = [[ident substringFromIndex:range.location + 3] intValue];
    NSStackView *vstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
    if (vstack) {
      NSArray<NSBox *> *panels = objc_getAssociatedObject(vstack, "accordionPanels");
      NSArray<NSButton *> *headers = objc_getAssociatedObject(vstack, "accordionHeaders");
      NSArray<NSString *> *titles = objc_getAssociatedObject(vstack, "accordionTitles");
      if (panels && headers && idx >= 0 && idx < (int)panels.count) {
        BOOL curHidden = [panels[idx] isHidden];
        [panels[idx] setHidden:!curHidden];
        NSString *stitle = (idx < (int)titles.count) ? titles[idx] : @"";
        [headers[idx] setTitle:[NSString stringWithFormat:@"%@  %@", curHidden ? @"▼" : @"▶", stitle]];
      }
    }
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "toggle_section", [[NSString stringWithFormat:@"%d", idx] UTF8String]);
  }
}

- (void)setAccordionExpanded:(BOOL)expanded index:(int)index forName:(NSString *)name {
  NSStackView *vstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (vstack) {
    NSArray<NSBox *> *panels = objc_getAssociatedObject(vstack, "accordionPanels");
    NSArray<NSButton *> *headers = objc_getAssociatedObject(vstack, "accordionHeaders");
    NSArray<NSString *> *titles = objc_getAssociatedObject(vstack, "accordionTitles");
    if (panels && headers && index >= 0 && index < (int)panels.count) {
      [panels[index] setHidden:!expanded];
      NSString *stitle = (index < (int)titles.count) ? titles[index] : @"";
      [headers[index] setTitle:[NSString stringWithFormat:@"%@  %@", expanded ? @"▼" : @"▶", stitle]];
    }
  }
}

// 21. Proportional Segment Distribution Bar Control
- (NSView *)makeSegmentDistributionBarWithName:(NSString *)name labels:(NSArray<NSString *> *)labels values:(NSArray<NSNumber *> *)values hexColors:(NSArray<NSString *> *)hexColors height:(int)height {
  NSStackView *container = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [container setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [container setAlignment:NSLayoutAttributeLeading];
  [container setSpacing:6.0];

  int barH = height > 0 ? height : 14;

  NSStackView *barStack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [barStack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [barStack setSpacing:2.0];
  [barStack setAlignment:NSLayoutAttributeCenterY];
  [barStack.heightAnchor constraintEqualToConstant:barH].active = YES;

  NSStackView *legendStack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [legendStack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [legendStack setSpacing:12.0];
  [legendStack setAlignment:NSLayoutAttributeCenterY];

  [container addArrangedSubview:barStack];
  [container addArrangedSubview:legendStack];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = container;
  objc_setAssociatedObject(container, "segBarStack", barStack, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(container, "segLegendStack", legendStack, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(container, "segLabels", labels, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(container, "segHexColors", hexColors, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self rebuildSegmentDistributionBar:container values:values];
  [self addControlToLayout:container];
  return container;
}

- (void)rebuildSegmentDistributionBar:(NSStackView *)container values:(NSArray<NSNumber *> *)values {
  NSStackView *barStack = objc_getAssociatedObject(container, "segBarStack");
  NSStackView *legendStack = objc_getAssociatedObject(container, "segLegendStack");
  NSArray<NSString *> *labels = objc_getAssociatedObject(container, "segLabels");
  NSArray<NSString *> *hexColors = objc_getAssociatedObject(container, "segHexColors");

  if (!barStack || !legendStack) return;

  for (NSView *v in [barStack.arrangedSubviews copy]) {
    [barStack removeArrangedSubview:v];
    [v removeFromSuperview];
  }
  for (NSView *v in [legendStack.arrangedSubviews copy]) {
    [legendStack removeArrangedSubview:v];
    [v removeFromSuperview];
  }

  double sum = 0.0;
  for (NSNumber *val in values) sum += [val doubleValue];
  if (sum <= 0.0) sum = 1.0;

  for (NSUInteger i = 0; i < values.count; i++) {
    double val = [values[i] doubleValue];
    double pct = (val / sum) * 100.0;
    NSString *hex = (i < hexColors.count) ? hexColors[i] : @"#007aff";
    NSString *label = (i < labels.count) ? labels[i] : [NSString stringWithFormat:@"Item %d", (int)i+1];

    NSBox *segBox = [[NSBox alloc] initWithFrame:NSZeroRect];
    [segBox setBoxType:NSBoxCustom];
    [segBox setCornerRadius:3.0];
    [segBox setFillColor:colorFromHexString(hex)];
    [segBox setBorderColor:[NSColor clearColor]];
    [segBox.widthAnchor constraintEqualToConstant:MAX(8.0, pct * 4.0)].active = YES;
    [barStack addArrangedSubview:segBox];

    NSStackView *legItem = [[NSStackView alloc] initWithFrame:NSZeroRect];
    [legItem setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
    [legItem setSpacing:4.0];

    NSBox *dot = [[NSBox alloc] initWithFrame:NSZeroRect];
    [dot setBoxType:NSBoxCustom];
    [dot setCornerRadius:4.0];
    [dot setFillColor:colorFromHexString(hex)];
    [dot.widthAnchor constraintEqualToConstant:8.0].active = YES;
    [dot.heightAnchor constraintEqualToConstant:8.0].active = YES;

    NSTextField *lText = [NSTextField labelWithString:[NSString stringWithFormat:@"%@ (%.0f%%)", label, pct]];
    [lText setFont:[NSFont systemFontOfSize:11.0]];
    [lText setTextColor:[NSColor colorWithWhite:0.8 alpha:1.0]];

    [legItem addArrangedSubview:dot];
    [legItem addArrangedSubview:lText];
    [legendStack addArrangedSubview:legItem];
  }
}

- (void)setSegmentDistributionValues:(NSArray<NSNumber *> *)values forName:(NSString *)name {
  NSStackView *container = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (container) {
    [self rebuildSegmentDistributionBar:container values:values];
  }
}

// 22. Tag Input Field Control
- (NSView *)makeTagInputFieldWithName:(NSString *)name tags:(NSArray<NSString *> *)tags {
  NSStackView *vstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [vstack setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [vstack setAlignment:NSLayoutAttributeLeading];
  [vstack setSpacing:6.0];

  NSStackView *tagFlow = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [tagFlow setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [tagFlow setSpacing:6.0];
  [tagFlow setAlignment:NSLayoutAttributeCenterY];

  NSTextField *input = [[NSTextField alloc] initWithFrame:NSZeroRect];
  [input setPlaceholderString:@"Add tag and press Enter..."];
  [input setTarget:self];
  [input setAction:@selector(handleTagInputSubmitted:)];
  input.identifier = name;
  [input.widthAnchor constraintEqualToConstant:180.0].active = YES;

  NSStackView *row = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [row setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [row setSpacing:8.0];
  [row setAlignment:NSLayoutAttributeCenterY];

  [row addArrangedSubview:tagFlow];
  [row addArrangedSubview:input];
  [vstack addArrangedSubview:row];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = vstack;
  objc_setAssociatedObject(vstack, "tagFlowStack", tagFlow, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(vstack, "tagInputField", input, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(vstack, "currentTags", [NSMutableArray arrayWithArray:tags], OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self rebuildTagInputField:vstack name:name];
  [self addControlToLayout:vstack];
  return vstack;
}

- (void)rebuildTagInputField:(NSStackView *)vstack name:(NSString *)name {
  NSStackView *tagFlow = objc_getAssociatedObject(vstack, "tagFlowStack");
  NSMutableArray<NSString *> *tags = objc_getAssociatedObject(vstack, "currentTags");
  if (!tagFlow || !tags) return;

  for (NSView *v in [tagFlow.arrangedSubviews copy]) {
    [tagFlow removeArrangedSubview:v];
    [v removeFromSuperview];
  }

  for (NSString *tag in tags) {
    NSButton *btn = [NSButton buttonWithTitle:[NSString stringWithFormat:@"%@  ✕", tag] target:self action:@selector(handleTagInputFieldRemove:)];
    [btn setBezelStyle:NSBezelStyleInline];
    [btn setFont:[NSFont systemFontOfSize:11.0 weight:NSFontWeightMedium]];
    btn.identifier = [NSString stringWithFormat:@"%@___%@", name, tag];
    [tagFlow addArrangedSubview:btn];
  }
}

- (void)handleTagInputSubmitted:(id)sender {
  NSTextField *input = (NSTextField *)sender;
  NSString *name = input.identifier;
  NSString *val = [[input stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if (val.length > 0) {
    NSStackView *vstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
    if (vstack) {
      NSMutableArray<NSString *> *tags = objc_getAssociatedObject(vstack, "currentTags");
      if (tags && ![tags containsObject:val]) {
        [tags addObject:val];
        [self rebuildTagInputField:vstack name:name];
      }
    }
    [input setStringValue:@""];
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "add_tag", [val UTF8String]);
  }
}

- (void)handleTagInputFieldRemove:(id)sender {
  NSButton *btn = (NSButton *)sender;
  NSString *ident = btn.identifier;
  NSRange range = [ident rangeOfString:@"___"];
  if (range.location != NSNotFound) {
    NSString *name = [ident substringToIndex:range.location];
    NSString *tag = [ident substringFromIndex:range.location + 3];
    NSStackView *vstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
    if (vstack) {
      NSMutableArray<NSString *> *tags = objc_getAssociatedObject(vstack, "currentTags");
      if (tags) {
        [tags removeObject:tag];
        [self rebuildTagInputField:vstack name:name];
      }
    }
    vlang_dispatch_event(self.win_ptr, [name UTF8String], "delete_tag", [tag UTF8String]);
  }
}

- (void)setTagInputTags:(NSArray<NSString *> *)tags forName:(NSString *)name {
  NSStackView *vstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (vstack) {
    objc_setAssociatedObject(vstack, "currentTags", [NSMutableArray arrayWithArray:tags], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self rebuildTagInputField:vstack name:name];
  }
}

- (NSString *)getTagInputTagsForName:(NSString *)name {
  NSStackView *vstack = (NSStackView *)self.controlsByName[[name lowercaseString]];
  if (vstack) {
    NSMutableArray<NSString *> *tags = objc_getAssociatedObject(vstack, "currentTags");
    if (tags) return [tags componentsJoinedByString:@","];
  }
  return @"";
}

// 23. Window Status Dock Footer Control
- (NSView *)makeStatusDockWithName:(NSString *)name statusText:(NSString *)statusText dotColor:(NSString *)dotColor countText:(NSString *)countText {
  NSBox *box = [[NSBox alloc] initWithFrame:NSZeroRect];
  [box setBoxType:NSBoxCustom];
  [box setCornerRadius:8.0];
  [box setFillColor:[NSColor colorWithRed:0.12 green:0.14 blue:0.18 alpha:1.0]];
  [box setBorderColor:[NSColor colorWithWhite:1.0 alpha:0.15]];

  NSStackView *hstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hstack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hstack setAlignment:NSLayoutAttributeCenterY];
  [hstack setSpacing:10.0];
  [hstack setEdgeInsets:NSEdgeInsetsMake(6, 12, 6, 12)];

  NSBox *dot = [[NSBox alloc] initWithFrame:NSZeroRect];
  [dot setBoxType:NSBoxCustom];
  [dot setCornerRadius:5.0];
  [dot setFillColor:colorFromHexString(dotColor ? dotColor : @"#34c759")];
  [dot.widthAnchor constraintEqualToConstant:10.0].active = YES;
  [dot.heightAnchor constraintEqualToConstant:10.0].active = YES;

  NSTextField *sLbl = [NSTextField labelWithString:statusText ? statusText : @"System Ready"];
  [sLbl setFont:[NSFont systemFontOfSize:12.0 weight:NSFontWeightMedium]];
  [sLbl setTextColor:[NSColor whiteColor]];

  NSBox *cntBox = [[NSBox alloc] initWithFrame:NSZeroRect];
  [cntBox setBoxType:NSBoxCustom];
  [cntBox setCornerRadius:4.0];
  [cntBox setFillColor:[NSColor colorWithWhite:1.0 alpha:0.15]];

  NSTextField *cLbl = [NSTextField labelWithString:countText ? countText : @"0 items"];
  [cLbl setFont:[NSFont boldSystemFontOfSize:11.0]];
  [cLbl setTextColor:[NSColor colorWithWhite:0.8 alpha:1.0]];
  [cntBox setContentView:cLbl];

  [hstack addArrangedSubview:dot];
  [hstack addArrangedSubview:sLbl];
  [hstack addArrangedSubview:[NSView new]]; // spacer
  [hstack addArrangedSubview:cntBox];

  [box setContentView:hstack];
  [box.heightAnchor constraintEqualToConstant:34.0].active = YES;

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = box;
  objc_setAssociatedObject(box, "dockDot", dot, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(box, "dockStatusLbl", sLbl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(box, "dockCountLbl", cLbl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:box];
  return box;
}

- (void)setStatusDockInfoForName:(NSString *)name statusText:(NSString *)statusText dotColor:(NSString *)dotColor countText:(NSString *)countText {
  NSBox *box = (NSBox *)self.controlsByName[[name lowercaseString]];
  if (box) {
    NSBox *dot = objc_getAssociatedObject(box, "dockDot");
    NSTextField *sLbl = objc_getAssociatedObject(box, "dockStatusLbl");
    NSTextField *cLbl = objc_getAssociatedObject(box, "dockCountLbl");
    if (dot && dotColor) [dot setFillColor:colorFromHexString(dotColor)];
    if (sLbl && statusText) [sLbl setStringValue:statusText];
    if (cLbl && countText) [cLbl setStringValue:countText];
  }
}

// 24. Styled Info Callout Alert Card Control
- (NSView *)makeInfoCalloutWithName:(NSString *)name title:(NSString *)title message:(NSString *)message styleType:(NSString *)styleType buttonText:(NSString *)buttonText {
  NSBox *box = [[NSBox alloc] initWithFrame:NSZeroRect];
  [box setBoxType:NSBoxCustom];
  [box setCornerRadius:8.0];

  NSString *accentHex = @"#007aff";
  NSColor *bgColor = [NSColor colorWithRed:0.1 green:0.15 blue:0.25 alpha:1.0];
  if ([styleType isEqualToString:@"warning"]) {
    accentHex = @"#ff9500";
    bgColor = [NSColor colorWithRed:0.25 green:0.18 blue:0.1 alpha:1.0];
  } else if ([styleType isEqualToString:@"danger"]) {
    accentHex = @"#ff3b30";
    bgColor = [NSColor colorWithRed:0.25 green:0.12 blue:0.12 alpha:1.0];
  } else if ([styleType isEqualToString:@"success"]) {
    accentHex = @"#34c759";
    bgColor = [NSColor colorWithRed:0.1 green:0.22 blue:0.14 alpha:1.0];
  }
  [box setFillColor:bgColor];
  [box setBorderColor:[NSColor clearColor]];

  NSStackView *hstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [hstack setOrientation:NSUserInterfaceLayoutOrientationHorizontal];
  [hstack setAlignment:NSLayoutAttributeCenterY];
  [hstack setSpacing:12.0];
  [hstack setEdgeInsets:NSEdgeInsetsMake(10, 12, 10, 12)];

  NSBox *accentBar = [[NSBox alloc] initWithFrame:NSZeroRect];
  [accentBar setBoxType:NSBoxCustom];
  [accentBar setCornerRadius:2.0];
  [accentBar setFillColor:colorFromHexString(accentHex)];
  [accentBar.widthAnchor constraintEqualToConstant:4.0].active = YES;
  [accentBar.heightAnchor constraintEqualToConstant:32.0].active = YES;

  NSStackView *vstack = [[NSStackView alloc] initWithFrame:NSZeroRect];
  [vstack setOrientation:NSUserInterfaceLayoutOrientationVertical];
  [vstack setAlignment:NSLayoutAttributeLeading];
  [vstack setSpacing:2.0];

  NSTextField *tLbl = [NSTextField labelWithString:title ? title : @"Information"];
  [tLbl setFont:[NSFont boldSystemFontOfSize:13.0]];
  [tLbl setTextColor:[NSColor whiteColor]];

  NSTextField *mLbl = [NSTextField labelWithString:message ? message : @""];
  [mLbl setFont:[NSFont systemFontOfSize:11.0]];
  [mLbl setTextColor:[NSColor colorWithWhite:0.85 alpha:1.0]];

  [vstack addArrangedSubview:tLbl];
  [vstack addArrangedSubview:mLbl];

  [hstack addArrangedSubview:accentBar];
  [hstack addArrangedSubview:vstack];

  if (buttonText && buttonText.length > 0) {
    NSButton *btn = [NSButton buttonWithTitle:buttonText target:self action:@selector(handleCalloutBtnClicked:)];
    [btn setBezelStyle:NSBezelStyleRounded];
    [btn setFont:[NSFont systemFontOfSize:11.0 weight:NSFontWeightMedium]];
    btn.identifier = name;
    [hstack addArrangedSubview:btn];
  }

  [box setContentView:hstack];

  if (!self.controlsByName) self.controlsByName = [NSMutableDictionary dictionary];
  self.controlsByName[[name lowercaseString]] = box;
  objc_setAssociatedObject(box, "calloutTLbl", tLbl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  objc_setAssociatedObject(box, "calloutMLbl", mLbl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

  [self addControlToLayout:box];
  return box;
}

- (void)handleCalloutBtnClicked:(id)sender {
  NSButton *btn = (NSButton *)sender;
  vlang_dispatch_event(self.win_ptr, [btn.identifier UTF8String], "click_action", "callout_action");
}

- (void)setInfoCalloutTextForName:(NSString *)name title:(NSString *)title message:(NSString *)message {
  NSBox *box = (NSBox *)self.controlsByName[[name lowercaseString]];
  if (box) {
    NSTextField *tLbl = objc_getAssociatedObject(box, "calloutTLbl");
    NSTextField *mLbl = objc_getAssociatedObject(box, "calloutMLbl");
    if (tLbl && title) [tLbl setStringValue:title];
    if (mLbl && message) [mLbl setStringValue:message];
  }
}

// Window management commands implementations
- (void)setWindowVibrancy:(NSString *)materialStr {
  if (!self.window) return;
  NSVisualEffectView *vibrancyView = [[NSVisualEffectView alloc] initWithFrame:self.window.contentView.bounds];
  [vibrancyView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
  [vibrancyView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
  if ([materialStr isEqualToString:@"hud"]) [vibrancyView setMaterial:NSVisualEffectMaterialHUDWindow];
  else if ([materialStr isEqualToString:@"sidebar"]) [vibrancyView setMaterial:NSVisualEffectMaterialSidebar];
  else if ([materialStr isEqualToString:@"popover"]) [vibrancyView setMaterial:NSVisualEffectMaterialPopover];
  else if ([materialStr isEqualToString:@"header"]) [vibrancyView setMaterial:NSVisualEffectMaterialHeaderView];
  else [vibrancyView setMaterial:NSVisualEffectMaterialWindowBackground];
  [self.window.contentView addSubview:vibrancyView positioned:NSWindowBelow relativeTo:nil];
}

- (void)setWindowCornerRadius:(double)radius {
  if (!self.window || !self.window.contentView) return;
  self.window.contentView.wantsLayer = YES;
  self.window.contentView.layer.cornerRadius = radius;
  self.window.contentView.layer.masksToBounds = YES;
}

- (void)setWindowBackgroundBlur:(BOOL)enabled {
  if (!self.window) return;
  [self.window setOpaque:!enabled];
  if (enabled) [self.window setBackgroundColor:[NSColor clearColor]];
}

- (void)flashWindowFrame:(BOOL)critical {
  if (self.window) {
    CGFloat origAlpha = self.window.alphaValue;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      context.duration = 0.12;
      self.window.animator.alphaValue = 0.35;
    } completionHandler:^{
      [NSAnimationContext runAnimationGroup:^(NSAnimationContext *ctx) {
        ctx.duration = 0.15;
        self.window.animator.alphaValue = origAlpha;
      } completionHandler:nil];
    }];
  }
  [NSApp requestUserAttention:critical ? NSCriticalRequest : NSInformationalRequest];
}

- (void)centerWindowOnActiveScreen {
  if (!self.window) return;
  NSScreen *screen = [NSScreen mainScreen];
  if (screen) {
    NSRect sRect = [screen visibleFrame];
    NSRect wRect = [self.window frame];
    CGFloat x = sRect.origin.x + (sRect.size.width - wRect.size.width) / 2.0;
    CGFloat y = sRect.origin.y + (sRect.size.height - wRect.size.height) / 2.0;
    [self.window setFrameOrigin:NSMakePoint(x, y)];
  }
}

- (void)setWindowLevelType:(NSString *)levelType {
  if (!self.window) return;
  if ([levelType isEqualToString:@"desktop"]) [self.window setLevel:kCGDesktopWindowLevel];
  else if ([levelType isEqualToString:@"floating"]) [self.window setLevel:NSFloatingWindowLevel];
  else if ([levelType isEqualToString:@"modal"]) [self.window setLevel:NSModalPanelWindowLevel];
  else if ([levelType isEqualToString:@"status"]) [self.window setLevel:NSSubmenuWindowLevel];
  else [self.window setLevel:NSNormalWindowLevel];
}

@end

// C Bridge functions for new controls and window commands
void *window_add_quick_action_bar_control(main__WindowInfo *info, const char *name, const char **labels, const char **symbols, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *lArr = [NSMutableArray arrayWithCapacity:count];
  NSMutableArray *sArr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    [lArr addObject:nsstring(labels[i])];
    [sArr addObject:nsstring(symbols[i])];
  }
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeQuickActionBarWithName:nsstring(name) labels:lArr symbols:sArr];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_quick_action_enabled(main__WindowInfo *info, const char *name, int index, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setQuickActionEnabled:(BOOL)enabled index:index forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void *window_add_accordion_group_control(main__WindowInfo *info, const char *name, const char **section_titles, int count, int expanded_index) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *tArr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    [tArr addObject:nsstring(section_titles[i])];
  }
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeAccordionGroupWithName:nsstring(name) sectionTitles:tArr expandedIndex:expanded_index];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_accordion_expanded(main__WindowInfo *info, const char *name, int index, int expanded) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setAccordionExpanded:(BOOL)expanded index:index forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void *window_add_segment_distribution_bar_control(main__WindowInfo *info, const char *name, const char **labels, const double *values, const char **hex_colors, int count, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *lArr = [NSMutableArray arrayWithCapacity:count];
  NSMutableArray *vArr = [NSMutableArray arrayWithCapacity:count];
  NSMutableArray *cArr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    [lArr addObject:nsstring(labels[i])];
    [vArr addObject:@(values[i])];
    [cArr addObject:nsstring(hex_colors[i])];
  }
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeSegmentDistributionBarWithName:nsstring(name) labels:lArr values:vArr hexColors:cArr height:height];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_segment_distribution_values(main__WindowInfo *info, const char *name, const double *values, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *vArr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    [vArr addObject:@(values[i])];
  }
  void (^runBlock)(void) = ^{
    [delegate setSegmentDistributionValues:vArr forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void *window_add_tag_input_field_control(main__WindowInfo *info, const char *name, const char **tags, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *tArr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    [tArr addObject:nsstring(tags[i])];
  }
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeTagInputFieldWithName:nsstring(name) tags:tArr];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_tag_input_tags(main__WindowInfo *info, const char *name, const char **tags, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *tArr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    [tArr addObject:nsstring(tags[i])];
  }
  void (^runBlock)(void) = ^{
    [delegate setTagInputTags:tArr forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

const char *window_get_tag_input_tags(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSString *res = @"";
  void (^runBlock)(void) = ^{
    res = [delegate getTagInputTagsForName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return [res UTF8String];
}

void *window_add_status_dock_control(main__WindowInfo *info, const char *name, const char *status_text, const char *dot_color, const char *count_text) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeStatusDockWithName:nsstring(name) statusText:nsstring(status_text) dotColor:nsstring(dot_color) countText:nsstring(count_text)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_status_dock_info(main__WindowInfo *info, const char *name, const char *status_text, const char *dot_color, const char *count_text) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setStatusDockInfoForName:nsstring(name) statusText:nsstring(status_text) dotColor:nsstring(dot_color) countText:nsstring(count_text)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void *window_add_info_callout_control(main__WindowInfo *info, const char *name, const char *title, const char *message, const char *style_type, const char *button_text) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeInfoCalloutWithName:nsstring(name) title:nsstring(title) message:nsstring(message) styleType:nsstring(style_type) buttonText:nsstring(button_text)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_info_callout_text(main__WindowInfo *info, const char *name, const char *title, const char *message) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setInfoCalloutTextForName:nsstring(name) title:nsstring(title) message:nsstring(message)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_set_vibrancy(main__WindowInfo *info, const char *material) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setWindowVibrancy:nsstring(material)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_set_corner_radius(main__WindowInfo *info, double radius) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setWindowCornerRadius:radius];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_set_background_blur(main__WindowInfo *info, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setWindowBackgroundBlur:(BOOL)enabled];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_flash_frame(main__WindowInfo *info, int critical) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate flashWindowFrame:(BOOL)critical];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_center_on_active_screen(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate centerWindowOnActiveScreen];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_set_level_type(main__WindowInfo *info, const char *level_type) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setWindowLevelType:nsstring(level_type)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}








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

void *window_add_stat_card_control(main__WindowInfo *info, const char *name, const char *title, const char *value, const char *trend, const char *trend_style) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeStatCardWithName:nsstring(name) title:nsstring(title) value:nsstring(value) trend:nsstring(trend) trendStyle:nsstring(trend_style)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void window_set_stat_card_value(main__WindowInfo *info, const char *name, const char *value, const char *trend, const char *trend_style) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = [delegate viewForControlName:nsstring(name)];
    if ([view isKindOfClass:[NSBox class]]) {
      NSBox *box = (NSBox *)view;
      NSView *content = [box contentView];
      if ([content isKindOfClass:[NSStackView class]]) {
        NSStackView *stack = (NSStackView *)content;
        for (NSView *subview in stack.arrangedSubviews) {
          if (subview.tag == 101 && [subview isKindOfClass:[NSTextField class]]) {
            [(NSTextField *)subview setStringValue:nsstring(value)];
          } else if (subview.tag == 102 && [subview isKindOfClass:[NSTextField class]]) {
            if (trend) {
              [(NSTextField *)subview setStringValue:nsstring(trend)];
            }
            if (trend_style) {
              NSColor *trendColor = [NSColor secondaryLabelColor];
              NSString *style = [nsstring(trend_style) lowercaseString];
              if ([style isEqualToString:@"success"]) {
                trendColor = [NSColor systemGreenColor];
              } else if ([style isEqualToString:@"error"]) {
                trendColor = [NSColor systemRedColor];
              } else if ([style isEqualToString:@"warning"]) {
                trendColor = [NSColor systemOrangeColor];
              } else if ([style isEqualToString:@"info"]) {
                trendColor = [NSColor systemBlueColor];
              }
              [(NSTextField *)subview setTextColor:trendColor];
            }
          }
        }
      }
    }
  });
}

void *window_add_banner_control(main__WindowInfo *info, const char *name, const char *text, const char *style) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeBannerWithName:nsstring(name) text:nsstring(text) style:nsstring(style)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void *window_add_section_header_control(main__WindowInfo *info, const char *name, const char *title, const char *subtitle) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeSectionHeaderWithName:nsstring(name) title:nsstring(title) subtitle:nsstring(subtitle)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void *window_add_vertical_slider_control(main__WindowInfo *info, const char *name, int value, int min_val, int max_val, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeVerticalSliderWithName:nsstring(name) value:value minValue:min_val maxValue:max_val height:height];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void *window_add_chip_group_control(main__WindowInfo *info, const char *name, const char **chips, int count, const char *selected) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
      [arr addObject:nsstring(chips[i])];
    }
    control = [delegate makeChipGroupWithName:nsstring(name) chips:arr selected:nsstring(selected)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
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

void window_set_banner_value(main__WindowInfo *info, const char *name, const char *text) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = [delegate viewForControlName:nsstring(name)];
    if ([view isKindOfClass:[NSBox class]]) {
      NSBox *box = (NSBox *)view;
      NSView *content = [box contentView];
      if ([content isKindOfClass:[NSTextField class]]) {
        [(NSTextField *)content setStringValue:nsstring(text)];
      }
    }
  });
}

void window_set_vertical_slider_value(main__WindowInfo *info, const char *name, int value) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = [delegate viewForControlName:nsstring(name)];
    if ([view isKindOfClass:[NSSlider class]]) {
      [(NSSlider *)view setIntegerValue:value];
    }
  });
}

void window_set_chip_group_selected(main__WindowInfo *info, const char *name, const char *selected) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = [delegate viewForControlName:nsstring(name)];
    if ([view isKindOfClass:[NSSegmentedControl class]]) {
      NSSegmentedControl *seg = (NSSegmentedControl *)view;
      NSString *sel = nsstring(selected);
      for (NSInteger i = 0; i < seg.segmentCount; i++) {
        if ([[seg labelForSegment:i] isEqualToString:sel]) {
          [seg setSelectedSegment:i];
          break;
        }
      }
    }
  });
}

void window_set_badge_value(main__WindowInfo *info, const char *name, const char *text, const char *styleStr) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = [delegate viewForControlName:nsstring(name)];
    if ([view isKindOfClass:[NSBox class]]) {
      NSBox *box = (NSBox *)view;
      NSView *content = [box contentView];
      if ([content isKindOfClass:[NSTextField class]]) {
        [(NSTextField *)content setStringValue:nsstring(text)];
      }
      if (styleStr) {
        NSString *style = [nsstring(styleStr) lowercaseString];
        NSColor *bgColor = [NSColor colorWithCalibratedWhite:0.5 alpha:0.15];
        NSColor *textColor = [NSColor secondaryLabelColor];
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
        }
        box.layer.backgroundColor = [bgColor CGColor];
        if ([content isKindOfClass:[NSTextField class]]) {
          [(NSTextField *)content setTextColor:textColor];
        }
      }
    }
  });
}

void *window_add_status_indicator_control(main__WindowInfo *info, const char *name, const char *label, const char *status) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeStatusIndicatorWithName:nsstring(name) label:nsstring(label) status:nsstring(status)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void window_set_status_indicator_value(main__WindowInfo *info, const char *name, const char *statusStr) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = [delegate viewForControlName:nsstring(name)];
    if ([view isKindOfClass:[NSStackView class]]) {
      NSStackView *stack = (NSStackView *)view;
      for (NSView *sub in stack.arrangedSubviews) {
        if ([sub.identifier isEqualToString:@"101"] && [sub isKindOfClass:[NSBox class]]) {
          NSBox *dot = (NSBox *)sub;
          NSColor *dotColor = [NSColor secondaryLabelColor];
          NSString *st = [nsstring(statusStr) lowercaseString];
          if ([st isEqualToString:@"active"] || [st isEqualToString:@"online"] || [st isEqualToString:@"success"]) {
            dotColor = [NSColor systemGreenColor];
          } else if ([st isEqualToString:@"warning"] || [st isEqualToString:@"busy"]) {
            dotColor = [NSColor systemOrangeColor];
          } else if ([st isEqualToString:@"error"] || [st isEqualToString:@"offline"]) {
            dotColor = [NSColor systemRedColor];
          }
          dot.layer.backgroundColor = [dotColor CGColor];
        }
      }
    }
  });
}

void *window_add_metric_meter_control(main__WindowInfo *info, const char *name, const char *title, int value, int min_val, int max_val, const char *unit) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeMetricMeterWithName:nsstring(name) title:nsstring(title) value:(double)value minVal:(double)min_val maxVal:(double)max_val unit:nsstring(unit)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void window_set_metric_meter_value(main__WindowInfo *info, const char *name, int value) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = [delegate viewForControlName:nsstring(name)];
    if ([view isKindOfClass:[NSBox class]]) {
      NSBox *box = (NSBox *)view;
      NSView *content = [box contentView];
      if ([content isKindOfClass:[NSStackView class]]) {
        NSStackView *vstack = (NSStackView *)content;
        for (NSView *vsub in vstack.arrangedSubviews) {
          if ([vsub isKindOfClass:[NSStackView class]]) {
            NSStackView *hstack = (NSStackView *)vsub;
            for (NSView *hsub in hstack.arrangedSubviews) {
              if (hsub.tag == 101 && [hsub isKindOfClass:[NSTextField class]]) {
                [(NSTextField *)hsub setIntegerValue:value];
              }
            }
          } else if ([vsub.identifier isEqualToString:@"102"] && [vsub isKindOfClass:[NSProgressIndicator class]]) {
            [(NSProgressIndicator *)vsub setDoubleValue:(double)value];
          }
        }
      }
    }
  });
}

void *window_add_avatar_card_control(main__WindowInfo *info, const char *name, const char *title, const char *subtitle, const char *status) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeAvatarCardWithName:nsstring(name) title:nsstring(title) subtitle:nsstring(subtitle) status:nsstring(status)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void window_set_avatar_card_value(main__WindowInfo *info, const char *name, const char *title, const char *subtitle, const char *statusStr) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = [delegate viewForControlName:nsstring(name)];
    if ([view isKindOfClass:[NSBox class]]) {
      NSBox *box = (NSBox *)view;
      NSView *content = [box contentView];
      if ([content isKindOfClass:[NSStackView class]]) {
        NSStackView *hstack = (NSStackView *)content;
        for (NSView *hsub in hstack.arrangedSubviews) {
          if ([hsub isKindOfClass:[NSStackView class]]) {
            NSStackView *vstack = (NSStackView *)hsub;
            for (NSView *vsub in vstack.arrangedSubviews) {
              if (vsub.tag == 101 && [vsub isKindOfClass:[NSTextField class]]) {
                if (title) [(NSTextField *)vsub setStringValue:nsstring(title)];
              } else if (vsub.tag == 102 && [vsub isKindOfClass:[NSTextField class]]) {
                if (subtitle) [(NSTextField *)vsub setStringValue:nsstring(subtitle)];
              }
            }
          } else if ([hsub.identifier isEqualToString:@"104"] && [hsub isKindOfClass:[NSBox class]]) {
            NSBox *badge = (NSBox *)hsub;
            if (statusStr) {
              NSString *st = [nsstring(statusStr) lowercaseString];
              NSColor *bColor = [NSColor colorWithCalibratedWhite:0.5 alpha:0.15];
              NSColor *tColor = [NSColor secondaryLabelColor];
              if ([st isEqualToString:@"online"] || [st isEqualToString:@"active"] || [st isEqualToString:@"success"]) {
                bColor = [NSColor colorWithCalibratedRed:0.18 green:0.49 blue:0.20 alpha:0.15];
                tColor = [NSColor systemGreenColor];
              } else if ([st isEqualToString:@"busy"] || [st isEqualToString:@"warning"]) {
                bColor = [NSColor colorWithCalibratedRed:0.95 green:0.60 blue:0.00 alpha:0.15];
                tColor = [NSColor systemOrangeColor];
              } else if ([st isEqualToString:@"offline"] || [st isEqualToString:@"error"]) {
                bColor = [NSColor colorWithCalibratedRed:0.83 green:0.18 blue:0.18 alpha:0.15];
                tColor = [NSColor systemRedColor];
              }
              badge.layer.backgroundColor = [bColor CGColor];
              NSView *bContent = [badge contentView];
              if ([bContent isKindOfClass:[NSTextField class]]) {
                [(NSTextField *)bContent setStringValue:nsstring(statusStr)];
                [(NSTextField *)bContent setTextColor:tColor];
              }
            }
          }
        }
      }
    }
  });
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
  BOOL hasModifier = NO;

  for (NSString *part in parts) {
    NSString *token = [[part lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([token isEqualToString:@""] || [token isEqualToString:@"cmd"] || [token isEqualToString:@"command"]) {
      mask |= NSEventModifierFlagCommand;
      if (![token isEqualToString:@""]) {
        hasModifier = YES;
      }
    } else if ([token isEqualToString:@"ctrl"] || [token isEqualToString:@"control"]) {
      mask |= NSEventModifierFlagControl;
      hasModifier = YES;
    } else if ([token isEqualToString:@"opt"] || [token isEqualToString:@"option"] || [token isEqualToString:@"alt"]) {
      mask |= NSEventModifierFlagOption;
      hasModifier = YES;
    } else if ([token isEqualToString:@"shift"]) {
      mask |= NSEventModifierFlagShift;
      hasModifier = YES;
    } else {
      key = token;
    }
  }

  if (!hasModifier && key.length > 0) {
    mask |= NSEventModifierFlagCommand;
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
  
  void (^runBlock)(void) = ^{
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

    NSMenu *mainMenu = [NSApp mainMenu];
    if (mainMenu) {
      [NSApp setMainMenu:mainMenu];
    }
  };

  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
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
      NSView *targetView = view;
      ModernTextField *cmdTf = objc_getAssociatedObject(view, "cmdTextField");
      if (cmdTf) {
        targetView = cmdTf;
      }
      [delegate.window makeFirstResponder:targetView];
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

char *window_get_clipboard_text(void) {
  __block NSString *value = @"";
  void (^runBlock)(void) = ^{
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSString *pbText = [pasteboard stringForType:NSPasteboardTypeString];
    value = pbText ?: @"";
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }

  return strdup([value UTF8String]);
}

int window_reveal_in_finder(const char *path) {
  if (!path || strlen(path) == 0) {
    return 0;
  }

  __block int result = 0;
  NSString *targetPath = nsstring(path);
  void (^runBlock)(void) = ^{
    if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
      NSURL *url = [NSURL fileURLWithPath:targetPath];
      [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[url]];
      result = 1;
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return result;
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

void *window_add_date_time_picker_control(main__WindowInfo *info, const char *name, const char *datetime) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  return [delegate makeDateTimePickerWithName:nsstring(name) dateTime:nsstring(datetime)];
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
static void applySelectionToCollectionView(NSCollectionView *collectionView, NSString *text) {
  if (!collectionView) {
    return;
  }

  NSString *trimmed = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if (trimmed.length == 0 || [trimmed isEqualToString:@"-1"]) {
    [collectionView deselectAll:nil];
    return;
  }

  NSScanner *scanner = [NSScanner scannerWithString:trimmed];
  long long parsed = 0;
  if (![scanner scanLongLong:&parsed] || ![scanner isAtEnd]) {
    [collectionView deselectAll:nil];
    return;
  }

  NSInteger index = (NSInteger)parsed;
  if (index < 0) {
    [collectionView deselectAll:nil];
    return;
  }

  NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
  NSSet *paths = [NSSet setWithObject:path];
  [collectionView selectItemsAtIndexPaths:paths scrollPosition:NSCollectionViewScrollPositionNone];
  if ([collectionView respondsToSelector:@selector(scrollToItemsAtIndexPaths:scrollPosition:)]) {
    [collectionView scrollToItemsAtIndexPaths:paths scrollPosition:NSCollectionViewScrollPositionNearestHorizontalEdge];
  }
}

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
    } else if ([doc isKindOfClass:[NSCollectionView class]]) {
      applySelectionToCollectionView((NSCollectionView *)doc, nsText);
      return;
    }
  }

  if ([view isKindOfClass:[NSCollectionView class]]) {
    applySelectionToCollectionView((NSCollectionView *)view, nsText);
    return;
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
  } else if ([view isKindOfClass:[NSBox class]]) {
    NSBox *box = (NSBox *)view;
    NSView *content = [box contentView];
    if ([content isKindOfClass:[NSTextField class]] && content.tag == 201) {
      [(NSTextField *)content setStringValue:nsText];
    } else if ([content isKindOfClass:[NSStackView class]]) {
      NSStackView *stack = (NSStackView *)content;
      for (NSView *subview in stack.arrangedSubviews) {
        if (subview.tag == 101 && [subview isKindOfClass:[NSTextField class]]) {
          [(NSTextField *)subview setStringValue:nsText];
        }
      }
    }
  } else if ([view isKindOfClass:[NSColorWell class]]) {
    [(NSColorWell *)view setColor:colorFromString(text)];
  } else if ([view isKindOfClass:[NSDatePicker class]]) {
    NSDatePicker *picker = (NSDatePicker *)view;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDatePickerElementFlags elements = [picker datePickerElements];
    BOOL hasDate = (elements & NSYearMonthDayDatePickerElementFlag) != 0;
    BOOL hasTime = (elements & (NSHourMinuteDatePickerElementFlag | NSHourMinuteSecondDatePickerElementFlag)) != 0;
    BOOL hasSeconds = (elements & NSHourMinuteSecondDatePickerElementFlag) != 0;
    
    NSDate *date = nil;
    if (hasDate && hasTime) {
      if (hasSeconds) {
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      } else {
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
      }
      date = [formatter dateFromString:nsText];
    }
    
    if (!date && hasDate) {
      [formatter setDateFormat:@"yyyy-MM-dd"];
      date = [formatter dateFromString:nsText];
    }
    
    if (!date && hasTime) {
      if (hasSeconds) {
        [formatter setDateFormat:@"HH:mm:ss"];
      } else {
        [formatter setDateFormat:@"HH:mm"];
      }
      date = [formatter dateFromString:nsText];
    }
    
    if (!date) {
      [formatter setDateStyle:NSDateFormatterMediumStyle];
      date = [formatter dateFromString:nsText];
    }
    
    if (date) {
      [picker setDateValue:date];
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
    if ([doc isKindOfClass:[NSTextView class]] ||
        [doc isKindOfClass:[NSOutlineView class]] ||
        [doc isKindOfClass:[NSTableView class]]) {
      view = doc;
    }
  }
  
  if ([view isKindOfClass:[NSCollectionView class]]) {
    NSCollectionView *collectionView = (NSCollectionView *)view;
    NSIndexPath *selected = [[collectionView selectionIndexPaths] anyObject];
    if (selected) {
      return strdup([[NSString stringWithFormat:@"%ld", (long)selected.item] UTF8String]);
    }
    return strdup("");
  }

  if ([view isKindOfClass:[NSScrollView class]]) {
    NSView *doc = [(NSScrollView *)view documentView];
    if ([doc isKindOfClass:[NSCollectionView class]]) {
      NSCollectionView *collectionView = (NSCollectionView *)doc;
      NSIndexPath *selected = [[collectionView selectionIndexPaths] anyObject];
      if (selected) {
        return strdup([[NSString stringWithFormat:@"%ld", (long)selected.item] UTF8String]);
      }
      return strdup("");
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
    result = [NSString stringWithFormat:@"#%02x%02x%02x", (int)(r * 255.99), (int)(g * 255.99), (int)(b * 255.99)];
  } else if ([view isKindOfClass:[NSDatePicker class]]) {
    NSDatePicker *picker = (NSDatePicker *)view;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDatePickerElementFlags elements = [picker datePickerElements];
    BOOL hasDate = (elements & NSYearMonthDayDatePickerElementFlag) != 0;
    BOOL hasTime = (elements & (NSHourMinuteDatePickerElementFlag | NSHourMinuteSecondDatePickerElementFlag)) != 0;
    BOOL hasSeconds = (elements & NSHourMinuteSecondDatePickerElementFlag) != 0;
    
    if (hasDate && hasTime) {
      if (hasSeconds) {
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      } else {
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
      }
    } else if (hasDate) {
      [formatter setDateFormat:@"yyyy-MM-dd"];
    } else if (hasTime) {
      if (hasSeconds) {
        [formatter setDateFormat:@"HH:mm:ss"];
      } else {
        [formatter setDateFormat:@"HH:mm"];
      }
    } else {
      [formatter setDateFormat:@"yyyy-MM-dd"];
    }
    result = [formatter stringFromDate:[picker dateValue]];
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
  
  void (^runBlock)(void) = ^{
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
  };
  
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_set_list_selected(main__WindowInfo *info, const char *name, int index) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  void (^runBlock)(void) = ^{
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
  };
  
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
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
  
  void (^runBlock)(void) = ^{
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
  };
  
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_select_all_list_items(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  void (^runBlock)(void) = ^{
    NSTableView *tableView = listTableViewForKey(delegate, key);
    if (tableView) {
      [tableView selectAll:nil];
    }
  };
  
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_clear_list_selection(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *key = [[nsstring(name) lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  
  void (^runBlock)(void) = ^{
    NSTableView *tableView = listTableViewForKey(delegate, key);
    if (tableView) {
      [tableView deselectAll:nil];
    }
  };
  
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
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
  void (^runBlock)(void) = ^{
    NSBox *spacer = [[NSBox alloc] initWithFrame:NSZeroRect];
    [spacer setBoxType:NSBoxCustom];
    [spacer setBorderType:NSNoBorder];
    [spacer setWantsLayer:YES];
    spacer.layer.backgroundColor = [NSColor clearColor].CGColor;
    spacer.translatesAutoresizingMaskIntoConstraints = NO;
    [spacer.heightAnchor constraintEqualToConstant:height].active = YES;
    [delegate addControlToLayout:spacer];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_add_horizontal_spacer(main__WindowInfo *info, int width) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    NSBox *spacer = [[NSBox alloc] initWithFrame:NSZeroRect];
    [spacer setBoxType:NSBoxCustom];
    [spacer setBorderType:NSNoBorder];
    [spacer setWantsLayer:YES];
    spacer.layer.backgroundColor = [NSColor clearColor].CGColor;
    spacer.translatesAutoresizingMaskIntoConstraints = NO;
    [spacer.widthAnchor constraintEqualToConstant:width].active = YES;
    [delegate addControlToLayout:spacer];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_add_separator(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    NSBox *separator = [[NSBox alloc] initWithFrame:NSZeroRect];
    [separator setBoxType:NSBoxCustom];
    [separator setBorderType:NSLineBorder];
    [separator setBorderWidth:1.0];
    [separator setBorderColor:modernBorderColor()];
    [separator setWantsLayer:YES];
    separator.translatesAutoresizingMaskIntoConstraints = NO;
    [separator.heightAnchor constraintEqualToConstant:1.0].active = YES;
    [delegate addControlToLayout:separator];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
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

void window_run_on_main_thread_sync(void *callback_fn, void *context) {
  void (*cb)(void *) = (void (*)(void *))callback_fn;
  if (!cb) {
    return;
  }

  if ([NSThread isMainThread]) {
    cb(context);
  } else {
    dispatch_sync(dispatch_get_main_queue(), ^{
      cb(context);
    });
  }
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

void *window_add_time_picker_control(main__WindowInfo *info, const char *name, const char *time) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeTimePickerWithName:nsstring(name) time:nsstring(time)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void window_set_time_picker_value(main__WindowInfo *info, const char *name, const char *time) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = [delegate viewForControlName:nsstring(name)];
    if ([view isKindOfClass:[NSDatePicker class]]) {
      NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
      [formatter setDateFormat:@"HH:mm:ss"];
      NSDate *date = [formatter dateFromString:nsstring(time)];
      if (!date) {
        [formatter setDateFormat:@"HH:mm"];
        date = [formatter dateFromString:nsstring(time)];
      }
      if (date) {
        [(NSDatePicker *)view setDateValue:date];
      }
      [formatter release];
    }
  });
}

const char *window_get_time_picker_value(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block const char *res = "";
  void (^runBlock)(void) = ^{
    NSView *view = [delegate viewForControlName:nsstring(name)];
    if ([view isKindOfClass:[NSDatePicker class]]) {
      NSDate *date = [(NSDatePicker *)view dateValue];
      NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
      [formatter setDateFormat:@"HH:mm:ss"];
      NSString *str = [formatter stringFromDate:date];
      if (str) {
        res = strdup([str UTF8String]);
      }
      [formatter release];
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return res;
}

void window_add_tray_icon_control(main__WindowInfo *info, const char *name, const char *symbol, const char *title) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate makeTrayIconWithName:nsstring(name) symbol:nsstring(symbol) title:nsstring(title)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_set_tray_icon_value(main__WindowInfo *info, const char *name, const char *symbol, const char *title) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSStatusItem *item = delegate.trayIconsByName[[nsstring(name) lowercaseString]];
    if (item) {
      if (@available(macOS 11.0, *)) {
        if (symbol && strlen(symbol) > 0) {
          NSImage *img = [NSImage imageWithSystemSymbolName:nsstring(symbol) accessibilityDescription:nil];
          if (img) {
            item.button.image = img;
          }
        }
      }
      if (title && strlen(title) > 0) {
        item.button.title = nsstring(title);
      }
    }
  });
}

void *window_add_collapsible_section_control(main__WindowInfo *info, const char *name, const char *title, int expanded) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeCollapsibleSectionWithName:nsstring(name) title:nsstring(title) expanded:expanded == 1];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void window_set_collapsible_section_expanded(main__WindowInfo *info, const char *name, int expanded) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = [delegate viewForControlName:nsstring(name)];
    if ([view isKindOfClass:[NSBox class]]) {
      NSBox *box = (NSBox *)view;
      NSView *content = [box contentView];
      if ([content isKindOfClass:[NSStackView class]]) {
        NSStackView *hstack = (NSStackView *)content;
        for (NSView *sub in hstack.arrangedSubviews) {
          if ([sub.identifier isEqualToString:@"101"] && [sub isKindOfClass:[NSButton class]]) {
            [(NSButton *)sub setState:expanded ? NSControlStateValueOn : NSControlStateValueOff];
          }
        }
      }
    }
  });
}

void *window_add_code_editor_control(main__WindowInfo *info, const char *name, const char *code, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeCodeEditorWithName:nsstring(name) code:nsstring(code) height:height];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void window_set_code_editor_value(main__WindowInfo *info, const char *name, const char *code) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = [delegate viewForControlName:nsstring(name)];
    if ([view isKindOfClass:[NSScrollView class]]) {
      NSView *doc = [(NSScrollView *)view documentView];
      if ([doc isKindOfClass:[NSTextView class]]) {
        [(NSTextView *)doc setString:nsstring(code)];
      }
    }
  });
}

const char *window_get_code_editor_value(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block const char *res = "";
  void (^runBlock)(void) = ^{
    NSView *view = [delegate viewForControlName:nsstring(name)];
    if ([view isKindOfClass:[NSScrollView class]]) {
      NSView *doc = [(NSScrollView *)view documentView];
      if ([doc isKindOfClass:[NSTextView class]]) {
        NSString *str = [(NSTextView *)doc string];
        if (str) {
          res = strdup([str UTF8String]);
        }
      }
    }
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return res;
}

void *window_add_timeline_view_control(main__WindowInfo *info, const char *name, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeTimelineViewWithName:nsstring(name) height:height];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
  return (__bridge void *)control;
}

void window_add_timeline_entry(main__WindowInfo *info, const char *name, const char *time_str, const char *title, const char *detail, const char *style) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    [delegate addTimelineEntryToName:nsstring(name) time:nsstring(time_str) title:nsstring(title) detail:nsstring(detail) style:nsstring(style)];
  });
}

void window_clear_timeline(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    [delegate clearTimelineName:nsstring(name)];
  });
}

void window_add_toolbar_button(main__WindowInfo *info, const char *id_str, const char *label, const char *symbol) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate addToolbarItemWithIdentifier:nsstring(id_str) label:nsstring(label) symbol:nsstring(symbol)];
  };
  if ([NSThread isMainThread]) {
    runBlock();
  } else {
    dispatch_sync(dispatch_get_main_queue(), runBlock);
  }
}

void window_set_toolbar_visible(main__WindowInfo *info, int visible) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    if (delegate.window && delegate.window.toolbar) {
      [delegate.window.toolbar setVisible:visible == 1];
    }
  });
}

void window_set_subtitle(main__WindowInfo *info, const char *subtitle) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (delegate.window && [delegate.window respondsToSelector:@selector(setSubtitle:)]) {
      [delegate.window setSubtitle:nsstring(subtitle)];
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

const char *window_get_subtitle(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSString *res = @"";
  void (^runBlock)(void) = ^{
    if (delegate.window && [delegate.window respondsToSelector:@selector(subtitle)]) {
      res = [delegate.window subtitle];
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res ? [res UTF8String] : "";
}

void window_set_titlebar_appears_transparent(main__WindowInfo *info, int transparent) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      delegate.window.titlebarAppearsTransparent = (transparent != 0);
      if (transparent != 0) {
        delegate.window.styleMask |= NSWindowStyleMaskFullSizeContentView;
      } else {
        delegate.window.styleMask &= ~NSWindowStyleMaskFullSizeContentView;
      }
      [delegate.window.contentView setNeedsDisplay:YES];
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

int window_get_titlebar_appears_transparent(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block BOOL res = NO;
  void (^runBlock)(void) = ^{
    if (delegate.window) { res = delegate.window.titlebarAppearsTransparent; }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res ? 1 : 0;
}

void window_set_full_size_content_view(main__WindowInfo *info, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      if (enabled) {
        delegate.window.styleMask |= NSWindowStyleMaskFullSizeContentView;
      } else {
        delegate.window.styleMask &= ~NSWindowStyleMaskFullSizeContentView;
      }
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

int window_get_full_size_content_view(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block BOOL res = NO;
  void (^runBlock)(void) = ^{
    if (delegate.window) { res = (delegate.window.styleMask & NSWindowStyleMaskFullSizeContentView) != 0; }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res ? 1 : 0;
}

void window_set_movable(main__WindowInfo *info, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      [delegate.window setMovable:(enabled != 0)];
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

int window_get_movable(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block BOOL res = YES;
  void (^runBlock)(void) = ^{
    if (delegate.window) { res = [delegate.window isMovable]; }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res ? 1 : 0;
}

void window_set_window_level(main__WindowInfo *info, const char *level) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (!delegate.window) return;
    NSString *lvlStr = nsstring(level);
    if ([lvlStr isEqualToString:@"floating"]) {
      [delegate.window setLevel:NSFloatingWindowLevel];
    } else if ([lvlStr isEqualToString:@"modal"]) {
      [delegate.window setLevel:NSModalPanelWindowLevel];
    } else if ([lvlStr isEqualToString:@"mainMenu"]) {
      [delegate.window setLevel:NSMainMenuWindowLevel];
    } else if ([lvlStr isEqualToString:@"statusBar"]) {
      [delegate.window setLevel:NSSubmenuWindowLevel];
    } else if ([lvlStr isEqualToString:@"screenSaver"]) {
      [delegate.window setLevel:NSScreenSaverWindowLevel];
    } else {
      [delegate.window setLevel:NSNormalWindowLevel];
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_set_aspect_ratio(main__WindowInfo *info, double width_ratio, double height_ratio) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    if (delegate.window) {
      [delegate.window setAspectRatio:NSMakeSize(width_ratio, height_ratio)];
    }
  });
}

void window_reset_aspect_ratio(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    if (delegate.window) {
      [delegate.window setAspectRatio:NSMakeSize(0, 0)];
    }
  });
}

void window_bounce_dock_icon(int critical) {
  dispatch_async(dispatch_get_main_queue(), ^{
    [NSApp requestUserAttention:critical ? NSCriticalRequest : NSInformationalRequest];
  });
}

void *window_add_rating_control(main__WindowInfo *info, const char *name, int value, int max_stars) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSControl *control = nil;
  void (^runBlock)(void) = ^{
    control = (NSControl *)[delegate makeRatingWithName:nsstring(name) value:value maxStars:max_stars];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_rating_value(main__WindowInfo *info, const char *name, int value) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    [delegate setRatingValue:value forName:nsstring(name)];
  });
}

int window_get_rating_value(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int res = 0;
  void (^runBlock)(void) = ^{
    res = [delegate ratingValueForName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res;
}

void *window_add_range_slider_control(main__WindowInfo *info, const char *name, int min_val, int max_val, int low_val, int high_val) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSControl *control = nil;
  void (^runBlock)(void) = ^{
    control = (NSControl *)[delegate makeRangeSliderWithName:nsstring(name) min:min_val max:max_val low:low_val high:high_val];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_range_slider_values(main__WindowInfo *info, const char *name, int low_val, int high_val) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    [delegate setRangeSliderLow:low_val high:high_val forName:nsstring(name)];
  });
}

int window_get_range_slider_low(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int res = 0;
  void (^runBlock)(void) = ^{
    res = [delegate rangeSliderLowForName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res;
}

int window_get_range_slider_high(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int res = 0;
  void (^runBlock)(void) = ^{
    res = [delegate rangeSliderHighForName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res;
}

void *window_add_split_button_control(main__WindowInfo *info, const char *name, const char *title, const char **menu_items, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *arr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    [arr addObject:nsstring(menu_items[i])];
  }
  __block NSControl *control = nil;
  void (^runBlock)(void) = ^{
    control = (NSControl *)[delegate makeSplitButtonWithName:nsstring(name) title:nsstring(title) menuItems:arr];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void *window_add_tag_cloud_control(main__WindowInfo *info, const char *name, const char **tags, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *arr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    [arr addObject:nsstring(tags[i])];
  }
  __block NSControl *control = nil;
  void (^runBlock)(void) = ^{
    control = (NSControl *)[delegate makeTagCloudWithName:nsstring(name) tags:arr];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_tag_cloud_tags(main__WindowInfo *info, const char *name, const char **tags, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *arr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    [arr addObject:nsstring(tags[i])];
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    [delegate setTagCloudTags:arr forName:nsstring(name)];
  });
}

void *window_add_wizard_stepper_control(main__WindowInfo *info, const char *name, const char **steps, int count, int current_step) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *arr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    [arr addObject:nsstring(steps[i])];
  }
  __block NSControl *control = nil;
  void (^runBlock)(void) = ^{
    control = (NSControl *)[delegate makeWizardStepperWithName:nsstring(name) steps:arr currentStep:current_step];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_wizard_stepper_step(main__WindowInfo *info, const char *name, int step) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    [delegate setWizardStepperStep:step forName:nsstring(name)];
  });
}

void window_begin_grid(main__WindowInfo *info, const char *name, int columns, int spacing) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    [delegate beginGridWithName:nsstring(name) columns:columns spacing:spacing];
  });
}

void window_end_grid(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    [delegate endGrid];
  });
}

void window_begin_flex_box(main__WindowInfo *info, const char *name, const char *direction, const char *justify, const char *align) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    [delegate beginFlexBoxWithName:nsstring(name) direction:nsstring(direction) justify:nsstring(justify) align:nsstring(align)];
  });
}

void window_end_flex_box(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    [delegate endFlexBox];
  });
}

void window_set_control_alignment_by_name(main__WindowInfo *info, const char *name, const char *alignment) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    [delegate setControlAlignment:nsstring(alignment) forName:nsstring(name)];
  });
}

void window_set_control_expand_fill_by_name(main__WindowInfo *info, const char *name, int expand) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    [delegate setControlExpandFill:(expand != 0) forName:nsstring(name)];
  });
}

void *window_add_gauge_control(main__WindowInfo *info, const char *name, const char *title, int value, int min_val, int max_val, const char *unit) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeGaugeWithName:nsstring(name) title:nsstring(title) value:value minVal:min_val maxVal:max_val unit:nsstring(unit)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_gauge_value(main__WindowInfo *info, const char *name, int value) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setGaugeValue:value forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

int window_get_gauge_value(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int res = 0;
  void (^runBlock)(void) = ^{
    res = [delegate gaugeValueForName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res;
}

void *window_add_pagination_control(main__WindowInfo *info, const char *name, int total_pages, int current_page) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makePaginationWithName:nsstring(name) totalPages:total_pages currentPage:current_page];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_pagination_page(main__WindowInfo *info, const char *name, int page, int total_pages) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setPaginationPage:page totalPages:total_pages forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

int window_get_pagination_page(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int res = 1;
  void (^runBlock)(void) = ^{
    res = [delegate paginationPageForName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res;
}

void *window_add_activity_feed_control(main__WindowInfo *info, const char *name, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeActivityFeedWithName:nsstring(name) height:height];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_add_activity_feed_item(main__WindowInfo *info, const char *name, const char *timestamp, const char *message, const char *level) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate addActivityFeedItemToName:nsstring(name) timestamp:nsstring(timestamp) message:nsstring(message) level:nsstring(level)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_clear_activity_feed(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate clearActivityFeedName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void *window_add_markdown_view_control(main__WindowInfo *info, const char *name, const char *markdown_text, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeMarkdownViewWithName:nsstring(name) markdownText:nsstring(markdown_text) height:height];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_markdown_view_text(main__WindowInfo *info, const char *name, const char *markdown_text) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setMarkdownViewText:nsstring(markdown_text) forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

const char *window_get_markdown_view_text(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block const char *res = "";
  void (^runBlock)(void) = ^{
    NSString *str = [delegate markdownViewTextForName:nsstring(name)];
    if (str) res = strdup([str UTF8String]);
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res;
}

void *window_add_sparkline_control(main__WindowInfo *info, const char *name, const double *values, int count, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *arr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    [arr addObject:@(values[i])];
  }
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeSparklineWithName:nsstring(name) values:arr height:height];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_sparkline_data(main__WindowInfo *info, const char *name, const double *values, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *arr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    [arr addObject:@(values[i])];
  }
  void (^runBlock)(void) = ^{
    [delegate setSparklineValues:arr forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void *window_add_pin_code_control(main__WindowInfo *info, const char *name, int digits) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makePinCodeWithName:nsstring(name) digits:digits];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_pin_code_value(main__WindowInfo *info, const char *name, const char *code) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setPinCodeValue:nsstring(code) forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

const char *window_get_pin_code_value(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block const char *res = "";
  void (^runBlock)(void) = ^{
    NSString *str = [delegate pinCodeValueForName:nsstring(name)];
    if (str) res = strdup([str UTF8String]);
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res;
}

void *window_add_color_palette_control(main__WindowInfo *info, const char *name, const char **hex_colors, int count, const char *selected) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *arr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    [arr addObject:nsstring(hex_colors[i])];
  }
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeColorPaletteWithName:nsstring(name) colors:arr selected:nsstring(selected)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_color_palette_selected(main__WindowInfo *info, const char *name, const char *hex_color) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setColorPaletteSelected:nsstring(hex_color) forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

const char *window_get_color_palette_selected(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block const char *res = "";
  void (^runBlock)(void) = ^{
    NSString *str = [delegate colorPaletteSelectedForName:nsstring(name)];
    if (str) res = strdup([str UTF8String]);
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res;
}

void *window_add_timeline_control(main__WindowInfo *info, const char *name, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeTimelineWithName:nsstring(name) height:height];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_add_timeline_item(main__WindowInfo *info, const char *name, const char *title, const char *subtitle, const char *time_str, const char *status) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate addTimelineItemToName:nsstring(name) title:nsstring(title) subtitle:nsstring(subtitle) timeStr:nsstring(time_str) status:nsstring(status)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void *window_add_metric_card_control(main__WindowInfo *info, const char *name, const char *title, const char *value, const char *change_badge, const char *subtitle) {

  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeMetricCardWithName:nsstring(name) title:nsstring(title) value:nsstring(value) changeBadge:nsstring(change_badge) subtitle:nsstring(subtitle)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_metric_card_value(main__WindowInfo *info, const char *name, const char *value, const char *change_badge) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setMetricCardValue:nsstring(value) changeBadge:nsstring(change_badge) forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void *window_add_tab_pills_control(main__WindowInfo *info, const char *name, const char **items, int count, const char *selected) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *arr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    [arr addObject:nsstring(items[i])];
  }
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeTabPillsWithName:nsstring(name) items:arr selected:nsstring(selected)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_tab_pills_active(main__WindowInfo *info, const char *name, const char *selected) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setTabPillsActive:nsstring(selected) forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

const char *window_get_tab_pills_active(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block const char *res = "";
  void (^runBlock)(void) = ^{
    NSString *str = [delegate tabPillsActiveForName:nsstring(name)];
    if (str) res = strdup([str UTF8String]);
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res;
}

void *window_add_transfer_list_control(main__WindowInfo *info, const char *name, const char **available, int avail_count, const char **selected, int sel_count, bool multi_select) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *aArr = [NSMutableArray arrayWithCapacity:avail_count];
  for (int i = 0; i < avail_count; i++) [aArr addObject:nsstring(available[i])];
  NSMutableArray *sArr = [NSMutableArray arrayWithCapacity:sel_count];
  for (int i = 0; i < sel_count; i++) [sArr addObject:nsstring(selected[i])];

  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeTransferListWithName:nsstring(name) available:aArr selected:sArr multiSelect:(BOOL)multi_select];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}


void *window_add_audio_waveform_control(main__WindowInfo *info, const char *name, const double *amplitudes, int count, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *arr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) [arr addObject:@(amplitudes[i])];
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeAudioWaveformWithName:nsstring(name) amplitudes:arr height:height];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_audio_waveform_data(main__WindowInfo *info, const char *name, const double *amplitudes, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *arr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) [arr addObject:@(amplitudes[i])];
  void (^runBlock)(void) = ^{
    [delegate setAudioWaveformAmplitudes:arr forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void *window_add_rating_breakdown_control(main__WindowInfo *info, const char *name, double avg_score, int total_reviews, const double *star_percentages, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *arr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) [arr addObject:@(star_percentages[i])];
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeRatingBreakdownWithName:nsstring(name) avgScore:avg_score totalReviews:total_reviews starPercentages:arr];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_rating_breakdown_data(main__WindowInfo *info, const char *name, double avg_score, int total_reviews, const double *star_percentages, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *arr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) [arr addObject:@(star_percentages[i])];
  void (^runBlock)(void) = ^{
    [delegate setRatingBreakdownData:avg_score totalReviews:total_reviews starPercentages:arr forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void *window_add_code_view_control(main__WindowInfo *info, const char *name, const char *lang, const char *code_text, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeCodeViewWithName:nsstring(name) lang:nsstring(lang) codeText:nsstring(code_text) height:height];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_code_view_text(main__WindowInfo *info, const char *name, const char *code_text) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setCodeViewText:nsstring(code_text) forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

const char *window_get_code_view_text(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block const char *res = "";
  void (^runBlock)(void) = ^{
    NSString *str = [delegate codeViewTextForName:nsstring(name)];
    if (str) res = strdup([str UTF8String]);
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res;
}

// Alert Banner C Bridge
void *window_add_alert_banner_control(main__WindowInfo *info, const char *name, const char *title, const char *message, const char *style) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeAlertBannerWithName:nsstring(name) title:nsstring(title) message:nsstring(message) style:nsstring(style)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_alert_banner_value(main__WindowInfo *info, const char *name, const char *title, const char *message, const char *style) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setAlertBannerValueForName:nsstring(name) title:nsstring(title) message:nsstring(message) style:nsstring(style)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

// Step Tracker C Bridge
void *window_add_step_tracker_control(main__WindowInfo *info, const char *name, const char **steps, int count, int current_step) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *arr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) [arr addObject:nsstring(steps[i])];
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeStepTrackerWithName:nsstring(name) steps:arr currentStep:current_step];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_step_tracker_step(main__WindowInfo *info, const char *name, int step) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setStepTrackerStep:step forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

int window_get_step_tracker_step(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int res = 0;
  void (^runBlock)(void) = ^{
    res = [delegate stepTrackerStepForName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res;
}

// Filter Chips C Bridge
void *window_add_filter_chips_control(main__WindowInfo *info, const char *name, const char **chips, int count, const char **selected, int sel_count, bool multi_select) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *chipArr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) [chipArr addObject:nsstring(chips[i])];
  NSMutableArray *selArr = [NSMutableArray arrayWithCapacity:sel_count];
  for (int i = 0; i < sel_count; i++) [selArr addObject:nsstring(selected[i])];

  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeFilterChipsWithName:nsstring(name) chips:chipArr selected:selArr multiSelect:multi_select];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_filter_chips_selected(main__WindowInfo *info, const char *name, const char **selected, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *selArr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) [selArr addObject:nsstring(selected[i])];
  void (^runBlock)(void) = ^{
    [delegate setFilterChipsSelected:selArr forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

const char *window_get_filter_chips_selected(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block const char *res = "";
  void (^runBlock)(void) = ^{
    NSString *str = [delegate filterChipsSelectedForName:nsstring(name)];
    if (str) res = strdup([str UTF8String]);
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res;
}

// File Picker Field C Bridge
void *window_add_file_picker_field_control(main__WindowInfo *info, const char *name, const char *initial_path, const char *button_title, bool folder_only) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeFilePickerFieldWithName:nsstring(name) initialPath:nsstring(initial_path) buttonTitle:nsstring(button_title) folderOnly:folder_only];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_file_picker_path(main__WindowInfo *info, const char *name, const char *path) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setFilePickerPath:nsstring(path) forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

const char *window_get_file_picker_path(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block const char *res = "";
  void (^runBlock)(void) = ^{
    NSString *str = [delegate filePickerPathForName:nsstring(name)];
    if (str) res = strdup([str UTF8String]);
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res;
}

// Radial Gauge C Bridge
void *window_add_radial_gauge_control(main__WindowInfo *info, const char *name, const char *title, double value, double min_val, double max_val, const char *unit) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeRadialGaugeWithName:nsstring(name) title:nsstring(title) value:value minVal:min_val maxVal:max_val unit:nsstring(unit)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_radial_gauge_value(main__WindowInfo *info, const char *name, double value) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setRadialGaugeValue:value forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

double window_get_radial_gauge_value(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block double res = 0.0;
  void (^runBlock)(void) = ^{
    res = [delegate radialGaugeValueForName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res;
}

// Key Value Card C Bridge
void *window_add_key_value_card_control(main__WindowInfo *info, const char *name, const char *title, const char **keys, const char **values, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *kArr = [NSMutableArray arrayWithCapacity:count];
  NSMutableArray *vArr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    [kArr addObject:nsstring(keys[i])];
    [vArr addObject:nsstring(values[i])];
  }
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeKeyValueCardWithName:nsstring(name) title:nsstring(title) keys:kArr values:vArr];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_key_value_card_data(main__WindowInfo *info, const char *name, const char **keys, const char **values, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *kArr = [NSMutableArray arrayWithCapacity:count];
  NSMutableArray *vArr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    [kArr addObject:nsstring(keys[i])];
    [vArr addObject:nsstring(values[i])];
  }
  void (^runBlock)(void) = ^{
    [delegate setKeyValueCardDataForName:nsstring(name) keys:kArr values:vArr];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

// 6 Developer Controls C Bridges
void *window_add_diff_view_control(main__WindowInfo *info, const char *name, const char *old_text, const char *new_text, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeDiffViewWithName:nsstring(name) oldText:nsstring(old_text) newText:nsstring(new_text) height:height];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_diff_view_text(main__WindowInfo *info, const char *name, const char *old_text, const char *new_text) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setDiffViewTextForName:nsstring(name) oldText:nsstring(old_text) newText:nsstring(new_text)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void *window_add_json_tree_control(main__WindowInfo *info, const char *name, const char *json_str, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeJsonTreeWithName:nsstring(name) jsonStr:nsstring(json_str) height:height];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_json_tree_data(main__WindowInfo *info, const char *name, const char *json_str) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setJsonTreeDataForName:nsstring(name) jsonStr:nsstring(json_str)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void *window_add_http_request_card_control(main__WindowInfo *info, const char *name, const char *method, const char *url, int status_code, int response_time_ms) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeHttpRequestCardWithName:nsstring(name) method:nsstring(method) url:nsstring(url) statusCode:status_code responseTimeMs:response_time_ms];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_http_request_card_data(main__WindowInfo *info, const char *name, const char *method, const char *url, int status_code, int response_time_ms) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setHttpRequestCardDataForName:nsstring(name) method:nsstring(method) url:nsstring(url) statusCode:status_code responseTimeMs:response_time_ms];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void *window_add_terminal_view_control(main__WindowInfo *info, const char *name, const char *prompt_text, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeTerminalViewWithName:nsstring(name) promptText:nsstring(prompt_text) height:height];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_append_terminal_line(main__WindowInfo *info, const char *name, const char *line_text, int line_type) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate appendTerminalLine:nsstring(line_text) lineType:line_type forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_clear_terminal(main__WindowInfo *info, const char *name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate clearTerminalForName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void *window_add_resource_monitor_control(main__WindowInfo *info, const char *name, int cpu_pct, int mem_pct, int disk_pct, int net_kbps) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeResourceMonitorWithName:nsstring(name) cpuPct:cpu_pct memPct:mem_pct diskPct:disk_pct netKbps:net_kbps];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_resource_monitor_metrics(main__WindowInfo *info, const char *name, int cpu_pct, int mem_pct, int disk_pct, int net_kbps) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setResourceMonitorMetricsForName:nsstring(name) cpuPct:cpu_pct memPct:mem_pct diskPct:disk_pct netKbps:net_kbps];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void *window_add_env_vars_control(main__WindowInfo *info, const char *name, const char *title, const char **keys, const char **values, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *kArr = [NSMutableArray arrayWithCapacity:count];
  NSMutableArray *vArr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    [kArr addObject:nsstring(keys[i])];
    [vArr addObject:nsstring(values[i])];
  }
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeEnvVarsWithName:nsstring(name) title:nsstring(title) keys:kArr values:vArr];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_env_vars_data(main__WindowInfo *info, const char *name, const char **keys, const char **values, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *kArr = [NSMutableArray arrayWithCapacity:count];
  NSMutableArray *vArr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    [kArr addObject:nsstring(keys[i])];
    [vArr addObject:nsstring(values[i])];
  }
  void (^runBlock)(void) = ^{
    [delegate setEnvVarsDataForName:nsstring(name) keys:kArr values:vArr];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void *window_add_badge_button_control(main__WindowInfo *info, const char *name, const char *title, int count, const char *badge_color) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeBadgeButtonWithName:nsstring(name) title:nsstring(title) count:count badgeColor:nsstring(badge_color)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_badge_button_count(main__WindowInfo *info, const char *name, int count) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setBadgeButtonCount:count forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void *window_add_command_palette_control(main__WindowInfo *info, const char *name, const char *placeholder, const char *shortcut_hint) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeCommandPaletteWithName:nsstring(name) placeholder:nsstring(placeholder) shortcutHint:nsstring(shortcut_hint)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_command_palette_text(main__WindowInfo *info, const char *name, const char *text) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setCommandPaletteText:nsstring(text) forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void *window_add_status_banner_control(main__WindowInfo *info, const char *name, const char *title, const char *message, const char *style_type) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeStatusBannerWithName:nsstring(name) title:nsstring(title) message:nsstring(message) styleType:nsstring(style_type)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_status_banner_text(main__WindowInfo *info, const char *name, const char *title, const char *message, const char *style_type) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setStatusBannerTextForName:nsstring(name) title:nsstring(title) message:nsstring(message) styleType:nsstring(style_type)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void *window_add_pill_toggle_control(main__WindowInfo *info, const char *name, const char **options, int count, int selected_index) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *oArr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    [oArr addObject:nsstring(options[i])];
  }
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makePillToggleWithName:nsstring(name) options:oArr selectedIndex:selected_index];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_pill_toggle_selected(main__WindowInfo *info, const char *name, int selected_index) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setPillToggleSelected:selected_index forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void *window_add_color_swatch_panel_control(main__WindowInfo *info, const char *name, const char **hex_colors, int count, const char *selected_color) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSMutableArray *cArr = [NSMutableArray arrayWithCapacity:count];
  for (int i = 0; i < count; i++) {
    [cArr addObject:nsstring(hex_colors[i])];
  }
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeColorSwatchPanelWithName:nsstring(name) hexColors:cArr selectedColor:nsstring(selected_color)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_color_swatch_selected(main__WindowInfo *info, const char *name, const char *hex_color) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setColorSwatchSelected:nsstring(hex_color) forName:nsstring(name)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void *window_add_hotkey_badge_control(main__WindowInfo *info, const char *name, const char *shortcut_str, const char *description) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSView *control = nil;
  void (^runBlock)(void) = ^{
    control = [delegate makeHotkeyBadgeWithName:nsstring(name) shortcutStr:nsstring(shortcut_str) description:nsstring(description)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return (__bridge void *)control;
}

void window_set_hotkey_badge_shortcut(main__WindowInfo *info, const char *name, const char *shortcut_str, const char *description) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    [delegate setHotkeyBadgeShortcutForName:nsstring(name) shortcutStr:nsstring(shortcut_str) description:nsstring(description)];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

double window_get_corner_radius(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block double res = 0.0;
  void (^runBlock)(void) = ^{
    if (delegate.window && delegate.window.contentView && delegate.window.contentView.layer) {
      res = (double)delegate.window.contentView.layer.cornerRadius;
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res;
}

const char *window_get_window_level(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block const char *res = "";
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      NSInteger lvl = delegate.window.level;
      if (lvl == NSFloatingWindowLevel) res = "floating";
      else if (lvl == NSModalPanelWindowLevel) res = "modal";
      else if (lvl == NSMainMenuWindowLevel) res = "mainMenu";
      else if (lvl == NSSubmenuWindowLevel) res = "statusBar";
      else if (lvl == NSScreenSaverWindowLevel) res = "screenSaver";
      else res = "normal";
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res;
}

void window_set_fullscreen(main__WindowInfo *info, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    if (!delegate.window) return;
    BOOL isFS = (delegate.window.styleMask & NSWindowStyleMaskFullScreen) != 0;
    if ((enabled && !isFS) || (!enabled && isFS)) {
      [delegate.window toggleFullScreen:nil];
    }
  });
}

void window_snap_to_edge(main__WindowInfo *info, const char *edge) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    if (!delegate.window) return;
    NSScreen *screen = delegate.window.screen ?: [NSScreen mainScreen];
    NSRect visibleFrame = screen.visibleFrame;
    NSRect winFrame = delegate.window.frame;
    CGFloat x = winFrame.origin.x;
    CGFloat y = winFrame.origin.y;
    NSString *e = [nsstring(edge) lowercaseString];

    if ([e containsString:@"left"]) {
      x = visibleFrame.origin.x;
    } else if ([e containsString:@"right"]) {
      x = NSMaxX(visibleFrame) - winFrame.size.width;
    } else if ([e isEqualToString:@"center"] || [e isEqualToString:@"middle"]) {
      x = visibleFrame.origin.x + (visibleFrame.size.width - winFrame.size.width) / 2.0;
    }

    if ([e containsString:@"top"]) {
      y = NSMaxY(visibleFrame) - winFrame.size.height;
    } else if ([e containsString:@"bottom"]) {
      y = visibleFrame.origin.y;
    } else if ([e isEqualToString:@"center"] || [e isEqualToString:@"middle"]) {
      y = visibleFrame.origin.y + (visibleFrame.size.height - winFrame.size.height) / 2.0;
    }

    [delegate.window setFrameOrigin:NSMakePoint(x, y)];
  });
}

void window_set_bounds(main__WindowInfo *info, int x, int y, int width, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      NSScreen *screen = delegate.window.screen ?: [NSScreen mainScreen];
      CGFloat screenH = screen.frame.size.height;
      NSRect frame = NSMakeRect((CGFloat)x, screenH - (CGFloat)y - (CGFloat)height, (CGFloat)width, (CGFloat)height);
      [delegate.window setFrame:frame display:YES animate:NO];
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_get_bounds(main__WindowInfo *info, int *out_x, int *out_y, int *out_w, int *out_h) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      NSScreen *screen = delegate.window.screen ?: [NSScreen mainScreen];
      CGFloat screenH = screen.frame.size.height;
      NSRect frame = delegate.window.frame;
      if (out_x) *out_x = (int)frame.origin.x;
      if (out_y) *out_y = (int)(screenH - frame.origin.y - frame.size.height);
      if (out_w) *out_w = (int)frame.size.width;
      if (out_h) *out_h = (int)frame.size.height;
    } else {
      if (out_x) *out_x = 0;
      if (out_y) *out_y = 0;
      if (out_w) *out_w = 0;
      if (out_h) *out_h = 0;
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

int window_has_aspect_ratio(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block BOOL res = NO;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      NSSize ar = delegate.window.aspectRatio;
      res = (ar.width > 0.0 && ar.height > 0.0);
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res ? 1 : 0;
}

void window_set_ignores_mouse_events(main__WindowInfo *info, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      [delegate.window setIgnoresMouseEvents:(enabled != 0)];
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

int window_get_ignores_mouse_events(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block BOOL res = NO;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      res = [delegate.window ignoresMouseEvents];
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res ? 1 : 0;
}

void window_set_hides_on_deactivate(main__WindowInfo *info, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      [delegate.window setHidesOnDeactivate:(enabled != 0)];
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

int window_get_hides_on_deactivate(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block BOOL res = NO;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      res = [delegate.window hidesOnDeactivate];
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res ? 1 : 0;
}

void window_set_prevents_app_termination(main__WindowInfo *info, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if ([NSApp respondsToSelector:@selector(setPreventsApplicationTerminationWhenUnenrolled:)]) {
      [NSApp setPreventsApplicationTerminationWhenUnenrolled:(enabled != 0)];
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

int window_get_prevents_app_termination(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block BOOL res = YES;
  void (^runBlock)(void) = ^{
    if ([NSApp respondsToSelector:@selector(preventsApplicationTerminationWhenUnenrolled)]) {
      res = [NSApp preventsApplicationTerminationWhenUnenrolled];
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res ? 1 : 0;
}

void window_set_represented_filename(main__WindowInfo *info, const char *filepath) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      NSString *path = nsstring(filepath);
      [delegate.window setRepresentedFilename:path];
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

const char *window_get_represented_filename(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSString *res = @"";
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      res = [delegate.window representedFilename] ?: @"";
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return [res UTF8String];
}

void window_set_frame_autosave_name(main__WindowInfo *info, const char *autosave_name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      if (autosave_name && strlen(autosave_name) > 0) {
        [delegate.window setFrameAutosaveName:nsstring(autosave_name)];
      } else {
        [delegate.window setFrameAutosaveName:nil];
      }
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

const char *window_get_frame_autosave_name(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block NSString *res = @"";
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      NSString *name = [delegate.window frameAutosaveName];
      res = name ?: @"";
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return strdup([res UTF8String]);
}

int window_save_frame(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block BOOL saved = NO;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      NSString *name = [delegate.window frameAutosaveName];
      if (name.length > 0) {
        [delegate.window saveFrameUsingName:name];
        saved = YES;
      }
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return saved ? 1 : 0;
}

int window_restore_frame(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block BOOL restored = NO;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      NSString *name = [delegate.window frameAutosaveName];
      if (name.length > 0) {
        restored = [delegate.window setFrameUsingName:name];
      }
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return restored ? 1 : 0;
}

int window_capture_screenshot(main__WindowInfo *info, const char *file_path) {
  if (!file_path || strlen(file_path) == 0) {
    return 0;
  }

  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block BOOL wrote = NO;
  NSString *path = nsstring(file_path);

  void (^runBlock)(void) = ^{
    if (!delegate.window) {
      return;
    }

    NSView *contentView = [delegate.window contentView];
    if (!contentView) {
      return;
    }

    NSRect bounds = [contentView bounds];
    NSBitmapImageRep *bitmapRep = [contentView bitmapImageRepForCachingDisplayInRect:bounds];
    if (!bitmapRep) {
      return;
    }

    [contentView cacheDisplayInRect:bounds toBitmapImageRep:bitmapRep];
    NSData *pngData = [bitmapRep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
    if (pngData) {
      wrote = [pngData writeToFile:path atomically:YES];
    }
  };

  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return wrote ? 1 : 0;
}

void window_set_document_edited(main__WindowInfo *info, int edited) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      [delegate.window setDocumentEdited:(edited != 0)];
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

int window_is_document_edited(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block BOOL res = NO;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      res = [delegate.window isDocumentEdited];
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res ? 1 : 0;
}

void window_fade_in(main__WindowInfo *info, int duration_ms) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    if (!delegate.window) return;
    double sec = (double)duration_ms / 1000.0;
    if (sec <= 0.0) sec = 0.25;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      context.duration = sec;
      delegate.window.animator.alphaValue = 1.0;
    } completionHandler:nil];
  });
}

void window_fade_out(main__WindowInfo *info, int duration_ms) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    if (!delegate.window) return;
    double sec = (double)duration_ms / 1000.0;
    if (sec <= 0.0) sec = 0.25;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
      context.duration = sec;
      delegate.window.animator.alphaValue = 0.0;
    } completionHandler:nil];
  });
}

void window_order_front(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    if (delegate.window) {
      [delegate.window orderFront:nil];
      [NSApp activateIgnoringOtherApps:YES];
    }
  });
}

void window_order_back(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  dispatch_async(dispatch_get_main_queue(), ^{
    if (delegate.window) {
      [delegate.window orderBack:nil];
    }
  });
}

void window_set_alpha(main__WindowInfo *info, double alpha) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      delegate.window.alphaValue = (CGFloat)alpha;
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

double window_get_alpha(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block double res = 1.0;
  void (^runBlock)(void) = ^{
    if (delegate.window) { res = (double)delegate.window.alphaValue; }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res;
}

void window_get_min_size(main__WindowInfo *info, int *out_w, int *out_h) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      NSSize sz = delegate.window.minSize;
      if (out_w) *out_w = (int)sz.width;
      if (out_h) *out_h = (int)sz.height;
    } else {
      if (out_w) *out_w = 0;
      if (out_h) *out_h = 0;
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_get_max_size(main__WindowInfo *info, int *out_w, int *out_h) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      NSSize sz = delegate.window.maxSize;
      if (out_w) *out_w = (int)sz.width;
      if (out_h) *out_h = (int)sz.height;
    } else {
      if (out_w) *out_w = 0;
      if (out_h) *out_h = 0;
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_set_collection_behavior(main__WindowInfo *info, const char *behavior) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (!delegate.window) return;
    NSString *b = [nsstring(behavior) lowercaseString];
    NSWindowCollectionBehavior cb = delegate.window.collectionBehavior;
    if ([b isEqualToString:@"can_join_all_spaces"]) {
      cb |= NSWindowCollectionBehaviorCanJoinAllSpaces;
    } else if ([b isEqualToString:@"move_to_active_space"]) {
      cb |= NSWindowCollectionBehaviorMoveToActiveSpace;
    } else if ([b isEqualToString:@"transient"]) {
      cb |= NSWindowCollectionBehaviorTransient;
    } else if ([b isEqualToString:@"full_screen_primary"]) {
      cb |= NSWindowCollectionBehaviorFullScreenPrimary;
    } else if ([b isEqualToString:@"full_screen_auxiliary"]) {
      cb |= NSWindowCollectionBehaviorFullScreenAuxiliary;
    }
    delegate.window.collectionBehavior = cb;
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_set_close_button_enabled(main__WindowInfo *info, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      NSButton *btn = [delegate.window standardWindowButton:NSWindowCloseButton];
      if (btn) [btn setEnabled:(enabled != 0)];
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_set_minimize_button_enabled(main__WindowInfo *info, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      NSButton *btn = [delegate.window standardWindowButton:NSWindowMiniaturizeButton];
      if (btn) [btn setEnabled:(enabled != 0)];
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_set_zoom_button_enabled(main__WindowInfo *info, int enabled) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      NSButton *btn = [delegate.window standardWindowButton:NSWindowZoomButton];
      if (btn) [btn setEnabled:(enabled != 0)];
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_set_content_insets(main__WindowInfo *info, int top, int left, int bottom, int right) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (delegate.window && delegate.window.contentView) {
      NSEdgeInsets insets = NSEdgeInsetsMake((CGFloat)top, (CGFloat)left, (CGFloat)bottom, (CGFloat)right);
      [delegate.window.contentView setAdditionalSafeAreaInsets:insets];
      [delegate.window.contentView setNeedsDisplay:YES];
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_set_tabbing_mode(main__WindowInfo *info, const char *mode) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (!delegate.window) return;
    if (@available(macOS 10.12, *)) {
      NSString *m = [nsstring(mode) lowercaseString];
      if ([m isEqualToString:@"disallowed"]) {
        delegate.window.tabbingMode = NSWindowTabbingModeDisallowed;
      } else if ([m isEqualToString:@"preferred"]) {
        delegate.window.tabbingMode = NSWindowTabbingModePreferred;
      } else {
        delegate.window.tabbingMode = NSWindowTabbingModeAutomatic;
      }
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

const char *window_get_tabbing_mode(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block const char *res = "automatic";
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      if (@available(macOS 10.12, *)) {
        NSWindowTabbingMode mode = delegate.window.tabbingMode;
        if (mode == NSWindowTabbingModeDisallowed) res = "disallowed";
        else if (mode == NSWindowTabbingModePreferred) res = "preferred";
        else res = "automatic";
      }
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res;
}

void window_set_tabbing_identifier(main__WindowInfo *info, const char *identifier) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (!delegate.window) return;
    if (@available(macOS 10.12, *)) {
      delegate.window.tabbingIdentifier = nsstring(identifier);
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

const char *window_get_tabbing_identifier(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block const char *res = "";
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      if (@available(macOS 10.12, *)) {
        NSString *tid = delegate.window.tabbingIdentifier;
        if (tid) res = [tid UTF8String];
      }
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return res;
}

void window_toggle_tab_bar(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      if (@available(macOS 10.12, *)) {
        [delegate.window toggleTabBar:nil];
      }
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_select_next_tab(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      if (@available(macOS 10.12, *)) {
        [delegate.window selectNextTab:nil];
      }
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_select_previous_tab(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (delegate.window) {
      if (@available(macOS 10.12, *)) {
        [delegate.window selectPreviousTab:nil];
      }
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_set_sharing_type(main__WindowInfo *info, const char *sharing) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (!delegate.window) return;
    NSString *s = [nsstring(sharing) lowercaseString];
    if ([s isEqualToString:@"none"]) {
      delegate.window.sharingType = NSWindowSharingNone;
    } else if ([s isEqualToString:@"read_only"]) {
      delegate.window.sharingType = NSWindowSharingReadOnly;
    } else {
      delegate.window.sharingType = NSWindowSharingReadWrite;
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

// ── Appearance Override ────────────────────────────────────────────────────
void window_set_window_appearance(main__WindowInfo *info, const char *appearance_name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (!delegate.window) return;
    NSString *name = [nsstring(appearance_name) lowercaseString];
    if ([name isEqualToString:@"dark"]) {
      if (@available(macOS 10.14, *)) {
        delegate.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
      }
    } else if ([name isEqualToString:@"light"]) {
      delegate.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
    } else {
      delegate.window.appearance = nil;
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

const char *window_get_window_appearance(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block const char *result = "auto";
  void (^runBlock)(void) = ^{
    if (!delegate.window) { result = "auto"; return; }
    NSAppearance *app = delegate.window.appearance;
    if (!app) { result = "auto"; return; }
    if (@available(macOS 10.14, *)) {
      NSAppearanceName best = [app bestMatchFromAppearancesWithNames:
        @[NSAppearanceNameDarkAqua, NSAppearanceNameAqua]];
      result = [best isEqualToString:NSAppearanceNameDarkAqua] ? "dark" : "light";
    } else {
      result = "light";
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return result;
}

int window_is_system_dark_mode(main__WindowInfo *info) {
  __block int result = 0;
  void (^runBlock)(void) = ^{
    NSAppearance *appearance = [NSApp effectiveAppearance];
    if (@available(macOS 10.14, *)) {
      result = ([appearance bestMatchFromAppearancesWithNames:
        @[NSAppearanceNameDarkAqua, NSAppearanceNameAqua]] == NSAppearanceNameDarkAqua) ? 1 : 0;
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return result;
}

// ── Screen Info ────────────────────────────────────────────────────────────
void window_get_screen_frame(main__WindowInfo *info, int *out_x, int *out_y, int *out_w, int *out_h) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    NSScreen *screen = delegate.window ? [delegate.window screen] : [NSScreen mainScreen];
    if (!screen) screen = [NSScreen mainScreen];
    NSRect frame = [screen visibleFrame];
    if (out_x) *out_x = (int)NSMinX(frame);
    if (out_y) *out_y = (int)NSMinY(frame);
    if (out_w) *out_w = (int)NSWidth(frame);
    if (out_h) *out_h = (int)NSHeight(frame);
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_get_screen_full_frame(main__WindowInfo *info, int *out_x, int *out_y, int *out_w, int *out_h) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    NSScreen *screen = delegate.window ? [delegate.window screen] : [NSScreen mainScreen];
    if (!screen) screen = [NSScreen mainScreen];
    NSRect frame = [screen frame];
    if (out_x) *out_x = (int)NSMinX(frame);
    if (out_y) *out_y = (int)NSMinY(frame);
    if (out_w) *out_w = (int)NSWidth(frame);
    if (out_h) *out_h = (int)NSHeight(frame);
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

double window_get_screen_scale_factor(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block double result = 1.0;
  void (^runBlock)(void) = ^{
    NSScreen *screen = delegate.window ? [delegate.window screen] : [NSScreen mainScreen];
    result = screen ? [screen backingScaleFactor] : 1.0;
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return result;
}

// ── Cursor Control ─────────────────────────────────────────────────────────
void window_set_cursor_hidden(main__WindowInfo *info, int hidden) {
  void (^runBlock)(void) = ^{
    if (hidden) { [NSCursor hide]; } else { [NSCursor unhide]; }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

// ── Resize Indicator ───────────────────────────────────────────────────────
void window_set_shows_resize_indicator(main__WindowInfo *info, int show) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (!delegate.window) return;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [delegate.window setShowsResizeIndicator:(show != 0)];
#pragma clang diagnostic pop
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

int window_get_shows_resize_indicator(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int result = 1;
  void (^runBlock)(void) = ^{
    if (!delegate.window) return;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    result = [delegate.window showsResizeIndicator] ? 1 : 0;
#pragma clang diagnostic pop
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return result;

}

// ── Content Size Constraints ───────────────────────────────────────────────
void window_set_content_min_size(main__WindowInfo *info, int width, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (!delegate.window) return;
    delegate.window.contentMinSize = NSMakeSize((CGFloat)width, (CGFloat)height);
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_set_content_max_size(main__WindowInfo *info, int width, int height) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (!delegate.window) return;
    delegate.window.contentMaxSize = NSMakeSize(
      width <= 0 ? FLT_MAX : (CGFloat)width,
      height <= 0 ? FLT_MAX : (CGFloat)height);
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_get_content_min_size(main__WindowInfo *info, int *out_w, int *out_h) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (!delegate.window) { if(out_w)*out_w=0; if(out_h)*out_h=0; return; }
    NSSize s = delegate.window.contentMinSize;
    if (out_w) *out_w = (int)s.width;
    if (out_h) *out_h = (int)s.height;
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_get_content_max_size(main__WindowInfo *info, int *out_w, int *out_h) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    if (!delegate.window) { if(out_w)*out_w=0; if(out_h)*out_h=0; return; }
    NSSize s = delegate.window.contentMaxSize;
    if (out_w) *out_w = (int)(s.width >= FLT_MAX ? 0 : s.width);
    if (out_h) *out_h = (int)(s.height >= FLT_MAX ? 0 : s.height);
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}


// ── Tab Count ──────────────────────────────────────────────────────────────

int window_get_tab_count(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block int result = 1;
  void (^runBlock)(void) = ^{
    if (!delegate.window) return;
    if (@available(macOS 10.12, *)) {
      NSWindowTabGroup *group = [delegate.window tabGroup];
      result = group ? (int)[[group windows] count] : 1;
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return result;
}

// ── Cursor Icon & Size ─────────────────────────────────────────────────────

static char kCursorCurrentKey;
static char kCursorNameKey;
static char kCursorScaleKey;
static char kCursorTrackingKey;
static char kControlCursorOwnerKey;
static char kControlCursorAreaKey;

// Maps a friendly cursor name to the matching system NSCursor.
static NSCursor *namedBaseCursor(NSString *name) {
  NSString *n = [[[name lowercaseString]
      stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
      stringByReplacingOccurrencesOfString:@"-" withString:@"_"];
  if ([n isEqualToString:@"ibeam"] || [n isEqualToString:@"text"]) return [NSCursor IBeamCursor];
  if ([n isEqualToString:@"crosshair"] || [n isEqualToString:@"cross"]) return [NSCursor crosshairCursor];
  if ([n isEqualToString:@"pointing_hand"] || [n isEqualToString:@"hand"] || [n isEqualToString:@"link"]) return [NSCursor pointingHandCursor];
  if ([n isEqualToString:@"open_hand"] || [n isEqualToString:@"grab"]) return [NSCursor openHandCursor];
  if ([n isEqualToString:@"closed_hand"] || [n isEqualToString:@"grabbing"]) return [NSCursor closedHandCursor];
  if ([n isEqualToString:@"resize_left"]) return [NSCursor resizeLeftCursor];
  if ([n isEqualToString:@"resize_right"]) return [NSCursor resizeRightCursor];
  if ([n isEqualToString:@"resize_left_right"] || [n isEqualToString:@"resize_horizontal"] || [n isEqualToString:@"col_resize"]) return [NSCursor resizeLeftRightCursor];
  if ([n isEqualToString:@"resize_up"]) return [NSCursor resizeUpCursor];
  if ([n isEqualToString:@"resize_down"]) return [NSCursor resizeDownCursor];
  if ([n isEqualToString:@"resize_up_down"] || [n isEqualToString:@"resize_vertical"] || [n isEqualToString:@"row_resize"]) return [NSCursor resizeUpDownCursor];
  if ([n isEqualToString:@"drag_copy"] || [n isEqualToString:@"copy"]) return [NSCursor dragCopyCursor];
  if ([n isEqualToString:@"drag_link"] || [n isEqualToString:@"alias"]) return [NSCursor dragLinkCursor];
  if ([n isEqualToString:@"operation_not_allowed"] || [n isEqualToString:@"not_allowed"] || [n isEqualToString:@"forbidden"] || [n isEqualToString:@"no_drop"]) return [NSCursor operationNotAllowedCursor];
  if ([n isEqualToString:@"context_menu"] || [n isEqualToString:@"contextual_menu"]) return [NSCursor contextualMenuCursor];
  if ([n isEqualToString:@"disappearing_item"] || [n isEqualToString:@"poof"]) return [NSCursor disappearingItemCursor];
  if ([n isEqualToString:@"ibeam_vertical"] || [n isEqualToString:@"vertical_text"]) return [NSCursor IBeamCursorForVerticalLayout];
  return [NSCursor arrowCursor];
}

// Returns a copy of the given cursor scaled by the given factor (1.0 = system size).
static NSCursor *scaledCursorFrom(NSCursor *base, double scale) {
  if (scale <= 0.0 || fabs(scale - 1.0) < 0.001) return base;
  NSImage *img = [base image];
  NSSize sz = [img size];
  if (sz.width <= 0 || sz.height <= 0) return base;
  NSSize newSize = NSMakeSize(sz.width * scale, sz.height * scale);
  NSPoint hot = [base hotSpot];
  NSImage *scaled = [[NSImage alloc] initWithSize:newSize];
  [scaled lockFocus];
  [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
  [img drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height)
         fromRect:NSZeroRect
        operation:NSCompositingOperationSourceOver
         fraction:1.0];
  [scaled unlockFocus];
  return [[NSCursor alloc] initWithImage:scaled
                                 hotSpot:NSMakePoint(hot.x * scale, hot.y * scale)];
}

static double delegateCursorScale(AppDelegate *delegate) {
  NSNumber *num = objc_getAssociatedObject(delegate, &kCursorScaleKey);
  return num ? [num doubleValue] : 1.0;
}

// Small owner object that keeps a per-control cursor alive and applies it
// whenever AppKit asks for a cursor update inside the control's bounds.
@interface ControlCursorOwner : NSObject
@property (nonatomic, strong) NSCursor *cursor;
@end

@implementation ControlCursorOwner
- (void)cursorUpdate:(NSEvent *)event {
  if (self.cursor) [self.cursor set];
}
@end

// Window-wide cursor support: the delegate owns a tracking area over the whole
// content view and re-applies the chosen cursor whenever AppKit resets it.
@interface AppDelegate (SimpleGUICursor)
- (void)cursorUpdate:(NSEvent *)event;
@end

@implementation AppDelegate (SimpleGUICursor)
- (void)cursorUpdate:(NSEvent *)event {
  NSCursor *cursor = objc_getAssociatedObject(self, &kCursorCurrentKey);
  if (cursor) {
    [cursor set];
  } else {
    [[NSCursor arrowCursor] set];
  }
}
@end

static void installWindowCursorTracking(AppDelegate *delegate) {
  if (!delegate.window || !delegate.window.contentView) return;
  if (objc_getAssociatedObject(delegate, &kCursorTrackingKey)) return;
  NSView *content = delegate.window.contentView;
  NSTrackingArea *area = [[NSTrackingArea alloc]
      initWithRect:NSZeroRect
           options:(NSTrackingCursorUpdate | NSTrackingActiveInActiveApp | NSTrackingInVisibleRect)
             owner:delegate
          userInfo:nil];
  [content addTrackingArea:area];
  objc_setAssociatedObject(delegate, &kCursorTrackingKey, area, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

void window_set_cursor(main__WindowInfo *info, const char *cursor_name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *name = nsstring(cursor_name);
  void (^runBlock)(void) = ^{
    NSCursor *cursor = scaledCursorFrom(namedBaseCursor(name), delegateCursorScale(delegate));
    objc_setAssociatedObject(delegate, &kCursorCurrentKey, cursor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(delegate, &kCursorNameKey, [name lowercaseString], OBJC_ASSOCIATION_COPY_NONATOMIC);
    installWindowCursorTracking(delegate);
    [cursor set];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

const char *window_get_cursor(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block const char *result = NULL;
  void (^runBlock)(void) = ^{
    NSString *name = objc_getAssociatedObject(delegate, &kCursorNameKey);
    result = strdup(name ? [name UTF8String] : "arrow");
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return result;
}

void window_set_cursor_scale(main__WindowInfo *info, double scale) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    double clamped = scale < 0.25 ? 0.25 : (scale > 8.0 ? 8.0 : scale);
    objc_setAssociatedObject(delegate, &kCursorScaleKey, @(clamped), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    // Re-apply the active cursor (if any) at the new scale.
    NSString *name = objc_getAssociatedObject(delegate, &kCursorNameKey);
    if (name) {
      NSCursor *cursor = scaledCursorFrom(namedBaseCursor(name), clamped);
      objc_setAssociatedObject(delegate, &kCursorCurrentKey, cursor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
      installWindowCursorTracking(delegate);
      [cursor set];
    }
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

double window_get_cursor_scale(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  __block double result = 1.0;
  void (^runBlock)(void) = ^{
    result = delegateCursorScale(delegate);
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
  return result;
}

void window_reset_cursor(main__WindowInfo *info) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  void (^runBlock)(void) = ^{
    objc_setAssociatedObject(delegate, &kCursorCurrentKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(delegate, &kCursorNameKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(delegate, &kCursorScaleKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [[NSCursor arrowCursor] set];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_push_cursor(main__WindowInfo *info, const char *cursor_name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *name = nsstring(cursor_name);
  void (^runBlock)(void) = ^{
    [scaledCursorFrom(namedBaseCursor(name), delegateCursorScale(delegate)) push];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_pop_cursor(main__WindowInfo *info) {
  void (^runBlock)(void) = ^{
    [NSCursor pop];
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_set_control_cursor_by_name(main__WindowInfo *info, const char *name, const char *cursor_name) {
  AppDelegate *delegate = (AppDelegate *)info->app_delegate;
  NSString *controlName = nsstring(name);
  NSString *cursorStr = nsstring(cursor_name);
  dispatch_async(dispatch_get_main_queue(), ^{
    NSView *view = [delegate viewForControlName:controlName];
    if (!view) return;
    // Remove any previously assigned cursor tracking area.
    NSTrackingArea *oldArea = objc_getAssociatedObject(view, &kControlCursorAreaKey);
    if (oldArea) {
      [view removeTrackingArea:oldArea];
      objc_setAssociatedObject(view, &kControlCursorAreaKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
      objc_setAssociatedObject(view, &kControlCursorOwnerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    NSString *trimmed = [[cursorStr lowercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmed length] == 0 || [trimmed isEqualToString:@"default"]) {
      [[NSCursor arrowCursor] set];
      return;
    }
    ControlCursorOwner *owner = [[ControlCursorOwner alloc] init];
    owner.cursor = scaledCursorFrom(namedBaseCursor(trimmed), delegateCursorScale(delegate));
    NSTrackingArea *area = [[NSTrackingArea alloc]
        initWithRect:NSZeroRect
             options:(NSTrackingCursorUpdate | NSTrackingActiveInActiveApp | NSTrackingInVisibleRect)
               owner:owner
            userInfo:nil];
    [view addTrackingArea:area];
    objc_setAssociatedObject(view, &kControlCursorOwnerKey, owner, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(view, &kControlCursorAreaKey, area, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  });
}

void window_get_mouse_location(main__WindowInfo *info, int *out_x, int *out_y) {
  void (^runBlock)(void) = ^{
    NSPoint p = [NSEvent mouseLocation];
    if (out_x) *out_x = (int)p.x;
    if (out_y) *out_y = (int)p.y;
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}

void window_move_cursor_to(main__WindowInfo *info, int x, int y) {
  void (^runBlock)(void) = ^{
    // Convert from Cocoa (bottom-left origin) to CG global (top-left origin) coordinates.
    CGFloat screenTop = NSMaxY([[[NSScreen screens] firstObject] frame]);
    CGWarpMouseCursorPosition(CGPointMake((CGFloat)x, screenTop - (CGFloat)y));
    CGAssociateMouseAndMouseCursorPosition(true);
  };
  if ([NSThread isMainThread]) { runBlock(); } else { dispatch_sync(dispatch_get_main_queue(), runBlock); }
}






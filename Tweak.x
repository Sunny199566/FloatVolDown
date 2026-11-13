#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

static UIWindow *floatWindow;

@interface FloatBtnView : UIView
@end

@implementation FloatBtnView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor systemBlueColor];
        self.layer.cornerRadius = frame.size.width / 2.0;
        self.clipsToBounds = YES;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.25;
        self.layer.shadowRadius = 6.0;
        self.layer.shadowOffset = CGSizeMake(0, 2);

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    UIWindow *window = [self window];
    if (!window) return;

    CGPoint translation = [gesture translationInView:window];
    CGPoint center = self.center;
    center.x += translation.x;
    center.y += translation.y;

    CGFloat radius = self.bounds.size.width / 2.0;
    CGRect bounds = window.bounds;

    if (center.x < radius) center.x = radius;
    if (center.y < radius) center.y = radius;
    if (center.x > bounds.size.width  - radius) center.x = bounds.size.width  - radius;
    if (center.y > bounds.size.height - radius) center.y = bounds.size.height - radius;

    self.center = center;
    [gesture setTranslation:CGPointZero inView:window];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touchesEnded:touches withEvent:event];

    if ([[self gestureRecognizers] anyPassesTest:^BOOL(UIGestureRecognizer *g) {
        return g.state == UIGestureRecognizerStateChanged;
    }]) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *url = [NSURL URLWithString:@"xxt://launch/"];
        if (!url) return;

        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[UIApplication sharedApplication] openURL:url];
#pragma clang diagnostic pop
        }
    });
}

@end

%ctor {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        CGFloat size = 54.0;

        floatWindow = [[UIWindow alloc] initWithFrame:CGRectMake(screenBounds.size.width - size - 16.0,
                                                                screenBounds.size.height / 2.0,
                                                                size,
                                                                size)];
        floatWindow.windowLevel = 10000000;
        floatWindow.hidden = NO;
        floatWindow.clipsToBounds = NO;

        FloatBtnView *btn = [[FloatBtnView alloc] initWithFrame:floatWindow.bounds];
        [floatWindow addSubview:btn];
    });
}
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

static UIWindow *floatWindow;

@interface FloatBtnView : UIView
@end

@implementation FloatBtnView {
    UIImpactFeedbackGenerator *_feedback;
}

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

        _feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
        [_feedback prepare];

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    UIWindow *window = [self window];
    if (!window) return;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;

    CGPoint translation = [gesture translationInView:window];
    CGPoint center = self.center;
    center.x += translation.x;
    center.y += translation.y;
    self.center = center;
    [gesture setTranslation:CGPointZero inView:window];

    // 拖动结束时判断是否靠近左右边缘，自动半隐藏
    if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        CGFloat hideThreshold = 25; // 距离左右边缘25pt就触发半隐
        if (center.x < hideThreshold || center.x > screenSize.width - hideThreshold) {
            [UIView animateWithDuration:0.2 animations:^{
                self.alpha = 0.3;
            }];
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                self.alpha = 1.0;
            }];
        }
    } else {
        // 正在拖动的时候，保持完全不透明，方便你看位置
        self.alpha = 1.0;
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touchesEnded:touches withEvent:event];

    if ([[self gestureRecognizers] anyPassesTest:^BOOL(UIGestureRecognizer *g) {
        return g.state == UIGestureRecognizerStateChanged;
    }]) {
        return;
    }

    // 点一下的时候，先恢复不透明，再震动、执行链接
    self.alpha = 1.0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_feedback impactOccurred];
        [_feedback prepare];

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
#import <UIKit/UIKit.h>
#import <substrate.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreFoundation/CoreFoundation.h>

static UIView *floatBall = nil;
static NSString *const kNotificationName = @"com.user.floatball.runscript";

static void playTapHaptic() {
    UIImpactFeedbackGenerator *feed = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    [feed prepare];
    [feed impactOccurred];
}

static void sendTriggerNotification(void) {
    CFNotificationCenterPostNotification(
        CFNotificationCenterGetDarwinNotifyCenter(),
        (__bridge CFStringRef)kNotificationName,
        NULL,
        NULL,
        YES
    );
}

@interface FloatBall : UIView
@end
@implementation FloatBall
- (instancetype)init{
    self = [super initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 55, 350, 40,40)];
    if(self){
        self.backgroundColor = [UIColor systemBlueColor];
        self.layer.cornerRadius = 20;
        self.userInteractionEnabled = YES;
        self.layer.zPosition = 99999;

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
        [self addGestureRecognizer:tap];
        [self addGestureRecognizer:pan];
    }
    return self;
}
- (void)tapAction {
    playTapHaptic();
    sendTriggerNotification();
}
- (void)drag:(UIPanGestureRecognizer *)g {
    CGPoint offset = [g translationInView:self.superview];
    self.center = CGPointMake(self.center.x + offset.x, self.center.y + offset.y);
    [g setTranslation:CGPointZero inView:self.superview];
}
@end

static void (*origSBHomeScreenOverlayViewDidMoveToWindow)(id self, SEL _cmd);
void hookSBHomeScreenOverlayViewDidMoveToWindow(id self, SEL _cmd) {
    origSBHomeScreenOverlayViewDidMoveToWindow(self, _cmd);
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!floatBall){
            floatBall = [[FloatBall alloc] init];
        }
        if(floatBall.superview != self){
            [self addSubview:floatBall];
        }
    });
}

%ctor{
    Class cls = objc_getClass("SBHomeScreenOverlayView");
    if(cls){
        MSHookMessageEx(cls, @selector(didMoveToWindow), (IMP)hookSBHomeScreenOverlayViewDidMoveToWindow, (IMP *)&origSBHomeScreenOverlayViewDidMoveToWindow);
    }
}
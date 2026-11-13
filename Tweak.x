#import <UIKit/UIKit.h>
#import <substrate.h>
#import <AudioToolbox/AudioToolbox.h>

// 直接指定你的脚本，静默运行，不跳转APP
static NSString * const targetScheme = @"xxt://run?file=rec_20261113153215.lua";

static void playTapHaptic() {
    UIImpactFeedbackGenerator *feed = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    [feed prepare];
    [feed impactOccurred];
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
        // 最高层级，覆盖所有App
        self.layer.zPosition = 9999;

        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
        [self addGestureRecognizer:tap];
        [self addGestureRecognizer:pan];
    }
    return self;
}
- (void)tapAction {
    playTapHaptic();
    NSURL *url = [NSURL URLWithString:targetScheme];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        // options里面加上后台唤起参数，尽量不切前台
        [[UIApplication sharedApplication] openURL:url options:@{UIApplicationOpenURLOptionUniversalLinksOnly:@(NO)} completionHandler:nil];
    }
}
- (void)drag:(UIPanGestureRecognizer *)g {
    CGPoint offset = [g translationInView:self.superview];
    self.center = CGPointMake(self.center.x + offset.x, self.center.y + offset.y);
    [g setTranslation:CGPointZero inView:self.superview];
}
@end

static void (*origSBOverlayWindowInit)(id self, SEL _cmd);
void hookSBOverlayWindowInit(id self, SEL _cmd){
    origSBOverlayWindowInit(self, _cmd);
    dispatch_async(dispatch_get_main_queue(), ^{
        FloatBall *ball = [[FloatBall alloc] init];
        [self addSubview:ball];
    });
}

%ctor{
    // 挂钩全局顶层Overlay窗口，桌面、微信、抖音、所有APP内都能看到小球
    Class cls = objc_getClass("SBOverlayWindow");
    if(cls){
        MSHookMessageEx(cls, @selector(init), (IMP)hookSBOverlayWindowInit, (IMP *)&origSBOverlayWindowInit);
    }
}
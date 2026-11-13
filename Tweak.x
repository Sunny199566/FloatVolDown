#import <UIKit/UIKit.h>
#import <substrate.h>
#import <AudioToolbox/AudioToolbox.h>

// 这里填你脚本APP的 URL Scheme！！！
static NSString * const targetScheme = @"yourapp://";

static void playTapHaptic() {
    // 系统轻触感震动
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
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}
- (void)drag:(UIPanGestureRecognizer *)g {
    CGPoint offset = [g translationInView:self.superview];
    self.center = CGPointMake(self.center.x + offset.x, self.center.y + offset.y);
    [g setTranslation:CGPointZero inView:self.superview];
}
@end

static void (*origSBWorkspaceInit)(id self, SEL _cmd);
void hookSBWorkspaceInit(id self, SEL _cmd){
    origSBWorkspaceInit(self, _cmd);
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *sbWin = nil;
        for (UIWindow *win in [UIApplication sharedApplication].windows) {
            if(win.isKeyWindow){
                sbWin = win;
                break;
            }
        }
        if(sbWin){
            FloatBall *ball = [[FloatBall alloc] init];
            [sbWin addSubview:ball];
        }
    });
}

%ctor{
    Class cls = objc_getClass("SBMainWorkspace");
    if(cls){
        MSHookMessageEx(cls, @selector(init), (IMP)hookSBWorkspaceInit, (IMP *)&origSBWorkspaceInit);
    }
}
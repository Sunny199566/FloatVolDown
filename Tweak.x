#import <UIKit/UIKit.h>
#import <substrate.h>
#import <AudioToolbox/AudioToolbox.h>

static NSString * const targetScheme = @"xxt://run?file=rec_20261113153215.lua";
static UIWindow *floatWindow = nil;

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

static void (*origSBMainWorkspaceInit)(id self, SEL _cmd);
void hookSBMainWorkspaceInit(id self, SEL _cmd){
    origSBMainWorkspaceInit(self, _cmd);
    dispatch_async(dispatch_get_main_queue(), ^{
        if(floatWindow) return;

        // 找到前台活跃的Scene，iOS17必须绑定Scene才能正常显示window
        UIWindowScene *activeScene = nil;
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]] && scene.activationState == UISceneActivationStateForegroundActive) {
                activeScene = scene;
                break;
            }
        }
        if (!activeScene) return;

        // 用scene初始化window，这是关键修复点
        floatWindow = [[UIWindow alloc] initWithWindowScene:activeScene];
        floatWindow.frame = [UIScreen mainScreen].bounds;
        floatWindow.windowLevel = UIWindowLevelAlert + 9999;
        floatWindow.hidden = NO;

        FloatBall *ball = [[FloatBall alloc] init];
        floatWindow.rootViewController = [UIViewController new];
        [floatWindow.rootViewController.view addSubview:ball];
    });
}

%ctor{
    Class cls = objc_getClass("SBMainWorkspace");
    if(cls){
        MSHookMessageEx(cls, @selector(init), (IMP)hookSBMainWorkspaceInit, (IMP *)&origSBMainWorkspaceInit);
    }
}
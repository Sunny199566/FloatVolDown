#import <UIKit/UIKit.h>
#import <substrate.h>
#import <AudioToolbox/AudioToolbox.h>

static UIWindow *floatWindow = nil;
// XXTouch本地http端口
static const uint16_t xxtPort = 46952;
static NSString *scriptAbsolutePath = @"/var/mobile/Media/1ferver/lua/scripts/rec_20261113153215.lua";

static void playTapHaptic() {
    UIImpactFeedbackGenerator *feed = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    [feed prepare];
    [feed impactOccurred];
}

static void runScriptBackground() {
    NSString *urlStr = [NSString stringWithFormat:@"http://localhost:%u/api/run", xxtPort];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    req.timeoutInterval = 2.0;
    [req setValue:@"application/json" forHTTPHeaderField:@"Content‑Type"];

    NSDictionary *bodyDict = @{@"path": scriptAbsolutePath};
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict options:0 error:&err];
    if(!jsonData) return;
    req.HTTPBody = jsonData;

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        // 后台回调，不需要处理返回结果
    }];
    [task resume];
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
    runScriptBackground();
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

        UIWindowScene *activeScene = nil;
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]] && scene.activationState == UISceneActivationStateForegroundActive) {
                activeScene = scene;
                break;
            }
        }
        if (!activeScene) return;

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
#import <UIKit/UIKit.h>
#import <substrate.h>

static void sendVolumeDownEvent(){
    Class GSEvent = objc_getClass("GSEvent");
    if(!GSEvent) return;
    SEL send = sel_getUid("sendHIDEvent:");
    if([GSEvent respondsToSelector:send]){
        uint32_t evt[] = {0x0C000102, 0, 0};
        [GSEvent performSelector:send withObject:(__bridge id)evt];
        usleep(30000);
        evt[1] = 1;
        [GSEvent performSelector:send withObject:(__bridge id)evt];
    }
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
    sendVolumeDownEvent();
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
        UIWindow *sbWin = [UIApplication sharedApplication].keyWindow;
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
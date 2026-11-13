#import <substrate.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

static UIWindow *floatWindow;
static FloatVolBtn *btn;
static BOOL globalEnable = YES;

@interface FloatVolBtn : UIView
@end
@implementation FloatVolBtn
- (instancetype)init {
    self = [super initWithFrame:CGRectMake(270,420,60,60)];
    if(self){
        self.backgroundColor = [UIColor systemBlueColor];
        self.layer.cornerRadius = 30;
        self.clipsToBounds = YES;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)];
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        UILongPressGestureRecognizer *longPressHide = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHide:)];
        longPressHide.minimumPressDuration = 0.4;
        [self addGestureRecognizer:longPressHide];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drag:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)singleTapAction{
    if(!globalEnable) return;
    // 轻触感震动反馈
    AudioServicesPlaySystemSound(1519);
    NSURL *url = [NSURL URLWithString:@"xxt://launch/"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    });
}

- (void)longPressHide:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.alpha = 0;
    }
}

- (void)drag:(UIPanGestureRecognizer *)g{
    if (self.alpha <= 0) return;
    CGPoint p = [g translationInView:self];
    self.center = CGPointMake(self.center.x + p.x, self.center.y + p.y);
    [g setTranslation:CGPointZero inView:self];
}
@end

static void updateFloatState() {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!floatWindow) return;
        if (globalEnable) {
            btn.alpha = 1;
        } else {
            btn.alpha = 0;
        }
    });
}

%ctor{
    dispatch_async(dispatch_get_main_queue(),^{
        floatWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        floatWindow.windowLevel = 1000000;
        floatWindow.hidden = NO;
        btn = [[FloatVolBtn alloc] init];
        [floatWindow addSubview:btn];
        updateFloatState();
    });
}

%hook PSListController
- (void)setPreferenceValue:(id)value specifier:(id)specifier {
    %orig;
    if([[specifier valueForKey:@"key"] isEqualToString:@"enableFloatVol"]){
        globalEnable = [value boolValue];
        updateFloatState();
    }
}
%end

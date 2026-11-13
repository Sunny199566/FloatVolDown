#import "VolView.h"
#import <GraphicsServices/GraphicsServices.h>

#define GSEventSendEvent  CFNotificationCenterPostNotification
extern void GSEventPostHIDEvent(int keyCode, int down);

// 音量减 keycode: 0x69
static const int kKeyVolDown = 0x69;

@implementation VolView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor systemBlueColor];
        self.layer.cornerRadius = 30;
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
        [self addGestureRecognizer:tap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onDrag:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)onTap {
    // 模拟实体按键：按下 → 松开，一次完整按键
    GSEventPostHIDEvent(kKeyVolDown, 1);
    usleep(80000);
    GSEventPostHIDEvent(kKeyVolDown, 0);
}

- (void)onDrag:(UIPanGestureRecognizer *)g {
    CGPoint pt = [g translationInView:self];
    self.center = CGPointMake(self.center.x + pt.x, self.center.y + pt.y);
    [g setTranslation:CGPointZero inView:self];
}
@end
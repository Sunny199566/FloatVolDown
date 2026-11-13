#import "VolView.h"
#import <UIKit/UIKit.h>
#import <dlfcn.h>

typedef void (*GSEventPostHIDEvent_t)(int keyCode, int down);
static GSEventPostHIDEvent_t GSEventPostHIDEvent = NULL;
static const int kKeyVolDown = 0x69;

@implementation VolView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor systemBlueColor];
        self.layer.cornerRadius = 30;
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        
        // 运行时打开私有框架，拿到函数地址
        void *gsHandle = dlopen("/System/Library/PrivateFrameworks/GraphicsServices.framework/GraphicsServices", RTLD_LAZY);
        if (gsHandle) {
            GSEventPostHIDEvent = dlsym(gsHandle, "GSEventPostHIDEvent");
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
        [self addGestureRecognizer:tap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onDrag:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)onTap {
    if (!GSEventPostHIDEvent) return;
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
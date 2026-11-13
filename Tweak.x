#import <UIKit/UIKit.h>
#import <GraphicsServices/GSEvent.h>

static UIWindow *floatWindow;

@interface FloatBtnView : UIView
@end
@implementation FloatBtnView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor systemBlueColor];
        self.layer.cornerRadius = frame.size.width/2;
        self.clipsToBounds = YES;
    }
    return self;
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    // 模拟实体音量减按键按下+松开，一次完整按键
    GSEventSendApplicationToggle(kGSEventVolumeDownButtonDown);
    GSEventSendApplicationToggle(kGSEventVolumeDownButtonUp);
}
@end

%ctor {
    dispatch_async(dispatch_get_main_queue(), ^{
        floatWindow = [[UIWindow alloc] initWithFrame:CGRectMake(30, 300, 50, 50)];
        floatWindow.windowLevel = 10000000;
        floatWindow.hidden = NO;
        FloatBtnView *btn = [[FloatBtnView alloc] initWithFrame:floatWindow.bounds];
        [floatWindow addSubview:btn];
    });
}
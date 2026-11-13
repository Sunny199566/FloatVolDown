#import "VolView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface VolView ()
@property (nonatomic, strong) MPVolumeView *volumeView;
@end

@implementation VolView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor systemBlueColor];
        self.layer.cornerRadius = 30;
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        
        // 隐藏的音量控件，用来控制系统音量
        _volumeView = [[MPVolumeView alloc] init];
        _volumeView.showsRouteButton = NO;
        _volumeView.showsVolumeSlider = NO;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
        [self addGestureRecognizer:tap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onDrag:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)onTap {
    UISlider *slider = nil;
    for (UIView *sub in self.volumeView.subviews) {
        if ([sub isKindOfClass:[UISlider class]]) {
            slider = (UISlider *)sub;
            break;
        }
    }
    if (!slider) return;
    float newVol = slider.value - 0.1f;
    if (newVol < 0) newVol = 0;
    slider.value = newVol;
    // 发送滑动事件，生效
    [slider sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)onDrag:(UIPanGestureRecognizer *)g {
    CGPoint pt = [g translationInView:self];
    self.center = CGPointMake(self.center.x + pt.x, self.center.y + pt.y);
    [g setTranslation:CGPointZero inView:self];
}
@end
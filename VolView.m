#import "VolView.h"
#import <AVFoundation/AVFoundation.h>

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
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    // 音量减少 0.1（系统音量区间0~1）
    float vol = session.outputVolume - 0.1f;
    if (vol < 0) vol = 0;
    [session setOutputVolume:vol error:nil];
}

- (void)onDrag:(UIPanGestureRecognizer *)g {
    CGPoint pt = [g translationInView:self];
    self.center = CGPointMake(self.center.x + pt.x, self.center.y + pt.y);
    [g setTranslation:CGPointZero inView:self];
}
@end
#import <UIKit/UIKit.h>
#import <GraphicsServices/GSEvent.h>

static UIWindow *overlayWin;

// 模拟实体音量减按键按下（按下+松开一套完整事件）
void sendVolumeDownKeyEvent(void) {
    GSEventRef pressEvent = GSEventCreateVolumeButtonEvent(kGSEventVolumeDownButton, YES);
    GSEventPost(pressEvent);
    CFRelease(pressEvent);
    
    usleep(80000);
    
    GSEventRef releaseEvent = GSEventCreateVolumeButtonEvent(kGSEventVolumeDownButton, NO);
    GSEventPost(releaseEvent);
    CFRelease(releaseEvent);
}

void setupFloatBtn(void) {
    @autoreleasepool {
        overlayWin = [[UIWindow alloc] initWithFrame:CGRectMake(60, 320, 70, 70)];
        overlayWin.windowLevel = UIWindowLevelAlert + 9999;
        overlayWin.backgroundColor = UIColor.clearColor;
        overlayWin.hidden = NO;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(5,5,60,60);
        btn.backgroundColor = [UIColor colorWithWhite:0 alpha:0.65];
        btn.layer.cornerRadius = 30;
        [btn setTitle:@"-" forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:28];
        [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [btn addTarget:nil action:@selector(onTap) forControlEvents:UIControlEventTouchUpInside];
        
        overlayWin.rootViewController = [UIViewController new];
        [overlayWin.rootViewController.view addSubview:btn];
        overlayWin.userInteractionEnabled = YES;
    }
}

void onTap() {
    sendVolumeDownKeyEvent();
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        setupFloatBtn();
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

static UIWindow *overlayWindow;
static float volumeStep = 0.1f;

void setupOverlayWindow() {
    @autoreleasepool {
        overlayWindow = [[UIWindow alloc] initWithFrame:CGRectMake(50, 300, 80, 160)];
        overlayWindow.windowLevel = UIWindowLevelAlert + 9999;
        overlayWindow.backgroundColor = [UIColor clearColor];
        overlayWindow.hidden = NO;

        UIButton *volDownBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        volDownBtn.frame = CGRectMake(10,10,60,60);
        [volDownBtn setTitle:@"-" forState:UIControlStateNormal];
        volDownBtn.titleLabel.font = [UIFont boldSystemFontOfSize:32];
        [volDownBtn addTarget:nil action:@selector(volDownTap) forControlEvents:UIControlEventTouchUpInside];

        UIButton *volUpBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        volUpBtn.frame = CGRectMake(10,80,60,60);
        [volUpBtn setTitle:@"+" forState:UIControlStateNormal];
        volUpBtn.titleLabel.font = [UIFont boldSystemFontOfSize:32];
        [volUpBtn addTarget:nil action:@selector(volUpTap) forControlEvents:UIControlEventTouchUpInside];

        overlayWindow.rootViewController = [UIViewController new];
        [overlayWindow.rootViewController.view addSubview:volDownBtn];
        [overlayWindow.rootViewController.view addSubview:volUpBtn];
        overlayWindow.userInteractionEnabled = YES;
    }
}

void volDownTap() {
    float v;
    UInt32 size = sizeof(v);
    AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareOutputVolume, &size, &v);
    v -= volumeStep;
    if(v < 0) v = 0;
    AudioSessionSetProperty(kAudioSessionProperty_CurrentHardwareOutputVolume, sizeof(v), &v);
}

void volUpTap() {
    float v;
    UInt32 size = sizeof(v);
    AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareOutputVolume, &size, &v);
    v += volumeStep;
    if(v > 1) v = 1;
    AudioSessionSetProperty(kAudioSessionProperty_CurrentHardwareOutputVolume, sizeof(v), &v);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if(argc >= 2) {
            volumeStep = atof(argv[1]);
        }
        AudioSessionInitialize(NULL, NULL, NULL, NULL);
        setupOverlayWindow();
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
#import <Foundation/Foundation.h>
#import <GraphicsServices/GraphicsServices.h>

typedef int GSEventRef;
void _GSSendEvent(GSEventRef event);

#define kGSEventVolumeDownButton 0x2001

static GSEventRef CreateVolumeDownEvent(void) {
    // 构造音量减按下事件
    GSEventRef evt = 0;
    // 这里是适配iOS17的GSEvent构造，对应实体音量减按键
    unsigned char buf[64] = {0};
    buf[0] = kGSEventVolumeDownButton;
    buf[1] = 1; // down
    evt = (GSEventRef)buf;
    return evt;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        GSEventRef e = CreateVolumeDownEvent();
        _GSSendEvent(e);
        // 模拟按下+松开，和实体按键一模一样
        usleep(30000);
        buf[1] = 0; // up
        _GSSendEvent(e);
    }
    return 0;
}
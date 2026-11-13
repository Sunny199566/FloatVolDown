#import <UIKit/UIKit.h>
#import "VolView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // 加入悬浮球，初始位置 x:260 y:400，大小60×60
    VolView *floatBtn = [[VolView alloc] initWithFrame:CGRectMake(260, 400, 60, 60)];
    [vc.view addSubview:floatBtn];
    
    self.window.rootViewController = vc;
    self.window.hidden = NO;
    return YES;
}
@end

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
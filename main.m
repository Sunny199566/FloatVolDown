#import <UIKit/UIKit.h>
#import "VolView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    CGRect f = [UIScreen mainScreen].bounds;
    self.window = [[UIWindow alloc] initWithFrame:f];
    self.window.rootViewController = [UIViewController new];
    self.window.hidden = NO;
    
    VolView *floatBtn = [[VolView alloc] initWithFrame:CGRectMake(30, 300, 60, 60)];
    floatBtn.windowLevel = UIWindowLevelAlert + 10;
    floatBtn.hidden = NO;
    return YES;
}
@end

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
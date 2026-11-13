#import <Preferences/Preferences.h>

@interface FloatVolDownPrefsListController : PSListController
@end

@implementation FloatVolDownPrefsListController
- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}
@end

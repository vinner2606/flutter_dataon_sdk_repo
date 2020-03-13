#import "PwcPlugin.h"
#import <pwc/pwc-Swift.h>

@implementation PwcPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPwcPlugin registerWithRegistrar:registrar];
}
@end

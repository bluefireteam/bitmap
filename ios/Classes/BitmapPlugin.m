#import "BitmapPlugin.h"
#import <bitmap/bitmap-Swift.h>

@implementation BitmapPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBitmapPlugin registerWithRegistrar:registrar];
}
@end

#import "BitmapPlugin.h"
#if __has_include(<bitmap/bitmap-Swift.h>)
#import <bitmap/bitmap-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "bitmap-Swift.h"
#endif

@implementation BitmapPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBitmapPlugin registerWithRegistrar:registrar];
}
@end

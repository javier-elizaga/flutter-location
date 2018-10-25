#import "FlutterLocationPlugin.h"
#import <flutter_location/flutter_location-Swift.h>

@implementation FlutterLocationPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterLocationPlugin registerWithRegistrar:registrar];
}
@end

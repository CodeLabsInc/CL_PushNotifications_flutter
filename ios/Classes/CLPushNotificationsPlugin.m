#import "CLPushNotificationsPlugin.h"
#if __has_include(<CL_PushNotifications/CL_PushNotifications-Swift.h>)
#import <CL_PushNotifications/CL_PushNotifications-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "CL_PushNotifications-Swift.h"
#endif

@implementation CLPushNotificationsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftCLPushNotificationsPlugin registerWithRegistrar:registrar];
}
@end

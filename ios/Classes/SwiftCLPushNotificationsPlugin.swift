import Flutter
import UIKit

public class SwiftCLPushNotificationsPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "CL_PushNotifications", binaryMessenger: registrar.messenger())
    let instance = SwiftCLPushNotificationsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}

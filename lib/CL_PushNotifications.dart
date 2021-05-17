
import 'dart:async';

import 'package:flutter/services.dart';

class CLPushNotifications {
  static const MethodChannel _channel =
      const MethodChannel('CL_PushNotifications');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

import 'dart:io';

import 'package:CL_PushNotifications/src/apns_connector.dart';
import 'package:CL_PushNotifications/src/connector.dart';
import 'package:CL_PushNotifications/src/firebase_connector.dart';
import 'package:flutter/material.dart';

export 'package:CL_PushNotifications/src/connector.dart';
export 'package:CL_PushNotifications/src/apns_connector.dart';
export 'package:CL_PushNotifications/src/firebase_connector.dart';

/// Creates either APNS or Firebase connector to manage the push notification registration.
PushConnector createPushConnector() {
  if (Platform.isIOS) {
    return ApnsPushConnector();
  } else {
    return FirebasePushConnector();
  }
}

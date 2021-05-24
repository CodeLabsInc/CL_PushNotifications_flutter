import 'package:CL_PushNotifications/src/connector.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebasePushConnector extends PushConnector {
  late final firebase = FirebaseMessaging.instance;

  @override
  final isDisabledByUser = ValueNotifier(false);

  bool didInitialize = false;

  @override
  void configure({
    MessageHandler? onMessage,
    MessageHandler? onLaunch,
    MessageHandler? onResume,
    MessageHandler? onBackgroundMessage,
  }) async {
    if (!didInitialize) {
      await Firebase.initializeApp();
      didInitialize = true;
    }

    firebase.onTokenRefresh.listen((value) {
      token.value = value;
    });

    FirebaseMessaging.onMessage.listen(onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(onResume);

    if (onBackgroundMessage != null) {
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    }

    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      onLaunch?.call(initial);
    }

    token.value = await firebase.getToken();
  }

  void setAuthkey(String authKey) {
    print("setAuthkey");

    if (authKey.isEmpty) {
      print(
          "CLPushNotifications: Mandatory parameters(authKey) must not be empty.");
    }

    // _channel.invokeMethod('setAuthKey', authKey);
  }

  void setAttribute(
      {required String fieldName,
      required String alias,
      required String value,
      required String type}) {
    // _channel.invokeMethod('setAttribute', authKeyString);
  }

  @override
  final token = ValueNotifier(null);

  @override
  void requestNotificationPermissions() async {
    if (!didInitialize) {
      await Firebase.initializeApp();
      didInitialize = true;
    }

    firebase.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  @override
  String get providerType => 'GCM';

  @override
  Future<void> unregister() async {
    await firebase.setAutoInitEnabled(false);
    await firebase.deleteToken();

    token.value = null;
  }
}

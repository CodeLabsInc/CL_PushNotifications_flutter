import 'package:CL_PushNotifications/apns.dart';
import 'package:CL_PushNotifications/flutter_apns.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:CL_PushNotifications/CL_PushNotifications.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final PushConnector connector = createPushConnector();

  Future<void> _register() async {
    final connector = this.connector;

    connector.setAuthkey("91c4a1e7fb0d458faeceae08296954f9");

    connector.configure(
      onLaunch: (data) => onPush('onLaunch', data),
      onResume: (data) => onPush('onResume', data),
      onMessage: (data) => onPush('onMessage', data),
      onBackgroundMessage: _onBackgroundMessage,
    );
    connector.token.addListener(() {
      print('Token ${connector.token.value}');
    });
    connector.requestNotificationPermissions();

    connector.setAttribute(
      fieldName: "first name",
      alias: "f_name",
      value: "Mehdi flutter",
      type: "text",
    );

    if (connector is ApnsPushConnector) {
      connector.shouldPresent = (x) async {
        final remote = RemoteMessage.fromMap(x.payload);
        return remote.category == 'MEETING_INVITATION';
      };
      connector.setNotificationCategories([
        UNNotificationCategory(
          identifier: 'MEETING_INVITATION',
          actions: [
            UNNotificationAction(
              identifier: 'ACCEPT_ACTION',
              title: 'Accept',
              options: UNNotificationActionOptions.values,
            ),
            UNNotificationAction(
              identifier: 'DECLINE_ACTION',
              title: 'Decline',
              options: [],
            ),
          ],
          intentIdentifiers: [],
          options: UNNotificationCategoryOptions.values,
        ),
      ]);
    }
  }

  Future<dynamic> onPush(String name, RemoteMessage payload) {
    // storage.append('$name: ${payload.notification?.title}');

    print("${name} ${payload.toString()}");
    final action = UNNotificationAction.getIdentifier(payload.data);

    if (action != null && action != UNNotificationAction.defaultIdentifier) {
      // storage.append('Action: $action');
    }

    return Future.value(true);
  }

  Future<dynamic> _onBackgroundMessage(RemoteMessage data) =>
      onPush('onBackgroundMessage', data);

  @override
  void initState() {
    print("initstate");
    _register();

    super.initState();
    // initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await CLPushNotifications.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}

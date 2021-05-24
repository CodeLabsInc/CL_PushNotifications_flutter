import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:CL_PushNotifications/flutter_apns_only.dart';
export 'package:CL_PushNotifications/flutter_apns_only.dart';

import 'connector.dart';

class ApnsPushConnector extends ApnsPushConnectorOnly implements PushConnector {
  // String authKey;
  // ApnsPushConnector({required this.authKey});

  @override
  void configure({onMessage, onLaunch, onResume, onBackgroundMessage}) {
    ApnsMessageHandler? mapHandler(MessageHandler? input) {
      if (input == null) {
        return null;
      }

      return (apnsMessage) => input(RemoteMessage.fromMap(apnsMessage.payload));
    }

    configureApns(
      onMessage: mapHandler(onMessage),
      onLaunch: mapHandler(onLaunch),
      onResume: mapHandler(onResume),
      onBackgroundMessage: mapHandler(onBackgroundMessage),
    );
  }
}

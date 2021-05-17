import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:CL_PushNotifications/CL_PushNotifications.dart';

void main() {
  const MethodChannel channel = MethodChannel('CL_PushNotifications');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await CLPushNotifications.platformVersion, '42');
  });
}

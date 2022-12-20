import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sms_call_barring_plugin/sms_call_barring_plugin_method_channel.dart';

void main() {
  MethodChannelSmsCallBarringPlugin platform = MethodChannelSmsCallBarringPlugin();
  const MethodChannel channel = MethodChannel('sms_call_barring_plugin');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('toggleBarring', () async {
    expect(await platform.toggleBarring(true), '42');
  });
}

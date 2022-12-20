import 'package:flutter_test/flutter_test.dart';
import 'package:sms_call_barring_plugin/sms_call_barring_plugin.dart';
import 'package:sms_call_barring_plugin/sms_call_barring_plugin_platform_interface.dart';
import 'package:sms_call_barring_plugin/sms_call_barring_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSmsCallBarringPluginPlatform
    with MockPlatformInterfaceMixin
    implements SmsCallBarringPluginPlatform {

  @override
  Future<String?> toggleBarring(bool isEnabled) => Future.value('42');
}

void main() {
  final SmsCallBarringPluginPlatform initialPlatform = SmsCallBarringPluginPlatform.instance;

  test('$MethodChannelSmsCallBarringPlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSmsCallBarringPlugin>());
  });

  test('toggleBarring', () async {
    SmsCallBarringPlugin smsCallBarringPlugin = SmsCallBarringPlugin();
    MockSmsCallBarringPluginPlatform fakePlatform = MockSmsCallBarringPluginPlatform();
    SmsCallBarringPluginPlatform.instance = fakePlatform;

    expect(await smsCallBarringPlugin.toggleBarring(true), '42');
  });
}

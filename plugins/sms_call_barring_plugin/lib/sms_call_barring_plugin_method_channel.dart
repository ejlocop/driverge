import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'sms_call_barring_plugin_platform_interface.dart';

/// An implementation of [SmsCallBarringPluginPlatform] that uses method channels.
class MethodChannelSmsCallBarringPlugin extends SmsCallBarringPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('sms_call_barring_plugin');

  @override
  Future<String?> toggleBarring(bool isEnabled) async {
    final version = await methodChannel.invokeMethod<String>('toggleBarring', {
      'isEnabled': isEnabled,
    });
    return version;
  }
}

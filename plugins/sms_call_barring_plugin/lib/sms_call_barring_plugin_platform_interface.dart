import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'sms_call_barring_plugin_method_channel.dart';

abstract class SmsCallBarringPluginPlatform extends PlatformInterface {
  /// Constructs a SmsCallBarringPluginPlatform.
  SmsCallBarringPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static SmsCallBarringPluginPlatform _instance = MethodChannelSmsCallBarringPlugin();

  /// The default instance of [SmsCallBarringPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelSmsCallBarringPlugin].
  static SmsCallBarringPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SmsCallBarringPluginPlatform] when
  /// they register themselves.
  static set instance(SmsCallBarringPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> toggleBarring(bool isEnabled) {
    throw UnimplementedError('toggleBarring() has not been implemented.');
  }
}

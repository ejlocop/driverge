
import 'sms_call_barring_plugin_platform_interface.dart';

class SmsCallBarringPlugin {
  Future<String?> toggleBarring(bool isEnabled) {
    return SmsCallBarringPluginPlatform.instance.toggleBarring(isEnabled);
  }
}

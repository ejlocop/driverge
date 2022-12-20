package com.ejlocop.sms_call_barring_plugin

//import com.ejlocop.sms_call_barring_plugin.CallBlocker
//import com.ejlocop.sms_call_barring_plugin.SMSBlocker
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** SmsCallBarringPlugin */
class SmsCallBarringPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "sms_call_barring_plugin")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    val hashMap = call.arguments as HashMap<*, *>
    val isEnabled = hashMap["isEnabled"] as Boolean
    if (call.method == "toggleBarring") {
//      CallBlocker.isBlockingEnabled = isEnabled
//      SMSBlocker.isBlockingEnabled = isEnabled
      Blocker.isBlockingEnabled = isEnabled
      result.success("SMS and Call Barring is now ${if (isEnabled) "enabled" else "disabled"}")
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}

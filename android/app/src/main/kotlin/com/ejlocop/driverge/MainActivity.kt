package com.ejlocop.driverge

import android.os.Build
import android.telephony.PhoneStateListener
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import androidx.annotation.NonNull;
import android.telephony.SmsManager
import android.telephony.TelephonyManager
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class MainActivity: FlutterActivity() {
// 	private val CHANNEL_NAME = "com.ejlocop.driverge/channel"
// 	private lateinit var channel: MethodChannel

// 	override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
// 		super.configureFlutterEngine(flutterEngine)
// 		channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
// 	}

// 	@RequiresApi(Build.VERSION_CODES.M)
// 	private fun setBlocking() {
// 		// Get the phone's TelephonyManager
// 		val telephonyManager = getSystemService(TelephonyManager::class.java) as TelephonyManager

// 		telephonyManager.emergencyNumberList

// 		// Block incoming calls
// 		telephonyManager.listen(object : PhoneStateListener() {
// 			override fun onCallStateChanged(state: Int, incomingNumber: String) {
// 				if (state == TelephonyManager.CALL_STATE_RINGING) {
// 					// End the call if it is incoming
// 					endCall()
// 				}
// 			}
// 		}, PhoneStateListener.LISTEN_CALL_STATE)

// 		val smsManager = context.getSystemService(SmsManager::class.java)
// //		smsManager.sendTextMessage()
// 	}
}

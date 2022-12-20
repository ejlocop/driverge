package com.ejlocop.sms_call_barring_plugin

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class SMSBlocker: BroadcastReceiver() {
	companion object {
		@JvmStatic
		var isBlockingEnabled: Boolean = false
	}

	override fun onReceive(context: Context, intent: Intent) {
		Log.d("SMSBlocker", "isBlockingEnabled=$isBlockingEnabled")
		Log.d("SMSBlocker", "action ${intent.action}")

		if (intent.action == "android.provider.Telephony.SMS_RECEIVED") {
			// This code will execute when an SMS message is received
			// You can block the message by canceling the broadcast
			Log.d("SMSBlocker", "trying to block SMS")
			abortBroadcast()
			setResultExtras(null)
		}
	}
}

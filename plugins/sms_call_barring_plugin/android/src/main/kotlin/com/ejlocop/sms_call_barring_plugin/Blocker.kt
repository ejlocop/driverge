package com.ejlocop.sms_call_barring_plugin

import android.app.Activity
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.telephony.SmsMessage
import android.widget.Toast
import android.telephony.TelephonyManager
import android.util.Log

class Blocker : BroadcastReceiver() {
	companion object {
		@JvmStatic
		var isBlockingEnabled: Boolean = false
	}

	override fun onReceive(context: Context, intent: Intent) {
		if(!isBlockingEnabled) {
			return
		}

		val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE)
		Log.d("Blocker", "State: $state")
		if (state == TelephonyManager.EXTRA_STATE_RINGING) {
			// This code will execute when an incoming call is received
			val phoneNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)
			// TODO: Add code here to block the incoming call
			Toast.makeText(context, "Incoming call from $phoneNumber blocked", Toast.LENGTH_SHORT).show()
		}

		if (intent.action == "android.provider.Telephony.SMS_RECEIVED") {
			// This code will execute when an SMS message is received
			val bundle = intent.extras
			if (bundle != null) {
				val pdus = bundle.get("pdus") as Array<*>
				for (i in pdus.indices) {
					val smsMessage = SmsMessage.createFromPdu(pdus[i] as ByteArray)
					val sender = smsMessage.displayOriginatingAddress
					// TODO: Add code here to block the incoming SMS message

					Toast.makeText(context, "Incoming SMS from $sender blocked", Toast.LENGTH_SHORT).show()
					abortBroadcast() // doesn't work
					setResultCode(Activity.RESULT_CANCELED)
					Toast.makeText(context, "Potaena!", Toast.LENGTH_SHORT).show()
				}
			}
		}
	}
}
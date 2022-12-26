package com.ejlocop.driverge.services

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.SmsMessage
import android.util.Log

class MySmsBroadcastReceiver : BroadcastReceiver() {
    companion object {
        @JvmStatic
        var isBlockingEnabled = false
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action == "android.provider.Telephony.SMS_RECEIVED") {
            val bundle = intent.extras
            val pdus = bundle?.get("pdus") as Array<*>
            val messages = arrayOfNulls<SmsMessage>(pdus.size)
            for (i in pdus.indices) {
                messages[i] = SmsMessage.createFromPdu(pdus[i] as ByteArray, bundle.getString("format"))
            }
            // Block the incoming SMS messages
            for (message in messages) {
                val sender = message?.displayOriginatingAddress
                val messageBody = message?.messageBody
                Log.d("SMSBlocker", "sender $sender messageBody $messageBody")
                if (isBlockingEnabled) {
                    abortBroadcast()
                }
            }
        }
    }
}
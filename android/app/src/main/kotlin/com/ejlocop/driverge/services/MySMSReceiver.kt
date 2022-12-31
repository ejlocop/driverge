package com.ejlocop.driverge.services

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.SmsMessage
import android.util.Log
import com.ejlocop.driverge.commons.events.MessageEvent
import com.ejlocop.driverge.commons.utils.NotificationManagerImpl
import org.greenrobot.eventbus.EventBus

class MySMSReceiver : BroadcastReceiver() {
    companion object {
        @JvmStatic
        var isBlockingEnabled = false
    }

    private val notificationManager = NotificationManagerImpl()

    override fun onReceive(context: Context?, intent: Intent?) {
        Log.d("MySMSReceiver", "Intent ${intent?.action}")
        if (intent?.action == "android.provider.Telephony.SMS_RECEIVED") {
            val bundle = intent.extras
            val pdus = bundle?.get("pdus") as Array<*>
            val messages = arrayOfNulls<SmsMessage>(pdus.size)
            for (i in pdus.indices) {
                messages[i] = SmsMessage.createFromPdu(pdus[i] as ByteArray, bundle.getString("format"))
            }
            // Block the incoming SMS messages
            for (message in messages) {
                val sender = message!!.displayOriginatingAddress
                val messageBody = message!!.messageBody

                Log.d("MySMSReceiver", "sender $sender messageBody $messageBody")
                if (isBlockingEnabled) {
                    displayToast(context!!, String.format("Rejected SMS from %s", sender))
                    broadcastEvent(sender)
                    abortBroadcast()
                }
            }
        }
    }

    private fun displayToast(context: Context, message: String) {
        notificationManager.showToastNotification(context, message)
    }

    private fun broadcastEvent(phoneNumber: String) {
        EventBus.getDefault().post(MessageEvent(phoneNumber, "SMS"))
    }
}
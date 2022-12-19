package com.ejlocop.driverge

import android.Manifest
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.provider.Telephony;
import android.telecom.TelecomManager;
import android.telephony.TelephonyManager;
import android.telecom.InCallService;
import android.telephony.SmsManager
import android.telephony.SmsMessage
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.Log

class CallBlocker : BroadcastReceiver() {

  override fun onReceive(context: Context, intent: Intent) {
    val action = intent.action
    if (Telephony.Sms.Intents.SMS_RECEIVED_ACTION == action) {
      // An SMS has been received, so block it
      val phoneNumber = getNumberFromSms(intent?.extras)
      Log.d(TAG, "phone number=$phoneNumber")

      val smsManager = ContextCompat.getSystemService(context, SmsManager::class.java)
      smsManager?.sendTextMessage(phoneNumber, null, "Message!", null, null)
    }
  }

  private fun getNumberFromSms(extras: Bundle?): String {
    val pdus = extras?.get("pdus") as Array<*>
    val format = extras.getString("format")
    var txt = ""
    for (pdu in pdus) {
      val smsmsg = getSmsMsg(pdu as ByteArray?, format)
      val submsg = smsmsg?.originatingAddress
      submsg?.let { txt = "$txt$it" }
    }
    return txt
  }

  private fun getSmsMsg(pdu: ByteArray?, format: String?): SmsMessage? {
    return when {
      Build.VERSION.SDK_INT >= Build.VERSION_CODES.M -> SmsMessage.createFromPdu(pdu, format)
      else -> SmsMessage.createFromPdu(pdu)
    }
  }

  companion object {
    private val TAG = CallBlocker::class.java.simpleName
  }
}























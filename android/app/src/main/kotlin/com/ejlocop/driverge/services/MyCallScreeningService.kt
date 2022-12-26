package com.ejlocop.driverge.services

import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log
import com.ejlocop.driverge.commons.FORBIDDEN_PHONE_CALL_NUMBER
import com.ejlocop.driverge.commons.events.MessageEvent
import com.ejlocop.driverge.commons.extensions.parseCountryCode
import com.ejlocop.driverge.commons.extensions.removeTelPrefix
import com.ejlocop.driverge.commons.utils.NotificationManagerImpl
import org.greenrobot.eventbus.EventBus

class MyCallScreeningService : CallScreeningService() {
    companion object {
        @JvmStatic
        var isBlockingEnabled = false
    }

    private val notificationManager = NotificationManagerImpl()

    override fun onScreenCall(callDetails: Call.Details) {
        val phoneNumber = getPhoneNumber(callDetails)
        var response = CallResponse.Builder()
        response = handlePhoneCall(response, phoneNumber)

        respondToCall(callDetails, response.build())
    }

    private fun handlePhoneCall(
            response: CallResponse.Builder,
            phoneNumber: String
    ): CallResponse.Builder {
        Log.d("HandlePhoneCall", "isBlockingEnabled $isBlockingEnabled incoming call from $phoneNumber")
        if(isBlockingEnabled) {
            response.apply {
                setRejectCall(true)
                setDisallowCall(true)
                setSkipCallLog(false)
                //
                displayToast(String.format("Rejected call from %s", phoneNumber))
                broadcastEvent(phoneNumber)
            }
        }
        return response
    }

    private fun getPhoneNumber(callDetails: Call.Details): String {
        return callDetails.handle.toString().removeTelPrefix().parseCountryCode()
    }

    private fun displayToast(message: String) {
        notificationManager.showToastNotification(applicationContext, message)
    }

    private fun broadcastEvent(phoneNumber: String) {
        EventBus.getDefault().post(MessageEvent(phoneNumber))
    }

}
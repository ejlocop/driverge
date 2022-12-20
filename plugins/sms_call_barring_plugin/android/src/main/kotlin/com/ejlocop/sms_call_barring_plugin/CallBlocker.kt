package com.ejlocop.sms_call_barring_plugin

import android.telecom.Call
import android.telecom.CallScreeningService
import android.util.Log


class CallBlocker : CallScreeningService() {
	companion object {
		@JvmStatic
		var isBlockingEnabled: Boolean = false
	}

	override fun onScreenCall(call: Call.Details) {

		Log.d("CallBlocker", "isBlockingEnabled=$isBlockingEnabled")
		Log.d("CallBlocker", "call $call")

		// Check if the call should be blocked
		if (isBlockingEnabled) {
			// Block the call
			val response = CallResponse.Builder()
				.setDisallowCall(true)
				.build()

			respondToCall(call, response)
		} else {
			// Allow the call
			val response = CallResponse.Builder()
				.setDisallowCall(false)
				.build()

			respondToCall(call, response)
		}
	}
}


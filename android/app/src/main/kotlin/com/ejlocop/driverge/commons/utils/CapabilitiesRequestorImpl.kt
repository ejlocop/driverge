package com.ejlocop.driverge.commons.utils

import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.appcompat.app.AlertDialog
import com.ejlocop.driverge.MainActivity
import com.ejlocop.driverge.R
import com.ejlocop.driverge.commons.base.BaseActivity
import com.ejlocop.driverge.commons.events.MessagingCapabilityEnabled
import com.ejlocop.driverge.commons.events.PhoneCapabilityEnabled
import com.ejlocop.driverge.commons.extensions.*
import java.lang.ref.WeakReference


/**
 * Interface that defines which method will be invoked in order to make capabilities
 * requestor implementation flow.
 */
interface CapabilitiesRequestor {
    /**
     * Invokes capabilities request.
     */
    fun invokeCapabilitiesRequest()

    fun invokeSmsCapabilitiesRequest(context: Context)

    /**
     * Handles [BaseActivity.onActivityResult] method, invoked from [BaseActivity] that starts
     * capabilities request.
     */
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {}
}


/**
 * Class that invokes enabling different capabilities (like phone dialer) in order to listen for
 * phone call data.
 *
 * @author Zoran Sasko
 * @version 1.0.0
 */
class CapabilitiesRequestorImpl : CapabilitiesRequestor {

    var activityReference: WeakReference<MainActivity>? = null

    override fun invokeCapabilitiesRequest() {
        activityReference?.get()?.let {
            if (!it.hasDialerCapability()) {
                requestDialerPermission()
            }
        }
    }

    override fun invokeSmsCapabilitiesRequest(context: Context) {
        activityReference?.get()?.let {
            if(!it.hasMessagingCapability(context)) {
                requestMessagingPermission()
            }
        }
    }

    /**
     * Invokes selecting default dialer, required for reading call info.
     */
    private fun requestDialerPermission() {
        activityReference?.get()?.let {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                it.startCallScreeningPermissionScreen(REQUEST_ID_CALL_SCREENING)
            } else {
                it.startSelectDialerScreen(REQUEST_ID_SET_DEFAULT_DIALER)
            }
        }
    }

    private fun requestMessagingPermission() {
        activityReference?.get()?.let {
//            if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
//                it.startSmsPermissionScreen(REQUEST_ID_SMS_SCREENING)
//            }
//            else {
                it.startSelectSmsScreen(REQUEST_ID_SMS_SCREENING)
//            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        Log.d("onActivityResult", "requestCode $requestCode resultCode $resultCode android.app.Activity.RESULT_OK ${android.app.Activity.RESULT_OK}")
        if (requestCode == REQUEST_ID_CALL_SCREENING || requestCode == REQUEST_ID_SET_DEFAULT_DIALER) {
            if (resultCode == android.app.Activity.RESULT_OK) {
                Log.d("PhoneCapabilityEnabled", "$PhoneCapabilityEnabled")
                activityReference?.get()?.let {
                    it.uiEvent.postValue(PhoneCapabilityEnabled)
                }
            } else {
                displayCallScreeningPermissionDialog {
                    requestDialerPermission()
                }
            }
        }
        else if (requestCode == REQUEST_ID_SMS_SCREENING) {
            if (resultCode == android.app.Activity.RESULT_OK) {
                Log.d("MessagingCapabilityEnabled", "$MessagingCapabilityEnabled")
                activityReference?.get()?.let {
                    it.uiEvent.postValue(MessagingCapabilityEnabled)
                }
            }
            else {
                displaySmsScreeningPermissionDialog {
                    requestMessagingPermission()
                }
            }
        }
    }

    /**
     * Displays a dialog asking from user to enable phone capability of the app
     * @param positiveButtonHandler Handler that's invoked when user clicks on positive button.
     */
    private fun displayCallScreeningPermissionDialog(positiveButtonHandler: (() -> Unit)?) {
        activityReference?.get()?.let {
            AlertDialog.Builder(it)
                .setTitle(R.string.global_message_title)
                .setMessage(R.string.global_call_screening_required_message)
                .setPositiveButton(android.R.string.ok) { _, _ ->
                    positiveButtonHandler?.invoke()
                }
                .setNegativeButton(android.R.string.cancel) { dialog, item -> }
                .create()
                .show()
        }
    }

    private fun displaySmsScreeningPermissionDialog(positiveButtonHandler: (() -> Unit)?) {
        activityReference?.get()?.let {
            AlertDialog.Builder(it)
                .setTitle(R.string.global_message_title)
                .setMessage(R.string.global_call_screening_required_message)
                .setPositiveButton(android.R.string.ok) { _, _ ->
                    Log.d("displaySmsScreeningPermissionDialog", "setPositiveButton")
                    positiveButtonHandler?.invoke()
                }
                .setNegativeButton(android.R.string.cancel) { dialog, item ->
                    Log.d("displaySmsScreeningPermissionDialog", "setNegativeButton")
                }
                .create()
                .show()
        }
    }

    companion object {
        const val REQUEST_ID_CALL_SCREENING = 9872
        const val REQUEST_ID_SMS_SCREENING = 9871
        const val REQUEST_ID_SET_DEFAULT_DIALER = 1144
        const val REQUEST_ID_SET_DEFAULT_SMS = 1143
    }
}
package com.ejlocop.driverge.commons.extensions

import android.app.Activity
import android.app.role.RoleManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Telephony
import android.telecom.TelecomManager
import android.util.Log
import androidx.annotation.RequiresApi
import androidx.appcompat.app.AppCompatActivity


/**
 * Invokes displaying Phone handling activity. It's used for call listening on Android API >= Android Q.
 * @param requestId Request ID
 */
@RequiresApi(Build.VERSION_CODES.Q)
fun Activity.startCallScreeningPermissionScreen(requestId: Int) {
    val roleManager = this.getSystemService(AppCompatActivity.ROLE_SERVICE) as RoleManager
    val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_CALL_SCREENING)
    this.startActivityForResult(intent, requestId)
}

@RequiresApi(Build.VERSION_CODES.Q)
fun Activity.startSmsPermissionScreen(requestId: Int) {
    val roleManager = this.getSystemService(AppCompatActivity.ROLE_SERVICE) as RoleManager
    var intent: Intent? = null
    if (roleManager.isRoleAvailable(RoleManager.ROLE_SMS) && !roleManager.isRoleHeld(RoleManager.ROLE_SMS)) {
        intent = roleManager.createRequestRoleIntent(
            RoleManager.ROLE_SMS
        )
    }
    this.startActivityForResult(intent, requestId)
}

/**
 * Checks if application has Dialer capability i.e. can take or place the calls.
 */
fun Activity.hasDialerCapability(): Boolean {
    val telecomManager = getSystemService(AppCompatActivity.TELECOM_SERVICE) as TelecomManager
    return packageName.equals(telecomManager.defaultDialerPackage)
}

fun Activity.hasMessagingCapability(context: Context): Boolean {
    val name: String = Telephony.Sms.getDefaultSmsPackage(context)
    return packageName.equals(name)
}

/**
 * Displays a dialog where user can select default dialer app.
 * @param requestId Request ID
 */
fun Activity.startSelectDialerScreen(requestId: Int) {
    Log.d("ActivityExts", "startSelectDialerScreen")
    val intent = Intent(TelecomManager.ACTION_CHANGE_DEFAULT_DIALER)
            .putExtra(TelecomManager.EXTRA_CHANGE_DEFAULT_DIALER_PACKAGE_NAME, packageName)

    startActivityForResult(intent, requestId)
}

fun Activity.startSelectSmsScreen(requestId: Int) {
    val setSmsAppIntent = Intent(Telephony.Sms.Intents.ACTION_CHANGE_DEFAULT)
    setSmsAppIntent.putExtra(Telephony.Sms.Intents.EXTRA_PACKAGE_NAME, packageName)
    startActivityForResult(setSmsAppIntent, requestId)
}
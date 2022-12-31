package com.ejlocop.driverge

import android.content.Intent
import android.os.Bundle
import android.telecom.TelecomManager
import android.util.Log
import androidx.annotation.NonNull
import com.ejlocop.driverge.commons.events.*
import com.ejlocop.driverge.commons.utils.CapabilitiesRequestorImpl
import com.ejlocop.driverge.commons.utils.ManifestPermissionRequesterImpl
import com.ejlocop.driverge.services.MyCallScreeningService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.greenrobot.eventbus.EventBus
import java.lang.ref.WeakReference
import android.content.Context
import android.provider.Telephony
import com.ejlocop.driverge.services.MySMSReceiver
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode

/** MainActivity */
class MainActivity: FlutterActivity() {
    val uiEvent = SingleLiveEvent<UiEvent>()
    private var checkCapabilitiesOnResume = false
    private val manifestPermissionRequestor = ManifestPermissionRequesterImpl()

    var CHANNEL_NAME = "com.ejlocop.driverge/channel"

    private val capabilitiesRequestor = CapabilitiesRequestorImpl()

    private lateinit var _flutterEngine: FlutterEngine;
    private lateinit var _context: Context;

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        listenUiEvents()

        _context = this;

        manifestPermissionRequestor.activity = WeakReference(this)
        capabilitiesRequestor.activityReference = WeakReference(this)

    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        _flutterEngine = flutterEngine
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME).setMethodCallHandler { call, result ->
            when (call.method) {
                "toggleBlocker" -> {
                    val isBlocked = call.argument<Boolean>("isBlocked") ?: false
                    toggleBlocker(isBlocked)
                    result.success("isBlocked $isBlocked")
                }
                "checkDefaultCallApp" -> {
                    val isDefault = checkDefaultCallApp()
                    result.success(isDefault)
                }
                "selectDefaultCallApp" -> {
                    selectDefaultCallApp()
                    result.success("Selecting default call app")
                }
                "checkDefaultSmsApp" -> {
                    val isDefault = checkDefaultSmsApp()
                    result.success(isDefault)
                }
                "selectDefaultSmsApp" -> {
                    selectDefaultSmsApp()
                    result.success("Selecting default call app")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * All Dart methods from MethodChannel
     */

    private fun selectDefaultCallApp() {
        capabilitiesRequestor.invokeCapabilitiesRequest()
    }

    private fun selectDefaultSmsApp() {
        capabilitiesRequestor.invokeSmsCapabilitiesRequest(_context)
    }

    private fun toggleBlocker(isBlocked: Boolean) {
        MyCallScreeningService.isBlockingEnabled = isBlocked
        MySMSReceiver.isBlockingEnabled = isBlocked
    }

    private fun checkDefaultCallApp(): Boolean {
        val manager: TelecomManager = getSystemService(TELECOM_SERVICE) as TelecomManager
        val name: String = manager.defaultDialerPackage
        Log.d("checkDefaultCallApp", name)
        return name == packageName;
    }

    private fun checkDefaultSmsApp(): Boolean {
        val name: String = Telephony.Sms.getDefaultSmsPackage(_context)
        Log.d("checkDefaultSmsApp", name)
        return name == packageName
    }


    private fun listenUiEvents() {

    }

    override fun onStart() {
        super.onStart()
        if (!EventBus.getDefault().isRegistered(this)) {
            EventBus.getDefault().register(this);
        }
    }

    override fun onStop() {
        super.onStop()
        if (EventBus.getDefault().isRegistered(this)) {
            EventBus.getDefault().unregister(this);
        }
    }

    override fun onResume() {
        super.onResume()
        if (checkCapabilitiesOnResume) {
            capabilitiesRequestor.invokeCapabilitiesRequest()
            capabilitiesRequestor.invokeSmsCapabilitiesRequest(_context)
            checkCapabilitiesOnResume = false
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        manifestPermissionRequestor.onRequestPermissionsResult(
            requestCode,
            permissions,
            grantResults
        )
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        capabilitiesRequestor.onActivityResult(requestCode, resultCode, data)
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public fun onMessageEvent(event: MessageEvent) {
        Log.d("Blocker", "onMessageEvent: ${event.message}")
        var args: HashMap<String, String?> = HashMap()
        var channel = MethodChannel(_flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        args.put("source", event.source)
        args.put("phoneNumber", event.message)
        channel.invokeMethod("barredContact", args)
    }
}


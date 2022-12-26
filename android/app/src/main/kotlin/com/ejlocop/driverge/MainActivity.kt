package com.ejlocop.driverge

import android.app.role.RoleManager
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.appcompat.app.AppCompatActivity
import com.ejlocop.driverge.commons.events.*
import com.ejlocop.driverge.commons.utils.CapabilitiesRequestorImpl
import com.ejlocop.driverge.commons.utils.ManifestPermissionRequesterImpl
import com.ejlocop.driverge.commons.utils.NativeMethodChannel
import com.ejlocop.driverge.services.MyCallScreeningService
import com.ejlocop.driverge.services.MySmsBroadcastReceiver
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.greenrobot.eventbus.EventBus
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode
import pub.devrel.easypermissions.AppSettingsDialog
import java.lang.ref.WeakReference

/** MainActivity */
class MainActivity: FlutterActivity() {
    val uiEvent = SingleLiveEvent<UiEvent>()
    private var checkCapabilitiesOnResume = false
    private val manifestPermissionRequestor = ManifestPermissionRequesterImpl()

    var CHANNEL_NAME = "com.ejlocop.driverge/channel"

    private val capabilitiesRequestor = CapabilitiesRequestorImpl()

    private lateinit var _flutterEngine: FlutterEngine;

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        listenUiEvents()

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
                "requestPermissions" -> {
                    requestPermissions()
                    result.success("Permissions requested")
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

    @RequiresApi(Build.VERSION_CODES.Q)
    private fun setDefaultSmsApp() {
        Log.d("MainActivity", "setDefaultSmsApp")
        val roleManager = this.getSystemService(AppCompatActivity.ROLE_SERVICE) as RoleManager
        val intent = roleManager.createRequestRoleIntent(RoleManager.ROLE_SMS)
        startActivity(intent)
    }

    private fun toggleBlocker(isBlocked: Boolean) {
        MyCallScreeningService.isBlockingEnabled = isBlocked
//        MySmsBroadcastReceiver.isBlockingEnabled = isBlocked
    }

    private fun requestPermissions() {
        manifestPermissionRequestor.getPermissions()
    }

    private fun listenUiEvents() {
        uiEvent.observe(this, {
            when (it) {
                is PermissionDenied -> {
                    checkCapabilitiesOnResume = true
                    // This will display a dialog directing them to enable the permission in app settings.
                    AppSettingsDialog.Builder(this).build().show()
                }
                is PhoneManifestPermissionsEnabled -> {
                    // now we can load phone dialer capabilities requests
                    capabilitiesRequestor.invokeCapabilitiesRequest()
                }
                else -> {
                    // NOOP
                }
            }
        })
    }

    override fun onStart() {
        super.onStart()
        EventBus.getDefault().register(this)
    }

    override fun onStop() {
        super.onStop()
        EventBus.getDefault().unregister(this)
    }

    override fun onResume() {
        super.onResume()
        if (checkCapabilitiesOnResume) {
            capabilitiesRequestor.invokeCapabilitiesRequest()
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
    fun onMessageEvent(event: MessageEvent) {
        Log.d("Blocker", "onMessageEvent: ${event.message}")
        var args: HashMap<String, String?> = HashMap()
        var channel = MethodChannel(_flutterEngine.dartExecutor.binaryMessenger, CHANNEL_NAME)
        args.put("source", event.source)
        args.put("phoneNumber", event.message)
        channel.invokeMethod("barredContact", args)
    }
}


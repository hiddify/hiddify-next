package com.hiddify.hiddify

import android.content.Intent
import android.content.IntentFilter
import android.net.VpnService
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var methodResult: MethodChannel.Result
    private var vpnBroadcastReceiver: VpnState? = null

    companion object {
        const val VPN_PERMISSION_REQUEST_CODE = 1001

        enum class Action(val method: String) {
            GrantPermission("grant_permission"),
            StartProxy("start"),
            StopProxy("stop"),
            RefreshStatus("refresh_status"),
            SetPrefs("set_prefs")
        }
    }

    private fun registerBroadcastReceiver() {
        Log.d(HiddifyVpnService.TAG, "registering broadcast receiver")
        vpnBroadcastReceiver = VpnState()
        val intentFilter = IntentFilter(VpnState.ACTION_VPN_STATUS)
        registerReceiver(vpnBroadcastReceiver, intentFilter)
    }

    private fun unregisterBroadcastReceiver() {
        Log.d(HiddifyVpnService.TAG, "unregistering broadcast receiver")
        if (vpnBroadcastReceiver != null) {
            unregisterReceiver(vpnBroadcastReceiver)
            vpnBroadcastReceiver = null
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel =
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HiddifyVpnService.TAG)
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, HiddifyVpnService.EVENT_TAG)
        registerBroadcastReceiver()
        eventChannel.setStreamHandler(vpnBroadcastReceiver)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        methodResult = result
        @Suppress("UNCHECKED_CAST")
        when (call.method) {
            Action.GrantPermission.method -> {
                grantVpnPermission()
            }

            Action.StartProxy.method -> {
                VpnServiceManager.startVpnService(this)
                result.success(true)
            }

            Action.StopProxy.method -> {
                VpnServiceManager.stopVpnService()
                result.success(true)
            }

            Action.RefreshStatus.method -> {
                val statusIntent = Intent(VpnState.ACTION_VPN_STATUS)
                statusIntent.putExtra(VpnState.IS_VPN_ACTIVE, VpnServiceManager.isRunning)
                sendBroadcast(statusIntent)
                result.success(true)
            }

            Action.SetPrefs.method -> {
                val args = call.arguments as Map<String, Any>
                VpnServiceManager.setPrefs(context, args)
                result.success(true)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterBroadcastReceiver()
    }

    private fun grantVpnPermission() {
        val vpnPermissionIntent = VpnService.prepare(this)
        if (vpnPermissionIntent == null) {
            onActivityResult(VPN_PERMISSION_REQUEST_CODE, RESULT_OK, null)
        } else {
            startActivityForResult(vpnPermissionIntent, VPN_PERMISSION_REQUEST_CODE)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == VPN_PERMISSION_REQUEST_CODE) {
            methodResult.success(resultCode == RESULT_OK)
        } else if (requestCode == 101010) {
            methodResult.success(resultCode == RESULT_OK)
        }
    }
}

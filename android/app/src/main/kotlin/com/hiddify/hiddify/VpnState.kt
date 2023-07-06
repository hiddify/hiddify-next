package com.hiddify.hiddify

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import io.flutter.plugin.common.EventChannel

class VpnState : BroadcastReceiver(), EventChannel.StreamHandler{
    companion object {
        const val ACTION_VPN_STATUS = "Hiddify.VpnState.ACTION_VPN_STATUS"
        const val IS_VPN_ACTIVE = "isVpnActive"
    }


    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == ACTION_VPN_STATUS) {
            val isVpnActive = intent.getBooleanExtra(IS_VPN_ACTIVE, false)
            Log.d(HiddifyVpnService.TAG, "send to flutter: status= $isVpnActive")
            VpnServiceManager.isRunning = isVpnActive
            eventSink?.success(isVpnActive)
        }
    }
}
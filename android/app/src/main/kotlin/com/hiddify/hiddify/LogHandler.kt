package com.hiddify.hiddify

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel


class LogHandler : FlutterPlugin {

    companion object {
        const val TAG = "A/LogHandler"
        const val SERVICE_LOGS = "com.hiddify.app/service.logs"
    }

    private lateinit var logsChannel: EventChannel

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        logsChannel = EventChannel(flutterPluginBinding.binaryMessenger, SERVICE_LOGS)

        logsChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                MainActivity.instance.serviceLogs.observeForever { it ->
                    if (it == null) return@observeForever
                    events?.success(it)
                }
            }

            override fun onCancel(arguments: Any?) {
            }
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    }
}
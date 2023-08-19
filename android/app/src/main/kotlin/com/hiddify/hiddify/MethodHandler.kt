package com.hiddify.hiddify

import androidx.annotation.NonNull
import com.hiddify.hiddify.bg.BoxService
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec

class MethodHandler : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel

    companion object {
        const val channelName = "com.hiddify.app/method"

        enum class Trigger(val method: String) {
            ParseConfig("parse_config"),
            SetActiveConfigPath("set_active_config_path"),
            Start("start"),
            Stop("stop"),
        }
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        val taskQueue = flutterPluginBinding.binaryMessenger.makeBackgroundTaskQueue()
        channel = MethodChannel(
            flutterPluginBinding.binaryMessenger,
            channelName,
            StandardMethodCodec.INSTANCE,
            taskQueue
        )
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            Trigger.ParseConfig.method -> {
                val args = call.arguments as Map<*, *>
                val path = args["path"] as String? ?: ""
                val msg = BoxService.parseConfig(path)
                result.success(msg)
            }

            Trigger.SetActiveConfigPath.method -> {
                val args = call.arguments as Map<*, *>
                Settings.selectedConfigPath = args["path"] as String? ?: ""
                result.success(true)
            }

            Trigger.Start.method -> {
                MainActivity.instance.startService()
                result.success(true)
            }

            Trigger.Stop.method -> {
                BoxService.stop()
                result.success(true)
            }

            else -> result.notImplemented()
        }
    }
}
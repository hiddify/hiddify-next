package com.hiddify.hiddify

import androidx.annotation.NonNull
import com.hiddify.hiddify.bg.BoxService
import com.hiddify.hiddify.constant.Status
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec
import io.nekohasekai.libbox.Libbox
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

class MethodHandler : FlutterPlugin, MethodChannel.MethodCallHandler {
    private var channel: MethodChannel? = null

    companion object {
        const val channelName = "com.hiddify.app/method"

        enum class Trigger(val method: String) {
            ParseConfig("parse_config"),
            ChangeConfigOptions("change_config_options"),
            Start("start"),
            Stop("stop"),
            Restart("restart"),
            SelectOutbound("select_outbound"),
            UrlTest("url_test"),
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
        channel!!.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            Trigger.ParseConfig.method -> {
                GlobalScope.launch {
                    result.runCatching {
                        val args = call.arguments as Map<*, *>
                        val path = args["path"] as String
                        val tempPath = args["tempPath"] as String
                        val debug = args["debug"] as Boolean
                        val msg = BoxService.parseConfig(path, tempPath, debug)
                        success(msg)
                    }
                }
            }

            Trigger.ChangeConfigOptions.method -> {
                result.runCatching {
                    val args = call.arguments as String
                    Settings.configOptions = args
                    success(true)
                }
            }

            Trigger.Start.method -> {
                val args = call.arguments as Map<*, *>
                Settings.activeConfigPath = args["path"] as String? ?: ""
                MainActivity.instance.startService()
                result.success(true)
            }

            Trigger.Stop.method -> {
                BoxService.stop()
                result.success(true)
            }

            Trigger.Restart.method -> {
                GlobalScope.launch {
                    result.runCatching {
                        val args = call.arguments as Map<*, *>
                        Settings.activeConfigPath = args["path"] as String? ?: ""
                        val mainActivity = MainActivity.instance
                        val started = mainActivity.serviceStatus.value == Status.Started
                        if (!started) return@launch success(true)
                        val restart = Settings.rebuildServiceMode()
                        if (restart) {
                            mainActivity.reconnect()
                            BoxService.stop()
                            delay(200)
                            mainActivity.startService()
                            success(true)
                            return@launch
                        }
                        runCatching {
                            Libbox.newStandaloneCommandClient().serviceReload()
                            success(true)
                        }.onFailure {
                            error(it)
                        }
                    }
                }
            }

            Trigger.SelectOutbound.method -> {
                GlobalScope.launch {
                    result.runCatching {
                        val args = call.arguments as Map<*, *>
                        Libbox.newStandaloneCommandClient()
                            .selectOutbound(
                                args["groupTag"] as String,
                                args["outboundTag"] as String
                            )
                        success(true)
                    }
                }
            }

            Trigger.UrlTest.method -> {
                GlobalScope.launch {
                    result.runCatching {
                        val args = call.arguments as Map<*, *>
                        Libbox.newStandaloneCommandClient()
                            .urlTest(
                                args["groupTag"] as String
                            )
                        success(true)
                    }
                }
            }

            else -> result.notImplemented()
        }
    }
}
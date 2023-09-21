package com.hiddify.hiddify

import android.util.Log
import com.google.gson.Gson
import com.google.gson.annotations.SerializedName
import com.hiddify.hiddify.utils.CommandClient
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.nekohasekai.libbox.OutboundGroup
import io.nekohasekai.libbox.OutboundGroupItem
import kotlinx.coroutines.CoroutineScope

class GroupsChannel(private val scope: CoroutineScope) : FlutterPlugin, CommandClient.Handler {
    companion object {
        const val TAG = "A/GroupsChannel"
        const val GROUP_CHANNEL = "com.hiddify.app/groups"
        val gson = Gson()
    }

    private val commandClient =
        CommandClient(scope, CommandClient.ConnectionType.Groups, this)

    private var groupsChannel: EventChannel? = null

    private var groupsEvent: EventChannel.EventSink? = null

    override fun updateGroups(groups: List<OutboundGroup>) {
        MainActivity.instance.runOnUiThread {
            val kGroups = groups.map { group -> KOutboundGroup.fromOutbound(group) }
            groupsEvent?.success(gson.toJson(kGroups))
        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        groupsChannel = EventChannel(
            flutterPluginBinding.binaryMessenger,
            GROUP_CHANNEL
        )

        groupsChannel!!.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                groupsEvent = events
                Log.d(TAG, "connecting groups command client")
                commandClient.connect()
            }

            override fun onCancel(arguments: Any?) {
                groupsEvent = null
                Log.d(TAG, "disconnecting groups command client")
                commandClient.disconnect()
            }
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        groupsEvent = null
        commandClient.disconnect()
        groupsChannel?.setStreamHandler(null)
    }

    data class KOutboundGroup(
        @SerializedName("tag") val tag: String,
        @SerializedName("type") val type: String,
        @SerializedName("selected") val selected: String,
        @SerializedName("items") val items: List<KOutboundGroupItem>
    ) {
        companion object {
            fun fromOutbound(group: OutboundGroup): KOutboundGroup {
                val outboundItems = group.items
                val items = mutableListOf<KOutboundGroupItem>()
                while (outboundItems.hasNext()) {
                    items.add(KOutboundGroupItem(outboundItems.next()))
                }
                return KOutboundGroup(group.tag, group.type, group.selected, items)
            }
        }
    }

    data class KOutboundGroupItem(
        @SerializedName("tag") val tag: String,
        @SerializedName("type") val type: String,
        @SerializedName("url-test-delay") val urlTestDelay: Int,
    ) {
        constructor(item: OutboundGroupItem) : this(item.tag, item.type, item.urlTestDelay)
    }
}
package com.hiddify.hiddify

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Context.NOTIFICATION_SERVICE
import android.content.Intent
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.app.NotificationCompat
import java.lang.ref.SoftReference

data class VpnServiceConfigs(val httpPort: Int = 12346, val socksPort: Int = 12347, val systemProxy: Boolean = true)

object VpnServiceManager {
    private const val NOTIFICATION_ID = 1
    private const val NOTIFICATION_CHANNEL_ID = "hiddify_vpn"
    private const val NOTIFICATION_CHANNEL_NAME = "Hiddify VPN"

    var vpnService: SoftReference<HiddifyVpnService>? = null
    var prefs = VpnServiceConfigs()
    var isRunning = false

    private var mBuilder: NotificationCompat.Builder? = null
    private var mNotificationManager: NotificationManager? = null

    fun startVpnService(context: Context) {
        val intent = Intent(context.applicationContext, HiddifyVpnService::class.java)
        if (Build.VERSION.SDK_INT > Build.VERSION_CODES.N_MR1) {
            context.startForegroundService(intent)
        } else {
            context.startService(intent)
        }
    }

    fun stopVpnService() {
        val service = vpnService?.get() ?: return
        service.stopVpnService()
    }

    fun setPrefs(context: Context,args: Map<String, Any>) {
        prefs = prefs.copy(
            httpPort = args["httpPort"] as Int? ?: prefs.httpPort,
            socksPort = args["socksPort"] as Int? ?: prefs.socksPort,
            systemProxy = args["systemProxy"] as Boolean? ?: prefs.systemProxy,
        )
        if(isRunning) {
            stopVpnService()
            startVpnService(context)
        }
    }

    fun showNotification() {
        val service = vpnService?.get()?.getService() ?: return
        val channelId = if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannel()
        } else {
            ""
        }

        mBuilder = NotificationCompat.Builder(service, channelId)
            .setSmallIcon(R.drawable.ic_stat_logo)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setOngoing(true)
            .setShowWhen(false)
            .setOnlyAlertOnce(true)
            .setContentTitle("Hiddify")
            .setContentText("Connected")

        service.startForeground(NOTIFICATION_ID, mBuilder?.build())
    }

    fun cancelNotification() {
        val service = vpnService?.get()?.getService() ?: return
        service.stopForeground(true)
        mBuilder = null
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun createNotificationChannel(): String {
        val channel = NotificationChannel(NOTIFICATION_CHANNEL_ID, NOTIFICATION_CHANNEL_NAME, NotificationManager.IMPORTANCE_HIGH)
        channel.lockscreenVisibility = Notification.VISIBILITY_PRIVATE
        getNotificationManager()?.createNotificationChannel(
            channel
        )
        return NOTIFICATION_CHANNEL_ID
    }

    private fun getNotificationManager(): NotificationManager? {
        if (mNotificationManager == null) {
            val service = vpnService?.get()?.getService() ?: return null
            mNotificationManager = service.getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        }
        return mNotificationManager
    }
}
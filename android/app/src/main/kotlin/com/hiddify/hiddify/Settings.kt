package com.hiddify.hiddify

import android.content.Context
import com.hiddify.hiddify.bg.ProxyService
import com.hiddify.hiddify.bg.VPNService
import com.hiddify.hiddify.constant.ServiceMode
import com.hiddify.hiddify.constant.SettingsKey
import org.json.JSONObject
import java.io.File

object Settings {

    const val PER_APP_PROXY_DISABLED = 0
    const val PER_APP_PROXY_EXCLUDE = 1
    const val PER_APP_PROXY_INCLUDE = 2

    private val preferences by lazy {
        val context = Application.application.applicationContext
        context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
    }

    var perAppProxyEnabled = preferences.getBoolean(SettingsKey.PER_APP_PROXY_ENABLED, false)
    var perAppProxyMode = preferences.getInt(SettingsKey.PER_APP_PROXY_MODE, PER_APP_PROXY_EXCLUDE)
    var perAppProxyList = preferences.getStringSet(SettingsKey.PER_APP_PROXY_LIST, emptySet())!!
    var perAppProxyUpdateOnChange =
        preferences.getInt(SettingsKey.PER_APP_PROXY_UPDATE_ON_CHANGE, PER_APP_PROXY_DISABLED)

    var activeConfigPath: String
        get() = preferences.getString(SettingsKey.ACTIVE_CONFIG_PATH, "") ?: ""
        set(value) = preferences.edit().putString(SettingsKey.ACTIVE_CONFIG_PATH, value).apply()

    var serviceMode: String
        get() = preferences.getString(SettingsKey.SERVICE_MODE, ServiceMode.NORMAL)
            ?: ServiceMode.NORMAL
        set(value) = preferences.edit().putString(SettingsKey.SERVICE_MODE, value).apply()

    var configOptions: String
        get() = preferences.getString(SettingsKey.CONFIG_OPTIONS, "") ?: ""
        set(value) = preferences.edit().putString(SettingsKey.CONFIG_OPTIONS, value).apply()

    var debugMode: Boolean
        get() = preferences.getBoolean(SettingsKey.DEBUG_MODE, false)
        set(value) = preferences.edit().putBoolean(SettingsKey.DEBUG_MODE, value).apply()

    val enableTun: Boolean
        get() = preferences.getBoolean(SettingsKey.ENABLE_TUN, true)

    var disableMemoryLimit: Boolean
        get() = preferences.getBoolean(SettingsKey.DISABLE_MEMORY_LIMIT, false)
        set(value) = preferences.edit().putBoolean(SettingsKey.DISABLE_MEMORY_LIMIT, value).apply()

    var systemProxyEnabled: Boolean
        get() = preferences.getBoolean(SettingsKey.SYSTEM_PROXY_ENABLED, true)
        set(value) = preferences.edit().putBoolean(SettingsKey.SYSTEM_PROXY_ENABLED, value).apply()

    var startedByUser: Boolean
        get() = preferences.getBoolean(SettingsKey.STARTED_BY_USER, false)
        set(value) = preferences.edit().putBoolean(SettingsKey.STARTED_BY_USER, value).apply()

    fun serviceClass(): Class<*> {
        return when (serviceMode) {
            ServiceMode.VPN -> VPNService::class.java
            else -> ProxyService::class.java
        }
    }

    suspend fun rebuildServiceMode(): Boolean {
        var newMode = ServiceMode.NORMAL
        try {
            if (needVPNService()) {
                newMode = ServiceMode.VPN
            }
        } catch (_: Exception) {
        }
        if (serviceMode == newMode) {
            return false
        }
        serviceMode = newMode
        return true
    }

    private suspend fun needVPNService(): Boolean {
        if(enableTun) return true
        val filePath = activeConfigPath
        if (filePath.isBlank()) return false
        val content = JSONObject(File(filePath).readText())
        val inbounds = content.getJSONArray("inbounds")
        for (index in 0 until inbounds.length()) {
            val inbound = inbounds.getJSONObject(index)
            if (inbound.getString("type") == "tun") {
                return true
            }
        }
        return false
    }
}


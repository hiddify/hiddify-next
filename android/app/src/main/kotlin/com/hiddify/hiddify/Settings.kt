package com.hiddify.hiddify

import android.content.Context
import com.hiddify.hiddify.constant.SettingsKey

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

    var configOptions: String
        get() = preferences.getString(SettingsKey.CONFIG_OPTIONS, "") ?: ""
        set(value) = preferences.edit().putString(SettingsKey.CONFIG_OPTIONS, value).apply()

    var disableMemoryLimit: Boolean
        get() = preferences.getBoolean(SettingsKey.DISABLE_MEMORY_LIMIT, false)
        set(value) = preferences.edit().putBoolean(SettingsKey.DISABLE_MEMORY_LIMIT, value).apply()

    var systemProxyEnabled: Boolean
        get() = preferences.getBoolean(SettingsKey.SYSTEM_PROXY_ENABLED, true)
        set(value) = preferences.edit().putBoolean(SettingsKey.SYSTEM_PROXY_ENABLED, value).apply()

    var startedByUser: Boolean
        get() = preferences.getBoolean(SettingsKey.STARTED_BY_USER, false)
        set(value) = preferences.edit().putBoolean(SettingsKey.STARTED_BY_USER, value).apply()
}


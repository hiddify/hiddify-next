package com.hiddify.hiddify.constant

object SettingsKey {
    private const val KEY_PREFIX = "flutter."

    const val ACTIVE_CONFIG_PATH = "${KEY_PREFIX}active_config_path"
    const val SERVICE_MODE = "${KEY_PREFIX}service_mode"

    const val CONFIG_OPTIONS = "config_options_json"

    const val PER_APP_PROXY_ENABLED = "per_app_proxy_enabled"
    const val PER_APP_PROXY_MODE = "per_app_proxy_mode"
    const val PER_APP_PROXY_LIST = "per_app_proxy_list"
    const val PER_APP_PROXY_UPDATE_ON_CHANGE = "per_app_proxy_update_on_change"

    const val DISABLE_MEMORY_LIMIT = "${KEY_PREFIX}disable_memory_limit"
    const val SYSTEM_PROXY_ENABLED = "${KEY_PREFIX}system_proxy_enabled"

    // cache

    const val STARTED_BY_USER = "${KEY_PREFIX}started_by_user"

}
package com.hiddify.hiddify

import android.content.Intent
import android.net.VpnService
import android.util.Log
import androidx.core.content.ContextCompat
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.lifecycleScope
import com.hiddify.hiddify.bg.ServiceConnection
import com.hiddify.hiddify.bg.ServiceNotification
import com.hiddify.hiddify.bg.VPNService
import com.hiddify.hiddify.constant.Alert
import com.hiddify.hiddify.constant.Status
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.LinkedList

class MainActivity : FlutterFragmentActivity(), ServiceConnection.Callback {
    companion object {
        private const val TAG = "ANDROID/MyActivity"
        lateinit var instance: MainActivity

        const val VPN_PERMISSION_REQUEST_CODE = 1001
        const val NOTIFICATION_PERMISSION_REQUEST_CODE = 1010
    }

    private val connection = ServiceConnection(this, this)

    val logList = LinkedList<String>()
    var logCallback: ((Boolean) -> Unit)? = null
    val serviceStatus = MutableLiveData(Status.Stopped)
    val serviceAlerts = MutableLiveData<ServiceEvent?>(null)
    val serviceLogs = MutableLiveData<String?>(null)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        instance = this
        reconnect()
        flutterEngine.plugins.add(MethodHandler())
        flutterEngine.plugins.add(EventHandler())
        flutterEngine.plugins.add(LogHandler())
    }

    fun reconnect() {
        connection.reconnect()
    }

    fun startService() {
        if (!ServiceNotification.checkPermission()) {
            Log.d(TAG, "missing notification permission")
            return
        }
        lifecycleScope.launch(Dispatchers.IO) {
//            if (Settings.rebuildServiceMode()) {
//                reconnect()
//            }
            if (prepare()) {
                Log.d(TAG, "VPN permission required")
                return@launch
            }

            val intent = Intent(Application.application, VPNService::class.java)
            withContext(Dispatchers.Main) {
                ContextCompat.startForegroundService(Application.application, intent)
            }
        }
    }


    override fun onServiceStatusChanged(status: Status) {
        Log.d(TAG, "service status changed: $status")
        serviceStatus.postValue(status)
    }


    override fun onServiceAlert(type: Alert, message: String?) {
        Log.d(TAG, "service alert: $type")
        serviceAlerts.postValue(ServiceEvent(Status.Stopped, type, message))
    }

    private var paused = false
    override fun onPause() {
        super.onPause()

        paused = true
    }

    override fun onResume() {
        super.onResume()

        paused = false
        logCallback?.invoke(true)
    }

    override fun onServiceWriteLog(message: String?) {
        if (paused) {
            if (logList.size > 300) {
                logList.removeFirst()
            }
        }
        logList.addLast(message)
        if (!paused) {
            logCallback?.invoke(false)
            serviceLogs.postValue(message)
        }
    }

    override fun onServiceResetLogs(messages: MutableList<String>) {
        logList.clear()
        logList.addAll(messages)
        if (!paused) logCallback?.invoke(true)
    }

    override fun onDestroy() {
        connection.disconnect()
        super.onDestroy()
    }

    private suspend fun prepare() = withContext(Dispatchers.Main) {
        try {
            val intent = VpnService.prepare(this@MainActivity)
            if (intent != null) {
//                prepareLauncher.launch(intent)
                startActivityForResult(intent, VPN_PERMISSION_REQUEST_CODE)
                true
            } else {
                false
            }
        } catch (e: Exception) {
            onServiceAlert(Alert.RequestVPNPermission, e.message)
            false
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == VPN_PERMISSION_REQUEST_CODE) {
            if (resultCode == RESULT_OK) startService()
            else onServiceAlert(Alert.RequestVPNPermission, null)
        } else if (requestCode == NOTIFICATION_PERMISSION_REQUEST_CODE) {
            if (resultCode == RESULT_OK) startService()
            else onServiceAlert(Alert.RequestNotificationPermission, null)
        }
    }
}

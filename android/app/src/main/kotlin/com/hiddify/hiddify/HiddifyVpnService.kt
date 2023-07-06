package com.hiddify.hiddify

import android.app.PendingIntent
import android.app.Service
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.LocalSocket
import android.net.LocalSocketAddress
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.net.ProxyInfo
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import android.os.StrictMode
import android.util.Log
import androidx.annotation.RequiresApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.io.File
import java.lang.ref.SoftReference

class HiddifyVpnService : VpnService() {
    companion object {
        const val TAG = "Hiddify/VpnService"
        const val EVENT_TAG = "Hiddify/VpnServiceEvents"
        private const val TUN2SOCKS = "libtun2socks.so"

        private const val TUN_MTU = 9000
        private const val TUN_GATEWAY = "172.19.0.1"
        private const val TUN_ROUTER = "172.19.0.2"
        private const val TUN_SUBNET_PREFIX = 30
        private const val NET_ANY = "0.0.0.0"
        private val HTTP_PROXY_LOCAL_LIST = listOf(
            "localhost",
            "*.local",
            "127.*",
            "10.*",
            "172.16.*",
            "172.17.*",
            "172.18.*",
            "172.19.*",
            "172.2*",
            "172.30.*",
            "172.31.*",
            "192.168.*"
        )
    }

    private var vpnBroadcastReceiver: VpnState? = null
    private var conn: ParcelFileDescriptor? = null
    private lateinit var process: Process
    private var isRunning = false

    // prefs
    private var includeAppPackages: Set<String> = HashSet()

    fun getService(): Service {
        return this
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        startVpnService()
        return START_STICKY
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "creating vpn service")
        val policy = StrictMode.ThreadPolicy.Builder().permitAll().build()
        StrictMode.setThreadPolicy(policy)
        registerBroadcastReceiver()
        VpnServiceManager.vpnService = SoftReference(this)
    }

    override fun onRevoke() {
        Log.d(TAG, "vpn service revoked")
        super.onRevoke()
        stopVpnService()
    }

    override fun onDestroy() {
        Log.d(TAG, "vpn service destroyed")
        super.onDestroy()
        broadcastVpnStatus(false)
        VpnServiceManager.cancelNotification()
        unregisterBroadcastReceiver()
    }

    private fun registerBroadcastReceiver() {
        Log.d(TAG, "registering receiver in service")
        vpnBroadcastReceiver = VpnState()
        val intentFilter = IntentFilter(VpnState.ACTION_VPN_STATUS)
        registerReceiver(vpnBroadcastReceiver, intentFilter)
    }

    private fun unregisterBroadcastReceiver() {
        Log.d(TAG, "unregistering receiver in service")
        if (vpnBroadcastReceiver != null) {
            unregisterReceiver(vpnBroadcastReceiver)
            vpnBroadcastReceiver = null
        }
    }

    private fun broadcastVpnStatus(isVpnActive: Boolean) {
        Log.d(TAG, "broadcasting status= $isVpnActive")
        val intent = Intent(VpnState.ACTION_VPN_STATUS)
        intent.putExtra(VpnState.IS_VPN_ACTIVE, isVpnActive)
        sendBroadcast(intent)
    }

    @delegate:RequiresApi(Build.VERSION_CODES.P)
    private val defaultNetworkRequest by lazy {
        NetworkRequest.Builder()
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .addCapability(NetworkCapabilities.NET_CAPABILITY_NOT_RESTRICTED)
            .build()
    }

    private val connectivity by lazy { getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager }

    @delegate:RequiresApi(Build.VERSION_CODES.P)
    private val defaultNetworkCallback by lazy {
        object : ConnectivityManager.NetworkCallback() {
            override fun onAvailable(network: Network) {
                setUnderlyingNetworks(arrayOf(network))
            }

            override fun onCapabilitiesChanged(network: Network, networkCapabilities: NetworkCapabilities) {
                // it's a good idea to refresh capabilities
                setUnderlyingNetworks(arrayOf(network))
            }

            override fun onLost(network: Network) {
                setUnderlyingNetworks(null)
            }
        }
    }

    private fun startVpnService() {
        val prepare = prepare(this)
        if (prepare != null) {
            return
        }

        with(Builder()) {
            addAddress(TUN_GATEWAY, TUN_SUBNET_PREFIX)
            setMtu(TUN_MTU)
            addRoute(NET_ANY, 0)
            addDnsServer(TUN_ROUTER)
            allowBypass()
            setBlocking(true)
            setSession("Hiddify")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                setMetered(false)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q && VpnServiceManager.prefs.systemProxy) {
                setHttpProxy(
                    ProxyInfo.buildDirectProxy(
                        "127.0.0.1",
                        VpnServiceManager.prefs.httpPort,
                        HTTP_PROXY_LOCAL_LIST,
                    )
                )
            }
            if (includeAppPackages.isEmpty()) {
                addDisallowedApplication(packageName)
            } else {
                includeAppPackages.forEach {
                    addAllowedApplication(it)
                }
            }
            setConfigureIntent(
                PendingIntent.getActivity(
                    this@HiddifyVpnService,
                    0,
                    Intent().setComponent(ComponentName(packageName, "$packageName.MainActivity")),
                    pendingIntentFlags(PendingIntent.FLAG_UPDATE_CURRENT)
                )
            )

            try {
                conn?.close()
            } catch (ignored: Exception) {
                // ignored
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                try {
                    connectivity.requestNetwork(defaultNetworkRequest, defaultNetworkCallback)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
            }
            try {
                conn = establish()
                isRunning = true
                runTun2socks()
                VpnServiceManager.showNotification()
                Log.d(TAG, "vpn connection established")
                broadcastVpnStatus(true)
            } catch (e: Exception) {
                Log.w(TAG, "failed to start vpn service: $e")
                e.printStackTrace()
                stopVpnService()
                broadcastVpnStatus(false)
            }
        }
    }

    fun stopVpnService(isForced: Boolean = true) {
        Log.d(TAG, "stopping vpn service, forced: [$isForced]")
        isRunning = false
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            try {
                connectivity.unregisterNetworkCallback(defaultNetworkCallback)
            } catch (ignored: Exception) {
                // ignored
            }
        }

        try {
            Log.d(TAG, "destroying tun2socks")
            process.destroy()
        } catch (e: Exception) {
            Log.e(TAG, e.toString())
        }

        if(isForced) {
            stopSelf()
            try {
                conn?.close()
                conn = null
            } catch (ignored: Exception) {
                // ignored
            }
        }
        Log.d(TAG, "vpn service stopped")
    }

    private fun runTun2socks() {
        val cmd = arrayListOf(
            File(applicationContext.applicationInfo.nativeLibraryDir, TUN2SOCKS).absolutePath,
            "--netif-ipaddr", TUN_ROUTER,
            "--netif-netmask", "255.255.255.252",
            "--socks-server-addr", "127.0.0.1:${VpnServiceManager.prefs.socksPort}",
            "--tunmtu", TUN_MTU.toString(),
            "--sock-path", "sock_path",//File(applicationContext.filesDir, "sock_path").absolutePath,
            "--enable-udprelay",
            "--loglevel", "notice")

        Log.d(TAG, cmd.toString())
        protect(conn!!.fd) // not sure

        try {
            val proBuilder = ProcessBuilder(cmd)
            proBuilder.redirectErrorStream(true)
            process = proBuilder
                .directory(applicationContext.filesDir)
                .start()
            Thread(Runnable {
                Log.d(TAG,"$TUN2SOCKS check")
                process.waitFor()
                Log.d(TAG,"$TUN2SOCKS exited")
                if (isRunning) {
                    Log.d(packageName,"$TUN2SOCKS restart")
                    runTun2socks()
                }
            }).start()
            Log.d(TAG, process.toString())

            sendFd()
        } catch (e: Exception) {
            Log.d(TAG, e.toString())
        }
    }

    private fun sendFd() {
        val fd = conn!!.fileDescriptor
        val path = File(applicationContext.filesDir, "sock_path").absolutePath
        Log.d(TAG, path)

        GlobalScope.launch(Dispatchers.IO) {
            var tries = 0
            while (true) try {
                Thread.sleep(50L shl tries)
                Log.d(TAG, "sendFd tries: $tries")
                LocalSocket().use { localSocket ->
                    localSocket.connect(LocalSocketAddress(path, LocalSocketAddress.Namespace.FILESYSTEM))
                    localSocket.setFileDescriptorsForSend(arrayOf(fd))
                    localSocket.outputStream.write(42)
                }
                break
            } catch (e: Exception) {
                Log.d(TAG, e.toString())
                if (tries > 5) break
                tries += 1
            }
        }
    }

    private fun pendingIntentFlags(flags: Int, mutable: Boolean = false): Int {
        return if (Build.VERSION.SDK_INT >= 24) {
            if (Build.VERSION.SDK_INT > 30 && mutable) {
                flags or PendingIntent.FLAG_MUTABLE
            } else {
                flags or PendingIntent.FLAG_IMMUTABLE
            }
        } else {
            flags
        }
    }
}
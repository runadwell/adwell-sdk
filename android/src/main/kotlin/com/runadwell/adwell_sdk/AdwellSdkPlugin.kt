package com.runadwell.adwell_sdk

import android.content.Context
import android.content.pm.ApplicationInfo
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicBoolean

/**
 * Android stub. Apple Ads has no Android installs and Google attribution comes
 * later, so this keeps an install id for billing SDKs and sends nothing.
 */
class AdwellSdkPlugin : FlutterPlugin, MethodCallHandler {
    private var channel: MethodChannel? = null
    private lateinit var installId: InstallId
    private var debuggable = false
    private val worker = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        val context = binding.applicationContext
        val prefs = context.getSharedPreferences("com.runadwell.sdk", Context.MODE_PRIVATE)
        installId = InstallId(
            read = { prefs.getString(KEY, null) },
            write = { prefs.edit().putString(KEY, it).apply() },
        )
        debuggable = context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE != 0
        channel = MethodChannel(binding.binaryMessenger, "com.runadwell.sdk").also { it.setMethodCallHandler(this) }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "configure" -> {
                if ((debuggable || call.argument<String>("logLevel") == "debug") && noticed.compareAndSet(false, true)) {
                    Log.i(TAG, "[Adwell] Android keeps an install id but sends nothing yet: Apple Ads attribution is iOS only.")
                }
                result.success(null)
            }
            // SharedPreferences reads from disk the first time: keep it off the main thread.
            "installId" -> worker.execute {
                val id = runCatching { installId.value() }.getOrNull()
                main.post { result.success(id) }
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }

    private companion object {
        const val KEY = "install_id"
        const val TAG = "Adwell"
        val noticed = AtomicBoolean(false)
    }
}

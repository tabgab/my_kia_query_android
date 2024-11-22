package com.example.my_kia_query

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform
import androidx.annotation.NonNull

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.example.my_kia_query/kia_bridge"
    private var python: Python? = null
    private var kiaBridgeModule: com.chaquo.python.PyObject? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Initialize Python
        if (!Python.isStarted()) {
            Python.start(AndroidPlatform(applicationContext))
        }
        python = Python.getInstance()
        kiaBridgeModule = python?.getModule("kia_bridge")

        // Set up method channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "authenticate" -> {
                        val username = call.argument<String>("username")
                        val password = call.argument<String>("password")
                        val pin = call.argument<String>("pin")
                        val region = call.argument<String>("region")
                        val brand = call.argument<String>("brand")

                        if (username == null || password == null || pin == null || region == null || brand == null) {
                            result.error("INVALID_ARGUMENTS", "Missing required arguments", null)
                            return@setMethodCallHandler
                        }

                        val response = kiaBridgeModule?.callAttr(
                            "authenticate",
                            username,
                            password,
                            pin,
                            region,
                            brand
                        )
                        result.success(response?.toBoolean())
                    }
                    "getVehicles" -> {
                        val response = kiaBridgeModule?.callAttr("get_vehicles")
                        result.success(response?.toString())
                    }
                    "refreshVehicleData" -> {
                        val response = kiaBridgeModule?.callAttr("refresh_vehicle_data")
                        result.success(response?.toBoolean())
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            } catch (e: Exception) {
                result.error("PYTHON_ERROR", e.message, e.stackTraceToString())
            }
        }
    }
}

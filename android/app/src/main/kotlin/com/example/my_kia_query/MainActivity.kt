package com.example.my_kia_query

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import com.example.my_kia_query.widget.VehicleUpdateService
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.example.my_kia_query/kia_bridge"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        if (!Python.isStarted()) {
            Python.start(AndroidPlatform(this))
        }
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
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

                    Thread {
                        try {
                            val py = Python.getInstance()
                            val module = py.getModule("kia_bridge")
                            val success = module.callAttr(
                                "authenticate",
                                username,
                                password,
                                pin,
                                region,
                                brand
                            ).toBoolean()
                            runOnUiThread { result.success(success) }
                        } catch (e: Exception) {
                            runOnUiThread {
                                result.error(
                                    "PYTHON_ERROR",
                                    "Error in Python code: ${e.message}",
                                    e.toString()
                                )
                            }
                        }
                    }.start()
                }
                "getVehicles" -> {
                    Thread {
                        try {
                            val py = Python.getInstance()
                            val module = py.getModule("kia_bridge")
                            val vehicles = module.callAttr("get_vehicles").toString()
                            runOnUiThread { result.success(vehicles) }
                        } catch (e: Exception) {
                            runOnUiThread {
                                result.error(
                                    "PYTHON_ERROR",
                                    "Error in Python code: ${e.message}",
                                    e.toString()
                                )
                            }
                        }
                    }.start()
                }
                "refreshVehicleData" -> {
                    Thread {
                        try {
                            val py = Python.getInstance()
                            val module = py.getModule("kia_bridge")
                            val success = module.callAttr("refresh_vehicle_data").toBoolean()
                            runOnUiThread { result.success(success) }
                        } catch (e: Exception) {
                            runOnUiThread {
                                result.error(
                                    "PYTHON_ERROR",
                                    "Error in Python code: ${e.message}",
                                    e.toString()
                                )
                            }
                        }
                    }.start()
                }
                "notifyWidget" -> {
                    val serviceIntent = Intent(this, VehicleUpdateService::class.java)
                    startService(serviceIntent)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}

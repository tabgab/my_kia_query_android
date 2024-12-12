package com.example.my_kia_query.widget

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.content.Context
import android.util.Log
import org.json.JSONArray
import java.io.File
import kotlin.concurrent.thread

class VehicleUpdateService : Service() {
    companion object {
        private const val TAG = "VehicleUpdateService"
        private const val CACHE_FILE = "vehicle_data.json"
        private const val DEFAULT_BATTERY_LEVEL = 0
        private const val DEFAULT_WARNING_LEVEL = 65
    }

    override fun onBind(intent: Intent): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        thread {
            updateWidgetFromCache()
        }
        return START_NOT_STICKY
    }

    private fun updateWidgetFromCache() {
        try {
            // Try all possible cache locations
            val cacheLocations = listOf(
                File(applicationContext.filesDir, "cache"),
                File(applicationContext.cacheDir, "cache"),
                File(applicationContext.getExternalFilesDir(null), "cache"),
                File(applicationContext.getExternalFilesDir(null), "app_flutter/cache"),
                File(applicationContext.filesDir.parentFile, "app_flutter/cache")
            )

            var jsonData: String? = null
            var foundLocation: String? = null

            for (cacheDir in cacheLocations) {
                val cacheFile = File(cacheDir, CACHE_FILE)
                Log.d(TAG, "Checking cache location: ${cacheFile.absolutePath}")
                
                if (cacheFile.exists()) {
                    jsonData = cacheFile.readText()
                    foundLocation = cacheFile.absolutePath
                    Log.d(TAG, "Found cache file at: $foundLocation")
                    break
                }
            }

            if (jsonData == null) {
                Log.e(TAG, "Cache file not found in any location")
                return
            }

            Log.d(TAG, "Reading cache from: $foundLocation")
            Log.d(TAG, "Cache content: $jsonData")

            val vehicles = JSONArray(jsonData)
            if (vehicles.length() > 0) {
                val vehicle = vehicles.getJSONObject(0)
                val status = vehicle.optJSONObject("status")
                
                var batteryLevel = DEFAULT_BATTERY_LEVEL
                var warningLevel = DEFAULT_WARNING_LEVEL
                
                if (status != null) {
                    val electronics = status.optJSONObject("Electronics")
                    if (electronics != null) {
                        val battery = electronics.optJSONObject("Battery")
                        if (battery != null) {
                            val auxiliary = battery.optJSONObject("Auxiliary")
                            batteryLevel = battery.optInt("Level", DEFAULT_BATTERY_LEVEL)
                            
                            val charging = battery.optJSONObject("Charging")
                            if (charging != null) {
                                warningLevel = charging.optInt("WarningLevel", DEFAULT_WARNING_LEVEL)
                            }
                            
                            Log.d(TAG, "Found battery level: $batteryLevel%, warning level: $warningLevel%")
                        }
                    }
                }

                // Update both widgets
                VehicleWidget().updateBatteryLevel(applicationContext, batteryLevel)
                GraphicalCarBatteryWidget().updateBatteryLevel(applicationContext, batteryLevel, warningLevel)
                Log.d(TAG, "Widgets updated with battery level: $batteryLevel%, warning level: $warningLevel%")
            } else {
                Log.w(TAG, "No vehicles found in cache data")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error updating widget from cache", e)
            e.printStackTrace()
        }
    }

    class DataUpdateReceiver : android.content.BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val serviceIntent = Intent(context, VehicleUpdateService::class.java)
            context.startService(serviceIntent)
        }
    }
}

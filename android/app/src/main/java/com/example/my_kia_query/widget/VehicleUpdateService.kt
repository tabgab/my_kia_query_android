package com.example.my_kia_query.widget

import android.app.Service
import android.content.Intent
import android.os.IBinder
import android.util.Log
import kotlinx.coroutines.*
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform
import org.json.JSONObject
import org.json.JSONArray

class VehicleUpdateService : Service() {
    private val serviceJob = Job()
    private val serviceScope = CoroutineScope(Dispatchers.Main + serviceJob)

    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        serviceScope.launch {
            try {
                if (!Python.isStarted()) {
                    Python.start(AndroidPlatform(this@VehicleUpdateService))
                }
                val py = Python.getInstance()
                val kiaBridge = py.getModule("kia_bridge")

                val result = withContext(Dispatchers.IO) {
                    kiaBridge.callAttr("get_vehicles").toString()
                }

                Log.d("VehicleUpdateService", "Raw result: $result")
                
                // Parse the JSON array and get the first vehicle
                val vehicles = JSONArray(result)
                if (vehicles.length() > 0) {
                    val vehicle = vehicles.getJSONObject(0)
                    val status = vehicle.getJSONObject("status")
                    val battery = status.getJSONObject("battery")
                    val batteryLevel = battery.getInt("level")
                    
                    Log.d("VehicleUpdateService", "Parsed battery level: $batteryLevel")

                    // Update both widgets
                    VehicleWidget().updateBatteryLevel(this@VehicleUpdateService, batteryLevel)
                    GraphicalCarBatteryWidget().updateBatteryLevel(this@VehicleUpdateService, batteryLevel)
                }

            } catch (e: Exception) {
                Log.e("VehicleUpdateService", "Error updating widgets", e)
            } finally {
                stopSelf(startId)
            }
        }

        return START_NOT_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        serviceJob.cancel()
    }
}

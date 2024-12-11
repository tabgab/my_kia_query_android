package com.example.my_kia_query.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.content.SharedPreferences
import android.app.PendingIntent
import android.content.ComponentName
import android.util.Log
import android.view.View
import com.example.my_kia_query.R

class GraphicalCarBatteryWidget : AppWidgetProvider() {
    companion object {
        private const val TAG = "GraphicalCarBatteryWidget"
        private const val PREFS_NAME = "GraphicalCarBatteryWidgetPrefs"
        private const val KEY_BATTERY = "battery_level"
        private const val ACTION_REFRESH = "com.example.my_kia_query.widget.GRAPHICAL_BATTERY_REFRESH"
        private const val WARNING_THRESHOLD = 65 // Show warning when battery level is below this value
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_REFRESH) {
            val serviceIntent = Intent(context, VehicleUpdateService::class.java)
            context.startService(serviceIntent)
        }
    }

    fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        try {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val batteryLevel = prefs.getInt(KEY_BATTERY, 0)
            Log.d(TAG, "Updating widget $appWidgetId with battery level $batteryLevel")

            val views = RemoteViews(context.packageName, R.layout.graphical_car_battery_widget)
            
            // Update battery level text
            views.setTextViewText(R.id.batteryText, "${batteryLevel}%")
            Log.d(TAG, "Set battery text to ${batteryLevel}%")

            // Update battery level indicator
            // Make sure the level indicator is fully visible (alpha 255) but scaled in height
            views.setInt(R.id.batteryLevel, "setImageAlpha", 255)
            
            // Calculate the scale factor for the level indicator
            // The level indicator's height should be scaled based on the battery percentage
            val scaleY = batteryLevel / 100f
            views.setFloat(R.id.batteryLevel, "setScaleY", scaleY)
            Log.d(TAG, "Set battery level scale to $scaleY")

            // Show/hide warning based on battery level
            val warningVisibility = if (batteryLevel < WARNING_THRESHOLD) View.VISIBLE else View.GONE
            views.setInt(R.id.batteryWarning, "setVisibility", warningVisibility)
            Log.d(TAG, "Set warning visibility to ${if (warningVisibility == View.VISIBLE) "visible" else "gone"}")

            // Set up refresh on widget click
            val refreshIntent = Intent(context, GraphicalCarBatteryWidget::class.java).apply {
                action = ACTION_REFRESH
            }
            val refreshPendingIntent = PendingIntent.getBroadcast(
                context,
                0,
                refreshIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.batteryBase, refreshPendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
            Log.d(TAG, "Widget $appWidgetId update completed")
        } catch (e: Exception) {
            Log.e(TAG, "Error updating widget $appWidgetId", e)
        }
    }

    fun updateBatteryLevel(context: Context, batteryLevel: Int) {
        Log.d(TAG, "Received battery level update: $batteryLevel")
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putInt(KEY_BATTERY, batteryLevel).apply()

        val appWidgetManager = AppWidgetManager.getInstance(context)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(ComponentName(context, GraphicalCarBatteryWidget::class.java))
        onUpdate(context, appWidgetManager, appWidgetIds)
    }
}

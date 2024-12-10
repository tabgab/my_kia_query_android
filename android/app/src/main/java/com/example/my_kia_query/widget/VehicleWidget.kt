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
import android.graphics.Color
import com.example.my_kia_query.R

class VehicleWidget : AppWidgetProvider() {
    companion object {
        private const val TAG = "VehicleWidget"
        private const val PREFS_NAME = "VehicleWidgetPrefs"
        private const val KEY_BATTERY = "battery_level"
        private const val ACTION_REFRESH = "com.example.my_kia_query.widget.VOLTAGE_REFRESH"
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

            val views = RemoteViews(context.packageName, R.layout.widget_layout)
            views.setTextViewText(R.id.voltageText, "12V Battery @ ${batteryLevel}%")

            // Apply configuration settings
            val (textSize, bgColor, textColor) = ConfigurationActivity.loadPreferences(context, appWidgetId)
            
            // Set text size
            views.setFloat(R.id.voltageText, "setTextSize", textSize.toFloat())
            
            // Set text color
            views.setTextColor(R.id.voltageText, textColor)
            
            // Set background color with alpha
            val alphaColor = if (bgColor == Color.TRANSPARENT) {
                Color.TRANSPARENT
            } else {
                Color.argb(
                    0xCC,
                    Color.red(bgColor),
                    Color.green(bgColor),
                    Color.blue(bgColor)
                )
            }
            views.setInt(R.id.voltageText, "setBackgroundColor", alphaColor)

            // Set up refresh on widget click
            val refreshIntent = Intent(context, VehicleWidget::class.java).apply {
                action = ACTION_REFRESH
            }
            val refreshPendingIntent = PendingIntent.getBroadcast(
                context,
                0,
                refreshIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.voltageText, refreshPendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        } catch (e: Exception) {
            Log.e(TAG, "Error updating widget $appWidgetId", e)
        }
    }

    fun updateBatteryLevel(context: Context, batteryLevel: Int) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().putInt(KEY_BATTERY, batteryLevel).apply()

        val appWidgetManager = AppWidgetManager.getInstance(context)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(ComponentName(context, VehicleWidget::class.java))
        onUpdate(context, appWidgetManager, appWidgetIds)
    }
}

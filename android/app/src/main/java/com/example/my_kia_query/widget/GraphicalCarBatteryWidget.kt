package com.example.my_kia_query.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.content.SharedPreferences
import android.app.PendingIntent
import android.content.ComponentName
import android.graphics.Color
import android.util.Log
import android.view.View
import android.widget.ImageView
import com.example.my_kia_query.R

class GraphicalCarBatteryWidget : AppWidgetProvider() {
    companion object {
        private const val TAG = "GraphicalCarBatteryWidget"
        private const val PREFS_NAME = "GraphicalCarBatteryWidgetPrefs"
        private const val KEY_BATTERY = "battery_level"
        private const val KEY_WARNING_LEVEL = "warning_level"
        private const val ACTION_REFRESH = "com.example.my_kia_query.widget.GRAPHICAL_BATTERY_REFRESH"
        private const val ACTION_CONFIGURE = "com.example.my_kia_query.widget.GRAPHICAL_BATTERY_CONFIGURE"
        private const val DEFAULT_BATTERY_LEVEL = 84  // Default from actual data
        private const val DEFAULT_WARNING_LEVEL = 65  // Standard warning level
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            ACTION_REFRESH -> {
                val serviceIntent = Intent(context, VehicleUpdateService::class.java)
                context.startService(serviceIntent)
            }
            ACTION_CONFIGURE -> {
                val configIntent = Intent(context, GraphicalWidgetConfigurationActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID))
                }
                context.startActivity(configIntent)
            }
        }
    }

    fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        try {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val batteryLevel = prefs.getInt(KEY_BATTERY, DEFAULT_BATTERY_LEVEL)
            val warningLevel = prefs.getInt(KEY_WARNING_LEVEL, DEFAULT_WARNING_LEVEL)

            val views = RemoteViews(context.packageName, R.layout.graphical_battery_widget_layout)

            // Set battery base image (always visible)
            views.setImageViewResource(R.id.batteryBaseImage, R.drawable.battery_base)

            // Set battery level indicator
            views.setImageViewResource(R.id.batteryLevelImage, R.drawable.battery_level)
            
            // Calculate vertical scale for battery level (0.0 to 1.0)
            val scale = batteryLevel / 100f
            views.setFloat(R.id.batteryLevelImage, "setScaleY", scale)
            
            // Position the level indicator at the bottom
            views.setFloat(R.id.batteryLevelImage, "setPivotY", 1f)

            // Set battery percentage text
            views.setTextViewText(R.id.batteryPercentage, "${batteryLevel}%")
            views.setTextColor(R.id.batteryPercentage, Color.BLACK)
            views.setFloat(R.id.batteryPercentage, "setTextSize", 24f)

            // Show warning only if battery level is below warning level
            if (batteryLevel < warningLevel) {
                views.setViewVisibility(R.id.batteryWarningImage, View.VISIBLE)
                views.setImageViewResource(R.id.batteryWarningImage, R.drawable.battery_warning)
            } else {
                views.setViewVisibility(R.id.batteryWarningImage, View.GONE)
            }

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
            views.setOnClickPendingIntent(R.id.root_layout, refreshPendingIntent)

            // Set up configuration on settings icon click
            val configIntent = Intent(context, GraphicalCarBatteryWidget::class.java).apply {
                action = ACTION_CONFIGURE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            val configPendingIntent = PendingIntent.getBroadcast(
                context,
                appWidgetId,
                configIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.settingsButton, configPendingIntent)

            // Update the widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
            
            Log.d(TAG, "Updated graphical widget $appWidgetId with battery level: $batteryLevel%, warning level: $warningLevel%")
        } catch (e: Exception) {
            Log.e(TAG, "Error updating graphical widget $appWidgetId", e)
        }
    }

    fun updateBatteryLevel(context: Context, batteryLevel: Int, warningLevel: Int) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        prefs.edit().apply {
            putInt(KEY_BATTERY, batteryLevel)
            putInt(KEY_WARNING_LEVEL, warningLevel)
            apply()
        }

        val appWidgetManager = AppWidgetManager.getInstance(context)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(ComponentName(context, GraphicalCarBatteryWidget::class.java))
        onUpdate(context, appWidgetManager, appWidgetIds)
    }
}

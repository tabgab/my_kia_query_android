package com.example.my_kia_query.widget

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.widget.Button
import android.widget.CheckBox
import android.widget.ImageView
import android.widget.TextView
import android.widget.RemoteViews
import android.view.View
import com.example.my_kia_query.R

class GraphicalWidgetConfigurationActivity : Activity() {
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    private lateinit var simulateLowBattery: CheckBox
    private lateinit var batteryLevelImage: ImageView
    private lateinit var batteryWarningImage: ImageView
    private lateinit var batteryPercentage: TextView

    companion object {
        private const val TAG = "GraphicalWidgetConfig"
        private const val PREFS_NAME = "GraphicalCarBatteryWidgetPrefs"
        private const val KEY_SIMULATE_LOW = "simulate_low_battery_"
        private const val DEFAULT_BATTERY_LEVEL = 84
        private const val SIMULATED_LOW_BATTERY = 20
        private const val WARNING_LEVEL = 65

        fun loadSimulateLowBattery(context: Activity, appWidgetId: Int): Boolean {
            val prefs = context.getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
            return prefs.getBoolean(KEY_SIMULATE_LOW + appWidgetId, false)
        }
    }

    public override fun onCreate(savedInstanceState: Bundle?) {
        Log.d(TAG, "onCreate called")
        super.onCreate(savedInstanceState)

        // Set the result to CANCELED. This will cause the widget host to cancel
        // out of the widget placement if they press the back button.
        setResult(RESULT_CANCELED)

        // Set the view layout resource to use.
        setContentView(R.layout.graphical_widget_configure)

        // Find the widget id from the intent.
        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        Log.d(TAG, "Widget ID from intent: $appWidgetId")

        // If they gave us an intent without the widget id, just bail.
        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            Log.e(TAG, "Invalid widget ID, finishing activity")
            finish()
            return
        }

        // Initialize views
        simulateLowBattery = findViewById(R.id.simulateLowBattery)
        batteryLevelImage = findViewById(R.id.batteryLevelImage)
        batteryWarningImage = findViewById(R.id.batteryWarningImage)
        batteryPercentage = findViewById(R.id.batteryPercentage)

        // Set initial preview state
        updatePreview(false)

        // Handle checkbox changes
        simulateLowBattery.setOnCheckedChangeListener { _, isChecked ->
            updatePreview(isChecked)
        }

        findViewById<Button>(R.id.add_button).setOnClickListener {
            Log.d(TAG, "Add button clicked")
            val context = this@GraphicalWidgetConfigurationActivity

            try {
                // Save the simulate low battery preference
                getSharedPreferences(PREFS_NAME, MODE_PRIVATE).edit().apply {
                    putBoolean(KEY_SIMULATE_LOW + appWidgetId, simulateLowBattery.isChecked)
                    apply()
                }
                Log.d(TAG, "Saved simulation preference: ${simulateLowBattery.isChecked}")

                // It is the responsibility of the configuration activity to update the app widget
                val appWidgetManager = AppWidgetManager.getInstance(context)
                
                // Create initial widget view
                val views = RemoteViews(context.packageName, R.layout.graphical_battery_widget_layout)
                
                // Update the widget
                appWidgetManager.updateAppWidget(appWidgetId, views)
                Log.d(TAG, "Initial widget update completed")

                // Create the return intent
                val resultValue = Intent().apply {
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                }
                setResult(RESULT_OK, resultValue)

                // Trigger an immediate update of the widget
                val updateIntent = Intent(context, GraphicalCarBatteryWidget::class.java).apply {
                    action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, intArrayOf(appWidgetId))
                }
                context.sendBroadcast(updateIntent)
                Log.d(TAG, "Sent widget update broadcast")

                finish()
            } catch (e: Exception) {
                Log.e(TAG, "Error configuring widget", e)
                setResult(RESULT_CANCELED)
                finish()
            }
        }

        Log.d(TAG, "Configuration activity setup completed")
    }

    private fun updatePreview(simulateLow: Boolean) {
        val batteryLevel = if (simulateLow) SIMULATED_LOW_BATTERY else DEFAULT_BATTERY_LEVEL
        
        if (batteryLevel < WARNING_LEVEL) {
            batteryLevelImage.visibility = View.GONE
            batteryWarningImage.visibility = View.VISIBLE
        } else {
            batteryLevelImage.visibility = View.VISIBLE
            batteryWarningImage.visibility = View.GONE
        }

        batteryPercentage.text = "${batteryLevel}%"
    }
}

package com.example.my_kia_query.widget

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.CheckBox
import android.widget.RemoteViews
import com.example.my_kia_query.R

class GraphicalWidgetConfigurationActivity : Activity() {
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    private lateinit var simulateLowBattery: CheckBox

    companion object {
        private const val PREFS_NAME = "GraphicalCarBatteryWidgetPrefs"
        private const val KEY_SIMULATE_LOW = "simulate_low_battery_"

        fun loadSimulateLowBattery(context: Activity, appWidgetId: Int): Boolean {
            val prefs = context.getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
            return prefs.getBoolean(KEY_SIMULATE_LOW + appWidgetId, false)
        }
    }

    public override fun onCreate(savedInstanceState: Bundle?) {
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

        // If they gave us an intent without the widget id, just bail.
        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        simulateLowBattery = findViewById(R.id.simulateLowBattery)

        findViewById<Button>(R.id.add_button).setOnClickListener {
            val context = this@GraphicalWidgetConfigurationActivity

            // Save the simulate low battery preference
            getSharedPreferences(PREFS_NAME, MODE_PRIVATE).edit().apply {
                putBoolean(KEY_SIMULATE_LOW + appWidgetId, simulateLowBattery.isChecked)
                apply()
            }

            // It is the responsibility of the configuration activity to update the app widget
            val appWidgetManager = AppWidgetManager.getInstance(context)
            
            // Create initial widget view
            val views = RemoteViews(context.packageName, R.layout.graphical_battery_widget_layout)
            
            // Update the widget
            appWidgetManager.updateAppWidget(appWidgetId, views)

            // Create the return intent
            val resultValue = Intent().apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            setResult(RESULT_OK, resultValue)
            finish()

            // Trigger an immediate update of the widget
            val updateIntent = Intent(context, GraphicalCarBatteryWidget::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, intArrayOf(appWidgetId))
            }
            context.sendBroadcast(updateIntent)
        }
    }
}

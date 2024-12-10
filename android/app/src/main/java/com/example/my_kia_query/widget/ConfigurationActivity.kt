package com.example.my_kia_query.widget

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.widget.*
import com.example.my_kia_query.R
import android.content.Context
import android.graphics.drawable.GradientDrawable
import android.view.View

class ConfigurationActivity : Activity() {
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    private lateinit var textSizeSeekBar: SeekBar
    private lateinit var backgroundColorGroup: RadioGroup
    private lateinit var textColorGroup: RadioGroup
    private lateinit var previewText: TextView
    private lateinit var addButton: Button

    companion object {
        private const val PREFS_NAME = "WidgetConfigPrefs"
        private const val PREF_TEXT_SIZE = "text_size_"
        private const val PREF_BG_COLOR = "bg_color_"
        private const val PREF_TEXT_COLOR = "text_color_"

        fun loadPreferences(context: Context, appWidgetId: Int): Triple<Int, Int, Int> {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val textSize = prefs.getInt(PREF_TEXT_SIZE + appWidgetId, 16)
            val bgColor = prefs.getInt(PREF_BG_COLOR + appWidgetId, Color.BLACK)
            val textColor = prefs.getInt(PREF_TEXT_COLOR + appWidgetId, Color.WHITE)
            return Triple(textSize, bgColor, textColor)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setResult(RESULT_CANCELED)
        setContentView(R.layout.widget_configure)

        appWidgetId = intent?.extras?.getInt(
            AppWidgetManager.EXTRA_APPWIDGET_ID,
            AppWidgetManager.INVALID_APPWIDGET_ID
        ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }

        setupViews()
        setupPreviewUpdates()
        setupAddButton()
    }

    private fun setupViews() {
        textSizeSeekBar = findViewById(R.id.textSizeSeekBar)
        backgroundColorGroup = findViewById(R.id.backgroundColorGroup)
        textColorGroup = findViewById(R.id.textColorGroup)
        previewText = findViewById(R.id.previewText)
        addButton = findViewById(R.id.addButton)

        // Set initial preview
        updatePreview()
    }

    private fun setupPreviewUpdates() {
        textSizeSeekBar.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener {
            override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
                updatePreview()
            }
            override fun onStartTrackingTouch(seekBar: SeekBar?) {}
            override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        })

        backgroundColorGroup.setOnCheckedChangeListener { _, _ -> updatePreview() }
        textColorGroup.setOnCheckedChangeListener { _, _ -> updatePreview() }
    }

    private fun updatePreview() {
        val textSize = textSizeSeekBar.progress + 8 // Min text size is 8sp
        val backgroundColor = getSelectedBackgroundColor()
        val textColor = getSelectedTextColor()

        previewText.textSize = textSize.toFloat()
        previewText.setTextColor(textColor)

        val background = GradientDrawable()
        background.setColor(backgroundColor)
        background.cornerRadius = resources.displayMetrics.density * 8
        previewText.background = background
    }

    private fun getSelectedBackgroundColor(): Int {
        return when (backgroundColorGroup.checkedRadioButtonId) {
            R.id.bgBlack -> Color.BLACK
            R.id.bgDarkGray -> Color.DKGRAY
            R.id.bgTransparent -> Color.TRANSPARENT
            else -> Color.BLACK
        }
    }

    private fun getSelectedTextColor(): Int {
        return when (textColorGroup.checkedRadioButtonId) {
            R.id.textWhite -> Color.WHITE
            R.id.textLightGray -> Color.LTGRAY
            R.id.textBlack -> Color.BLACK
            else -> Color.WHITE
        }
    }

    private fun setupAddButton() {
        addButton.setOnClickListener {
            val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().apply {
                putInt(PREF_TEXT_SIZE + appWidgetId, textSizeSeekBar.progress + 8)
                putInt(PREF_BG_COLOR + appWidgetId, getSelectedBackgroundColor())
                putInt(PREF_TEXT_COLOR + appWidgetId, getSelectedTextColor())
                apply()
            }

            val appWidgetManager = AppWidgetManager.getInstance(this)
            VehicleWidget().updateAppWidget(this, appWidgetManager, appWidgetId)

            val resultValue = Intent()
            resultValue.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            setResult(RESULT_OK, resultValue)
            finish()
        }
    }
}

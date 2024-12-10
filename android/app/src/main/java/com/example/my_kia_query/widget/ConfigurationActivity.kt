package com.example.my_kia_query.widget

import android.app.Activity
import android.app.Dialog
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.widget.*
import com.example.my_kia_query.R
import android.content.Context
import android.graphics.drawable.GradientDrawable
import android.view.Window
import com.skydoves.colorpickerview.ColorPickerView
import com.skydoves.colorpickerview.listeners.ColorListener
import com.skydoves.colorpickerview.sliders.BrightnessSlideBar
import com.skydoves.colorpickerview.AlphaTileView

class ConfigurationActivity : Activity() {
    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID
    private lateinit var textSizeSeekBar: SeekBar
    private lateinit var previewText: TextView
    private lateinit var addButton: Button
    private lateinit var changeTextColorButton: Button
    private lateinit var changeBackgroundColorButton: Button
    private var currentTextColor = Color.WHITE
    private var currentBackgroundColor = Color.BLACK

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
        loadSavedColors()
    }

    private fun setupViews() {
        textSizeSeekBar = findViewById(R.id.textSizeSeekBar)
        previewText = findViewById(R.id.previewText)
        addButton = findViewById(R.id.addButton)
        changeTextColorButton = findViewById(R.id.changeTextColorButton)
        changeBackgroundColorButton = findViewById(R.id.changeBackgroundColorButton)

        changeTextColorButton.setOnClickListener {
            showColorPickerDialog(true)
        }

        changeBackgroundColorButton.setOnClickListener {
            showColorPickerDialog(false)
        }

        // Set initial preview
        updatePreview()
    }

    private fun loadSavedColors() {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        currentTextColor = prefs.getInt(PREF_TEXT_COLOR + appWidgetId, Color.WHITE)
        currentBackgroundColor = prefs.getInt(PREF_BG_COLOR + appWidgetId, Color.BLACK)
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
    }

    private fun showColorPickerDialog(isTextColor: Boolean) {
        val dialog = Dialog(this)
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE)
        dialog.setContentView(R.layout.dialog_color_picker)
        dialog.window?.setLayout(
            (resources.displayMetrics.widthPixels * 0.9).toInt(),
            (resources.displayMetrics.heightPixels * 0.9).toInt()
        )

        val colorPicker = dialog.findViewById<ColorPickerView>(R.id.colorPicker)
        val brightnessSlideBar = dialog.findViewById<BrightnessSlideBar>(R.id.brightnessSlide)
        val alphaTileView = dialog.findViewById<AlphaTileView>(R.id.alphaTileView)
        val cancelButton = dialog.findViewById<Button>(R.id.cancelButton)
        val applyButton = dialog.findViewById<Button>(R.id.applyButton)

        // Attach brightness slider
        colorPicker.attachBrightnessSlider(brightnessSlideBar)

        // Set initial color
        val initialColor = if (isTextColor) currentTextColor else currentBackgroundColor
        colorPicker.setInitialColor(initialColor)
        alphaTileView.setPaintColor(initialColor)

        var selectedColor = initialColor

        colorPicker.setColorListener(object : ColorListener {
            override fun onColorSelected(color: Int, fromUser: Boolean) {
                selectedColor = color
                alphaTileView.setPaintColor(color)
            }
        })

        cancelButton.setOnClickListener {
            dialog.dismiss()
        }

        applyButton.setOnClickListener {
            if (isTextColor) {
                currentTextColor = selectedColor
            } else {
                currentBackgroundColor = selectedColor
            }
            updatePreview()
            dialog.dismiss()
        }

        dialog.show()
    }

    private fun updatePreview() {
        val textSize = textSizeSeekBar.progress + 8 // Min text size is 8sp

        previewText.textSize = textSize.toFloat()
        previewText.setTextColor(currentTextColor)

        val background = GradientDrawable()
        background.setColor(currentBackgroundColor)
        background.cornerRadius = resources.displayMetrics.density * 8
        previewText.background = background

        // Update button backgrounds to show current colors
        val textColorPreview = GradientDrawable()
        textColorPreview.setColor(currentTextColor)
        textColorPreview.cornerRadius = resources.displayMetrics.density * 4
        changeTextColorButton.background = textColorPreview

        val bgColorPreview = GradientDrawable()
        bgColorPreview.setColor(currentBackgroundColor)
        bgColorPreview.cornerRadius = resources.displayMetrics.density * 4
        changeBackgroundColorButton.background = bgColorPreview

        // Ensure button text is visible
        changeTextColorButton.setTextColor(getContrastColor(currentTextColor))
        changeBackgroundColorButton.setTextColor(getContrastColor(currentBackgroundColor))
    }

    private fun getContrastColor(color: Int): Int {
        // Calculate relative luminance
        val red = Color.red(color) / 255.0
        val green = Color.green(color) / 255.0
        val blue = Color.blue(color) / 255.0
        val luminance = 0.299 * red + 0.587 * green + 0.114 * blue

        return if (luminance > 0.5) Color.BLACK else Color.WHITE
    }

    private fun setupAddButton() {
        addButton.setOnClickListener {
            val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            prefs.edit().apply {
                putInt(PREF_TEXT_SIZE + appWidgetId, textSizeSeekBar.progress + 8)
                putInt(PREF_BG_COLOR + appWidgetId, currentBackgroundColor)
                putInt(PREF_TEXT_COLOR + appWidgetId, currentTextColor)
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

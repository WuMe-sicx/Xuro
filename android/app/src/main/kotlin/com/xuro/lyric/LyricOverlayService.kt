package com.xuro.lyric

import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Paint
import android.graphics.PixelFormat
import android.os.Binder
import android.os.IBinder
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.TextView
import com.xuro.R

class LyricOverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var lyricView: View? = null
    private var strokeView: TextView? = null
    private var fillView: TextView? = null
    private var params: WindowManager.LayoutParams? = null
    private var initialY = 0
    private var initialTouchY = 0f
    private var editable = false
    private val binder = LocalBinder()

    companion object {
        private const val PREFS_NAME = "LyricOverlayPrefs"
        private const val KEY_Y = "window_y"
        private const val KEY_SHOWING = "is_showing"

        private const val BASE_FLAGS =
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN

        // Android 12+ 安全策略：TYPE_APPLICATION_OVERLAY 的 alpha 超过
        // getMaximumObscuringOpacityForTouch()（默认 0.8）时，下层 app
        // 不会收到被遮挡的触摸事件，FLAG_NOT_TOUCHABLE 形同虚设。
        // 这里固定使用 0.8 兼容所有版本；编辑态恢复 1.0 让歌词不透明便于拖动。
        private const val PASS_THROUGH_ALPHA = 0.8f
        private const val EDIT_MODE_ALPHA = 1.0f
    }

    inner class LocalBinder : Binder() {
        val service: LyricOverlayService
            get() = this@LyricOverlayService
    }

    override fun onBind(intent: Intent?): IBinder = binder

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
    }

    fun showLyric(text: String) {
        if (lyricView == null) {
            createLyricView()
        }
        strokeView?.text = text
        fillView?.text = text
        getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(KEY_SHOWING, true)
            .apply()
    }

    fun setEditable(editable: Boolean) {
        this.editable = editable
        val view = lyricView ?: return
        val p = params ?: return
        p.flags = computeFlags(editable)
        p.alpha = if (editable) EDIT_MODE_ALPHA else PASS_THROUGH_ALPHA
        windowManager?.updateViewLayout(view, p)
    }

    private fun computeFlags(editable: Boolean): Int =
        if (editable) BASE_FLAGS
        else BASE_FLAGS or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE

    private fun createLyricView() {
        val root = LayoutInflater.from(this)
            .inflate(R.layout.lyric_overlay, null) as FrameLayout
        lyricView = root
        strokeView = root.findViewById(R.id.lyric_stroke)
        fillView = root.findViewById(R.id.lyric_fill)

        strokeView?.paint?.apply {
            style = Paint.Style.STROKE
            strokeWidth = 6f
            strokeJoin = Paint.Join.ROUND
        }

        val displayMetrics = resources.displayMetrics
        val screenHeight = displayMetrics.heightPixels
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val savedY = prefs.getInt(KEY_Y, (screenHeight * 2 / 3))

        params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            computeFlags(editable),
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
            x = 0
            y = savedY
            alpha = if (editable) EDIT_MODE_ALPHA else PASS_THROUGH_ALPHA
            windowAnimations = 0
        }

        root.setOnTouchListener { _, event ->
            if (!editable) return@setOnTouchListener false
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialY = params?.y ?: 0
                    initialTouchY = event.rawY
                }
                MotionEvent.ACTION_MOVE -> {
                    val dy = (event.rawY - initialTouchY).toInt()
                    params?.y = initialY + dy
                    params?.let { windowManager?.updateViewLayout(lyricView, it) }
                }
                MotionEvent.ACTION_UP -> {
                    params?.let { p ->
                        getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                            .edit()
                            .putInt(KEY_Y, p.y)
                            .apply()
                    }
                }
            }
            true
        }

        windowManager?.addView(lyricView, params)
    }

    fun hideLyric() {
        try {
            if (lyricView != null) {
                windowManager?.removeView(lyricView)
                lyricView = null
                strokeView = null
                fillView = null
                editable = false
                getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                    .edit()
                    .putBoolean(KEY_SHOWING, false)
                    .apply()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        hideLyric()
    }

    fun isShowing(): Boolean {
        if (lyricView == null) {
            return getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .getBoolean(KEY_SHOWING, false)
        }
        return true
    }
}

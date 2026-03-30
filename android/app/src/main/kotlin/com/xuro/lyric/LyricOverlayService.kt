package com.xuro.lyric

import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Binder
import android.os.IBinder
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import com.xuro.R
import android.view.Gravity

class LyricOverlayService : Service() {
    private var windowManager: WindowManager? = null
    private var lyricView: View? = null
    private var params: WindowManager.LayoutParams? = null
    private var initialX = 0
    private var initialY = 0
    private var initialTouchX = 0f
    private var initialTouchY = 0f
    private val binder = LocalBinder()

    companion object {
        private const val PREFS_NAME = "LyricOverlayPrefs"
        private const val KEY_X = "window_x"
        private const val KEY_Y = "window_y"
        private const val KEY_SHOWING = "is_showing"
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
        (lyricView as? TextView)?.text = text
        getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putBoolean(KEY_SHOWING, true)
            .apply()
    }

    private fun createLyricView() {
        lyricView = LayoutInflater.from(this).inflate(R.layout.lyric_overlay, null)

        // 获取屏幕高度
        val displayMetrics = resources.displayMetrics
        val screenHeight = displayMetrics.heightPixels

        // 读取保存的位置，默认位置设在屏幕2/3处
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val savedX = prefs.getInt(KEY_X, 50)  // 距离右边50dp
        val savedY = prefs.getInt(KEY_Y, (screenHeight * 2 / 3))  // 屏幕高度的2/3处

        params = WindowManager.LayoutParams(
            360.dpToPx(),
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.END
            x = savedX
            y = savedY
            windowAnimations = 0
        }

        lyricView?.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = params?.x ?: 0
                    initialY = params?.y ?: 0
                    initialTouchX = event.rawX
                    initialTouchY = event.rawY
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = (event.rawX - initialTouchX).toInt()
                    val dy = (event.rawY - initialTouchY).toInt()

                    params?.x = initialX - dx
                    params?.y = initialY + dy
                    params?.let { windowManager?.updateViewLayout(lyricView, it) }
                }
                MotionEvent.ACTION_UP -> {
                    // 保存新位置
                    params?.let { params ->
                        getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                            .edit()
                            .putInt(KEY_X, params.x)
                            .putInt(KEY_Y, params.y)
                            .apply()
                    }
                }
            }
            true
        }

        windowManager?.addView(lyricView, params)
    }

    private fun Int.dpToPx(): Int {
        val scale = resources.displayMetrics.density
        return (this * scale + 0.5f).toInt()
    }

    fun hideLyric() {
        try {
            if (lyricView != null) {
                windowManager?.removeView(lyricView)
                lyricView = null
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
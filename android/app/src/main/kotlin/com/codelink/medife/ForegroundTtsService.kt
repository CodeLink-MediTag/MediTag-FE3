package com.codelink.medife

import android.app.Service
import android.content.Intent
import android.os.Bundle
import android.os.IBinder
import android.speech.tts.TextToSpeech
import android.util.Log

class ForegroundTtsService : Service(), TextToSpeech.OnInitListener {
    companion object {
        // 서비스에서 사용할 Intent extra 키 (앱의 패키지 네임을 접두사로 넣어 충돌 방지)
        const val EXTRA_TEXT = "com.codelink.medife.EXTRA_TEXT"
    }

    private lateinit var tts: TextToSpeech

    override fun onCreate() {
        super.onCreate()
        tts = TextToSpeech(this, this)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // 여기에선 위에서 정의한 EXTRA_TEXT로 읽음
        val textToSpeak: String = intent?.getStringExtra(EXTRA_TEXT) ?: ""
        if (textToSpeak.isNotEmpty()) {
            tts.speak(textToSpeak, TextToSpeech.QUEUE_ADD, null, "TTS_ID")
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        tts.stop()
        tts.shutdown()
        super.onDestroy()
    }

    override fun onInit(status: Int) { /* 초기화 처리 */ }
}

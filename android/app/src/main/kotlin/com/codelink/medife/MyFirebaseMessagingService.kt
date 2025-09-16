package com.codelink.medife

import android.content.Intent
import android.os.Build
import android.util.Log
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MyFirebaseMessagingService: FirebaseMessagingService() {

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        Log.d("MyFMS", "onMessageReceived: $remoteMessage")

        // 우선 data payload를 우선: server에서 data-only로 보낼 것을 권장
        val data = remoteMessage.data
        val text = when {
            data != null && data.containsKey("tts") -> data["tts"]
            remoteMessage.notification != null -> remoteMessage.notification?.body
            else -> null
        }

        if (!text.isNullOrEmpty()) {
            val intent = Intent(this, ForegroundTtsService::class.java)
            intent.putExtra(ForegroundTtsService.EXTRA_TEXT, text)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
        }
    }

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.d("MyFMS", "onNewToken: $token")
        // 필요시 서버로 토큰 전송
    }
}

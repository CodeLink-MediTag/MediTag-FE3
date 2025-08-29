package com.codelink.medife

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.nfc.NdefMessage
import android.nfc.NdefRecord
import android.nfc.NfcAdapter

class MainActivity: FlutterActivity() {
    private val CHANNEL = "nfc_channel"
    private var initialNfcData: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getInitialNfcData") {
                result.success(initialNfcData)
                initialNfcData = null   // 한 번 전달 후 초기화
            } else {
                result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent == null) return

        if (NfcAdapter.ACTION_NDEF_DISCOVERED == intent.action) {
            val rawMsgs = intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES)
            if (rawMsgs != null && rawMsgs.isNotEmpty()) {
                val msgs = rawMsgs.map { it as NdefMessage }
                if (msgs.isNotEmpty() && msgs[0].records.isNotEmpty()) {
                    val record = msgs[0].records[0]
                    val payload = record.payload
                    if (payload.isNotEmpty()) {
                        val langCodeLen = payload[0].toInt() and 0x3F
                        initialNfcData = String(payload.copyOfRange(1 + langCodeLen, payload.size))
                    }
                }
            }
        }
    }



}

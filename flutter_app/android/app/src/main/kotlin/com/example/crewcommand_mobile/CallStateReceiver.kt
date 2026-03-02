package com.example.crewcommand_mobile

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.TelephonyManager
import java.time.Instant

class CallStateReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != TelephonyManager.ACTION_PHONE_STATE_CHANGED) {
            return
        }

        val state = intent.getStringExtra(TelephonyManager.EXTRA_STATE) ?: return
        val incomingNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER)

        when (state) {
            TelephonyManager.EXTRA_STATE_RINGING -> {
                lastKnownNumber = incomingNumber
            }

            TelephonyManager.EXTRA_STATE_OFFHOOK -> {
                callStartedAtMs = System.currentTimeMillis()
                if (!incomingNumber.isNullOrBlank()) {
                    lastKnownNumber = incomingNumber
                }
            }

            TelephonyManager.EXTRA_STATE_IDLE -> {
                val endedFromCall = previousState == TelephonyManager.EXTRA_STATE_OFFHOOK ||
                    previousState == TelephonyManager.EXTRA_STATE_RINGING

                if (endedFromCall) {
                    val durationSec = if (callStartedAtMs > 0L) {
                        ((System.currentTimeMillis() - callStartedAtMs) / 1000L).toInt().coerceAtLeast(0)
                    } else {
                        0
                    }

                    val number = when {
                        !incomingNumber.isNullOrBlank() -> incomingNumber
                        !lastKnownNumber.isNullOrBlank() -> lastKnownNumber
                        else -> ""
                    }

                    CallEventStore.enqueueCallEvent(
                        context = context,
                        phoneNumber = number,
                        durationSec = durationSec,
                        timestampIso = Instant.now().toString(),
                    )
                }

                callStartedAtMs = 0L
                lastKnownNumber = null
            }
        }

        previousState = state
    }

    companion object {
        private var previousState: String? = null
        private var callStartedAtMs: Long = 0L
        private var lastKnownNumber: String? = null
    }
}

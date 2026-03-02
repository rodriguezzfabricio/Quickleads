package com.example.crewcommand_mobile

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.crewcommand/call_detector"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "consumePendingCallEvents" -> {
                        val events = CallEventStore.consumePendingCallEvents(applicationContext)
                        result.success(events)
                    }

                    else -> result.notImplemented()
                }
            }
    }
}

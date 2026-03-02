package com.example.crewcommand_mobile

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

object CallEventStore {
    private const val PREFS_NAME = "call_detector_store"
    private const val KEY_PENDING_EVENTS = "pending_events"

    fun enqueueCallEvent(
        context: Context,
        phoneNumber: String?,
        durationSec: Int,
        timestampIso: String,
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val existing = prefs.getString(KEY_PENDING_EVENTS, "[]") ?: "[]"
        val array = JSONArray(existing)

        val payload = JSONObject().apply {
            put("phoneNumber", phoneNumber ?: "")
            put("durationSec", durationSec)
            put("timestampIso", timestampIso)
        }
        array.put(payload)

        prefs.edit().putString(KEY_PENDING_EVENTS, array.toString()).apply()
    }

    fun consumePendingCallEvents(context: Context): List<Map<String, Any>> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val existing = prefs.getString(KEY_PENDING_EVENTS, "[]") ?: "[]"
        val array = JSONArray(existing)
        val output = mutableListOf<Map<String, Any>>()

        for (i in 0 until array.length()) {
            val obj = array.optJSONObject(i) ?: continue
            val map = mutableMapOf<String, Any>()
            map["phoneNumber"] = obj.optString("phoneNumber", "")
            map["durationSec"] = obj.optInt("durationSec", 0)
            map["timestampIso"] = obj.optString("timestampIso", "")
            output.add(map)
        }

        prefs.edit().putString(KEY_PENDING_EVENTS, "[]").apply()
        return output
    }
}

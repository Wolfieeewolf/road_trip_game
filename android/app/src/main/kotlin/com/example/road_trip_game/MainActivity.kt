package com.example.road_trip_game

import android.util.Log
import com.example.road_trip_game.car.ScoreboardEntryModel
import com.example.road_trip_game.car.ScoreboardRepository
import com.example.road_trip_game.car.ScoreboardSnapshotModel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        Log.i(TAG, "Configuring Flutter engine - setting up Android Auto MethodChannel")
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            Log.d(TAG, "MethodChannel received call: ${call.method}")

            if (call.method == "updateScoreboard") {
                try {
                    val args = call.arguments as? Map<*, *>
                    if (args == null) {
                        Log.e(TAG, "updateScoreboard called with null arguments")
                        result.error("INVALID_ARGS", "Arguments cannot be null", null)
                        return@setMethodCallHandler
                    }

                    val sessionCode = args["sessionCode"] as? String
                    val updatedAt = (args["updatedAt"] as? Number)?.toLong() ?: 0L
                    val rawEntries = args["entries"] as? List<*>

                    Log.i(
                        TAG,
                        "updateScoreboard: session=$sessionCode, " +
                            "updatedAt=$updatedAt, entriesCount=${rawEntries?.size ?: 0}",
                    )

                    val entries = rawEntries
                        ?.mapNotNull { entry ->
                            (entry as? Map<*, *>)?.let { map ->
                                val name = map["name"] as? String
                                if (name == null) {
                                    Log.w(TAG, "Entry missing name field: $map")
                                    return@mapNotNull null
                                }
                                val score = (map["score"] as? Number)?.toInt() ?: 0
                                val isHost = map["isHost"] as? Boolean ?: false
                                ScoreboardEntryModel(
                                    name = name,
                                    score = score,
                                    isHost = isHost,
                                )
                            }
                        }
                        ?: emptyList()

                    val snapshot = ScoreboardSnapshotModel(
                        sessionCode = sessionCode,
                        updatedAt = updatedAt,
                        entries = entries,
                    )

                    Log.i(TAG, "Updating ScoreboardRepository with $snapshot")
                    ScoreboardRepository.update(snapshot)

                    result.success(null)
                    Log.d(TAG, "updateScoreboard completed successfully")
                } catch (e: Exception) {
                    Log.e(TAG, "Error in updateScoreboard", e)
                    result.error(
                        "UPDATE_ERROR",
                        "Failed to update scoreboard: ${e.message}",
                        e.stackTraceToString(),
                    )
                }
            } else {
                Log.w(TAG, "Unknown method called: ${call.method}")
                result.notImplemented()
            }
        }
        Log.i(TAG, "MethodChannel setup complete")
    }

    private companion object {
        const val TAG = "MainActivity"
        const val CHANNEL_NAME = "road_trip_car/android_auto"
    }
}

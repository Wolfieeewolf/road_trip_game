package com.example.road_trip_game.car

import android.util.Log
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

object ScoreboardRepository {
    private val _snapshot =
        MutableStateFlow(ScoreboardSnapshotModel.EMPTY)

    val snapshot: StateFlow<ScoreboardSnapshotModel> = _snapshot.asStateFlow()

    fun update(newSnapshot: ScoreboardSnapshotModel) {
        Log.i("ScoreboardRepository", "update called with $newSnapshot")
        _snapshot.value = newSnapshot
    }
}

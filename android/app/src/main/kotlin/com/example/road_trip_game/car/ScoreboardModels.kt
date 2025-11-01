package com.example.road_trip_game.car

data class ScoreboardEntryModel(
    val name: String,
    val score: Int,
    val isHost: Boolean,
)

data class ScoreboardSnapshotModel(
    val sessionCode: String?,
    val updatedAt: Long,
    val entries: List<ScoreboardEntryModel>,
) {
    fun hasSession(): Boolean = !sessionCode.isNullOrEmpty()

    companion object {
        val EMPTY = ScoreboardSnapshotModel(
            sessionCode = null,
            updatedAt = 0L,
            entries = emptyList(),
        )
    }
}

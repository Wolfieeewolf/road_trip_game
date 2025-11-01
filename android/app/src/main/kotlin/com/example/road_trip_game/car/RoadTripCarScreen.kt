package com.example.road_trip_game.car

import android.util.Log
import androidx.car.app.CarContext
import androidx.car.app.Screen
import androidx.car.app.model.Action
import androidx.car.app.model.ItemList
import androidx.car.app.model.ListTemplate
import androidx.car.app.model.Row
import androidx.car.app.model.Template
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class RoadTripCarScreen(carContext: CarContext) : Screen(carContext) {
    private var snapshot = ScoreboardRepository.snapshot.value

    init {
        Log.i("RoadTripCarScreen", "Screen created with initial snapshot=$snapshot")
        lifecycleScope.launch {
            Log.i("RoadTripCarScreen", "Starting snapshot collector")
            ScoreboardRepository.snapshot.collectLatest { latest ->
                Log.i("RoadTripCarScreen", "Received snapshot update: $latest on thread=${Thread.currentThread().name}")
                snapshot = latest
                Log.i("RoadTripCarScreen", "Triggering invalidate()")
                invalidate()
                Log.i("RoadTripCarScreen", "invalidate() completed")
            }
        }
    }

    override fun onGetTemplate(): Template {
        Log.i(
            "RoadTripCarScreen",
            "onGetTemplate called, hasSession=${snapshot.hasSession()} entries=${snapshot.entries.size}",
        )
        val listBuilder = ItemList.Builder()

        if (!snapshot.hasSession()) {
            Log.i("RoadTripCarScreen", "Building waiting template")
            listBuilder.addItem(
                Row.Builder()
                    .setTitle("Waiting for game")
                    .addText("Start a game from your phone.")
                    .build(),
            )
        } else {
            Log.i("RoadTripCarScreen", "Building scoreboard template")
            listBuilder.addItem(
                Row.Builder()
                    .setTitle("Session code")
                    .addText(snapshot.sessionCode ?: "-")
                    .build(),
            )
            snapshot.entries.forEach { entry ->
                Log.i("RoadTripCarScreen", "Adding row for ${entry.name} score=${entry.score}")
                val rowBuilder = Row.Builder()
                    .setTitle(entry.name)
                    .addText("Score: ${entry.score}")
                if (entry.isHost) {
                    Log.i("RoadTripCarScreen", "${entry.name} is host")
                    rowBuilder.addText("Host")
                }
                listBuilder.addItem(rowBuilder.build())
            }
        }

        return ListTemplate.Builder()
            .setTitle("Road Trip Scoreboard")
            .setHeaderAction(Action.APP_ICON)
            .setSingleList(listBuilder.build())
            .build()
    }
}

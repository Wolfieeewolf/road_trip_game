package com.example.road_trip_game.car

import android.content.Intent
import android.content.pm.ApplicationInfo
import android.util.Log
import androidx.car.app.CarAppService
import androidx.car.app.Screen
import androidx.car.app.Session
import androidx.car.app.validation.HostValidator

class RoadTripCarAppService : CarAppService() {
    override fun onCreateSession(): Session {
        Log.i(TAG, "onCreateSession invoked")
        return RoadTripCarSession()
    }

    override fun createHostValidator(): HostValidator {
        Log.i(TAG, "createHostValidator invoked")
        return if ((applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0) {
            Log.i(TAG, "Debug build detected; allowing all hosts")
            HostValidator.ALLOW_ALL_HOSTS_VALIDATOR
        } else {
            Log.i(TAG, "Release build detected; using hosts allowlist")
            HostValidator.Builder(applicationContext)
                .addAllowedHosts(androidx.car.app.R.array.hosts_allowlist_sample)
                .build()
        }
    }

    private companion object {
        const val TAG = "RoadTripCarAppService"
    }
}

private class RoadTripCarSession : Session() {
    override fun onCreateScreen(intent: Intent): Screen {
        Log.i(TAG, "RoadTripCarSession.onCreateScreen intent=$intent")
        return RoadTripCarScreen(carContext)
    }

    private companion object {
        const val TAG = "RoadTripCarAppService"
    }
}

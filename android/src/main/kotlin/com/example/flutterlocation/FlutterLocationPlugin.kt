package com.example.flutterlocation

import android.Manifest
import com.google.android.gms.location.FusedLocationProviderClient
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.PluginRegistry.Registrar
import android.app.Activity
import android.content.pm.PackageManager
import android.location.Location
import android.os.Looper
import android.support.v4.app.ActivityCompat
import com.google.android.gms.location.LocationCallback
import io.flutter.plugin.common.PluginRegistry
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationRequest


class Channel {
    companion object {
        const val LOCATION = "javier-elizaga.location"
        const val LOCATION_EVENT = "javier-elizaga.location-event"
    }
}

class Method {
    companion object {
        const val PERMISSION = "permission"
        const val LOCATION = "location"
        const val REQUEST_PERMISSIONS = "requestPermissions"
    }
}

class Permission {
    companion object {
        const val NOT_DETERMINED = "NOT_DETERMINED"
        const val DENIED = "DENIED"
        const val AUTHORIZED = "AUTHORIZED"
    }
}

data class Error(val code: String, val desc: String)



class FlutterLocationPlugin(val activity: Activity) : MethodCallHandler, EventChannel.StreamHandler, PluginRegistry.RequestPermissionsResultListener {

    private val permissionNotDeterminedErr = Error("PERMISSION_NOT_DETERMINED", "Location must be determined, call request permission before calling location")
    private val permissionDeniedErr = Error("PERMISSION_DENIED", "You are not allow to access location")
    private val requestCode = 22


    private var fusedLocationClient = FusedLocationProviderClient(activity)
    private val locationRequest = LocationRequest()

    private var permission: String = Permission.NOT_DETERMINED
    private var permissionRequested = false

    // private var result: Result? = null
    private var eventSink: EventChannel.EventSink? = null


    private var locationCallback: LocationCallback = object : LocationCallback() {
        override fun onLocationResult(locationResult: LocationResult) {
            eventSink?.success(locationToMap(locationResult.lastLocation))
        }

    }

    init {
        locationRequest.interval = 10000
        locationRequest.fastestInterval = 10000 / 2
        locationRequest.priority = LocationRequest.PRIORITY_HIGH_ACCURACY
    }

    /**
     * Request permission callback
     */
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>?, grantResults: IntArray?): Boolean {
        var result = false
        if (requestCode == requestCode && permissions?.size == 1 && grantResults?.size == 1) {
            if (permissions[0] == Manifest.permission.ACCESS_FINE_LOCATION) {
                permission = when (grantResults?.get(0)) {
                    PackageManager.PERMISSION_GRANTED -> Permission.AUTHORIZED
                    else -> Permission.DENIED
                }
                permissionRequested = false
                result = true
            }
        }
        return result
    }

    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), Channel.LOCATION)
            val event = EventChannel(registrar.messenger(), Channel.LOCATION_EVENT)
            val instance = FlutterLocationPlugin(registrar.activity())
            channel.setMethodCallHandler(instance)
            event.setStreamHandler(instance)
            registrar.addRequestPermissionsResultListener(instance)
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            Method.PERMISSION -> permission(result)
            Method.LOCATION -> location(result)
            Method.REQUEST_PERMISSIONS -> requestPermissions(result)
            else -> {
                result.notImplemented()
            }
        }
    }

    // Stream Handler
    override fun onListen(argument: Any?, eventSink: EventChannel.EventSink?) {
        if (permission == Permission.NOT_DETERMINED) {
            return
        }
        this.eventSink = eventSink
        fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, Looper.myLooper())
    }

    override fun onCancel(argument: Any?) {
        fusedLocationClient.removeLocationUpdates(locationCallback)
        this.eventSink = null
    }

    private fun permission(result: Result) {
        val location = ActivityCompat.checkSelfPermission(activity,  Manifest.permission.ACCESS_FINE_LOCATION)
        permission = when {
            location == PackageManager.PERMISSION_GRANTED -> Permission.AUTHORIZED
            permissionRequested -> Permission.NOT_DETERMINED
            else -> Permission.DENIED
        }
        result.success(permission)
    }

    private fun requestPermissions(result: Result) {
        var requested = false
        val location = ActivityCompat.checkSelfPermission(activity,  Manifest.permission.ACCESS_FINE_LOCATION)
        if (location == PackageManager.PERMISSION_DENIED) {
            if (!permissionRequested) {
                permissionRequested = true
                permission = Permission.NOT_DETERMINED
                ActivityCompat.requestPermissions(activity, arrayOf(Manifest.permission.ACCESS_FINE_LOCATION), requestCode)
                requested = true
            }
        }
        result.success(requested)
    }


    private fun location(result: Result) {
        when (permission) {
            Permission.NOT_DETERMINED -> result.error(permissionNotDeterminedErr.code, permissionNotDeterminedErr.desc, null)
            Permission.DENIED -> result.error(permissionDeniedErr.code, permissionDeniedErr.desc, null)
            Permission.AUTHORIZED -> fusedLocationClient.lastLocation.addOnSuccessListener { location ->
                result.success(locationToMap(location))
            }
        }

    }

    private fun locationToMap(location: Location?) = hashMapOf(
            "latitude" to location?.latitude,
            "longitude" to location?.longitude,
            "accuracy" to location?.accuracy?.toDouble(),
            "altitude" to location?.altitude,
            "speed" to location?.speed?.toDouble()
    )


}

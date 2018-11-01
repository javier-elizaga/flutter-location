import Flutter
import UIKit
import CoreLocation

enum Channel {
    static let location = "javier-elizaga.location"
    static let locationEvent = "javier-elizaga.location-event"
}

enum Method {
    static let permission = "permission"
    static let location = "location"
    static let request_permissions = "requestPermissions"
}

enum Permission {
    static let notDetermined = "NOT_DETERMINED"
    static let denied = "DENIED"
    static let authorized = "AUTHORIZED"
}

enum Error {
    static func unknown(method: String) -> FlutterError{
        return FlutterError.init(
            code: "UNKNOWN METHOD",
            message: "Method \(method) does not exist",
            details: nil);
    }
    static let locationUnavailable = FlutterError.init(
            code: "LOCATION_UNAVAILABLE",
            message: "Location is unavailable",
            details: nil);
}


public class SwiftFlutterLocationPlugin: NSObject, FlutterPlugin, FlutterStreamHandler, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    private var locationRequested = false
    private var pendingResult: FlutterResult?
    
    private var eventListening = false
    private var eventSink: FlutterEventSink?

    public override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: Channel.location, binaryMessenger: registrar.messenger())
        let event = FlutterEventChannel(name: Channel.locationEvent, binaryMessenger: registrar.messenger())
        
        let instance = SwiftFlutterLocationPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        event.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case Method.permission:
            self.permission(with: result)
        case Method.location:
            self.location(with: result)
        case Method.request_permissions:
            self.requestLocations(with: result)
        default:
            result(Error.unknown(method: call.method))
        }
    }
    
    private func requestLocations(with result: @escaping FlutterResult) {
        if (CLLocationManager.authorizationStatus() == .notDetermined) {
            manager.requestWhenInUseAuthorization()
            result(true)
        } else {
            result(false)
        }
    }
    
    private func permission(with result: @escaping FlutterResult) {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse: result(Permission.authorized)
        case .denied, .restricted: result(Permission.denied)
        default:
            result(Permission.notDetermined)
        }
    }
    
    private func location(with result: @escaping FlutterResult) {
        if CLLocationManager.authorizationStatus() != .authorizedAlways &&
            CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            return result(Error.locationUnavailable)
        }
        locationRequested = true
        pendingResult = result
        manager.startUpdatingLocation()
    }

    // event channel
    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        if CLLocationManager.authorizationStatus() != .authorizedAlways &&
            CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            return Error.locationUnavailable
        }
        
        self.eventSink = eventSink
        manager.startUpdatingLocation()
        eventListening = true
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        self.eventListening = false
        return nil
    }

   
    // location delegate
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location: CLLocation = locations.last else {
            pendingResult?(Error.locationUnavailable)
            return
        }
        
        let lastLocation = [
            "latitude": Double(location.coordinate.latitude),
            "longitude": Double(location.coordinate.longitude),
            "accuracy": Double(location.horizontalAccuracy),
            "altitude": Double(location.altitude),
            "speed": Double(location.speed)
        ]
        
        if locationRequested {
            locationRequested = false
            pendingResult?(lastLocation)
        }
        
        if eventListening {
            eventSink?(lastLocation);
        }
        
        if !locationRequested && !eventListening {
            manager.stopUpdatingLocation()
        }
    }
    
}

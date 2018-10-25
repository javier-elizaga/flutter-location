import 'dart:async';

import 'package:flutter/services.dart';

import 'permission.dart';

class Channel {
  static const location = 'javier-elizaga.location';
  static const locationEvent = 'javier-elizaga.location-event';
}

class Method {
  static const permission = 'permission';
  static const location = 'location';
}

class FlutterLocation {
  static const MethodChannel _channel = const MethodChannel(Channel.location);
  static const EventChannel _eventChannel =
      const EventChannel(Channel.locationEvent);

  static Stream<Map<String, double>> _onLocationChanged;

  static Future<Permission> get permissionLevel async {
    String permission = await _channel.invokeMethod(Method.permission);
    print('Location permission: $permission');
    return Permission.values.firstWhere(
        (p) => p.toString() == 'Permission.$permission',
        orElse: () => Permission.NOT_DETERMINED);
  }

  static Future<Map<String, double>> get location async {
    final location = await _channel.invokeMethod(Method.location);
    print('Location: $location');
    return toLocation(location);
  }

  static Stream<Map<String, double>> get onLocationChange {
    if (_onLocationChanged == null) {
      _onLocationChanged = _eventChannel.receiveBroadcastStream().map((data) {
        print('LocationData: $data');
        return toLocation(data);
      });
    }
    return _onLocationChanged;
  }

  static Map<String, double> toLocation(location) {
    return {
      'longitude': location['longitude'] ?? 0.0,
      'latitude': location['latitude'] ?? 0.0,
    };
  }
}

import 'dart:async';

import 'package:flutter/services.dart';

import 'permission.dart';
import 'location.dart';

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
  static Stream<Location> _onLocationChanged;

  static Future<Permission> get permissionLevel async {
    String permission = await _channel.invokeMethod(Method.permission);
    return Permission.values.firstWhere(
        (p) => p.toString() == 'Permission.$permission',
        orElse: () => Permission.NOT_DETERMINED);
  }

  static Future<Location> get location async {
    final location = await _channel.invokeMethod(Method.location);
    return Location.fromJson(location);
  }

  static Stream<Location> get onLocationChanged {
    if (_onLocationChanged == null) {
      _onLocationChanged = _eventChannel.receiveBroadcastStream().map((data) {
        return Location.fromJson(data);
      });
    }
    return _onLocationChanged;
  }
}

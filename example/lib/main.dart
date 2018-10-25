import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_location/flutter_location.dart';
import 'package:flutter_location/permission.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _permission;
  Map<String, double> _location;
  Map<String, double> _currentLocation;

  @override
  void initState() {
    super.initState();
    initPermission();
    initLocation();
    initCurrentLocation();
  }

  Future<void> initPermission() async {
    try {
      await _initPermission();
    } on PlatformException catch (e) {
      print('Permission error: $e');
    }
  }

  Future<void> initLocation() async {
    try {
      await _initLocation();
    } on PlatformException catch (e) {
      print('Location error: ${e.message}');
    }
  }

  Future<void> initCurrentLocation() async {
    try {
      await _initCurrentLocation();
    } on PlatformException catch (e) {
      print('Current location error: ${e.message}');
    }
  }

  static get _waitForUser => Duration(seconds: 1);

  Future<void> _initPermission() async {
    Permission locationPermission;

    //  Location.permissionLevel can throw PlatformException
    locationPermission = await FlutterLocation.permissionLevel;
    if (locationPermission == Permission.NOT_DETERMINED) {
      // Waiting for the user to authorized or denied permission
      return await Future.delayed(_waitForUser, _initPermission);
    }
    if (!mounted) {
      // nothing to do here
      return;
    }
    String locationPermissionDesc;
    if (locationPermission == Permission.DENIED) {
      locationPermissionDesc = "Denied";
    } else if (locationPermission == Permission.AUTHORIZED) {
      locationPermissionDesc = "Authorized";
    } else {
      locationPermissionDesc = "Error";
    }
    print('Permission $_permission -> $locationPermissionDesc');
    setState(() {
      _permission = locationPermissionDesc;
    });
  }

  Future<void> _initLocation() async {
    Permission locationPermission;
    //  Location.permissionLevel can throw PlatformException
    locationPermission = await FlutterLocation.permissionLevel;
    if (locationPermission == Permission.NOT_DETERMINED) {
      // Waiting for the user to authorized or denied permission
      return await Future.delayed(_waitForUser, _initLocation);
    }
    if (locationPermission == Permission.DENIED || !mounted) {
      // nothing to do here
      return;
    }

    Map<String, double> location = await FlutterLocation.location;
    setState(() {
      _location = location;
    });
  }

  Future<void> _initCurrentLocation() async {
    Permission locationPermission;
    //  Location.permissionLevel can throw PlatformException
    locationPermission = await FlutterLocation.permissionLevel;
    if (locationPermission == Permission.NOT_DETERMINED) {
      // Waiting for the user to authorized or denied permission
      return await Future.delayed(_waitForUser, _initCurrentLocation);
    }
    // if user denied permissions, or component is not mounted return
    if (locationPermission == Permission.DENIED || !mounted) {
      return;
    }
    FlutterLocation.onLocationChange.listen(
      (location) {
        print('Current location changes to: $location');
        setState(() {
          _currentLocation = location;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      children: <Widget>[
        ListTile(
          title: Text('Permission'),
          subtitle: Text(_permission ?? '-'),
        ),
        ListTile(
          title: Text('Location'),
          subtitle: Text(_location ?? '-'),
        ),
        ListTile(
          title: Text('Current'),
          subtitle: Text(_currentLocation ?? '-'),
        ),
      ],
    );

    return new MaterialApp(
      home: new Scaffold(
          appBar: new AppBar(
            title: const Text('Location Plugin example'),
          ),
          body: body),
    );
  }
}

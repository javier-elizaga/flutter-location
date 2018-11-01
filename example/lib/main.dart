import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_location/flutter_location.dart';
import 'package:flutter_location/permission.dart';
import 'package:flutter_location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Permission _permission = Permission.NOT_DETERMINED;
  Location _location;
  Location _currentLocation;

  @override
  void initState() {
    super.initState();
    initLocation();
  }

  Future<Permission> initPermission() async {
    Permission permission;
    bool isDetermined = false;
    await FlutterLocation.requestPermission;
    while (!isDetermined) {
      permission = await FlutterLocation.permission;
      if (permission == Permission.NOT_DETERMINED) {
        await Future.delayed(_waitForUser);
      } else {
        isDetermined = true;
      }
    }
    return permission;
  }

  void initLocation() async {
    Permission permission;
    permission = await initPermission();
    Location location;
    if (permission == Permission.AUTHORIZED) {
      location = await FlutterLocation.location;
      FlutterLocation.onLocationChanged.listen(
        (location) {
          setState(() => this._currentLocation = location);
        },
      );
    }
    setState(() {
      this._permission = permission;
      this._location = location;
    });
  }

  static get _waitForUser => Duration(seconds: 1);

  String init() {
    String permissionDesc = '-';
    if (_permission == Permission.AUTHORIZED) {
      permissionDesc = 'Authorized';
    } else if (_permission == Permission.DENIED) {
      permissionDesc = 'Denied';
    }
    return permissionDesc;
  }

  @override
  Widget build(BuildContext context) {
    String permissionDesc = init();
    final body = ListView(
      children: <Widget>[
        ListTile(
          title: Text('Permission'),
          subtitle: Text(permissionDesc),
        ),
        ListTile(
          title: Text('Location'),
          subtitle: Text(_location?.toString() ?? '-'),
        ),
        ListTile(
          title: Text('Current'),
          subtitle: Text(_currentLocation?.toString() ?? '-'),
        ),
      ],
    );

    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Location Plugin example'),
          ),
          body: body),
    );
  }
}

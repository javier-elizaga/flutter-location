# Flutter Location Plugin

A Flutter plugin to provide native location.

WARN: This plugin was written in swift/kotlin to be able to use it, you should have created the project with:

```
    flutter create -i swift -a kotlin project_name
```

## Getting Started

For help getting started with Flutter, view our online [documentation](https://flutter.io/).
For help on editing plugin code, view the [documentation](https://flutter.io/developing-packages/#edit-plugin-package).

Add the dependency to your pubspec.yaml file.

```
dependencies:
  flutter_location: ^0.0.4
```

For **iOS** device, add these in lines in the Info.plist file:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This message will be display to the user</string>
```

For **android** device, add these in lines in the AndroidManifest.xml file:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

Then import the plugin in your code:

```java
import 'package:flutter_location/flutter_location.dart'; // Plugin
import 'package:flutter_location/permission.dart'; // Return type
import 'package:flutter_location/location.dart'; // Return type
```

Look into the example for utilisation:

```java
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
```

For more examples check out:

- [Madrid Bike app](https://github.com/javier-elizaga/flutter-madrid-bike)
- [Flutter location example](https://github.com/javier-elizaga/flutter-location/tree/master/example)

## API

| Methods                                | Description                                                                                                                                                  |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Future<Permission> **permission**      | Get the level of permission the user has granted to the app (NOT_DETERMINED, DENIED, AUTHORIZED).                                                            |
| Future<Location> **location**          | Get the location of the user.                                                                                                                                |
| Stream<Location> **onLocationChanged** | Get the stream of the user's location.                                                                                                                       |
| Future<bool> **requestPermission**     | Show pop-up to the user to accept or decline permission authorizations. true if the pop-up was shown false if not (only will request once to show the popup) |

## Model

### Permission:

- NOT_DETERMINED: Permission not specified
- DENIED: The user rejected the authorization
- AUTHORIZED: The user granted permission to use location

### Location {

- double latitude
- double longitude
- double accuracy, // in iOS horizontal accuracy
- double altitude
- double speed

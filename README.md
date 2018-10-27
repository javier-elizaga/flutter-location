# Flutter Location Plugin

A Flutter plugin to provide native location.

WARN: This plugin was written in swift/kotlin to be able to use it, you should have create the project with:

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

In order to be able to receive location information from an **iOS** device, you need to modify the Info.plist, and add:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This message will be display to the user</string>
```

Then import the publin in your code:

```java
import 'package:flutter_location/flutter_location.dart'; // Plugin
import 'package:flutter_location/permission.dart'; // Return type
import 'package:flutter_location/location.dart'; // Return type
```

Look into the example for utilisation, but a basic implementation can be done like this for a one time location:

```java
Location _location;
Location _currentLocation;
@override
void initState() {
    super.initState();
    initLocation();
}
Future<void> initLocation() async {
    try {
      await _initLocation();
    } on PlatformException catch (e) {
      print('Location initialization errror: ${e.message}');
    }
}
Future<void> _initLocation() async {
    Permission locationPermission;
    //  FlutterLocation.permissionLevel can throw PlatformException
    locationPermission = await FlutterLocation.permissionLevel;
    if (locationPermission == Permission.NOT_DETERMINED) {
      // Waiting for the user to authorized or denied permission
      return await Future.delayed(_waitForUser, _initLocation);
    }
    if (locationPermission == Permission.DENIED || !mounted) {
      // nothing to do here
      return;
    }
    Location location = await FlutterLocation.location;
    setState(() => _location = location);
    FlutterLocation.onLocationChanged.listen(
      (location) {
        print('Current location changes to: $location');
        setState(() => _currentLocation = location);
      },
    );
}
```

For more examples checkout:

- [Madrid Bike app](https://github.com/javier-elizaga/flutter-madrid-bike)
- [Flutter location example](https://github.com/javier-elizaga/flutter-location/tree/master/example)

## API

| Methods                                | Description                                                                                       |
| -------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Future<Permission> **permissionLevel** | Get the level of permission the user has granted to the app (NOT_DETERMINED, DENIED, AUTHORIZED). |
| Future<Location> **location**          | Get the location of the user.                                                                     |
| Stream<Location> **onLocationChanged** | Get the stream of the user's location.                                                            |

## Model

### Permission:

- NOT_DETERMINED: Permission not specified
- DENIED: The user rejected the authorization
- AUTHORIZED: The user granted permission to use location

### Location {

- double latitude
- double longitude
- double accuracy, right now set it to horizontal accuracy
- double altitude
- double speed

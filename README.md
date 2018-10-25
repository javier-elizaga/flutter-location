# Flutter Location Plugin

A new flutter plugin to provide native location.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/developing-packages/#edit-plugin-package).

## API

| Methods                                          | Description                                                                                       |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------- |
| Future<Permission> **permissionLevel**           | Get the level of permission the user has granted to the app (NOT_DETERMINED, DENIED, AUTHORIZED). |
| Future<Map<String, double>> **location**         | Get the location of the user                                                                      |
| Stream<Map<String, double>> **onLocationChange** | Get the stream of the user's location.                                                            |

## Model

Permission:

- NOT_DETERMINED: Permission not specified
- DENIED: The user rejected the authorization
- AUTHORIZED: The user granted permission to use location

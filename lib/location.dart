class Location {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double speed;

  Location({
    this.latitude,
    this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
  });

  factory Location.fromJson(json) {
    return Location(
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      accuracy: json['accuracy'] ?? 0.0,
      altitude: json['altitude'] ?? 0.0,
      speed: json['speed'] ?? 0.0,
    );
  }

  @override
  String toString() {
    return '''{
  'latitude': $latitude
  'longitude': $longitude
  'accuracy': $accuracy
  'altitude': $altitude
  'speed': $speed
}''';
  }
}

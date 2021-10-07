import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:location/location.dart';
import 'package:async/async.dart';

class Position {
  const Position({this.location, this.bearing});

  final LocationData? location;
  final double? bearing;
}

class PositionTracker {
  Position position = const Position();
  late Location location;

  static Future<PositionTracker?> init() async {
    return PositionTracker()._init();
  }

  Future<PositionTracker?> _init() async {
    location = Location();
    var enabled = await location.serviceEnabled();
    if (!enabled) {
      enabled = await location.requestService();
      if (!enabled) {
        return null;
      }
    }

    var granted = await location.hasPermission();
    if (granted == PermissionStatus.denied) {
      granted = await location.requestPermission();
      if (granted != PermissionStatus.granted) {
        return null;
      }
    }
    return this;
  }

  /// Provides a [Stream] of position events that can be listened to.
  Stream<Position>? get onChanged {
    var stream = StreamGroup.merge(
        [location.onLocationChanged, FlutterCompass.events as Stream<dynamic>]);
    if (kIsWeb) {
      stream = StreamGroup.merge([location.onLocationChanged]);
    }

    return stream.map((dynamic event) {
      switch (event.runtimeType) {
        case LocationData:
          var cur = event as LocationData;
          position = Position(location: cur, bearing: position.bearing);
          return position;
        case CompassEvent:
          var cur = event as CompassEvent;
          position =
              Position(location: position.location, bearing: cur.heading!);
          return position;
      }
      return position;
    });
  }
}

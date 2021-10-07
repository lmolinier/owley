import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

/// Converts degree to radian
double degToRadian(final double deg) => deg * (math.pi / 180.0);

/// Radian to degree
double radianToDeg(final double rad) => rad * (180.0 / math.pi);

class LatLngRadian {
  const LatLngRadian({
    required this.latitudeRadian,
    required this.longitudeRadian,
  });

  final double latitudeRadian;
  final double longitudeRadian;

  static LatLngRadian fromLatLngDegree(LatLng p) {
    return LatLngRadian(
        latitudeRadian: degToRadian(p.latitude),
        longitudeRadian: degToRadian(p.longitude));
  }

  LatLng toLatLngDegree() {
    return LatLng(radianToDeg(latitudeRadian), radianToDeg(longitudeRadian));
  }
}

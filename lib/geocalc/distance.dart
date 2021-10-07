import 'package:demogonio/geocalc/coord.dart';
import 'package:demogonio/geocalc/harvesine.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class DistanceCalculator {
  double distance(final LatLngRadian p1, final LatLngRadian p2);
  LatLngRadian offset(final LatLngRadian from, final double distanceInMeter,
      final double bearingRadian);
}

class Distance {
  final calculator = const Haversine();

  LatLng offset(LatLng from, final double distance, double bearing) {
    return calculator
        .offset(
            LatLngRadian.fromLatLngDegree(from), distance, degToRadian(bearing))
        .toLatLngDegree();
  }
}

import 'dart:math' as math;

import 'package:demogonio/geocalc/coord.dart';

import 'distance.dart';

class Haversine implements DistanceCalculator {
  // final Logger _logger = new Logger('latlong.Haversine');

  // Equator radius in meter (WGS84 ellipsoid)
  final double equatorRadius = 6378137.0;

  const Haversine();

  /// Calculates distance with Haversine algorithm.
  ///
  /// Accuracy can be out by 0.3%
  /// More on [Wikipedia](https://en.wikipedia.org/wiki/Haversine_formula)
  @override
  double distance(final LatLngRadian p1, final LatLngRadian p2) {
    final sinDLat = math.sin((p2.latitudeRadian - p1.latitudeRadian) / 2);
    final sinDLng = math.sin((p2.longitudeRadian - p1.longitudeRadian) / 2);

    // Sides
    final a = sinDLat * sinDLat +
        sinDLng *
            sinDLng *
            math.cos(p1.latitudeRadian) *
            math.cos(p2.latitudeRadian);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return equatorRadius * c;
  }

  /// Returns a destination point based on the given [distance] and [bearing]
  ///
  /// Given a [from] (start) point, initial [bearing], and [distance],
  /// this will calculate the destination point and
  /// final bearing travelling along a (shortest distance) great circle arc.
  ///
  ///     final Haversine distance = const Haversine();
  ///
  ///     final num distanceInMeter = (EARTH_RADIUS * math.PI / 4).round();
  ///
  ///     final p1 = new LatLng(0.0, 0.0);
  ///     final p2 = distance.offset(p1, distanceInMeter, 180);
  ///
  @override
  LatLngRadian offset(final LatLngRadian from, final double distanceInMeter,
      final double bearingRadian) {
    final double a = distanceInMeter / equatorRadius;

    final double lat2 = math.asin(math.sin(from.latitudeRadian) * math.cos(a) +
        math.cos(from.latitudeRadian) * math.sin(a) * math.cos(bearingRadian));

    final double lng2 = from.longitudeRadian +
        math.atan2(
            math.sin(bearingRadian) *
                math.sin(a) *
                math.cos(from.latitudeRadian),
            math.cos(a) - math.sin(from.latitudeRadian * math.sin(lat2)));

    return LatLngRadian(latitudeRadian: lat2, longitudeRadian: lng2);
  }
}

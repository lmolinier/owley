import 'package:demogonio/geocalc/distance.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Cone {
  final double distance = 20000; // in meter.

  const Cone({required this.center, required this.heading, this.angle});

  final LatLng center;
  final double heading;
  final double? angle;

  List<LatLng> asPoints() {
    final Distance d = Distance();
    final LatLng p1 = d.offset(center, distance, heading - ((angle ?? 0) / 2));
    final LatLng p2 = d.offset(center, distance, heading + ((angle ?? 0) / 2));
    return [
      center,
      LatLng(p1.latitude, p1.longitude),
      LatLng(p2.latitude, p2.longitude),
    ];
  }
}

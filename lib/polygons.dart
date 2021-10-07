import 'package:demogonio/geocalc/distance.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Cone {
  final double distance = 10000; // in meter.

  const Cone(
      {required this.id,
      required this.center,
      required this.heading,
      this.width});

  final String id;
  final LatLng center;
  final double heading;
  final double? width;

  Polygon asPolygon() {
    final Distance d = Distance();
    final LatLng p1 = d.offset(center, distance, heading - ((width ?? 0) / 2));
    final LatLng p2 = d.offset(center, distance, heading + ((width ?? 0) / 2));
    return Polygon(
      polygonId: PolygonId(id),
      points: [
        center,
        LatLng(p1.latitude, p1.longitude),
        LatLng(p2.latitude, p2.longitude),
      ],
      fillColor: Colors.red.shade200.withOpacity(0.5),
      strokeColor: Colors.red.shade600.withOpacity(0.9),
      strokeWidth: 3,
    );
  }
}

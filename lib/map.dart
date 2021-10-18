import 'package:demogonio/polygons.dart';
import 'package:demogonio/position.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dart:collection';

class GonioMap extends StatefulWidget {
  const GonioMap({Key? key}) : super(key: key);

  @override
  State<GonioMap> createState() => GonioMapState();
}

class GonioMapState extends State<GonioMap> {
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);

  final SplayTreeMap<String, Cone> _cones = SplayTreeMap();

  late GoogleMapController mapController;

  // The camera is currently moving
  bool _isMoving = false;

  // Camera current position
  CameraPosition _currentPosition =
      const CameraPosition(target: LatLng(0, 0), zoom: 16);

  // Camera target position as calculated from (location,compass,user)
  CameraPosition _wantedPosition =
      const CameraPosition(target: LatLng(0, 0), zoom: 16);
  LocationData? _wantedLocation;

  MapType _mapType = MapType.normal;
  bool _centerLock = true;

  @override
  initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () {
      // Update the position (and compass).
      PositionTracker.init().then((tracker) {
        tracker?.onChanged?.listen((Position position) {
          setState(() {
            _wantedPosition = CameraPosition(
                target: LatLng(position.location!.latitude!,
                    position.location!.longitude!),
                bearing: position.bearing ?? 0,
                tilt: _wantedPosition.tilt,
                zoom: _wantedPosition.zoom);
            _wantedLocation = position.location;
          });
        });
      });
    });
  }

  drawPolygon() {
    setState(() {
      _cones["cone_${_cones.length}"] = Cone(
          center: _wantedPosition.target,
          heading: (_wantedPosition.bearing + 360) % 360,
          angle: 5);
    });
  }

  toggleMapType() {
    setState(() {
      _mapType =
          _mapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    if (_centerLock && !_isMoving) {
      try {
        mapController
            .animateCamera(CameraUpdate.newCameraPosition(_wantedPosition));
      } catch (e) {
        // ignore
      }
    }

    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          openCloseDial: isDialOpen,
          backgroundColor: Colors.redAccent,
          overlayColor: Colors.grey,
          overlayOpacity: 0.5,
          spacing: 15,
          spaceBetweenChildren: 15,
          closeManually: false,
          children: [
            SpeedDialChild(
                child: const Icon(Icons.layers),
                label: 'Type',
                onTap: () {
                  toggleMapType();
                }),
            SpeedDialChild(
                child: const Icon(Icons.delete_sweep),
                label: 'Clear',
                onTap: () {
                  setState(() {
                    _cones.clear();
                  });
                }),
            SpeedDialChild(
                child: const Icon(Icons.delete),
                label: 'Delete last',
                onTap: () {
                  setState(() {
                    var key = _cones.lastKey();
                    _cones.remove(key);
                  });
                }),
          ],
        ),
        body: Stack(children: <Widget>[
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            onCameraIdle: () {
              _isMoving = false;
              _wantedPosition = CameraPosition(
                  target: _wantedPosition.target,
                  bearing: _wantedPosition.bearing,
                  tilt: _currentPosition.tilt,
                  zoom: _currentPosition.zoom);
            },
            onCameraMove: (position) {
              _currentPosition = position;
            },
            onCameraMoveStarted: () {
              _isMoving = true;
            },
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            mapType: _mapType,
            initialCameraPosition: _currentPosition,
            polygons: Set.from(_cones.map<String, Polygon>((id, cone) {
              return MapEntry(
                  id,
                  Polygon(
                    polygonId: PolygonId(id),
                    points: cone.asPoints(),
                    fillColor: Colors.red.shade200.withOpacity(0.5),
                    strokeColor: Colors.red.shade600.withOpacity(0.9),
                    strokeWidth: 3,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Row(
                            children: const [
                              Icon(Icons.delete_forever, color: Colors.white),
                              Text("Please confirm deletion"),
                            ],
                          ),
                          action: SnackBarAction(
                            label: 'delete',
                            onPressed: () {
                              setState(() {
                                _cones.remove(id);
                              });
                            },
                          )));
                    },
                  ));
            }).values),
            circles: {
              Circle(
                circleId: const CircleId("myself-radius"),
                center: _wantedPosition.target,
                radius: _wantedLocation?.accuracy ?? 0,
                fillColor: Colors.blue.shade100.withOpacity(0.5),
                strokeWidth: 0,
              ),
              Circle(
                circleId: const CircleId("myself"),
                center: _wantedPosition.target,
                radius: 0.5,
                fillColor: Colors.blue.withOpacity(0.9),
                strokeWidth: 0,
              )
            },
          ),
          Container(
              margin: const EdgeInsets.only(top: 80, bottom: 90, right: 15),
              alignment: Alignment.topRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FloatingActionButton(
                          child: const Icon(Icons.architecture),
                          elevation: 5,
                          backgroundColor: Colors.teal[200],
                          onPressed: () {
                            drawPolygon();
                          }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FloatingActionButton(
                          child: Icon(Icons.my_location,
                              color: _centerLock ? Colors.blue : Colors.black),
                          elevation: 5,
                          backgroundColor: Colors.white,
                          onPressed: () {
                            setState(() {
                              _centerLock = !_centerLock;
                            });
                          }),
                    ],
                  )
                ],
              )),
        ]),
      ),
    );
  }
}

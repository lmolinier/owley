import 'package:demogonio/dial.dart';
import 'package:demogonio/polygons.dart';
import 'package:demogonio/position.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radio Goniometry Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Demo Gonio Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final List<Polygon> _polygons = [];

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

    // Update the position (and compass).
    PositionTracker.init().then((tracker) {
      tracker?.onChanged?.listen((Position position) {
        setState(() {
          _wantedPosition = CameraPosition(
              target: LatLng(
                  position.location!.latitude!, position.location!.longitude!),
              bearing: position.bearing ?? 0,
              tilt: _wantedPosition.tilt,
              zoom: _wantedPosition.zoom);
          _wantedLocation = position.location!;
        });
      });
    });
  }

  clearPolygons() {
    setState(() {
      _polygons.clear();
    });
  }

  removeLastPolygon() {
    setState(() {
      _polygons.removeLast();
    });
  }

  drawPolygon() {
    setState(() {
      _polygons.add(Cone(
              id: "cone_${_polygons.length}",
              center: _wantedPosition.target,
              heading: (_wantedPosition.bearing + 360) % 360,
              width: 5)
          .asPolygon());
      print(_wantedPosition.bearing);
    });
  }

  toggleMapType() {
    setState(() {
      _mapType =
          _mapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  bool isCenterLocked() {
    return _centerLock;
  }

  toggleCenterLock() {
    setState(() {
      _centerLock = !_centerLock;
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

    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: DialMenu(
            parent: this,
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
                polygons: Set.from(_polygons),
                circles: {
                  Circle(
                    circleId: const CircleId("myself-radius"),
                    center: _wantedPosition.target,
                    radius: _wantedLocation?.accuracy ?? 0,
                    fillColor: Colors.blue.shade100.withOpacity(0.5),
                    strokeColor: Colors.blue.shade100.withOpacity(0.9),
                    strokeWidth: 3,
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
                margin: const EdgeInsets.only(top: 80, right: 10),
                alignment: Alignment.topRight,
                child: Column(children: <Widget>[
                  FloatingActionButton(
                      child: const Icon(Icons.architecture),
                      elevation: 5,
                      backgroundColor: Colors.teal[200],
                      onPressed: () {
                        drawPolygon();
                      }),
                ]),
              )
            ])));
  }
}

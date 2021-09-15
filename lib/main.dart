import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recentering Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  var startingPosition = LatLng(40.702872, -74.015431); // The Battery, lower Manhattan Island
  bool _isInForeground = true; // when the app first initializes, it IS in the foreground
  late final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isInForeground = state == AppLifecycleState.resumed;
    print("Status of var _isInForeground: $_isInForeground");
    updateUserCenter(_isInForeground);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recentering Demo"),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: startingPosition,
          zoom: 13,
        ),
        layers: [
          TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']
          ),
        ],
      ),
    );
  }

  void updateUserCenter(bool _isInForeground) {
    if (_isInForeground) {
      print("inside of updateUserCenter() function");
      StreamSubscription<Position> positionStream = Geolocator.getPositionStream(distanceFilter: 10).listen(
              (Position position) {
            // the distanceFilter is to ensure we only update the stream if a significant (10  meter) change has occured
            // next, convert the latitude and longitude into a LatLng and save it into startingPosition
            // then .move the _mapController
            print(position == null ? 'Unknown' : position.latitude.toString() + ', ' + position.longitude.toString());
            startingPosition = LatLng(position.latitude, position.longitude);
            _mapController.move(startingPosition, 13);
          });
    }
  }
}

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

void main(List<String> args) {
  runApp(const MapDeepLearningApp());
}

class MapDeepLearningApp extends StatelessWidget {
  const MapDeepLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyYandexMap(),
    );
  }
}

class MyYandexMap extends StatefulWidget {
  const MyYandexMap({super.key});

  @override
  State<MyYandexMap> createState() => _MyYandexMapState();
}

class _MyYandexMapState extends State<MyYandexMap> {
  YandexMapController? mapController;
  Point? myLocation;

  Future<void> getCurrentLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    location.onLocationChanged.listen((event) {
      myLocation =
          Point(latitude: event.latitude ?? 0, longitude: event.longitude ?? 0);
      if (mapController != null) {
        mapController!.moveCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 17,
            target: myLocation!,
          ),
        ));
        setState(() {

        });
      }

      print("Location ${event.latitude} & ${event.longitude}");
    });
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: YandexMap(
          mapObjects: [
            CircleMapObject(
              mapId: const MapObjectId("my_location"),
              circle: Circle(
                  center: myLocation ?? const Point(latitude: 0, longitude: 0),
                  radius: 5),
            ),
          ],
          onMapCreated: (controller) {
            mapController = controller;
            setState(() {});
          },
        ),
      ),
    );
  }
}

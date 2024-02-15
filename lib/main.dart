import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:map_notification/pages/location_page.dart';
import 'package:map_notification/pages/permission.dart';

import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'bloc/map_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await permission();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapBloc(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WayHome(),
      ),
    );
  }
}

class MyYandexMap extends StatefulWidget {
  const MyYandexMap({super.key});

  @override
  State<MyYandexMap> createState() => _MyYandexMapState();
}

class _MyYandexMapState extends State<MyYandexMap> {
  late YandexMapController controllerYandex;
  int a = 0;
  Point? myPosition;
  Future<void> getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    await location.changeSettings(interval: 250);

    locationData = await location.getLocation();
    location.onLocationChanged.listen((event) {
      myPosition = Point(
        latitude: event.latitude ?? 0,
        longitude: event.longitude ?? 0,
      );

      if (controllerYandex != null) {
        controllerYandex.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 18,
              target: myPosition!,
            ),
          ),
        );
      }
      print('${event.latitude} ${event.longitude}');
    });
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: YandexMap(
          mapObjects: [
            CircleMapObject(
              strokeColor: Colors.black,
              fillColor: Colors.black,
              mapId: const MapObjectId("my_location"),
              circle: Circle(
                center: myPosition ??
                    const Point(
                      latitude: 0,
                      longitude: 0,
                    ),
                radius: 5,
              ),
            ),
            const PolygonMapObject(
              mapId: MapObjectId("polygon"),
              fillColor: Colors.black,
              polygon: Polygon(
                outerRing: LinearRing(
                  points: [
                    Point(latitude: 56.34295, longitude: 74.62829),
                    Point(latitude: 70.12669, longitude: 98.97399),
                    Point(latitude: 56.04956, longitude: 125.07751),
                  ],
                ),
                innerRings: [
                  LinearRing(
                    points: [
                      Point(latitude: 57.34295, longitude: 78.62829),
                      Point(latitude: 69.12669, longitude: 98.97399),
                      Point(latitude: 57.04956, longitude: 121.07751),
                    ],
                  ),
                ],
              ),
            ),
          ],
          onMapCreated: (controller) async {
            controllerYandex = controller;
          },
        ),
      ),
    );
  }
}

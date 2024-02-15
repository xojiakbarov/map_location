import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../bloc/map_bloc.dart';

class WayHome extends StatefulWidget {
  const WayHome({super.key});

  @override
  State<WayHome> createState() => _WayHomeState();
}

class _WayHomeState extends State<WayHome> {
  Location location = Location();
  @override
  void initState() {
    location.onLocationChanged.listen((event) {
      context.read<MapBloc>().add(StartedBloc());
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        return Builder(builder: (context) {
          if (state.status == Status.loading) {
            context.read<MapBloc>().add(StartedBloc());
            return const CupertinoActivityIndicator();
          } else if (state.status == Status.succses) {
            return Scaffold(
              body: YandexMap(
                mapObjects: [
                  CircleMapObject(
                    fillColor: Colors.blue,
                    mapId: const MapObjectId("source"),
                    circle: Circle(
                      center: state.myPoint,
                      radius: 10,
                    ),
                  ),
                  PlacemarkMapObject(
                    mapId: const MapObjectId("destination"),
                    point: state.anotherLocation,
                  ),
                  state.route,
                ],
                onMapCreated: (controller) async {
                  state.controller = controller;
                  await controller.moveCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        zoom: 17,
                        target: state.myPoint,
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return const Scaffold(
              body: Center(
                child: Text("error"),
              ),
            );
          }
        });
      },
    );
  }
}

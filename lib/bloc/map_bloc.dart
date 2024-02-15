import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:bloc/bloc.dart';

part 'map_event.dart';
part 'map_state.dart';



class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc()
      : super(
    MapState(
      route: const PolylineMapObject(
        mapId: MapObjectId('route'),
        polyline: Polyline(
          points: [],
        ),
      ),
      status: Status.loading,
      anotherLocation: const Point(latitude: 41.285703, longitude: 69.203733),
      myPoint: const Point(
        latitude: 0,
        longitude: 0,
      ),
    ),
  ) {
    on<StartedBloc>((event, emit) async {
      var point = await Location().getLocation();

      emit(state.copyWith(
        myPoint: Point(latitude: point.latitude!, longitude: point.longitude!),
        status: Status.succses,
      ));
      final request = YandexDriving.requestRoutes(
        points: [
          RequestPoint(
            point: state.myPoint,
            requestPointType: RequestPointType.wayPoint,
          ),
          RequestPoint(
            point: state.anotherLocation,
            requestPointType: RequestPointType.wayPoint,
          ),
        ],
        drivingOptions: const DrivingOptions(
          initialAzimuth: 0,
          routesCount: 1,
          avoidTolls: true,
        ),
      );
      final result = await request.result;

      emit(state.copyWith(
        route: PolylineMapObject(
          strokeColor: Colors.red,
          strokeWidth: 3,
          mapId: const MapObjectId("route"),
          polyline: Polyline(
            points: result.routes?.first.geometry ?? [],
          ),
        ),
      ));
    });
  }
}

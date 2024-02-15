part of 'map_bloc.dart';


class MapState {
  final Point anotherLocation;
  final Point myPoint;
  YandexMapController? controller;
  final PolylineMapObject route;
  final Status status;
  MapState({
    required this.anotherLocation,
    required this.myPoint,
    this.controller,
    required this.route,
    required this.status,
  });


  MapState copyWith({
    Point? anotherLocation,
    Point? myPoint,
    YandexMapController? controller,
    PolylineMapObject? route,
    Status? status,
  }) {
    return MapState(
      anotherLocation: anotherLocation ?? this.anotherLocation,
      myPoint: myPoint ?? this.myPoint,
      controller: controller ?? this.controller,
      route: route ?? this.route,
      status: status ?? this.status,
    );
  }
}

enum Status{
  loading, succses,
}

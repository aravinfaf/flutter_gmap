import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '.env.dart';
import 'directions_model.dart';

class DirectionRepository {
  static const _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';
  final Dio _dio;

  DirectionRepository({Dio dio}) : _dio = dio ?? Dio();

  Future<Directions> getDirections(LatLng origin, LatLng destination) async {
    final response = await _dio.get(_baseUrl, queryParameters: {
      'origin': '${origin.latitude},${origin.latitude}',
      'destination': '${destination.latitude},${destination.latitude}',
      'key': googleAPIKey,
    });

    //Check if response successful
    if (response.statusCode == 200) {
      return Directions.fromMap(response.data);
    }
    return null;
  }
}

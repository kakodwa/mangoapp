import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class MapService {
  final String apiKey =
      "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6Ijk0YzE2Y2Q3YjRhZDQ3YmJhMTg0ZGNmNDllMWJkZjUzIiwiaCI6Im11cm11cjY0In0=";

  final List<int> retryRadiuses = [2000, 5000, 10000];

  Future<List<LatLng>> getRoute(
      LatLng start, LatLng end) async {

    for (int radius in retryRadiuses) {
      final route = await _fetchRoute(start, end, radius);

      if (route.isNotEmpty) {
        print("✅ Route found with radius: $radius");
        return route;
      }
    }

    print("❌ No valid route found");
    return [];
  }

  Future<List<LatLng>> _fetchRoute(
      LatLng start, LatLng end, int radius) async {

    final url = Uri.parse(
      "https://api.openrouteservice.org/v2/directions/driving-car",
    );

    final body = jsonEncode({
      "coordinates": [
        [start.longitude, start.latitude],
        [end.longitude, end.latitude],
      ],
      "radiuses": [radius, radius],
    });

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": apiKey,
          "Content-Type": "application/json",
        },
        body: body,
      );

      print("🔵 Radius: $radius");
      print("STATUS CODE: ${response.statusCode}");

      final data = jsonDecode(response.body);

      // ❌ API failure check
      if (response.statusCode != 200 ||
          data["routes"] == null ||
          data["routes"].isEmpty) {
        print("❌ No route for radius $radius");
        return [];
      }

      final route = data["routes"][0];

      // ✅ IMPORTANT: geometry is encoded polyline STRING
      final encodedGeometry = route["geometry"];

      if (encodedGeometry == null || encodedGeometry is! String) {
        print("❌ Invalid geometry format");
        return [];
      }

      // 🔥 Decode polyline
      List<PointLatLng> decodedPoints =
          PolylinePoints().decodePolyline(encodedGeometry);

      List<LatLng> routePoints = decodedPoints
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      print("📍 Route points: ${routePoints.length}");

      return routePoints;
    } catch (e) {
      print("🔥 ERROR: $e");
      return [];
    }
  }
}
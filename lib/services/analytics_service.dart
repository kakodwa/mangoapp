import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/payment_model.dart';
import '../core/errors/api_exception.dart';
import '../core/api/api_client.dart';

class AnalyticsService {
  final ApiClient _apiClient = ApiClient();

  /// Helper to get current GPS coordinates safely with a 3-second timeout
  Future<Position?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      
      if (permission == LocationPermission.deniedForever) return null;

      // Fetch position with a short timeout to avoid blocking page loads
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      ).timeout(const Duration(seconds: 3));
    } catch (_) {
      return null; // Return null gracefully if GPS times out or permission is denied
    }
  }

  /// Sends anonymous app events along with device type and GPS location
  /// Fails silently without crashing or logging red terminal errors if endpoint is unreachable
  Future<void> logEvent(String eventName) async {
    try {
      // 1. Determine Platform
      String platform = 'Unknown';
      if (kIsWeb) {
        platform = 'Web';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        platform = 'Android';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        platform = 'iOS';
      }

      // 2. Fetch GPS Location (Safe timeout fallback)
      Position? position = await _getCurrentLocation();

      // 3. Send payload to Django backend
      await _apiClient.post(
        'analytics/log/', 
        data: {
          'event_name': eventName,
          'device_type': platform,
          'latitude': position?.latitude,
          'longitude': position?.longitude,
        },
        fromJson: (json) => json,
      );
      
      debugPrint("📊 Analytics logged: $eventName on $platform");
    } catch (e) {
      // Catch and swallow analytics network errors silently
      debugPrint("⚠️ Analytics log skipped ($eventName): $e");
    }
  }

  /// Retrieves aggregated analytics data back from Django for Admin/Dashboards
  Future<Map<String, dynamic>> fetchAnalyticsStats() async {
    try {
      return await _apiClient.get(
        'analytics/stats/',
        fromJson: (json) => json,
      );
    } on ApiException {
      rethrow; 
    } catch (e) {
      debugPrint('❌ Failed fetching analytics stats: $e');
      throw ApiException("Could not load tracking statistics");
    }
  }
}
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/payment_model.dart'; // Adjust path if needed based on directory structure
import '../core/errors/api_exception.dart';   // Adjust path to your api_exception.dart
import '../core/api/api_client.dart';              // Adjust path to your ApiClient file

class AnalyticsService {
  final ApiClient _apiClient = ApiClient();

  /// Helper to get current GPS coordinates safely
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

      // Fetch current position with a low accuracy to save battery
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );
    } catch (e) {
      return null; // Return null if anything fails (e.g. on Web or Emulator issues)
    }
  }

  /// Sends anonymous app events along with device type and GPS location
  Future<void> logEvent(String eventName) async {
    try {
      // 1. Get Platform
      String platform = 'Unknown';
      if (kIsWeb) {
        platform = 'Web';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        platform = 'Android';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        platform = 'iOS';
      }

      // 2. Fetch GPS Location (Will request permission on first run)
      Position? position = await _getCurrentLocation();

      // 3. Send payload to Django
      await _apiClient.post(
        'analytics/log/', 
        data: {
          'event_name': eventName,
          'device_type': platform,
          'latitude': position?.latitude,  // Will be null if permission denied
          'longitude': position?.longitude, // Will be null if permission denied
        },
        fromJson: (json) => json,
      );
      
      _apiClient.logger.i("📊 Analytics logged: $eventName on $platform (GPS: ${position?.latitude}, ${position?.longitude})");
    } catch (e) {
      _apiClient.logger.e('⚠️ Failed to log event "$eventName": $e');
    }
  }

  /// Retrieves aggregated analytics data back from Django
  Future<Map<String, dynamic>> fetchAnalyticsStats() async {
    try {
      return await _apiClient.get(
        'analytics/stats/',
        fromJson: (json) => json,
      );
    } on ApiException {
      rethrow; 
    } catch (e) {
      _apiClient.logger.e('❌ Failed fetching analytics stats: $e');
      throw ApiException("Could not load tracking statistics");
    }
  }
}

/*
* 
* import 'path/to/analytics_service.dart';

// 1. To track an app open in initState:
AnalyticsService().logEvent('app_open');

// 2. To track a click event on a button:
ElevatedButton(
  onPressed: () => AnalyticsService().logEvent('checkout_click'),
  child: const Text("Proceed to Checkout"),
);

// 3. To read stats back in an Admin/Dashboard widget:
FutureBuilder<Map<String, dynamic>>(
  future: AnalyticsService().fetchAnalyticsStats(),
  builder: (context, snapshot) {
    // build layout using snapshot.data...
  },
); */
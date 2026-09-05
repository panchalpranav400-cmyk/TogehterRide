import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum LocationFailure { serviceDisabled, permissionDenied, permissionDeniedForever, unavailable }

class LocationResult {
  final LatLng? coordinate;
  final LocationFailure? failure;

  const LocationResult.success(this.coordinate) : failure = null;

  const LocationResult.failure(this.failure) : coordinate = null;

  bool get isSuccess => coordinate != null;
}

/// Wraps [Geolocator] with permission handling so callers just get either a
/// coordinate or a reason it couldn't be obtained.
class LocationService {
  static Future<LocationResult> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult.failure(LocationFailure.serviceDisabled);
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.failure(
            LocationFailure.permissionDeniedForever);
      }
      if (permission == LocationPermission.denied) {
        return const LocationResult.failure(LocationFailure.permissionDenied);
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return LocationResult.success(
        LatLng(position.latitude, position.longitude),
      );
    } catch (_) {
      return const LocationResult.failure(LocationFailure.unavailable);
    }
  }
}

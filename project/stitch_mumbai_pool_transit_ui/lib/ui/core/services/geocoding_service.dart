import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../constants/app_config.dart';

/// A resolved place from Mapbox Geocoding — a coordinate plus its
/// human-readable name (used to correct free-text input to a canonical label).
class GeocodedPlace {
  final LatLng coordinate;
  final String placeName;

  const GeocodedPlace(this.coordinate, this.placeName);
}

/// Forward/reverse geocoding backed by the Mapbox Geocoding API, biased to
/// the Mumbai metro area so short queries like "Bandra" resolve sensibly.
class GeocodingService {
  static const String _mumbaiBbox = '72.75,18.85,73.05,19.35';

  static Future<GeocodedPlace?> forwardGeocode(String query) async {
    final token = AppConfig.mapboxAccessToken;
    final trimmed = query.trim();
    if (token.isEmpty || trimmed.isEmpty) return null;

    final uri = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeComponent(trimmed)}.json',
    ).replace(queryParameters: {
      'access_token': token,
      'bbox': _mumbaiBbox,
      'country': 'IN',
      'limit': '1',
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final features = body['features'] as List<dynamic>?;
      if (features == null || features.isEmpty) return null;

      final feature = features.first as Map<String, dynamic>;
      final center = feature['center'] as List<dynamic>;
      final lng = (center[0] as num).toDouble();
      final lat = (center[1] as num).toDouble();
      final placeName = feature['place_name'] as String? ?? trimmed;

      return GeocodedPlace(LatLng(lat, lng), placeName);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> reverseGeocode(LatLng point) async {
    final token = AppConfig.mapboxAccessToken;
    if (token.isEmpty) return null;

    final uri = Uri.parse(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/'
      '${point.longitude},${point.latitude}.json',
    ).replace(queryParameters: {
      'access_token': token,
      'limit': '1',
    });

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final features = body['features'] as List<dynamic>?;
      if (features == null || features.isEmpty) return null;

      return (features.first as Map<String, dynamic>)['place_name'] as String?;
    } catch (_) {
      return null;
    }
  }
}

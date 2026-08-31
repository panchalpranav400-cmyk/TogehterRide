/// TogetherRide Application Configuration & API Credentials
class AppConfig {
  /// Google Maps API Key
  /// Replace 'YOUR_GOOGLE_MAPS_API_KEY' with your actual key from Google Cloud Console.
  /// Ensure Maps SDK for Android, Maps SDK for iOS, and Maps JavaScript API are enabled.
  static const String googleMapsApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  /// Default Mumbai Map Center (Bandra - Lower Parel Transit Corridor)
  static const double defaultLat = 19.0300;
  static const double defaultLng = 72.8350;
  static const double defaultZoom = 13.5;

  /// Common Mumbai Transit Coordinates
  static const Map<String, List<double>> mumbaiCoordinates = {
    'Bandra West': [19.0596, 72.8295],
    'Lower Parel': [19.0000, 72.8300],
    'BKC': [19.0657, 72.8686],
    'Marine Drive': [18.9440, 72.8230],
    'CSMT Station': [18.9400, 72.8350],
    'Andheri East': [19.1197, 72.8464],
    'Powai': [19.1176, 72.9060],
    'Dadad': [19.0178, 72.8478],
  };
}

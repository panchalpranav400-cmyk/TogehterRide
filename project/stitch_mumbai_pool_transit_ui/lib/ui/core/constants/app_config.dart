/// TogetherRide Application Configuration & API Credentials
class AppConfig {
  /// Supabase project URL (Dashboard → Project Settings → API).
  static const String supabaseUrl = 'https://zmuxmtumlbnkpfnkzlfc.supabase.co';

  /// Supabase publishable (anon) key — safe for client-side use.
  static const String supabaseAnonKey =
      'sb_publishable_bsflwfhIxAxJVa12hqjpBQ_1MpcuKEL';

  /// Google OAuth Web Client ID (Google Cloud → Credentials → Web client).
  /// Also add this in Supabase Dashboard → Authentication → Providers → Google.
  static const String googleWebClientId =
      '956521732197-u98gt12cjtf5gdq3esso6kjtibitqalp.apps.googleusercontent.com';

  /// Google OAuth iOS Client ID — only required when building for iOS.
  static const String googleIosClientId = 'YOUR_GOOGLE_IOS_CLIENT_ID';

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

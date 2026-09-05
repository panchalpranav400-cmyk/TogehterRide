import 'package:flutter/foundation.dart';

/// OAuth redirect URL — must be listed in Supabase Dashboard → Authentication → URL Configuration.
/// Must match the Android deep-link intent filter in AndroidManifest.xml.
const String kOAuthRedirectUrl =
    'com.sahay.mumbai_pool_transit://login-callback';

/// Legacy redirect kept for projects that already registered it in Supabase.
const String kLegacyOAuthRedirectUrl = 'myflutterapp://login-callback';

/// Returns the appropriate OAuth redirect URL for the current platform.
/// On Web, returns the running web origin (e.g. http://localhost:52058/).
/// On Mobile/Desktop, returns the custom app deep-link URI.
String getOAuthRedirectUrl() {
  if (kIsWeb) {
    final origin = Uri.base.origin;
    return origin.endsWith('/') ? origin : '$origin/';
  }
  return kOAuthRedirectUrl;
}

/// Returns true when [uri] is a Supabase OAuth callback for this app.
bool isOAuthCallbackUri(Uri uri) {
  final fragmentParams = Uri.splitQueryString(uri.fragment);
  bool hasAuthParam(String key) =>
      uri.queryParameters.containsKey(key) ||
      fragmentParams.containsKey(key);

  final hasAuth = hasAuthParam('code') ||
      hasAuthParam('access_token') ||
      hasAuthParam('error') ||
      hasAuthParam('error_code') ||
      hasAuthParam('error_description');

  if (!hasAuth) return false;

  // On Web, any incoming redirect from the app origin containing auth parameters is a valid callback.
  if (kIsWeb) return true;

  // On Mobile, verify against the custom deep-link schemes.
  final isAppRedirect = uri.scheme == 'com.sahay.mumbai_pool_transit' &&
      uri.host == 'login-callback';
  final isLegacyRedirect =
      uri.scheme == 'myflutterapp' && uri.host == 'login-callback';

  return isAppRedirect || isLegacyRedirect;
}

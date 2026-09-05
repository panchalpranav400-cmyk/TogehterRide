import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../supabase_client.dart';
import '../constants/app_config.dart';

class AuthService {
  static SupabaseClient get _supabase => Supabase.instance.client;

  static bool _googleSignInInitialized = false;

  static bool get isLoggedIn => _supabase.auth.currentSession != null;

  static Map<String, dynamic>? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return {
      'id': user.id,
      'email': user.email,
      'name': user.userMetadata?['name'] ??
          user.userMetadata?['full_name'] ??
          user.email?.split('@')[0] ??
          '',
    };
  }

  static String? get accessToken => _supabase.auth.currentSession?.accessToken;

  static bool get _useNativeGoogleSignIn =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Creates a new account with email, password, and name using Supabase Auth.
  /// Profile creation is handled automatically by the handle_new_user() DB trigger.
  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim()},
      );

      final user = response.user;
      if (user != null) {
        return {
          'success': true,
          'message': 'Account created successfully!',
          'user': {
            'id': user.id,
            'email': user.email,
          },
        };
      } else {
        return {
          'success': true,
          'message': 'Please check your email to confirm your account.',
          'needsConfirmation': true,
        };
      }
    } on AuthException catch (e) {
      debugPrint('Supabase signUp error: $e');
      String message;
      if (e.message.contains('already registered')) {
        message = 'An account with this email already exists. Please log in.';
      } else if (e.message.contains('password')) {
        message = 'Password must be at least 6 characters.';
      } else {
        message = e.message;
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      debugPrint('Supabase signUp error: $e');
      return {
        'success': false,
        'message': 'Sign up failed. Please try again.',
      };
    }
  }

  /// Signs in with email and password using Supabase Auth.
  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = response.user;
      if (user != null) {
        return {
          'success': true,
          'message': 'Welcome back!',
          'user': {
            'id': user.id,
            'email': user.email,
          },
        };
      } else {
        return {
          'success': false,
          'message': 'Login failed. Please try again.',
        };
      }
    } on AuthException catch (e) {
      debugPrint('Supabase signIn error: $e');
      String message = 'Login failed';
      if (e.message.contains('Invalid login credentials')) {
        message = 'Invalid email or password. Please try again.';
      } else if (e.message.contains('Email not confirmed')) {
        message = 'Please confirm your email before logging in.';
      } else {
        message = e.message;
      }
      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      debugPrint('Supabase signIn error: $e');
      return {
        'success': false,
        'message': 'Login failed: $e',
      };
    }
  }

  /// Signs in with Google.
  ///
  /// On Android/iOS this uses the native [google_sign_in] SDK plus
  /// [GoTrueClient.signInWithIdToken] (recommended by Supabase).
  /// On Web or if native is unavailable/fails, it uses browser OAuth + redirect.
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    if (AppConfig.supabaseUrl.contains('YOUR_') ||
        AppConfig.supabaseAnonKey.contains('YOUR_')) {
      return {
        'success': false,
        'message':
            'Supabase is not configured. Set AppConfig.supabaseUrl and supabaseAnonKey.',
      };
    }

    if (_useNativeGoogleSignIn && !_isGoogleNativeConfigured) {
      return _signInWithGoogleOAuth();
    }

    if (_useNativeGoogleSignIn) {
      final nativeResult = await _signInWithGoogleNative();
      // If native sign-in succeeded or was deliberately cancelled by user, return it
      if (nativeResult['success'] == true ||
          nativeResult['message'] == 'Google sign-in was cancelled.') {
        return nativeResult;
      }
      // If native sign-in failed (e.g. SHA-1 or client ID not set up on device),
      // seamlessly fall back to browser OAuth flow so user can still log in
      debugPrint(
        'Native Google sign-in failed (${nativeResult['message']}). Falling back to OAuth browser flow...',
      );
      return _signInWithGoogleOAuth();
    }

    return _signInWithGoogleOAuth();
  }

  static bool get _isGoogleNativeConfigured =>
      !AppConfig.googleWebClientId.contains('YOUR_');

  static Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;

    if (AppConfig.googleWebClientId.contains('YOUR_')) {
      throw const AuthException(
        'Set AppConfig.googleWebClientId to your Google Cloud Web Client ID.',
      );
    }

    await GoogleSignIn.instance.initialize(
      serverClientId: AppConfig.googleWebClientId,
      clientId: defaultTargetPlatform == TargetPlatform.iOS
          ? (AppConfig.googleIosClientId.contains('YOUR_')
              ? null
              : AppConfig.googleIosClientId)
          : null,
    );

    _googleSignInInitialized = true;
  }

  static Future<Map<String, dynamic>> _signInWithGoogleNative() async {
    const scopes = ['email', 'profile'];

    try {
      await _ensureGoogleSignInInitialized();

      final googleSignIn = GoogleSignIn.instance;
      final googleUser = await googleSignIn.authenticate(
        scopeHint: scopes,
      );

      final authorization =
          await googleUser.authorizationClient.authorizationForScopes(scopes) ??
              await googleUser.authorizationClient.authorizeScopes(scopes);

      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        return {
          'success': false,
          'message': 'Google did not return an ID token. Check your Web Client ID.',
        };
      }

      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: authorization.accessToken,
      );

      return {
        'success': true,
        'authenticated': true,
        'message': 'Welcome!',
      };
    } on GoogleSignInException catch (e) {
      debugPrint('Google sign-in error: $e');
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return {
          'success': false,
          'message': 'Google sign-in was cancelled.',
        };
      }
      return {
        'success': false,
        'message':
            'Google sign-in failed (${e.code.name}). Verify your Google Cloud OAuth client IDs and SHA-1 fingerprint.',
      };
    } on AuthException catch (e) {
      debugPrint('Supabase Google sign-in error: ${e.message}');
      return {
        'success': false,
        'message': _friendlyOAuthMessage(e.message),
      };
    } catch (e) {
      debugPrint('Native Google sign-in error: $e');
      return {
        'success': false,
        'message': 'Google sign-in failed. Please try again.',
      };
    }
  }

  static Future<Map<String, dynamic>> _signInWithGoogleOAuth() async {
    try {
      final redirectUrl = getOAuthRedirectUrl();
      debugPrint('Starting Supabase Google OAuth with redirectTo: $redirectUrl');

      final launched = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        authScreenLaunchMode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );

      if (launched) {
        return {
          'success': true,
          'authenticated': false,
          'message': kIsWeb
              ? 'Redirecting to Google sign-in...'
              : 'Complete sign-in in your browser.',
        };
      }

      return {
        'success': false,
        'message':
            'Could not open the browser. Check that a browser is installed and try again.',
      };
    } on AuthException catch (e) {
      debugPrint('Supabase Google sign-in error: ${e.message}');
      return {
        'success': false,
        'message': _friendlyOAuthMessage(e.message),
      };
    } catch (e) {
      debugPrint('Supabase Google sign-in error: $e');
      return {
        'success': false,
        'message': 'Google sign-in failed. Please try again.',
      };
    }
  }

  static String _friendlyOAuthMessage(String message) {
    if (message.contains('Provider') && message.contains('not enabled')) {
      return 'Google sign-in is not enabled in Supabase. Enable it under Authentication → Providers.';
    }
    if (message.contains('redirect') || message.contains('Redirect')) {
      final currentRedirect = getOAuthRedirectUrl();
      return 'Redirect URL not allowed. Add $currentRedirect in Supabase → Authentication → URL Configuration.';
    }
    if (message.contains('Web Client ID')) {
      return message;
    }
    return message;
  }

  /// Logs out the user and clears all credentials
  static Future<void> signOut() async {
    try {
      if (_googleSignInInitialized) {
        await GoogleSignIn.instance.signOut();
      }
      await _supabase.auth.signOut();
    } catch (_) {}
  }
}

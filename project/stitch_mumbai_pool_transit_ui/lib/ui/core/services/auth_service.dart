import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _supabase = Supabase.instance.client;

  static bool get isLoggedIn => _supabase.auth.currentSession != null;
  
  static Map<String, dynamic>? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return {
      'id': user.id,
      'email': user.email,
      'name': user.userMetadata?['name'] ?? user.email?.split('@')[0] ?? '',
    };
  }
  
  static String? get accessToken => _supabase.auth.currentSession?.accessToken;

  /// Sends a 6-digit OTP code to the user's email address using Supabase Auth
  static Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      // emailRedirectTo: null disables magic-link mode and forces Supabase
      // to send a 6-digit numeric OTP token to the user's email instead.
      await _supabase.auth.signInWithOtp(
        email: email.trim(),
        shouldCreateUser: true,
        emailRedirectTo: null,
      );
      return {
        'success': true,
        'message': 'A 6-digit code has been sent to $email',
      };
    } catch (e) {
      debugPrint('Supabase sendOtp error: $e');
      return {
        'success': false,
        'message': 'Failed to send OTP: $e',
      };
    }
  }

  /// Verifies the 6-digit OTP and establishes a Supabase session
  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.email,
        email: email.trim(),
        token: otp.trim(),
      );

      final user = response.user;
      if (user != null) {
        // Upsert a basic profile in the profiles table to ensure database has an entry for the user
        await _supabase.from('profiles').upsert({
          'id': user.id,
          'name': user.email?.split('@')[0] ?? 'User',
          'role': 'passenger', // default
          'phone': '',
          'rating': '5.0',
          'is_verified': false,
        });

        return {
          'success': true,
          'message': 'Successfully authenticated!',
          'user': {
            'id': user.id,
            'email': user.email,
          },
        };
      } else {
        return {
          'success': false,
          'message': 'Verification failed: User not created',
        };
      }
    } catch (e) {
      debugPrint('Supabase verifyOtp error: $e');
      return {
        'success': false,
        'message': 'Verification error: $e',
      };
    }
  }

  /// Logs out the user and clears all credentials
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {}
  }
}

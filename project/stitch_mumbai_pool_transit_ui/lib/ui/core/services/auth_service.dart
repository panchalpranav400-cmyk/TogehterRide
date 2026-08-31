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
        // Pass name in metadata — the handle_new_user() trigger reads this
        data: {'name': name.trim()},
      );

      final user = response.user;
      if (user != null) {
        // Profile is created automatically by the handle_new_user() DB trigger.
        // No client-side upsert needed — avoids RLS race condition.
        return {
          'success': true,
          'message': 'Account created successfully!',
          'user': {
            'id': user.id,
            'email': user.email,
          },
        };
      } else {
        // Happens when email confirmation is enabled in Supabase Dashboard
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

  /// Logs out the user and clears all credentials
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (_) {}
  }
}

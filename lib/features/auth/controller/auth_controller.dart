import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_x/core/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';

final _logger = Logger('AuthController');

class AuthController {
  Future<bool> verifyDatabaseSchema() async {
    try {
      await SupabaseConfig.client
          .from('profiles')
          .select('id, username, email, created_at, updated_at')
          .limit(1);
      return true;
    } catch (e) {
      if (e is PostgrestException) {
        if (e.message.contains('column profiles.username does not exist') ||
            e.message.contains('column profiles.email does not exist')) {
          _logger.severe('Database schema is missing required columns. Please run the SQL migration script.');
          return false;
        }
      }
      _logger.severe('Error verifying database schema', e);
      return false;
    }
  }

  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final isSchemaValid = await verifyDatabaseSchema();
      if (!isSchemaValid) {
        return 'Database configuration error: profiles table is missing required columns. Please contact support.';
      }

      final existingProfile = await SupabaseConfig.client
          .from('profiles')
          .select('id')
          .eq('username', username)
          .maybeSingle();
      
      if (existingProfile != null) {
        return 'Username is already taken';
      }

      final response = await SupabaseConfig.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
        },
      );

      if (response.user != null) {
        try {
          final profileData = {
            'id': response.user!.id,
            'email': email,
            'username': username,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          };

          _logger.info('Creating profile with data: $profileData');

          // Use upsert to handle potential conflicts
          await SupabaseConfig.client
              .from('profiles')
              .upsert(profileData, onConflict: 'id')
              .select()
              .single();
          
          _logger.info('User signed up successfully: ${response.user!.id}');
          return null;
        } catch (profileError) {
          _logger.severe('Profile creation error', profileError);
          // Don't try to delete the auth user as it requires admin privileges
          if (profileError is PostgrestException) {
            if (profileError.code == '23505') {
              return 'A profile with this ID already exists. Please try signing in instead.';
            }
            if (profileError.message.contains('column profiles.username does not exist') ||
                profileError.message.contains('column profiles.email does not exist')) {
              return 'Database configuration error: profiles table is missing required columns. Please contact support.';
            }
            return 'Database error: ${profileError.message}';
          }
          return 'Failed to create profile: ${profileError.toString()}';
        }
      }
      return 'Failed to create account';
    } catch (e) {
      _logger.severe('Sign up error', e);
      if (e is AuthException) {
        if (e.message.contains('not_admin')) {
          return 'Signup is currently disabled. This could be because:\n'
              '1. Email signup is disabled in the project settings\n'
              '2. Your email domain is not allowed\n'
              '3. The project is in admin-only mode\n\n'
              'Please contact support or try using a different email address.';
        }
        if (e.message.contains('Email not confirmed')) {
          return 'Please check your email for a confirmation link before signing in.';
        }
        return e.message;
      }
      return 'An error occurred during signup. Please try again.';
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await SupabaseConfig.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        _logger.info('User logged in successfully: ${response.user!.id}');
        return null;
      }
      return 'Invalid credentials';
    } catch (e) {
      _logger.severe('Login error', e);
      return e.toString();
    }
  }

  Future<void> logout() async {
    try {
      await SupabaseConfig.client.auth.signOut();
      _logger.info('User logged out successfully');
    } catch (e) {
      _logger.severe('Logout error', e);
      rethrow;
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await SupabaseConfig.client.auth.resetPasswordForEmail(email);
      _logger.info('Password reset email sent to: $email');
      return null;
    } catch (e) {
      _logger.severe('Password reset error', e);
      return e.toString();
    }
  }

  Future<String?> updatePassword(String newPassword) async {
    try {
      await SupabaseConfig.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      _logger.info('Password updated successfully');
      return null;
    } catch (e) {
      _logger.severe('Password update error', e);
      return e.toString();
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) return null;

      final profile = await SupabaseConfig.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      
      return profile;
    } catch (e) {
      _logger.severe('Get profile error', e);
      return null;
    }
  }

  Future<String?> updateProfile(Map<String, dynamic> updates) async {
    try {
      final user = SupabaseConfig.client.auth.currentUser;
      if (user == null) return 'Not authenticated';

      await SupabaseConfig.client
          .from('profiles')
          .update(updates)
          .eq('id', user.id);
      
      _logger.info('Profile updated successfully');
      return null;
    } catch (e) {
      _logger.severe('Profile update error', e);
      return e.toString();
    }
  }
}

final authControllerProvider = Provider<AuthController>((ref) => AuthController());

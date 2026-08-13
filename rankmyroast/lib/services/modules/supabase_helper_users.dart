import 'package:rankmyroast/services/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHelperUsers {
  static final _client = Supabase.instance.client;

  String? getAuthId() {
    final authId = _client.auth.currentUser?.id;

    if (authId == null) {
      throw Exception("User not logged in");
    }
    return authId;
  }

  Future<void> addUser() async {
    final authId = _client.auth.currentUser?.id;

    if (authId != null) {
      final existingUser =
          await _client
              .from("user")
              .select("*")
              .eq("auth_id", authId)
              .maybeSingle();

      if (existingUser?["auth_id"] != null) {
        return;
      }

      try {
        await _client.from("user").insert({"auth_id": authId});
      } on Exception catch (e) {
        await SupabaseHelper.logging.logEvent(
          type: 'error',
          location: 'supabase_helper_users.dart:33',
          content:
              'Attempted to add a user row for auth_id=$authId to the user table. Error: ${e.toString()}',
        );
      }
    }
  }

  Future<bool> checkForUsername() async {
    final authId = _client.auth.currentUser?.id;
    if (authId != null) {
      try {
        final response =
            await _client
                .from("user")
                .select("username")
                .eq("auth_id", authId)
                .maybeSingle();
        final username = response?["username"];
        if (username == null) {
          return false;
        } else {
          return true;
        }
      } on Exception catch (e) {
        await SupabaseHelper.logging.logEvent(
          type: 'error',
          location: 'supabase_helper_users.dart:61',
          content:
              'Attempted to check whether the current user has a username populated in the user table. Error: ${e.toString()}',
        );
        return false;
      }
    }
    throw Exception("User not logged in");
  }

  Future<bool> checkUsernameUniqueness(final String username) async {
    final authId = _client.auth.currentUser?.id;
    if (authId != null) {
      try {
        final response =
            await _client
                .from("user")
                .select("username")
                .eq("username", username)
                .maybeSingle();

        if (response?["username"] != null) {
          return false;
        }
        return true;
      } on Exception catch (e) {
        await SupabaseHelper.logging.logEvent(
          type: 'error',
          location: 'supabase_helper_users.dart:78',
          content:
              'Attempted to validate whether the username "$username" is already in use. Error: ${e.toString()}',
        );
        return false;
      }
    }
    throw Exception("User not logged in");
  }

  Future<bool> setUsername(final String username) async {
    final authId = _client.auth.currentUser?.id;
    if (authId != null) {
      try {
        final response =
            await _client
                .from("user")
                .update({"username": username})
                .eq("auth_id", authId)
                .select()
                .single();

        if (response["username"] != null) {
          return true;
        }
        return false;
      } on Exception catch (e) {
        await SupabaseHelper.logging.logEvent(
          type: 'error',
          location: 'supabase_helper_users.dart:102',
          content:
              'Attempted to set the current user\'s username to "$username" in the user table. Error: ${e.toString()}',
        );
        return false;
      }
    }
    throw Exception("User not logged in");
  }

  Future<String?> getUsername() async {
    final authId = _client.auth.currentUser?.id;
    if (authId != null) {
      try {
        final response =
            await _client
                .from("user")
                .select("username")
                .eq("auth_id", authId)
                .maybeSingle();

        return response?["username"];
      } on Exception catch (e) {
        await SupabaseHelper.logging.logEvent(
          type: 'error',
          location: 'supabase_helper_users.dart:122',
          content:
              'Attempted to read the current user\'s username from the user table. Error: ${e.toString()}',
        );
        return null;
      }
    }
    throw Exception("User not logged in");
  }
}

import 'package:rankmyroast/classes/modals/schedule.dart';
import 'package:rankmyroast/services/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHelperSchedule {
  static final _client = Supabase.instance.client;

  Future<List<Schedule>?> getAllScheduledEventsForUser() async {
    try {
      final response = await _client
          .from("schedule")
          .select(
            "*, recipe (id, created_at, name, ingredients, instructions, groceries, prep_time, cook_time, is_public, image_name), group (id, created_at, name, user_id, grade_visible, use_rating, is_personal_group)",
          );

      return response.map((toElement) => Schedule.fromMap(toElement)).toList();
    } on Exception catch (e) {
      await SupabaseHelper.logging.logEvent(
        type: 'error',
        location: 'supabase_helper_schedule.dart:18',
        content:
            'Attempted to load scheduled events for the current user from the schedule table. Error: ${e.toString()}',
      );
      return null;
    }
  }

  Future<bool?> createScheduledEvent(
    String groupId,
    String recipeId,
    String notes,
    DateTime servedAt,
  ) async {
    try {
      final userId = SupabaseHelper.users.getAuthId();

      final response =
          await _client
              .from("schedule")
              .insert({
                "group_id": groupId,
                "recipe_id": recipeId,
                "served_at": servedAt.toIso8601String(),
                "notes": notes,
                "user_id": userId,
              })
              .select("id")
              .single();

      if (response["id"] == null) {
        await SupabaseHelper.logging.logEvent(
          type: 'error',
          location: 'supabase_helper_schedule.dart:41',
          content:
              'Attempted to create a scheduled event for group_id=$groupId, recipe_id=$recipeId, served_at=${servedAt.toIso8601String()}. The insert returned no id, so the database rejected the create request.',
        );
        return false;
      }

      return true;
    } on Exception catch (e) {
      await SupabaseHelper.logging.logEvent(
        type: 'error',
        location: 'supabase_helper_schedule.dart:50',
        content:
            'Attempted to create a scheduled event for group_id=$groupId, recipe_id=$recipeId, served_at=${servedAt.toIso8601String()}. Error: ${e.toString()}',
      );
      return null;
    }
  }

  Future<bool?> deleteScheduledEvent(int scheduleId) async {
    try {
      await _client.from("schedule").delete().eq("id", scheduleId);

      return true;
    } on Exception catch (e) {
      await SupabaseHelper.logging.logEvent(
        type: 'error',
        location: 'supabase_helper_schedule.dart:64',
        content:
            'Attempted to delete scheduled event id=$scheduleId from the schedule table. Error: ${e.toString()}',
      );
      return null;
    }
  }

  Future<bool?> updateScheduledEvent(
    int scheduleId,
    DateTime newServedAt,
    String newRecipeId,
    String newGroupId,
    String newNotes,
  ) async {
    try {
      final response =
          await _client
              .from("schedule")
              .update({
                "served_at": newServedAt.toIso8601String(),
                "recipe_id": newRecipeId,
                "group_id": newGroupId,
                "notes": newNotes,
              })
              .eq("id", scheduleId)
              .select(); // <--- Forces Supabase to return the modified row(s)

      // If the list is empty, no row matched the ID or RLS denied it
      if ((response as List).isEmpty) {
        await SupabaseHelper.logging.logEvent(
          type: 'error',
          location: 'supabase_helper_schedule.dart:86',
          content:
              'Attempted to update scheduled event id=$scheduleId with served_at=${newServedAt.toIso8601String()}, recipe_id=$newRecipeId, group_id=$newGroupId. The update affected 0 rows, so the ID may be invalid or the RLS policy blocked the change.',
        );
        return false;
      }

      return true;
    } catch (e) {
      await SupabaseHelper.logging.logEvent(
        type: 'error',
        location: 'supabase_helper_schedule.dart:100',
        content:
            'Attempted to update scheduled event id=$scheduleId with served_at=${newServedAt.toIso8601String()}, recipe_id=$newRecipeId, group_id=$newGroupId, notes=$newNotes. Error: ${e.toString()}',
      );
      return null;
    }
  }
}

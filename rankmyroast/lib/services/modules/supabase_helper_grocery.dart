import 'package:rankmyroast/classes/modals/grocery.dart';
import 'package:rankmyroast/services/supabase_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHelperGrocery {
  static final _client = Supabase.instance.client;

  Future<List<Grocery>?> getGroceriesByGroupId(String groupId) async {
    try {
      final response = await _client
          .from('grocery')
          .select()
          .eq('group_id', groupId);

      return response
          .map<Grocery>((grocery) => Grocery.fromMap(grocery))
          .toList();
    } on Exception catch (e) {
      SupabaseHelper.logging.logEvent(
        type: "error",
        location: "supabase_helper_grocery.dart:08",
        content: "Error getting groceries by group id: $e",
      );
    }
  }

  Future<List<Grocery>?> getGroceriesForUser() async {
    try {
      final response = await _client.from('grocery').select("*");

      return response
          .map<Grocery>((grocery) => Grocery.fromMap(grocery))
          .toList();
    } on Exception catch (e) {
      SupabaseHelper.logging.logEvent(
        type: "error",
        location: "supabase_helper_grocery.dart:08",
        content: "Error getting groceries by group id: $e",
      );
    }
  }

  Future<bool?> insertGrocery(List<Grocery> groceries) async {
    try {
      final response = await _client.from('grocery').insert(groceries).select();

      if (response.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on Exception catch (e) {
      SupabaseHelper.logging.logEvent(
        type: "error",
        location: "supabase_helper_grocery.dart:27",
        content: "Error inserting grocery: $e",
      );
    }
  }

  Future<bool?> updateGrocery(Grocery grocery) async {
    try {
      final response =
          await _client
              .from('grocery')
              .update({"item": grocery.item, "completed": grocery.completed})
              .eq("id", grocery.id)
              .select();

      if (response.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on Exception catch (e) {
      SupabaseHelper.logging.logEvent(
        type: "error",
        location: "supabase_helper_grocery.dart:45",
        content: "Error updating grocery: $grocery. error: $e",
      );
    }
  }

  Future<bool?> deleteGrocery(Grocery grocery) async {
    try {
      await _client.from('grocery').delete().eq("id", grocery.id);

      final response = await _client
          .from("grocery")
          .select("*")
          .eq("id", grocery.id);

      if (response.isEmpty) {
        return true;
      } else {
        return false;
      }
    } on Exception catch (e) {
      SupabaseHelper.logging.logEvent(
        type: "error",
        location: "supabase_helper_grocery.dart:68",
        content: "Error deleting grocery: $grocery. error: $e",
      );
    }
  }
}

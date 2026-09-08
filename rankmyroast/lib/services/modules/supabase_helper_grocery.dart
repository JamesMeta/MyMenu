import 'package:rankmyroast/classes/modals/grocery.dart';
import 'package:rankmyroast/classes/modals/grocery_list.dart';
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
        location: "supabase_helper_grocery.dart:09",
        content: "Error getting groceries by group id: $e",
      );
      return null;
    }
  }

  Future<List<GroceryList>?> getGroceriesForUser() async {
    try {
      final response = await _client.from('grocery_list').select('''
      *,
      grocery (*)
    ''');

      return response
          .map((groceryList) => GroceryList.fromMap(groceryList))
          .toList();
    } on Exception catch (e) {
      SupabaseHelper.logging.logEvent(
        type: "error",
        location: "supabase_helper_grocery.dart:29",
        content: "Error getting groceries by user: $e",
      );
      return null;
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
        location: "supabase_helper_grocery.dart:49",
        content: "Error inserting grocery: $e",
      );
      return null;
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
        location: "supabase_helper_grocery.dart:68",
        content: "Error updating grocery: $grocery. error: $e",
      );
      return null;
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
        location: "supabase_helper_grocery.dart:92",
        content: "Error deleting grocery: $grocery. error: $e",
      );
      return null;
    }
  }

  Future<bool?> createGroceryList(String name, String? groupId) async {
    try {
      late List<Map<String, dynamic>> response;

      if (groupId == null) {
        response =
            await _client.from('grocery_list').insert({
              'name': name,
              'user_id': SupabaseHelper.users.getAuthId(),
            }).select();
      } else {
        response =
            await _client.from('grocery_list').insert({
              'name': name,
              'group_id': groupId,
            }).select();
      }

      if (response.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on Exception catch (e) {
      SupabaseHelper.logging.logEvent(
        type: "error",
        location: "supabase_helper_grocery.dart:116",
        content: "Error creating grocery list: $name. error: $e",
      );
      return null;
    }
  }
}

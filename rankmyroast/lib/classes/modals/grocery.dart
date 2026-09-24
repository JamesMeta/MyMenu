import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Grocery {
  final int id;
  String item;
  bool completed;
  final String groceryListId;

  Grocery({
    required this.id,
    required this.item,
    required this.completed,
    required this.groceryListId,
  });

  factory Grocery.fromMap(Map<String, dynamic> map) {
    return Grocery(
      id: map['id'] ?? 0,
      item: map['item'] ?? '',
      completed: map['completed'] ?? false,
      groceryListId: map['grocery_list_id'] ?? '',
    );
  }

  @override
  String toString() {
    return "Grocery($id, $item, $completed, $groceryListId)";
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item': item,
      'completed': completed,
      'grocery_list_id': groceryListId,
    };
  }
}

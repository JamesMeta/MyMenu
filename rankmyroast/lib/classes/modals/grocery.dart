import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Grocery {
  final int id;
  final String item;
  final bool completed;
  final String groupId;

  Grocery({
    required this.id,
    required this.item,
    required this.completed,
    required this.groupId,
  });

  factory Grocery.fromMap(Map<String, dynamic> map) {
    return Grocery(
      id: map['id'] ?? 0,
      item: map['item'] ?? '',
      completed: map['completed'] ?? false,
      groupId: map['group_id'] ?? '',
    );
  }

  @override
  String toString() {
    return "Grocery($id, $item, $completed, $groupId)";
  }
}

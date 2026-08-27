import 'package:rankmyroast/classes/modals/grocery.dart';

class GroceryList {
  final String id;
  final String name;
  final String? groupId;
  final String userId;
  final List<Grocery> groceryList;

  GroceryList({
    required this.id,
    required this.name,
    this.groupId,
    required this.userId,
    required this.groceryList,
  });

  factory GroceryList.fromMap(Map<String, dynamic> map) {
    return GroceryList(
      id: map['id'],
      name: map['name'],
      groupId: map['group_id'],
      userId: map['user_id'],
      groceryList:
          map['grocery']
              .map<Grocery>((grocery) => Grocery.fromMap(grocery))
              .toList(),
    );
  }
}

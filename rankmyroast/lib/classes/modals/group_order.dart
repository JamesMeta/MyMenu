// ignore_for_file: non_constant_identifier_names

class GroupOrder {
  final int id;
  final String groupId;
  final int group_index;

  GroupOrder({
    required this.id,
    required this.groupId,
    required this.group_index,
  });

  factory GroupOrder.fromMap(Map<String, dynamic> map) {
    return GroupOrder(
      id: map['id'],
      groupId: map['group_id'],
      group_index: map['group_index'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'group_id': groupId, 'group_index': group_index};
  }
}

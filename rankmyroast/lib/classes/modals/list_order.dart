class ListOrder {
  final String listId;
  final DateTime lastUpdated;

  ListOrder({required this.listId, required this.lastUpdated});

  factory ListOrder.fromMap(Map<String, dynamic> map) {
    return ListOrder(
      listId: map['list_id'],
      lastUpdated: DateTime.parse(map['last_updated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {'list_id': listId, 'last_updated': lastUpdated.toIso8601String()};
  }
}

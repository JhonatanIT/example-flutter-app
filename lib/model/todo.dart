class Todo {
  final int id;
  final String title;

  final String createdAt;
  final String? updatedAt;

  Todo(
      {required this.id,
      required this.title,
      required this.createdAt,
      this.updatedAt});

  // Convert a Todo into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt,
      'updatedAt': updatedAt
    };
  }

  // Implement toString to make it easier to see information about
  // each todo when using the print statement.
  @override
  String toString() {
    return 'Todo{id: $id, title: $title, createdAt: $createdAt, updatedAt: $updatedAt}';
  }

  factory Todo.fromSqfliteDatabase(Map<String, dynamic> map) => Todo(
        id: map['id']?.toInt() ?? 0,
        title: map['title'] ?? '',
        createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'])
            .toIso8601String(),
        updatedAt: map['updated_at'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(map['updated_at'])
                .toIso8601String(),
      );
}

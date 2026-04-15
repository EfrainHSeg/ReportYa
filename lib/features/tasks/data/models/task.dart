class Task {
  final String id;
  final String title;
  final String? description;
  final String status;
  final String? dueDate;
  final String? assignedToName;

  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    this.dueDate,
    this.assignedToName,
  });

  factory Task.fromRow(Map<String, dynamic> row) {
    final profile = row['profiles'] as Map<String, dynamic>?;
    return Task(
      id:             row['id'] as String,
      title:          row['title'] as String? ?? '',
      description:    row['description'] as String?,
      status:         row['status'] as String? ?? 'pending',
      dueDate:        row['due_date'] as String?,
      assignedToName: profile?['full_name'] as String?,
    );
  }
}

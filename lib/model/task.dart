class Task {
  final int id;
  final String marketName;
  final String address;
  final String taskType;
  final String dueDate;
  final String frequency;
  final String status;

  Task({
    required this.id,
    required this.marketName,
    required this.address,
    required this.taskType,
    required this.dueDate,
    required this.frequency,
    required this.status,
  });
}
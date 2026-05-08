class UpdateTaskDto {
  final int? storeId;
  final int? userId;
  final int? taskType; // String? yerine tekrar int? yapıyoruz
  final int? priority; // String? yerine tekrar int? yapıyoruz
  final String? dueDate;
  final String? description;
  final int? status;   // String? yerine tekrar int? yapıyoruz

  UpdateTaskDto({
    this.storeId,
    this.userId,
    this.taskType,
    this.priority,
    this.dueDate,
    this.description,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (storeId != null) data['storeId'] = storeId;
    if (userId != null) data['userId'] = userId;
    if (taskType != null) data['taskType'] = taskType;
    if (priority != null) data['priority'] = priority;
    if (dueDate != null) data['dueDate'] = dueDate;
    if (description != null) data['description'] = description;
    if (status != null) data['status'] = status;

    return data;
  }
}
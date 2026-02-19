class TaskDto {
  final int? id;
  final int? storeId;
  final String? storeName;
  final String? storeAddress;
  final double? latitude;
  final double? longitude;
  final String? taskType;
  final String? priority;
  final String? status;
  final String? dueDate;
  final String? description;
  final int? assigneeId;
  final String? assigneeName;

  TaskDto({
    this.id,
    this.storeId,
    this.storeName,
    this.storeAddress,
    this.latitude,
    this.longitude,
    this.taskType,
    this.priority,
    this.status,
    this.dueDate,
    this.description,
    this.assigneeId,
    this.assigneeName,
  });

  factory TaskDto.fromJson(Map<String, dynamic> json) {
    return TaskDto(
      id: json['id'] as int?,
      storeId: json['storeId'] as int?,
      storeName: json['storeName'] as String?,
      storeAddress: json['storeAddress'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      taskType: json['taskType'] as String?,
      priority: json['priority'] as String?,
      status: json['status'] as String?,
      dueDate: json['dueDate'] as String?,
      description: json['description'] as String?,
      assigneeId: json['assigneeId'] as int?,
      assigneeName: json['assigneeName'] as String?,
    );
  }
}
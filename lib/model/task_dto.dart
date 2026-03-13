class TaskDto {
  final int? id;
  final int? storeId;      // Eksik olan alan eklendi
  final int? userId;       // HATA VEREN EKSİK ALAN EKLENDİ
  final String? storeName;
  final String? storeAddress;
  final double? latitude;
  final double? longitude;
  final String? taskType;
  final String? priority;
  final String? status;
  final String? dueDate;
  final String? description;
  final String? completedAt;

  TaskDto({
    this.id,
    this.storeId,
    this.userId,
    this.storeName,
    this.storeAddress,
    this.latitude,
    this.longitude,
    this.taskType,
    this.priority,
    this.status,
    this.dueDate,
    this.description,
    this.completedAt,
  });

  factory TaskDto.fromJson(Map<String, dynamic> json) {
    return TaskDto(
      id: json['id'],
      storeId: json['storeId'],
      userId: json['userId'], // JSON'dan okuma eklendi
      storeName: json['storeName'] ?? json['marketName'],
      storeAddress: json['storeAddress'] ?? json['address'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      taskType: json['taskType'],
      priority: json['priority'],
      status: json['status'],
      dueDate: json['dueDate'],
      description: json['description'],
      completedAt: json['completedAt'],
    );
  }
}
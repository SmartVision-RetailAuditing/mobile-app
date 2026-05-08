class Task {
  final int id;
  final int? storeId;
  final int? userId;
  final String? storeName;     // Eski marketName yerine backend'e uyumlu isim
  final String? storeAddress;  // Eski address yerine backend'e uyumlu isim
  final double? latitude;      // Harita butonu için gerekli
  final double? longitude;     // Harita butonu için gerekli
  final String? taskType;
  final String? priority;      // Yeni eklendi (LOW, MEDIUM, HIGH)
  final String? status;
  final String? dueDate;
  final String? description;   // Yeni eklendi
  final String? completedAt;   // Yeni eklendi

  Task({
    required this.id,
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

  // Backend'den gelen JSON verisini Task nesnesine çeviren fabrika metodu
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? 0,
      storeId: json['storeId'],
      userId: json['userId'],
      // Geriye dönük uyumluluk veya farklı isimlendirmeler için yedekli okuma yapabiliriz:
      storeName: json['storeName'] ?? json['marketName'],
      storeAddress: json['storeAddress'] ?? json['address'],
      // Koordinatları double'a güvenli çevirme:
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
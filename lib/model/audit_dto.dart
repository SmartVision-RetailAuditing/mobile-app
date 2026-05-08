import 'audit_product_dto.dart';
import 'audit_issue_dto.dart';

class AuditDto {
  final int id;
  final String storeName;
  final String taskType;
  final DateTime captureDate;
  final double complianceScore;
  final double shelfSharePercentage;
  final String status;
  final String? brandDistributionJson;
  final String? preImageUrl;
  final String? postImageUrl;
  final List<AuditProductDto> products;
  final List<AuditIssueDto> issues;

  AuditDto({
    required this.id,
    required this.storeName,
    required this.taskType,
    required this.captureDate,
    required this.complianceScore,
    required this.shelfSharePercentage,
    required this.status,
    this.brandDistributionJson,
    this.preImageUrl,
    this.postImageUrl,
    required this.products,
    required this.issues,
  });

  factory AuditDto.fromJson(Map<String, dynamic> json) {
    return AuditDto(
      id: json['id'] ?? 0,
      storeName: json['storeName'] ?? '',
      taskType: json['taskType'] ?? '',
      captureDate: json['captureDate'] != null
          ? DateTime.parse(json['captureDate'])
          : DateTime.now(),
      complianceScore: (json['complianceScore'] as num?)?.toDouble() ?? 0.0,
      shelfSharePercentage: (json['shelfSharePercentage'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      brandDistributionJson: json['brandDistributionJson'],
      preImageUrl: json['preImageUrl'],
      postImageUrl: json['postImageUrl'],
      products: json['products'] != null
          ? (json['products'] as List).map((p) => AuditProductDto.fromJson(p)).toList()
          : [],
      issues: json['issues'] != null
          ? (json['issues'] as List).map((i) => AuditIssueDto.fromJson(i)).toList()
          : [],
    );
  }

  // --- RIVERPOD VE STATE GÜNCELLEMELERİ İÇİN KRİTİK METOD ---
  AuditDto copyWith({
    int? id,
    String? storeName,
    String? taskType,
    DateTime? captureDate,
    double? complianceScore,
    double? shelfSharePercentage,
    String? status,
    String? brandDistributionJson,
    String? preImageUrl,
    String? postImageUrl,
    List<AuditProductDto>? products,
    List<AuditIssueDto>? issues,
  }) {
    return AuditDto(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      taskType: taskType ?? this.taskType,
      captureDate: captureDate ?? this.captureDate,
      complianceScore: complianceScore ?? this.complianceScore,
      shelfSharePercentage: shelfSharePercentage ?? this.shelfSharePercentage,
      status: status ?? this.status,
      brandDistributionJson: brandDistributionJson ?? this.brandDistributionJson,
      preImageUrl: preImageUrl ?? this.preImageUrl,
      postImageUrl: postImageUrl ?? this.postImageUrl,
      products: products ?? this.products,
      issues: issues ?? this.issues,
    );
  }
}
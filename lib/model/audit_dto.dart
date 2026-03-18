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
      products: json['products'] != null
          ? (json['products'] as List).map((p) => AuditProductDto.fromJson(p)).toList()
          : [],
      issues: json['issues'] != null
          ? (json['issues'] as List).map((i) => AuditIssueDto.fromJson(i)).toList()
          : [],
    );
  }
}
class AuditIssueDto {
  final int id;
  final String issueType; // LOW_SHELF_SHARE, MISSING_PRODUCT vb.
  final String severity; // HIGH, MEDIUM, LOW, CRITICAL
  final String description;

  AuditIssueDto({
    required this.id,
    required this.issueType,
    required this.severity,
    required this.description,
  });

  factory AuditIssueDto.fromJson(Map<String, dynamic> json) {
    return AuditIssueDto(
      id: json['id'] ?? 0,
      issueType: json['issueType'] ?? '',
      severity: json['severity'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
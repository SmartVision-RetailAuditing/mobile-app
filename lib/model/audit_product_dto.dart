class AuditProductDto {
  final int id;
  final String productName;
  final String brandName;
  final double? price; // OCR ile okunan fiyat, okunamadıysa null olabilir
  final double confidenceScore;

  AuditProductDto({
    required this.id,
    required this.productName,
    required this.brandName,
    this.price,
    required this.confidenceScore,
  });

  factory AuditProductDto.fromJson(Map<String, dynamic> json) {
    return AuditProductDto(
      id: json['id'] ?? 0,
      productName: json['productName'] ?? '',
      brandName: json['brandName'] ?? '',
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
    );
  }
}
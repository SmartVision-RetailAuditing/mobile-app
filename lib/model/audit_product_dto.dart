class AuditProductDto {
  final int id;
  final int auditId;
  final String productName;
  final String productCode;
  final String brandName;
  final String? volume;
  final String? category;
  final double? price;
  final bool? isEyeLevel;
  final int? shelfPosition;
  final bool isManuallyEdited;
  final double confidenceScore;

  // YENİ KOORDİNAT İSİMLERİ (Backend'den Gelen)
  final double boundingBoxX;
  final double boundingBoxY;
  final double boundingBoxWidth;
  final double boundingBoxHeight;

  // --- HARİKA BİR DART HİLESİ ---
  // Ekran kodunu (UI) hiç değiştirmene gerek kalmayacak.
  // UI "product.x" dediğinde arka planda "boundingBoxX" verilecek.
  double get x => boundingBoxX;
  double get y => boundingBoxY;
  double get width => boundingBoxWidth;
  double get height => boundingBoxHeight;

  AuditProductDto({
    required this.id,
    this.auditId = 0,
    required this.productName,
    this.productCode = '',
    required this.brandName,
    this.volume,
    this.category,
    this.price,
    this.isEyeLevel,
    this.shelfPosition,
    this.isManuallyEdited = false,
    required this.confidenceScore,
    this.boundingBoxX = 0.0,
    this.boundingBoxY = 0.0,
    this.boundingBoxWidth = 0.0,
    this.boundingBoxHeight = 0.0,
  });

  factory AuditProductDto.fromJson(Map<String, dynamic> json) {
    return AuditProductDto(
      id: json['id'] ?? 0,
      auditId: json['auditId'] ?? 0,
      productName: json['productName'] ?? 'Bilinmeyen Ürün',
      productCode: json['productCode'] ?? '',
      brandName: json['brandName'] ?? 'Bilinmiyor',
      volume: json['volume'],
      category: json['category'],
      price: (json['price'] as num?)?.toDouble(),
      isEyeLevel: json['isEyeLevel'],
      shelfPosition: json['shelfPosition'],
      isManuallyEdited: json['isManuallyEdited'] ?? false,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      // Yeni JSON key'lerinden okuma yapıyoruz!
      boundingBoxX: (json['boundingBoxX'] as num?)?.toDouble() ?? 0.0,
      boundingBoxY: (json['boundingBoxY'] as num?)?.toDouble() ?? 0.0,
      boundingBoxWidth: (json['boundingBoxWidth'] as num?)?.toDouble() ?? 0.0,
      boundingBoxHeight: (json['boundingBoxHeight'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Riverpod State güncellemeleri için
  AuditProductDto copyWith({
    String? brandName,
    String? productName, // EKLENDİ
    String? productCode, // EKLENDİ
    bool? isManuallyEdited,
  }) {
    return AuditProductDto(
      id: id,
      auditId: auditId,
      productName: productName ?? this.productName, // GÜNCELLENDİ
      productCode: productCode ?? this.productCode, // GÜNCELLENDİ
      brandName: brandName ?? this.brandName,
      volume: volume,
      category: category,
      price: price,
      isEyeLevel: isEyeLevel,
      shelfPosition: shelfPosition,
      isManuallyEdited: isManuallyEdited ?? this.isManuallyEdited,
      confidenceScore: confidenceScore,
      boundingBoxX: boundingBoxX,
      boundingBoxY: boundingBoxY,
      boundingBoxWidth: boundingBoxWidth,
      boundingBoxHeight: boundingBoxHeight,
    );
  }
}
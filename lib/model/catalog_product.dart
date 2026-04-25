// model/catalog_product.dart
class CatalogProduct {
  final String originalCode;
  final String brand;
  final String productName;

  CatalogProduct({required this.originalCode, required this.brand, required this.productName});

  // Ekranda "PINAR Süt Tam Yağlı %3,3 1/1" şeklinde görünmesi için
  String get displayTitle => "$brand $productName";

  factory CatalogProduct.fromJson(Map<String, dynamic> json) {
    return CatalogProduct(
      originalCode: json['original_code'] ?? '',
      brand: json['brand'] ?? '',
      productName: json['product_name'] ?? '',
    );
  }
}
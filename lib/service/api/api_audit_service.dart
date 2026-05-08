import 'package:dio/dio.dart';
import 'package:smart_vision_mobile/service/base/api_client.dart';
import '../../model/audit_dto.dart';
import '../../model/audit_product_dto.dart';
import '../base/audit_service.dart';

class ApiAuditService implements AuditService {
  final ApiClient _apiClient = ApiClient(); // Merkezi Dio istemcisi

  // --- 1. DASHBOARD İÇİN VERİ ÇEKME ---
  Future<List<AuditDto>> getRecentAudits(int page, int size) async {
    try {
      final response = await _apiClient.dio.get(
        '/Audits/my-audits',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      // Yeni JSON yapısında veriler "data" listesi içinde geliyor
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> dataList = response.data['data'];
        return dataList.map((json) => AuditDto.fromJson(json)).toList();
      } else {
        throw Exception("Veriler alınamadı");
      }
    } on DioException catch (e) {
      throw Exception("Bağlantı hatası: ${e.message}");
    }
  }

  // Tek bir denetimin detayını getirir
  Future<AuditDto> getAuditById(int id) async {
    try {
      final response = await _apiClient.dio.get('/Audits/$id');
      if (response.statusCode == 200) {
        return AuditDto.fromJson(response.data);
      } else {
        throw Exception("Denetim detayı alınamadı");
      }
    } on DioException catch (e) {
      throw Exception("Bağlantı hatası: ${e.message}");
    }
  }

  // --- 2. ÜRÜN DETAYLARINI GÜNCELLEME (PATCH) ---
  // KRİTİK GÜNCELLEME: Sabit "string" değerleri yerine ürünün gerçek verilerini gönderiyoruz
  Future<bool> updateProductDetails(AuditProductDto product) async {
    try {
      final response = await _apiClient.dio.patch(
        '/AuditProducts/${product.id}',
        data: {
          "brandName": product.brandName,
          "productName": product.productName,
          "productCode": product.productCode,
          "volume": product.volume ?? "", // Eğer backend modelinde varsa ekle, yoksa boş gönder
          "category": product.category ?? "",
          "price": product.price ?? 0.0,
          "shelfPosition": product.shelfPosition ?? 0,
          "isEyeLevel": product.isEyeLevel ?? true
        },
      );

      if (response.statusCode == 200) {
        print("✅ Ürün başarıyla güncellendi (ID: ${product.id})");
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("🚨 Ürün Güncelleme Hatası: ${e.message}");
      if (e.response != null) {
        print("Hata Detayı: ${e.response?.data}");
      }
      return false;
    }
  }

  // --- 3. KAMERA İÇİN FOTOĞRAF GÖNDERME ---
  @override
  Future<bool> submitAuditPhoto(int taskId, String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'TaskId': taskId,
        'Image': await MultipartFile.fromFile(imagePath, filename: 'audit_photo.jpg'),
      });

      final response = await _apiClient.dio.post(
        '/Audits/submit',
        data: formData,
        options: Options(
          receiveTimeout: const Duration(seconds: 180),
          sendTimeout: const Duration(seconds: 180),
        ),
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        print("✅ Fotoğraf başarıyla yüklendi: ${response.data}");
        return true;
      }

      print("⚠️ Backend başarısız bir kod döndü: ${response.statusCode}");
      return false;

    } on DioException catch (e) {
      print("🚨 --- API GÖNDERİM HATASI (DioException) --- 🚨");
      print("Hata Türü (Type): ${e.type}");
      print("Hata Mesajı (Message): ${e.message}");

      if (e.response != null) {
        print("Sunucudan Gelen Durum Kodu (StatusCode): ${e.response?.statusCode}");
        print("Sunucudan Gelen Hata Detayı (Data): ${e.response?.data}");
      } else {
        print("Sunucudan hiçbir cevap alınamadı!");
      }
      return false;
    } catch (e) {
      print("🚨 --- BEKLENMEYEN HATA --- 🚨");
      print("Hata: $e");
      return false;
    }
  }
}
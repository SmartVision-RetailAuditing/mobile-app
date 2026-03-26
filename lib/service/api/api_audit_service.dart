import 'package:dio/dio.dart';
import 'package:smart_vision_mobile/service/base/api_client.dart';
import '../../model/audit_dto.dart';
import '../base/api_client.dart';
import '../base/audit_service.dart'; // Eğer interface'i hala kullanıyorsan

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

  // --- 2. KAMERA İÇİN FOTOĞRAF GÖNDERME ---
  @override
  Future<bool> submitAuditPhoto(int taskId, String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'TaskId': taskId,
        'Image': await MultipartFile.fromFile(imagePath, filename: 'audit_photo.jpg'),
      });

      // API İsteği
      final response = await _apiClient.dio.post(
        '/Audits/submit',
        data: formData,
        // DÜZELTME 1: Görüntü işleme modeli uzun sürebileceği için süreyi uzatıyoruz!
        options: Options(
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ),
      );

      // DÜZELTME 2: 200, 201, 202, 204 gibi TÜM başarılı (2xx) kodları kabul et!
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        print("Fotoğraf başarıyla yüklendi: ${response.data}");
        return true;
      }

      print("Backend başarısız bir kod döndü: ${response.statusCode}");
      return false;

    } on DioException catch (e) {
      // Hatayı net görebilmek için detaylandırıyoruz
      print("Dio API Hatası: ${e.type} - ${e.message}");
      if (e.response != null) {
        print("Hata detayı: ${e.response?.data}");
      }
      return false;
    } catch (e) {
      print("Beklenmeyen Hata: $e");
      return false;
    }
  }
}
import 'package:dio/dio.dart';
import 'package:smart_vision_mobile/service/base/api_client.dart';
import '../../model/audit_dto.dart';
import '../base/api_client.dart';
import '../base/audit_service.dart'; // Eğer interface'i hala kullanıyorsan

class ApiAuditService implements AuditService {
  final ApiClient _apiClient = ApiClient(); // Merkezi Dio istemcisi

  // --- 1. DASHBOARD İÇİN VERİ ÇEKME ---
  Future<List<AuditDto>> getRecentAudits() async {
    try {
      final response = await _apiClient.dio.get(
        '/Audits',
        queryParameters: {
          'page': 1,
          'size': 10,
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

      final response = await _apiClient.dio.post(
        '/Audits/submit',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Fotoğraf başarıyla yüklendi: ${response.data}");
        return true;
      }
      return false;
    } on DioException catch (e) {
      print("Audit API Hatası: ${e.response?.statusCode}");
      print("Hata detayı: ${e.response?.data}");
      return false;
    } catch (e) {
      print("Beklenmeyen Hata: $e");
      return false;
    }
  }
}
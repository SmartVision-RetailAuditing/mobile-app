import 'package:dio/dio.dart';
import '../base/audit_service.dart';
import '../base/api_client.dart';

class ApiAuditService implements AuditService {
  final Dio _dio = ApiClient().dio; // Merkezi Dio istemciniz

  @override
  Future<bool> submitAuditPhoto(int taskId, String imagePath) async {
    try {
      final formData = FormData.fromMap({
        'TaskId': taskId,
        'Image': await MultipartFile.fromFile(imagePath, filename: 'audit_photo.jpg'),
      });

      final response = await _dio.post(
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
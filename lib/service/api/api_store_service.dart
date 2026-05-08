import 'package:dio/dio.dart';
import '../../model/store_dto.dart';
import '../base/store_service.dart';
import '../base/api_client.dart';

class ApiStoreService implements StoreService {
  final Dio _dio = ApiClient().dio; // Merkezi Dio

  @override
  Future<List<StoreDto>> getStores() async {
    try {
      // Interceptor sayesinde bu isteğin içine Token otomatik eklenecek!
      final response = await _dio.get('/Stores');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => StoreDto.fromJson(json)).toList();
      } else {
        throw Exception("Mağazalar alınamadı: ${response.statusCode}");
      }
    } catch (e) {
      print("GetStores API Hatası: $e");
      rethrow;
    }
  }

  @override
  Future<StoreDto> getStoreById(int id) async {
    try {
      final response = await _dio.get('/Stores/$id');
      if (response.statusCode == 200) {
        return StoreDto.fromJson(response.data);
      } else {
        throw Exception("Mağaza detayı alınamadı: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }
}
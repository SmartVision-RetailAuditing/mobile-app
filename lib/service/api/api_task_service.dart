import 'package:dio/dio.dart';
import '../../model/task_dto.dart';
import '../../model/update_task_dto.dart';
import '../base/task_service.dart';
import '../base/api_client.dart';

class ApiTaskService implements TaskService {
  final Dio _dio = ApiClient().dio; // Merkezi Dio

  @override
  Future<List<TaskDto>> getMyTasks({int page = 1, int size = 10}) async {
    try {
      final response = await _dio.get(
        '/Tasks/my-tasks',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> dataList = response.data['data'];
        return dataList.map((json) => TaskDto.fromJson(json)).toList();
      } else {
        throw Exception("Görevler alınamadı: ${response.statusCode}");
      }
    } catch (e) {
      print("GetMyTasks API Hatası: $e");
      rethrow;
    }
  }

  @override
  Future<TaskDto> getTaskById(int id) async {
    try {
      final response = await _dio.get('/Tasks/$id');
      if (response.statusCode == 200) {
        return TaskDto.fromJson(response.data);
      } else {
        throw Exception("Görev detayı alınamadı.");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> updateTask(int id, UpdateTaskDto updateData) async {
    try {
      final response = await _dio.put(
        '/Tasks/$id',
        data: updateData.toJson(),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      // YENİ DEĞİŞİKLİK BURADA: Backend'in gönderdiği gerçek hata mesajını konsola basıyoruz
      print("UpdateTask API Hatası: ${e.response?.statusCode}");
      print("Backend Hata Detayı: ${e.response?.data}");
      return false;
    } catch (e) {
      print("UpdateTask Beklenmeyen Hata: $e");
      return false;
    }
  }
}
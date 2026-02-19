import 'package:dio/dio.dart';
import '../../model/task_dto.dart';
import '../../model/update_task_dto.dart';
import '../base/task_service.dart';
import '../base/api_client.dart';

class ApiTaskService implements TaskService {
  final Dio _dio = ApiClient().dio; // Merkezi Dio

  @override
  Future<List<TaskDto>> getMyTasks() async {
    try {
      final response = await _dio.get('/Tasks/my-tasks');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => TaskDto.fromJson(json)).toList();
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
    } catch (e) {
      print("UpdateTask API Hatası: $e");
      return false;
    }
  }
}
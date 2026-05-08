import 'package:dio/dio.dart';
import '../../model/user_profile_dto.dart';
import '../../model/user_stats_response_dto.dart';
import '../base/user_service.dart';
import '../base/api_client.dart';

class ApiUserService implements UserService {
  final Dio _dio = ApiClient().dio; // Merkezi Dio

  @override
  Future<UserProfileDto> getProfile() async {
    try {
      final response = await _dio.get('/Users/profile');
      if (response.statusCode == 200) {
        return UserProfileDto.fromJson(response.data);
      } else {
        throw Exception("Profil bilgileri alınamadı.");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserStatsResponseDto> getMyStats() async {
    try {
      final response = await _dio.get('/Users/me/stats');
      if (response.statusCode == 200) {
        return UserStatsResponseDto.fromJson(response.data);
      } else {
        throw Exception("İstatistikler alınamadı.");
      }
    } catch (e) {
      rethrow;
    }
  }
}
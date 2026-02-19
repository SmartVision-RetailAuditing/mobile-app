import '../model/user_profile_dto.dart';
import '../model/user_stats_response_dto.dart';

abstract class UserBase {
  Future<UserProfileDto> getProfile();
  Future<UserStatsResponseDto> getMyStats();
}
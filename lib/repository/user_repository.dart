import '../model/user_profile_dto.dart';
import '../model/user_stats_response_dto.dart';
import '../service/api/api_user_service.dart';
import '../service/base/user_service.dart';
import '../base/user_base.dart';

class UserRepository implements UserBase {
  final UserService _service = ApiUserService();

  @override
  Future<UserProfileDto> getProfile() async {
    return await _service.getProfile();
  }

  @override
  Future<UserStatsResponseDto> getMyStats() async {
    return await _service.getMyStats();
  }
}
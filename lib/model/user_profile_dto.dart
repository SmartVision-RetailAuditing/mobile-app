import 'user_stats_dto.dart';

class UserProfileDto {
  final String? fullName;
  final String? employeeId;
  final String? role;
  final String? email;
  final String? phone;
  final UserStatsDto? stats;

  UserProfileDto({
    this.fullName,
    this.employeeId,
    this.role,
    this.email,
    this.phone,
    this.stats,
  });

  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      fullName: json['fullName'] as String?,
      employeeId: json['employeeId'] as String?,
      role: json['role'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      stats: json['stats'] != null ? UserStatsDto.fromJson(json['stats']) : null,
    );
  }
}
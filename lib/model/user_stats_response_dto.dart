class WeeklyTasksStatsDto {
  final int? total;
  final int? completed;
  final int? pending;

  WeeklyTasksStatsDto({this.total, this.completed, this.pending});

  factory WeeklyTasksStatsDto.fromJson(Map<String, dynamic> json) {
    return WeeklyTasksStatsDto(
      total: json['total'] as int?,
      completed: json['completed'] as int?,
      pending: json['pending'] as int?,
    );
  }
}

class PerformanceStatsDto {
  final double? completionRate; // int? yerine double? yaptık
  final double? averageScore;   // int? yerine double? yaptık
  final int? totalStoreVisits;

  PerformanceStatsDto({this.completionRate, this.averageScore, this.totalStoreVisits});

  factory PerformanceStatsDto.fromJson(Map<String, dynamic> json) {
    return PerformanceStatsDto(
      // Backend'den 80 (int) veya 80.5 (double) gelebilir. 'num' kullanmak her ikisini de güvenle 'double'a çevirir.
      completionRate: json['completionRate'] != null ? (json['completionRate'] as num).toDouble() : null,
      averageScore: json['averageScore'] != null ? (json['averageScore'] as num).toDouble() : null,
      totalStoreVisits: json['totalStoreVisits'] as int?,
    );
  }
}

class UserStatsResponseDto {
  final WeeklyTasksStatsDto? weeklyTasks;
  final PerformanceStatsDto? performance;

  UserStatsResponseDto({this.weeklyTasks, this.performance});

  factory UserStatsResponseDto.fromJson(Map<String, dynamic> json) {
    return UserStatsResponseDto(
      weeklyTasks: json['weeklyTasks'] != null
          ? WeeklyTasksStatsDto.fromJson(json['weeklyTasks'])
          : null,
      performance: json['performance'] != null
          ? PerformanceStatsDto.fromJson(json['performance'])
          : null,
    );
  }
}
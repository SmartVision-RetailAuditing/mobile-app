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
  final int? completionRate;
  final int? averageScore;
  final int? totalStoreVisits;

  PerformanceStatsDto({this.completionRate, this.averageScore, this.totalStoreVisits});

  factory PerformanceStatsDto.fromJson(Map<String, dynamic> json) {
    return PerformanceStatsDto(
      completionRate: json['completionRate'] as int?,
      averageScore: json['averageScore'] as int?,
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
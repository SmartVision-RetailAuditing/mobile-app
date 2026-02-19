class UserStatsDto {
  final int? totalTasks;
  final int? completedTasks;
  final int? pendingTasks;
  final int? totalStoreVisits;
  final int? averageScore;
  final int? completionRate;

  UserStatsDto({
    this.totalTasks,
    this.completedTasks,
    this.pendingTasks,
    this.totalStoreVisits,
    this.averageScore,
    this.completionRate,
  });

  factory UserStatsDto.fromJson(Map<String, dynamic> json) {
    return UserStatsDto(
      totalTasks: json['totalTasks'] as int?,
      completedTasks: json['completedTasks'] as int?,
      pendingTasks: json['pendingTasks'] as int?,
      totalStoreVisits: json['totalStoreVisits'] as int?,
      averageScore: json['averageScore'] as int?,
      completionRate: json['completionRate'] as int?,
    );
  }
}
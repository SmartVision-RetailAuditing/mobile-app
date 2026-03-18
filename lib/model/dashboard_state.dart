import 'audit_dto.dart';

class DashboardState {
  final List<AuditDto> recentAudits;
  final int? selectedAuditId;
  final bool isLoading;
  final String? errorMessage;

  DashboardState({
    this.recentAudits = const [],
    this.selectedAuditId,
    this.isLoading = true,
    this.errorMessage,
  });

  // Seçili olan denetimi getirir, yoksa ilk denetimi getirir
  AuditDto? get currentAudit {
    if (recentAudits.isEmpty) return null;
    try {
      return recentAudits.firstWhere((a) => a.id == selectedAuditId);
    } catch (e) {
      return recentAudits.first;
    }
  }

  DashboardState copyWith({
    List<AuditDto>? recentAudits,
    int? selectedAuditId,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DashboardState(
      recentAudits: recentAudits ?? this.recentAudits,
      selectedAuditId: selectedAuditId ?? this.selectedAuditId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}
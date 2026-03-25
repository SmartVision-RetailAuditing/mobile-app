import '../model/audit_dto.dart';
import '../base/audit_base.dart';
import '../service/api/api_audit_service.dart';

class AuditRepository implements AuditBase {
  final ApiAuditService _apiService;

  // Dependency Injection (Riverpod'dan gelecek olan servis)
  AuditRepository(this._apiService);

  // --- DASHBOARD İÇİN ---
  Future<List<AuditDto>> getRecentAudits(int page, int size) async {
    return await _apiService.getRecentAudits(page, size);
  }

  // --- KAMERA İÇİN ---
  @override
  Future<bool> submitAuditPhoto(int taskId, String imagePath) async {
    return await _apiService.submitAuditPhoto(taskId, imagePath);
  }
}
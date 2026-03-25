import '../model/audit_dto.dart';

abstract class AuditBase {
  Future<bool> submitAuditPhoto(int taskId, String imagePath);
  Future<List<AuditDto>> getRecentAudits(int page, int size);
}
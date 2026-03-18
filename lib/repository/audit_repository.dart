import '../base/audit_base.dart';
import '../service/api/api_audit_service.dart';
import '../service/base/audit_service.dart';

class AuditRepository implements AuditBase {
  // API servisini çağırıyoruz
  final AuditService _service = ApiAuditService();

  @override
  Future<bool> submitAuditPhoto(int taskId, String imagePath) async {
    return await _service.submitAuditPhoto(taskId, imagePath);
  }
}
import '../model/audit_dto.dart';
import '../base/audit_base.dart';
import '../model/audit_product_dto.dart';
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

  @override
  Future<AuditDto> getAuditById(int id) async {
    return await _apiService.getAuditById(id);
  }

  @override
  Future<bool> updateProductDetails(AuditProductDto product) async {
    // Artık id ve brandName değil, direkt product objesini paslıyoruz.
    return await _apiService.updateProductDetails(product);
  }
}
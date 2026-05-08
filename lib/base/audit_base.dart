import '../model/audit_dto.dart';
import '../model/audit_product_dto.dart';

abstract class AuditBase {
  Future<bool> submitAuditPhoto(int taskId, String imagePath);
  Future<List<AuditDto>> getRecentAudits(int page, int size);
  Future<AuditDto> getAuditById(int id);
  Future<bool> updateProductDetails(AuditProductDto product);
}
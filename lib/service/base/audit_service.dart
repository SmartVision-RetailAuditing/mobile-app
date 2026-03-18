abstract class AuditService {
  // Fotoğraf yükleme işleminin taslağı
  Future<bool> submitAuditPhoto(int taskId, String imagePath);
}
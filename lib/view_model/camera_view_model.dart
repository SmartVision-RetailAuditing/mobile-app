import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_vision_mobile/view_model/task_view_model.dart';
import '../providers.dart';
import '../repository/audit_repository.dart';
import '../service/api/api_audit_service.dart';

class CameraViewModel extends StateNotifier<void> {
  final Ref ref;
  // Artık doğrudan servisi değil, katmanlı mimariye uygun olarak Repository'i kullanıyoruz
  final AuditRepository _repository = AuditRepository(ApiAuditService());

  CameraViewModel(this.ref) : super(null);

  // DİKKAT: Artık Future<bool> dönüyor! (Başarılı mı başarısız mı)
  Future<bool> takePhotoAndCompleteTask(String imagePath) async {
    final activeTask = ref.read(activeTaskProvider);

    if (activeTask != null && activeTask.id != null) {
      try {
        // İşlemi Repository üzerinden tetikliyoruz
        final success = await _repository.submitAuditPhoto(activeTask.id!, imagePath);

        if (success) {
          print("Fotoğraf başarıyla gönderildi ve görev tamamlandı!");
          // Ana sayfadaki görev listesini yeniliyoruz
          ref.read(taskListProvider.notifier).refresh();

          // Başarılıysa aktif görevi temizle
          ref.read(activeTaskProvider.notifier).state = null;
          return true; // İşlem başarılı!
        } else {
          print("Backend fotoğraf yüklemeyi reddetti.");
          return false; // İşlem başarısız!
        }
      } catch (e) {
        print("Beklenmeyen Hata oluştu: $e");
        return false; // Hata oldu!
      }
    }
    return false;
  }
}

// Provider tanımı
final cameraViewModelProvider = StateNotifierProvider<CameraViewModel, void>((ref) {
  return CameraViewModel(ref);
});
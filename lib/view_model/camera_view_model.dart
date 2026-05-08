import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
// DİKKAT: legacy.dart importu buradan tamamen silindi! Çakışmaları önlemek için bir daha ekleme.
import 'package:smart_vision_mobile/view_model/task_view_model.dart';
import '../providers.dart';

class CameraViewModel extends StateNotifier<void> {
  final Ref ref;

  CameraViewModel(this.ref) : super(null);

  // DİKKAT: Artık Future<bool> dönüyor! (Başarılı mı başarısız mı)
  Future<bool> takePhotoAndCompleteTask(String imagePath) async {
    final activeTask = ref.read(activeTaskProvider);

    if (activeTask != null && activeTask.id != null) {
      try {
        // Sınıfı elle oluşturmak (new) yerine Riverpod'dan istiyoruz!
        final success = await ref.read(auditRepositoryProvider).submitAuditPhoto(activeTask.id!, imagePath);

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


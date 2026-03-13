import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../providers.dart';
import '../view_model/task_view_model.dart';

class CameraViewModel extends StateNotifier<void> {
  final Ref ref;

  CameraViewModel(this.ref) : super(null);

  Future<void> takePhotoAndCompleteTask() async {
    // 1. Hangi görev üzerinden kameraya gelindiğini alıyoruz
    final activeTask = ref.read(activeTaskProvider);

    if (activeTask != null && activeTask.id != null) {
      try {
        // YENİ DEĞİŞİKLİK BURADA: Sadece ID'yi değil, görevin tamamını (activeTask) yolluyoruz
        final success = await ref.read(taskViewModelProvider).completeTask(activeTask);

        if (success) {
          print("Görev başarıyla backend tarafında güncellendi.");

          // Yeni sonsuz kaydırma mantığına (StateNotifier) göre listeyi baştan çekiyoruz
          ref.read(taskListProvider.notifier).refresh();
        } else {
          print("Backend güncellemeyi reddetti (Success: false).");
        }
      } catch (e) {
        print("Hata oluştu: $e");
        return; // Hata varsa Dashboard'a gitme, kullanıcı ekranda kalsın.
      }

      // 2. İşlem bittikten sonra aktif görevi temizle
      ref.read(activeTaskProvider.notifier).state = null;
    }

    // 3. Dashboard sekmesine (index: 3) yönlendir
    ref.read(navIndexProvider.notifier).state = 3;
  }
}

final cameraViewModelProvider = StateNotifierProvider<CameraViewModel, void>((ref) {
  return CameraViewModel(ref);
});
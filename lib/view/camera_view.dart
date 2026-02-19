import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart'; // activeTaskProvider için
import '../view_model/camera_view_model.dart';

class CameraScreen extends ConsumerWidget {
  const CameraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sadece ekranda göstermek istersek aktif görevi izleyebiliriz
    final activeTask = ref.watch(activeTaskProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Kullanıcıya hangi mağazanın fotoğrafını çektiğini gösterebiliriz (İsteğe bağlı)
            if (activeTask != null) ...[
              Text(
                activeTask.storeName ?? "Bilinmeyen Mağaza",
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Görev: ${activeTask.taskType ?? '-'}",
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 32),
            ],

            ElevatedButton.icon(
              onPressed: () {
                // ViewModel'deki fonksiyonu tetikliyoruz
                ref.read(cameraViewModelProvider.notifier).takePhotoAndCompleteTask();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              icon: const Icon(Icons.camera),
              label: const Text(
                "Fotoğraf Çek ve Bitir",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers.dart';
import '../view_model/camera_view_model.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  // Kameradan veya Galeriden fotoğraf seçme fonksiyonu
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Yüklemeyi hızlandırmak için boyutu optimize ediyoruz
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Fotoğraf seçme hatası: $e");
    }
  }

  // Fotoğrafı Backend'e Gönderme Fonksiyonu
  Future<void> _submitPhoto() async {
    final activeTask = ref.read(activeTaskProvider);

    // KONTROL 1: Görev seçili mi?
    if (activeTask == null || activeTask.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hata: Lütfen önce Görevler sekmesinden bir görev seçin!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // KONTROL 2: Fotoğraf var mı?
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen göndermeden önce bir fotoğraf çekin veya seçin."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() { _isLoading = true; });

    // ViewModel'i çağırıp dosya yolunu (imagePath) gönderiyoruz
    await ref.read(cameraViewModelProvider.notifier).takePhotoAndCompleteTask(_selectedImage!.path);

    if (mounted) {
      setState(() { _isLoading = false; });
      _selectedImage = null; // Yükleme sonrası ekranı temizle
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTask = ref.watch(activeTaskProvider);
    final hasTask = activeTask != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Raf Fotoğrafı Yükle'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // GÖREV BİLGİ KARTI
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: hasTask ? Colors.blue.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: hasTask ? Colors.blue.shade200 : Colors.red.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    hasTask ? Icons.assignment_turned_in : Icons.warning_amber_rounded,
                    color: hasTask ? Colors.blue.shade700 : Colors.red.shade700,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasTask
                        ? "Aktif Görev: ${activeTask.storeName}\nTip: ${activeTask.taskType}"
                        : "Lütfen fotoğraf yüklemek için Görevler listesinden bir görev seçin.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: hasTask ? Colors.blue.shade900 : Colors.red.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // FOTOĞRAF ÖNİZLEME ALANI
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined, size: 64, color: Colors.grey.shade500),
                    const SizedBox(height: 16),
                    Text(
                      "Henüz fotoğraf seçilmedi",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // KAMERA / GALERİ BUTONLARI
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: hasTask && !_isLoading ? () => _pickImage(ImageSource.camera) : null,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamera'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: hasTask && !_isLoading ? () => _pickImage(ImageSource.gallery) : null,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeri'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // GÖNDER BUTONU
            ElevatedButton(
              onPressed: hasTask && _selectedImage != null && !_isLoading ? _submitPhoto : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green.shade600, // Aktifken arka plan rengi
                foregroundColor: Colors.white,          // Aktifken yazı rengi
                disabledBackgroundColor: Colors.grey.shade300, // Pasifken arka plan rengi
                disabledForegroundColor: Colors.grey.shade700, // EKLENEN SATIR: Pasifken yazı rengi
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text('Fotoğrafı Gönder ve Tamamla', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
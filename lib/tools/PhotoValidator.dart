import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

// --- FOTOĞRAF KONTROL SINIFI (ML KIT) ---
class PhotoValidator {
  late ImageLabeler _imageLabeler;

  PhotoValidator() {
    // Güven eşiği 0.5 (Yani model %50'den fazla eminse etiketi kabul edecek)
    _imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));
  }

  Future<bool> isValidShelfPhoto(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);

    try {
      final List<ImageLabel> labels = await _imageLabeler.processImage(inputImage);

      // Modelin bulduğu tüm etiketleri konsola yazdır (Test için çok faydalı)
      print("--- AI ETİKETLERİ ---");
      for (ImageLabel label in labels) {
        print('${label.label}: %${(label.confidence * 100).toStringAsFixed(1)}');
      }

      // Kabul edilebilir anahtar kelimeler (Genellikle İngilizce döner)
      const allowedLabels = {
        'Shelf', 'Shelving', 'Supermarket', 'Grocery store',
        'Retail', 'Product', 'Bottle', 'Box', 'Food',
        'Beverage', 'Dairy product', 'Convenience store'
      };

      for (ImageLabel label in labels) {
        if (allowedLabels.contains(label.label)) {
          return true; // Geçerli bir etiket bulundu!
        }
      }
    } catch (e) {
      print("ML Kit hatası: $e");
      // Cihaz kaynaklı bir hata olursa kullanıcıyı engellememek için true dönüyoruz
      return true;
    }

    return false; // Hiçbir eşleşme yoksa fotoğraf reddedilir
  }

  void dispose() {
    _imageLabeler.close();
  }
}
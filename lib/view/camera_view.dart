import 'package:flutter/material.dart';

class CameraScreen extends StatelessWidget {
  final VoidCallback onComplete; // İşlem bitince çalışacak fonksiyon

  const CameraScreen({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ElevatedButton(
          onPressed: onComplete, // Tıklanınca Dashboard'a atacak
          child: const Text("Fotoğraf Çek ve Bitir"),
        ),
      ),
    );
  }
}
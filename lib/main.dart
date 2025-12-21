import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_vision_mobile/providers.dart';
import 'package:smart_vision_mobile/view/navigation_bar_view.dart';
import 'package:smart_vision_mobile/tools/AppColors.dart'; // Renk dosyan

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Görev Uygulaması',
      themeMode: themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: const NavigationBarView(),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.colorWhite, // Arka plan beyaz
      primaryColor: AppColors.colorPrimaryBlue,
      cardColor: Colors.white, // Kartlar beyaz

      // Navigation Bar Ayarı (Light)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.colorPrimaryBlue,
        unselectedItemColor: Colors.grey.shade500,
      ),

      // Text Teması (Siyah yazı)
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.colorText),
        bodyLarge: TextStyle(color: AppColors.colorText),
      ),
      useMaterial3: true,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212), // Arka plan koyu gri
      primaryColor: AppColors.colorPrimaryBlue,
      cardColor: const Color(0xFF1E1E1E), // Kartlar biraz daha açık gri

      // Navigation Bar Ayarı (Dark)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E), // Bar koyu olsun
        selectedItemColor: AppColors.colorPrimaryBlue,
        unselectedItemColor: Colors.grey.shade400,
      ),

      // Text Teması (Beyaz yazı)
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
      ),
      useMaterial3: true,
    );
  }
}
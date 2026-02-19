import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_vision_mobile/providers.dart';
import 'package:smart_vision_mobile/view/navigation_bar_view.dart';
import 'package:smart_vision_mobile/view/login_view.dart'; // Giriş sayfanı import et
import 'package:smart_vision_mobile/tools/AppColors.dart';
import 'package:smart_vision_mobile/providers.dart';

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
      // Artık direkt NavigationBarView'u DEĞİL, kapı görevlisini çağırıyoruz:
      home: const AuthChecker(),
    );
  }

  ThemeData _buildLightTheme() {
    // ... Senin yazdığın mevcut light theme kodları ...
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.colorWhite,
      primaryColor: AppColors.colorPrimaryBlue,
      cardColor: Colors.white,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.colorPrimaryBlue,
        unselectedItemColor: Colors.grey.shade500,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.colorText),
        bodyLarge: TextStyle(color: AppColors.colorText),
      ),
      useMaterial3: true,
    );
  }

  ThemeData _buildDarkTheme() {
    // ... Senin yazdığın mevcut dark theme kodları ...
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      primaryColor: AppColors.colorPrimaryBlue,
      cardColor: const Color(0xFF1E1E1E),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: AppColors.colorPrimaryBlue,
        unselectedItemColor: Colors.grey.shade400,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.white),
        bodyLarge: TextStyle(color: Colors.white),
      ),
      useMaterial3: true,
    );
  }
}

// YENİ EKLENEN KAPI GÖREVLİSİ (AUTH CHECKER)
class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // providers.dart içindeki token kontrolünü dinler
    final authState = ref.watch(authCheckProvider);

    return authState.when(
      // Kontrol bittiğinde: Token varsa Ana Sayfa, yoksa Login Sayfası
      data: (isAuthenticated) {
        if (isAuthenticated) {
          return const NavigationBarView();
        } else {
          return const LoginView(); // Senin Figma tasarımın olan sayfa
        }
      },
      // Kontrol sürerken (ilk 0.1 saniye) ekranda yükleniyor ikonu gösterir
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      // Bir hata çıkarsa güvenli liman olarak yine Login'i gösterir
      error: (err, stack) => const LoginView(),
    );
  }
}
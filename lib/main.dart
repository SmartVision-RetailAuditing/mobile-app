import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_vision_mobile/providers.dart';
import 'package:smart_vision_mobile/view/navigation_bar_view.dart';
import 'package:smart_vision_mobile/view/login_view.dart';
import 'package:smart_vision_mobile/tools/AppColors.dart';

// DİKKAT: Kendi ApiClient dosyanın yolunu buraya eklemelisin
import 'package:smart_vision_mobile/service/base/api_client.dart';

// 1. ADIM: Tüm uygulamayı yönetecek global navigasyon anahtarımızı oluşturuyoruz
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();


   ApiClient.onUnauthorized = () {
     navigatorKey.currentState?.pushAndRemoveUntil(
       MaterialPageRoute(builder: (context) => const LoginView()),
       (route) => false, // false diyerek arkadaki tüm açık sayfaları (Kamera, Harita vs.) siliyoruz
     );
   };

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
      // 3. ADIM: Oluşturduğumuz anahtarı MaterialApp'a veriyoruz ki tüm sayfaları kontrol edebilsin
      navigatorKey: navigatorKey,

      debugShowCheckedModeBanner: false,
      title: 'Görev Uygulaması',
      themeMode: themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: const AuthChecker(),
    );
  }

  ThemeData _buildLightTheme() {
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

// KAPI GÖREVLİSİ (AUTH CHECKER)
class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authCheckProvider);

    return authState.when(
      data: (isAuthenticated) {
        if (isAuthenticated) {
          return const NavigationBarView();
        } else {
          return const LoginView();
        }
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => const LoginView(),
    );
  }
}
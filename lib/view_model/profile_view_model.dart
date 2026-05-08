import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import yollarını kendi klasör yapına göre kontrol etmelisin
import '../repository/user_repository.dart';
import '../model/user_profile_dto.dart';
import '../model/user_stats_response_dto.dart';
import '../tools/token_manager.dart';
import '../main.dart';
import '../view/login_view.dart'; // AuthChecker sınıfının (Kapı Görevlisi) olduğu dosya
import '../providers.dart'; // YENİ: DashboardViewModel gibi provider'lara erişmek için ekledik

// 1. Profil ve İstatistik verilerini tek bir pakette toplayan yardımcı model sınıfı
class ProfileData {
  final UserProfileDto profile;
  final UserStatsResponseDto stats;

  ProfileData(this.profile, this.stats);
}

// 2. AZURE'DAN GERÇEK VERİLERİ ÇEKEN SAĞLAYICI
// autoDispose kullandık ki kullanıcı bu sayfadan çıkınca hafıza temizlensin, tekrar girince veriler güncellensin.
final profileDataProvider = FutureProvider.autoDispose<ProfileData>((ref) async {
  final repo = UserRepository();

  // İki API isteğini aynı anda başlatıp bekliyoruz
  final profile = await repo.getProfile();
  final stats = await repo.getMyStats();

  return ProfileData(profile, stats);
});

// 3. Çıkış yapma gibi aksiyonları tutan ViewModel'in Sağlayıcısı
// YENİ: ProfilViewModel'e 'ref' objesini gönderiyoruz
final profileViewModelProvider = Provider((ref) => ProfileViewModel(ref));

// 4. Aksiyonları barındıran asıl ViewModel Sınıfı
class ProfileViewModel {
  // YENİ: Diğer Provider'lara ulaşıp emir verebilmek için ref'i tanımlıyoruz
  final Ref ref;

  // YENİ: Constructor (Yapıcı Metot)
  ProfileViewModel(this.ref);

  // Arayüzden (View) buraya taşıdığımız formatlama fonksiyonu
  String formatRole(String? rawRole) {
    if (rawRole == null) return 'Rol Belirtilmemiş';

    switch (rawRole.toUpperCase()) {
      case 'FIELD_WORKER':
        return 'Saha Çalışanı';
      case 'MANAGER':
        return 'Yönetici';
      case 'ADMIN':
        return 'Sistem Yöneticisi';
      default:
        return rawRole;
    }
  }

  // --- YENİ EKLENEN: TEMA DEĞİŞTİRME VE KAYDETME ---
  Future<void> toggleTheme(bool isDark) async {
    // 1. Ekrandaki temayı anında değiştir
    ref.read(themeModeProvider.notifier).state = isDark ? ThemeMode.dark : ThemeMode.light;

    // 2. Bu tercihi telefonun kalıcı hafızasına kaydet
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  Future<void> logout(BuildContext context) async {
    // 1. YENİ EKLENEN: DİĞER EKRANLARIN HAFIZASINI TEMİZLE!
    // Başka bir hesapla girildiğinde eski Dashboard verileri görünmesin diye temizliyoruz.
    ref.read(dashboardViewModelProvider).clearData();

    // 2. Cihazdaki (Kasadaki) Token'ı tamamen sil
    await TokenManager.deleteToken();

    // 3. Geçmiş sayfaları silerek DOĞRUDAN LOGIN SAYFASINA DÖN
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        PageRouteBuilder(
          // AuthChecker YERİNE doğrudan LoginView'u çağırıyoruz!
          pageBuilder: (context, animation1, animation2) => const LoginView(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
            (route) => false,
      );
    }
  }
}
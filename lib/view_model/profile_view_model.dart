import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import yollarını kendi klasör yapına göre kontrol etmelisin
import '../repository/user_repository.dart';
import '../model/user_profile_dto.dart';
import '../model/user_stats_response_dto.dart';
import '../tools/token_manager.dart';
import '../main.dart';
import '../view/login_view.dart'; // AuthChecker sınıfının (Kapı Görevlisi) olduğu dosya

// 1. Profil ve İstatistik verilerini tek bir pakette toplayan yardımcı model sınıfı
class ProfileData {
  final UserProfileDto profile;
  final UserStatsResponseDto stats;

  ProfileData(this.profile, this.stats);
}

// 2. AZURE'DAN GERÇEK VERİLERİ ÇEKEN SAĞLAYICI (İşte buraya yazıyoruz)
// autoDispose kullandık ki kullanıcı bu sayfadan çıkınca hafıza temizlensin, tekrar girince veriler güncellensin.
final profileDataProvider = FutureProvider.autoDispose<ProfileData>((ref) async {
  final repo = UserRepository();

  // İki API isteğini aynı anda başlatıp bekliyoruz
  final profile = await repo.getProfile();
  final stats = await repo.getMyStats();

  return ProfileData(profile, stats);
});

// 3. Çıkış yapma gibi aksiyonları tutan ViewModel'in Sağlayıcısı
final profileViewModelProvider = Provider((ref) => ProfileViewModel());

// 4. Aksiyonları barındıran asıl ViewModel Sınıfı
class ProfileViewModel {

  // YENİ: Arayüzden (View) buraya taşıdığımız formatlama fonksiyonu
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

  Future<void> logout(BuildContext context) async {
    // 1. Cihazdaki (Kasadaki) Token'ı tamamen sil
    await TokenManager.deleteToken();

    // 2. Geçmiş sayfaları silerek DOĞRUDAN LOGIN SAYFASINA DÖN
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
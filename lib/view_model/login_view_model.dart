import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../repository/auth_repository.dart';
import '../model/login_request_dto.dart';
import '../view/navigation_bar_view.dart';

// Import yollarını kendi projene göre kontrol etmeyi unutma
import '../providers.dart'; // YENİ: DashboardViewModel'e erişmek için
import '../tools/token_manager.dart'; // YENİ: Token'ı cihaza kaydetmek için

// YENİ: ref objesini LoginViewModel'e gönderiyoruz ki diğer sağlayıcılara erişebilsin
final loginViewModelProvider = ChangeNotifierProvider((ref) => LoginViewModel(ref));

class LoginViewModel extends ChangeNotifier {
  final Ref ref; // YENİ: Diğer provider'lara emir vermek için tanımladık
  final AuthRepository _authRepository = AuthRepository();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // YENİ: Constructor (Yapıcı Metot) içine ref'i ekledik
  LoginViewModel(this.ref);

  Future<void> login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    _errorMessage = null;
    notifyListeners();

    if (email.isEmpty || password.isEmpty) {
      _errorMessage = 'Lütfen e-posta ve şifre alanlarını doldurun.';
      notifyListeners();
      return;
    }

    _setLoading(true);

    try {
      final request = LoginRequestDto(email: email, password: password);
      final response = await _authRepository.login(request);

      if (response != null && response.token != null) {

        // 1. YENİ: Token'ı cihazın güvenli hafızasına kaydet
        // (Eğer authRepository içinde zaten kaydetmiyorsan bu satır API istekleri için şart!)
        await TokenManager.saveToken(response.token!);

        // 2. YENİ: Dashboard verilerini taze olarak çekmesini tetikle!
        // Bu sayede eski kullanıcının verileri ekranda kalmaz, yenileri anında yüklenir.
        ref.read(dashboardViewModelProvider).loadDashboardData(isRefresh: true);

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const NavigationBarView()),
          );
        }
      } else {
        _errorMessage = 'Giriş başarısız. Lütfen bilgilerinizi kontrol edin.';
      }
    } catch (e) {
      _errorMessage = 'E-posta veya şifre hatalı.';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
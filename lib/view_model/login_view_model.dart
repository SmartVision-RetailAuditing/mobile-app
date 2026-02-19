import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../repository/auth_repository.dart';
import '../model/login_request_dto.dart';
import '../view/navigation_bar_view.dart';

final loginViewModelProvider = ChangeNotifierProvider((ref) => LoginViewModel());

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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
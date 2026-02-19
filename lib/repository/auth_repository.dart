import '../model/login_request_dto.dart';
import '../model/login_response_dto.dart';
import '../model/change_password_dto.dart';
import '../service/api/api_auth_service.dart';
import '../service/base/auth_service.dart';
import '../base/auth_base.dart';

class AuthRepository implements AuthBase {
  // Servisimizi çağırıyoruz
  final AuthService _service = ApiAuthService();

  @override
  Future<LoginResponseDto?> login(LoginRequestDto request) async {
    // Burada API'den dönen cevabı (Token'ı) alıyoruz.
    final response = await _service.login(request);

    // İPUCU: Burada dönen response.token değerini
    // flutter_secure_storage paketi ile cihazın hafızasına kaydedebilirsin.

    return response;
  }

  @override
  Future<bool> changePassword(ChangePasswordDto request) async {
    return await _service.changePassword(request);
  }
}
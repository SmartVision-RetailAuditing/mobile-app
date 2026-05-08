import 'package:dio/dio.dart';
import '../../model/login_request_dto.dart';
import '../../model/login_response_dto.dart';
import '../../model/change_password_dto.dart';
import '../base/auth_service.dart';
import '../base/api_client.dart'; // Yeni merkezi ekledik
import '../../tools/token_manager.dart'; // Token yöneticisini ekledik

class ApiAuthService implements AuthService {
  // Artık kendi Dio'sunu değil, merkezdeki Dio'yu kullanıyor
  final Dio _dio = ApiClient().dio;

  @override
  Future<LoginResponseDto?> login(LoginRequestDto request) async {
    try {
      // BaseUrl merkezde olduğu için sadece '/Auth/login' yazıyoruz
      final response = await _dio.post(
        '/Auth/login',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponseDto.fromJson(response.data);

        // SİHİRLİ DOKUNUŞ: Token'ı telefonun güvenli hafızasına kaydediyoruz!
        if (loginResponse.token != null) {
          await TokenManager.saveToken(loginResponse.token!);
          print("Token başarıyla telefona kaydedildi!");
        }

        return loginResponse;
      } else {
        throw Exception("Giriş başarısız: ${response.statusCode}");
      }
    } catch (e) {
      print("Login API Hatası: $e");
      rethrow;
    }
  }

  @override
  Future<bool> changePassword(ChangePasswordDto request) async {
    try {
      final response = await _dio.post(
        '/Auth/change-password',
        data: request.toJson(),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Şifre Değiştirme API Hatası: $e");
      return false;
    }
  }
}
import '../model/login_request_dto.dart';
import '../model/login_response_dto.dart';
import '../model/change_password_dto.dart';

abstract class AuthBase {
  Future<LoginResponseDto?> login(LoginRequestDto request);
  Future<bool> changePassword(ChangePasswordDto request);
}
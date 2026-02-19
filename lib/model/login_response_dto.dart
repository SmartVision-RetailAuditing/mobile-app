class LoginResponseDto {
  final String? token;

  LoginResponseDto({this.token});

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      token: json['token'] as String?,
    );
  }
}
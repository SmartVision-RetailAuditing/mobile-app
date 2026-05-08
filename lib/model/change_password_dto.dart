class ChangePasswordDto {
  final String oldPassword;
  final String newPassword;

  ChangePasswordDto({
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };
  }
}
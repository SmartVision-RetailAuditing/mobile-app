import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_vision_mobile/providers.dart';
import 'package:smart_vision_mobile/tools/AppColors.dart';
import 'package:smart_vision_mobile/tools/AppIcons.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);

    // 1. Temayı Dinle
    final currentTheme = ref.watch(themeModeProvider);
    final isDark = currentTheme == ThemeMode.dark;

    // 2. Renkleri Dinamik Hale Getir
    // Eğer karanlık mod ise koyu renkler, değilse AppColors renkleri
    final Color kBgColor = isDark ? const Color(0xFF121212) : AppColors.colorWhite;
    final Color kCardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color kPrimaryBlue = AppColors.colorPrimaryBlue; // Bu genelde değişmez
    final Color kTextColor = isDark ? Colors.white : AppColors.colorText;
    final Color kSubTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    final Color kIconBgColor = isDark ? const Color(0xFF2C2C2C) : AppColors.colorWhite;

    final Color kGradientStart = AppColors.colorGradientStart;
    final Color kGradientEnd = AppColors.colorGradientEnd;

    return Scaffold(
      backgroundColor: kBgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, user, kTextColor, kPrimaryBlue, kGradientStart, kGradientEnd, kCardColor, kSubTextColor),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // YENİ: Tema Değiştirme Kartı
                  _buildThemeSwitchCard(isDark, ref, kCardColor, kTextColor),
                  const SizedBox(height: 12),

                  _buildPersonalInfoCard(user, kTextColor, kPrimaryBlue, kIconBgColor, kCardColor, kSubTextColor),
                  const SizedBox(height: 12),
                  _buildWeeklyTasksCard(user['stats'], kTextColor, kPrimaryBlue, kCardColor, kIconBgColor, kSubTextColor),
                  const SizedBox(height: 12),
                  _buildLogoutButton(kCardColor),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- YENİ EKLENEN KISIM: Tema Değiştirme Kartı ---
  Widget _buildThemeSwitchCard(bool isDark, WidgetRef ref, Color kCardColor, Color kTextColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: _cardDecoration(kCardColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: AppColors.colorPrimaryBlue),
              const SizedBox(width: 12),
              Text(
                'Karanlık Mod',
                style: TextStyle(
                    color: kTextColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 16
                ),
              ),
            ],
          ),
          Switch(
            value: isDark,
            activeColor: AppColors.colorPrimaryBlue,
            onChanged: (value) {
              // Provider'ı güncelle
              ref.read(themeModeProvider.notifier).state =
              value ? ThemeMode.dark : ThemeMode.light;
            },
          ),
        ],
      ),
    );
  }

  // Header Parametrelerini Güncelledim (kCardColor ve kSubTextColor eklendi)
  Widget _buildHeader(BuildContext context, Map<String, dynamic> user, Color kTextColor, Color kPrimaryBlue, Color kGradientStart, Color kGradientEnd, Color kCardColor, Color kSubTextColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 24,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: kCardColor, // Dinamik Renk
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _buildHeaderText(kTextColor),
          ),
          const SizedBox(height: 24),
          _buildUserIcon(kGradientStart, kGradientEnd, kPrimaryBlue),
          const SizedBox(height: 16),
          _buildUserName(user, kTextColor),
          const SizedBox(height: 4),
          _buildUserRole(user, kSubTextColor),
        ],
      ),
    );
  }

  Widget _buildHeaderText(Color kTextColor) {
    return Text(
      'Profil',
      style: TextStyle(
        color: kTextColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildUserIcon(Color kGradientStart, kGradientEnd, Color kPrimaryBlue) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kGradientStart, kGradientEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: kPrimaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: AppIcons.iconUser,
    );
  }

  Widget _buildUserName(Map<String, dynamic> user, Color kTextColor) {
    return Text(
      user['name'],
      style: TextStyle(
        color: kTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildUserRole(Map<String, dynamic> user, Color kSubTextColor) {
    return Text(
      user['role'],
      style: TextStyle(
        color: kSubTextColor, // Dinamik Renk
        fontSize: 14,
      ),
    );
  }

  // Arka plan rengini (kBgColor) parametresini kIconBgColor olarak değiştirdim çünkü kartın içi ile genel arka plan farklı olabilir
  Widget _buildPersonalInfoCard(Map<String, dynamic> user, Color kTextColor, Color kPrimaryBlue, Color kIconBgColor, Color kCardColor, Color kSubTextColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(kCardColor), // Dinamik
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kişisel Bilgiler',
            style: TextStyle(
              color: kTextColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(AppIcons.iconUser.icon!, 'Ad Soyad', user['name'], kTextColor, kPrimaryBlue, kIconBgColor, kSubTextColor),
          const SizedBox(height: 12),
          _buildInfoRow(AppIcons.iconId.icon!, 'Çalışan ID', user['id'], kTextColor, kPrimaryBlue, kIconBgColor, kSubTextColor),
          const SizedBox(height: 12),
          _buildInfoRow(AppIcons.iconRole.icon!, 'Rol', user['role'], kTextColor, kPrimaryBlue, kIconBgColor, kSubTextColor),
          const SizedBox(height: 12),
          _buildInfoRow(AppIcons.iconMail.icon!, 'E-posta', user['email'], kTextColor, kPrimaryBlue, kIconBgColor, kSubTextColor),
          const SizedBox(height: 12),
          _buildInfoRow(AppIcons.iconPhone.icon!, 'Telefon', user['phone'], kTextColor, kPrimaryBlue, kIconBgColor, kSubTextColor),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color kTextColor, Color kPrimaryBlue, Color kIconBgColor, Color kSubTextColor) {
    return Row(
      children: [
        _buildInfoIcon(kIconBgColor, icon, kPrimaryBlue),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoText(label, value, kTextColor, kSubTextColor),
        ),
      ],
    );
  }

  Widget _buildInfoIcon(Color kIconBgColor, IconData icon, Color kPrimaryBlue) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: kIconBgColor, // Dinamik
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: kPrimaryBlue, size: 20),
    );
  }

  Widget _buildInfoText(String label, String value, Color kTextColor, Color kSubTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: kSubTextColor, fontSize: 12), // Dinamik
        ),
        Text(
          value,
          style: TextStyle(
            color: kTextColor, // Dinamik
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildWeeklyTasksCard(Map<String, dynamic> stats, Color kTextColor, Color kPrimaryBlue, Color kCardColor, Color kIconBgColor, Color kSubTextColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(kCardColor),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 20, color: kPrimaryBlue),
                  const SizedBox(width: 8),
                  Text(
                    'Haftalık Görevlerim',
                    style: TextStyle(
                      color: kTextColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Icon(Icons.chevron_right, color: kSubTextColor, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTaskStatBox(stats['total'], 'Toplam', kTextColor, kIconBgColor, kSubTextColor),
              const SizedBox(width: 12),
              // Renkli kutular (Yeşil ve Turuncu) için dark mode'da çok parlak olmasın diye opaklık ayarı yapılabilir ama şimdilik standart bırakıyorum
              _buildTaskStatBox(stats['done'], 'Tamamlandı', Colors.green.shade600, Colors.green.shade50, kSubTextColor),
              const SizedBox(width: 12),
              _buildTaskStatBox(stats['pending'], 'Bekliyor', Colors.orange.shade600, Colors.orange.shade50, kSubTextColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStatBox(String count, String label, Color textColor, Color bgColor, Color kSubTextColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: kSubTextColor, fontSize: 11), // Text rengi hardcoded gridi, düzelttim
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(Color kCardColor) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          debugPrint("Çıkış yapıldı");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kCardColor, // Dinamik
          foregroundColor: Colors.red.shade600,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _buildLogoutButtonContainer(),
      ),
    );
  }

  Widget _buildLogoutButtonContainer() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(AppIcons.iconLogout.icon!, size: 20, color: Colors.red.shade600),
          const SizedBox(width: 8),
          const Text(
            'Çıkış Yap',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // Box decoration'ı da dinamik hale getirdik
  BoxDecoration _cardDecoration(Color cardColor) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
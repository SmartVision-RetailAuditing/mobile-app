import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_vision_mobile/providers.dart';
import 'package:smart_vision_mobile/tools/AppColors.dart';
import 'package:smart_vision_mobile/tools/AppIcons.dart';
import '../view_model/profile_view_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileDataProvider);

    final currentTheme = ref.watch(themeModeProvider);
    final isDark = currentTheme == ThemeMode.dark;

    final Color kBgColor = isDark ? const Color(0xFF121212) : AppColors.colorWhite;
    final Color kCardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color kPrimaryBlue = AppColors.colorPrimaryBlue;
    final Color kTextColor = isDark ? Colors.white : AppColors.colorText;
    final Color kSubTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade500;
    final Color kIconBgColor = isDark ? const Color(0xFF2C2C2C) : AppColors.colorWhite;
    final Color kGradientStart = AppColors.colorGradientStart;
    final Color kGradientEnd = AppColors.colorGradientEnd;

    return Scaffold(
      backgroundColor: kBgColor,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Veriler yüklenirken bir hata oluştu: $error', style: TextStyle(color: kTextColor)),
              const SizedBox(height: 16),
              _buildLogoutButton(context, ref, kCardColor),
            ],
          ),
        ),
        data: (data) {
          final profile = data.profile;
          final stats = data.stats.weeklyTasks;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Parametrelere ref eklendi
                _buildHeader(context, ref, profile, kTextColor, kPrimaryBlue, kGradientStart, kGradientEnd, kCardColor, kSubTextColor),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildThemeSwitchCard(isDark, ref, kCardColor, kTextColor),
                      const SizedBox(height: 12),
                      // Parametrelere ref eklendi
                      _buildPersonalInfoCard(ref, profile, kTextColor, kPrimaryBlue, kIconBgColor, kCardColor, kSubTextColor),
                      const SizedBox(height: 12),
                      _buildWeeklyTasksCard(stats, kTextColor, kPrimaryBlue, kCardColor, kIconBgColor, kSubTextColor),
                      const SizedBox(height: 12),
                      _buildLogoutButton(context, ref, kCardColor),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, dynamic profile, Color kTextColor, Color kPrimaryBlue, Color kGradientStart, Color kGradientEnd, Color kCardColor, Color kSubTextColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 24,
        left: 24,
        right: 24,
      ),
      decoration: BoxDecoration(
        color: kCardColor,
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
            child: Text('Profil', style: TextStyle(color: kTextColor, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 24),
          _buildUserIcon(kGradientStart, kGradientEnd, kPrimaryBlue),
          const SizedBox(height: 16),
          Text(profile.fullName ?? 'İsimsiz Kullanıcı', style: TextStyle(color: kTextColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          // Rol formatlama işlemi ViewModel üzerinden yapılıyor:
          Text(ref.read(profileViewModelProvider).formatRole(profile.role), style: TextStyle(color: kSubTextColor, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildUserIcon(Color kGradientStart, Color kGradientEnd, Color kPrimaryBlue) {
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
          BoxShadow(color: kPrimaryBlue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: AppIcons.iconUser,
    );
  }

  Widget _buildPersonalInfoCard(WidgetRef ref, dynamic profile, Color kTextColor, Color kPrimaryBlue, Color kIconBgColor, Color kCardColor, Color kSubTextColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(kCardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kişisel Bilgiler', style: TextStyle(color: kTextColor, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildInfoRow(AppIcons.iconUser.icon!, 'Ad Soyad', profile.fullName ?? '-', kTextColor, kPrimaryBlue, kIconBgColor, kSubTextColor),
          const SizedBox(height: 12),
          // Rol formatlama işlemi ViewModel üzerinden yapılıyor:
          _buildInfoRow(AppIcons.iconRole.icon!, 'Rol', ref.read(profileViewModelProvider).formatRole(profile.role), kTextColor, kPrimaryBlue, kIconBgColor, kSubTextColor),
          const SizedBox(height: 12),
          _buildInfoRow(AppIcons.iconMail.icon!, 'E-posta', profile.email ?? '-', kTextColor, kPrimaryBlue, kIconBgColor, kSubTextColor),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color kTextColor, Color kPrimaryBlue, Color kIconBgColor, Color kSubTextColor) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: kIconBgColor, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: kPrimaryBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: kSubTextColor, fontSize: 12)),
              Text(value, style: TextStyle(color: kTextColor, fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyTasksCard(dynamic stats, Color kTextColor, Color kPrimaryBlue, Color kCardColor, Color kIconBgColor, Color kSubTextColor) {
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
                  Text('Haftalık Görevlerim', style: TextStyle(color: kTextColor, fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTaskStatBox(stats?.total?.toString() ?? '0', 'Toplam', kTextColor, kIconBgColor, kSubTextColor),
              const SizedBox(width: 12),
              _buildTaskStatBox(stats?.completed?.toString() ?? '0', 'Tamamlandı', Colors.green.shade600, Colors.green.shade50, kSubTextColor),
              const SizedBox(width: 12),
              _buildTaskStatBox(stats?.pending?.toString() ?? '0', 'Bekliyor', Colors.orange.shade600, Colors.orange.shade50, kSubTextColor),
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
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(count, style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: kSubTextColor, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref, Color kCardColor) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => ref.read(profileViewModelProvider).logout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: kCardColor,
          foregroundColor: Colors.red.shade600,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.iconLogout.icon!, size: 20, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text('Çıkış Yap', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

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
              Text('Karanlık Mod', style: TextStyle(color: kTextColor, fontWeight: FontWeight.w500, fontSize: 16)),
            ],
          ),
          Switch(
            value: isDark,
            activeColor: AppColors.colorPrimaryBlue,
            // DEĞİŞEN KISIM BURASI: Artık ViewModel'deki fonksiyonu çağırıyoruz
            onChanged: (value) => ref.read(profileViewModelProvider).toggleTheme(value),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(Color cardColor) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
    );
  }
}
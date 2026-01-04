import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_vision_mobile/providers.dart';
import 'package:smart_vision_mobile/view/profile_view.dart';
import 'package:smart_vision_mobile/view/task_view.dart';
import '../tools/AppIcons.dart';
import 'camera_view.dart';
import 'dashboard_view.dart';
import 'map_view.dart';

class NavigationBarView extends ConsumerWidget {
  const NavigationBarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final selectedIndex = ref.watch(navIndexProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> pages = [
      const TaskScreen(),
      const MapScreen(),
      CameraScreen(
        onComplete: () {
          ref.read(navIndexProvider.notifier).state = 3;
        },
      ),
      const DashboardScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBarContainer(ref, selectedIndex, isDark),
    );
  }

  Widget _buildBottomNavigationBarContainer(WidgetRef ref, int selectedIndex, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: _buildBottomNavigationBar(ref, selectedIndex),
    );
  }

  Widget _buildBottomNavigationBar(WidgetRef ref, int selectedIndex) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      onTap: (index) {
        ref.read(navIndexProvider.notifier).state = index;
      },
      elevation: 0,
      items: _navItems,
    );
  }

  List<BottomNavigationBarItem> get _navItems {
    return const [
      BottomNavigationBarItem(icon: AppIcons.iconTask, label: 'Görevler'),
      BottomNavigationBarItem(icon: AppIcons.iconMap, label: 'Harita'),
      BottomNavigationBarItem(icon: AppIcons.iconCamera, label: 'Kamera'),
      BottomNavigationBarItem(icon: AppIcons.iconDashboard, label: 'Dashboard'),
      BottomNavigationBarItem(icon: AppIcons.iconProfile, label: 'Profil'),
    ];
  }
}
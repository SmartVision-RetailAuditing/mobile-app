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

    // DEĞİŞEN KISIM: Artık genişliğe değil, cihazın yatay/dikey tutulduğuna bakıyoruz!
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    final List<Widget> pages = [
      const TaskScreen(),
      const MapScreen(),
      const CameraScreen(),
      const DashboardScreen(),
      const ProfileScreen(),
    ];

    final bodyContent = IndexedStack(
      index: selectedIndex,
      children: pages,
    );

    // EĞER CİHAZ YATAY TUTULUYORSA (TABLET YAN VEYA TELEFON YAN) -> SOL MENÜ
    if (isLandscape) {
      return Scaffold(
        body: Row(
          children: [
            _buildNavigationRail(context, ref, selectedIndex),
            VerticalDivider(thickness: 1, width: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
            Expanded(child: bodyContent),
          ],
        ),
      );
    }

    // EĞER CİHAZ DİKEY TUTULUYORSA (TABLET DİK VEYA TELEFON DİK) -> ALT MENÜ
    return Scaffold(
      body: bodyContent,
      bottomNavigationBar: _buildBottomNavigationBarContainer(ref, selectedIndex, isDark),
    );
  }

  // --- SOL MENÜ (RAIL) TASARIMI ---
  Widget _buildNavigationRail(BuildContext context, WidgetRef ref, int selectedIndex) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        ref.read(navIndexProvider.notifier).state = index;
      },
      labelType: NavigationRailLabelType.all,
      useIndicator: true,
      indicatorColor: Theme.of(context).primaryColor.withOpacity(0.1),
      selectedLabelTextStyle: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelTextStyle: const TextStyle(fontSize: 12),
      destinations: _railItems,
    );
  }

  // --- ALT MENÜ TASARIMI ---
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

  // --- ALT MENÜ İKONLARI ---
  List<BottomNavigationBarItem> get _navItems {
    return const [
      BottomNavigationBarItem(icon: AppIcons.iconTask, label: 'Görevler'),
      BottomNavigationBarItem(icon: AppIcons.iconMap, label: 'Harita'),
      BottomNavigationBarItem(icon: AppIcons.iconCamera, label: 'Kamera'),
      BottomNavigationBarItem(icon: AppIcons.iconDashboard, label: 'Dashboard'),
      BottomNavigationBarItem(icon: AppIcons.iconProfile, label: 'Profil'),
    ];
  }

  // --- SOL MENÜ İKONLARI (NavigationRail için özel yapı) ---
  List<NavigationRailDestination> get _railItems {
    return const [
      NavigationRailDestination(icon: AppIcons.iconTask, label: Text('Görevler')),
      NavigationRailDestination(icon: AppIcons.iconMap, label: Text('Harita')),
      NavigationRailDestination(icon: AppIcons.iconCamera, label: Text('Kamera')),
      NavigationRailDestination(icon: AppIcons.iconDashboard, label: Text('Dashboard')),
      NavigationRailDestination(icon: AppIcons.iconProfile, label: Text('Profil')),
    ];
  }
}
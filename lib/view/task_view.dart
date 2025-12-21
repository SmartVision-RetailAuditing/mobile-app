import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Task;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riverpod/src/framework.dart' hide Task;
import 'package:smart_vision_mobile/providers.dart';
import 'package:smart_vision_mobile/model/task.dart';
import '../tools/AppColors.dart';
import '../view_model/map_view_model.dart';

class TaskScreen extends ConsumerWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(taskTabProvider);
    final selectedDate = ref.watch(taskDateProvider);
    final allTasks = ref.watch(taskListProvider);

    final filteredTasks = activeTab == 'active'
        ? allTasks.where((t) => t.status == 'Pending').toList()
        : allTasks.where((t) => t.status == 'Done').toList();

    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 380;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, ref, activeTab, selectedDate, allTasks, isSmallScreen),
            Expanded(
              child: _buildTaskList(ref, filteredTasks, isSmallScreen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context,
      WidgetRef ref,
      String activeTab,
      DateTime selectedDate,
      List<Task> allTasks,
      bool isSmallScreen,
      ) {

    final kCardColor = Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: kCardColor,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildHeaderText(context, isSmallScreen),
          const SizedBox(height: 16),
          _buildDatePicker(context, ref, selectedDate),
          const SizedBox(height: 16),
          _buildTaskButtons(context, ref, activeTab, allTasks, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildTaskButtons(
      BuildContext context,
      WidgetRef ref,
      String activeTab,
      List<Task> allTasks,
      bool isSmallScreen,
      ) {

    final kInactiveColor = Theme.of(context).scaffoldBackgroundColor;

    return Row(
      children: [
        Expanded(
          child: _buildTabButton(
            context: context,
            title: 'Aktif (${allTasks.where((t) => t.status == 'Pending').length})',
            isActive: activeTab == 'active',
            isSmallScreen: isSmallScreen,
            kBgColor: kInactiveColor,
            onTap: () => ref.read(taskTabProvider.notifier).state = 'active',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTabButton(
            context: context,
            title: 'Geçmiş (${allTasks.where((t) => t.status == 'Done').length})',
            isActive: activeTab == 'history',
            isSmallScreen: isSmallScreen,
            kBgColor: kInactiveColor,
            onTap: () => ref.read(taskTabProvider.notifier).state = 'history',
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderText(BuildContext context, bool isSmallScreen) {
    final kTextColor = Theme.of(context).textTheme.bodyMedium!.color;

    return Text(
      'Görevler',
      style: TextStyle(
        color: kTextColor,
        fontSize: isSmallScreen ? 24 : 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, WidgetRef ref, DateTime selectedDate) {
    String dateText = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    final kPrimaryBlue = AppColors.colorPrimaryBlue;
    final kTextColor = Theme.of(context).textTheme.bodyMedium!.color;
    final kInputBg = Theme.of(context).scaffoldBackgroundColor; // Input zemini

    return GestureDetector(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(primary: kPrimaryBlue),
                ),
                child: child!,
              );
            }
        );
        if (picked != null) {
          ref.read(taskDateProvider.notifier).state = picked;
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kInputBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: kPrimaryBlue, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dateText,
                style: TextStyle(color: kTextColor, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required BuildContext context,
    required String title,
    required bool isActive,
    required bool isSmallScreen,
    required VoidCallback onTap,
    required Color kBgColor,
  }) {
    final kPrimaryBlue = AppColors.colorPrimaryBlue;
    final kGrayText = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade400
        : AppColors.colorTextGray;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? kPrimaryBlue : kBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isActive ? Colors.white : kGrayText,
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 12 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(WidgetRef ref, List<Task> tasks, bool isSmallScreen) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildTaskCard(context, ref, tasks[index], isSmallScreen);
      },
    );
  }

  Widget _buildTaskCard(BuildContext context, WidgetRef ref, Task task, bool isSmallScreen) {
    bool isDone = task.status == 'Done';

    final kCardColor = Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildTaskCardColumn(context, ref, task, isSmallScreen, isDone),
    );
  }

  Widget _buildTaskCardColumn(BuildContext context, WidgetRef ref, Task task, bool isSmallScreen, bool isDone) {
    final kTextColor = Theme.of(context).textTheme.bodyMedium!.color;
    final kPrimaryBlue = AppColors.colorPrimaryBlue;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMarketName(task, kTextColor!, isSmallScreen),
                  const SizedBox(height: 6),
                  _buildLocation(context, task),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusBadge(isDone),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoRow(context, 'Görev Tipi', task.taskType, kTextColor!),
        const SizedBox(height: 8),
        _buildInfoRow(context, 'Son Tarih', task.dueDate, kTextColor),
        const SizedBox(height: 8),
        _buildInfoRow(context, 'Sıklık', task.frequency, kTextColor),
        if (!isDone) ...[
          const SizedBox(height: 16),
          _buildMapButton(ref, kPrimaryBlue),
        ]
      ],
    );
  }

  Widget _buildMarketName(Task task, Color kTextColor, bool isSmallScreen) {
    return Text(
      task.marketName,
      style: TextStyle(
        color: kTextColor,
        fontWeight: FontWeight.bold,
        fontSize: isSmallScreen ? 15 : 17,
      ),
    );
  }

  Widget _buildLocation(BuildContext context, Task task) {
    final kGrayText = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade400
        : Colors.grey;

    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 14, color: kGrayText),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            task.address,
            style: TextStyle(color: kGrayText, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMapButton(WidgetRef ref, Color kPrimaryBlue) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final mockTarget = const LatLng(38.4583, 27.0996);
          await ref.read(mapViewModelProvider as ProviderListenable).setTargetLocation(mockTarget);
          ref.read(navIndexProvider.notifier).state = 1;
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
        ),
        child: const Text('Göreve Git', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, Color kTextColor) {
    final kGrayText = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade400
        : Colors.grey;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: kGrayText, fontSize: 14),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: kTextColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isDone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDone ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isDone ? 'Tamamlandı' : 'Bekliyor',
        style: TextStyle(
          color: isDone ? Colors.green.shade700 : Colors.orange.shade800,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
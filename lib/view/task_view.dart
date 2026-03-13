import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_vision_mobile/providers.dart'; // NavIndexProvider için
import '../model/task_dto.dart';
import '../tools/AppColors.dart';
import '../view_model/map_view_model.dart';
import '../view_model/task_view_model.dart';

// 1. DEĞİŞİKLİK: ScrollController kullanabilmek için ConsumerStatefulWidget'a geçtik.
class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key});

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen> {
  // 2. DEĞİŞİKLİK: Kullanıcının ne kadar kaydırdığını takip eden dinleyici
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Liste aşağı kaydırıldığında tetiklenecek olay
    _scrollController.addListener(() {
      // Eğer listenin en altına (veya 100 piksel yakınına) ulaşıldıysa yeni sayfa çek
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
        ref.read(taskListProvider.notifier).fetchMoreTasks();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(taskTabProvider);
    // 3. DEĞİŞİKLİK: Artık AsyncValue (.when) değil, kendi yazdığımız TaskListState'i dinliyoruz
    final taskState = ref.watch(taskListProvider);

    final Size screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 380;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            // İlk yükleme ekranı
            if (taskState.isLoading && taskState.tasks.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // Hata ekranı
            if (taskState.error != null && taskState.tasks.isEmpty) {
              return Center(child: Text('Görevler yüklenemedi: ${taskState.error}'));
            }

            // Verileri ayıklama
            final allTasks = taskState.tasks;
            final pendingTasks = allTasks.where((t) => t.status != 'COMPLETED').toList();
            final doneTasks = allTasks.where((t) => t.status == 'COMPLETED').toList();

            final filteredTasks = activeTab == 'active' ? pendingTasks : doneTasks;

            return Column(
              children: [
                _buildHeader(context, ref, activeTab, pendingTasks.length, doneTasks.length, isSmallScreen),
                Expanded(
                  child: filteredTasks.isEmpty
                      ? const Center(child: Text("Bu sekmede görev bulunmuyor."))
                  // 4. DEĞİŞİKLİK: Listeye controller'ı ve isLoadingMore bilgisini gönderiyoruz
                      : _buildTaskList(ref, filteredTasks, isSmallScreen, taskState.isLoadingMore),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- HEADER VE BUTONLAR AYNEN KALIYOR ---
  Widget _buildHeader(BuildContext context, WidgetRef ref, String activeTab, int pendingCount, int doneCount, bool isSmallScreen) {
    final kCardColor = Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05, vertical: 16),
      decoration: BoxDecoration(
        color: kCardColor,
        boxShadow: [
          BoxShadow(color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildHeaderText(context, isSmallScreen),
          const SizedBox(height: 20),
          _buildTaskButtons(context, ref, activeTab, pendingCount, doneCount, isSmallScreen),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildTaskButtons(BuildContext context, WidgetRef ref, String activeTab, int pendingCount, int doneCount, bool isSmallScreen) {
    final kInactiveColor = Theme.of(context).scaffoldBackgroundColor;

    return Row(
      children: [
        Expanded(
          child: _buildTabButton(
            context: context,
            title: 'Aktif ($pendingCount)',
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
            title: 'Geçmiş ($doneCount)',
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
    return Text('Görevler', style: TextStyle(color: kTextColor, fontSize: isSmallScreen ? 24 : 28, fontWeight: FontWeight.bold));
  }

  Widget _buildTabButton({required BuildContext context, required String title, required bool isActive, required bool isSmallScreen, required VoidCallback onTap, required Color kBgColor}) {
    final kPrimaryBlue = AppColors.colorPrimaryBlue;
    final kGrayText = Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : AppColors.colorTextGray;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: isActive ? kPrimaryBlue : kBgColor, borderRadius: BorderRadius.circular(12)),
        alignment: Alignment.center,
        child: Text(
          title, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: TextStyle(color: isActive ? Colors.white : kGrayText, fontWeight: FontWeight.w500, fontSize: isSmallScreen ? 12 : 14),
        ),
      ),
    );
  }

  // 5. DEĞİŞİKLİK: Listeyi güncelledik (Controller eklendi ve en alta yükleniyor animasyonu kondu)
  Widget _buildTaskList(WidgetRef ref, List<TaskDto> tasks, bool isSmallScreen, bool isLoadingMore) {
    return ListView.separated(
      controller: _scrollController, // Controller'ı bağladık
      padding: const EdgeInsets.all(16),
      // Eğer arkadan yeni veri yükleniyorsa listeye +1 eleman ekliyoruz (ProgressIndicator için)
      itemCount: tasks.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        // Eğer listenin sonuna geldiysek ve yükleniyorsa dönen animasyonu göster
        if (index == tasks.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildTaskCard(context, ref, tasks[index], isSmallScreen);
      },
    );
  }

  // --- KART TASARIMLARI AYNEN KALIYOR ---
  Widget _buildTaskCard(BuildContext context, WidgetRef ref, TaskDto task, bool isSmallScreen) {
    bool isDone = task.status == 'COMPLETED';
    final kCardColor = Theme.of(context).cardColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: _buildTaskCardColumn(context, ref, task, isSmallScreen, isDone),
    );
  }

  Widget _buildTaskCardColumn(BuildContext context, WidgetRef ref, TaskDto task, bool isSmallScreen, bool isDone) {
    final kTextColor = Theme.of(context).textTheme.bodyMedium!.color;
    final kPrimaryBlue = AppColors.colorPrimaryBlue;
    final viewModel = ref.read(taskViewModelProvider);

    String formattedDate = "Tarih Yok";
    if (task.dueDate != null) {
      try {
        final parsedDate = DateTime.parse(task.dueDate!);
        formattedDate = "${parsedDate.day.toString().padLeft(2, '0')}.${parsedDate.month.toString().padLeft(2, '0')}.${parsedDate.year}";
      } catch (e) {
        formattedDate = task.dueDate!;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMarketName(task.storeName ?? "Bilinmeyen Mağaza", kTextColor!, isSmallScreen),
                  const SizedBox(height: 6),
                  _buildLocation(context, task.storeAddress ?? "-"),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildStatusBadge(isDone),
          ],
        ),
        const SizedBox(height: 16),
        _buildInfoRow(context, 'Görev Tipi', viewModel.formatTaskType(task.taskType), kTextColor!),
        const SizedBox(height: 8),
        _buildInfoRow(context, 'Öncelik', viewModel.formatPriority(task.priority), kTextColor),
        const SizedBox(height: 8),
        _buildInfoRow(context, 'Son Tarih', formattedDate, kTextColor),

        if (task.description != null && task.description!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(task.description!, style: TextStyle(color: kTextColor.withOpacity(0.8), fontSize: 13, fontStyle: FontStyle.italic)),
        ],

        if (!isDone) ...[
          const SizedBox(height: 16),
          _buildActionButtons(context, ref, task, kPrimaryBlue),
        ]
      ],
    );
  }

  Widget _buildMarketName(String name, Color kTextColor, bool isSmallScreen) {
    return Text(name, style: TextStyle(color: kTextColor, fontWeight: FontWeight.bold, fontSize: isSmallScreen ? 15 : 17));
  }

  Widget _buildLocation(BuildContext context, String address) {
    final kGrayText = Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey;
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 14, color: kGrayText),
        const SizedBox(width: 4),
        Expanded(
          child: Text(address, style: TextStyle(color: kGrayText, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, Color kTextColor) {
    final kGrayText = Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade400 : Colors.grey;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: kGrayText, fontSize: 14)),
        const SizedBox(width: 16),
        Flexible(
          child: Text(value, textAlign: TextAlign.right, style: TextStyle(color: kTextColor, fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isDone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: isDone ? Colors.green.shade100 : Colors.orange.shade100, borderRadius: BorderRadius.circular(20)),
      child: Text(
        isDone ? 'Tamamlandı' : 'Bekliyor',
        style: TextStyle(color: isDone ? Colors.green.shade700 : Colors.orange.shade800, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, TaskDto task, Color kPrimaryBlue) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              if (task.latitude != null && task.longitude != null) {
                final targetLocation = LatLng(task.latitude!, task.longitude!);
                await ref.read(mapViewModelProvider.notifier).setTargetLocation(targetLocation);
                ref.read(navIndexProvider.notifier).state = 1;
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
            icon: const Icon(Icons.map_outlined, size: 18),
            label: const Text('Göreve Git', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ref.read(activeTaskProvider.notifier).state = task;
              ref.read(navIndexProvider.notifier).state = 2;
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 0,
            ),
            icon: const Icon(Icons.camera_alt_outlined, size: 18),
            label: const Text('Kamera', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}
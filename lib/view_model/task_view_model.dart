import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../model/update_task_dto.dart';
import '../repository/task_repository.dart';
import '../model/task_dto.dart';

// 1. DURUM (STATE) SINIFI: Sayfalama için gerekli değişkenleri tutar
class TaskListState {
  final List<TaskDto> tasks;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int page;
  final bool hasMore;

  TaskListState({
    this.tasks = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.error,
    this.page = 1,
    this.hasMore = true,
  });

  TaskListState copyWith({
    List<TaskDto>? tasks,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? page,
    bool? hasMore,
  }) {
    return TaskListState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// 2. STATE NOTIFIER: Mantığı ve verileri yönetir
class TaskListNotifier extends StateNotifier<TaskListState> {
  final TaskRepository _repository = TaskRepository();

  TaskListNotifier() : super(TaskListState()) {
    fetchInitialTasks();
  }

  Future<void> fetchInitialTasks() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final tasks = await _repository.getMyTasks(page: 1, size: 50);
      state = state.copyWith(
        tasks: tasks,
        isLoading: false,
        page: 1,
        hasMore: tasks.length == 50,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchMoreTasks() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.page + 1;
      final newTasks = await _repository.getMyTasks(page: nextPage, size: 50);

      state = state.copyWith(
        tasks: [...state.tasks, ...newTasks],
        isLoadingMore: false,
        page: nextPage,
        hasMore: newTasks.length == 50,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  void refresh() {
    fetchInitialTasks();
  }
}

// 3. PROVIDER GÜNCELLEMESİ
final taskListProvider = StateNotifierProvider.autoDispose<TaskListNotifier, TaskListState>((ref) {
  return TaskListNotifier();
});

final taskTabProvider = StateProvider<String>((ref) => 'active');

final taskViewModelProvider = Provider((ref) => TaskViewModel());

class TaskViewModel {
  final TaskRepository _repository = TaskRepository();

  // --- YENİ EKLENEN ÇEVİRİCİLER (STRING -> INT) ---
  int _mapTaskTypeToInt(String? type) {
    if (type == null) return 0;
    switch (type.toUpperCase()) {
      case 'SHELF_AUDIT': return 0;
      case 'PRICE_CHECK': return 1;
      case 'PANORAMA': return 2;
      case 'PLANOGRAM_COMPLIANCE': return 3;
      default: return 0;
    }
  }

  int _mapPriorityToInt(String? priority) {
    if (priority == null) return 0;
    switch (priority.toUpperCase()) {
      case 'LOW': return 0;
      case 'MEDIUM': return 1;
      case 'HIGH': return 2;
      default: return 0;
    }
  }
  // ------------------------------------------------

  Future<bool> completeTask(TaskDto task) async {
    // YENİ DEĞİŞİKLİK: Çeviricileri kullanarak updateData'yı tam ve sayısal olarak hazırlıyoruz
    final updateData = UpdateTaskDto(
      storeId: task.storeId,
      userId: task.userId,
      dueDate: task.dueDate,
      description: task.description,
      taskType: _mapTaskTypeToInt(task.taskType),
      priority: _mapPriorityToInt(task.priority),
      status: 2, // 'COMPLETED' durumunun backend'deki sayısal karşılığı
    );

    return await _repository.updateTask(task.id!, updateData);
  }

  String formatTaskType(String? type) {
    if (type == null) return 'Bilinmeyen Görev';
    switch (type.toUpperCase()) {
      case 'SHELF_AUDIT': return 'Raf Kontrolü';
      case 'PRICE_CHECK': return 'Fiyat Etiketi Kontrolü';
      case 'PANORAMA': return 'Genel Panorama Çekimi';
      case 'PLANOGRAM_COMPLIANCE': return 'Planogram Uyumluluk';
      default: return type;
    }
  }

  String formatPriority(String? priority) {
    if (priority == null) return '-';
    switch (priority.toUpperCase()) {
      case 'HIGH': return 'Yüksek';
      case 'MEDIUM': return 'Orta';
      case 'LOW': return 'Düşük';
      default: return priority;
    }
  }

  String formatStatus(String? status) {
    if (status == null) return 'Bilinmiyor';
    switch (status.toUpperCase()) {
      case 'PENDING': return 'Bekliyor';
      case 'IN_PROGRESS': return 'Devam Ediyor';
      case 'COMPLETED': return 'Tamamlandı';
      default: return status;
    }
  }
}
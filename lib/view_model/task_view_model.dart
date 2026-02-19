import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../model/update_task_dto.dart';
import '../repository/task_repository.dart';
import '../model/task_dto.dart';

final taskListProvider = FutureProvider.autoDispose<List<TaskDto>>((ref) async {
  final repository = TaskRepository();
  return await repository.getMyTasks();
});

final taskTabProvider = StateProvider<String>((ref) => 'active');

// taskDateProvider buradan SİLİNDİ.

final taskViewModelProvider = Provider((ref) => TaskViewModel());

class TaskViewModel {
  final TaskRepository _repository = TaskRepository();

  Future<bool> completeTask(int taskId) async {
    // API'nin beklediği UpdateTaskDto nesnesini oluşturuyoruz
    final updateData = UpdateTaskDto(status: 2);
    return await _repository.updateTask(taskId, updateData);
  }

  String formatTaskType(String? type) {
    if (type == null) return 'Bilinmeyen Görev';
    switch (type.toUpperCase()) {
      case 'SHELF_AUDIT': return 'Raf Kontrolü';
      case 'PRICE_CHECK': return 'Fiyat Etiketi Kontrolü';
      case 'PANORAMA': return 'Genel Panorama Çekimi';
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
}
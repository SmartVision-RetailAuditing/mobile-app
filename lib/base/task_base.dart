import '../model/task_dto.dart';
import '../model/update_task_dto.dart';

abstract class TaskBase {
  Future<List<TaskDto>> getMyTasks();
  Future<TaskDto> getTaskById(int id);
  Future<bool> updateTask(int id, UpdateTaskDto updateData);
}
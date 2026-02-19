import '../model/task_dto.dart';
import '../model/update_task_dto.dart';
import '../service/api/api_task_service.dart';
import '../service/base/task_service.dart';
import '../base/task_base.dart';

class TaskRepository implements TaskBase {
  final TaskService _service = ApiTaskService();

  @override
  Future<List<TaskDto>> getMyTasks() async {
    return await _service.getMyTasks();
  }

  @override
  Future<TaskDto> getTaskById(int id) async {
    return await _service.getTaskById(id);
  }

  @override
  Future<bool> updateTask(int id, UpdateTaskDto updateData) async {
    return await _service.updateTask(id, updateData);
  }
}
import '../../domain/entities/task.dart';
import 'task_registry.dart';
import '../widgets/task_types/single_choice_widget.dart';
import '../widgets/task_types/dialogue_choice_widget.dart';

class TaskRegistryInitializer {
  static void initialize() {
    final registry = TaskRegistry();

    registry.registerAll({
      TaskType.singleChoice: (task, callbacks) =>
          SingleChoiceTaskWidget(task: task, callbacks: callbacks),
      TaskType.dialogueChoice: (task, callbacks) =>
          DialogueChoiceTaskWidget(task: task, callbacks: callbacks),
    });
  }
}

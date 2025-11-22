import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';

typedef TaskWidgetBuilder = Widget Function(
  Task task,
  TaskCallbacks callbacks,
);

class TaskCallbacks {
  final void Function(TaskResult result) onComplete;
  final void Function(String hint)? onHintRequested;
  final VoidCallback? onSkip;
  final void Function(int progress)? onProgressUpdate;

  const TaskCallbacks({
    required this.onComplete,
    this.onHintRequested,
    this.onSkip,
    this.onProgressUpdate,
  });
}

class TaskRegistry {
  static final TaskRegistry _instance = TaskRegistry._internal();
  factory TaskRegistry() => _instance;
  TaskRegistry._internal();

  final Map<TaskType, TaskWidgetBuilder> _builders = {};

  void register(TaskType type, TaskWidgetBuilder builder) {
    _builders[type] = builder;
  }

  void registerAll(Map<TaskType, TaskWidgetBuilder> builders) {
    _builders.addAll(builders);
  }

  Widget buildWidget(Task task, TaskCallbacks callbacks) {
    final builder = _builders[task.type];
    if (builder == null) {
      return UnsupportedTaskWidget(task: task);
    }
    return builder(task, callbacks);
  }

  bool isSupported(TaskType type) => _builders.containsKey(type);
}

class UnsupportedTaskWidget extends StatelessWidget {
  final Task task;

  const UnsupportedTaskWidget({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            'Тип задания "${task.type.name}" не поддерживается',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';
import '../core/task_registry.dart';

class TaskRenderer extends StatelessWidget {
  final Task task;
  final void Function(TaskResult) onTaskComplete;
  final VoidCallback? onSkip;

  const TaskRenderer({
    super.key,
    required this.task,
    required this.onTaskComplete,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final callbacks = TaskCallbacks(
      onComplete: onTaskComplete,
      onSkip: onSkip,
      onHintRequested: (hint) => _showHint(context, hint),
    );

    return TaskRegistry().buildWidget(task, callbacks);
  }

  void _showHint(BuildContext context, String hint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.amber),
            SizedBox(width: 8),
            Text('Подсказка'),
          ],
        ),
        content: Text(hint),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }
}

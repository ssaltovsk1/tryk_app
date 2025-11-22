import 'package:flutter/material.dart';

class LessonProgressBar extends StatelessWidget {
  final int currentTask;
  final int totalTasks;
  final double progress;

  const LessonProgressBar({
    super.key,
    required this.currentTask,
    required this.totalTasks,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Вопрос $currentTask из $totalTasks',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                '${(progress * 100).round()}%',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

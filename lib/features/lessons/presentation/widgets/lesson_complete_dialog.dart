import 'package:flutter/material.dart';

class LessonCompleteDialog extends StatelessWidget {
  final String lessonTitle;
  final int correctAnswers;
  final int totalTasks;
  final int score;
  final int percentage;
  final VoidCallback onContinue;

  const LessonCompleteDialog({
    super.key,
    required this.lessonTitle,
    required this.correctAnswers,
    required this.totalTasks,
    required this.score,
    required this.percentage,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final isPassed = percentage >= 70;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPassed ? Icons.emoji_events : Icons.refresh,
              size: 64,
              color: isPassed ? Colors.amber : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              isPassed ? 'Урок пройден!' : 'Попробуй еще раз!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              lessonTitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildStatRow(
                    context,
                    'Правильных ответов',
                    '$correctAnswers из $totalTasks',
                    Icons.check_circle,
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    context,
                    'Процент выполнения',
                    '$percentage%',
                    Icons.pie_chart,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    context,
                    'Заработано очков',
                    '$score',
                    Icons.star,
                    Colors.amber,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: Text(isPassed ? 'Продолжить' : 'Вернуться'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../tasks/domain/entities/lesson.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/widgets/task_renderer.dart';
import '../widgets/lesson_progress_bar.dart';
import '../widgets/lesson_complete_dialog.dart';

class LessonPage extends StatefulWidget {
  final Lesson lesson;

  const LessonPage({super.key, required this.lesson});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  int currentTaskIndex = 0;
  final List<TaskResult> results = [];
  int totalScore = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.lesson.tasks.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.lesson.title),
        ),
        body: const Center(
          child: Text('Нет заданий в этом уроке'),
        ),
      );
    }

    final currentTask = widget.lesson.tasks[currentTaskIndex];
    final progress = (currentTaskIndex + 1) / widget.lesson.tasks.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: LessonProgressBar(
            currentTask: currentTaskIndex + 1,
            totalTasks: widget.lesson.tasks.length,
            progress: progress,
          ),
        ),
      ),
      body: SafeArea(
        child: TaskRenderer(
          key: ValueKey(currentTask.id),
          task: currentTask,
          onTaskComplete: _onTaskComplete,
        ),
      ),
    );
  }

  void _onTaskComplete(TaskResult result) {
    setState(() {
      results.add(result);
      totalScore += result.score;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (currentTaskIndex < widget.lesson.tasks.length - 1) {
        setState(() {
          currentTaskIndex++;
        });
      } else {
        _completelesson();
      }
    });
  }

  void _completelesson() {
    final correctAnswers = results.where((r) => r.isCorrect).length;
    final totalTasks = widget.lesson.tasks.length;
    final percentage = (correctAnswers / totalTasks * 100).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LessonCompleteDialog(
        lessonTitle: widget.lesson.title,
        correctAnswers: correctAnswers,
        totalTasks: totalTasks,
        score: totalScore,
        percentage: percentage,
        onContinue: () {
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pop(); // Return to lesson list
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';
import '../core/task_registry.dart';

abstract class BaseTaskWidget extends StatefulWidget {
  final Task task;
  final TaskCallbacks callbacks;

  const BaseTaskWidget({
    super.key,
    required this.task,
    required this.callbacks,
  });
}

abstract class BaseTaskState<T extends BaseTaskWidget> extends State<T> {
  late DateTime _startTime;
  int _attemptCount = 0;
  final List<String> _usedHints = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
  }

  Future<void> submitAnswer({
    required bool isCorrect,
    String? userAnswer,
    Map<String, dynamic>? details,
  }) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _attemptCount++;
    });

    final result = TaskResult(
      taskId: widget.task.id,
      isCorrect: isCorrect,
      attemptNumber: _attemptCount,
      startedAt: _startTime,
      completedAt: DateTime.now(),
      userAnswer: userAnswer,
      details: details,
      hintsUsed: _usedHints,
      score: calculateScore(isCorrect),
    );

    widget.callbacks.onComplete(result);

    setState(() {
      _isSubmitting = false,
    });
  }

  void requestHint(int hintIndex) {
    if (hintIndex < widget.task.hints.length) {
      final hint = widget.task.hints[hintIndex];
      if (!_usedHints.contains(hint)) {
        _usedHints.add(hint);
        widget.callbacks.onHintRequested?.call(hint);
      }
    }
  }

  int calculateScore(bool isCorrect) {
    if (!isCorrect) return 0;

    int baseScore = 100;
    baseScore -= _usedHints.length * 10;
    baseScore -= (_attemptCount - 1) * 20;

    return baseScore > 0 ? baseScore : 10;
  }

  Widget buildTaskContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.task.instructions != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.task.instructions!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        Expanded(
          child: buildTaskContent(context),
        ),
        if (widget.task.hints.isNotEmpty) _buildHintButton(context),
      ],
    );
  }

  Widget _buildHintButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextButton.icon(
        onPressed: _usedHints.length < widget.task.hints.length
            ? () => requestHint(_usedHints.length)
            : null,
        icon: const Icon(Icons.lightbulb_outline),
        label: Text(
          'Подсказка (${_usedHints.length}/${widget.task.hints.length})',
        ),
      ),
    );
  }
}

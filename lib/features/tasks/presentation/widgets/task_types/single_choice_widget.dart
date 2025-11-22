import 'package:flutter/material.dart';
import '../../../domain/entities/task.dart';
import '../../core/task_registry.dart';
import '../base_task_widget.dart';

class ChoiceOption {
  final String id;
  final String text;
  final bool isCorrect;
  final String? imageUrl;
  final String? feedback;

  ChoiceOption({
    required this.id,
    required this.text,
    required this.isCorrect,
    this.imageUrl,
    this.feedback,
  });

  factory ChoiceOption.fromJson(Map<String, dynamic> json) {
    return ChoiceOption(
      id: json['id'] as String,
      text: json['text'] as String,
      isCorrect: json['isCorrect'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      feedback: json['feedback'] as String?,
    );
  }
}

class SingleChoicePayload {
  final String question;
  final List<ChoiceOption> options;
  final bool shuffleOptions;
  final String? imageUrl;

  SingleChoicePayload({
    required this.question,
    required this.options,
    this.shuffleOptions = true,
    this.imageUrl,
  });

  factory SingleChoicePayload.fromJson(Map<String, dynamic> json) {
    return SingleChoicePayload(
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>)
          .map((o) => ChoiceOption.fromJson(o as Map<String, dynamic>))
          .toList(),
      shuffleOptions: json['shuffleOptions'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class SingleChoiceTaskWidget extends BaseTaskWidget {
  const SingleChoiceTaskWidget({
    super.key,
    required super.task,
    required super.callbacks,
  });

  @override
  State<SingleChoiceTaskWidget> createState() => _SingleChoiceTaskWidgetState();
}

class _SingleChoiceTaskWidgetState
    extends BaseTaskState<SingleChoiceTaskWidget> {
  late SingleChoicePayload payload;
  String? selectedOptionId;
  bool hasAnswered = false;

  @override
  void initState() {
    super.initState();
    payload = SingleChoicePayload.fromJson(widget.task.payload);
    if (payload.shuffleOptions) {
      payload.options.shuffle();
    }
  }

  void _handleOptionSelect(String optionId) {
    if (hasAnswered) return;

    setState(() {
      selectedOptionId = optionId;
    });
  }

  void _handleSubmit() {
    if (selectedOptionId == null || hasAnswered) return;

    final selectedOption = payload.options.firstWhere(
      (o) => o.id == selectedOptionId,
    );

    setState(() {
      hasAnswered = true;
    });

    submitAnswer(
      isCorrect: selectedOption.isCorrect,
      userAnswer: selectedOptionId,
      details: {
        'selectedText': selectedOption.text,
        'feedback': selectedOption.feedback,
      },
    );

    _showFeedback(selectedOption);
  }

  void _showFeedback(ChoiceOption option) {
    final color = option.isCorrect ? Colors.green : Colors.red;
    final icon = option.isCorrect ? Icons.check_circle : Icons.cancel;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                option.feedback ??
                    (option.isCorrect ? 'Правильно!' : 'Неправильно'),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget buildTaskContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            payload.question,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (payload.imageUrl != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                payload.imageUrl!,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ],
          const SizedBox(height: 24),
          ...payload.options.map((option) => _buildOptionCard(option)).toList(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: selectedOptionId != null && !hasAnswered
                ? _handleSubmit
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
            child: Text(
              hasAnswered ? 'Отправлено' : 'Ответить',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(ChoiceOption option) {
    final isSelected = selectedOptionId == option.id;
    final showResult = hasAnswered;

    Color? backgroundColor;
    if (showResult) {
      if (option.isCorrect) {
        backgroundColor = Colors.green.withOpacity(0.2);
      } else if (isSelected) {
        backgroundColor = Colors.red.withOpacity(0.2);
      }
    } else if (isSelected) {
      backgroundColor = Theme.of(context).primaryColor.withOpacity(0.1);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: !hasAnswered ? () => _handleOptionSelect(option.id) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              if (option.imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    option.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  option.text,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              if (showResult)
                Icon(
                  option.isCorrect ? Icons.check_circle : Icons.cancel,
                  color: option.isCorrect ? Colors.green : Colors.red,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/task.dart';
import '../base_task_widget.dart';
import 'multiple_choice_models.dart';

class MultipleChoiceTaskWidget extends BaseTaskWidget {
  const MultipleChoiceTaskWidget({
    super.key,
    required super.task,
    required super.callbacks,
  });

  @override
  State<MultipleChoiceTaskWidget> createState() =>
      _MultipleChoiceTaskWidgetState();
}

class _MultipleChoiceTaskWidgetState
    extends BaseTaskState<MultipleChoiceTaskWidget> {
  late MultipleChoicePayload payload;
  Set<String> selectedOptionIds = {};
  bool hasAnswered = false;

  @override
  void initState() {
    super.initState();
    payload = MultipleChoicePayload.fromJson(widget.task.payload);
  }

  @override
  Widget buildTaskContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Вопрос
          Text(
            payload.question,
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          // Опциональное изображение
          if (payload.imageUrl != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                payload.imageUrl!,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 48),
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Подсказка о множественном выборе
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Выберите все правильные ответы',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.info,
                        ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Варианты ответов
          ...payload.options.map((option) => _buildOptionCard(option)),

          const SizedBox(height: 24),

          // Кнопка отправки
          ElevatedButton(
            onPressed:
                selectedOptionIds.isNotEmpty && !hasAnswered ? _submitAnswer : null,
            child: Text(
              hasAnswered
                  ? 'Ответ отправлен'
                  : 'Ответить (выбрано: ${selectedOptionIds.length})',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(MultipleChoiceOption option) {
    final isSelected = selectedOptionIds.contains(option.id);

    Color? borderColor;
    Color? backgroundColor;
    IconData? icon;
    Color? iconColor;

    if (hasAnswered) {
      // После ответа
      if (option.isCorrect) {
        // Правильный ответ
        borderColor = AppColors.success;
        backgroundColor = AppColors.success.withOpacity(0.1);
        iconColor = AppColors.success;
        icon = isSelected ? Icons.check_box : Icons.check_box_outline_blank;
      } else if (isSelected) {
        // Неправильный выбор
        borderColor = AppColors.error;
        backgroundColor = AppColors.error.withOpacity(0.1);
        iconColor = AppColors.error;
        icon = Icons.cancel;
      } else {
        // Не выбран и неправильный
        icon = Icons.check_box_outline_blank;
        iconColor = Colors.grey;
      }
    } else {
      // До ответа
      if (isSelected) {
        borderColor = AppColors.primary;
        backgroundColor = AppColors.primary.withOpacity(0.1);
        icon = Icons.check_box;
        iconColor = AppColors.primary;
      } else {
        icon = Icons.check_box_outline_blank;
        iconColor = Colors.grey;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: hasAnswered ? null : () => _toggleOption(option.id),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: borderColor ?? Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: iconColor,
                    ),
                    const SizedBox(width: 12),
                    if (option.imageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          option.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image, size: 24),
                            );
                          },
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
                  ],
                ),
                // Показать обратную связь после ответа
                if (hasAnswered &&
                    option.feedback != null &&
                    (option.isCorrect || isSelected)) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (option.isCorrect
                              ? AppColors.success
                              : AppColors.error)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      option.feedback!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: option.isCorrect
                                ? AppColors.success
                                : AppColors.error,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleOption(String optionId) {
    if (!hasAnswered) {
      setState(() {
        if (selectedOptionIds.contains(optionId)) {
          selectedOptionIds.remove(optionId);
        } else {
          selectedOptionIds.add(optionId);
        }
      });
    }
  }

  Future<void> _submitAnswer() async {
    if (selectedOptionIds.isEmpty || hasAnswered) return;

    setState(() {
      hasAnswered = true;
    });

    // Определить правильные ответы
    final correctOptionIds = payload.options
        .where((opt) => opt.isCorrect)
        .map((opt) => opt.id)
        .toSet();

    // Проверить правильность
    bool isCorrect;
    int score;

    if (payload.requireAllCorrect) {
      // Должны быть выбраны все правильные и только правильные
      isCorrect = selectedOptionIds.length == correctOptionIds.length &&
          selectedOptionIds.every((id) => correctOptionIds.contains(id));
      score = calculateScore(isCorrect);
    } else {
      // Достаточно хотя бы одного правильного
      isCorrect = selectedOptionIds.any((id) => correctOptionIds.contains(id));
      score = calculateScore(isCorrect);
    }

    // Частичный балл (если включен)
    if (payload.partialCredit && !isCorrect) {
      final correctSelected =
          selectedOptionIds.where((id) => correctOptionIds.contains(id)).length;
      final incorrectSelected = selectedOptionIds
          .where((id) => !correctOptionIds.contains(id))
          .length;
      final totalCorrect = correctOptionIds.length;

      // Формула: (правильные - неправильные) / всего правильных * 100
      final partialScore =
          ((correctSelected - incorrectSelected) / totalCorrect * 100)
              .clamp(0, 100)
              .round();

      score = partialScore;
    }

    await submitAnswer(
      isCorrect: isCorrect,
      userAnswer: selectedOptionIds.join(','),
      details: {
        'selectedOptions': selectedOptionIds.toList(),
        'correctOptions': correctOptionIds.toList(),
        'totalCorrect': correctOptionIds.length,
        'correctlySelected':
            selectedOptionIds.where((id) => correctOptionIds.contains(id)).length,
        'incorrectlySelected': selectedOptionIds
            .where((id) => !correctOptionIds.contains(id))
            .length,
        'partialScore': payload.partialCredit ? score : null,
      },
    );

    // Показать обратную связь
    if (mounted) {
      String message;
      Color backgroundColor;

      if (isCorrect) {
        message = 'Отлично! Все ответы правильные! 🎉';
        backgroundColor = AppColors.success;
      } else if (payload.partialCredit && score > 30) {
        message = 'Частично правильно. Набрано $score баллов.';
        backgroundColor = AppColors.warning;
      } else {
        final correctCount =
            selectedOptionIds.where((id) => correctOptionIds.contains(id)).length;
        final totalCorrect = correctOptionIds.length;
        message =
            'Не все ответы правильные. Выбрано $correctCount из $totalCorrect правильных.';
        backgroundColor = AppColors.error;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  int calculateScore(bool isCorrect) {
    if (payload.partialCredit && !isCorrect) {
      // Частичный балл уже вычислен в _submitAnswer
      return super.calculateScore(false);
    }
    return super.calculateScore(isCorrect);
  }
}

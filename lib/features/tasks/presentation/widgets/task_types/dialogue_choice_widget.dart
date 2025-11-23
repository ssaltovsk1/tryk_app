import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/task.dart';
import '../../core/task_registry.dart';
import '../base_task_widget.dart';

enum MessageType { text, choice, result }

class DialogueMessage {
  final String id;
  final String speaker;
  final String? avatarUrl;
  final String message;
  final bool isUser;
  final MessageType type;

  DialogueMessage({
    required this.id,
    required this.speaker,
    required this.message,
    this.avatarUrl,
    this.isUser = false,
    this.type = MessageType.text,
  });

  factory DialogueMessage.fromJson(Map<String, dynamic> json) {
    return DialogueMessage(
      id: json['id'] as String,
      speaker: json['speaker'] as String,
      message: json['message'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      isUser: json['isUser'] as bool? ?? false,
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
    );
  }
}

class DialogueChoice {
  final String id;
  final String text;
  final bool isCorrect;
  final String? feedback;
  final String? consequence;

  DialogueChoice({
    required this.id,
    required this.text,
    required this.isCorrect,
    this.feedback,
    this.consequence,
  });

  factory DialogueChoice.fromJson(Map<String, dynamic> json) {
    return DialogueChoice(
      id: json['id'] as String,
      text: json['text'] as String,
      isCorrect: json['isCorrect'] as bool? ?? false,
      feedback: json['feedback'] as String?,
      consequence: json['consequence'] as String?,
    );
  }
}

class DialogueChoicePayload {
  final String scenario;
  final List<DialogueMessage> messages;
  final List<DialogueChoice> choices;
  final String? contextImageUrl;

  DialogueChoicePayload({
    required this.scenario,
    required this.messages,
    required this.choices,
    this.contextImageUrl,
  });

  factory DialogueChoicePayload.fromJson(Map<String, dynamic> json) {
    return DialogueChoicePayload(
      scenario: json['scenario'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((m) => DialogueMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
      choices: (json['choices'] as List<dynamic>)
          .map((c) => DialogueChoice.fromJson(c as Map<String, dynamic>))
          .toList(),
      contextImageUrl: json['contextImageUrl'] as String?,
    );
  }
}

class DialogueChoiceTaskWidget extends BaseTaskWidget {
  const DialogueChoiceTaskWidget({
    super.key,
    required super.task,
    required super.callbacks,
  });

  @override
  State<DialogueChoiceTaskWidget> createState() =>
      _DialogueChoiceTaskWidgetState();
}

class _DialogueChoiceTaskWidgetState
    extends BaseTaskState<DialogueChoiceTaskWidget> {
  late DialogueChoicePayload payload;
  final ScrollController _scrollController = ScrollController();
  final List<DialogueMessage> displayedMessages = [];
  DialogueChoice? selectedChoice;
  bool hasAnswered = false;
  int currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();
    payload = DialogueChoicePayload.fromJson(widget.task.payload);
    _startDialogue();
  }

  void _startDialogue() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _addNextMessage();
    });
  }

  void _addNextMessage() {
    if (currentMessageIndex < payload.messages.length) {
      setState(() {
        displayedMessages.add(payload.messages[currentMessageIndex]);
        currentMessageIndex++;
      });

      _scrollToBottom();

      Future.delayed(const Duration(milliseconds: 1500), () {
        _addNextMessage();
      });
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _selectChoice(DialogueChoice choice) {
    if (hasAnswered) return;

    setState(() {
      selectedChoice = choice;
      hasAnswered = true;

      displayedMessages.add(DialogueMessage(
        id: 'user_choice',
        speaker: 'Вы',
        message: choice.text,
        isUser: true,
        type: MessageType.choice,
      ));

      if (choice.consequence != null) {
        displayedMessages.add(DialogueMessage(
          id: 'consequence',
          speaker: 'Система',
          message: choice.consequence!,
          type: MessageType.result,
        ));
      }
    });

    _scrollToBottom();

    submitAnswer(
      isCorrect: choice.isCorrect,
      userAnswer: choice.id,
      details: {
        'selectedText': choice.text,
        'feedback': choice.feedback,
        'consequence': choice.consequence,
      },
    );

    if (choice.feedback != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _showFeedback(choice);
      });
    }
  }

  void _showFeedback(DialogueChoice choice) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              choice.isCorrect ? Icons.check_circle : Icons.warning,
              color: choice.isCorrect ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(choice.isCorrect ? 'Правильно!' : 'Подумайте еще'),
          ],
        ),
        content: Text(choice.feedback ??
            (choice.isCorrect
                ? 'Вы выбрали безопасный вариант ответа!'
                : 'Этот ответ может быть опасным.')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildTaskContent(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Theme.of(context).primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  payload.scenario,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: displayedMessages.length,
            itemBuilder: (context, index) {
              final message = displayedMessages[index];
              return _buildMessage(message);
            },
          ),
        ),
        if (currentMessageIndex >= payload.messages.length && !hasAnswered)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Выберите ваш ответ:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                ...payload.choices.map((choice) => _buildChoiceButton(choice)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMessage(DialogueMessage message) {
    final isUser = message.isUser;
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color =
        isUser ? AppColors.userMessage : AppColors.botMessage;
    final textColor = isUser ? Colors.white : Colors.black87;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.type == MessageType.result
              ? AppColors.systemMessage
              : color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Text(
                message.speaker,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              message.message,
              style: TextStyle(color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton(DialogueChoice choice) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _selectChoice(choice),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(choice.text),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

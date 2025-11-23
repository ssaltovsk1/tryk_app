# 🤖 AI Integration Guide - Cyber Shield

> **Статус:** Планируется (Q3 2025)
> **Дата обновления:** 2025-01-23

Это руководство описывает, как интегрировать искусственный интеллект в приложение Cyber Shield для создания адаптивного обучающего опыта.

---

## 📑 Содержание

1. [Обзор AI возможностей](#обзор-ai-возможностей)
2. [AI Чат-помощник](#ai-чат-помощник)
3. [Персонализированный контент](#персонализированный-контент)
4. [AI-генерация задач](#ai-генерация-задач)
5. [Сценарий-бранчинг с AI](#сценарий-бранчинг-с-ai)
6. [Адаптивная сложность](#адаптивная-сложность)
7. [Безопасность и модерация](#безопасность-и-модерация)
8. [Выбор AI провайдера](#выбор-ai-провайдера)

---

## 🌟 Обзор AI возможностей

### Планируемые AI функции

1. **AI Чат-помощник**
   - Контекстная помощь в задачах
   - Объяснение концепций кибербезопасности
   - Ролевые диалоги для обучения

2. **Персонализированный контент**
   - Адаптация сложности под уровень ребенка
   - Рекомендации уроков
   - Анализ слабых мест

3. **AI-генерация задач**
   - Динамическое создание вопросов
   - Вариации существующих задач
   - Бесконечный контент

4. **Интерактивные сценарии**
   - Ветвящиеся истории с AI персонажами
   - Уникальный опыт каждого прохождения
   - Реалистичные симуляции ситуаций

---

## 💬 AI Чат-помощник

### Архитектура

```
┌─────────────┐
│   User      │
└──────┬──────┘
       │
       v
┌─────────────────────────┐
│  Chat UI Widget         │
│  - Messages             │
│  - Input field          │
│  - Typing indicator     │
└──────┬──────────────────┘
       │
       v
┌─────────────────────────┐
│  AI Assistant Service   │
│  - Context management   │
│  - Prompt engineering   │
│  - Response formatting  │
└──────┬──────────────────┘
       │
       v
┌─────────────────────────┐
│  AI Provider            │
│  - OpenAI               │
│  - Google Gemini        │
│  - Local LLM            │
└─────────────────────────┘
```

### Шаг 1: Создание AI Service

**Файл:** `lib/core/services/ai_assistant_service.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AIProvider {
  openai,
  gemini,
  local,
}

class AIAssistantConfig {
  final AIProvider provider;
  final String apiKey;
  final String model;
  final double temperature;
  final int maxTokens;

  const AIAssistantConfig({
    required this.provider,
    required this.apiKey,
    this.model = 'gpt-4o-mini',
    this.temperature = 0.7,
    this.maxTokens = 500,
  });
}

class ChatMessage {
  final String id;
  final String role; // 'system', 'user', 'assistant'
  final String content;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });
}

class AIAssistantService {
  final AIAssistantConfig config;
  final Dio _dio = Dio();

  // Контекст текущего урока/задачи
  LessonContext? currentContext;

  // История диалога
  final List<ChatMessage> conversationHistory = [];

  AIAssistantService({required this.config});

  /// Генерация ответа на сообщение пользователя
  Future<String> generateResponse(String userMessage) async {
    // Добавить сообщение пользователя в историю
    conversationHistory.add(ChatMessage(
      id: _generateId(),
      role: 'user',
      content: userMessage,
      timestamp: DateTime.now(),
    ));

    try {
      final response = await _callAI(userMessage);

      // Добавить ответ ассистента в историю
      conversationHistory.add(ChatMessage(
        id: _generateId(),
        role: 'assistant',
        content: response,
        timestamp: DateTime.now(),
      ));

      return response;
    } catch (e) {
      return 'Извини, у меня возникли проблемы. Попробуй еще раз.';
    }
  }

  /// Генерация подсказки для задачи
  Future<String> generateHint(Task task, int hintLevel) async {
    final prompt = _buildHintPrompt(task, hintLevel);
    return await _callAI(prompt);
  }

  /// Объяснение ошибки
  Future<String> explainMistake(
    Task task,
    String userAnswer,
    String correctAnswer,
  ) async {
    final prompt = _buildExplanationPrompt(task, userAnswer, correctAnswer);
    return await _callAI(prompt);
  }

  /// Установить контекст урока
  void setContext(LessonContext context) {
    currentContext = context;

    // Добавить системное сообщение с контекстом
    conversationHistory.insert(
      0,
      ChatMessage(
        id: _generateId(),
        role: 'system',
        content: _buildSystemPrompt(context),
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Сброс истории диалога
  void resetConversation() {
    conversationHistory.clear();
    currentContext = null;
  }

  // Private методы

  Future<String> _callAI(String prompt) async {
    switch (config.provider) {
      case AIProvider.openai:
        return await _callOpenAI(prompt);
      case AIProvider.gemini:
        return await _callGemini(prompt);
      case AIProvider.local:
        return await _callLocalLLM(prompt);
    }
  }

  Future<String> _callOpenAI(String prompt) async {
    final messages = conversationHistory.map((msg) => {
      'role': msg.role,
      'content': msg.content,
    }).toList();

    final response = await _dio.post(
      'https://api.openai.com/v1/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${config.apiKey}',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': config.model,
        'messages': messages,
        'temperature': config.temperature,
        'max_tokens': config.maxTokens,
      },
    );

    return response.data['choices'][0]['message']['content'];
  }

  Future<String> _callGemini(String prompt) async {
    // Google Gemini API
    final response = await _dio.post(
      'https://generativelanguage.googleapis.com/v1beta/models/${config.model}:generateContent',
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': config.apiKey,
        },
      ),
      data: {
        'contents': [{
          'parts': [{'text': prompt}],
        }],
        'generationConfig': {
          'temperature': config.temperature,
          'maxOutputTokens': config.maxTokens,
        },
      },
    );

    return response.data['candidates'][0]['content']['parts'][0]['text'];
  }

  Future<String> _callLocalLLM(String prompt) async {
    // Ollama или другая локальная LLM
    final response = await _dio.post(
      'http://localhost:11434/api/generate',
      data: {
        'model': config.model,
        'prompt': prompt,
        'stream': false,
      },
    );

    return response.data['response'];
  }

  String _buildSystemPrompt(LessonContext context) {
    return '''
Ты - дружелюбный AI помощник в образовательном приложении Cyber Shield.
Твоя задача - помогать детям 8-14 лет изучать кибербезопасность.

Контекст:
- Модуль: ${context.moduleName}
- Урок: ${context.lessonTitle}
- Текущая задача: ${context.currentTask?.title ?? 'N/A'}

Правила:
1. Используй простой язык, понятный детям
2. Будь дружелюбным и поддерживающим
3. Не давай прямых ответов, направляй к правильному решению
4. Используй примеры из реальной жизни
5. Поощряй критическое мышление
6. НИКОГДА не используй страшные или пугающие примеры
7. Сообщения должны быть короткими (2-3 предложения)

Отвечай только на вопросы, связанные с кибербезопасностью и текущим уроком.
''';
  }

  String _buildHintPrompt(Task task, int hintLevel) {
    return '''
Задача: ${task.title}
${task.instructions != null ? 'Инструкция: ${task.instructions}' : ''}

Уровень подсказки: $hintLevel (1 - легкая, 2 - средняя, 3 - почти ответ)

Создай подсказку для ребенка уровня $hintLevel. Не давай прямого ответа!
Подсказка должна быть в 1-2 предложения.
''';
  }

  String _buildExplanationPrompt(
    Task task,
    String userAnswer,
    String correctAnswer,
  ) {
    return '''
Задача: ${task.title}

Ответ ребенка: $userAnswer
Правильный ответ: $correctAnswer

Объясни ребенку, почему его ответ неправильный и почему правильный ответ лучше.
Используй позитивный тон и конкретные примеры.
Ответ должен быть 2-3 предложения.
''';
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

// Riverpod Provider
final aiAssistantProvider = Provider<AIAssistantService>((ref) {
  // Получить API ключ из конфигурации/env
  const config = AIAssistantConfig(
    provider: AIProvider.openai,
    apiKey: 'YOUR_API_KEY',  // Из env переменных
    model: 'gpt-4o-mini',
  );

  return AIAssistantService(config: config);
});
```

### Шаг 2: Создание Chat UI Widget

**Файл:** `lib/features/ai_assistant/presentation/widgets/ai_chat_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AIChatWidget extends ConsumerStatefulWidget {
  final LessonContext? context;

  const AIChatWidget({super.key, this.context});

  @override
  ConsumerState<AIChatWidget> createState() => _AIChatWidgetState();
}

class _AIChatWidgetState extends ConsumerState<AIChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();

    if (widget.context != null) {
      final aiService = ref.read(aiAssistantProvider);
      aiService.setContext(widget.context!);

      // Приветственное сообщение
      _addMessage(ChatMessage(
        id: '0',
        role: 'assistant',
        content: 'Привет! Я твой AI помощник. Чем могу помочь?',
        timestamp: DateTime.now(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Заголовок
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.smart_toy, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Помощник',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  Text(
                    'Онлайн',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Список сообщений
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return _buildMessageBubble(_messages[index]);
            },
          ),
        ),

        // Индикатор печати
        if (_isTyping)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _TypingDot(delay: 0),
                      SizedBox(width: 4),
                      _TypingDot(delay: 200),
                      SizedBox(width: 4),
                      _TypingDot(delay: 400),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Поле ввода
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Задай вопрос...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.greyLight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();
    _controller.clear();

    // Добавить сообщение пользователя
    _addMessage(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'user',
      content: userMessage,
      timestamp: DateTime.now(),
    ));

    // Показать индикатор печати
    setState(() {
      _isTyping = true;
    });

    // Получить ответ от AI
    try {
      final aiService = ref.read(aiAssistantProvider);
      final response = await aiService.generateResponse(userMessage);

      setState(() {
        _isTyping = false;
      });

      // Добавить ответ AI
      _addMessage(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'assistant',
        content: response,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      setState(() {
        _isTyping = false;
      });

      _addMessage(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        role: 'assistant',
        content: 'Извини, произошла ошибка. Попробуй еще раз.',
        timestamp: DateTime.now(),
      ));
    }
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });

    // Автоскролл
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

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// Анимированная точка для индикатора печати
class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      _controller.repeat(reverse: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### Шаг 3: Интеграция в Lesson Page

Добавьте кнопку AI помощника:

```dart
// В LessonPage добавить FloatingActionButton
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(/* ... */),
    body: Column(/* ... */),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _openAIChat,
      icon: const Icon(Icons.smart_toy),
      label: const Text('AI Помощник'),
    ),
  );
}

void _openAIChat() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: AIChatWidget(
        context: LessonContext(
          moduleName: 'Название модуля',
          lessonTitle: widget.lesson.title,
          currentTask: widget.lesson.tasks[_currentTaskIndex],
        ),
      ),
    ),
  );
}
```

---

## 🎯 Персонализированный контент

### Система рекомендаций

**Файл:** `lib/core/services/ai_recommendation_service.dart`

```dart
class AIRecommendationService {
  final AIAssistantService aiService;

  AIRecommendationService({required this.aiService});

  /// Рекомендация следующего урока
  Future<List<Lesson>> recommendLessons(
    UserProgress progress,
    List<Lesson> availableLessons,
  ) async {
    final prompt = '''
На основе прогресса пользователя, порекомендуй 3 урока для изучения:

Пройденные уроки: ${progress.completedLessons.map((l) => l.title).join(', ')}
Слабые области: ${_analyzeWeaknesses(progress)}
Средняя точность: ${progress.averageAccuracy}%

Доступные уроки: ${availableLessons.map((l) => '${l.id}: ${l.title}').join('\n')}

Верни только ID уроков в формате: lesson_id1, lesson_id2, lesson_id3
''';

    final response = await aiService.generateResponse(prompt);
    final lessonIds = response.split(',').map((id) => id.trim()).toList();

    return availableLessons
        .where((lesson) => lessonIds.contains(lesson.id))
        .toList();
  }

  /// Адаптация сложности
  int recommendDifficulty(UserProgress progress) {
    final avgAccuracy = progress.averageAccuracy;

    if (avgAccuracy >= 90) return 5; // Максимальная сложность
    if (avgAccuracy >= 75) return 4;
    if (avgAccuracy >= 60) return 3;
    if (avgAccuracy >= 45) return 2;
    return 1; // Минимальная сложность
  }

  List<String> _analyzeWeaknesses(UserProgress progress) {
    // Анализ типов задач, где пользователь делает больше ошибок
    final weaknesses = <String>[];

    final taskTypeAccuracy = <TaskType, double>{};

    for (final result in progress.allResults) {
      taskTypeAccuracy[result.task.type] =
          (taskTypeAccuracy[result.task.type] ?? 0.0) + (result.isCorrect ? 100 : 0);
    }

    taskTypeAccuracy.forEach((type, accuracy) {
      if (accuracy < 60) {
        weaknesses.add(type.name);
      }
    });

    return weaknesses;
  }
}
```

---

## 🎲 AI-генерация задач

### Динамическое создание вопросов

```dart
class AITaskGeneratorService {
  final AIAssistantService aiService;

  AITaskGeneratorService({required this.aiService});

  /// Генерация SingleChoice задачи
  Future<Task> generateSingleChoiceTask({
    required String topic,
    required int difficulty,
  }) async {
    final prompt = '''
Создай вопрос с одним правильным ответом на тему: "$topic"
Сложность: $difficulty из 5
Целевая аудитория: дети 8-14 лет

Формат ответа (JSON):
{
  "question": "текст вопроса",
  "options": [
    {"id": "o1", "text": "вариант 1", "isCorrect": true, "feedback": "объяснение"},
    {"id": "o2", "text": "вариант 2", "isCorrect": false, "feedback": "объяснение"},
    {"id": "o3", "text": "вариант 3", "isCorrect": false, "feedback": "объяснение"},
    {"id": "o4", "text": "вариант 4", "isCorrect": false, "feedback": "объяснение"}
  ],
  "hints": ["подсказка 1", "подсказка 2"]
}

Верни ТОЛЬКО JSON без дополнительного текста.
''';

    final response = await aiService.generateResponse(prompt);
    final jsonData = json.decode(_extractJSON(response));

    return Task(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      lessonId: 'ai_generated',
      type: TaskType.singleChoice,
      orderIndex: 0,
      title: 'AI сгенерированный вопрос',
      payload: jsonData,
      hints: List<String>.from(jsonData['hints'] ?? []),
    );
  }

  /// Генерация DialogueChoice сценария
  Future<Task> generateDialogueTask({
    required String scenario,
    required int difficulty,
  }) async {
    final prompt = '''
Создай интерактивный сценарий для обучения детей кибербезопасности.

Сценарий: "$scenario"
Сложность: $difficulty из 5

Требования:
- 3-5 сообщений диалога перед выбором
- 3-4 варианта ответа
- Реалистичная ситуация из жизни ребенка
- Четкие последствия для каждого выбора

Формат ответа (JSON):
{
  "scenario": "краткое описание",
  "messages": [
    {"id": "m1", "speaker": "Персонаж", "message": "текст", "isUser": false}
  ],
  "choices": [
    {"id": "c1", "text": "выбор", "isCorrect": true/false, "feedback": "объяснение", "consequence": "что случилось"}
  ]
}

Верни ТОЛЬКО JSON.
''';

    final response = await aiService.generateResponse(prompt);
    final jsonData = json.decode(_extractJSON(response));

    return Task(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      lessonId: 'ai_generated',
      type: TaskType.dialogueChoice,
      orderIndex: 0,
      title: 'AI сгенерированный сценарий',
      payload: jsonData,
    );
  }

  String _extractJSON(String response) {
    // Извлечь JSON из ответа (если AI добавил текст вокруг)
    final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(response);
    return jsonMatch?.group(0) ?? response;
  }
}
```

---

## 🌳 Сценарий-бранчинг с AI

### Новый тип задачи: AI Scenario

```dart
enum TaskType {
  // ... существующие типы
  aiScenarioBranching,  // ✅ Новый тип
}

class AIScenarioTaskWidget extends BaseTaskWidget {
  // Динамический сценарий с AI персонажами

  @override
  Widget buildTaskContent(BuildContext context) {
    return AIScenarioPlayer(
      scenario: widget.task.payload['initialScenario'],
      characters: widget.task.payload['characters'],
      learningObjectives: widget.task.payload['learningObjectives'],
      onComplete: (result) => submitAnswer(/* ... */),
    );
  }
}

class AIScenarioPlayer extends StatefulWidget {
  final String scenario;
  final List<Character> characters;
  final List<String> learningObjectives;

  // Реализация:
  // 1. Пользователь делает выбор
  // 2. AI генерирует ответ персонажа
  // 3. Сюжет ветвится динамически
  // 4. AI оценивает решения в конце
}
```

---

## 📊 Адаптивная сложность

### Динамическое изменение сложности

```dart
class AdaptiveDifficultyService {
  int currentDifficulty = 3;  // Начальная сложность (1-5)

  void adjustDifficulty(TaskResult result) {
    if (result.isCorrect && result.score >= 90) {
      // Идеальный результат - увеличить сложность
      currentDifficulty = (currentDifficulty + 1).clamp(1, 5);
    } else if (!result.isCorrect || result.score < 50) {
      // Ошибка или низкий балл - уменьшить сложность
      currentDifficulty = (currentDifficulty - 1).clamp(1, 5);
    }
    // Средний результат - оставить текущую сложность
  }

  Task getNextTask(List<Task> availableTasks) {
    // Фильтровать задачи по текущему уровню сложности
    final suitableTasks = availableTasks.where(
      (task) => task.metadata?['difficulty'] == currentDifficulty,
    ).toList();

    if (suitableTasks.isEmpty) {
      return availableTasks.first;
    }

    // Случайная задача из подходящих
    return suitableTasks[Random().nextInt(suitableTasks.length)];
  }
}
```

---

## 🛡️ Безопасность и модерация

### Фильтрация контента

```dart
class AIContentModerationService {
  final AIAssistantService aiService;

  /// Проверка безопасности сообщения
  Future<bool> isSafeForChildren(String content) async {
    final prompt = '''
Проверь, безопасен ли следующий текст для детей 8-14 лет.

Текст: "$content"

Критерии:
- Нет насилия, страшных образов
- Нет неподобающего языка
- Нет личной информации
- Соответствует теме кибербезопасности

Ответь ТОЛЬКО: "safe" или "unsafe"
''';

    final response = await aiService.generateResponse(prompt);
    return response.toLowerCase().contains('safe');
  }

  /// Модерация пользовательского ввода
  String moderateUserInput(String userInput) {
    // Удалить потенциально опасную информацию
    String moderated = userInput;

    // Маскировать email
    moderated = moderated.replaceAllMapped(
      RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w+\b'),
      (match) => '[EMAIL СКРЫТ]',
    );

    // Маскировать телефоны
    moderated = moderated.replaceAllMapped(
      RegExp(r'\b\d{10,}\b'),
      (match) => '[ТЕЛЕФОН СКРЫТ]',
    );

    // Маскировать адреса (упрощенно)
    moderated = moderated.replaceAllMapped(
      RegExp(r'\b\d{1,5}\s+\w+\s+(улица|проспект|переулок)', caseSensitive: false),
      (match) => '[АДРЕС СКРЫТ]',
    );

    return moderated;
  }

  /// Проверка на оффтопик
  Future<bool> isOnTopic(String userMessage, String currentTopic) async {
    final prompt = '''
Проверь, относится ли вопрос пользователя к теме обучения.

Текущая тема: "$currentTopic"
Вопрос пользователя: "$userMessage"

Ответь ТОЛЬКО: "on-topic" или "off-topic"
''';

    final response = await aiService.generateResponse(prompt);
    return response.toLowerCase().contains('on-topic');
  }
}
```

---

## 🔌 Выбор AI провайдера

### Сравнение провайдеров

| Провайдер | Стоимость | Скорость | Качество | Приватность | Офлайн |
|-----------|-----------|----------|----------|-------------|---------|
| **OpenAI** | $$ | ⚡⚡⚡ | ⭐⭐⭐⭐⭐ | ⚠️ | ❌ |
| **Google Gemini** | $ | ⚡⚡⚡ | ⭐⭐⭐⭐ | ⚠️ | ❌ |
| **Anthropic Claude** | $$$ | ⚡⚡ | ⭐⭐⭐⭐⭐ | ✅ | ❌ |
| **Local LLM (Ollama)** | FREE | ⚡ | ⭐⭐⭐ | ✅✅✅ | ✅ |

### Рекомендации

**Для продакшена:**
- **OpenAI GPT-4o-mini** - Лучший баланс цены/качества
- **Google Gemini 1.5 Flash** - Дешевле, быстрее

**Для приватности:**
- **Local LLM (Llama 3)** - Полная приватность, но требует мощного устройства

**Для развития:**
- **OpenAI GPT-4o** - Для тестирования лучших результатов

### Конфигурация провайдера

**Через environment variables:**

```bash
# .env файл
AI_PROVIDER=openai  # or gemini, claude, local
OPENAI_API_KEY=sk-...
GEMINI_API_KEY=...
AI_MODEL=gpt-4o-mini
```

**В коде:**

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load();

  final config = AIAssistantConfig(
    provider: _parseProvider(dotenv.env['AI_PROVIDER']),
    apiKey: dotenv.env['OPENAI_API_KEY'] ?? '',
    model: dotenv.env['AI_MODEL'] ?? 'gpt-4o-mini',
  );

  runApp(MyApp(aiConfig: config));
}
```

---

## 💰 Оценка стоимости

### OpenAI GPT-4o-mini

**Цены (на 01.2025):**
- Input: $0.15 / 1M tokens
- Output: $0.60 / 1M tokens

**Средний диалог:**
- 10 сообщений
- ~500 tokens input
- ~300 tokens output
- **Стоимость:** ~$0.0003 (0.03 цента)

**1000 пользователей:**
- 10 диалогов/день каждый
- 10,000 диалогов/день
- **$3/день** или **$90/месяц**

### Оптимизация затрат

1. **Кэширование ответов** - Сохранять частые вопросы
2. **Контекстное окно** - Ограничить историю диалога
3. **Батчинг** - Группировать запросы
4. **Fallback на шаблоны** - Для простых вопросов

---

## 📚 Полезные ресурсы

- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Google Gemini API](https://ai.google.dev/docs)
- [Anthropic Claude API](https://docs.anthropic.com/)
- [Ollama - Local LLMs](https://ollama.ai/)
- [LangChain Dart](https://pub.dev/packages/langchain)

---

## 🚀 План внедрения

### Этап 1: MVP (Q3 2025)
- ✅ AI чат-помощник (базовый)
- ✅ Контекстные подсказки
- ✅ Объяснение ошибок

### Этап 2: Персонализация (Q4 2025)
- ⏳ Рекомендации уроков
- ⏳ Адаптивная сложность
- ⏳ Анализ слабых мест

### Этап 3: Генерация контента (Q1 2026)
- ⏳ AI генерация задач
- ⏳ Динамические сценарии
- ⏳ Бесконечный режим

---

**Документ обновлен:** 2025-01-23
**Версия:** 1.0
**Статус:** В разработке

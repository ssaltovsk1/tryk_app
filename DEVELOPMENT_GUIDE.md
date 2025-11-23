# 🛠️ Руководство разработчика Cyber Shield

> **Для кого:** Разработчики, дизайнеры контента, контрибьюторы
> **Обновлено:** 2025-01-23

Это руководство объясняет, как добавлять новые функции, типы задач и контент в приложение Cyber Shield.

---

## 📑 Содержание

1. [Добавление нового типа задачи](#добавление-нового-типа-задачи)
2. [Добавление контента в существующие уровни](#добавление-контента-в-существующие-уровни)
3. [Создание нового модуля](#создание-нового-модуля)
4. [Лучшие практики](#лучшие-практики)
5. [Тестирование](#тестирование)
6. [Часто задаваемые вопросы](#часто-задаваемые-вопросы)

---

## 🎯 Добавление нового типа задачи

### Шаг 1: Определение типа задачи

Если вы добавляете новый тип задачи, сначала добавьте его в `TaskType` enum.

**Файл:** `lib/features/tasks/domain/entities/task.dart`

```dart
enum TaskType {
  singleChoice,
  multipleChoice,        // ✅ Добавьте здесь
  trueFalse,
  matchPairs,
  dragAndDropSequence,
  dialogueChoice,
  inputTextShort,
  scenarioBranching,
}
```

### Шаг 2: Определение структуры Payload

Создайте модели данных для вашего типа задачи.

**Пример: Multiple Choice**

Создайте файл `lib/features/tasks/presentation/widgets/task_types/multiple_choice_models.dart`:

```dart
class MultipleChoicePayload {
  final String question;
  final List<MultipleChoiceOption> options;
  final bool requireAllCorrect;
  final bool partialCredit;
  final String? imageUrl;

  const MultipleChoicePayload({
    required this.question,
    required this.options,
    this.requireAllCorrect = true,
    this.partialCredit = false,
    this.imageUrl,
  });

  factory MultipleChoicePayload.fromJson(Map<String, dynamic> json) {
    return MultipleChoicePayload(
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>)
          .map((o) => MultipleChoiceOption.fromJson(o as Map<String, dynamic>))
          .toList(),
      requireAllCorrect: json['requireAllCorrect'] as bool? ?? true,
      partialCredit: json['partialCredit'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class MultipleChoiceOption {
  final String id;
  final String text;
  final bool isCorrect;
  final String? imageUrl;
  final String? feedback;

  const MultipleChoiceOption({
    required this.id,
    required this.text,
    required this.isCorrect,
    this.imageUrl,
    this.feedback,
  });

  factory MultipleChoiceOption.fromJson(Map<String, dynamic> json) {
    return MultipleChoiceOption(
      id: json['id'] as String,
      text: json['text'] as String,
      isCorrect: json['isCorrect'] as bool,
      imageUrl: json['imageUrl'] as String?,
      feedback: json['feedback'] as String?,
    );
  }
}
```

### Шаг 3: Создание виджета задачи

Создайте файл `lib/features/tasks/presentation/widgets/task_types/multiple_choice_widget.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/task.dart';
import '../base_task_widget.dart';
import './multiple_choice_models.dart';

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
                Icon(Icons.info_outline, color: AppColors.info, size: 20),
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
              'Ответить (выбрано: ${selectedOptionIds.length})',
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

    if (hasAnswered) {
      if (option.isCorrect) {
        borderColor = AppColors.success;
        backgroundColor = AppColors.success.withOpacity(0.1);
        icon = isSelected ? Icons.check_box : Icons.check_box_outline_blank;
      } else if (isSelected) {
        borderColor = AppColors.error;
        backgroundColor = AppColors.error.withOpacity(0.1);
        icon = Icons.cancel;
      } else {
        icon = Icons.check_box_outline_blank;
      }
    } else {
      if (isSelected) {
        borderColor = AppColors.primary;
        backgroundColor = AppColors.primary.withOpacity(0.1);
        icon = Icons.check_box;
      } else {
        icon = Icons.check_box_outline_blank;
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
            child: Row(
              children: [
                Icon(
                  icon,
                  color: borderColor ?? Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option.text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
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
    if (payload.requireAllCorrect) {
      // Должны быть выбраны все правильные и только правильные
      isCorrect = selectedOptionIds.length == correctOptionIds.length &&
          selectedOptionIds.every((id) => correctOptionIds.contains(id));
    } else {
      // Достаточно хотя бы одного правильного
      isCorrect = selectedOptionIds.any((id) => correctOptionIds.contains(id));
    }

    // Частичный балл
    int score;
    if (payload.partialCredit && !isCorrect) {
      final correctSelected =
          selectedOptionIds.where((id) => correctOptionIds.contains(id)).length;
      final totalCorrect = correctOptionIds.length;
      score = ((correctSelected / totalCorrect) * 100).round();
    } else {
      score = calculateScore(isCorrect);
    }

    await submitAnswer(
      isCorrect: isCorrect,
      userAnswer: selectedOptionIds.join(','),
      details: {
        'selectedOptions': selectedOptionIds.toList(),
        'correctOptions': correctOptionIds.toList(),
        'partialScore': payload.partialCredit ? score : null,
      },
    );

    // Показать обратную связь
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCorrect
                ? 'Правильно! Все ответы верны.'
                : 'Не все ответы правильные. Попробуйте еще раз.',
          ),
          backgroundColor: isCorrect ? AppColors.success : AppColors.error,
        ),
      );
    }
  }
}
```

### Шаг 4: Регистрация в Task Registry

**Файл:** `lib/features/tasks/presentation/core/task_registry_initializer.dart`

```dart
import 'package:cyber_shield/features/tasks/presentation/widgets/task_types/multiple_choice_widget.dart';
// ... другие импорты

class TaskRegistryInitializer {
  static void initialize() {
    final registry = TaskRegistry();

    registry.registerAll({
      TaskType.singleChoice: (task, callbacks) =>
          SingleChoiceTaskWidget(task: task, callbacks: callbacks),

      TaskType.dialogueChoice: (task, callbacks) =>
          DialogueChoiceTaskWidget(task: task, callbacks: callbacks),

      // ✅ Добавьте вашу задачу
      TaskType.multipleChoice: (task, callbacks) =>
          MultipleChoiceTaskWidget(task: task, callbacks: callbacks),
    });
  }
}
```

### Шаг 5: Тестирование

Создайте демо-задачу для тестирования:

**Файл:** `lib/features/lessons/presentation/pages/lesson_list_page.dart`

```dart
Task(
  id: 'test_mc_1',
  lessonId: 'test_lesson',
  type: TaskType.multipleChoice,
  orderIndex: 0,
  title: 'Тест множественного выбора',
  instructions: 'Выберите все правильные ответы',
  payload: {
    'question': 'Какие из этих действий безопасны в интернете?',
    'requireAllCorrect': true,
    'partialCredit': false,
    'options': [
      {
        'id': 'o1',
        'text': 'Использовать сложные пароли',
        'isCorrect': true,
      },
      {
        'id': 'o2',
        'text': 'Делиться паролями с друзьями',
        'isCorrect': false,
      },
      {
        'id': 'o3',
        'text': 'Включить двухфакторную аутентификацию',
        'isCorrect': true,
      },
      {
        'id': 'o4',
        'text': 'Переходить по подозрительным ссылкам',
        'isCorrect': false,
      },
    ],
  },
  hints: [
    'Подумай о защите аккаунта',
    'Что помогает сделать аккаунт более безопасным?',
  ],
)
```

---

## 📝 Добавление контента в существующие уровни

### Вариант 1: Добавление задачи в существующий урок

**Файл:** `lib/features/lessons/presentation/pages/lesson_list_page.dart`

Найдите нужный урок и добавьте задачу в список `tasks`:

```dart
Lesson(
  id: 'education_1',
  moduleId: '5',
  title: 'Незнакомец в сети',
  description: 'Как вести себя с незнакомцами онлайн',
  difficulty: 1,
  tasks: [
    // Существующая задача
    Task(
      id: 'edu_q1',
      lessonId: 'education_1',
      type: TaskType.singleChoice,
      // ... остальные параметры
    ),

    // ✅ Добавьте новую задачу
    Task(
      id: 'edu_q2',  // Уникальный ID
      lessonId: 'education_1',
      type: TaskType.dialogueChoice,
      orderIndex: 1,  // Порядковый номер
      title: 'Подозрительное сообщение',
      instructions: 'Как ты поступишь?',
      payload: {
        'scenario': 'Тебе пришло странное сообщение',
        'messages': [
          {
            'id': 'm1',
            'speaker': 'Незнакомец',
            'message': 'Привет! Хочешь получить бесплатные скины?',
            'isUser': false,
          },
        ],
        'choices': [
          {
            'id': 'c1',
            'text': 'Игнорирую и блокирую',
            'isCorrect': true,
            'feedback': 'Правильно!',
          },
          {
            'id': 'c2',
            'text': 'Интересуюсь подробностями',
            'isCorrect': false,
            'feedback': 'Это может быть опасно!',
          },
        ],
      },
      hints: ['Это похоже на мошенничество'],
    ),
  ],
  timeEstimate: 10,  // Обновите время
  points: 200,       // Обновите очки
  iconName: 'school',
)
```

### Вариант 2: Создание нового урока

```dart
// В функции _getDemoLessons() добавьте:
if (module.id == '5') {
  return [
    // Существующий урок
    _getEducationLesson1(),

    // ✅ Новый урок
    Lesson(
      id: 'education_2',
      moduleId: '5',
      title: 'Безопасные пароли',
      description: 'Учимся создавать и хранить пароли',
      difficulty: 2,
      tasks: [
        Task(
          id: 'edu2_q1',
          lessonId: 'education_2',
          type: TaskType.singleChoice,
          orderIndex: 0,
          title: 'Какой пароль безопаснее?',
          payload: {
            'question': 'Выбери самый безопасный пароль:',
            'options': [
              {
                'id': 'o1',
                'text': '12345',
                'isCorrect': false,
                'feedback': 'Это очень слабый пароль!',
              },
              {
                'id': 'o2',
                'text': 'password',
                'isCorrect': false,
                'feedback': 'Это один из самых популярных и слабых паролей.',
              },
              {
                'id': 'o3',
                'text': 'Tr!cky_P@ssw0rd#2024',
                'isCorrect': true,
                'feedback': 'Отлично! Длинный, со спецсимволами и цифрами.',
              },
              {
                'id': 'o4',
                'text': 'ivan1990',
                'isCorrect': false,
                'feedback': 'Личная информация делает пароль слабым.',
              },
            ],
          },
          hints: [
            'Хороший пароль должен быть длинным',
            'Используй буквы, цифры и символы',
          ],
        ),
        // Добавьте еще задачи...
      ],
      timeEstimate: 8,
      points: 120,
      iconName: 'lock',
    ),
  ];
}
```

### Шаблон для быстрого создания задач

#### Single Choice
```dart
Task(
  id: 'unique_id',
  lessonId: 'lesson_id',
  type: TaskType.singleChoice,
  orderIndex: 0,
  title: 'Название задачи',
  instructions: 'Инструкция (опционально)',
  payload: {
    'question': 'Текст вопроса?',
    'shuffleOptions': false,
    'options': [
      {
        'id': 'o1',
        'text': 'Вариант 1',
        'isCorrect': true,
        'feedback': 'Обратная связь',
      },
      // ... еще варианты
    ],
  },
  hints: ['Подсказка 1', 'Подсказка 2'],
)
```

#### Dialogue Choice
```dart
Task(
  id: 'unique_id',
  lessonId: 'lesson_id',
  type: TaskType.dialogueChoice,
  orderIndex: 0,
  title: 'Название задачи',
  payload: {
    'scenario': 'Описание ситуации',
    'messages': [
      {
        'id': 'm1',
        'speaker': 'Персонаж',
        'message': 'Текст сообщения',
        'isUser': false,
      },
      // ... еще сообщения
    ],
    'choices': [
      {
        'id': 'c1',
        'text': 'Вариант ответа',
        'isCorrect': true,
        'feedback': 'Обратная связь',
        'consequence': 'Что произошло',
      },
      // ... еще варианты
    ],
  },
  hints: ['Подсказка'],
)
```

---

## 🗂️ Создание нового модуля

### Шаг 1: Добавьте модуль в HomePage

**Файл:** `lib/features/home/presentation/pages/home_page.dart`

```dart
List<Module> _getDemoModules() {
  return [
    // Существующие модули...
    Module(
      id: '5',
      title: 'Образование',
      description: 'Общая цифровая грамотность',
      iconName: 'school',
      color: '#3498DB',
      badgeCount: 7,
      lessons: [],
    ),

    // ✅ Новый модуль
    Module(
      id: '6',
      title: 'Социальные сети',
      description: 'Безопасность в соцсетях',
      iconName: 'people',  // Используйте Material Icons
      color: '#E91E63',    // Hex цвет (Розовый)
      badgeCount: 0,
      lessons: [],
    ),
  ];
}
```

### Шаг 2: Создайте уроки для модуля

**Файл:** `lib/features/lessons/presentation/pages/lesson_list_page.dart`

```dart
List<Lesson> _getDemoLessons(Module module) {
  // Существующие модули...

  // ✅ Новый модуль
  if (module.id == '6') {
    return [
      Lesson(
        id: 'social_1',
        moduleId: '6',
        title: 'Настройки приватности',
        description: 'Как правильно настроить приватность',
        difficulty: 1,
        tasks: [
          Task(
            id: 'social_q1',
            lessonId: 'social_1',
            type: TaskType.singleChoice,
            orderIndex: 0,
            title: 'Кто должен видеть твои посты?',
            payload: {
              'question': 'Какую настройку лучше выбрать для своего профиля?',
              'options': [
                {
                  'id': 'o1',
                  'text': 'Публичный профиль (все)',
                  'isCorrect': false,
                  'feedback': 'Так твою информацию увидят незнакомцы.',
                },
                {
                  'id': 'o2',
                  'text': 'Только друзья',
                  'isCorrect': true,
                  'feedback': 'Правильно! Так безопаснее.',
                },
                {
                  'id': 'o3',
                  'text': 'Друзья друзей',
                  'isCorrect': false,
                  'feedback': 'Это могут быть незнакомые люди.',
                },
              ],
            },
            hints: ['Подумай о безопасности'],
          ),
        ],
        timeEstimate: 5,
        points: 100,
        iconName: 'privacy_tip',
      ),

      // Добавьте еще уроки...
    ];
  }

  // Заглушка для пустых модулей
  return [
    Lesson(
      id: '${module.id}_dummy',
      moduleId: module.id,
      title: 'Скоро здесь появятся уроки!',
      description: 'Этот модуль в разработке',
      difficulty: 1,
      tasks: [],
      timeEstimate: 5,
      points: 50,
      iconName: 'construction',
    ),
  ];
}
```

### Шаг 3: Выберите иконку

Доступные иконки из [Material Icons](https://fonts.google.com/icons):

- `lightbulb` - Лампочка
- `psychology` - Мозг
- `emoji_events` - Трофей
- `search` - Поиск
- `school` - Школа
- `people` - Люди
- `lock` - Замок
- `security` - Щит
- `games` - Игры
- `wifi` - WiFi
- `smartphone` - Смартфон
- `laptop` - Ноутбук

Добавьте в `ModuleCard._getIconData()` если нужна новая иконка:

```dart
IconData _getIconData() {
  switch (iconName) {
    case 'lightbulb': return Icons.lightbulb;
    case 'psychology': return Icons.psychology;
    case 'emoji_events': return Icons.emoji_events;
    case 'search': return Icons.search;
    case 'school': return Icons.school;
    case 'people': return Icons.people;  // ✅ Добавьте
    default: return Icons.help;
  }
}
```

---

## ✅ Лучшие практики

### Структура кода

**DO:**
- ✅ Используйте `const` конструкторы где возможно
- ✅ Разделяйте UI и бизнес-логику
- ✅ Следуйте naming conventions (camelCase, PascalCase)
- ✅ Добавляйте комментарии к сложным частям
- ✅ Используйте `final` для неизменяемых переменных

**DON'T:**
- ❌ Не создавайте виджеты в методах (используйте `Widget _buildSomething()`)
- ❌ Не дублируйте код (создавайте переиспользуемые компоненты)
- ❌ Не используйте magic numbers (создайте константы)
- ❌ Не забывайте `dispose()` для контроллеров

### Дизайн задач

**DO:**
- ✅ Делайте вопросы понятными для детей
- ✅ Используйте конкретные примеры из жизни
- ✅ Давайте конструктивную обратную связь
- ✅ Добавляйте подсказки для сложных вопросов
- ✅ Балансируйте сложность (начинайте легко, усложняйте постепенно)

**DON'T:**
- ❌ Не используйте сложные термины без объяснений
- ❌ Не создавайте слишком длинные задачи
- ❌ Не делайте все задачи одного типа подряд
- ❌ Не пугайте детей (избегайте страшных сценариев)

### Производительность

**DO:**
- ✅ Используйте `ListView.builder` для длинных списков
- ✅ Оптимизируйте изображения (WebP, сжатие)
- ✅ Кэшируйте данные локально
- ✅ Используйте `const` виджеты

**DON'T:**
- ❌ Не загружайте большие изображения в payload
- ❌ Не создавайте слишком глубокую иерархию виджетов
- ❌ Не делайте тяжелые операции в `build()`

---

## 🧪 Тестирование

### Ручное тестирование

**Чеклист для новой задачи:**
- [ ] Задача отображается корректно
- [ ] Все варианты ответов видны
- [ ] Выбор ответа работает
- [ ] Обратная связь корректна
- [ ] Подсказки работают
- [ ] Баллы начисляются правильно
- [ ] Переход к следующей задаче работает
- [ ] На разных размерах экрана все читаемо

### Unit тесты (будущее)

Создайте тесты для моделей данных:

```dart
// test/features/tasks/domain/entities/task_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cyber_shield/features/tasks/domain/entities/task.dart';

void main() {
  group('Task Entity', () {
    test('should create task with required fields', () {
      final task = Task(
        id: 'test_id',
        lessonId: 'lesson_1',
        type: TaskType.singleChoice,
        orderIndex: 0,
        payload: {'question': 'Test?'},
      );

      expect(task.id, 'test_id');
      expect(task.type, TaskType.singleChoice);
    });

    test('should have default values for optional fields', () {
      final task = Task(
        id: 'test_id',
        lessonId: 'lesson_1',
        type: TaskType.singleChoice,
        orderIndex: 0,
        payload: {},
      );

      expect(task.hints, isEmpty);
      expect(task.isRequired, true);
      expect(task.maxAttempts, 1);
    });
  });
}
```

### Widget тесты (будущее)

```dart
// test/features/tasks/presentation/widgets/task_types/single_choice_widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('SingleChoiceWidget renders options', (tester) async {
    // Arrange
    final task = Task(
      id: 'test',
      lessonId: 'lesson',
      type: TaskType.singleChoice,
      orderIndex: 0,
      payload: {
        'question': 'Test question?',
        'options': [
          {'id': 'o1', 'text': 'Option 1', 'isCorrect': true},
          {'id': 'o2', 'text': 'Option 2', 'isCorrect': false},
        ],
      },
    );

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChoiceTaskWidget(
            task: task,
            callbacks: TaskCallbacks(
              onComplete: (_) {},
            ),
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('Test question?'), findsOneWidget);
    expect(find.text('Option 1'), findsOneWidget);
    expect(find.text('Option 2'), findsOneWidget);
  });
}
```

---

## ❓ Часто задаваемые вопросы

### Как добавить изображение к вопросу?

Добавьте `imageUrl` в payload:

```dart
payload: {
  'question': 'Что изображено на картинке?',
  'imageUrl': 'https://example.com/image.jpg',
  'options': [/* ... */],
}
```

Или используйте локальное изображение:

1. Добавьте изображение в `assets/images/`
2. Зарегистрируйте в `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/
```
3. Используйте:
```dart
'imageUrl': 'assets/images/my_image.png',
```
4. В виджете измените `Image.network` на `Image.asset`

### Как изменить цвет модуля?

В `home_page.dart` измените значение `color`:

```dart
Module(
  id: '1',
  title: 'Введение',
  color: '#4ECDC4',  // ← Измените hex код
  // ...
)
```

Используйте [Color Picker](https://htmlcolorcodes.com/) для выбора цвета.

### Как добавить больше подсказок?

Просто добавьте в массив `hints`:

```dart
Task(
  // ...
  hints: [
    'Подсказка 1',
    'Подсказка 2',
    'Подсказка 3',
    // Можно добавлять сколько угодно
  ],
)
```

Каждая подсказка снижает балл на 10 очков.

### Как изменить формулу подсчета баллов?

Измените метод `calculateScore` в `BaseTaskState`:

```dart
int calculateScore(bool isCorrect) {
  if (!isCorrect) return 10;

  int score = 100;

  // ✅ Измените штрафы
  score -= _usedHints.length * 15;  // Было 10

  if (_attemptCount > 1) {
    score -= (_attemptCount - 1) * 25;  // Было 20
  }

  // ✅ Добавьте бонусы
  final timeSpent = DateTime.now().difference(_startTime).inSeconds;
  if (timeSpent < 30) {
    score += 10;  // Бонус за скорость
  }

  return score.clamp(10, 110);  // Макс. 110 баллов
}
```

### Как сделать задачу необязательной?

Установите `isRequired: false`:

```dart
Task(
  id: 'optional_task',
  lessonId: 'lesson_1',
  type: TaskType.singleChoice,
  orderIndex: 0,
  payload: {/* ... */},
  isRequired: false,  // ✅ Необязательная задача
)
```

**Примечание:** В текущей версии необязательные задачи не реализованы в UI, но поле уже есть в модели.

### Как добавить ограничение по времени?

Установите `timeLimit` (в секундах):

```dart
Task(
  id: 'timed_task',
  lessonId: 'lesson_1',
  type: TaskType.singleChoice,
  orderIndex: 0,
  payload: {/* ... */},
  timeLimit: 60,  // ✅ 60 секунд на задачу
)
```

**Примечание:** Таймер нужно реализовать в виджете задачи.

### Как добавить анимацию?

Используйте `AnimatedContainer`, `Hero`, или `flutter_animate`:

```dart
// Простая анимация размера
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  width: isSelected ? 100 : 80,
  height: isSelected ? 100 : 80,
  child: Icon(Icons.check),
)

// С пакетом flutter_animate
Text('Правильно!')
  .animate()
  .fadeIn(duration: 300.ms)
  .scale(delay: 100.ms);
```

### Где хранить большие JSON данные?

Для больших объемов контента создайте JSON файлы:

1. Создайте `assets/data/lessons.json`:
```json
{
  "lessons": [
    {
      "id": "lesson_1",
      "title": "Урок 1",
      "tasks": [/* ... */]
    }
  ]
}
```

2. Зарегистрируйте в `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/data/
```

3. Загрузите в коде:
```dart
import 'dart:convert';
import 'package:flutter/services.dart';

Future<List<Lesson>> loadLessons() async {
  final jsonString = await rootBundle.loadString('assets/data/lessons.json');
  final jsonData = json.decode(jsonString);

  return (jsonData['lessons'] as List)
      .map((l) => Lesson.fromJson(l))
      .toList();
}
```

---

## 🔧 Полезные команды

```bash
# Запуск приложения
flutter run

# Горячая перезагрузка (в терминале с запущенным приложением)
# Нажмите 'r'

# Полная перезагрузка
# Нажмите 'R'

# Форматирование кода
flutter format lib/

# Анализ кода
flutter analyze

# Генерация кода (для Freezed, JSON serialization)
flutter pub run build_runner build --delete-conflicting-outputs

# Очистка build кэша
flutter clean

# Обновление зависимостей
flutter pub get
```

---

## 📚 Дополнительные ресурсы

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design 3](https://m3.material.io/)
- [Google Fonts](https://fonts.google.com/)
- [Material Icons](https://fonts.google.com/icons)

---

**Документ обновлен:** 2025-01-23
**Версия:** 1.0

Если у вас есть вопросы, создайте Issue в репозитории!

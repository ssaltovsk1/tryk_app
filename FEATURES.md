# ✨ Реализованные функции Cyber Shield

> **Версия:** 1.0.0 (MVP)
> **Дата обновления:** 2025-01-23

Этот документ содержит детальное описание всех реализованных функций приложения с примерами кода и скриншотами использования.

---

## 📑 Содержание

1. [Архитектура приложения](#архитектура-приложения)
2. [Модуль Home](#модуль-home)
3. [Модуль Lessons](#модуль-lessons)
4. [Модуль Tasks](#модуль-tasks)
5. [Система тем](#система-тем)
6. [Модели данных](#модели-данных)
7. [Навигация](#навигация)

---

## 🏛️ Архитектура приложения

### Общая структура

Приложение построено на принципах **Clean Architecture** с разделением на слои:

```
📁 lib/
├── 📁 core/           # Общие компоненты
│   └── 📁 theme/      # Темы и стили
│
├── 📁 features/       # Функциональные модули
│   ├── 📁 home/       # Главный экран
│   ├── 📁 lessons/    # Система уроков
│   └── 📁 tasks/      # Движок задач
│
└── main.dart          # Точка входа
```

### Принципы архитектуры

**1. Feature-based структура**
- Каждый модуль (feature) независим
- Внутри модуля: `domain` → `data` → `presentation`
- Минимум связей между модулями

**2. Слои модуля**
```
feature/
├── domain/           # Бизнес-логика
│   └── entities/     # Модели данных
│
├── data/             # Работа с данными (будущее)
│   ├── models/
│   ├── datasources/
│   └── repositories/
│
└── presentation/     # UI слой
    ├── pages/        # Экраны
    ├── widgets/      # Виджеты
    └── providers/    # State management (будущее)
```

**3. Task Engine паттерн**
- Registry для регистрации типов задач
- Factory для создания виджетов
- Base класс для общей логики
- Callbacks для коммуникации

---

## 🏠 Модуль Home

### Файл: `lib/features/home/presentation/pages/home_page.dart`

### Описание
Главный экран приложения с сеткой модулей обучения. Использует Material Design 3 с адаптивной версткой.

### Компоненты

#### HomePage Widget

**Основной виджет:**
```dart
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cyber Shield'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(context),
              const SizedBox(height: 24),
              Expanded(child: _buildModulesGrid(context)),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Функции:**

1. **_buildWelcomeSection()**
```dart
Widget _buildWelcomeSection(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Привет! 👋',
        style: Theme.of(context).textTheme.displaySmall,
      ),
      const SizedBox(height: 8),
      Text(
        'Выбери модуль для обучения',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
    ],
  );
}
```

2. **_buildModulesGrid()**
```dart
Widget _buildModulesGrid(BuildContext context) {
  final modules = _getDemoModules();

  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,          // 2 колонки
      crossAxisSpacing: 16,       // Отступ между колонками
      mainAxisSpacing: 16,        // Отступ между рядами
      childAspectRatio: 0.85,     // Соотношение сторон карточки
    ),
    itemCount: modules.length,
    itemBuilder: (context, index) {
      final module = modules[index];
      return ModuleCard(
        title: module.title,
        iconName: module.iconName,
        color: Color(int.parse(module.color.replaceFirst('#', '0xFF'))),
        badgeCount: module.badgeCount,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LessonListPage(module: module),
            ),
          );
        },
      );
    },
  );
}
```

3. **_getDemoModules()**
```dart
List<Module> _getDemoModules() {
  return [
    Module(
      id: '1',
      title: 'Введение',
      description: 'Основы кибербезопасности',
      iconName: 'lightbulb',
      color: '#4ECDC4',
      badgeCount: 3,
      lessons: [],
    ),
    // ... еще 4 модуля
  ];
}
```

### Реализованные модули

| ID | Название | Описание | Цвет | Иконка | Бейджи |
|----|----------|----------|------|--------|--------|
| 1 | Введение | Основы кибербезопасности | #4ECDC4 (Teal) | lightbulb | 3 |
| 2 | Модели Мошенничества | Виды онлайн-мошенничества | #9B59B6 (Purple) | psychology | 5 |
| 3 | Тренировка | Практические упражнения | #E74C3C (Red) | emoji_events | 8 |
| 4 | Детективный Квест | Интерактивные расследования | #F39C12 (Orange) | search | 12 |
| 5 | Образование | Общая цифровая грамотность | #3498DB (Blue) | school | 7 |

### ModuleCard Widget

**Файл:** `lib/features/home/presentation/widgets/module_card.dart`

```dart
class ModuleCard extends StatelessWidget {
  final String title;
  final String iconName;
  final Color color;
  final int badgeCount;
  final VoidCallback onTap;

  const ModuleCard({
    super.key,
    required this.title,
    required this.iconName,
    required this.color,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(),
              const SizedBox(height: 12),
              _buildTitle(context),
              if (badgeCount > 0) ...[
                const SizedBox(height: 8),
                _buildBadge(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getIconData(),
        size: 32,
        color: color,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '🏆 $badgeCount',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getIconData() {
    switch (iconName) {
      case 'lightbulb': return Icons.lightbulb;
      case 'psychology': return Icons.psychology;
      case 'emoji_events': return Icons.emoji_events;
      case 'search': return Icons.search;
      case 'school': return Icons.school;
      default: return Icons.help;
    }
  }
}
```

**Визуальные особенности:**
- Круглая иконка с цветовым фоном модуля
- Название с переносом строк (max 2 линии)
- Бейдж достижений (если есть)
- Ripple эффект при нажатии
- Тени для глубины

---

## 📚 Модуль Lessons

### 1. Экран списка уроков

**Файл:** `lib/features/lessons/presentation/pages/lesson_list_page.dart`

#### Описание
Отображает список всех уроков внутри выбранного модуля.

#### Код
```dart
class LessonListPage extends StatelessWidget {
  final Module module;

  const LessonListPage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(module.title),
        backgroundColor: _getModuleColor(),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          return _buildLessonCard(context, lesson);
        },
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, Lesson lesson) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _openLesson(context, lesson),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildThumbnail(lesson),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (lesson.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        lesson.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    _buildMetadata(context, lesson),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadata(BuildContext context, Lesson lesson) {
    return Row(
      children: [
        Icon(Icons.timer, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          '${lesson.timeEstimate} мин',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 16),
        Icon(Icons.star, size: 16, color: AppColors.warning),
        const SizedBox(width: 4),
        Text(
          '${lesson.points} очков',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
```

#### Демо-уроки

**1. Детективный Квест (Модуль 4)**
```dart
Lesson(
  id: 'detective_1',
  moduleId: '4',
  title: 'Детективный Квест',
  description: 'Раскрой тайну мошенничества',
  difficulty: 2,
  tasks: [/* DialogueChoice task */],
  timeEstimate: 10,
  points: 150,
  iconName: 'search',
)
```

**2. Незнакомец в сети (Модуль 5)**
```dart
Lesson(
  id: 'education_1',
  moduleId: '5',
  title: 'Незнакомец в сети',
  description: 'Как вести себя с незнакомцами онлайн',
  difficulty: 1,
  tasks: [/* SingleChoice task */],
  timeEstimate: 5,
  points: 100,
  iconName: 'school',
)
```

### 2. Экран прохождения урока

**Файл:** `lib/features/lessons/presentation/pages/lesson_page.dart`

#### Функционал
- Отображение текущей задачи
- Прогресс-бар
- Автопереход к следующей задаче
- Финальный диалог с результатами

#### Код
```dart
class LessonPage extends StatefulWidget {
  final Lesson lesson;

  const LessonPage({super.key, required this.lesson});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  int _currentTaskIndex = 0;
  final List<TaskResult> _results = [];
  int _totalScore = 0;

  @override
  Widget build(BuildContext context) {
    final task = widget.lesson.tasks[_currentTaskIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'Очки: $_totalScore',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LessonProgressBar(
            current: _currentTaskIndex + 1,
            total: widget.lesson.tasks.length,
          ),
          Expanded(
            child: TaskRenderer(
              task: task,
              onTaskComplete: _onTaskComplete,
            ),
          ),
        ],
      ),
    );
  }

  void _onTaskComplete(TaskResult result) {
    setState(() {
      _results.add(result);
      _totalScore += result.score;
    });

    // Подождать 2 секунды перед переходом
    Future.delayed(const Duration(seconds: 2), () {
      if (_currentTaskIndex < widget.lesson.tasks.length - 1) {
        setState(() {
          _currentTaskIndex++;
        });
      } else {
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LessonCompleteDialog(
        lessonTitle: widget.lesson.title,
        totalScore: _totalScore,
        maxScore: widget.lesson.tasks.length * 100,
        tasksCompleted: _results.length,
        totalTasks: widget.lesson.tasks.length,
        onContinue: () {
          Navigator.of(context).pop(); // Закрыть диалог
          Navigator.of(context).pop(); // Вернуться к списку уроков
        },
      ),
    );
  }
}
```

### 3. Прогресс-бар урока

**Файл:** `lib/features/lessons/presentation/widgets/lesson_progress_bar.dart`

```dart
class LessonProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const LessonProgressBar({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (current / total * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Вопрос $current из $total',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: current / total,
              minHeight: 8,
              backgroundColor: AppColors.greyLight,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 4. Диалог завершения урока

**Файл:** `lib/features/lessons/presentation/widgets/lesson_complete_dialog.dart`

```dart
class LessonCompleteDialog extends StatelessWidget {
  final String lessonTitle;
  final int totalScore;
  final int maxScore;
  final int tasksCompleted;
  final int totalTasks;
  final VoidCallback onContinue;

  const LessonCompleteDialog({
    super.key,
    required this.lessonTitle,
    required this.totalScore,
    required this.maxScore,
    required this.tasksCompleted,
    required this.totalTasks,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (totalScore / maxScore * 100).round();
    final isPerfect = percentage == 100;

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
              isPerfect ? Icons.emoji_events : Icons.check_circle,
              size: 64,
              color: isPerfect ? AppColors.warning : AppColors.success,
            ),
            const SizedBox(height: 16),
            Text(
              isPerfect ? 'Идеально! 🎉' : 'Урок завершен!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              lessonTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildStatRow(
              context,
              'Набрано очков',
              '$totalScore / $maxScore',
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              context,
              'Точность',
              '$percentage%',
            ),
            const SizedBox(height: 8),
            _buildStatRow(
              context,
              'Выполнено',
              '$tasksCompleted / $totalTasks',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinue,
                child: const Text('Продолжить'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
```

---

## ⚙️ Модуль Tasks

### Архитектура Task Engine

#### 1. Task Registry

**Файл:** `lib/features/tasks/presentation/core/task_registry.dart`

```dart
typedef TaskWidgetBuilder = Widget Function(
  Task task,
  TaskCallbacks callbacks,
);

class TaskRegistry {
  static final TaskRegistry _instance = TaskRegistry._internal();
  factory TaskRegistry() => _instance;
  TaskRegistry._internal();

  final Map<TaskType, TaskWidgetBuilder> _builders = {};

  /// Регистрация одного типа задачи
  void register(TaskType type, TaskWidgetBuilder builder) {
    _builders[type] = builder;
  }

  /// Массовая регистрация
  void registerAll(Map<TaskType, TaskWidgetBuilder> builders) {
    _builders.addAll(builders);
  }

  /// Создание виджета для задачи
  Widget buildWidget(Task task, TaskCallbacks callbacks) {
    final builder = _builders[task.type];
    if (builder == null) {
      return _buildUnsupportedWidget(task);
    }
    return builder(task, callbacks);
  }

  /// Проверка поддержки типа
  bool isSupported(TaskType type) {
    return _builders.containsKey(type);
  }

  Widget _buildUnsupportedWidget(Task task) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          Text('Тип задачи "${task.type.name}" не поддерживается'),
        ],
      ),
    );
  }
}
```

#### 2. Task Registry Initializer

**Файл:** `lib/features/tasks/presentation/core/task_registry_initializer.dart`

```dart
class TaskRegistryInitializer {
  static void initialize() {
    final registry = TaskRegistry();

    registry.registerAll({
      TaskType.singleChoice: (task, callbacks) =>
          SingleChoiceTaskWidget(task: task, callbacks: callbacks),

      TaskType.dialogueChoice: (task, callbacks) =>
          DialogueChoiceTaskWidget(task: task, callbacks: callbacks),
    });
  }
}
```

Вызывается в `main.dart`:
```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  TaskRegistryInitializer.initialize();
  runApp(const CyberShieldApp());
}
```

#### 3. Task Callbacks

```dart
class TaskCallbacks {
  final void Function(TaskResult result) onComplete;
  final void Function(String hint)? onHintRequested;
  final VoidCallback? onSkip;
  final void Function(int progress)? onProgressUpdate;

  const TaskCallbacks({
    required this.onComplete,
    this.onHintRequested,
    this.onSkip,
    this.onProgressUpdate,
  });
}
```

#### 4. Base Task Widget

**Файл:** `lib/features/tasks/presentation/widgets/base_task_widget.dart`

```dart
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

  /// Отправка результата задачи
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
      score: calculateScore(isCorrect),
      hintsUsed: List.from(_usedHints),
    );

    widget.callbacks.onComplete(result);
  }

  /// Запрос подсказки
  void requestHint(int hintIndex) {
    if (hintIndex < widget.task.hints.length) {
      final hint = widget.task.hints[hintIndex];

      if (!_usedHints.contains(hint)) {
        setState(() {
          _usedHints.add(hint);
        });

        widget.callbacks.onHintRequested?.call(hint);
      }
    }
  }

  /// Вычисление очков
  int calculateScore(bool isCorrect) {
    if (!isCorrect) return 10; // Минимальный балл за попытку

    int score = 100;

    // Штраф за подсказки
    score -= _usedHints.length * 10;

    // Штраф за дополнительные попытки
    if (_attemptCount > 1) {
      score -= (_attemptCount - 1) * 20;
    }

    return score.clamp(10, 100);
  }

  /// Абстрактный метод для UI задачи
  Widget buildTaskContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.task.instructions != null)
          _buildInstructions(context),

        Expanded(
          child: buildTaskContent(context),
        ),

        if (widget.task.hints.isNotEmpty && !_isSubmitting)
          _buildHintButton(context),
      ],
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.info.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.info),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.task.instructions!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: OutlinedButton.icon(
        onPressed: () => _showHintDialog(context),
        icon: const Icon(Icons.lightbulb_outline),
        label: Text(
          _usedHints.isEmpty
            ? 'Показать подсказку'
            : 'Подсказок: ${_usedHints.length}',
        ),
      ),
    );
  }

  void _showHintDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Подсказки'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < widget.task.hints.length; i++)
              _buildHintItem(i),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildHintItem(int index) {
    final isUsed = index < _usedHints.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isUsed ? Icons.check_circle : Icons.lock,
            color: isUsed ? AppColors.success : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isUsed
                ? widget.task.hints[index]
                : 'Подсказка ${index + 1}',
              style: TextStyle(
                color: isUsed ? Colors.black : Colors.grey,
              ),
            ),
          ),
          if (!isUsed)
            TextButton(
              onPressed: () {
                requestHint(index);
                Navigator.pop(context);
              },
              child: const Text('Открыть (-10 очков)'),
            ),
        ],
      ),
    );
  }
}
```

---

### Реализованные типы задач

## 1️⃣ Single Choice Widget

**Файл:** `lib/features/tasks/presentation/widgets/task_types/single_choice_widget.dart`

### Описание
Задача с одним правильным ответом из нескольких вариантов.

### Payload структура

```json
{
  "question": "Текст вопроса",
  "shuffleOptions": true,
  "imageUrl": "https://example.com/image.jpg (optional)",
  "options": [
    {
      "id": "уникальный_id",
      "text": "Текст варианта",
      "isCorrect": true,
      "imageUrl": "url_картинки (optional)",
      "feedback": "Текст обратной связи (optional)"
    }
  ]
}
```

### Пример использования

```dart
Task(
  id: 'edu_q1',
  lessonId: 'education_1',
  type: TaskType.singleChoice,
  orderIndex: 0,
  title: 'Незнакомец в сети',
  instructions: 'Выбери правильный ответ',
  payload: {
    'question': 'Онлайн-незнакомец просит твой домашний адрес. Что ты будешь делать?',
    'shuffleOptions': false,
    'options': [
      {
        'id': 'o1',
        'text': 'Расскажу взрослому',
        'isCorrect': true,
        'feedback': 'Правильно! Всегда рассказывай родителям о таких ситуациях.',
      },
      {
        'id': 'o2',
        'text': 'Отправлю адрес',
        'isCorrect': false,
        'feedback': 'Никогда не делись личной информацией с незнакомцами!',
      },
      {
        'id': 'o3',
        'text': 'Отправлю фейковый адрес',
        'isCorrect': false,
        'feedback': 'Лучше вообще не общаться и рассказать родителям.',
      },
      {
        'id': 'o4',
        'text': 'Просто проигнорирую',
        'isCorrect': false,
        'feedback': 'Хорошо, но лучше также сообщить родителям.',
      },
    ],
  },
  hints: [
    'Подумай о безопасности',
    'Личная информация должна оставаться личной',
  ],
  explanation: 'Никогда не делись личными данными с незнакомцами в интернете.',
  isRequired: true,
  maxAttempts: 3,
)
```

### Реализация (ключевые части)

```dart
class _SingleChoiceTaskWidgetState
    extends BaseTaskState<SingleChoiceTaskWidget> {
  late List<SingleChoiceOption> options;
  String? selectedOptionId;
  bool hasAnswered = false;

  @override
  void initState() {
    super.initState();
    final payload = SingleChoicePayload.fromJson(widget.task.payload);
    options = payload.shuffleOptions
        ? (payload.options..shuffle())
        : payload.options;
  }

  @override
  Widget buildTaskContent(BuildContext context) {
    final payload = SingleChoicePayload.fromJson(widget.task.payload);

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

          const SizedBox(height: 24),

          // Варианты ответов
          ...options.map((option) => _buildOptionCard(option)),

          const SizedBox(height: 24),

          // Кнопка отправки
          ElevatedButton(
            onPressed: selectedOptionId != null && !hasAnswered
                ? _submitAnswer
                : null,
            child: const Text('Ответить'),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(SingleChoiceOption option) {
    final isSelected = selectedOptionId == option.id;
    final isCorrect = option.isCorrect;

    Color? borderColor;
    Color? backgroundColor;
    IconData? icon;

    if (hasAnswered) {
      if (isSelected && isCorrect) {
        borderColor = AppColors.success;
        backgroundColor = AppColors.success.withOpacity(0.1);
        icon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        borderColor = AppColors.error;
        backgroundColor = AppColors.error.withOpacity(0.1);
        icon = Icons.cancel;
      } else if (isCorrect) {
        borderColor = AppColors.success;
        backgroundColor = AppColors.success.withOpacity(0.05);
        icon = Icons.check_circle_outline;
      }
    } else if (isSelected) {
      borderColor = AppColors.primary;
      backgroundColor = AppColors.primary.withOpacity(0.1);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: hasAnswered ? null : () => _selectOption(option.id),
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
                if (icon != null)
                  Icon(
                    icon,
                    color: borderColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectOption(String optionId) {
    if (!hasAnswered) {
      setState(() {
        selectedOptionId = optionId;
      });
    }
  }

  Future<void> _submitAnswer() async {
    if (selectedOptionId == null || hasAnswered) return;

    final selectedOption = options.firstWhere(
      (opt) => opt.id == selectedOptionId,
    );

    setState(() {
      hasAnswered = true;
    });

    await submitAnswer(
      isCorrect: selectedOption.isCorrect,
      userAnswer: selectedOptionId,
      details: {
        'selectedText': selectedOption.text,
        'feedback': selectedOption.feedback,
      },
    );

    // Показать обратную связь
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            selectedOption.feedback ??
            (selectedOption.isCorrect
              ? 'Правильно!'
              : 'Неправильно. Попробуй еще раз.'),
          ),
          backgroundColor: selectedOption.isCorrect
            ? AppColors.success
            : AppColors.error,
        ),
      );
    }
  }
}
```

### Визуальные состояния

**1. До ответа:**
- Белые карточки с серой рамкой
- Выбранная карточка: синяя рамка и фон

**2. После ответа:**
- Правильный ответ: зеленая рамка, иконка ✅
- Неправильный выбор: красная рамка, иконка ❌
- SnackBar с обратной связью

---

## 2️⃣ Dialogue Choice Widget

**Файл:** `lib/features/tasks/presentation/widgets/task_types/dialogue_choice_widget.dart`

### Описание
Интерактивный чат-сценарий с NPC персонажами и выбором ответов с последствиями.

### Payload структура

```json
{
  "scenario": "Описание сценария",
  "contextImageUrl": "url_изображения (optional)",
  "messages": [
    {
      "id": "msg_id",
      "speaker": "Имя персонажа",
      "message": "Текст сообщения",
      "avatarUrl": "url_аватара (optional)",
      "isUser": false,
      "type": "text"
    }
  ],
  "choices": [
    {
      "id": "choice_id",
      "text": "Текст варианта ответа",
      "isCorrect": true,
      "feedback": "Обратная связь в диалоге (optional)",
      "consequence": "Что произошло после выбора (optional)"
    }
  ]
}
```

### Типы сообщений (MessageType)

```dart
enum MessageType {
  text,     // Обычное сообщение NPC
  choice,   // Выбор пользователя (добавляется автоматически)
  result,   // Последствие выбора (добавляется автоматически)
}
```

### Пример использования

```dart
Task(
  id: 'detective_q1',
  lessonId: 'detective_1',
  type: TaskType.dialogueChoice,
  orderIndex: 0,
  title: 'Начало расследования',
  instructions: 'Прочитай диалог и выбери правильный ответ',
  payload: {
    'scenario': 'Детективное расследование мошенничества',
    'messages': [
      {
        'id': 'm1',
        'speaker': 'Детектив',
        'message': 'Привет, юный детектив! Готов разгадать тайну?',
        'isUser': false,
        'type': 'text',
      },
      {
        'id': 'm2',
        'speaker': 'Вы',
        'message': 'Конечно, готов!',
        'isUser': true,
        'type': 'text',
      },
      {
        'id': 'm3',
        'speaker': 'Детектив',
        'message': 'Отлично! Слушай внимательно...',
        'isUser': false,
        'type': 'text',
      },
      {
        'id': 'm4',
        'speaker': 'Детектив',
        'message': 'Ты играешь в свою любимую игру, и вдруг тебе приходит сообщение от «королевы». Она пишет, что ты выиграл приз и просит твой пароль от игры, чтобы перевести награду. Что ты сделаешь?',
        'isUser': false,
        'type': 'text',
      },
    ],
    'choices': [
      {
        'id': 'c1',
        'text': 'Расскажу родителям о сообщении',
        'isCorrect': true,
        'feedback': 'Отлично! Рассказать взрослому - это всегда правильное решение.',
        'consequence': 'Родители похвалили тебя за бдительность и объяснили, что это была попытка мошенничества!',
      },
      {
        'id': 'c2',
        'text': 'Отправлю пароль, чтобы получить приз',
        'isCorrect': false,
        'feedback': 'Это очень опасно! Никогда не делись паролями.',
        'consequence': 'Твой аккаунт был взломан, и ты потерял все свои достижения в игре.',
      },
      {
        'id': 'c3',
        'text': 'Напишу «королеве», что у меня нет пароля',
        'isCorrect': false,
        'feedback': 'Лучше вообще не отвечать мошенникам.',
        'consequence': 'Мошенник продолжил тебя уговаривать и спрашивать другую информацию.',
      },
    ],
  },
  hints: [
    'Подумай, что самое безопасное?',
    'Всегда спрашивай у родителей, если что-то кажется подозрительным!',
  ],
  isRequired: true,
)
```

### Реализация (ключевые части)

```dart
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

      // Автоматически добавлять следующее сообщение
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

  @override
  Widget buildTaskContent(BuildContext context) {
    return Column(
      children: [
        // Блок сценария
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Theme.of(context).primaryColor,
              ),
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

        // Список сообщений
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: displayedMessages.length,
            itemBuilder: (context, index) {
              return _buildMessage(displayedMessages[index]);
            },
          ),
        ),

        // Варианты выбора (показываются после всех сообщений)
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

    Color color;
    if (message.type == MessageType.result) {
      color = AppColors.systemMessage;
    } else if (isUser) {
      color = AppColors.userMessage;
    } else {
      color = AppColors.botMessage;
    }

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
          color: color,
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
            if (!isUser) const SizedBox(height: 4),
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

  void _selectChoice(DialogueChoice choice) {
    if (hasAnswered) return;

    setState(() {
      selectedChoice = choice;
      hasAnswered = true;

      // Добавить выбор пользователя как сообщение
      displayedMessages.add(DialogueMessage(
        id: 'user_choice',
        speaker: 'Вы',
        message: choice.text,
        isUser: true,
        type: MessageType.choice,
      ));

      // Добавить последствие, если есть
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

    // Показать feedback диалог
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
        content: Text(
          choice.feedback ??
              (choice.isCorrect
                  ? 'Вы выбрали безопасный вариант ответа!'
                  : 'Этот ответ может быть опасным.'),
        ),
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

### Визуальные особенности

**Цвета сообщений:**
- Пользователь: Синий (#5B9FFF) с белым текстом
- NPC: Светло-зеленый (#E8F5E9) с темным текстом
- Система/результат: Светло-желтый (#FFF9E6)

**Анимация:**
- Сообщения появляются с задержкой 1.5 сек
- Автоскролл к последнему сообщению
- Плавная анимация скролла

**Элементы UI:**
- Скругленные углы сообщений (кроме "хвостика")
- Имя говорящего для NPC
- Блок сценария сверху
- Варианты выбора внизу после всех сообщений

---

## 🎨 Система тем

### App Colors

**Файл:** `lib/core/theme/app_colors.dart`

```dart
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF5B9FFF);
  static const Color primaryDark = Color(0xFF4A7FCC);
  static const Color primaryLight = Color(0xFF8FC3FF);

  // Secondary Colors
  static const Color secondary = Color(0xFFFF9E5B);
  static const Color secondaryDark = Color(0xFFCC7E4A);
  static const Color secondaryLight = Color(0xFFFFB88F);

  // Module Colors
  static const Color introduction = Color(0xFF4ECDC4);
  static const Color fraudModels = Color(0xFF9B59B6);
  static const Color training = Color(0xFFE74C3C);
  static const Color detectiveQuest = Color(0xFFF39C12);
  static const Color education = Color(0xFF3498DB);

  // Feedback Colors
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Color(0xFF3498DB);

  // Neutral Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF95A5A6);
  static const Color greyLight = Color(0xFFECF0F1);
  static const Color greyDark = Color(0xFF7F8C8D);

  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Chat Colors
  static const Color userMessage = Color(0xFF5B9FFF);
  static const Color botMessage = Color(0xFFE8F5E9);
  static const Color systemMessage = Color(0xFFFFF9E6);
}
```

### App Theme

**Файл:** `lib/core/theme/app_theme.dart`

```dart
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        background: AppColors.background,
        surface: AppColors.surface,
      ),

      // Typography
      textTheme: GoogleFonts.nunitoTextTheme(
        ThemeData.light().textTheme,
      ).copyWith(
        displayLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        displayMedium: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        displaySmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        headlineLarge: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        headlineMedium: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        headlineSmall: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        titleLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        titleMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        titleSmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          color: AppColors.black,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          color: AppColors.black,
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          color: AppColors.grey,
        ),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.black,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: AppColors.surface,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: AppColors.greyLight.withOpacity(0.3),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.greyLight,
      ),
    );
  }
}
```

---

## 📦 Модели данных

### Task Entity

**Файл:** `lib/features/tasks/domain/entities/task.dart`

```dart
enum TaskType {
  singleChoice,
  multipleChoice,
  trueFalse,
  matchPairs,
  dragAndDropSequence,
  dialogueChoice,
  inputTextShort,
  scenarioBranching,
}

class Task {
  final String id;
  final String lessonId;
  final TaskType type;
  final int orderIndex;
  final String? title;
  final String? instructions;
  final Map<String, dynamic> payload;
  final List<String> hints;
  final String? explanation;
  final Map<String, dynamic>? metadata;
  final bool isRequired;
  final int maxAttempts;
  final int? timeLimit;

  const Task({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.orderIndex,
    required this.payload,
    this.title,
    this.instructions,
    this.hints = const [],
    this.explanation,
    this.metadata,
    this.isRequired = true,
    this.maxAttempts = 1,
    this.timeLimit,
  });
}
```

### TaskResult Entity

```dart
class TaskResult {
  final String taskId;
  final bool isCorrect;
  final int attemptNumber;
  final DateTime startedAt;
  final DateTime completedAt;
  final String? userAnswer;
  final Map<String, dynamic>? details;
  final int score;
  final List<String> hintsUsed;

  const TaskResult({
    required this.taskId,
    required this.isCorrect,
    required this.attemptNumber,
    required this.startedAt,
    required this.completedAt,
    this.userAnswer,
    this.details,
    required this.score,
    this.hintsUsed = const [],
  });

  Duration get timeSpent => completedAt.difference(startedAt);
}
```

### Lesson Entity

**Файл:** `lib/features/tasks/domain/entities/lesson.dart`

```dart
class Lesson {
  final String id;
  final String moduleId;
  final String title;
  final String? description;
  final int difficulty;
  final List<Task> tasks;
  final int timeEstimate;
  final int points;
  final String? imageUrl;
  final String? iconName;

  const Lesson({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.tasks,
    this.description,
    this.difficulty = 1,
    this.timeEstimate = 5,
    this.points = 100,
    this.imageUrl,
    this.iconName,
  });
}
```

### Module Entity

```dart
class Module {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final String color;
  final int badgeCount;
  final List<Lesson> lessons;

  const Module({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.color,
    this.badgeCount = 0,
    this.lessons = const [],
  });
}
```

---

## 🧭 Навигация

### Схема навигации

```
CyberShieldApp (MaterialApp)
  └─> HomePage
       └─> (Tap Module Card)
            └─> LessonListPage
                 └─> (Tap Lesson Card)
                      └─> LessonPage
                           └─> TaskRenderer
                                └─> [Task Widget]
                                     └─> (Complete)
                                          └─> LessonCompleteDialog
                                               └─> (Continue)
                                                    └─> Back to LessonListPage
```

### Навигация между экранами

```dart
// Home → LessonList
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => LessonListPage(module: module),
  ),
);

// LessonList → LessonPage
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => LessonPage(lesson: lesson),
  ),
);

// LessonPage → Back (после завершения)
Navigator.of(context).pop(); // Закрыть диалог
Navigator.of(context).pop(); // Вернуться к списку
```

---

## 📊 Статистика проекта

### Код

- **Общее количество файлов Dart:** ~20+
- **Строк кода:** ~3000+
- **Виджетов:** 15+
- **Модели данных:** 8+

### Контент

- **Модулей:** 5
- **Уроков (демо):** 2 полностью функциональных
- **Задач (демо):** 2 (SingleChoice + DialogueChoice)
- **Типов задач реализовано:** 2 из 8

### Покрытие функционала

| Функция | Статус |
|---------|--------|
| Архитектура | ✅ 100% |
| Домашний экран | ✅ 100% |
| Список уроков | ✅ 100% |
| Прохождение урока | ✅ 100% |
| Task Engine | ✅ 100% |
| Single Choice | ✅ 100% |
| Dialogue Choice | ✅ 100% |
| Другие типы задач | ⏳ 0% (6 типов) |
| Сохранение прогресса | ⏳ 0% |
| Аутентификация | ⏳ 0% |
| AI интеграция | ⏳ 0% |
| Геймификация | ⏳ 0% |

---

## 🔜 Следующие шаги

См. [ROADMAP.md](ROADMAP.md) для детального плана развития.

---

**Последнее обновление:** 2025-01-23
**Версия документа:** 1.0

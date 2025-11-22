# Cyber Shield - Educational Cybersecurity App for Children

An interactive educational Flutter application designed to teach children about cybersecurity and safe online behavior through engaging quizzes, detective quests, and interactive scenarios.

## 🎯 Features

### Implemented Screens

1. **Home Screen (Module Selection)**
   - Grid layout with 5 educational modules
   - Each module has a distinct icon and color
   - Badge count display for achievements
   - Modules:
     - Введение (Introduction)
     - Модели Мошенничества (Fraud Models)
     - Тренировка (Training)
     - Детективный Квест (Detective Quest)
     - Образование (Education)

2. **Lesson List Screen**
   - Displays lessons within a selected module
   - Shows lesson difficulty, time estimate, and points
   - Visual cards with icons or images

3. **Lesson/Quiz Screen**
   - Progress bar showing current question/total questions
   - Task renderer for different question types
   - Completion dialog with statistics

### Task Engine

The app features a flexible **Task Engine** that supports multiple task types:

#### Implemented Task Types:

1. **Single Choice**
   - Multiple choice with one correct answer
   - Visual feedback (green for correct, red for incorrect)
   - Option to show images with choices
   - Shuffling support

2. **Dialogue Choice**
   - Chat-based interface
   - Animated message appearance
   - Multiple choice responses
   - Consequence and feedback system
   - Perfect for scenario-based learning

#### Task Engine Architecture:

```
TaskRegistry (Singleton)
├── Task Types Registration
├── Widget Builders
└── Task Rendering

BaseTaskWidget
├── State Management
├── Hint System
├── Score Calculation
└── Result Submission
```

## 🏗️ Project Structure

```
lib/
├── core/
│   └── theme/
│       ├── app_colors.dart      # Color palette
│       └── app_theme.dart       # App theme configuration
│
├── features/
│   ├── home/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── home_page.dart
│   │       └── widgets/
│   │           └── module_card.dart
│   │
│   ├── lessons/
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── lesson_list_page.dart
│   │       │   └── lesson_page.dart
│   │       └── widgets/
│   │           ├── lesson_progress_bar.dart
│   │           └── lesson_complete_dialog.dart
│   │
│   └── tasks/
│       ├── domain/
│       │   └── entities/
│       │       ├── task.dart
│       │       └── lesson.dart
│       │
│       └── presentation/
│           ├── core/
│           │   ├── task_registry.dart
│           │   └── task_registry_initializer.dart
│           │
│           └── widgets/
│               ├── base_task_widget.dart
│               ├── task_renderer.dart
│               └── task_types/
│                   ├── single_choice_widget.dart
│                   └── dialogue_choice_widget.dart
│
└── main.dart
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  dartz: ^0.10.1
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  google_fonts: ^6.1.0
  get_it: ^7.6.4
  shared_preferences: ^2.2.2
  dio: ^5.4.0
  equatable: ^2.0.5
```

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd tryk_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 📱 Usage

### Creating a New Task Type

1. Create a new widget in `lib/features/tasks/presentation/widgets/task_types/`:

```dart
class MyCustomTaskWidget extends BaseTaskWidget {
  const MyCustomTaskWidget({
    super.key,
    required super.task,
    required super.callbacks,
  });

  @override
  State<MyCustomTaskWidget> createState() => _MyCustomTaskWidgetState();
}

class _MyCustomTaskWidgetState extends BaseTaskState<MyCustomTaskWidget> {
  @override
  Widget buildTaskContent(BuildContext context) {
    // Your custom UI here
    return Container();
  }
}
```

2. Register it in `task_registry_initializer.dart`:

```dart
registry.register(
  TaskType.myCustomType,
  (task, callbacks) => MyCustomTaskWidget(task: task, callbacks: callbacks),
);
```

### Adding a New Lesson

Lessons are defined in `lesson_list_page.dart`. Example:

```dart
Task(
  id: 'unique_id',
  lessonId: 'lesson_id',
  type: TaskType.singleChoice,
  orderIndex: 0,
  title: 'Task Title',
  instructions: 'Instructions for the user',
  payload: {
    'question': 'Your question here?',
    'options': [
      {
        'id': 'o1',
        'text': 'Option 1',
        'isCorrect': true,
        'feedback': 'Great job!',
      },
      // More options...
    ],
  },
  hints: ['Hint 1', 'Hint 2'],
)
```

## 🎨 Design System

### Colors

- **Primary**: `#5B9FFF` (Blue)
- **Secondary**: `#FF9E5B` (Orange)
- **Success**: `#27AE60` (Green)
- **Error**: `#E74C3C` (Red)
- **Warning**: `#F39C12` (Orange)

### Module Colors

- **Introduction**: `#4ECDC4` (Teal)
- **Fraud Models**: `#9B59B6` (Purple)
- **Training**: `#E74C3C` (Red)
- **Detective Quest**: `#F39C12` (Orange)
- **Education**: `#3498DB` (Blue)

## 🔄 Future Enhancements

### Planned Task Types:

1. **Multiple Choice** - Select multiple correct answers
2. **True/False** - Simple true or false questions
3. **Match Pairs** - Connect related items
4. **Drag and Drop Sequence** - Arrange items in correct order
5. **Text Input** - Short text answer validation
6. **Scenario Branching** - Interactive story with multiple paths

### Planned Features:

- User authentication and profiles
- Progress tracking and persistence
- Achievements and badges system
- Parent dashboard
- AI-powered chat assistant
- Multiplayer challenges
- Leaderboards
- Certificate generation

## 📄 License

This project is licensed under the MIT License.

## 👥 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For support, email support@cybershield.com or open an issue in the repository.

---

**Made with ❤️ for children's online safety**

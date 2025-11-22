import 'package:flutter/material.dart';
import '../../../tasks/domain/entities/lesson.dart';
import '../../../tasks/domain/entities/task.dart';
import 'lesson_page.dart';

class LessonListPage extends StatelessWidget {
  final Module module;

  const LessonListPage({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    final lessons = _getDemoLessons(module.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(module.title),
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonPage(lesson: lesson),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (lesson.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    lesson.imageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.image,
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIcon(lesson.iconName),
                    color: Theme.of(context).primaryColor,
                    size: 40,
                  ),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    if (lesson.description != null)
                      Text(
                        lesson.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${lesson.timeEstimate} мин',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${lesson.points} очков',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
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

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'detective':
        return Icons.search;
      case 'education':
        return Icons.school;
      case 'quiz':
        return Icons.quiz;
      default:
        return Icons.article;
    }
  }

  List<Lesson> _getDemoLessons(String moduleId) {
    if (moduleId == '4') {
      // Детективный квест
      return [
        Lesson(
          id: 'detective_1',
          moduleId: moduleId,
          title: 'Детективный квест',
          description: 'Помоги детективу раскрыть онлайн мошенничество',
          difficulty: 1,
          tasks: _getDetectiveQuestTasks(),
          timeEstimate: 10,
          points: 150,
          iconName: 'detective',
        ),
      ];
    } else if (moduleId == '5') {
      // Образование
      return [
        Lesson(
          id: 'education_1',
          moduleId: moduleId,
          title: 'Незнакомец в сети',
          description: 'Научись правильно реагировать на незнакомцев онлайн',
          difficulty: 1,
          tasks: _getEducationTasks(),
          timeEstimate: 5,
          points: 100,
          iconName: 'education',
        ),
      ];
    }

    return [
      Lesson(
        id: 'demo_1',
        moduleId: moduleId,
        title: 'Введение в модуль',
        description: 'Изучи основы безопасности',
        difficulty: 1,
        tasks: [],
        timeEstimate: 5,
        points: 50,
        iconName: 'quiz',
      ),
    ];
  }

  List<Task> _getDetectiveQuestTasks() {
    return [
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
            },
            {
              'id': 'm3',
              'speaker': 'Детектив',
              'message':
                  'Отлично! Сегодня мы узнаем, как быть умным и безопасным онлайн. Вот тебе первая подсказка:',
              'isUser': false,
            },
            {
              'id': 'm4',
              'speaker': 'Детектив',
              'message':
                  'Представь, что ты играешь в свою любимую игру, и вдруг тебе приходит сообщение от «королевы», которая обещает миллион монет, если ты нажмешь на ссылку. Что ты будешь делать?',
              'isUser': false,
            },
          ],
          'choices': [
            {
              'id': 'c1',
              'text': 'Расскажу родителям о сообщении',
              'isCorrect': true,
              'feedback':
                  'Отлично! Рассказать взрослому - это всегда правильное решение.',
              'consequence': 'Родители похвалили тебя за бдительность!',
            },
            {
              'id': 'c2',
              'text': 'Проигнорирую сообщение',
              'isCorrect': true,
              'feedback':
                  'Хороший выбор! Игнорировать подозрительные сообщения - безопасно.',
              'consequence': 'Ты не попался на уловку мошенников!',
            },
            {
              'id': 'c3',
              'text': 'Нажму на ссылку, чтобы узнать больше',
              'isCorrect': false,
              'feedback':
                  'Осторожно! Нажатие на подозрительные ссылки может быть опасным.',
              'consequence':
                  'К счастью, антивирус заблокировал опасный сайт!',
            },
          ],
        },
        hints: [
          'Подумай, что самое безопасное?',
          'Всегда спрашивай у родителей, если что-то кажется подозрительным!',
        ],
      ),
    ];
  }

  List<Task> _getEducationTasks() {
    return [
      Task(
        id: 'edu_q1',
        lessonId: 'education_1',
        type: TaskType.singleChoice,
        orderIndex: 0,
        title: 'Незнакомец в сети',
        instructions: 'Что ты будешь делать?',
        payload: {
          'question':
              'Онлайн-незнакомец просит ваш домашний адрес. Что вы будете делать?',
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
              'text': 'Дать им адрес',
              'isCorrect': false,
              'feedback': 'Нет! Никогда не делись личной информацией с незнакомцами.',
            },
            {
              'id': 'o3',
              'text': 'Заблокировать незнакомца',
              'isCorrect': true,
              'feedback': 'Отлично! Блокировка - хороший способ защиты.',
            },
            {
              'id': 'o4',
              'text': 'Спросить у друга',
              'isCorrect': false,
              'feedback': 'Лучше спросить у взрослых, а не у друзей.',
            },
          ],
        },
        hints: ['Подумай о безопасности', 'Личная информация должна оставаться личной'],
      ),
    ];
  }
}

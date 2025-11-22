import 'task.dart';

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
    this.description,
    required this.difficulty,
    required this.tasks,
    required this.timeEstimate,
    required this.points,
    this.imageUrl,
    this.iconName,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      difficulty: json['difficulty'] as int? ?? 1,
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((t) => Task.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      timeEstimate: json['timeEstimate'] as int? ?? 10,
      points: json['points'] as int? ?? 100,
      imageUrl: json['imageUrl'] as String?,
      iconName: json['iconName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'moduleId': moduleId,
      'title': title,
      'description': description,
      'difficulty': difficulty,
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'timeEstimate': timeEstimate,
      'points': points,
      'imageUrl': imageUrl,
      'iconName': iconName,
    };
  }
}

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

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String,
      color: json['color'] as String,
      badgeCount: json['badgeCount'] as int? ?? 0,
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((l) => Lesson.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'color': color,
      'badgeCount': badgeCount,
      'lessons': lessons.map((l) => l.toJson()).toList(),
    };
  }
}

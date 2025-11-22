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
    this.title,
    this.instructions,
    required this.payload,
    this.hints = const [],
    this.explanation,
    this.metadata,
    this.isRequired = false,
    this.maxAttempts = 1,
    this.timeLimit,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      type: TaskType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TaskType.singleChoice,
      ),
      orderIndex: json['orderIndex'] as int? ?? 0,
      title: json['title'] as String?,
      instructions: json['instructions'] as String?,
      payload: json['payload'] as Map<String, dynamic>,
      hints: (json['hints'] as List<dynamic>?)?.cast<String>() ?? [],
      explanation: json['explanation'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isRequired: json['isRequired'] as bool? ?? false,
      maxAttempts: json['maxAttempts'] as int? ?? 1,
      timeLimit: json['timeLimit'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'type': type.name,
      'orderIndex': orderIndex,
      'title': title,
      'instructions': instructions,
      'payload': payload,
      'hints': hints,
      'explanation': explanation,
      'metadata': metadata,
      'isRequired': isRequired,
      'maxAttempts': maxAttempts,
      'timeLimit': timeLimit,
    };
  }
}

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
    this.score = 0,
    this.hintsUsed = const [],
  });

  Duration get timeSpent => completedAt.difference(startedAt);

  factory TaskResult.fromJson(Map<String, dynamic> json) {
    return TaskResult(
      taskId: json['taskId'] as String,
      isCorrect: json['isCorrect'] as bool,
      attemptNumber: json['attemptNumber'] as int,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: DateTime.parse(json['completedAt'] as String),
      userAnswer: json['userAnswer'] as String?,
      details: json['details'] as Map<String, dynamic>?,
      score: json['score'] as int? ?? 0,
      hintsUsed: (json['hintsUsed'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskId': taskId,
      'isCorrect': isCorrect,
      'attemptNumber': attemptNumber,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt.toIso8601String(),
      'userAnswer': userAnswer,
      'details': details,
      'score': score,
      'hintsUsed': hintsUsed,
    };
  }
}

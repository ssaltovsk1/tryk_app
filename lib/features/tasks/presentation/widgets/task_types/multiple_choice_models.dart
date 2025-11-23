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

import 'question.dart';

class Lesson {
  final String id;
  final String title;
  final String description;
  final int rewardXp;
  final List<Question> questions;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardXp,
    required this.questions,
  });
}

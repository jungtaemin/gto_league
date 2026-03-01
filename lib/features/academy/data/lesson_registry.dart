import '../models/lesson.dart';
import 'phase1_data.dart';
import 'phase2_data.dart';

Lesson? lessonForLevel(int level) {
  switch (level) {
    case 1:
      return phase1Data;
    case 2:
      return phase2Data;
    default:
      return null;
  }
}

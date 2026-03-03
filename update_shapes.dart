import 'dart:io';

void main() {
  final files = [
    'lib/features/academy/widgets/concept_question_widget.dart',
    'lib/features/academy/widgets/multiple_choice_question_widget.dart',
    'lib/features/academy/widgets/playing_card_animation_area.dart',
    'lib/features/academy/widgets/battle_question_widget.dart',
  ];

  for (var path in files) {
    if (!File(path).existsSync()) continue;
    var content = File(path).readAsStringSync();
    content = content.replaceAll(
      'PlayingCardView(card:',
      'PlayingCardView(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), card:',
    );
    File(path).writeAsStringSync(content);
    print('Updated $path');
  }
}

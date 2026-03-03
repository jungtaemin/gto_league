import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

Widget buildCard() {
  return PlayingCardView(
    card: PlayingCard(Suit.spades, CardValue.ace),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
  );
}

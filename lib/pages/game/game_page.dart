import 'package:flutter/material.dart';
import 'package:reactive_alias/resources/content.dart';

import 'components/deck.dart';
import 'components/footer_buttons.dart';

class GamePage extends StatefulWidget {
  final deckController = DeckController();

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int currentCard = 1;

  void onSwipe(int previousIndex, int index, DeckSwipeResult result) {
    if (result != DeckSwipeResult.forward) {
      setState(() => currentCard = index + 1);
    }
  }

  List<TextSpan> handleDescription(final String description) {
    var result = [TextSpan(text: description)];
    final match = RegExp(r'\*.*?\*').firstMatch(description);
    if (match != null) {
      final before = description.substring(0, match.start);
      final highlight = description.substring(match.start + 1, match.end - 1);
      final after = description.substring(match.end);
      result = [
        if (before.isNotEmpty) TextSpan(text: before),
        if (highlight.isNotEmpty)
          TextSpan(
            text: highlight,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        if (after.isNotEmpty) TextSpan(text: after),
      ];
    }
    return result;
  }

  Widget cardBuilder(BuildContext context, int index) {
    return Center(
      child: Text(
        data[index],
        style: TextStyle(fontSize: 30, color: Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: Column(
        children: [
          SizedBox(height: 50.0),
          Expanded(
            child: Deck(
              onSwipe: onSwipe,
              cardsCount: data.length,
              visibleCardsCount: 3,
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              cardBuilder: cardBuilder,
              controller: widget.deckController,
              fakeVelocity: 3000.0,
            ),
          ),
          SizedBox(height: 50.0),
          FooterButtons(deckController: widget.deckController),
        ],
      ),
    );
  }
}

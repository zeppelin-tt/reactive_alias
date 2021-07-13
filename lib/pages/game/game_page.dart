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
              cardScaleFactor: .89,
              swipeTransitionThreshold: 1.45,
              edgeWidthFactor: 1.0,
              visibleCardsCount: 3,
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              cardBuilder: (BuildContext context, int index) => Center(
                child: Text(
                  data[index],
                  style: TextStyle(fontSize: 30, color: Colors.black),
                ),
              ),
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

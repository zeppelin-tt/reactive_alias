import 'package:flutter/material.dart';

import 'deck.dart';
import 'game_action_button.dart';

class FooterButtons extends StatelessWidget {
  const FooterButtons({
    @required this.deckController,
  });

  final DeckController deckController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: <Widget>[
          Button(
            leftIconData: Icons.arrow_back,
            text: 'Wrong',
            color: Colors.red,
            textColor: Colors.white,
            onPressed: deckController.backward,
          ),
          SizedBox(width: 16.0),
          Button(
            rightIconData: Icons.arrow_forward,
            color: Colors.blue,
            textColor: Colors.white,
            text: 'Right',
            onPressed: deckController.forward,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:reactive_alias/resources/custom_icons.dart';

class CardContent extends StatelessWidget {
  const CardContent({
    this.word,
    this.transcription,
    this.description,
    this.pronunciation,
  });

  final String word;
  final String transcription;
  final List<TextSpan> description;
  final String pronunciation;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(word, style: Theme.of(context).textTheme.headline),
            SizedBox(height: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(width: 8.0),
                Text(
                  '[$transcription]',
                  style: Theme.of(context).textTheme.body2,
                ),
                SizedBox(width: 4.0),
                IconButton(
                  icon: Icon(
                    CustomIcons.listen,
                    size: 32.0,
                    color: Colors.black45,
                  ),
                  // size: 48.0,
                  color: Colors.black12,
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(height: 4.0),
            RichText(
              text: TextSpan(
                children: description,
                style: Theme.of(context).textTheme.body1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

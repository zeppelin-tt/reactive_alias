import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({
    this.leftIconData,
    this.rightIconData,
    this.color,
    this.textColor,
    @required this.text,
    @required this.onPressed,
  });

  final IconData leftIconData;
  final IconData rightIconData;
  final Color color;
  final Color textColor;
  final String text;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RaisedButton(
        color: color,
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (leftIconData != null) ...[
              Icon(leftIconData, color: textColor),
              SizedBox(width: 8.0),
            ],
            Text(text, style: TextStyle(fontSize: 16.0, color: textColor)),
            if (rightIconData != null) ...[
              SizedBox(width: 8.0),
              Icon(rightIconData, color: textColor),
            ],
          ],
        ),
      ),
    );
  }
}

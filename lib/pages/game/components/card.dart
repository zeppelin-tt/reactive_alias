import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;

class Card extends StatelessWidget {
  Card({
    Key key,
    @required this.order,
    @required this.visibleCardsCount,
    @required double scaleFactor,
    @required double offset,
    @required this.transition,
    @required this.child,
  })  : assert(order >= 0),
        assert(visibleCardsCount >= 0),
        _matrix = Matrix4.identity()
          ..translate(0.0, -offset * (order - transition))
          ..scale(math.pow(scaleFactor, order - transition)),
        _opacity = visibleCardsCount == order ? math.min(transition, 1.0) : 1.0,
        super(key: key);

  final int order;
  final int visibleCardsCount;
  final double transition;
  final Widget child;

  final Matrix4 _matrix;
  final double _opacity;

  @override
  Widget build(BuildContext context) {
    final color = Color.lerp(
      CardTheme.of(context).color ?? Theme.of(context).cardColor,
      Color.alphaBlend(
        Colors.black.withOpacity(0.35),
        CardTheme.of(context).color ?? Theme.of(context).cardColor,
      ),
      (order - transition) / (visibleCardsCount + 1),
    );
    return Visibility(
      visible: child != null,
      child: Transform(
        alignment: Alignment.topCenter,
        transform: _matrix,
        child: Opacity(
          opacity: _opacity,
          child: material.Card(
            color: color,
            child: child,
          ),
        ),
      ),
    );
  }
}

class DraggableCard extends StatelessWidget {
  const DraggableCard({
    Key key,
    @required this.deckWidth,
    @required double maxAngle,
    @required this.alignment,
    @required this.transition,
    @required this.child,
  })  : _angle = maxAngle * transition,
        super(key: key);

  final double deckWidth;
  final double transition;
  final Alignment alignment;
  final Widget child;

  final double _angle;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: child != null,
      child: Transform(
        alignment: alignment,
        transform: Matrix4.identity()
          ..translate(transition * deckWidth, .0)
          ..rotateZ(alignment == Alignment.topCenter ? _angle : -_angle),
        child: material.Card(
          child: child,
        ),
      ),
    );
  }
}

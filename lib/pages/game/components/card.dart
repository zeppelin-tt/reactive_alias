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

class DraggableCard extends StatefulWidget {
  const DraggableCard({
    Key key,
    @required this.deckWidth,
    @required double maxAngle,
    @required this.alignment,
    @required this.transition,
    @required this.child,
  })  : _angle = maxAngle * transition,
        _maxTransition = maxAngle + 1.0,
        super(key: key);

  final double deckWidth;
  final double transition;
  final Alignment alignment;
  final Widget child;

  final double _angle;
  final double _maxTransition;

  @override
  _DraggableCardState createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard> {
  ColorTween wrongTween;
  ColorTween rightTween;

  @override
  void initState() {
    wrongTween = ColorTween(begin: Colors.white, end: Colors.blue);
    rightTween = ColorTween(begin: Colors.white, end: Colors.red);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final transitionRatio = (widget.transition / widget._maxTransition).abs();
    final _color = (widget.transition.isNegative ? rightTween : wrongTween).lerp(transitionRatio);

    return Visibility(
      visible: widget.child != null,
      child: Transform(
        alignment: widget.alignment,
        transform: Matrix4.identity()
          ..translate(widget.transition * widget.deckWidth, .0)
          ..rotateZ(widget.alignment == Alignment.topCenter ? widget._angle : -widget._angle),
        child: material.Card(
          color: _color,
          child: widget.child,
        ),
      ),
    );
  }
}

library deck;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Card;

import 'card.dart';

/// Enumeration of possible swipe results. If deck is returnable then `reverse`
/// means return of a card. Otherwise, `forward` and `reverse` mean
/// the direction in which card has been swiped. In both cases `dismiss` is
/// when no cards change.
enum DeckSwipeResult {
  reverse,
  forward,
  backward,
}

/// Enumeration that is used to define what direction `left` or `right`
/// is to be known as forward.
enum DeckForwardDirection {
  forward,
  backward,
  both,
}

/// Signature for a function that is called when card is swiped. It provides:
/// * `previousIndex` of swiped card,
/// * `index` of currently shown card,
/// * `result` that holds the direction of swipe or whether the swipe was
/// dismissed.
typedef DeckSwipeCallback = void Function(
  int previousIndex,
  int index,
  DeckSwipeResult result,
);

/// A controller for a deck of cards.
class DeckController {
  @protected
  void Function(DeckSwipeResult) _callback;

  /// Simulates a forward swipe on the deck.
  void forward() => _callback?.call(DeckSwipeResult.forward);

  /// Simulates a reverse swipe on the deck.
  void backward() => _callback?.call(DeckSwipeResult.backward);
}

class Deck extends StatefulWidget {
  /// Creates a deck of cards.
  ///
  /// The `cardBuilder` property must be not null.
  const Deck({
    Key key,
    this.cardsCount = 1,
    this.visibleCardsCount = 3,
    this.padding = EdgeInsets.zero,
    @required this.cardBuilder,
    this.looped = true,
    this.forwardDirection = DeckForwardDirection.both,
    this.cardMaxAngle = 0.2,
    this.cardOffset = 8.0,
    this.cardScaleFactor = 0.89,
    this.swipeVelocityThreshold = 1600.0,
    this.swipeTransitionThreshold = 0.35,
    this.edgeWidthFactor = 0.23,
    this.controller,
    this.onLoop,
    this.onSwipe,
    this.fakeVelocity,
  })  : assert(visibleCardsCount != null && visibleCardsCount >= 1),
        assert(looped ? cardsCount != null : true),
        assert(cardsCount != null ? cardsCount >= 1 : true),
        assert(cardBuilder != null),
        _offstageCardBoxWidth = 1.0 + cardMaxAngle + 0.01,
        super(key: key);

  /// Count of cards in the deck. If null then deck is infinite.
  final int cardsCount;

  /// Count of cards that are visible until the deck is getting over.
  final int visibleCardsCount;

  /// The amount of space by which to inset the cards.
  final EdgeInsets padding;

  /// A function that is called before every card is shown. Return value is a
  /// child widget of the card. If function returns null then the card is
  /// invisible.
  final IndexedWidgetBuilder cardBuilder;

  /// A flag that determines whether to start the deck over when cards ran out.
  /// If `looped` is true then `cardsCount` must be positive integer.
  final bool looped;

  /// The direction of forward side.
  final DeckForwardDirection forwardDirection;

  /// The maximum absolute value of angle in radians on which the card can be
  /// tilted.
  final double cardMaxAngle;

  /// The amount of space on which the card is shifted relative to the previous
  /// one.
  final double cardOffset;

  /// The scale of the previous card relative to the next one.
  final double cardScaleFactor;

  /// The minimum velocity of swipe to trigger the positive result, in logical
  /// pixels per second. If this or `swipeTransitionThreshold` is satisfied then
  /// the result is positive.
  final double swipeVelocityThreshold;

  /// The minimum part of deck the swipe must pass to trigger the positive
  /// result. If this or `swipeVelocityThreshold` is satisfied then
  /// the result is positive.
  final double swipeTransitionThreshold;

  /// The part of the deck width on which swipe triggers returning of card.
  /// Has meaning only if `returnable` is true.
  final double edgeWidthFactor;

  /// A controller that allows to swipe cards by calling the functions.
  final DeckController controller;

  /// A function that is called when `cardsCount - 1`th card has been swiped.
  final VoidCallback onLoop;

  /// A function that is called when the card has been dragged or `controller`
  /// has been used.
  final DeckSwipeCallback onSwipe;

  final double fakeVelocity;

  final double _offstageCardBoxWidth;

  @override
  _DeckState createState() => _DeckState();
}

class _DeckState extends State<Deck> with SingleTickerProviderStateMixin {
  List<Widget> widgets;
  var previousIndex = -1;
  var index = -1;

  var isDragging = false;
  var isReturning = false;
  var transition = 0.0;

  var isGrabbedAtTop = true;

  Tween<double> cardTween = Tween();
  Tween<double> draggableCardTween = Tween();
  Animation<double> cardAnimation;
  Animation<double> draggableCardAnimation;
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    changeCard();
    widget.controller?._callback = control;

    animationController = AnimationController(vsync: this)..addListener(() => setState(() {}));

    cardAnimation = cardTween.animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInBack,
      ),
    );

    draggableCardAnimation = draggableCardTween.animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutExpo,
        reverseCurve: Curves.easeInCubic,
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Widget cardBuilder(int offset) {
    offset += index;
    return !widget.looped && widget.cardsCount != null && offset >= widget.cardsCount
        ? null
        : widget.cardBuilder(context, offset % (widget.cardsCount ?? 1));
  }

  bool changeCard({bool reverse = false}) {
    index += reverse ? -1 : 1;
    final overflow = index == widget.cardsCount;
    final underflow = index == -1;
    final loop = overflow;

    if (overflow || underflow) {
      if (widget.looped) {
        index %= widget.cardsCount;
      } else if (underflow) {
        index = 0;
      } else {
        return loop;
      }
    }

    if (widgets == null) {
      widgets = List.generate(
        widget.visibleCardsCount + 1,
        cardBuilder,
        growable: false,
      );
    } else {
      if (reverse) {
        widgets.setRange(1, widgets.length, widgets);
        widgets[0] = cardBuilder(0);
      } else {
        widgets.setRange(0, widgets.length - 1, widgets, 1);
        widgets[widgets.length - 1] = cardBuilder(widget.visibleCardsCount);
      }
    }

    return loop;
  }

  void onReturn() {
    isReturning = true;
    previousIndex = index;
    changeCard(reverse: true);
  }

  void onDragStart(DragStartDetails details) {
    var isLeftEdge = false, isRightEdge = false;

    final isEdge = isRightEdge || isLeftEdge;
    final isTop = details.localPosition.dy < context.size.height * 0.6;
    setState(() {
      isDragging = true;
      isGrabbedAtTop = isTop;
      if (isEdge) onReturn();
    });

    if (isEdge) animateGrab(isLeftEdge, details.localPosition.dx);
  }

  void onDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta == 0.0) return;

    final delta = details.primaryDelta / context.size.width;
    var newTransition = transition + delta;

    if (isReturning && animationController.isAnimating) {
      draggableCardTween.end += delta;
      cardTween.end = draggableCardTween.end.abs().clamp(0.0, 1.0);
    }

    setState(() => transition = newTransition);
  }

  DeckSwipeResult dragResult({bool farEnough, bool fastEnough, bool forwardDirection}) {
    if (!farEnough && !fastEnough) {
      return DeckSwipeResult.reverse;
    }
    if (forwardDirection) {
      return DeckSwipeResult.forward;
    }
    return DeckSwipeResult.backward;
  }

  void onDragEnd(DragEndDetails details) async {
    if (isReturning && animationController.isAnimating) {
      animationController.stop(canceled: false);
    }

    final result = dragResult(
      farEnough: transition.abs() >= widget.swipeTransitionThreshold,
      fastEnough: details.primaryVelocity.abs() >= widget.swipeVelocityThreshold,
      forwardDirection: !details.primaryVelocity.isNegative,
    );

    swipe(result, details.primaryVelocity);
    setState(() => isDragging = false);
  }

  void control(DeckSwipeResult result) async {
    animationController.stop(canceled: false);
    if (isDragging) return;

    final fakeVelocity = result == DeckSwipeResult.forward ? widget.fakeVelocity : -widget.fakeVelocity;
    swipe(result, fakeVelocity);
  }

  void neutralResult(DeckSwipeResult result, {bool changeCards = false}) {
    setState(() {
      if (changeCards) changeCard();
      transition = 0.0;
    });
    widget.onSwipe?.call(index, index, result);
  }

  void positiveResult(DeckSwipeResult result, {bool changeCards = true}) {
    var loop = false;
    setState(() {
      if (changeCards) {
        previousIndex = index;
        loop = changeCard();
      }
      transition = 0.0;
    });
    widget.onSwipe?.call(
      previousIndex,
      index == widget.cardsCount ? null : index,
      result,
    );
    if (loop) widget.onLoop?.call();
  }

  void swipe(DeckSwipeResult result, double velocity) {
    if (result == DeckSwipeResult.reverse) {
      animateReturn((_) => neutralResult(result));
    } else {
      animateLeave(velocity, (_) => positiveResult(result));
    }
  }

  void animateGrab(bool isLeftEdge, double x) async {
    animationController.stop(canceled: false);
    animationController.reset();
    animationController.duration = Duration(milliseconds: 250);
    if (!isLeftEdge) {
      draggableCardTween
        ..begin = widget._offstageCardBoxWidth
        ..end = x / context.size.width;
    } else {
      draggableCardTween
        ..begin = -widget._offstageCardBoxWidth
        ..end = -1.0 + x / (context.size.width - widget.padding.left);
    }
    cardTween
      ..begin = 1.0
      ..end = draggableCardTween.end.abs();
    animationController.forward().then((_) {
      setState(() => transition = draggableCardTween.end);
    });
  }

  void animateReturn(Function(void) callback) async {
    animationController.stop(canceled: false);
    animationController.reset();
    animationController.duration = Duration(milliseconds: 250);
    cardTween
      ..begin = transition
      ..end = 0.0;
    draggableCardTween
      ..begin = transition
      ..end = 0.0;
    animationController.forward().then(callback);
  }

  void animateLeave(
    double velocity,
    Function(void) callback, {
    bool reverse = false,
  }) async {
    animationController.stop(canceled: false);
    animationController.value = -1.0;
    final sign = widget.forwardDirection == DeckForwardDirection.both
        ? velocity.isNegative
            ? -1.0
            : 1.0
        : widget.forwardDirection == DeckForwardDirection.forward
            ? 1.0
            : -1.0;
    animationController.duration = Duration(
      milliseconds: 300 - 200 * velocity ~/ 10000,
    );
    if (reverse) {
      cardTween
        ..begin = 0.0
        ..end = transition.abs();
      draggableCardTween
        ..begin = 0.0
        ..end = sign * transition.abs();
      animationController.reverse().then(callback);
    } else {
      cardTween
        ..begin = transition
        ..end = sign;
      draggableCardTween
        ..begin = transition
        ..end = sign * widget._offstageCardBoxWidth;
      animationController.forward().then(callback);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: widget.cardOffset * widget.visibleCardsCount - 1,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: onDragStart,
        onHorizontalDragUpdate: onDragUpdate,
        onHorizontalDragEnd: onDragEnd,
        child: Padding(
          padding: widget.padding,
          child: Stack(
            children: <Widget>[
              for (var order = widget.visibleCardsCount; order >= 1; order--)
                Card(
                  order: order,
                  visibleCardsCount: widget.visibleCardsCount,
                  offset: widget.cardOffset,
                  scaleFactor: widget.cardScaleFactor,
                  transition: animationController.isAnimating ? cardAnimation.value.abs() : transition.abs(),
                  child: widgets[order],
                ),
              LayoutBuilder(
                builder: (_, BoxConstraints constraints) => DraggableCard(
                  deckWidth: widget.padding.horizontal + constraints.maxWidth,
                  maxAngle: widget.cardMaxAngle,
                  alignment: isGrabbedAtTop ? Alignment.topCenter : Alignment.bottomCenter,
                  transition: animationController.isAnimating ? draggableCardAnimation.value : transition,
                  child: widgets[0],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

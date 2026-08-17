import 'package:flutter/material.dart';

enum SwipeAction { pass, like, superLike }

/// Drives the deck from outside the gesture layer — the card's buttons use
/// this so a tap and a drag end up in exactly the same animation. Super Like
/// lives only here: vertical gestures on the card always mean scrolling.
class SwipeDeckController {
  _SwipeDeckState? _state;

  void swipe(SwipeAction action) => _state?._flyOut(action);

  bool get isBusy => _state?._flying ?? false;
}

/// A two-card stack: the top card follows the finger, the one behind sits
/// scaled down so the next profile is already on screen.
///
/// Gesture model — one rule, enforced by Flutter's gesture arena rather than
/// by hand: the deck registers only a *horizontal* drag recognizer, and the
/// card's own scroll view owns the vertical axis. The first few pixels of
/// movement decide which one wins, and the winner keeps the pointer for the
/// whole gesture. A sideways drag can never scroll; an up/down drag can never
/// move the card. Scrolling keeps native physics and fling momentum.
///
/// The list is owned by the caller. [onSwipe] fires once, after the card has
/// finished flying off, and the caller is expected to drop that item — the
/// deck resets its own transform in the same frame, so the card underneath
/// arrives at rest instead of inheriting the outgoing card's position.
class SwipeDeck extends StatefulWidget {
  const SwipeDeck({
    super.key,
    required this.itemCount,
    required this.cardBuilder,
    required this.onSwipe,
    required this.controller,
    this.onDrag,
  });

  final int itemCount;

  /// [depth] 0 is the card being swiped, 1 the one behind it.
  final Widget Function(BuildContext context, int index, int depth) cardBuilder;

  final void Function(int index, SwipeAction action) onSwipe;
  final SwipeDeckController controller;

  /// Live drag offset, for the like/pass overlays. Never triggers a deck
  /// rebuild of its own — the listener decides what to repaint.
  final ValueChanged<Offset>? onDrag;

  @override
  State<SwipeDeck> createState() => _SwipeDeckState();
}

class _SwipeDeckState extends State<SwipeDeck>
    with SingleTickerProviderStateMixin {
  /// How far across the screen a drag must travel to commit.
  static const double _swipeFraction = 0.28;

  /// The card leans as it goes, but only this far (~5.7°) — the tilt the old
  /// library maxed out at.
  static const double _maxTilt = 0.1;

  /// How far ahead of the finger the release is projected: a release is
  /// scored at `dx + vx * _projection`, so a slow drag is judged on distance
  /// and a flick on where it was clearly headed. One rule covers slow, fast,
  /// short, long, and changed-my-mind swipes — flicking back toward the
  /// centre from beyond the line correctly springs home.
  static const double _projection = 0.15;

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  Animation<Offset>? _flight;

  Offset _drag = Offset.zero;
  bool _flying = false;

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
    _anim.addListener(() {
      if (_flight != null) _setDrag(_flight!.value);
    });
  }

  @override
  void didUpdateWidget(SwipeDeck old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      if (old.controller._state == this) old.controller._state = null;
      widget.controller._state = this;
    }
  }

  @override
  void dispose() {
    if (widget.controller._state == this) widget.controller._state = null;
    _anim.dispose();
    super.dispose();
  }

  void _setDrag(Offset value) {
    setState(() => _drag = value);
    widget.onDrag?.call(value);
  }

  /// Judged against the deck's own width, not the window's — the two differ
  /// in split-screen and in tests.
  Size get _size => context.size ?? MediaQuery.sizeOf(context);
  double get _threshold => _size.width * _swipeFraction;

  // ------------------------------------------------------------------ drag
  void _onDragStart(DragStartDetails d) {
    if (_flying) return;
    // Touching a card that is still springing home catches it in place —
    // otherwise the animation and the finger both write the position and the
    // card stutters between them.
    if (_anim.isAnimating) {
      _anim.stop();
      _flight = null;
    }
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_flying) return;
    // The horizontal recognizer only ever reports x — the card tracks the
    // finger 1:1 on its axis and holds its line, no drift to correct later.
    _setDrag(Offset(_drag.dx + d.delta.dx, 0));
  }

  void _onDragEnd(DragEndDetails d) {
    if (_flying) return;

    final projected = _drag.dx + d.velocity.pixelsPerSecond.dx * _projection;

    if (projected.abs() > _threshold) {
      _flyOut(projected > 0 ? SwipeAction.like : SwipeAction.pass);
    } else {
      _springBack();
    }
  }

  void _springBack() {
    _flight = Tween(begin: _drag, end: Offset.zero).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
    );
    _anim.forward(from: 0);
  }

  void _flyOut(SwipeAction action) {
    if (_flying || widget.itemCount == 0) return;
    _flying = true;

    // Just past the edge, and accelerating — a flicked card speeds away, it
    // does not coast to a halt in mid-air.
    final size = _size;
    final target = switch (action) {
      SwipeAction.like => Offset(size.width * 1.1, _drag.dy),
      SwipeAction.pass => Offset(-size.width * 1.1, _drag.dy),
      SwipeAction.superLike => Offset(_drag.dx, -size.height * 1.1),
    };

    _flight = Tween(begin: _drag, end: target).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInCubic),
    );
    _anim.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      _flight = null;
      _drag = Offset.zero;
      _flying = false;
      widget.onDrag?.call(Offset.zero);
      // Hand the card over and land the next one at rest in the same frame.
      widget.onSwipe(0, action);
    });
  }

  // ----------------------------------------------------------------- build
  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0) return const SizedBox.shrink();

    final hasNext = widget.itemCount > 1;
    // Behind card creeps up to full size as the top one leaves.
    final progress = (_drag.dx.abs() / 180).clamp(0.0, 1.0);

    return Stack(
      children: [
        if (hasNext)
          Positioned.fill(
            child: IgnorePointer(
              child: Transform.scale(
                scale: 0.94 + (0.06 * progress),
                child: widget.cardBuilder(context, 1, 1),
              ),
            ),
          ),
        Positioned.fill(
          child: Transform.translate(
            offset: _drag,
            child: Transform.rotate(
              alignment: Alignment.bottomCenter,
              angle: (_drag.dx * 0.0006).clamp(-_maxTilt, _maxTilt),
              child: GestureDetector(
                // Horizontal only: vertical drags fall through to the card's
                // scroll view, which is what makes scroll vs swipe unambiguous.
                onHorizontalDragStart: _onDragStart,
                onHorizontalDragUpdate: _onDragUpdate,
                onHorizontalDragEnd: _onDragEnd,
                child: widget.cardBuilder(context, 0, 0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

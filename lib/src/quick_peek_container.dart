import 'dart:ui';

import 'package:flutter/material.dart';

class QuickPeekContainer extends StatefulWidget {
  /// Duration of peek dialog animation
  final Duration dialogDuration;

  /// Color of background
  final Color barrierColor;

  /// Animation curve of dialog
  final Curve animationCurve;

  /// Reverse animation curve of dialog.
  /// If null [animationCurve] will be used with flipped.
  final Curve? reverseAnimationCurve;

  final Widget child;

  /// This will blur child when dialog is open.
  final double backgroundBlur;

  /// Main container widget for QuickPeek
  /// Wrap Scaffold with this widget,
  ///
  const QuickPeekContainer({
    Key? key,
    required this.child,
    this.dialogDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.ease,
    this.barrierColor = Colors.black26,
    this.backgroundBlur = 2,
    this.reverseAnimationCurve,
  }) : super(key: key);

  static QuickPeekContainerState of(BuildContext context) {
    var result = context.findAncestorStateOfType<QuickPeekContainerState>();
    if (result != null) {
      return result;
    }
    throw "No State found of type QuickPeekContainerState";
  }

  @override
  QuickPeekContainerState createState() => QuickPeekContainerState();
}

class QuickPeekContainerState extends State<QuickPeekContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _dialogAnimation;
  late Widget _dialog;
  bool _isPeaking = false;
  double _currentBlur = 0.0;

  late Color barrierColor;
  late Duration animationDuration;
  late double backgroundBlur;
  late Curve animationCurve;
  late Curve reverseAnimationCurve;

  bool get isPeaking => _isPeaking;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    barrierColor = widget.barrierColor;
    backgroundBlur = widget.backgroundBlur;
    animationDuration = widget.dialogDuration;
    animationCurve = widget.animationCurve;
    reverseAnimationCurve =
        widget.reverseAnimationCurve ?? animationCurve.flipped;

    _controller =
        AnimationController(duration: widget.dialogDuration, vsync: this);

    _dialogAnimation = CurvedAnimation(
      curve: animationCurve,
      reverseCurve: reverseAnimationCurve,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closePopUpDialog() async {
    if (_isPeaking) {
      _isPeaking = false;
      _currentBlur = 0.0;
      if (mounted) {
        await _controller.reverse();
        setState(() {});
      }
    }
  }

  void showPopUpDialog({
    double? blur,
    required Widget dialog,
    Color? barrierColor,
  }) {
    if (!_isPeaking) {
      _isPeaking = true;

      _currentBlur = blur ?? backgroundBlur;

      _dialog = dialog;

      this.barrierColor = barrierColor ?? this.barrierColor;

      if (mounted) {
        setState(() {});
        _controller.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (event) => _closePopUpDialog(),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.topLeft,
        fit: StackFit.expand,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaY: _currentBlur,
              sigmaX: _currentBlur,
            ),
            child: widget.child,
          ),
          if (_isPeaking)
            Transform.scale(
              scale: 1,
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  color: barrierColor,
                ),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _dialogAnimation,
                    builder: (context, child) => Transform.scale(
                      scale: _dialogAnimation.value,
                      child: child,
                    ),
                    child: _dialog,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

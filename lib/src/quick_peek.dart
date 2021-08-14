import 'package:flutter/material.dart';

import 'quick_peek_container.dart';

class QuickPeek extends StatelessWidget {
  final Widget child;

  /// Widget to show as dialog
  final Widget dialog;

  /// Barrier color when dialog is open.
  /// If null [QuickPeekContainer.barrierColor] will be considered as default value.
  final Color? barrierColor;

  /// Blur value when dialog is open.
  /// If null [QuickPeekContainer.backgroundBlur] will be considered as default value.
  final double? blur;

  /// Callback when use long press on widget.
  /// This method will be called after dialog is opened.
  final void Function(LongPressStartDetails)? onLongPress;

  /// QuickPeek widget.
  /// Displays popup when user long press on this widget.
  const QuickPeek({
    Key? key,
    required this.dialog,
    required this.child,
    this.onLongPress,
    this.barrierColor,
    this.blur,
  }) : super(key: key);

  void _longPressStartCallback(
      BuildContext context, LongPressStartDetails details) {
    QuickPeekContainer.of(context).showPopUpDialog(
      dialog: dialog,
      barrierColor: barrierColor,
      blur: blur,
    );
    onLongPress?.call(details);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) => _longPressStartCallback(context, details),
      child: child,
    );
  }
}

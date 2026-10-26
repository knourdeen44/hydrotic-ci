import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Appui long d'une seconde (accès caché au mode démo depuis le logo).
class LongPress1s extends StatelessWidget {
  const LongPress1s({super.key, required this.onLongPress, required this.child});

  static const duree = Duration(seconds: 1);

  final VoidCallback? onLongPress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final action = onLongPress;
    if (action == null) return child;
    return RawGestureDetector(
      gestures: {
        LongPressGestureRecognizer: GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
          () => LongPressGestureRecognizer(duration: duree),
          (recognizer) => recognizer.onLongPress = action,
        ),
      },
      child: child,
    );
  }
}

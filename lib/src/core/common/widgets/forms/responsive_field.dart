import 'package:flutter/widgets.dart';

Widget responsiveField(Widget child, bool isWide) {
  return ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: isWide ? 400 : double.infinity,
    ),
    child: child,
  );
}

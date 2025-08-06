import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

void showSnackBar(
  BuildContext context,
  String content, {
  Color backgroundColor = AppPallete.greyColor,
  bool autoClose = false,
  Duration duration = const Duration(seconds: 3),
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final snackBar = SnackBar(
      content: Text(content),
      backgroundColor: backgroundColor,
      duration: autoClose ? duration : const Duration(days: 1),
      action: !autoClose
          ? SnackBarAction(
              label: 'Close',
              textColor: Colors.white,
              onPressed: () =>
                  ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            )
          : null,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  });
}

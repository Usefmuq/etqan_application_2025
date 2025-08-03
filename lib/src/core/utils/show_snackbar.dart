import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String content) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(content)),
      );
  });
}

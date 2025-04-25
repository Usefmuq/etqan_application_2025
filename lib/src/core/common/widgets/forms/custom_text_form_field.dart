import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int? maxLines;
  final bool? readOnly;
  const CustomTextFormField({
    super.key,
    required this.controller,
    this.hintText = '',
    this.maxLines = 1,
    this.readOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly!,
      decoration: InputDecoration(
        hintText: hintText,
      ),
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$hintText ${AppLocalizations.of(context)!.isEmpty}';
        }
        return null;
      },
    );
  }
}

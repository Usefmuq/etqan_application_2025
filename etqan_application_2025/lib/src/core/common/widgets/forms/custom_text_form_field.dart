import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int? maxLines;
  const CustomTextFormField({
    super.key,
    required this.controller,
    this.hintText = '',
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
      ),
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$hintText is missing!';
        }
        return null;
      },
    );
  }
}

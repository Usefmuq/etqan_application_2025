import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isObscureText;

  const AuthField(
      {super.key,
      required this.hintText,
      required this.controller,
      this.isObscureText = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(hintText: hintText),
      validator: (value) {
        if (value!.isEmpty) {
          return "$hintText ${AppLocalizations.of(context)!.isEmpty}";
        }
        return null;
      },
      obscureText: isObscureText,
    );
  }
}

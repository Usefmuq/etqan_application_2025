import 'package:flutter/material.dart';

class CustomSectionTitle extends StatelessWidget {
  final String title;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final TextAlign textAlign;
  final Widget? trailing;

  const CustomSectionTitle({
    super.key,
    required this.title,
    this.fontSize = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 12.0),
    this.textAlign = TextAlign.start,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              textAlign: textAlign,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

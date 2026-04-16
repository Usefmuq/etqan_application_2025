import 'package:flutter/material.dart';

class CustomSwitchField extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  /// The main text displayed next to the switch
  final String title;

  /// Optional helper text underneath the title (e.g., "Saturday and Sunday")
  final String? subtitle;

  final bool readOnly;
  final String? reviewerComment;
  final bool showCommentAbove;
  final bool isActive;

  const CustomSwitchField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
    this.readOnly = false,
    this.reviewerComment,
    this.showCommentAbove = false,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isActive) return const SizedBox.shrink();

    final hasComment =
        reviewerComment != null && reviewerComment!.trim().isNotEmpty;

    Widget commentChip() {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber.shade300),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, size: 18, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                reviewerComment!,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.35,
                  color: Colors.white, // Ensures text is visible on dark bg
                ),
              ),
            ),
          ],
        ),
      );
    }

    // InputDecorator gives us the exact same border/background as TextFormField
    final field = InputDecorator(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: hasComment
                ? Colors.amber.shade300
                : (readOnly ? Colors.grey.shade400 : Colors.grey.shade300),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade200 : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: readOnly ? Colors.grey.shade700 : Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: readOnly
                          ? Colors.grey.shade500
                          : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (readOnly)
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.lock_outline, size: 18, color: Colors.grey),
            ),
          Switch(
            value: value,
            // Passing null automatically disables the switch and grays it out
            onChanged: readOnly ? null : onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasComment && showCommentAbove) commentChip(),
        field,
        if (hasComment && !showCommentAbove) ...[
          const SizedBox(height: 8),
          commentChip(),
        ],
      ],
    );
  }
}

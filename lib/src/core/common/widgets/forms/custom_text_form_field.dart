import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int? maxLines;
  final bool readOnly;

  /// Optional reviewer note shown to the submitter.
  final String? reviewerComment;

  /// Where to show the reviewer note: true = above, false = below the field.
  final bool showCommentAbove;

  /// Make the field required (affects validator).
  final bool required;

  const CustomTextFormField({
    super.key,
    required this.controller,
    this.hintText = '',
    this.maxLines = 1,
    this.readOnly = true,
    this.reviewerComment,
    this.showCommentAbove = false,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasComment =
        reviewerComment != null && reviewerComment!.trim().isNotEmpty;

    Widget commentChip() {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.15),
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
                style: const TextStyle(fontSize: 13.5, height: 1.35),
              ),
            ),
          ],
        ),
      );
    }

    final field = TextFormField(
      controller: controller,
      readOnly: readOnly,
      style: TextStyle(
        color: readOnly ? Colors.grey.shade700 : Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: hintText.isNotEmpty ? hintText : null,
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
        suffixIcon: readOnly
            ? const Icon(Icons.lock_outline, size: 18, color: Colors.grey)
            : (hasComment ? const Icon(Icons.comment, size: 18) : null),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      maxLines: maxLines,
      validator: (value) {
        if (!required) return null;
        if (value == null || value.trim().isEmpty) {
          return '$hintText ${AppLocalizations.of(context)!.isEmpty}';
        }
        return null;
      },
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

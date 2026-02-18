import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomDoubleFormField extends StatelessWidget {
  final double? initialValue; // Now accepts double
  final ValueChanged<double?>? onChanged; // Now returns double
  final String hintText;
  final bool readOnly;

  /// Optional reviewer note shown to the submitter.
  final String? reviewerComment;

  /// Where to show the reviewer note: true = above, false = below the field.
  final bool showCommentAbove;

  /// Make the field required (affects validator).
  final bool required;
  final bool isActive;

  const CustomDoubleFormField({
    super.key,
    this.initialValue,
    this.onChanged,
    this.hintText = '',
    this.readOnly = true,
    this.reviewerComment,
    this.showCommentAbove = false,
    this.required = false,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isActive) return const SizedBox.shrink();

    final hasComment =
        reviewerComment != null && reviewerComment!.trim().isNotEmpty;

    Widget commentChip() {
      return Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Colors.orange),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              reviewerComment!,
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 12,
              ),
            ),
          ),
        ],
      );
    }

    final field = TextFormField(
      // 1. Convert double to String for the text field
      initialValue: initialValue?.toString(),

      // 2. Parse the String back to a double when the user types
      onChanged: (value) {
        if (onChanged != null) {
          if (value.trim().isEmpty) {
            onChanged!(null);
          } else {
            onChanged!(double.tryParse(value));
          }
        }
      },
      readOnly: readOnly,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
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
      maxLines: 1,
      validator: (value) {
        if (!required && (value == null || value.trim().isEmpty)) return null;

        if (required && (value == null || value.trim().isEmpty)) {
          return '$hintText ${AppLocalizations.of(context)!.isEmpty}';
        }

        if (value != null && value.isNotEmpty) {
          final parsed = double.tryParse(value);
          if (parsed == null) {
            return 'Invalid number format';
          }
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

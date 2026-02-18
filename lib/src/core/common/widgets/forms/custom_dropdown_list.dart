import 'package:flutter/material.dart';

class CustomDropdownList<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedItem;
  final void Function(T?)? onChanged; // Made nullable to support readOnly
  final String Function(T) getLabel;
  final String label;
  final String? hintText; // Replaced 'hint' to match your naming
  final FormFieldValidator<T>? validator;

  // New Fields
  final bool readOnly;
  final bool isActive;
  final String? reviewerComment;

  const CustomDropdownList({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.getLabel,
    required this.label,
    this.hintText,
    this.validator,
    this.readOnly = false,
    this.isActive = true,
    this.reviewerComment,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Handle isActive: If false, do not render the widget at all
    if (!isActive) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: selectedItem,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            // Add a visual cue when the field is read-only
            filled: readOnly,
            fillColor: readOnly ? Colors.grey.shade200 : null,
          ),
          hint: hintText != null ? Text(hintText!) : null,
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(getLabel(item)),
            );
          }).toList(),

          // 2. Handle readOnly: Passing null disables the dropdown
          onChanged: readOnly ? null : onChanged,
          validator: validator,

          // Ensures the selected text is still visible even when disabled
          disabledHint: selectedItem != null
              ? Text(getLabel(selectedItem as T),
                  style: TextStyle(color: Colors.black87))
              : null,
        ),

        // 3. Handle Reviewer Comment: Show below the dropdown if it exists
        if (reviewerComment != null && reviewerComment!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
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
          ),
        ],
      ],
    );
  }
}

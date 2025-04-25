import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomDropdownList<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedItem;
  final void Function(T?) onChanged;
  final String Function(T) getLabel;
  final String label;
  final String? hint;
  final FormFieldValidator<T>? validator;

  const CustomDropdownList({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.getLabel,
    required this.label,
    this.hint,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
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
          ),
          hint: Text(hint ?? AppLocalizations.of(context)!.dropDownSelect),
          isExpanded: true,
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(getLabel(item)),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}

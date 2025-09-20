import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomDatePicker extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final void Function(DateTime date) onChanged;
  final String? Function(DateTime?)? validator;
  final String? hint;

  const CustomDatePicker({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onChanged,
    this.validator,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = selectedDate != null
        ? DateFormat.yMMMd().format(selectedDate!)
        : (hint ?? AppLocalizations.of(context)!.selectDate);

    final errorText = validator?.call(selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        InputDecorator(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            errorText: errorText,
          ),
          child: InkWell(
            onTap: () async {
              final now = DateTime.now().toUtc().add(Duration(hours: 3));
              final initialDate = selectedDate ?? now;
              final picked = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(now.year + 5),
              );
              if (picked != null) onChanged(picked);
            },
            child: Text(
              formattedDate,
              style: TextStyle(
                fontSize: 16,
                color:
                    selectedDate != null ? Colors.black : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

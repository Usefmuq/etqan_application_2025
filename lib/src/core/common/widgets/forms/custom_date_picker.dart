import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomDatePicker extends StatefulWidget {
  final String label;
  final DateTime? selectedDate;
  final void Function(DateTime date)? onChanged;
  final String? Function(DateTime?)? validator;
  final String? hint;

  final bool isRequired;
  final bool isActive;
  final bool readOnly;
  final String? reviewerComment;
  final bool showCommentAbove;

  // NEW
  final bool showNoEndDateToggle;
  final bool noEndDate;
  final ValueChanged<bool>? onNoEndDateChanged;

  const CustomDatePicker({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onChanged,
    this.validator,
    this.hint,
    this.isRequired = false,
    this.isActive = true,
    this.readOnly = false,
    this.reviewerComment,
    this.showCommentAbove = false,
    this.showNoEndDateToggle = false,
    this.noEndDate = false,
    this.onNoEndDateChanged,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  bool _touched = false;
  String? _errorText;

  void _validate(DateTime? date) {
    final loc = AppLocalizations.of(context)!;

    // If "no end date", treat as valid
    if (widget.noEndDate) {
      _errorText = null;
      return;
    }

    final customError = widget.validator?.call(date);

    if (widget.isRequired && (date == null)) {
      _errorText = loc.startDateValid; // your required message
    } else {
      _errorText = customError;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    final showComment =
        widget.reviewerComment != null && widget.reviewerComment!.isNotEmpty;
    final labelText = widget.isRequired ? '${widget.label} *' : widget.label;

    final effectiveReadOnly =
        widget.readOnly || widget.noEndDate || !widget.isActive;

    // Only show error AFTER touch
    if (_touched) {
      _validate(widget.selectedDate);
    }

    final formattedDate = (!widget.noEndDate && widget.selectedDate != null)
        ? DateFormat.yMMMd().format(widget.selectedDate!)
        : (widget.hint ?? loc.selectDate);

    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      errorText: _touched ? _errorText : null,
      filled: !widget.isActive || widget.noEndDate,
      fillColor:
          (!widget.isActive || widget.noEndDate) ? Colors.grey.shade100 : null,
    );

    final dateTextStyle = TextStyle(
      fontSize: 16,
      color: (!widget.noEndDate && widget.selectedDate != null)
          ? Colors.black
          : (effectiveReadOnly ? Colors.grey.shade400 : Colors.grey.shade600),
    );

    final datePickerCore = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: theme.textTheme.labelLarge),
        const SizedBox(height: 6),
        InputDecorator(
          decoration: inputDecoration,
          child: InkWell(
            onTap: effectiveReadOnly
                ? null
                : () async {
                    setState(() => _touched = true);
                    final now =
                        DateTime.now().toUtc().add(const Duration(hours: 3));
                    final initialDate = widget.selectedDate ?? now;
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(now.year + 5),
                    );
                    if (picked != null && widget.onChanged != null) {
                      widget.onChanged!(picked);
                      setState(() => _validate(picked));
                    } else {
                      setState(() => _validate(widget.selectedDate));
                    }
                  },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(formattedDate,
                        style: dateTextStyle, overflow: TextOverflow.ellipsis)),
                if (!effectiveReadOnly)
                  const Icon(Icons.calendar_today,
                      size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (showComment && !widget.showCommentAbove) ...[
          const SizedBox(height: 4),
          Text(
            widget.reviewerComment!,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange),
          ),
        ],
      ],
    );

    final noEndToggle = Visibility(
      visible: widget.showNoEndDateToggle,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: InkWell(
          onTap: (widget.isActive && widget.onNoEndDateChanged != null)
              ? () {
                  final newVal = !widget.noEndDate;
                  widget.onNoEndDateChanged!(newVal);
                }
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: widget.noEndDate,
                onChanged: (val) {
                  if (!(widget.isActive)) return;
                  if (widget.onNoEndDateChanged != null) {
                    widget.onNoEndDateChanged!(val ?? false);
                  }
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Text(
                // localize this caption if you have a key
                AppLocalizations.of(context)?.noDate ?? 'No end date',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
    if (!widget.isActive) return Card();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showComment && widget.showCommentAbove) ...[
          Text(
            widget.reviewerComment!,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange),
          ),
          const SizedBox(height: 6),
        ],
        datePickerCore,
        noEndToggle,
      ],
    );
  }
}

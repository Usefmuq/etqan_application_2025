import 'package:etqan_application_2025/src/core/constants/uuid_lookup_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomKeyValueGrid extends StatelessWidget {
  final Map<String, dynamic> data;
  final double minColumnWidth;
  final double spacing;

  const CustomKeyValueGrid({
    super.key,
    required this.data,
    this.minColumnWidth = 200,
    this.spacing = 16,
  });

  Map<String, dynamic> _getLookupMeta(dynamic value, String locale) {
    if (value is String &&
        RegExp(r'^[0-9a-fA-F\-]{36}$').hasMatch(value) &&
        UuidLookupConstants.combinedLookup.containsKey(value)) {
      final lookup = UuidLookupConstants.combinedLookup[value]!;
      return {
        'label': lookup[locale] ?? '—',
        'color': lookup['color'],
        'isChip': true,
      };
    }

    if (value is DateTime) {
      return {
        'label': DateFormat.yMMMd(locale).add_jm().format(value),
      };
    }

    if (value is bool) {
      return {
        'label':
            locale == 'ar' ? (value ? 'نعم' : 'لا') : (value ? 'Yes' : 'No')
      };
    }

    return {
      'label': value?.toString() ?? '—',
    };
  }

  @override
  Widget build(BuildContext context) {
    final localeCode = Localizations.localeOf(context).languageCode;
    final screenWidth = MediaQuery.of(context).size.width;
    final availableWidth = screenWidth - (spacing * 2);
    final calculatedColumns =
        (availableWidth / minColumnWidth).floor().clamp(1, 4);
    final columnWidth = (availableWidth -
            (spacing * (calculatedColumns > 1 ? calculatedColumns - 1 : 0))) /
        calculatedColumns;

    final items = data.entries.toList();

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: items.map((entry) {
        final meta = _getLookupMeta(entry.value, localeCode);
        final label = meta['label'] ?? '—';
        final color = meta['color'] as Color?;
        final isChip = meta['isChip'] == true;

        Widget valueWidget = Text(label, style: const TextStyle(fontSize: 14));

        if (isChip && color != null) {
          valueWidget = Chip(
            label: Text(label),
            backgroundColor: color.withAlpha(30),
            labelStyle: TextStyle(
              fontWeight: FontWeight.w500,
            ),
            shape: const StadiumBorder(),
          );
        }

        return SizedBox(
          width: columnWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              valueWidget,
            ],
          ),
        );
      }).toList(),
    );
  }
}

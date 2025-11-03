import 'package:etqan_application_2025/src/core/constants/uuid_lookup_constants.dart';
import 'package:flutter/material.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:intl/intl.dart';

class CustomCardListRequests extends StatelessWidget {
  final List<String>? chips;
  final String title;
  final String? subtitle;
  final String? statusId;
  final DateTime? requestDate;
  final void Function()? onTap;

  const CustomCardListRequests({
    super.key,
    this.chips,
    required this.title,
    this.subtitle,
    this.statusId,
    this.requestDate,
    this.onTap,
  });

  Map<String, dynamic> _getLookupMeta(String? id, BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    if (id is String &&
        RegExp(r'^[0-9a-fA-F\-]{36}$').hasMatch(id) &&
        UuidLookupConstants.combinedLookup.containsKey(id)) {
      final lookup = UuidLookupConstants.combinedLookup[id]!;
      return {
        'label': lookup[locale] ?? '—',
        'color': lookup['color'] ?? AppPallete.greyColor,
        'isChip': true,
      };
    }
    return {'label': '—', 'color': AppPallete.greyColor, 'isChip': true};
  }

  @override
  Widget build(BuildContext context) {
    final statusMeta = _getLookupMeta(statusId, context);
    final dateFormatted = requestDate != null
        ? DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
            .format(requestDate!)
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                  if (statusId != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusMeta['color'].withOpacity(0.1),
                        border: Border.all(color: statusMeta['color']),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusMeta['label'],
                        style: TextStyle(
                          color: statusMeta['color'],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              if (subtitle != null || dateFormatted != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (subtitle != null)
                      Expanded(
                        child: Text(
                          subtitle!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppPallete.greyColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (dateFormatted != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          dateFormatted,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppPallete.greyColor,
                                  ),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              if (chips != null && chips!.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: -8,
                  children: chips!
                      .map(
                        (chip) => Chip(
                          label: Text(
                            chip,
                            style: const TextStyle(fontSize: 12),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: AppPallete.greyColor
                              .withAlpha((0.1 * 255).toInt()),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

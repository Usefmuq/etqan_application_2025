import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_key_value_grid.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_section_title.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/entities/vacation_viewer_page_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

Widget buildDetailsSection(
  BuildContext context,
  VacationViewerPageEntity? vacationViewerPage,
) {
  // If data hasn't loaded yet, render nothing (or a small placeholder if you want)
  if (vacationViewerPage == null) return const SizedBox.shrink();

  final l10n = AppLocalizations.of(context)!;
  final view = vacationViewerPage.vacationsView;

  String fmt(DateTime? dt) =>
      dt == null ? l10n.notYet : DateFormat.yMMMd().add_jm().format(dt);

  // topics may be null/empty

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomSectionTitle(title: l10n.vacationDetails),
      CustomKeyValueGrid(
        data: {
          l10n.vacationType: view.vacationTypeId ?? '—',
          l10n.vacationReason: view.reason ?? '—',
          l10n.vacationStartDate: view.startDate ?? '—',
          l10n.vacationEndDate: view.endDate ?? '—',
          l10n.vacationDaysCount: view.daysCount ?? '—',
          l10n.requestId: "${l10n.vacation}-${view.requestId ?? '—'}",
          l10n.status: view.requestStatusId, // assuming grid handles lookup
          l10n.createdBy: view.fullNameAr ?? '—',
          l10n.priority: view.priorityId, // assuming grid handles lookup
          l10n.requestDetails: view.requestDetails ?? '—',
          l10n.createdAt: fmt(view.requestCreatedAt),
          // If vacationUpdatedAt is a DateTime, format it; if it's already a string, show it.
          l10n.updatedAt: view.vacationUpdatedAt is DateTime
              ? fmt(view.vacationUpdatedAt as DateTime)
              : (view.vacationUpdatedAt?.toString() ?? '—'),
          l10n.approvedAt: fmt(view.requestApprovedAt),
        },
      ),
    ],
  );
}

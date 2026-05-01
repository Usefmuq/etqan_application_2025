import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_key_value_grid.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_section_title.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_regularization_viewer_page_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

Widget buildDetailsSection(
  BuildContext context,
  AttendanceRegularizationViewerPageEntity? attendanceregularizationViewerPage,
) {
  // If data hasn't loaded yet, render nothing (or a small placeholder if you want)
  if (attendanceregularizationViewerPage == null) {
    return const SizedBox.shrink();
  }

  final l10n = AppLocalizations.of(context)!;
  final view = attendanceregularizationViewerPage.attendancesView;
  final locale = Intl.getCurrentLocale();

  String fmt(DateTime? dt) =>
      dt == null ? l10n.notYet : DateFormat.yMMMd().add_jm().format(dt);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomSectionTitle(title: l10n.attendanceRegularizationDetails),
      CustomKeyValueGrid(
        data: {
          // Basic Request Info
          l10n.requestId: "${l10n.attendanceRegularization}-${view.requestId}",
          l10n.createdBy:
              (locale == 'ar' ? view.fullNameAr : view.fullNameEn) ?? '—',

          // Regularization Specific Details
          l10n.attendanceRegularizationStartDate: fmt(view.startDate),
          l10n.attendanceRegularizationEndDate: fmt(view.endDate),
          l10n.attendanceRegularizationIncludeWeekends: view.includeWeekends
              ? (locale == 'ar' ? 'نعم' : 'Yes')
              : (locale == 'ar' ? 'لا' : 'No'),
          l10n.attendanceRegularizationProposedCheckIn:
              view.proposedCheckIn ?? '—',
          l10n.attendanceRegularizationProposedCheckOut:
              view.proposedCheckOut ?? '—',
          l10n.attendanceRegularizationReason:
              view.reason.isNotEmpty ? view.reason : '—',
          l10n.status: view.requestStatusId, // Assuming grid handles lookup
          l10n.requestDetails: view.requestDetails ?? '—',

          // Timestamps
          l10n.createdAt: fmt(view.requestCreatedAt),
          l10n.updatedAt: view.updatedAt != null ? fmt(view.updatedAt!) : '—',
          l10n.approvedAt: fmt(view.requestApprovedAt),
        },
      ),
    ],
  );
}

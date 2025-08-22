import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_key_value_grid.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_section_title.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_viewer_page_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

Widget buildDetailsSection(
  BuildContext context,
  BlogViewerPageEntity? blogViewerPage,
) {
  // If data hasn't loaded yet, render nothing (or a small placeholder if you want)
  if (blogViewerPage == null) return const SizedBox.shrink();

  final l10n = AppLocalizations.of(context)!;
  final view = blogViewerPage.blogsView;

  String _fmt(DateTime? dt) =>
      dt == null ? l10n.notYet : DateFormat.yMMMd().add_jm().format(dt);

  // topics may be null/empty
  final topicsText = (view.topics == null || view.topics!.isEmpty)
      ? '—'
      : view.topics!.join(', ');

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomSectionTitle(title: l10n.blogDetails),
      CustomKeyValueGrid(
        data: {
          l10n.title: view.title ?? '—',
          l10n.requestId: "${l10n.blog}-${view.requestId ?? '—'}",
          l10n.status: view.requestStatusId, // assuming grid handles lookup
          l10n.topics: topicsText,
          l10n.createdBy: view.fullNameAr ?? '—',
          l10n.priority: view.priorityId, // assuming grid handles lookup
          l10n.requestDetails: view.requestDetails ?? '—',
          l10n.createdAt: _fmt(view.requestCreatedAt),
          // If blogUpdatedAt is a DateTime, format it; if it's already a string, show it.
          l10n.updatedAt: view.blogUpdatedAt is DateTime
              ? _fmt(view.blogUpdatedAt as DateTime)
              : (view.blogUpdatedAt?.toString() ?? '—'),
          l10n.approvedAt: _fmt(view.requestApprovedAt),
        },
      ),
    ],
  );
}

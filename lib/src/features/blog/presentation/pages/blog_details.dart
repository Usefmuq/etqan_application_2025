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
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomSectionTitle(title: AppLocalizations.of(context)!.blogDetails),
      CustomKeyValueGrid(
        data: {
          AppLocalizations.of(context)!.title: blogViewerPage!.blogsView.title,
          AppLocalizations.of(context)!.requestId:
              "${AppLocalizations.of(context)!.blog}-${blogViewerPage.blogsView.requestId}",
          AppLocalizations.of(context)!.status:
              blogViewerPage.blogsView.requestStatusId,
          AppLocalizations.of(context)!.topics:
              blogViewerPage.blogsView.topics!.join(', '),
          AppLocalizations.of(context)!.createdBy:
              blogViewerPage.blogsView.fullNameAr,
          AppLocalizations.of(context)!.priority:
              blogViewerPage.blogsView.priorityId,
          AppLocalizations.of(context)!.requestDetails:
              blogViewerPage.blogsView.requestDetails,
          AppLocalizations.of(context)!.createdAt: DateFormat.yMMMd()
              .add_jm()
              .format(blogViewerPage.blogsView.requestCreatedAt!),
          AppLocalizations.of(context)!.updatedAt:
              blogViewerPage.blogsView.blogUpdatedAt,
          AppLocalizations.of(context)!.approvedAt:
              blogViewerPage.blogsView.requestApprovedAt != null
                  ? DateFormat.yMMMd()
                      .add_jm()
                      .format(blogViewerPage.blogsView.requestApprovedAt!)
                  : AppLocalizations.of(context)!.notYet,
        },
      ),
    ],
  );
}

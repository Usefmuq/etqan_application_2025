import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_key_value_grid.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_section_title.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/entities/users_manager_viewer_page_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

Widget buildDetailsSection(
  BuildContext context,
  UsersManagerViewerPageEntity? usersManagerViewerPage,
) {
  // If data hasn't loaded yet, render nothing (or a small placeholder if you want)
  if (usersManagerViewerPage == null) return const SizedBox.shrink();

  final l10n = AppLocalizations.of(context)!;
  final view = usersManagerViewerPage.usersManagersView;

  String fmt(DateTime? dt) =>
      dt == null ? l10n.notYet : DateFormat.yMMMd().add_jm().format(dt);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CustomSectionTitle(title: l10n.usersManagerDetails),
      CustomKeyValueGrid(
        data: {l10n.title: ''},
      ),
    ],
  );
}

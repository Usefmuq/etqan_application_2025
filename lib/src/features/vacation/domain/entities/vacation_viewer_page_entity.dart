import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/features/vacation/data/models/vacation_page_view_model.dart';

class VacationViewerPageEntity {
  final VacationsPageViewModel vacationsView;

  final List<ApprovalSequenceViewModel>? approval;
  final List<RequestUnlockedFieldModel>? unlockedFields;

  VacationViewerPageEntity({
    required this.vacationsView,
    this.approval,
    this.unlockedFields,
  });
}

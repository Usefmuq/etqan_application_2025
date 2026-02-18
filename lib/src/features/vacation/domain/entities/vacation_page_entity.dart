import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/features/vacation/data/models/vacation_page_view_model.dart';

class VacationPageEntity {
  final List<VacationsPageViewModel> vacationsView;
  final List<ApprovalSequenceViewModel> approvalsView;

  VacationPageEntity({
    required this.vacationsView,
    required this.approvalsView,
  });
}

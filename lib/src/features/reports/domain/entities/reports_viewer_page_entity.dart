import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/features/reports/data/models/reports_page_view_model.dart';

class ReportsViewerPageEntity {
  final ReportssPageViewModel reportssView;

  final List<ApprovalSequenceViewModel>? approval;
  final List<RequestUnlockedFieldModel>? unlockedFields;

  ReportsViewerPageEntity({
    required this.reportssView,
    this.approval,
    this.unlockedFields,
  });
}

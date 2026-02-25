import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/features/reports/data/models/reports_page_view_model.dart';

class ReportsPageEntity {
  final List<ReportssPageViewModel> reportssView;
  final List<ApprovalSequenceViewModel> approvalsView;

  ReportsPageEntity({
    required this.reportssView,
    required this.approvalsView,
  });
}

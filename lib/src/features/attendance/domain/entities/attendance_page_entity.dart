import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_page_view_model.dart';

class AttendancePageEntity {
  final List<AttendancesPageViewModel> attendancesView;
  final List<ApprovalSequenceViewModel> approvalsView;

  AttendancePageEntity({
    required this.attendancesView,
    required this.approvalsView,
  });
}

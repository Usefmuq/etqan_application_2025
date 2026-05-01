import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_regularization_view_model.dart';

class AttendanceRegularizationPageEntity {
  final List<AttendanceRegularizationViewModel> attendancesView;
  final List<ApprovalSequenceViewModel> approvalsView;

  AttendanceRegularizationPageEntity({
    required this.attendancesView,
    required this.approvalsView,
  });
}

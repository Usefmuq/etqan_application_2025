import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_regularization_view_model.dart';

class AttendanceRegularizationViewerPageEntity {
  final AttendanceRegularizationViewModel attendancesView;

  final List<ApprovalSequenceViewModel>? approval;
  final List<RequestUnlockedFieldModel>? unlockedFields;

  AttendanceRegularizationViewerPageEntity({
    required this.attendancesView,
    this.approval,
    this.unlockedFields,
  });
}

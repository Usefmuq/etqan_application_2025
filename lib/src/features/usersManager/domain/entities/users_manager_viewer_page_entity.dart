import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/features/usersManager/data/models/users_manager_page_view_model.dart';

class UsersManagerViewerPageEntity {
  final UsersManagerPageViewModel usersManagersView;

  final List<ApprovalSequenceViewModel>? approval;
  final List<RequestUnlockedFieldModel>? unlockedFields;

  UsersManagerViewerPageEntity({
    required this.usersManagersView,
    this.approval,
    this.unlockedFields,
  });
}

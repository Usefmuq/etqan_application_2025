import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/features/usersManager/data/models/users_manager_page_view_model.dart';

class UsersManagerPageEntity {
  final List<UsersManagerPageViewModel> usersManagersView;
  final List<ApprovalSequenceViewModel> approvalsView;

  UsersManagerPageEntity({
    required this.usersManagersView,
    required this.approvalsView,
  });
}

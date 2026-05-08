import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/features/servicesManager/data/models/services_manager_page_view_model.dart';

class ServicesManagerPageEntity {
  final List<ServicesManagersPageViewModel> servicesmanagersView;
  final List<ApprovalSequenceViewModel> approvalsView;

  ServicesManagerPageEntity({
    required this.servicesmanagersView,
    required this.approvalsView,
  });
}

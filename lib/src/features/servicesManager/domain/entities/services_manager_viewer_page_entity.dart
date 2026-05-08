import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/features/servicesManager/data/models/services_manager_page_view_model.dart';

class ServicesManagerViewerPageEntity {
  final ServicesManagersPageViewModel servicesmanagersView;

  final List<ApprovalSequenceViewModel>? approval;
  final List<RequestUnlockedFieldModel>? unlockedFields;

  ServicesManagerViewerPageEntity({
    required this.servicesmanagersView,
    this.approval,
    this.unlockedFields,
  });
}

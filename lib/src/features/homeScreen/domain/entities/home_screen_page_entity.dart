import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/service_master_model.dart';

class HomeScreenPageEntity {
  final List<ServiceMasterModel> services;
  final List<ApprovalSequenceViewModel> approvals;

  HomeScreenPageEntity({
    required this.services,
    required this.approvals,
  });
}

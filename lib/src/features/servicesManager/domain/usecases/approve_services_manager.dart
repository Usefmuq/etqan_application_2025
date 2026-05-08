import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/servicesManager/data/models/services_manager_page_view_model.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/entities/services_manager_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/repositories/services_manager_repository.dart';
import 'package:fpdart/fpdart.dart';

class ApproveServicesManager
    implements
        Usecase<ServicesManagerViewerPageEntity, ApproveServicesManagerParams> {
  final ServicesManagerRepository servicesmanagerRepostory;
  ApproveServicesManager(this.servicesmanagerRepostory);
  @override
  Future<Either<Failure, ServicesManagerViewerPageEntity>> call(
      ApproveServicesManagerParams params) async {
    return await servicesmanagerRepostory.approveServicesManager(
      requestUnlockedFields: params.requestUnlockedFields,
      approvalSequenceModel: params.approvalSequenceModel,
      servicesmanagerModel: params.servicesmanagerModel,
    );
  }
}

class ApproveServicesManagerParams {
  final ApprovalSequenceViewModel approvalSequenceModel;
  final List<RequestUnlockedFieldModel>? requestUnlockedFields;

  final ServicesManagersPageViewModel servicesmanagerModel;

  ApproveServicesManagerParams({
    required this.approvalSequenceModel,
    this.requestUnlockedFields,
    required this.servicesmanagerModel,
  });
}

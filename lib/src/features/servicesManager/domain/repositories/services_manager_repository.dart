import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/features/servicesManager/data/models/services_manager_page_view_model.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/entities/services_manager_page_entity.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/entities/services_manager_viewer_page_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ServicesManagerRepository {
  Future<Either<Failure, ServicesManagerViewerPageEntity>>
      submitServicesManager({
    required String createdById,
    // required String status,
    // required String requestId,
    required String title,
    required String content,
    required List<String> topics,
  });
  Future<Either<Failure, ServicesManagerViewerPageEntity>>
      updateServicesManager({
    required ServicesManagersPageViewModel servicesmanagerViewerPage,
    required String updatedBy,
  });
  Future<Either<Failure, ServicesManagerViewerPageEntity>>
      approveServicesManager({
    required ApprovalSequenceViewModel approvalSequenceModel,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    required ServicesManagersPageViewModel servicesmanagerModel,
  });
  Future<Either<Failure, ServicesManagerPageEntity>> getAllServicesManagers({
    required User user,
    String? departmentId,
    required bool isManagerExpanded,
    required bool isDepartmentManagerExpanded,
    required bool isViewAll,
  });
  Future<Either<Failure, ServicesManagerViewerPageEntity>>
      fetchServicesManagerViewerPage({
    required int requestId,
  });
}

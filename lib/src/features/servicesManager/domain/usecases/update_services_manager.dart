import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/servicesManager/data/models/services_manager_page_view_model.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/entities/services_manager_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/repositories/services_manager_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateServicesManager
    implements
        Usecase<ServicesManagerViewerPageEntity, UpdateServicesManagerParams> {
  final ServicesManagerRepository servicesmanagerRepostory;
  UpdateServicesManager(this.servicesmanagerRepostory);
  @override
  Future<Either<Failure, ServicesManagerViewerPageEntity>> call(
      UpdateServicesManagerParams params) async {
    return await servicesmanagerRepostory.updateServicesManager(
      servicesmanagerViewerPage: params.servicesmanagerViewerPage,
      updatedBy: params.updatedBy,
    );
  }
}

class UpdateServicesManagerParams {
  final ServicesManagersPageViewModel servicesmanagerViewerPage;
  final String updatedBy;

  UpdateServicesManagerParams({
    required this.servicesmanagerViewerPage,
    required this.updatedBy,
  });
}

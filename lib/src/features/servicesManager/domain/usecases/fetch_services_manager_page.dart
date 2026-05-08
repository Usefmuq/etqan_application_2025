import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/entities/services_manager_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/repositories/services_manager_repository.dart';
import 'package:fpdart/fpdart.dart';

class FetchServicesManagerPage
    implements
        Usecase<ServicesManagerViewerPageEntity,
            FetchServicesManagerPageParams> {
  final ServicesManagerRepository servicesmanagerRepostory;
  FetchServicesManagerPage(this.servicesmanagerRepostory);
  @override
  Future<Either<Failure, ServicesManagerViewerPageEntity>> call(
      FetchServicesManagerPageParams params) async {
    return await servicesmanagerRepostory.fetchServicesManagerViewerPage(
      requestId: params.requestId,
    );
  }
}

class FetchServicesManagerPageParams {
  final int requestId;

  FetchServicesManagerPageParams({
    required this.requestId,
  });
}

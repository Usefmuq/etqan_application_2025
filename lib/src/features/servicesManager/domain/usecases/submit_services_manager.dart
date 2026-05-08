import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/entities/services_manager_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/repositories/services_manager_repository.dart';
import 'package:fpdart/fpdart.dart';

class SubmitServicesManager
    implements
        Usecase<ServicesManagerViewerPageEntity, SubmitServicesManagerParams> {
  final ServicesManagerRepository servicesmanagerRepostory;
  SubmitServicesManager(this.servicesmanagerRepostory);
  @override
  Future<Either<Failure, ServicesManagerViewerPageEntity>> call(
      SubmitServicesManagerParams params) async {
    return await servicesmanagerRepostory.submitServicesManager(
      createdById: params.createdById,
      // status: params.status,
      // requestId: params.requestId,
      title: params.title,
      content: params.content,
      topics: params.topics,
    );
  }
}

class SubmitServicesManagerParams {
  final String createdById;
  // final String status;
  // final String requestId;
  final String title;
  final String content;
  final List<String> topics;

  SubmitServicesManagerParams({
    required this.createdById,
    // required this.status,
    // required this.requestId,
    required this.title,
    required this.content,
    required this.topics,
  });
}

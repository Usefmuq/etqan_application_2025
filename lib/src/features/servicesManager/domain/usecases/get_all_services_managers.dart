import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/entities/services_manager_page_entity.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/repositories/services_manager_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllServicesManagers
    implements
        Usecase<ServicesManagerPageEntity, GetAllServicesManagersParams> {
  final ServicesManagerRepository servicesmanagerRepostory;
  GetAllServicesManagers(this.servicesmanagerRepostory);
  @override
  Future<Either<Failure, ServicesManagerPageEntity>> call(
      GetAllServicesManagersParams params) async {
    return await servicesmanagerRepostory.getAllServicesManagers(
      user: params.user,
      departmentId: params.departmentId,
      isManagerExpanded: params.isManagerExpanded,
      isDepartmentManagerExpanded: params.isDepartmentManagerExpanded,
      isViewAll: params.isViewAll,
    );
  }
}

class GetAllServicesManagersParams {
  final User user;
  final String? departmentId;
  final bool isManagerExpanded;
  final bool isDepartmentManagerExpanded;
  final bool isViewAll;

  GetAllServicesManagersParams({
    required this.user,
    this.departmentId,
    required this.isManagerExpanded,
    required this.isDepartmentManagerExpanded,
    required this.isViewAll,
  });
}

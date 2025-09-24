import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/entities/users_manager_page_entity.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/repositories/users_manager_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllUsersManagers
    implements Usecase<UsersManagerPageEntity, GetAllUsersManagersParams> {
  final UsersManagerRepository usersManagerRepostory;
  GetAllUsersManagers(this.usersManagerRepostory);
  @override
  Future<Either<Failure, UsersManagerPageEntity>> call(
      GetAllUsersManagersParams params) async {
    return await usersManagerRepostory.getAllUsersManagers(
      user: params.user,
      departmentId: params.departmentId,
      isManagerExpanded: params.isManagerExpanded,
      isDepartmentManagerExpanded: params.isDepartmentManagerExpanded,
      isViewAll: params.isViewAll,
    );
  }
}

class GetAllUsersManagersParams {
  final User user;
  final String? departmentId;
  final bool isManagerExpanded;
  final bool isDepartmentManagerExpanded;
  final bool isViewAll;

  GetAllUsersManagersParams({
    required this.user,
    this.departmentId,
    required this.isManagerExpanded,
    required this.isDepartmentManagerExpanded,
    required this.isViewAll,
  });
}

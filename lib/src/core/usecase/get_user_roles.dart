import 'package:etqan_application_2025/src/core/common/entities/user_roles.dart';
import 'package:etqan_application_2025/src/core/domain/repository/user_roles_repository.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../error/failure.dart';

class GetUserRoles implements Usecase<List<UserRoles>, GetUserRolesParams> {
  final UserRolesRepository userRolesRepository;
  const GetUserRoles(this.userRolesRepository);
  @override
  Future<Either<Failure, List<UserRoles>>> call(
      GetUserRolesParams params) async {
    return await userRolesRepository.getUserRoles(
      userId: params.userId,
    );
  }
}

class GetUserRolesParams {
  final String userId;

  GetUserRolesParams({
    required this.userId,
  });
}

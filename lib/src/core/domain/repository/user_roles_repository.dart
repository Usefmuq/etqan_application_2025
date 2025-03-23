import 'package:etqan_application_2025/src/core/common/entities/user_roles.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class UserRolesRepository {
  Future<Either<Failure, List<UserRoles>>> getUserRoles({
    required String userId,
  });
}

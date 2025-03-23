import 'package:etqan_application_2025/src/core/common/entities/user_roles.dart';
import 'package:etqan_application_2025/src/core/data/datasources/user_roles_remote_data_source.dart';
import 'package:etqan_application_2025/src/core/domain/repository/user_roles_repository.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:fpdart/fpdart.dart';

class UserRolesRepositoryImpl implements UserRolesRepository {
  final UserRolesRemoteDataSource remoteDataSource;
  const UserRolesRepositoryImpl(
    this.remoteDataSource,
  );

  @override
  Future<Either<Failure, List<UserRoles>>> getUserRoles({
    required String userId,
  }) async {
    try {
      final userRoles = await remoteDataSource.getUserRoles(userId: userId);
      return right(userRoles);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}

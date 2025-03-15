import 'package:etqan_application_2025/src/core/common/entities/permissions_view.dart';
import 'package:etqan_application_2025/src/core/data/datasources/permission_remote_data_source.dart';
import 'package:etqan_application_2025/src/core/domain/repository/permission_repository.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:fpdart/fpdart.dart';

class PermissionRepositoryImpl implements PermissionRepository {
  final PermissionRemoteDataSource remoteDataSource;
  const PermissionRepositoryImpl(
    this.remoteDataSource,
  );

  @override
  Future<Either<Failure, List<PermissionsView>>> getUserPermissions({
    required String userId,
  }) async {
    try {
      final permissions = await remoteDataSource.getPermissions(userId: userId);
      return right(permissions);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}

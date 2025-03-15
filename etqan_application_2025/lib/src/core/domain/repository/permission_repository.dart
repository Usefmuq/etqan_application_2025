import 'package:etqan_application_2025/src/core/common/entities/permissions_view.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class PermissionRepository {
  Future<Either<Failure, List<PermissionsView>>> getUserPermissions({
    required String userId,
  });
}

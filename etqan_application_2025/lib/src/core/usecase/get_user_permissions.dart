import 'package:etqan_application_2025/src/core/common/entities/permissions_view.dart';
import 'package:etqan_application_2025/src/core/domain/repository/permission_repository.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';

import '../error/failure.dart';

class GetUserPermissions
    implements Usecase<List<PermissionsView>, GetUserPermissionsParams> {
  final PermissionRepository permissionRepository;
  const GetUserPermissions(this.permissionRepository);
  @override
  Future<Either<Failure, List<PermissionsView>>> call(
      GetUserPermissionsParams params) async {
    return await permissionRepository.getUserPermissions(
      userId: params.userId,
    );
  }
}

class GetUserPermissionsParams {
  final String userId;

  GetUserPermissionsParams({
    required this.userId,
  });
}

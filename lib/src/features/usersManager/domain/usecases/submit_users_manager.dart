import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/entities/users_manager_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/repositories/users_manager_repository.dart';
import 'package:fpdart/fpdart.dart';

class SubmitUsersManager
    implements Usecase<UsersManagerViewerPageEntity, SubmitUsersManagerParams> {
  final UsersManagerRepository usersManagerRepostory;
  SubmitUsersManager(this.usersManagerRepostory);
  @override
  Future<Either<Failure, UsersManagerViewerPageEntity>> call(
      SubmitUsersManagerParams params) async {
    return await usersManagerRepostory.submitUsersManager(
      createdById: params.createdById,
      userId: params.userId,
      roleId: params.roleId,
      startAt: params.startAt,
      endAt: params.endAt,
      action: params.action,
      notes: params.notes,
      departmentId: params.departmentId,
      appliesToAllDepartments: params.appliesToAllDepartments,
    );
  }
}

class SubmitUsersManagerParams {
  final String createdById;
  final String userId;
  final String roleId;
  final DateTime startAt;
  final DateTime? endAt;
  final String action;
  final String notes;
  final String departmentId;
  final bool appliesToAllDepartments;

  SubmitUsersManagerParams({
    required this.createdById,
    required this.userId,
    required this.roleId,
    required this.startAt,
    required this.endAt,
    required this.action,
    required this.notes,
    required this.departmentId,
    required this.appliesToAllDepartments,
  });
}

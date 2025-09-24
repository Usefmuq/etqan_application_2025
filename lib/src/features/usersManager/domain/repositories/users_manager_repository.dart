import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/features/usersManager/data/models/users_manager_page_view_model.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/entities/users_manager_page_entity.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/entities/users_manager_viewer_page_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class UsersManagerRepository {
  Future<Either<Failure, UsersManagerViewerPageEntity>> submitUsersManager({
    required String createdById,
    required String userId,
    required String roleId,
    required DateTime startAt,
    required DateTime? endAt,
    required String action,
    required String notes,
    required String departmentId,
    required bool appliesToAllDepartments,
  });
  Future<Either<Failure, UsersManagerViewerPageEntity>> updateUsersManager({
    required UsersManagerPageViewModel usersManagerViewerPage,
    required String updatedBy,
  });
  Future<Either<Failure, UsersManagerViewerPageEntity>> approveUsersManager({
    required ApprovalSequenceViewModel approvalSequenceModel,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    required UsersManagerPageViewModel usersManagerModel,
  });
  Future<Either<Failure, UsersManagerPageEntity>> getAllUsersManagers({
    required User user,
    String? departmentId,
    required bool isManagerExpanded,
    required bool isDepartmentManagerExpanded,
    required bool isViewAll,
  });
  Future<Either<Failure, UsersManagerViewerPageEntity>>
      fetchUsersManagerViewerPage({
    required int requestId,
  });
}

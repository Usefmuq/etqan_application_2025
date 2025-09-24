import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/usersManager/data/models/users_manager_page_view_model.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/entities/users_manager_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/repositories/users_manager_repository.dart';
import 'package:fpdart/fpdart.dart';

class ApproveUsersManager
    implements
        Usecase<UsersManagerViewerPageEntity, ApproveUsersManagerParams> {
  final UsersManagerRepository usersManagerRepostory;
  ApproveUsersManager(this.usersManagerRepostory);
  @override
  Future<Either<Failure, UsersManagerViewerPageEntity>> call(
      ApproveUsersManagerParams params) async {
    return await usersManagerRepostory.approveUsersManager(
      requestUnlockedFields: params.requestUnlockedFields,
      approvalSequenceModel: params.approvalSequenceModel,
      usersManagerModel: params.usersManagerModel,
    );
  }
}

class ApproveUsersManagerParams {
  final ApprovalSequenceViewModel approvalSequenceModel;
  final List<RequestUnlockedFieldModel>? requestUnlockedFields;

  final UsersManagerPageViewModel usersManagerModel;

  ApproveUsersManagerParams({
    required this.approvalSequenceModel,
    this.requestUnlockedFields,
    required this.usersManagerModel,
  });
}

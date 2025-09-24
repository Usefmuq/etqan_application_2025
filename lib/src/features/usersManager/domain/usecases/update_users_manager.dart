import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/usersManager/data/models/users_manager_page_view_model.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/entities/users_manager_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/repositories/users_manager_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateUsersManager
    implements Usecase<UsersManagerViewerPageEntity, UpdateUsersManagerParams> {
  final UsersManagerRepository usersManagerRepostory;
  UpdateUsersManager(this.usersManagerRepostory);
  @override
  Future<Either<Failure, UsersManagerViewerPageEntity>> call(
      UpdateUsersManagerParams params) async {
    return await usersManagerRepostory.updateUsersManager(
      usersManagerViewerPage: params.usersManagerViewerPage,
      updatedBy: params.updatedBy,
    );
  }
}

class UpdateUsersManagerParams {
  final UsersManagerPageViewModel usersManagerViewerPage;
  final String updatedBy;

  UpdateUsersManagerParams({
    required this.usersManagerViewerPage,
    required this.updatedBy,
  });
}

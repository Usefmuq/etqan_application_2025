import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/entities/users_manager_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/repositories/users_manager_repository.dart';
import 'package:fpdart/fpdart.dart';

class FetchUsersManagerPage
    implements
        Usecase<UsersManagerViewerPageEntity, FetchUsersManagerPageParams> {
  final UsersManagerRepository usersManagerRepostory;
  FetchUsersManagerPage(this.usersManagerRepostory);
  @override
  Future<Either<Failure, UsersManagerViewerPageEntity>> call(
      FetchUsersManagerPageParams params) async {
    return await usersManagerRepostory.fetchUsersManagerViewerPage(
      requestId: params.requestId,
    );
  }
}

class FetchUsersManagerPageParams {
  final int requestId;

  FetchUsersManagerPageParams({
    required this.requestId,
  });
}

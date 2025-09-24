part of 'users_manager_bloc.dart';

@immutable
sealed class UsersManagerState {}

final class UsersManagerInitial extends UsersManagerState {}

final class UsersManagerLoading extends UsersManagerState {}

final class UsersManagerFailure extends UsersManagerState {
  final String error;
  UsersManagerFailure(this.error);
}

final class UsersManagerSubmitSuccess extends UsersManagerState {}

final class UsersManagerUpdateSuccess extends UsersManagerState {
  final UsersManagerViewerPageEntity usersManagerViewerPageEntity;
  UsersManagerUpdateSuccess(this.usersManagerViewerPageEntity);
}

final class UsersManagerApproveSuccess extends UsersManagerState {
  final UsersManagerViewerPageEntity usersManagerViewerPageEntity;
  UsersManagerApproveSuccess(this.usersManagerViewerPageEntity);
}

final class UsersManagerShowAllSuccess extends UsersManagerState {
  final UsersManagerPageEntity usersManagerPage;
  UsersManagerShowAllSuccess(this.usersManagerPage);
}

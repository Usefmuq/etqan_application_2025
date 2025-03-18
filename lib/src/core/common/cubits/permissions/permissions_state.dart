part of 'permissions_cubit.dart';

@immutable
sealed class PermissionsState {}

final class PermissionsInitial extends PermissionsState {}

final class PermissionsList extends PermissionsState {
  final List<PermissionsView> permissions;
  PermissionsList(this.permissions);
}

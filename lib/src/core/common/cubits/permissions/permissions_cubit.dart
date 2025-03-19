import 'package:etqan_application_2025/src/core/usecase/get_user_permissions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:etqan_application_2025/src/core/common/entities/permissions_view.dart';
part 'permissions_state.dart';

class PermissionsCubit extends Cubit<PermissionsState> {
  final GetUserPermissions getUserPermissions;

  PermissionsCubit(this.getUserPermissions) : super(PermissionsInitial());

  Future<void> loadPermissions(String userId) async {
    final response =
        await getUserPermissions.call(GetUserPermissionsParams(userId: userId));

    response.fold(
      (failure) => emit(PermissionsInitial()), // Handle failure case
      (permissionsList) {
        // ✅ Convert List<PermissionsView> to List<String>
        // List<String> permissionKeys =
        //     permissionsList.map((perm) => perm.permissionKey).toList();
        emit(PermissionsList(permissionsList));
      },
    );
  }

  bool hasPermission(String permissionId) {
    if (state is! PermissionsList) {
      return false;
    }

    final permissionsList = (state as PermissionsList).permissions;

    if (permissionsList.isEmpty) {
      return false;
    }

    final hasPerm =
        permissionsList.any((perm) => perm.permissionKey == permissionId);

    return hasPerm;
  }

  // bool hasPermission(String permissionId) {
  //   print("ss");

  //   final xx =
  //       (state as PermissionsList).permissions.first.permissionDescriptionAr;
  //   print("hasPermission ${xx}");
  //   return false;
  // }
}

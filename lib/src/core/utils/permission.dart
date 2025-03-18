import 'package:etqan_application_2025/init_dependencies.dart';
import 'package:etqan_application_2025/src/core/usecase/get_user_permissions.dart';

bool isUserHasPermissionsView(
  List<String> permissionsList,
  String permissionId,
) {
  return permissionsList.contains(permissionId);
}

Future<List<String>?> fetchUserPermissions(String userId) async {
  final GetUserPermissions getUserPermissions = serviceLocator<
      GetUserPermissions>(); // ✅ Get use case from service locator

  final response =
      await getUserPermissions.call(GetUserPermissionsParams(userId: userId));

  return response.fold((failure) {
    return [];
  }, (permissionsList) {
    final perms = permissionsList.map((p) => p.permissionKey).toList();
    return perms;
  });
}

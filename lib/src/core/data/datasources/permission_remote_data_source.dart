import 'package:etqan_application_2025/src/core/data/models/permission_model.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class PermissionRemoteDataSource {
  Future<List<PermissionModel>> getPermissions({
    required String userId,
  });
}

class PermissionRemoteDataSourceImpl implements PermissionRemoteDataSource {
  final SupabaseClient supabaseClient;
  PermissionRemoteDataSourceImpl(this.supabaseClient);
  @override
  Future<List<PermissionModel>> getPermissions({
    required String userId,
  }) async {
    try {
      final permissions = await supabaseClient
          .from('user_permissions_view')
          .select('*')
          .eq('user_id', userId)
          .or(
            'end_date.gt.${DateTime.now().toIso8601String()},end_date.is.null',
          );
      return permissions
          .map((permissions) => PermissionModel.fromJson(permissions))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

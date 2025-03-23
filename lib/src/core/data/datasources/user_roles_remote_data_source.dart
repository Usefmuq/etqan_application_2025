import 'package:etqan_application_2025/src/core/data/models/user_roles_model.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class UserRolesRemoteDataSource {
  Future<List<UserRolesModel>> getUserRoles({
    required String userId,
  });
}

class UserRolesRemoteDataSourceImpl implements UserRolesRemoteDataSource {
  final SupabaseClient supabaseClient;
  UserRolesRemoteDataSourceImpl(this.supabaseClient);
  @override
  Future<List<UserRolesModel>> getUserRoles({
    required String userId,
  }) async {
    try {
      final userRoless = await supabaseClient
          .from('userroles')
          .select('*')
          .eq('user_id', userId)
          .gt(
            'end_date',
            DateTime.now().toIso8601String(),
          );
      return userRoless
          .map((userRoless) => UserRolesModel.fromJson(userRoless))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

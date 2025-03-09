import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Session? get currentUserSession;
  Future<UserModel> signUp({
    required String email,
    required String password,
  });
  Future<UserModel> signIn({
    required String email,
    required String password,
  });
  Future<UserModel?> getUserDataBySession();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;
  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Session? get currentUserSession => supabaseClient.auth.currentSession;

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signUp(
        password: password,
        email: email,
      );
      if (response.user == null) {
        throw ServerException('ServerException ~ user is null');
      }
      return UserModel.fromJson(response.user!.toJson())
          .copyWith(email: currentUserSession!.user.email);
    } catch (e) {
      throw ServerException('ServerException ~ ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        password: password,
        email: email,
      );
      if (response.user == null) {
        throw ServerException('ServerException ~ user is null');
      }
      return UserModel.fromJson(response.user!.toJson())
          .copyWith(email: currentUserSession!.user.email);
    } catch (e) {
      throw ServerException('ServerException ~ ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getUserDataBySession() async {
    try {
      if (currentUserSession != null) {
        final userData = await supabaseClient.from('users').select().eq(
              'id',
              currentUserSession!.user.id,
            );
        if (userData.isEmpty) {
          return null;
        }
        return UserModel.fromJson(userData.first)
            .copyWith(email: currentUserSession!.user.email);
      }
      return null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}

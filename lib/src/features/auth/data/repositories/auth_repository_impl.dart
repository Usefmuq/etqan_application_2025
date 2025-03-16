import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/network/connection_checker.dart';
import 'package:etqan_application_2025/src/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/features/auth/data/models/user_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;

import '../../domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;
  const AuthRepositoryImpl(
    this.remoteDataSource,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, User>> currentUserBySession() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final session = remoteDataSource.currentUserSession;
        if (session == null) {
          return left(Failure('User is not logged in'));
        }
        return right(
          UserModel(
            id: session.user.id,
            email: session.user.email ?? '',
            firstNameEn: '',
            lastNameEn: '',
            firstNameAr: '',
            lastNameAr: '',
            phone: '',
            departmentId: '',
            positionId: '',
            statusId: '',
            reportTo: '',
            languagePreference: '',
            timezone: '',
            createdAt: '',
            updatedAt: '',
          ),
        );
      }
      final user = await remoteDataSource.getUserDataBySession();
      if (user == null) {
        return left(Failure('User is not logged in'));
      }
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.signUp(
        email: email,
        password: password,
      ),
    );
  }

  @override
  Future<Either<Failure, User>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return _getUser(
      () async => await remoteDataSource.signIn(
        email: email,
        password: password,
      ),
    );
  }

  Future<Either<Failure, User>> _getUser(Future<User> Function() fn) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure('no internet connection!'));
      }
      final user = await fn();
      return right(user);
    } on sp.AuthException catch (e) {
      return left(Failure(e.message));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}

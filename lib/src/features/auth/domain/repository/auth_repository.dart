import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> signUpWithEmailPassword({
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> signInWithEmailPassword({
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> currentUserBySession();
}

import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/features/auth/domain/usecase/current_user_by_session.dart';
import 'package:etqan_application_2025/src/features/auth/domain/usecase/user_sign_in.dart';
import 'package:etqan_application_2025/src/features/auth/domain/usecase/user_sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserSignIn _userSignIn;
  final CurrentUserBySession _currentUserBySession;
  final AppUserCubit _appUserCubit;
  AuthBloc({
    required UserSignUp userSignUp,
    required UserSignIn userSignIn,
    required CurrentUserBySession currentUserBySession,
    required AppUserCubit appUserCubit,
  })  : _userSignUp = userSignUp,
        _userSignIn = userSignIn,
        _currentUserBySession = currentUserBySession,
        _appUserCubit = appUserCubit,
        super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthSignIn>(_onAuthSignIn);
    on<AuthIsUserSignedIn>(_isUserSignedIn);
  }

  void _isUserSignedIn(
    AuthIsUserSignedIn event,
    Emitter<AuthState> emit,
  ) async {
    final response = await _currentUserBySession(NoParams());
    response.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) {
        _emitAuthSuccess(user, emit);
      },
    );
  }

  void _onAuthSignUp(
    AuthSignUp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final response = await _userSignUp(UserSignUpParams(
      email: event.email,
      password: event.password,
    ));
    response.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _onAuthSignIn(
    AuthSignIn event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final response = await _userSignIn(UserSignInParams(
      email: event.email,
      password: event.password,
    ));
    response.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => _emitAuthSuccess(user, emit),
    );
  }

  void _emitAuthSuccess(
    User user,
    Emitter<AuthState> emit,
  ) async {
    _appUserCubit.updatUser(user);
    emit(AuthSuccess(user));
  }
}

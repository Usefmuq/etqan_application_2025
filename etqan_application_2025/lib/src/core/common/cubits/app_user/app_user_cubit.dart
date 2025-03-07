import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_user_state.dart';

class AppUserCubit extends Cubit<AppUserState> {
  AppUserCubit() : super(AppUserInitial());
  void updatUser(User? user) {
    if (user == null) {
      emit(AppUserInitial());
    } else {
      emit(AppUserSignedIn(user));
    }
  }
}

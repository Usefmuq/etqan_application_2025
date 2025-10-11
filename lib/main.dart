import 'package:etqan_application_2025/init_dependencies.dart';
import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/usecase/get_user_permissions.dart';
import 'package:etqan_application_2025/src/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:etqan_application_2025/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:etqan_application_2025/src/features/homeScreen/presentation/bloc/home_screen_bloc.dart';
import 'package:etqan_application_2025/src/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:etqan_application_2025/src/features/usersManager/presentation/bloc/users_manager_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initdependencies();
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => serviceLocator<AppUserCubit>(),
      ),
      RepositoryProvider(
        // ✅ Register GetUserPermissions
        create: (_) => serviceLocator<GetUserPermissions>(),
      ),
      BlocProvider(
        create: (_) => serviceLocator<AuthBloc>(),
      ),
      BlocProvider(
        create: (_) => serviceLocator<BlogBloc>(),
      ),
      BlocProvider(
        create: (_) => serviceLocator<UsersManagerBloc>(),
      ),
      BlocProvider(
        create: (_) => serviceLocator<AttendanceBloc>(),
      ),
      BlocProvider(
        create: (_) => serviceLocator<HomeScreenBloc>(),
      ),
      BlocProvider(
        create: (_) => serviceLocator<OnboardingBloc>(),
      ),
    ],
    child: MyApp(settingsController: settingsController),
  ));
}

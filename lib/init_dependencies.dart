import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/data/datasources/permission_remote_data_source.dart';
import 'package:etqan_application_2025/src/core/data/datasources/user_roles_remote_data_source.dart';
import 'package:etqan_application_2025/src/core/data/repositories/permission_repository_impl.dart';
import 'package:etqan_application_2025/src/core/data/repositories/user_roles_repository_impl.dart';
import 'package:etqan_application_2025/src/core/domain/repository/permission_repository.dart';
import 'package:etqan_application_2025/src/core/domain/repository/user_roles_repository.dart';
import 'package:etqan_application_2025/src/core/network/connection_checker.dart';
import 'package:etqan_application_2025/src/core/supabase/supabase_conf.dart';
import 'package:etqan_application_2025/src/core/usecase/get_user_permissions.dart';
import 'package:etqan_application_2025/src/core/usecase/get_user_roles.dart';
import 'package:etqan_application_2025/src/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:etqan_application_2025/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:etqan_application_2025/src/features/auth/domain/repository/auth_repository.dart';
import 'package:etqan_application_2025/src/features/auth/domain/usecase/current_user_by_session.dart';
import 'package:etqan_application_2025/src/features/auth/domain/usecase/user_sign_in.dart';
import 'package:etqan_application_2025/src/features/auth/domain/usecase/user_sign_up.dart';
import 'package:etqan_application_2025/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:etqan_application_2025/src/features/blog/data/datasources/blog_remote_data_source.dart';
import 'package:etqan_application_2025/src/features/blog/data/repositories/blog_repository_impl.dart';
import 'package:etqan_application_2025/src/features/blog/domain/repositories/blog_repository.dart';
import 'package:etqan_application_2025/src/features/blog/domain/usecases/approve_blog.dart';
import 'package:etqan_application_2025/src/features/blog/domain/usecases/fetch_blog_page.dart';
import 'package:etqan_application_2025/src/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:etqan_application_2025/src/features/blog/domain/usecases/submit_blog.dart';
import 'package:etqan_application_2025/src/features/blog/domain/usecases/update_blog.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:etqan_application_2025/src/features/homeScreen/data/datasources/home_screen_remote_data_source.dart';
import 'package:etqan_application_2025/src/features/homeScreen/data/repositories/home_screen_repository_impl.dart';
import 'package:etqan_application_2025/src/features/homeScreen/domain/repositories/home_screen_repository.dart';
import 'package:etqan_application_2025/src/features/homeScreen/domain/usecases/get_all_services.dart';
import 'package:etqan_application_2025/src/features/homeScreen/presentation/bloc/home_screen_bloc.dart';
import 'package:etqan_application_2025/src/features/onboarding/data/datasources/onboarding_remote_data_source.dart';
import 'package:etqan_application_2025/src/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/usecases/approve_onboarding.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/usecases/get_all_onboardings.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/usecases/submit_onboarding.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/usecases/update_onboarding.dart';
import 'package:etqan_application_2025/src/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final serviceLocator = GetIt.instance;
Future<void> initdependencies() async {
  _intitAuth();
  _intitHomeScreen();
  _intitBlog();
  _intitOnboarding();
  final supabase = await Supabase.initialize(
    url: SupabaseConf.supabaseUrl,
    anonKey: SupabaseConf.supabaseAnonKey,
  );
  serviceLocator.registerLazySingleton(
    () => supabase.client,
  );
  serviceLocator.registerFactory(
    () => InternetConnection(),
  );
  // core
  serviceLocator.registerLazySingleton(
    () => AppUserCubit(),
  );
  serviceLocator.registerFactory<ConnectionChecker>(
    () => ConnectionCheckerImpl(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory<PermissionRemoteDataSource>(
    () => PermissionRemoteDataSourceImpl(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory<PermissionRepository>(
    () => PermissionRepositoryImpl(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory<UserRolesRemoteDataSource>(
    () => UserRolesRemoteDataSourceImpl(
      serviceLocator(),
    ),
  );
  serviceLocator.registerFactory<UserRolesRepository>(
    () => UserRolesRepositoryImpl(
      serviceLocator(),
    ),
  );
  //use cases
  // ✅ Register GetUserPermissions Use Case
  serviceLocator.registerLazySingleton<GetUserPermissions>(
    () => GetUserPermissions(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<GetUserRoles>(
    () => GetUserRoles(serviceLocator()),
  );
}

void _intitAuth() {
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    //UseCases
    ..registerFactory(
      () => UserSignUp(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UserSignIn(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => CurrentUserBySession(
        serviceLocator(),
      ),
    )
    //Bloc
    ..registerLazySingleton(
      () => AuthBloc(
        userSignUp: serviceLocator(),
        userSignIn: serviceLocator(),
        currentUserBySession: serviceLocator(),
        appUserCubit: serviceLocator(),
      ),
    );
}

void _intitBlog() {
  // DataSource
  serviceLocator
    ..registerFactory<BlogRemoteDataSource>(
      () => BlogRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<BlogRepository>(
      () => BlogRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    //UseCases
    ..registerFactory(
      () => SubmitBlog(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UpdateBlog(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetAllBlogs(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => FetchBlogPage(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ApproveBlog(
        serviceLocator(),
      ),
    )
    //Bloc
    ..registerLazySingleton(
      () => BlogBloc(
        submitBlog: serviceLocator(),
        updateBlog: serviceLocator(),
        approveBlog: serviceLocator(),
        getAllBlogs: serviceLocator(),
      ),
    );
}

void _intitHomeScreen() {
  // DataSource
  serviceLocator
    ..registerFactory<HomeScreenRemoteDataSource>(
      () => HomeScreenRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<HomeScreenRepository>(
      () => HomeScreenRepositoryImpl(
        serviceLocator(),
      ),
    )
    //UseCases
    ..registerFactory(
      () => GetAllServices(
        serviceLocator(),
      ),
    )
    //Bloc
    ..registerLazySingleton(
      () => HomeScreenBloc(
        getAllServices: serviceLocator(),
      ),
    );
}

void _intitOnboarding() {
  // DataSource
  serviceLocator
    ..registerFactory<OnboardingRemoteDataSource>(
      () => OnboardingRemoteDataSourceImpl(
        serviceLocator(),
      ),
    )
    // Repository
    ..registerFactory<OnboardingRepository>(
      () => OnboardingRepositoryImpl(
        serviceLocator(),
        serviceLocator(),
      ),
    )
    //UseCases
    ..registerFactory(
      () => SubmitOnboarding(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => UpdateOnboarding(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => GetAllOnboardings(
        serviceLocator(),
      ),
    )
    ..registerFactory(
      () => ApproveOnboarding(
        serviceLocator(),
      ),
    )
    //Bloc
    ..registerLazySingleton(
      () => OnboardingBloc(
        submitOnboarding: serviceLocator(),
        updateOnboarding: serviceLocator(),
        approveOnboarding: serviceLocator(),
        getAllOnboardings: serviceLocator(),
      ),
    );
}

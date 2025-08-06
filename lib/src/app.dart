import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/theme/theme.dart';
import 'package:etqan_application_2025/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/pages/add_new_blog_page.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/pages/blog_page.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/pages/blog_viewer_page.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/pages/update_blog_page.dart';
import 'package:etqan_application_2025/src/features/homeScreen/presentation/pages/home_screen_page.dart';
import 'package:etqan_application_2025/src/features/onboarding/data/models/onboarding_page_view_model.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/entities/onboarding_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/onboarding/presentation/pages/add_new_onboarding_page.dart';
import 'package:etqan_application_2025/src/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:etqan_application_2025/src/features/onboarding/presentation/pages/onboarding_viewer_page.dart';
import 'package:etqan_application_2025/src/features/onboarding/presentation/pages/update_onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/auth/presentation/pages/signup_page.dart';
import 'settings/settings_controller.dart';

/// The Widget that configures your application.
class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.settingsController});

  final SettingsController settingsController;

  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // ✅ Check if already signed in
    context.read<AuthBloc>().add(AuthIsUserSignedIn());

    // ✅ Listen to Supabase auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (!mounted) return; // ✅ safely check before using context

      if (event == AuthChangeEvent.signedOut) {
        // 🔁 Tell your Cubit to update auth state
        context.read<AppUserCubit>().signOut(); // You must implement this
      } else if (event == AuthChangeEvent.signedIn) {
        final state = context.read<AppUserCubit>().state;
        if (state is! AppUserSignedIn) {
        } else {
          final user = state.user;
          context.read<AppUserCubit>().updatUser(user); // Also implement this
        }
      }
    });
  }

  Locale _locale = const Locale('ar'); // default locale

  void changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.

    final GoRouter router = GoRouter(
      // debugLogDiagnostics: true,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            return BlocSelector<AppUserCubit, AppUserState, bool>(
              selector: (state) => state is AppUserSignedIn,
              builder: (context, isSignedIn) {
                return isSignedIn ? const HomeScreenPage() : const SignupPage();
              },
            );
          },
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) {
            return HomeScreenPage();
          },
        ),
        GoRoute(
          path: '/blogs',
          builder: (context, state) {
            return BlogPage();
          },
        ),
        GoRoute(
          path: '/blog/submit',
          builder: (context, state) {
            return AddNewBlogPage();
          },
        ),
        GoRoute(
          path: '/blog/update/:id',
          builder: (context, state) {
            if (state.extra != null) {
              final entity = state.extra as BlogViewerPageEntity;
              return UpdateBlogPage(initialBlogViewerPage: entity);
            }
            final requestId = int.tryParse(state.pathParameters['id'] ?? '');
            return UpdateBlogPage(requestId: requestId!);
          },
        ),
        GoRoute(
          path: '/blog/:id',
          builder: (context, state) {
            if (state.extra != null) {
              final entity = state.extra as BlogViewerPageEntity;
              return BlogViewerPage(initialBlogViewerPage: entity);
            }
            final requestId = int.tryParse(state.pathParameters['id'] ?? '');
            return BlogViewerPage(requestId: requestId!);
          },
        ),
        GoRoute(
          path: '/onboardings',
          builder: (context, state) {
            return OnboardingPage();
          },
        ),
        GoRoute(
          path: '/onboarding/submit',
          builder: (context, state) {
            return AddNewOnboardingPage();
          },
        ),
        GoRoute(
          path: '/onboarding/update/:id',
          builder: (context, state) {
            final entity = state.extra as OnboardingsPageViewModel;
            return UpdateOnboardingPage(onboarding: entity);
          },
        ),
        GoRoute(
          path: '/onboarding/:id',
          builder: (context, state) {
            final entity = state.extra as OnboardingViewerPageEntity;
            return OnboardingViewerPage(onboardingViewerPage: entity);
          },
        ),
      ],
    );
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedOut) {
        // Update your state or redirect globally
      }
    });

    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp.router(
          //hide top right banner
          debugShowCheckedModeBanner: false,

          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English, no country code
            Locale('ar'), // English, no country code
          ],
          locale: _locale,

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: AppTheme.lightThemeMode,
          // darkTheme: ThemeData.dark(),
          // themeMode: settingsController.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          routerConfig: router, // ✅ Replaces onGenerateRoute with router
        );
      },
    );
  }
}

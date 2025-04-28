import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/animated_card_wrapper.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_card_service.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/core/utils/show_snackbar.dart';
import 'package:etqan_application_2025/src/features/homeScreen/presentation/bloc/home_screen_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreenPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const HomeScreenPage(),
      );

  const HomeScreenPage({super.key});

  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  List<String>? permissions;
  _HomeScreenPageState() : super();
  @override
  void initState() {
    super.initState();
    final userId =
        (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;

    Future.microtask(() async {
      final fetchedPermissions = await fetchUserPermissions(userId);

      if (mounted) {
        setState(() {
          permissions = fetchedPermissions;
        });
      }
    });
    // context.read<HomeScreenBloc>().add(HomeScreenGetAllHomeScreensEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Re-fetch homeScreens when this page becomes active again
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ModalRoute? route = ModalRoute.of(context);
      if (route?.isCurrent == true) {
        context.read<HomeScreenBloc>().add(HomeScreenGetAllHomeScreensEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localeIsEn = Localizations.localeOf(context).languageCode == 'en';
    return CustomScaffold(
      title: AppLocalizations.of(context)!.homeScreensService,
      subtitle: AppLocalizations.of(context)!.homeScreensServiceSubtitle,
      body: [
        BlocConsumer<HomeScreenBloc, HomeScreenState>(
          listener: (context, state) {
            if (state is HomeScreenFailure) {
              showSnackBar(context, state.error);
            }
          },
          builder: (context, state) {
            if (state is HomeScreenLoading) {
              return const Loader();
            }
            if (state is HomeScreenShowAllSuccess) {
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.start,
                children: List.generate(
                  state.homeScreenPage.services.length,
                  (index) {
                    final homeScreen = state.homeScreenPage.services[index];

                    return SizedBox(
                      width: 140,
                      child: AnimatedCardWrapper(
                        index: index,
                        child: CustomCardServiceList(
                          title: localeIsEn
                              ? homeScreen.serviceNameEn
                              : homeScreen.serviceNameAr,
                          subtitle: localeIsEn
                              ? homeScreen.serviceDescriptionEn
                              : homeScreen.serviceDescriptionAr,
                          icon: Icons.people_alt,
                          onTap: () {
                            context.push(
                              ServicesConstants
                                  .servicesRoutes[homeScreen.serviceId - 1],
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ],
    );
  }
}

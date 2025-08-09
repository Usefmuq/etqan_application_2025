import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/animated_card_wrapper.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_card_list_requests.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/utils/notifier.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/entities/onboarding_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const OnboardingPage(),
      );

  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  List<String>? permissions;
  _OnboardingPageState() : super();
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
    // context.read<OnboardingBloc>().add(OnboardingGetAllOnboardingsEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Re-fetch onboardings when this page becomes active again
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ModalRoute? route = ModalRoute.of(context);
      if (route?.isCurrent == true) {
        context.read<OnboardingBloc>().add(OnboardingGetAllOnboardingsEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: AppLocalizations.of(context)!.onboardingsService,
      subtitle: AppLocalizations.of(context)!.onboardingsServiceSubtitle,
      tilteActions: [
        if (isUserHasPermissionsView(
          permissions ?? [],
          PermissionsConstants.addOnboarding,
        ))
          IconButton(
            onPressed: () {
              context.push('/onboarding/submit/');
            },
            icon: Icon(Icons.add),
          ),
      ],
      body: [
        BlocConsumer<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            if (state is OnboardingFailure) {
              SmartNotifier.error(context,
                  title: AppLocalizations.of(context)!.error,
                  message: state.error);
            }
          },
          builder: (context, state) {
            if (state is OnboardingLoading ||
                !isUserHasPermissionsView(
                  permissions ?? [],
                  PermissionsConstants.viewOnboarding,
                )) {
              return const Loader();
            }
            if (state is OnboardingShowAllSuccess) {
              return Column(
                children: List.generate(
                    state.onboardingPage.onboardingsView.length, (index) {
                  final onboarding =
                      state.onboardingPage.onboardingsView[index];

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: AnimatedCardWrapper(
                      index: index,
                      child: CustomCardListRequests(
                        title:
                            '${AppLocalizations.of(context)!.employeeName}: ${onboarding.firstNameEn} ${onboarding.lastNameEn}',
                        subtitle:
                            '${AppLocalizations.of(context)!.position}: ${onboarding.positionNameEn}',
                        statusId: onboarding.requestStatusId,
                        requestDate: onboarding.createdAt,
                        onTap: () {
                          if (context.mounted) {
                            context.push(
                              '/onboarding/${onboarding.onboardingId}',
                              extra: OnboardingViewerPageEntity(
                                onboardingsView: onboarding,
                                approval: state.onboardingPage.approvalsView
                                    .where((a) =>
                                        a.requestId == onboarding.requestId)
                                    .toList(),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                }),
              );
            }

            return const SizedBox();
          },
        ),
      ],
    );
  }
}

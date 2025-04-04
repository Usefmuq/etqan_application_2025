import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_text_form_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/core/utils/show_snackbar.dart';
import 'package:etqan_application_2025/src/features/onboarding/data/models/onboarding_page_view_model.dart';
import 'package:etqan_application_2025/src/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UpdateOnboardingPage extends StatefulWidget {
  final OnboardingsPageViewModel onboarding;
  const UpdateOnboardingPage({super.key, required this.onboarding});
  static route(OnboardingsPageViewModel onboarding) => MaterialPageRoute(
        builder: (context) => UpdateOnboardingPage(
          onboarding: onboarding,
        ),
      );

  @override
  State<UpdateOnboardingPage> createState() => _UpdateOnboardingPageState();
}

class _UpdateOnboardingPageState extends State<UpdateOnboardingPage> {
  List<String>? permissions;

  late OnboardingsPageViewModel
      onboarding; // Declare a variable to hold the Onboarding object

  final TextEditingController firstNameEnControler = TextEditingController();
  final TextEditingController lastNameEnControler = TextEditingController();
  final TextEditingController firstNameArControler = TextEditingController();
  final TextEditingController lastNameArControler = TextEditingController();
  final TextEditingController emailControler = TextEditingController();
  final TextEditingController phoneControler = TextEditingController();
  final TextEditingController notesControler = TextEditingController();

  final formKey = GlobalKey<FormState>();

  void _updateOnboarding() {
    if (formKey.currentState!.validate()) {
      // final createdById =
      //     (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;
      context.read<OnboardingBloc>().add(
            OnboardingUpdateEvent(onboardingsPageViewModel: onboarding),
          );
    }
  }

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
    onboarding = widget.onboarding; // Assign the Onboarding object in initState
  }

  @override
  Widget build(BuildContext context) {
    firstNameEnControler.text = onboarding.firstNameEn;
    lastNameEnControler.text = onboarding.lastNameEn;
    firstNameArControler.text = onboarding.firstNameAr ?? '';
    lastNameArControler.text = onboarding.lastNameAr ?? '';
    emailControler.text = onboarding.email;
    phoneControler.text = onboarding.phone ?? '';
    notesControler.text = onboarding.notes ?? '';
    return CustomScaffold(
      title: 'Update Onboarding-${widget.onboarding.requestId}',
      showDrawer: false,
      tilteActions: [
        if (isUserHasPermissionsView(
          permissions ?? [],
          PermissionsConstants.updateOnboarding,
        ))
          IconButton(
            onPressed: () {
              _updateOnboarding();
            },
            icon: Icon(Icons.done_rounded),
          )
      ],
      body: [
        BlocConsumer<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            if (state is OnboardingFailure) {
              showSnackBar(context, state.error);
            } else if (state is OnboardingUpdateSuccess) {
              context.pop(
                  state.onboardingViewerPageEntity); // Go back and return data
            }
          },
          builder: (context, state) {
            if (state is OnboardingLoading ||
                !isUserHasPermissionsView(
                  permissions ?? [],
                  PermissionsConstants.updateOnboarding,
                )) {
              return const Loader();
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    CustomTextFormField(
                      controller: firstNameEnControler,
                      readOnly: false,
                      hintText: 'Employee first name English',
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomTextFormField(
                      controller: lastNameEnControler,
                      hintText: 'Employee last name English',
                      readOnly: false,
                    ),
                    CustomTextFormField(
                      controller: firstNameArControler,
                      readOnly: false,
                      hintText: 'Employee first name Arabic',
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomTextFormField(
                      controller: lastNameArControler,
                      hintText: 'Employee last name Arabic',
                      readOnly: false,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomTextFormField(
                      controller: emailControler,
                      hintText: 'Employee E-mail',
                      readOnly: false,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomTextFormField(
                      controller: phoneControler,
                      hintText: 'Employee Phone',
                      readOnly: false,
                    ),
                    CustomTextFormField(
                      controller: notesControler,
                      hintText: 'Onboarding Notes',
                      readOnly: false,
                      maxLines: null,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    firstNameEnControler.dispose();
    lastNameEnControler.dispose();
    firstNameArControler.dispose();
    lastNameArControler.dispose();
    emailControler.dispose();
    phoneControler.dispose();
    notesControler.dispose();
  }
}

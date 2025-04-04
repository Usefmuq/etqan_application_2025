import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_text_form_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/core/utils/show_snackbar.dart';
import 'package:etqan_application_2025/src/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AddNewOnboardingPage extends StatefulWidget {
  const AddNewOnboardingPage({super.key});
  static route() => MaterialPageRoute(
        builder: (context) => const AddNewOnboardingPage(),
      );
  @override
  State<AddNewOnboardingPage> createState() => _AddNewOnboardingPageState();
}

class _AddNewOnboardingPageState extends State<AddNewOnboardingPage> {
  List<String>? permissions;
  final TextEditingController firstNameEnControler = TextEditingController();
  final TextEditingController lastNameEnControler = TextEditingController();
  final TextEditingController firstNameArControler = TextEditingController();
  final TextEditingController lastNameArControler = TextEditingController();
  final TextEditingController emailControler = TextEditingController();
  final TextEditingController phoneControler = TextEditingController();
  final String departmentId = '';
  final String positionId = '';
  final String reportTo = '';
  final DateTime startDate = DateTime.now();
  final TextEditingController notesControler = TextEditingController();
  final formKey = GlobalKey<FormState>();
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
  }

  void _submitOnboarding() {
    if (formKey.currentState!.validate()) {
      final createdBy =
          (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;
      context.read<OnboardingBloc>().add(
            OnboardingSubmitEvent(
              firstNameEn: firstNameEnControler.text.trim(),
              lastNameEn: lastNameEnControler.text.trim(),
              firstNameAr: firstNameArControler.text.trim(),
              lastNameAr: lastNameArControler.text.trim(),
              email: emailControler.text.trim(),
              phone: phoneControler.text.trim(),
              departmentId: departmentId,
              positionId: positionId,
              reportTo: reportTo,
              startDate: startDate,
              createdBy: createdBy,
              notes: notesControler.text.trim(),
            ),
          );
    }
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

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Submit New Onboarding',
      showDrawer: false,
      tilteActions: [
        IconButton(
          onPressed: () {
            _submitOnboarding();
          },
          icon: Icon(Icons.done_rounded),
        )
      ],
      body: [
        BlocConsumer<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            if (state is OnboardingFailure) {
              showSnackBar(context, state.error);
            } else if (state is OnboardingSubmitSuccess) {
              context.pop(); // Go back and return data
            }
          },
          builder: (context, state) {
            if (state is OnboardingLoading ||
                !isUserHasPermissionsView(
                  permissions ?? [],
                  PermissionsConstants.addOnboarding,
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
}

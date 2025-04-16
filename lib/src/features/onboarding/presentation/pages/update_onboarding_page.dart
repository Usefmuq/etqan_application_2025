import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/entities/departments.dart';
import 'package:etqan_application_2025/src/core/common/entities/positions.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_dropdown_list.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_text_form_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:etqan_application_2025/src/core/utils/lookups_and_constants.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/core/utils/show_snackbar.dart';
import 'package:etqan_application_2025/src/features/auth/data/models/user_model.dart';
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
  List<Departments> departments = [];
  Departments? selectedDepartment;
  List<Positions> positions = [];
  Positions? selectedPosition;
  List<UserModel> managers = [];
  UserModel? selectedManager;

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
            OnboardingUpdateEvent(
                onboardingsPageViewModel: onboarding.copyWith(
              firstNameEn: firstNameEnControler.text.trim(),
              lastNameEn: lastNameEnControler.text.trim(),
              firstNameAr: firstNameArControler.text.trim(),
              lastNameAr: lastNameArControler.text.trim(),
              email: emailControler.text.trim(),
              phone: phoneControler.text.trim(),
              notes: notesControler.text.trim(),
              departmentId: selectedDepartment?.id,
              positionId: selectedPosition?.id,
              reportTo: selectedManager?.id,
              updatedAt: DateTime.now(),
            )),
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
      final fetchedDepartments = await fetchDepartments();
      final fetchedPositions = await fetchPositions(
        onboarding.departmentId ?? '',
      );
      final fetchedManagers = await fetchUsersByDepartment(
        onboarding.departmentId ?? '',
      );

      if (mounted) {
        setState(() {
          permissions = fetchedPermissions;
          departments = fetchedDepartments;
          positions = fetchedPositions;
          managers = fetchedManagers;
          selectedDepartment = departments.firstWhereOrNull(
            (a) => a.id == (onboarding.departmentId ?? ''),
          );
          selectedPosition = positions.firstWhereOrNull(
            (a) => a.id == (onboarding.positionId ?? ''),
          );
          selectedManager = managers.firstWhereOrNull(
            (a) => a.id == (onboarding.reportTo ?? ''),
          );
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            CustomTextFormField(
                              controller: firstNameEnControler,
                              hintText: 'First name (EN)',
                              readOnly: false,
                            ),
                            const SizedBox(height: 12),
                            CustomTextFormField(
                              controller: lastNameEnControler,
                              hintText: 'Last name (EN)',
                              readOnly: false,
                            ),
                            const SizedBox(height: 12),
                            CustomTextFormField(
                              controller: firstNameArControler,
                              hintText: 'First name (AR)',
                              readOnly: false,
                            ),
                            const SizedBox(height: 12),
                            CustomTextFormField(
                              controller: lastNameArControler,
                              hintText: 'Last name (AR)',
                              readOnly: false,
                            ),
                            const SizedBox(height: 12),
                            CustomTextFormField(
                              controller: emailControler,
                              hintText: 'Email',
                              readOnly: false,
                            ),
                            const SizedBox(height: 12),
                            CustomTextFormField(
                              controller: phoneControler,
                              hintText: 'Phone',
                              readOnly: false,
                            ),
                            const SizedBox(height: 12),
                            CustomTextFormField(
                              controller: notesControler,
                              hintText: 'Onboarding Notes',
                              readOnly: false,
                              maxLines: null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            CustomDropdownList<Departments>(
                              label: "Department",
                              hint: "Select department",
                              items: departments,
                              selectedItem: selectedDepartment,
                              onChanged: (value) async {
                                final deptId = value?.id;
                                final newPositions =
                                    await fetchPositions(deptId ?? '-1');
                                final newManagers =
                                    await fetchUsersByDepartment(
                                        deptId ?? '-1');

                                setState(() {
                                  selectedDepartment = value;
                                  // onboarding.departmentId = value?.id;
                                  positions = newPositions;
                                  managers = newManagers;
                                  selectedPosition = null;
                                  selectedManager = null;
                                });
                              },
                              getLabel: (dept) => dept.nameEn,
                              validator: (value) => value == null
                                  ? 'Please select a department'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            CustomDropdownList<Positions>(
                              label: "Position",
                              hint: "Select position",
                              items: positions,
                              selectedItem: selectedPosition,
                              onChanged: (value) {
                                setState(() {
                                  selectedPosition = value;
                                  // positionId = value?.id;
                                });
                              },
                              getLabel: (pos) => pos.nameEn,
                              validator: (value) => value == null
                                  ? 'Please select a position'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            CustomDropdownList<UserModel>(
                              label: "Manager",
                              hint: "Select manager",
                              items: managers,
                              selectedItem: selectedManager,
                              onChanged: (value) {
                                setState(() {
                                  selectedManager = value;
                                  // reportTo = value?.id;
                                });
                              },
                              getLabel: (usr) =>
                                  '${usr.firstNameEn} ${usr.lastNameEn}',
                              validator: (value) => value == null
                                  ? 'Please select a manager'
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 👇 Submit Button at the bottom
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _updateOnboarding,
                        icon: const Icon(Icons.send),
                        label: const Text("Update Onboarding"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
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

import 'package:dotted_border/dotted_border.dart';
import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_text_form_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
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
  final TextEditingController titleControler = TextEditingController();
  final TextEditingController contentControler = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<String> selectedTopics = [];
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
    if (formKey.currentState!.validate() && selectedTopics.isNotEmpty) {
      final createdById =
          (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;
      context.read<OnboardingBloc>().add(
            OnboardingSubmitEvent(
              createdById: createdById,
              title: titleControler.text.trim(),
              content: contentControler.text.trim(),
              topics: selectedTopics,
            ),
          );
    }
  }

  @override
  void dispose() {
    super.dispose();
    titleControler.dispose();
    contentControler.dispose();
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
                    DottedBorder(
                      color: AppPallete.borderColor,
                      dashPattern: const [
                        10,
                        4,
                      ],
                      radius: const Radius.circular(10),
                      borderType: BorderType.RRect,
                      strokeCap: StrokeCap.round,
                      child: SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 40,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              'Select your image',
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'Option 1',
                          'Option 2',
                          'Option 3',
                          'Option 4',
                          'Option 5',
                        ]
                            .map(
                              (_) => Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: GestureDetector(
                                  onTap: () {
                                    if (selectedTopics.contains(_)) {
                                      selectedTopics.remove(_);
                                    } else {
                                      selectedTopics.add(_);
                                    }
                                    setState(() {});
                                  },
                                  child: Chip(
                                    label: Text(
                                      _,
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    color: selectedTopics.contains(_)
                                        ? const WidgetStatePropertyAll(
                                            AppPallete.gradient1,
                                          )
                                        : null,
                                    side: selectedTopics.contains(_)
                                        ? null
                                        : const BorderSide(
                                            color: AppPallete.borderColor),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomTextFormField(
                      controller: titleControler,
                      readOnly: false,
                      hintText: 'Onboarding title',
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomTextFormField(
                      controller: contentControler,
                      hintText: 'Onboarding content',
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

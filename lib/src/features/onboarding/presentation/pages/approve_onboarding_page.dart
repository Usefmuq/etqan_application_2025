import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_button.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_text_form_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/core/utils/show_snackbar.dart';
import 'package:etqan_application_2025/src/features/onboarding/data/models/onboarding_page_view_model.dart';
import 'package:etqan_application_2025/src/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ApproveOnboardingPage extends StatefulWidget {
  final OnboardingsPageViewModel onboarding;
  final ApprovalSequenceViewModel approvalSequence;
  const ApproveOnboardingPage({
    super.key,
    required this.onboarding,
    required this.approvalSequence,
  });
  static route(
    OnboardingsPageViewModel onboarding,
    ApprovalSequenceViewModel approvalSequence,
  ) =>
      MaterialPageRoute(
        builder: (context) => ApproveOnboardingPage(
          onboarding: onboarding,
          approvalSequence: approvalSequence,
        ),
      );

  @override
  State<ApproveOnboardingPage> createState() => _ApproveOnboardingPageState();
}

class _ApproveOnboardingPageState extends State<ApproveOnboardingPage> {
  List<String>? permissions;

  late OnboardingsPageViewModel
      onboarding; // Declare a variable to hold the Onboarding object
  late ApprovalSequenceViewModel
      approvalSequence; // Declare a variable to hold the Onboarding object

  final TextEditingController titleControler = TextEditingController();
  final TextEditingController contentControler = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<String> selectedTopics = [];

  void _approveOnboarding({required bool isApproved}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isApproved ? 'Confirm Approval' : 'Confirm Rejection'),
        content: Text(isApproved
            ? 'Are you sure you want to approve this onboarding?'
            : 'Are you sure you want to reject this onboarding?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes')),
        ],
      ),
    );
    if (!mounted) return; // ✅ Prevent using context if widget is disposed

    if (confirmed != true) return;

    if (formKey.currentState!.validate() && selectedTopics.isNotEmpty) {
      final updatedApproval = widget.approvalSequence.copyWith(
        approvalStatus: isApproved
            ? LookupConstants.approvalStatusApprovalApproved
            : LookupConstants.approvalStatusApprovalRejected,
        approverComment: commentController.text,
      );

      context.read<OnboardingBloc>().add(
            OnboardingApproveEvent(
              approvalSequence: updatedApproval,
              onboardingModel: onboarding,
            ),
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
    selectedTopics = onboarding.topics ?? [];
    titleControler.text = onboarding.title ?? "";
    contentControler.text = onboarding.content ?? "";

    return CustomScaffold(
      title: 'Approve Onboarding-${widget.onboarding.requestId}',
      showDrawer: false,
      tilteActions: [
        // if (isUserHasPermissionsView(
        //   permissions ?? [],
        //   PermissionsConstants.approveOnboarding,
        // ))
        //   IconButton(
        //     onPressed: _approveOnboarding,
        //     icon: const Icon(Icons.done_rounded),
        //   )
      ],
      body: [
        BlocConsumer<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            if (state is OnboardingFailure) {
              showSnackBar(context, state.error);
            } else if (state is OnboardingApproveSuccess) {
              context.pop(
                  state.onboardingViewerPageEntity); // Go back and return data
            }
          },
          builder: (context, state) {
            if (state is OnboardingLoading ||
                !isUserHasPermissionsView(
                  permissions ?? [],
                  PermissionsConstants.approveOnboarding,
                )) {
              return const Loader();
            }

            return Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selected Topics",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Option 1',
                      'Option 2',
                      'Option 3',
                      'Option 4',
                      'Option 5',
                    ].map((option) {
                      final selected = selectedTopics.contains(option);
                      return GestureDetector(
                        onTap: () {},
                        child: Chip(
                          label: Text(option),
                          backgroundColor: selected
                              ? AppPallete.gradient1
                                  .withAlpha((0.1 * 255).toInt())
                              : null,
                          labelStyle: TextStyle(
                            color: selected
                                ? AppPallete.gradient1
                                : AppPallete.textPrimary,
                            fontWeight:
                                selected ? FontWeight.bold : FontWeight.normal,
                          ),
                          side: selected
                              ? BorderSide(color: AppPallete.gradient1)
                              : const BorderSide(color: AppPallete.borderColor),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Onboarding Title",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    controller: titleControler,
                    hintText: 'Onboarding title',
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Onboarding Content",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    controller: contentControler,
                    hintText: 'Onboarding content',
                    maxLines: null,
                    readOnly: true,
                  ),
                  const SizedBox(height: 30),
                  CustomTextFormField(
                    controller: commentController,
                    hintText: 'Approval comment',
                    maxLines: null,
                    readOnly: false,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Approve',
                          icon: Icons.check_circle_outline,
                          onPressed: () {
                            _approveOnboarding(isApproved: true);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Reject',
                          icon: Icons.cancel_outlined,
                          backgroundColor: AppPallete.errorColor,
                          onPressed: () {
                            _approveOnboarding(isApproved: false);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
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
    titleControler.dispose();
    contentControler.dispose();
    commentController.dispose();
  }
}

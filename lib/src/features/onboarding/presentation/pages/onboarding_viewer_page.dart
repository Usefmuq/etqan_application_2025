import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_key_value_grid.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_section_title.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_button.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_text_form_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/grids/custom_table_grid.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:etqan_application_2025/src/core/utils/notifier.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/features/onboarding/domain/entities/onboarding_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OnboardingViewerPage extends StatefulWidget {
  static route(OnboardingViewerPageEntity onboardingViewerPage) =>
      MaterialPageRoute(
        builder: (context) => OnboardingViewerPage(
          onboardingViewerPage: onboardingViewerPage,
        ),
      );

  final OnboardingViewerPageEntity onboardingViewerPage;
  const OnboardingViewerPage({super.key, required this.onboardingViewerPage});

  @override
  State<OnboardingViewerPage> createState() => _OnboardingViewerPageState();
}

class _OnboardingViewerPageState extends State<OnboardingViewerPage> {
  List<String>? permissions;
  ApprovalSequenceViewModel? pendingApproval;
  final TextEditingController commentController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final userId =
        (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;

    Future.microtask(() async {
      final fetchedPermissions = await fetchUserPermissions(userId);

      final fetchPendingApproval = await widget.onboardingViewerPage.approval!
          .firstWhereOrNullAsync((a) async {
        return a.approvalStatus?.toLowerCase() ==
                LookupConstants.approvalStatusApprovalPending &&
            (a.approverUserId == userId ||
                await isUserHasRole(
                  userId,
                  a.roleId ?? '',
                ));
      });
      if (mounted) {
        setState(() {
          permissions = fetchedPermissions;
          pendingApproval = fetchPendingApproval;
        });
      }
    });
  }

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

    if (!isUserHasPermissionsView(
          permissions ?? [],
          PermissionsConstants.approveOnboarding,
        ) &&
        pendingApproval.isNullOrEmpty) {
      return;
    }
    if (confirmed != true) return;

    final userId =
        (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;
    if (formKey.currentState!.validate()) {
      final updatedApproval = pendingApproval!.copyWith(
        approvalStatus: isApproved
            ? LookupConstants.approvalStatusApprovalApproved
            : LookupConstants.approvalStatusApprovalRejected,
        approverComment: commentController.text,
        approvedBy: userId,
      );

      context.read<OnboardingBloc>().add(
            OnboardingApproveEvent(
              approvalSequence: updatedApproval,
              onboardingModel: widget.onboardingViewerPage.onboardingsView,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title:
          'Onboarding- ${widget.onboardingViewerPage.onboardingsView.requestId}',
      tilteActions: [
        if (isUserHasPermissionsView(
          permissions ?? [],
          PermissionsConstants.updateOnboarding,
        ))
          IconButton(
            onPressed: () {
              context.push(
                '/onboarding/update/${widget.onboardingViewerPage.onboardingsView.onboardingId}',
                extra: widget.onboardingViewerPage.onboardingsView,
              );
            },
            icon: Icon(Icons.edit),
          ),
        // if (isUserHasPermissionsView(
        //       permissions ?? [],
        //       PermissionsConstants.approveOnboarding,
        //     ) &&
        //     !pendingApproval.isNullOrEmpty)
        //   IconButton(
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         ApproveOnboardingPage.route(
        //           widget.onboardingViewerPage.onboardingsView,
        //           pendingApproval!,
        //         ),
        //       );
        //     },
        //     icon: Icon(Icons.check),
        //   ),
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
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSectionTitle(
                      title: AppLocalizations.of(context)!.onboardingDetails,
                    ),
                    CustomKeyValueGrid(
                      data: {
                        AppLocalizations.of(context)!.employeeNameEn:
                            '${widget.onboardingViewerPage.onboardingsView.firstNameEn} ${widget.onboardingViewerPage.onboardingsView.lastNameEn}',
                        AppLocalizations.of(context)!.requestId:
                            "${AppLocalizations.of(context)!.onboarding}-${widget.onboardingViewerPage.onboardingsView.requestId}",
                        AppLocalizations.of(context)!.employeeNameAr:
                            '${widget.onboardingViewerPage.onboardingsView.firstNameAr} ${widget.onboardingViewerPage.onboardingsView.lastNameAr}',
                        AppLocalizations.of(context)!.status: widget
                            .onboardingViewerPage
                            .onboardingsView
                            .requestStatusId,
                        AppLocalizations.of(context)!.department: widget
                            .onboardingViewerPage
                            .onboardingsView
                            .departmentNameEn,
                        AppLocalizations.of(context)!.createdBy: widget
                            .onboardingViewerPage
                            .onboardingsView
                            .createdByNameEn,
                        AppLocalizations.of(context)!.position: widget
                            .onboardingViewerPage
                            .onboardingsView
                            .positionNameEn,
                        AppLocalizations.of(context)!.notes:
                            widget.onboardingViewerPage.onboardingsView.notes,
                        AppLocalizations.of(context)!.createdAt:
                            DateFormat.yMMMd().add_jm().format(widget
                                .onboardingViewerPage
                                .onboardingsView
                                .createdAt!),
                        AppLocalizations.of(context)!.updatedAt: widget
                            .onboardingViewerPage.onboardingsView.updatedAt,
                        // 'Approved At': widget.onboardingViewerPage
                        //             .onboardingsView.requestApprovedAt !=
                        //         null
                        //     ? DateFormat.yMMMd().add_jm().format(widget
                        //         .onboardingViewerPage
                        //         .onboardingsView
                        //         .requestApprovedAt!)
                        //     : "Not yet",
                      },
                    ),
                    const Divider(),
                    const SizedBox(height: 12),
                    CustomSectionTitle(
                      title: AppLocalizations.of(context)!.approvalSequence,
                    ),
                    CustomTableGrid(
                      headers: [
                        AppLocalizations.of(context)!.approvalId,
                        AppLocalizations.of(context)!.requestId,
                        AppLocalizations.of(context)!.approvalStatus,
                        AppLocalizations.of(context)!.approverName,
                        AppLocalizations.of(context)!.roleName,
                        AppLocalizations.of(context)!.approvedAt,
                        AppLocalizations.of(context)!.createdAt,
                      ],
                      rows: widget.onboardingViewerPage.approval!
                          .map((e) => e.toTableRow())
                          .toList(),
                      useChipsForStatus: true,
                    ),
                    const SizedBox(height: 30),
                    if (isUserHasPermissionsView(
                          permissions ?? [],
                          PermissionsConstants.approveOnboarding,
                        ) &&
                        !pendingApproval.isNullOrEmpty)
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            CustomTextFormField(
                              controller: commentController,
                              hintText: 'Approval comment',
                              maxLines: null,
                              readOnly: false,
                            ),
                            const SizedBox(height: 20),
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
    commentController.dispose();
  }
}

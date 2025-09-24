import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_button.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_text_form_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:etqan_application_2025/src/core/utils/notifier.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/features/usersManager/data/models/users_manager_page_view_model.dart';
import 'package:etqan_application_2025/src/features/usersManager/presentation/bloc/users_manager_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ApproveUsersManagerPage extends StatefulWidget {
  final UsersManagerPageViewModel usersManager;
  final ApprovalSequenceViewModel approvalSequence;
  const ApproveUsersManagerPage({
    super.key,
    required this.usersManager,
    required this.approvalSequence,
  });
  static route(
    UsersManagerPageViewModel usersManager,
    ApprovalSequenceViewModel approvalSequence,
  ) =>
      MaterialPageRoute(
        builder: (context) => ApproveUsersManagerPage(
          usersManager: usersManager,
          approvalSequence: approvalSequence,
        ),
      );

  @override
  State<ApproveUsersManagerPage> createState() =>
      _ApproveUsersManagerPageState();
}

class _ApproveUsersManagerPageState extends State<ApproveUsersManagerPage> {
  List<String>? permissions;

  late UsersManagerPageViewModel
      usersManager; // Declare a variable to hold the UsersManager object
  late ApprovalSequenceViewModel
      approvalSequence; // Declare a variable to hold the UsersManager object

  final TextEditingController titleControler = TextEditingController();
  final TextEditingController contentControler = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<String> selectedTopics = [];

  void _approveUsersManager({required bool isApproved}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isApproved ? 'Confirm Approval' : 'Confirm Rejection'),
        content: Text(isApproved
            ? 'Are you sure you want to approve this usersManager?'
            : 'Are you sure you want to reject this usersManager?'),
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

      context.read<UsersManagerBloc>().add(
            UsersManagerApproveEvent(
              approvalSequence: updatedApproval,
              usersManagerModel: usersManager,
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
    usersManager =
        widget.usersManager; // Assign the UsersManager object in initState
  }

  @override
  Widget build(BuildContext context) {
    // selectedTopics = usersManager.topics ?? [];
    // titleControler.text = usersManager.title ?? "";
    // contentControler.text = usersManager.content ?? "";

    return CustomScaffold(
      // title: 'Approve UsersManager-${widget.usersManager.requestId}',
      title: 'Approve UsersManager-widget.usersManager.requestId}',
      showDrawer: false,
      tilteActions: [
        // if (isUserHasPermissionsView(
        //   permissions ?? [],
        //   PermissionsConstants.approveUsersManager,
        // ))
        //   IconButton(
        //     onPressed: _approveUsersManager,
        //     icon: const Icon(Icons.done_rounded),
        //   )
      ],
      body: [
        BlocConsumer<UsersManagerBloc, UsersManagerState>(
          listener: (context, state) {
            if (state is UsersManagerFailure) {
              SmartNotifier.error(context,
                  title: AppLocalizations.of(context)!.error,
                  message: state.error);
            } else if (state is UsersManagerApproveSuccess) {
              context.pop(state
                  .usersManagerViewerPageEntity); // Go back and return data
            }
          },
          builder: (context, state) {
            if (state is UsersManagerLoading ||
                !isUserHasPermissionsView(
                  permissions ?? [],
                  PermissionsConstants.approveUsersManager,
                )) {
              return const Loader();
            }

            return Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.selectedTopics,
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
                  Text(
                    AppLocalizations.of(context)!.usersManagerTitle,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    controller: titleControler,
                    hintText: AppLocalizations.of(context)!.usersManagerTitle,
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.usersManagerContent,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    controller: contentControler,
                    hintText: AppLocalizations.of(context)!.usersManagerContent,
                    maxLines: null,
                    readOnly: true,
                  ),
                  const SizedBox(height: 30),
                  CustomTextFormField(
                    controller: commentController,
                    hintText: AppLocalizations.of(context)!.approvalComment,
                    maxLines: null,
                    readOnly: false,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: AppLocalizations.of(context)!.approve,
                          icon: Icons.check_circle_outline,
                          onPressed: () {
                            _approveUsersManager(isApproved: true);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: AppLocalizations.of(context)!.reject,
                          icon: Icons.cancel_outlined,
                          backgroundColor: AppPallete.errorColor,
                          onPressed: () {
                            _approveUsersManager(isApproved: false);
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

import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_button.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_text_form_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/core/utils/show_snackbar.dart';
import 'package:etqan_application_2025/src/features/blog/data/models/blog_page_view_model.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/pages/blog_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ApproveBlogPage extends StatefulWidget {
  final BlogsPageViewModel blog;
  final ApprovalSequenceViewModel approvalSequence;
  const ApproveBlogPage({
    super.key,
    required this.blog,
    required this.approvalSequence,
  });
  static route(
    BlogsPageViewModel blog,
    ApprovalSequenceViewModel approvalSequence,
  ) =>
      MaterialPageRoute(
        builder: (context) => ApproveBlogPage(
          blog: blog,
          approvalSequence: approvalSequence,
        ),
      );

  @override
  State<ApproveBlogPage> createState() => _ApproveBlogPageState();
}

class _ApproveBlogPageState extends State<ApproveBlogPage> {
  List<String>? permissions;

  late BlogsPageViewModel blog; // Declare a variable to hold the Blog object
  late ApprovalSequenceViewModel
      approvalSequence; // Declare a variable to hold the Blog object

  final TextEditingController titleControler = TextEditingController();
  final TextEditingController contentControler = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<String> selectedTopics = [];

  void _approveBlog({required bool isApproved}) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isApproved ? 'Confirm Approval' : 'Confirm Rejection'),
        content: Text(isApproved
            ? 'Are you sure you want to approve this blog?'
            : 'Are you sure you want to reject this blog?'),
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

      context.read<BlogBloc>().add(
            BlogApproveEvent(
              approvalSequence: updatedApproval,
              blogModel: blog,
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
    blog = widget.blog; // Assign the Blog object in initState
  }

  @override
  Widget build(BuildContext context) {
    selectedTopics = blog.topics ?? [];
    titleControler.text = blog.title ?? "";
    contentControler.text = blog.content ?? "";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Approve Blog"),
        actions: [
          // if (isUserHasPermissionsView(
          //   permissions ?? [],
          //   PermissionsConstants.approveBlog,
          // ))
          //   IconButton(
          //     onPressed: _approveBlog,
          //     icon: const Icon(Icons.done_rounded),
          //   )
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackBar(context, state.error);
          } else if (state is BlogApproveSuccess) {
            context.pop(state.blogViewerPageEntity); // Go back and return data
          }
        },
        builder: (context, state) {
          if (state is BlogLoading ||
              !isUserHasPermissionsView(
                permissions ?? [],
                PermissionsConstants.approveBlog,
              )) {
            return const Loader();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
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
                    "Blog Title",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    controller: titleControler,
                    hintText: 'Blog title',
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Blog Content",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  CustomTextFormField(
                    controller: contentControler,
                    hintText: 'Blog content',
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
                            _approveBlog(isApproved: true);
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
                            _approveBlog(isApproved: false);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
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

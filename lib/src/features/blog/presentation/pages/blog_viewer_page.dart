import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_key_value_grid.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_section_title.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_button.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_text_form_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/grids/custom_table_grid.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/core/utils/show_snackbar.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BlogViewerPage extends StatefulWidget {
  static route(BlogViewerPageEntity blogViewerPage) => MaterialPageRoute(
        builder: (context) => BlogViewerPage(
          blogViewerPage: blogViewerPage,
        ),
      );

  final BlogViewerPageEntity blogViewerPage;
  const BlogViewerPage({super.key, required this.blogViewerPage});

  @override
  State<BlogViewerPage> createState() => _BlogViewerPageState();
}

class _BlogViewerPageState extends State<BlogViewerPage> {
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

      final fetchPendingApproval = await widget.blogViewerPage.approval!
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

    if (!isUserHasPermissionsView(
          permissions ?? [],
          PermissionsConstants.approveBlog,
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

      context.read<BlogBloc>().add(
            BlogApproveEvent(
              approvalSequence: updatedApproval,
              blogModel: widget.blogViewerPage.blogsView,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (isUserHasPermissionsView(
                permissions ?? [],
                PermissionsConstants.updateBlog,
              ) &&
              widget.blogViewerPage.blogsView.toBlog() != null)
            IconButton(
              onPressed: () {
                context.push(
                  '/blog/update/${widget.blogViewerPage.blogsView.blogId}',
                  extra: widget.blogViewerPage.blogsView.toBlog()!,
                );
              },
              icon: Icon(Icons.edit),
            ),
          // if (isUserHasPermissionsView(
          //       permissions ?? [],
          //       PermissionsConstants.approveBlog,
          //     ) &&
          //     !pendingApproval.isNullOrEmpty)
          //   IconButton(
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         ApproveBlogPage.route(
          //           widget.blogViewerPage.blogsView,
          //           pendingApproval!,
          //         ),
          //       );
          //     },
          //     icon: Icon(Icons.check),
          //   ),
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackBar(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is BlogLoading ||
              !isUserHasPermissionsView(
                permissions ?? [],
                PermissionsConstants.viewBlog,
              )) {
            return const Loader();
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSectionTitle(
                      title: "Blog details",
                      trailing: IconButton(
                        icon: Icon(Icons.info),
                        onPressed: () {},
                      ),
                    ),
                    CustomKeyValueGrid(
                      data: {
                        'Title': widget.blogViewerPage.blogsView.title,
                        'Request ID':
                            "blog-${widget.blogViewerPage.blogsView.requestId}",
                        'Status':
                            widget.blogViewerPage.blogsView.requestStatusId,
                        'Topics':
                            widget.blogViewerPage.blogsView.topics!.join(', '),
                        'Created By Ar':
                            widget.blogViewerPage.blogsView.fullNameAr,
                        'Priority': widget.blogViewerPage.blogsView.priorityId,
                        'Request Details':
                            widget.blogViewerPage.blogsView.requestDetails,
                        'Created At': DateFormat.yMMMd().add_jm().format(
                            widget.blogViewerPage.blogsView.requestCreatedAt!),
                        'Updated':
                            widget.blogViewerPage.blogsView.blogUpdatedAt,
                        'Approved At':
                            widget.blogViewerPage.blogsView.requestApprovedAt !=
                                    null
                                ? DateFormat.yMMMd().add_jm().format(widget
                                    .blogViewerPage
                                    .blogsView
                                    .requestApprovedAt!)
                                : "Not yet",
                      },
                    ),
                    const Divider(),
                    const SizedBox(height: 12),
                    CustomSectionTitle(
                      title: "Approval Sequence",
                    ),
                    CustomTableGrid(
                      headers: [
                        'Approval ID',
                        'Request ID',
                        'Approval Status EN',
                        'Approver Name EN',
                        'Role Name EN',
                        'Approved At',
                        'Created At',
                        'Request User Name EN',
                        'Service Name EN',
                      ],
                      rows: widget.blogViewerPage.approval!
                          .map((e) => e.toTableRow())
                          .toList(),
                      useChipsForStatus: true,
                    ),
                    const SizedBox(height: 30),
                    if (isUserHasPermissionsView(
                          permissions ?? [],
                          PermissionsConstants.approveBlog,
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
                  ],
                ),
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
    commentController.dispose();
  }
}

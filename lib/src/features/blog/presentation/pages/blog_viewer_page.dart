import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_key_value_grid.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_section_title.dart';
import 'package:etqan_application_2025/src/core/common/widgets/grids/custom_table_grid.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/features/blog/data/models/blog_page_view_model.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/pages/approve_blog_page.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/pages/update_blog_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (isUserHasPermissionsView(
            permissions ?? [],
            PermissionsConstants.updateBlog,
          ))
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  UpdateBlogPage.route(
                    (widget.blogViewerPage.blogsView as BlogsPageViewModel)
                        .toBlog()!,
                  ),
                );
              },
              icon: Icon(Icons.edit),
            ),
          if (isUserHasPermissionsView(
                permissions ?? [],
                PermissionsConstants.approveBlog,
              ) &&
              !pendingApproval.isNullOrEmpty)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  ApproveBlogPage.route(
                    (widget.blogViewerPage.blogsView as BlogsPageViewModel)
                        .toBlog()!,
                    (pendingApproval as ApprovalSequenceViewModel)
                        .toApprovalSequence(),
                  ),
                );
              },
              icon: Icon(Icons.check),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    'Status': widget.blogViewerPage.blogsView.requestStatusId,
                    'Topics':
                        widget.blogViewerPage.blogsView.topics!.join(', '),
                    'Created By Ar': widget.blogViewerPage.blogsView.fullNameAr,
                    'Priority': widget.blogViewerPage.blogsView.priorityId,
                    'Request Details':
                        widget.blogViewerPage.blogsView.requestDetails,
                    'Created At': DateFormat.yMMMd().add_jm().format(
                        widget.blogViewerPage.blogsView.requestCreatedAt!),
                    'Updated': widget.blogViewerPage.blogsView.blogUpdatedAt,
                    'Approved At': widget
                                .blogViewerPage.blogsView.requestApprovedAt !=
                            null
                        ? DateFormat.yMMMd().add_jm().format(
                            widget.blogViewerPage.blogsView.requestApprovedAt!)
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
                CustomTableGrid(
                  headers: [
                    'Approver ID',
                    'Role ID',
                    'Status',
                    'Comment',
                    'Approved At',
                    'Order',
                    'Created At',
                  ],
                  rows: (widget.blogViewerPage.approval
                          as List<ApprovalSequenceViewModel>)
                      .map((e) => e.toTableRow())
                      .toList(),
                  // onEdit: (row) {
                  //   print('✏️ Edit row for approver: ${row['Approver ID']}');
                  // },
                  // onApprove: (row) {
                  //   print('✅ Approve row: ${row['Approver ID']}');
                  // },
                  // onDelete: (row) {
                  //   print('🗑 Delete row for role: ${row['Role ID']}');
                  // },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

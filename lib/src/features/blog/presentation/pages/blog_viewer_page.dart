import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/entities/approval_sequence.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_key_value_grid.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_section_title.dart';
import 'package:etqan_application_2025/src/core/common/widgets/grids/custom_table_grid.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/utils/approval_sequence_utils.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
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
  ApprovalSequence? pendingApproval;
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
                  UpdateBlogPage.route(widget.blogViewerPage.blog),
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
                      widget.blogViewerPage.blog, pendingApproval!),
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
                    'Title': widget.blogViewerPage.blog.title,
                    'Status': widget.blogViewerPage.blog.status,
                    'Topics': widget.blogViewerPage.blog.topics.join(', '),
                    'Active': widget.blogViewerPage.blog.isActive,
                    'Updated': widget.blogViewerPage.blog.updatedAt,
                    'Created By': widget.blogViewerPage.blog.createdByName,
                  },
                ),
                const Divider(),
                CustomSectionTitle(
                  title: "Request Info",
                  trailing: IconButton(
                    icon: Icon(Icons.info),
                    onPressed: () {},
                  ),
                ),
                CustomKeyValueGrid(
                  data: {
                    'Request ID': widget.blogViewerPage.request!.requestId,
                    'Service ID': widget.blogViewerPage.request!.serviceId,
                    'Status': widget.blogViewerPage.request!.status ?? '—',
                    'Priority': widget.blogViewerPage.request!.priority ?? '—',
                    'Details':
                        widget.blogViewerPage.request!.requestDetails ?? '—',
                    'Is Active':
                        widget.blogViewerPage.request!.isActive ? 'Yes' : 'No',
                    'Created At': DateFormat.yMMMd()
                        .add_jm()
                        .format(widget.blogViewerPage.request!.createdAt),
                    'Updated At': DateFormat.yMMMd()
                        .add_jm()
                        .format(widget.blogViewerPage.request!.updatedAt),
                    'Approved At': widget.blogViewerPage.request!.approvedAt !=
                            null
                        ? DateFormat.yMMMd()
                            .add_jm()
                            .format(widget.blogViewerPage.request!.approvedAt!)
                        : "Not yet",
                  },
                ),
                const SizedBox(height: 12),
                CustomSectionTitle(
                  title: "Approval Sequence",
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
                  rows: widget.blogViewerPage.approval!
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

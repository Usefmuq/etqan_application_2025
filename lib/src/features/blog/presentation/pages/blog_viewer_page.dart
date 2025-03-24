import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/entities/approval_sequence.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_section_title.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 4.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildKeyValue(String label, String value) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(value),
    );
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
                _buildKeyValue("Title", widget.blogViewerPage.blog.title),
                _buildKeyValue("Content", widget.blogViewerPage.blog.content),
                _buildKeyValue("Status", widget.blogViewerPage.blog.status),
                _buildKeyValue("Active",
                    widget.blogViewerPage.blog.isActive ? "Yes" : "No"),
                _buildKeyValue(
                    "Updated At",
                    DateFormat.yMMMd()
                        .add_jm()
                        .format(widget.blogViewerPage.blog.updatedAt)),
                _buildKeyValue(
                    "Topics", widget.blogViewerPage.blog.topics.join(', ')),
                if (widget.blogViewerPage.blog.createdByName != null)
                  _buildKeyValue(
                      "Author", widget.blogViewerPage.blog.createdByName!),
                const Divider(),
                _buildSectionTitle("Request Info"),
                _buildKeyValue(
                    "Request ID",
                    widget.blogViewerPage.request!.requestId?.toString() ??
                        "N/A"),
                _buildKeyValue("Status",
                    widget.blogViewerPage.request!.status ?? "Unknown"),
                _buildKeyValue("Priority",
                    widget.blogViewerPage.request!.priority ?? "None"),
                _buildKeyValue("Details",
                    widget.blogViewerPage.request!.requestDetails ?? "N/A"),
                _buildKeyValue(
                    "Created At",
                    DateFormat.yMMMd()
                        .add_jm()
                        .format(widget.blogViewerPage.request!.createdAt)),
                _buildKeyValue(
                    "Updated At",
                    DateFormat.yMMMd()
                        .add_jm()
                        .format(widget.blogViewerPage.request!.updatedAt)),
                _buildKeyValue(
                    "Approved At",
                    widget.blogViewerPage.request!.approvedAt != null
                        ? DateFormat.yMMMd()
                            .add_jm()
                            .format(widget.blogViewerPage.request!.approvedAt!)
                        : "Not yet"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

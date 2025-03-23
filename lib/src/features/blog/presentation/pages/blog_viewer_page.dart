import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/entities/approval_sequence.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/core/utils/show_snackbar.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/pages/approve_blog_page.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/pages/update_blog_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          return Column(
            children: [
              Text(widget.blogViewerPage.blog.title),
              Text(widget.blogViewerPage.blog.content),
              Text(widget.blogViewerPage.blog.createdByName ?? ''),
              Text(
                  "approvalStatus ${widget.blogViewerPage.approval!.first.approvalStatus ?? ''}"),
              Text(
                  "requestId ${widget.blogViewerPage.request!.requestId ?? ''}"),
            ],
          );
        },
      ),
    );
  }
}

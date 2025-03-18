import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/no_permissions.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/pages/update_blog_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogViewerPage extends StatefulWidget {
  static route(Blog blog) => MaterialPageRoute(
        builder: (context) => BlogViewerPage(
          blog: blog,
        ),
      );

  final Blog blog;
  const BlogViewerPage({super.key, required this.blog});

  @override
  State<BlogViewerPage> createState() => _BlogViewerPageState();
}

class _BlogViewerPageState extends State<BlogViewerPage> {
  List<String>? permissions;
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

  @override
  Widget build(BuildContext context) {
    if (!isUserHasPermissionsView(
        permissions ?? [], PermissionsConstants.viewBlog)) {
      return NoPermissions();
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (isUserHasPermissionsView(
              permissions ?? [], PermissionsConstants.updateBlog))
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  UpdateBlogPage.route(widget.blog),
                );
              },
              icon: Icon(Icons.edit),
            ),
        ],
      ),
      body: Column(
        children: [
          Text(widget.blog.title),
          Text(widget.blog.content),
          Text(widget.blog.createdByName ?? ''),
        ],
      ),
    );
  }
}

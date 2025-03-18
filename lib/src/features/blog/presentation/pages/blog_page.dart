import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_card_with_chips.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/usecase/get_user_permissions.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/core/utils/show_snackbar.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/pages/add_new_blog_page.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/pages/blog_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const BlogPage(),
      );

  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  late GetUserPermissions getUserPermissions; // ✅ Declare the use case
  late List<String>? permissions;
  _BlogPageState() : super();
  @override
  void initState() {
    super.initState();
    // ✅ Load permissions when the page initializes
    final userId =
        (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;
    // ✅ Get `GetUserPermissions` instance from service locator
    getUserPermissions = context.read<GetUserPermissions>();

    // ✅ Call the use case asynchronously
    _fetchUserPermissions(userId).then((result) {
      permissions = result ?? [];
    }).catchError((error) {
      permissions = [];
    });

    context.read<BlogBloc>().add(BlogGetAllBlogsEvent());
  }

  Future<List<String>?> _fetchUserPermissions(String userId) async {
    final response =
        await getUserPermissions.call(GetUserPermissionsParams(userId: userId));

    return response.fold((failure) {
      return [];
    }, (permissionsList) {
      final perms = permissionsList.map((p) => p.permissionKey).toList();
      return perms;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                AddNewBlogPage.route(),
              );
            },
            icon: Icon(Icons.add),
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
          if (state is BlogLoading) {
            return const Loader();
          }
          if (state is BlogShowAllSuccess) {
            if (!isUserHasPermissionsView(
                permissions ?? [], PermissionsConstants.viewBlog)) {
              return Scaffold(
                body: const Center(
                  child: Text('No Permissions'),
                ),
              );
            }
            return ListView.builder(
              itemCount: state.blogs.length,
              itemBuilder: (context, index) {
                final blog = state.blogs[index];
                return CustomCardWithChips(
                  chips: blog.topics,
                  title: blog.title,
                  onTap: () {
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        BlogViewerPage.route(blog),
                      );
                    }
                  },
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

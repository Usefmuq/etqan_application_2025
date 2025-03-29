import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/animated_card_wrapper.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_card_with_chips.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/core/utils/show_snackbar.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_viewer_page_entity.dart';
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
  List<String>? permissions;
  _BlogPageState() : super();
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
    context.read<BlogBloc>().add(BlogGetAllBlogsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
        actions: [
          if (isUserHasPermissionsView(
            permissions ?? [],
            PermissionsConstants.addBlog,
          ))
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
          if (state is BlogLoading ||
              !isUserHasPermissionsView(
                permissions ?? [],
                PermissionsConstants.viewBlog,
              )) {
            return const Loader();
          }
          if (state is BlogShowAllSuccess) {
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.blogPage.blogsView.length,
              itemBuilder: (context, index) {
                final blog = state.blogPage.blogsView[index];

                return AnimatedCardWrapper(
                  index: index, // 👈 fade/slide stagger delay
                  child: CustomCardWithChips(
                    chips: blog.topics!,
                    title: blog.title!,
                    onTap: () {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          BlogViewerPage.route(
                            BlogViewerPageEntity(
                              blogsView: blog,
                              approval: state.blogPage.approvalsView
                                  .where((a) => a.requestId == blog.requestId)
                                  .toList(),
                            ),
                          ),
                        );
                      }
                    },
                  ),
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

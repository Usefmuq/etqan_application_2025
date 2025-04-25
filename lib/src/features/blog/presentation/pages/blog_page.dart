import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/animated_card_wrapper.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_card_list_requests.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/core/utils/show_snackbar.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    // context.read<BlogBloc>().add(BlogGetAllBlogsEvent());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Re-fetch blogs when this page becomes active again
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ModalRoute? route = ModalRoute.of(context);
      if (route?.isCurrent == true) {
        context.read<BlogBloc>().add(BlogGetAllBlogsEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: AppLocalizations.of(context)!.blogsService,
      subtitle: AppLocalizations.of(context)!.blogsServiceSubtitle,
      tilteActions: [
        if (isUserHasPermissionsView(
          permissions ?? [],
          PermissionsConstants.addBlog,
        ))
          IconButton(
            onPressed: () {
              context.push('/blog/submit/');
            },
            icon: Icon(Icons.add),
          ),
      ],
      body: [
        BlocConsumer<BlogBloc, BlogState>(
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
              return Column(
                children:
                    List.generate(state.blogPage.blogsView.length, (index) {
                  final blog = state.blogPage.blogsView[index];

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: AnimatedCardWrapper(
                        index: index,
                        child: CustomCardListRequests(
                          chips: blog.topics ?? [],
                          title: blog.title ?? '',
                          statusId: blog.requestStatusId, // Optional
                          requestDate: blog.requestCreatedAt,

                          subtitle: blog.content, // Optional
                          onTap: () {
                            context.push(
                              '/blog/${blog.blogId}',
                              extra: BlogViewerPageEntity(
                                blogsView: blog,
                                approval: state.blogPage.approvalsView
                                    .where((a) => a.requestId == blog.requestId)
                                    .toList(),
                              ),
                            );
                          },
                        )),
                  );
                }),
              );
            }

            return const SizedBox();
          },
        ),
      ],
    );
  }
}

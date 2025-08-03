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

class _BlogPageState extends State<BlogPage>
    with SingleTickerProviderStateMixin {
  List<String>? permissions;
  late TabController _tabController;
  bool isManagerExpanded = false;
  bool isDepartmentManagerExpanded = false;
  bool isViewAll = false;

  @override
  void initState() {
    super.initState();

    final userId =
        (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;

    _tabController = TabController(length: 4, vsync: this);

    Future.microtask(() async {
      final fetchedPermissions = await fetchUserPermissions(userId);
      if (mounted) {
        setState(() {
          permissions = fetchedPermissions;
        });
      }
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      setState(() {
        isManagerExpanded = false;
        isDepartmentManagerExpanded = false;
        isViewAll = false;

        if (_tabController.index == 1) {
          isManagerExpanded = true;
        } else if (_tabController.index == 2) {
          isDepartmentManagerExpanded = true;
        } else if (_tabController.index == 3) {
          isViewAll = true;
        }
      });

      final user = (context.read<AppUserCubit>().state as AppUserSignedIn).user;
      context.read<BlogBloc>().add(BlogGetAllBlogsEvent(
            user: user,
            departmentId: user.departmentId,
            isManagerExpanded: isManagerExpanded,
            isDepartmentManagerExpanded: isDepartmentManagerExpanded,
            isViewAll: isViewAll,
          ));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final state = context.read<AppUserCubit>().state;

    if (state is AppUserSignedIn) {
      final user = state.user;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ModalRoute? route = ModalRoute.of(context);
        if (route?.isCurrent == true) {
          context.read<BlogBloc>().add(BlogGetAllBlogsEvent(
                user: user,
                departmentId: user.departmentId,
                isManagerExpanded: isManagerExpanded,
                isDepartmentManagerExpanded: isDepartmentManagerExpanded,
                isViewAll: isViewAll,
              ));
        }
      });
    } else {
      // Optional: handle unauthenticated state (e.g., redirect to login)
      debugPrint("User is not signed in yet.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: AppLocalizations.of(context)!.blogsService,
      subtitle: AppLocalizations.of(context)!.blogsServiceSubtitle,
      tabController: _tabController,
      tabs: [
        Tab(text: AppLocalizations.of(context)!.myRequests),
        Tab(text: AppLocalizations.of(context)!.employees),
        Tab(text: AppLocalizations.of(context)!.department),
        Tab(text: AppLocalizations.of(context)!.all),
      ],
      bodyPerTab: [
        [_blogTab()],
        [_blogTab()],
        [_blogTab()],
        [_blogTab()],
      ],
      tilteActions: [
        if (isUserHasPermissionsView(
          permissions ?? [],
          PermissionsConstants.addBlog,
        ))
          IconButton(
            onPressed: () {
              context.push('/blog/submit/');
            },
            icon: const Icon(Icons.add),
          ),
      ],
      body: [],
    );
  }

  Widget _blogTab() {
    return BlocConsumer<BlogBloc, BlogState>(
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
          if (state.blogPage.blogsView.isEmpty) {
            return const Center(child: Text("No Blogs Found"));
          }

          return ListView.builder(
            shrinkWrap: true, // 👈 Important
            physics:
                const NeverScrollableScrollPhysics(), // 👈 Prevent inner scroll
            itemCount: state.blogPage.blogsView.length,
            itemBuilder: (context, index) {
              final blog = state.blogPage.blogsView[index];

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: AnimatedCardWrapper(
                  index: index,
                  child: CustomCardListRequests(
                    chips: blog.topics ?? [],
                    title: blog.title ?? '',
                    statusId: blog.requestStatusId,
                    requestDate: blog.requestCreatedAt,
                    subtitle: blog.content,
                    onTap: () {
                      context.push(
                        '/blog/${blog.requestId}',
                        extra: BlogViewerPageEntity(
                          blogsView: blog,
                          approval: state.blogPage.approvalsView
                              .where((a) => a.requestId == blog.requestId)
                              .toList(),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        }

        return const SizedBox();
      },
    );
  }
}

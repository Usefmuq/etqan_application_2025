import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/entities/departments.dart';
import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/animated_card_wrapper.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_card_list_requests.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/utils/lookups_and_constants.dart';
import 'package:etqan_application_2025/src/core/utils/notifier.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
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
  TabController? _tabController;
  bool isManagerExpanded = false;
  bool isDepartmentManagerExpanded = false;
  bool isViewAll = false;
  Departments? userDepartment;
  User? userDetails;
  List<Tab> tabs = [];
  List<List<Widget>> bodyPerTab = [[]];

  @override
  void initState() {
    super.initState();

    final user = (context.read<AppUserCubit>().state as AppUserSignedIn).user;

    Future.microtask(() async {
      final fetchedPermissions = await fetchUserPermissions(user.id);
      final fetchedDepartment = await fetchDepartmentById(user.departmentId);
      if (mounted) {
        setState(() {
          permissions = fetchedPermissions;
          userDepartment = fetchedDepartment;
          userDetails = user;
          _setupTabsAndController();
          _tabController?.addListener(() {
            if (_tabController!.indexIsChanging) return;

            setState(() {
              isManagerExpanded = false;
              isDepartmentManagerExpanded = false;
              isViewAll = false;

              if (_tabController?.index == 1) {
                isManagerExpanded = true;
              } else if (_tabController?.index == 2) {
                isDepartmentManagerExpanded = true;
              } else if (_tabController?.index == 3) {
                isViewAll = true;
              }
            });

            final user =
                (context.read<AppUserCubit>().state as AppUserSignedIn).user;
            context.read<BlogBloc>().add(BlogGetAllBlogsEvent(
                  user: user,
                  departmentId: user.departmentId,
                  isManagerExpanded: isManagerExpanded,
                  isDepartmentManagerExpanded: isDepartmentManagerExpanded,
                  isViewAll: isViewAll,
                ));
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _setupTabsAndController() {
    final isDepManager = userDepartment?.managerId == userDetails?.id;
    final updatedTabs = [
      Tab(text: AppLocalizations.of(context)!.myRequests),
      Tab(text: AppLocalizations.of(context)!.employees),
      if (isDepManager) Tab(text: AppLocalizations.of(context)!.department),
      if (isUserHasPermissionsView(
          permissions ?? [], PermissionsConstants.updateBlog))
        Tab(text: AppLocalizations.of(context)!.all),
    ];

    _tabController?.dispose(); // dispose old controller

    setState(() {
      tabs = updatedTabs;
      bodyPerTab = List.generate(tabs.length, (_) => [_blogTab()]);
      _tabController = TabController(length: tabs.length, vsync: this);
      isManagerExpanded = false;
      isDepartmentManagerExpanded = false;
      isViewAll = false;
    });
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
      tabs: tabs,
      bodyPerTab: bodyPerTab,
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
          SmartNotifier.error(context,
              title: AppLocalizations.of(context)!.error, message: state.error);
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

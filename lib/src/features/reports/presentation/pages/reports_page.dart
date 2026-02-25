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
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum _TabKind { my, employees, department, all }

class ReportsPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const ReportsPage(),
      );

  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  List<String>? permissions;
  TabController? _tabController;

  bool isManagerExpanded = false;
  bool isDepartmentManagerExpanded = false;
  bool isViewAll = false;

  Departments? userDepartment;
  User? userDetails;

  // Build tabs from kinds (no l10n usage before build)
  List<_TabKind> _tabKinds = [];

  // optional: if you still use this elsewhere
  List<List<Widget>> bodyPerTab = [[]];

  @override
  void initState() {
    super.initState();

    final appUserState = context.read<AppUserCubit>().state;
    if (appUserState is! AppUserSignedIn) return;
    final user = appUserState.user;

    Future.microtask(() async {
      final fetchedPermissions = await fetchUserPermissions(user.id);
      final fetchedDepartment = await fetchDepartmentById(user.departmentId);

      if (!mounted) return;
      setState(() {
        permissions = fetchedPermissions;
        userDepartment = fetchedDepartment;
        userDetails = user;
        _setupTabsAndController();
      });
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _setupTabsAndController() {
    final isDepManager = userDepartment?.managerId == userDetails?.id;

    final kinds = <_TabKind>[
      _TabKind.my,
      _TabKind.employees,
      if (isDepManager) _TabKind.department,
      // if (isUserHasPermissionsView(
      //     permissions ?? [], PermissionsConstants.updateReports))
      _TabKind.all,
    ];

    _tabController?.dispose();

    setState(() {
      _tabKinds = kinds;
      bodyPerTab = List.generate(_tabKinds.length, (_) => [_reportsTab()]);
      _tabController = TabController(length: _tabKinds.length, vsync: this);

      isManagerExpanded = false;
      isDepartmentManagerExpanded = false;
      isViewAll = false;

      _tabController!.addListener(() {
        if (_tabController!.indexIsChanging) return;

        final selectedKind = _tabKinds[_tabController!.index];
        setState(() {
          isManagerExpanded = (selectedKind == _TabKind.employees);
          isDepartmentManagerExpanded = (selectedKind == _TabKind.department);
          isViewAll = (selectedKind == _TabKind.all);
        });

        final appUserState = context.read<AppUserCubit>().state;
        if (appUserState is! AppUserSignedIn) return;
        final user = appUserState.user;

        context.read<ReportsBloc>().add(
              ReportsGetAllReportssEvent(
                user: user,
                departmentId: user.departmentId,
                isManagerExpanded: isManagerExpanded,
                isDepartmentManagerExpanded: isDepartmentManagerExpanded,
                isViewAll: isViewAll,
              ),
            );
      });

      // initial fetch right after controller creation
      final appUserState = context.read<AppUserCubit>().state;
      if (appUserState is AppUserSignedIn) {
        final user = appUserState.user;
        context.read<ReportsBloc>().add(
              ReportsGetAllReportssEvent(
                user: user,
                departmentId: user.departmentId,
                isManagerExpanded: false,
                isDepartmentManagerExpanded: false,
                isViewAll: false,
              ),
            );
      }
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
          context.read<ReportsBloc>().add(
                ReportsGetAllReportssEvent(
                  user: user,
                  departmentId: user.departmentId,
                  isManagerExpanded: isManagerExpanded,
                  isDepartmentManagerExpanded: isDepartmentManagerExpanded,
                  isViewAll: isViewAll,
                ),
              );
        }
      });
    } else {
      debugPrint("User is not signed in yet.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: AppLocalizations.of(context)!.reportsService,
      subtitle: AppLocalizations.of(context)!.reportsServiceSubtitle,
      tabController: _tabController,
      tabs: _tabsFromKinds(context, _tabKinds),
      bodyPerTab: bodyPerTab,
      tilteActions: [
        // if (isUserHasPermissionsView(
        //   permissions ?? [],
        //   PermissionsConstants.addReports,
        // ))
        //   IconButton(
        //     onPressed: () {
        //       context.push('/reports/submit/');
        //     },
        //     icon: const Icon(Icons.add),
        //   ),
      ],
      body: [],
    );
  }

  List<Tab> _tabsFromKinds(BuildContext context, List<_TabKind> kinds) {
    final l10n = AppLocalizations.of(context)!;
    return kinds.map((k) {
      switch (k) {
        case _TabKind.my:
          return Tab(text: l10n.myRequests);
        case _TabKind.employees:
          return Tab(text: l10n.employees);
        case _TabKind.department:
          return Tab(text: l10n.department);
        case _TabKind.all:
          return Tab(text: l10n.all);
      }
    }).toList();
  }

  Widget _reportsTab() {
    return BlocConsumer<ReportsBloc, ReportsState>(
      listener: (context, state) {
        if (state is ReportsFailure) {
          SmartNotifier.error(
            context,
            title: AppLocalizations.of(context)!.error,
            message: state.error,
          );
        }
      },
      builder: (context, state) {
        final permsReady = permissions != null;
        final canAdd = isUserHasPermissionsView(
          permissions ?? const [],
          PermissionsConstants.viewReports,
        );

        if (state is ReportsLoading || !permsReady) {
          return const Loader();
        }
        if (!canAdd) {
          return Center(
            child: Text(AppLocalizations.of(context)!.noPermission),
          );
        }

        if (state is ReportsShowAllSuccess) {
          if (state.reportsPage.reportssView.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noResults));
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.reportsPage.reportssView.length,
            itemBuilder: (context, index) {
              final reports = state.reportsPage.reportssView[index];

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: AnimatedCardWrapper(
                  index: index,
                  child: CustomCardListRequests(
                    chips: reports.topics ?? [],
                    title: reports.title ?? '',
                    statusId: reports.requestStatusId,
                    requestDate: reports.requestCreatedAt,
                    subtitle: reports.content,
                    onTap: () {
                      context.push(
                        '/reports/${reports.requestId}',
                        extra: ReportsViewerPageEntity(
                          reportssView: reports,
                          approval: state.reportsPage.approvalsView
                              .where((a) => a.requestId == reports.requestId)
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

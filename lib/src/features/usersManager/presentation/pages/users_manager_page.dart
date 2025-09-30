import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/entities/departments.dart';
import 'package:etqan_application_2025/src/core/common/entities/positions.dart';
import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_section_title.dart';
import 'package:etqan_application_2025/src/core/common/widgets/grids/custom_table_grid.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/utils/lookups_and_constants.dart';
import 'package:etqan_application_2025/src/core/utils/notifier.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/features/auth/data/models/user_model.dart';
import 'package:etqan_application_2025/src/features/usersManager/presentation/bloc/users_manager_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum _TabKind { my, employees, department, all }

class UsersManagerPage extends StatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const UsersManagerPage(),
      );

  const UsersManagerPage({super.key});

  @override
  State<UsersManagerPage> createState() => _UsersManagerPageState();
}

class _UsersManagerPageState extends State<UsersManagerPage>
    with SingleTickerProviderStateMixin {
  List<String>? permissions;
  TabController? _tabController;
  List<UserModel>? allUsers;
  bool isManagerExpanded = false;
  bool isDepartmentManagerExpanded = false;
  bool isViewAll = false;

  Departments? userDepartment;
  List<Departments>? allDepartments;
  List<Positions>? allPositions;
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
      final fetchedAllDepartments = await fetchDepartments();
      final fetchedAllPositions = await fetchAllPositions();
      final fetchedUsers = await fetchAllUsers();
      if (!mounted) return;
      setState(() {
        allUsers = fetchedUsers;
        permissions = fetchedPermissions;
        userDepartment = fetchedDepartment;
        allDepartments = fetchedAllDepartments;
        allPositions = fetchedAllPositions;
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
      if (isUserHasPermissionsView(
          permissions ?? [], PermissionsConstants.updateUsersManager))
        _TabKind.all,
    ];

    _tabController?.dispose();

    setState(() {
      _tabKinds = kinds;
      bodyPerTab = List.generate(_tabKinds.length, (_) => [_usersManagerTab()]);
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

        context.read<UsersManagerBloc>().add(
              UsersManagerGetAllUsersManagersEvent(
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
        context.read<UsersManagerBloc>().add(
              UsersManagerGetAllUsersManagersEvent(
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
          context.read<UsersManagerBloc>().add(
                UsersManagerGetAllUsersManagersEvent(
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
      title: AppLocalizations.of(context)!.usersManagersService,
      subtitle: AppLocalizations.of(context)!.usersManagersServiceSubtitle,
      tabController: _tabController,
      tabs: _tabsFromKinds(context, _tabKinds),
      bodyPerTab: bodyPerTab,
      tilteActions: [
        if (isUserHasPermissionsView(
          permissions ?? [],
          PermissionsConstants.addUsersManager,
        ))
          IconButton(
            onPressed: () {
              context.push('/usersManager/submit/');
            },
            icon: const Icon(Icons.add),
          ),
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

  Widget _usersManagerTab() {
    return BlocConsumer<UsersManagerBloc, UsersManagerState>(
      listener: (context, state) {
        if (state is UsersManagerFailure) {
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
          PermissionsConstants.viewUsersManager,
        );

        if (state is UsersManagerLoading || !permsReady) {
          return const Loader();
        }
        if (!canAdd) {
          return Center(
            child: Text(AppLocalizations.of(context)!.noPermission),
          );
        }

        if (state is UsersManagerShowAllSuccess) {
          if (allUsers == null) {
            return Center(child: Text(AppLocalizations.of(context)!.noResults));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionTitle(
                title:
                    'AppLocalizations.of(context)!.approvalSequence) list of all users',
              ),
              CustomTableGrid(
                headers: [
                  AppLocalizations.of(context)!.email,
                  AppLocalizations.of(context)!.fullNameAR,
                  AppLocalizations.of(context)!.fullNameEN,
                  AppLocalizations.of(context)!.phone,
                  AppLocalizations.of(context)!.department,
                  AppLocalizations.of(context)!.position,
                  AppLocalizations.of(context)!.status,
                  AppLocalizations.of(context)!.manager,
                ],
                rows: allUsers!.map((u) => u.toTableRow()).toList(),
                useChipsForStatus: true,
                departments: allDepartments ?? [],
                positions: allPositions ?? [],
                users: allUsers ?? [],
                onEdit: (row) {
                  print(row['ID']);
                  context.push('/usersManager/submit/${row['ID']}');
                },
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }
}

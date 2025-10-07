import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/entities/permissions_view.dart';
import 'package:etqan_application_2025/src/core/common/entities/service_fields.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_button.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/role_permission_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/roles_model.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:etqan_application_2025/src/core/utils/lookups_and_constants.dart';
import 'package:etqan_application_2025/src/core/utils/notifier.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/features/usersManager/presentation/bloc/users_manager_bloc.dart';
import 'package:etqan_application_2025/src/features/usersManager/presentation/pages/users_manager_input_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddNewUsersManagerPage extends StatefulWidget {
  final String? userId;
  const AddNewUsersManagerPage({super.key, this.userId});
  static route() => MaterialPageRoute(
        builder: (context) => const AddNewUsersManagerPage(),
      );
  @override
  State<AddNewUsersManagerPage> createState() => _AddNewUsersManagerPageState();
}

class _AddNewUsersManagerPageState extends State<AddNewUsersManagerPage> {
  List<String>? permissions;
  List<PermissionsView>? permissionsView;
  List<RolesModel>? allRoles;
  List<RolesModel> selectedRoles = [];
  List<RolePermissionViewModel> rolePermissionView = [];
  final TextEditingController notesController = TextEditingController();
  DateTime? endDate;
  bool noEndDate = false;
  final formKey = GlobalKey<FormState>();
  List<ServiceField> serviceFields = [];
  @override
  void initState() {
    super.initState();
    final userState = context.read<AppUserCubit>().state;
    if (userState is! AppUserSignedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {}); // let build run after auth state becomes ready
      });
      return;
    }
    final loggedInUserId = userState.user.id;

    Future.microtask(() async {
      final fetchedPermissions = await fetchUserPermissions(loggedInUserId);
      final fetchedPermissionsView =
          await fetchUserPermissionsView(widget.userId ?? '');
      final fetchedAllRoles = await fetchAllRoles();
      final fetchedServiceFields =
          await fetchFieldsByServiceId(ServicesConstants.usersManagerServiceId);

      if (mounted) {
        setState(() {
          permissions = fetchedPermissions;
          permissionsView = fetchedPermissionsView;
          serviceFields = fetchedServiceFields;
          allRoles = fetchedAllRoles;
        });
      }
    });
  }

  void _submitUsersManager() {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    {
      final userState = context.read<AppUserCubit>().state;
      if (userState is! AppUserSignedIn) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          SmartNotifier.warning(
            context,
            title: AppLocalizations.of(context)!.error,
            message: AppLocalizations.of(context)!.unexpectedError,
          );
        });
        return;
      }
      final createdById = userState.user.id;
      print(notesController.text);
      for (final userRole in selectedRoles) {
        context.read<UsersManagerBloc>().add(
              UsersManagerSubmitEvent(
                createdById: createdById,
                notes: notesController.text.trim(),
                userId: widget.userId!,
                roleId: userRole.roleId,
                startAt: DateTime.now().toUtc().add(const Duration(hours: 3)),
                endAt: endDate,
                action: 'ADD',
                departmentId: '',
                appliesToAllDepartments: true,
              ),
            );
      }

      // context.read<UsersManagerBloc>().add(
      //       UsersManagerSubmitEvent(
      //         createdById: createdById,
      //         notes: notesController.text.trim(),
      //         userId: '',
      //         roleId: '',
      //         startAt: DateTime.now().toUtc().add(Duration(hours: 3)),
      //         endAt: null,
      //         action: '',
      //         departmentId: '',
      //         appliesToAllDepartments: true,
      //       ),
      //     );
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: AppLocalizations.of(context)!.usersManagerSubmitNew,
      showDrawer: false,
      body: [
        BlocConsumer<UsersManagerBloc, UsersManagerState>(
          listener: (context, state) {
            if (state is UsersManagerFailure) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                SmartNotifier.error(
                  context,
                  title: AppLocalizations.of(context)!.error,
                  message: state.error,
                );
              });
            } else if (state is UsersManagerSubmitSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) context.pop();
              });
            }
          },
          builder: (context, state) {
            final permsReady = permissions != null;
            final canAdd = isUserHasPermissionsView(
              permissions ?? const [],
              PermissionsConstants.addUsersManager,
            );

            if (state is UsersManagerLoading || !permsReady) {
              return const Loader();
            }
            if (!canAdd) {
              return Center(
                child: Text(AppLocalizations.of(context)!.noPermission),
              );
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 600;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...UsersManagerInputSection.build(
                          serviceFields: serviceFields,
                          isLockFieldsWithoutComment: false,
                          setState: setState,
                          notesController: notesController,
                          isWide: isWide,
                          permissionsView: permissionsView ?? [],
                          allRoles: allRoles ?? [],
                          selectedRoles: selectedRoles,
                          rolePermissionView: rolePermissionView,
                          endDate: endDate,
                          noEndDate: noEndDate,
                          onEndDateChanged: (d) => setState(() => endDate = d),
                          onNoEndDateChanged: (v) => setState(() {
                            noEndDate = v;
                            if (v) endDate = null;
                          }),
                        ),
                        const SizedBox(height: 40),
                        const SizedBox(height: 40),
                        Divider(thickness: 1.5, color: Colors.grey[300]),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              width: 180,
                              icon: Icons.check_circle,
                              text: AppLocalizations.of(context)!.submit,
                              onPressed: _submitUsersManager,
                            ),
                            CustomButton(
                              width: 180,
                              icon: Icons.cancel,
                              text: AppLocalizations.of(context)!.cancel,
                              // type: ButtonType.outlined,
                              backgroundColor: AppPallete.errorColor,
                              onPressed: context.pop,
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

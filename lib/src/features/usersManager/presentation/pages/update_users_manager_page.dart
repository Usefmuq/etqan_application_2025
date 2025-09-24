import 'package:etqan_application_2025/init_dependencies.dart';
import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/entities/service_fields.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_button.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:etqan_application_2025/src/core/utils/approval_sequence_utils.dart';
import 'package:etqan_application_2025/src/core/utils/lookups_and_constants.dart';
import 'package:etqan_application_2025/src/core/utils/notifier.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/entities/users_manager_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/usersManager/domain/usecases/fetch_users_manager_page.dart';
import 'package:etqan_application_2025/src/features/usersManager/presentation/bloc/users_manager_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UpdateUsersManagerPage extends StatefulWidget {
  final UsersManagerViewerPageEntity? initialUsersManagerViewerPage;
  final int? requestId;
  const UpdateUsersManagerPage(
      {super.key, this.initialUsersManagerViewerPage, this.requestId});
  static route(UsersManagerViewerPageEntity usersManagerViewerPage) =>
      MaterialPageRoute(
        builder: (context) => UpdateUsersManagerPage(
            initialUsersManagerViewerPage: usersManagerViewerPage),
      );

  @override
  State<UpdateUsersManagerPage> createState() => _UpdateUsersManagerPageState();
}

class _UpdateUsersManagerPageState extends State<UpdateUsersManagerPage> {
  List<String>? permissions;
  List<RequestUnlockedFieldModel>? unlockedFields;
  UsersManagerViewerPageEntity? usersManagerViewerPage;
  final TextEditingController titleControler = TextEditingController();
  final TextEditingController contentControler = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<String> selectedTopics = [];
  String userId = '';
  List<ServiceField> serviceFields = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialUsersManagerViewerPage != null) {
      usersManagerViewerPage = widget.initialUsersManagerViewerPage!;
      // selectedTopics = usersManagerViewerPage!.usersManagersView.topics!;
      // titleControler.text = usersManagerViewerPage!.usersManagersView.title!;
      // contentControler.text =
      //     usersManagerViewerPage!.usersManagersView.content!;
    } else if (widget.requestId != null) {
      _fetchUsersManagerViewerData(widget.requestId!);
    }

    userId = (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;
    Future.microtask(() async {
      // final fetchedUnlockedFields =
      //     await fetchUnlockedFields(usersManagerViewerPage?.usersManagersView.requestId ?? -1);
      final fetchedPermissions = await fetchUserPermissions(userId);
      final fetchedServiceFields =
          await fetchFieldsByServiceId(ServicesConstants.usersManagerServiceId);

      final reqId = widget.requestId ??
          // widget.initialUsersManagerViewerPage?.usersManagersView.requestId;
          -1;
      List<RequestUnlockedFieldModel>? fetchedUnlockedFields;
      if (reqId != null) {
        fetchedUnlockedFields = await fetchUnlockedFields(reqId);
      }
      if (!mounted) return;
      setState(() {
        permissions = fetchedPermissions;
        unlockedFields = fetchedUnlockedFields; // may be null initially
        serviceFields = fetchedServiceFields;
      });
    });
  }

  void _fetchUsersManagerViewerData(int requestId) async {
    final FetchUsersManagerPage fetchUsersManagerPage = serviceLocator<
        FetchUsersManagerPage>(); // ✅ Get use case from service locator

    final fetched = await fetchUsersManagerPage.call(
        FetchUsersManagerPageParams(
            requestId: requestId)); // Implement this fetch
    final fetchedUnlockedFields = await fetchUnlockedFields(requestId);

    fetched.fold((failure) {
      return;
    }, (fetch) {
      if (mounted) {
        setState(() {
          usersManagerViewerPage = fetch;
          unlockedFields = fetchedUnlockedFields;
          // selectedTopics = usersManagerViewerPage!.usersManagersView.topics!;
          // titleControler.text =
          //     usersManagerViewerPage!.usersManagersView.title!;
          // contentControler.text =
          //     usersManagerViewerPage!.usersManagersView.content!;
        });
      }
    });
  }

  void _updateUsersManager() {
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (selectedTopics.isEmpty) {
      SmartNotifier.warning(
        context,
        title: AppLocalizations.of(context)!.error,
        message: AppLocalizations.of(context)!.fieldIsRequired,
      );
      return;
    }
    context.read<UsersManagerBloc>().add(
          UsersManagerUpdateEvent(
            usersManagerViewerPage:
                usersManagerViewerPage!.usersManagersView.copyWith(),
            updatedBy: userId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'usersManagerViewerPage?.usersManagersView.requestId != null',
      // ? '${AppLocalizations.of(context)!.usersManagerUpdate} #${usersManagerViewerPage!.usersManagersView.requestId}'
      // : AppLocalizations.of(context)!.usersManager,
      showDrawer: false,
      body: [
        BlocConsumer<UsersManagerBloc, UsersManagerState>(
          listener: (context, state) {
            if (state is UsersManagerFailure) {
              SmartNotifier.error(context,
                  title: AppLocalizations.of(context)!.error,
                  message: state.error);
            } else if (state is UsersManagerUpdateSuccess) {
              context.pop(state.usersManagerViewerPageEntity);
              SmartNotifier.success(
                context,
                title: AppLocalizations.of(context)!.approvalSuccessful,
              );
            }
          },
          builder: (context, state) {
            if (state is UsersManagerLoading ||
                usersManagerViewerPage == null ||
                !isUserHasPermissionsView(permissions ?? [],
                    PermissionsConstants.updateUsersManager)) {
              return const Loader();
            }
// compute using the data you actually have at build time
            // final currentCreatedById =
            //     usersManagerViewerPage?.usersManagersView.createdById ??
            //         widget.initialUsersManagerViewerPage?.usersManagersView
            //             .createdById;

// approver = has update permission (your existing flag)
            final isApprover = isUserHasPermissionsView(
                permissions ?? [], PermissionsConstants.updateUsersManager);

// creator?
            // final isCreator = currentCreatedById == userId;

// lock mode: submitter should be locked (except returned fields).
// approver (not creator) can edit regardless; otherwise locked.
            // final isLockFieldsWithoutComment = !(isApprover && !isCreator);

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
                        // ...UsersManagerInputSection.build(
                        //   serviceFields: serviceFields,
                        //   isLockFieldsWithoutComment:
                        //       isLockFieldsWithoutComment,
                        //   setState: setState,
                        //   selectedTopics: selectedTopics,
                        //   // onToggleTopic: (topic) {
                        //   //   setState(() {
                        //   //     selectedTopics.contains(topic)
                        //   //         ? selectedTopics.remove(topic)
                        //   //         : selectedTopics.add(topic);
                        //   //   });
                        //   // },
                        //   titleController: titleControler,
                        //   contentController: contentControler,
                        //   isWide: isWide,
                        //   unlockedFields: unlockedFields,
                        // ),
                        const SizedBox(height: 40),
                        Divider(thickness: 1.5, color: Colors.grey[300]),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            // CustomButton(
                            //   width: 180,
                            //   icon: Icons.check_circle,
                            //   text: AppLocalizations.of(context)!.update,
                            //   isDisabled: isCreator &&
                            //       usersManagerViewerPage
                            //               ?.usersManagersView.requestStatusId !=
                            //           LookupConstants
                            //               .requestStatusReturnForCorrection,
                            //   onPressed: _updateUsersManager,
                            // ),
                            CustomButton(
                              width: 180,
                              icon: Icons.cancel,
                              text: AppLocalizations.of(context)!.cancel,
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

  @override
  void dispose() {
    super.dispose();
    titleControler.dispose();
    contentControler.dispose();
  }
}

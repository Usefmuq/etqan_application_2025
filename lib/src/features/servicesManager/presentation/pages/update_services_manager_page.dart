import 'package:etqan_application_2025/init_dependencies.dart';
import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/entities/service_fields.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_button.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:etqan_application_2025/src/core/utils/approval_sequence_utils.dart';
import 'package:etqan_application_2025/src/core/utils/lookups_and_constants.dart';
import 'package:etqan_application_2025/src/core/utils/notifier.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/entities/services_manager_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/usecases/fetch_services_manager_page.dart';
import 'package:etqan_application_2025/src/features/servicesManager/presentation/bloc/services_manager_bloc.dart';
import 'package:etqan_application_2025/src/features/servicesManager/presentation/pages/services_manager_input_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UpdateServicesManagerPage extends StatefulWidget {
  final ServicesManagerViewerPageEntity? initialServicesManagerViewerPage;
  final int? requestId;
  const UpdateServicesManagerPage(
      {super.key, this.initialServicesManagerViewerPage, this.requestId});
  static route(ServicesManagerViewerPageEntity servicesmanagerViewerPage) =>
      MaterialPageRoute(
        builder: (context) => UpdateServicesManagerPage(
            initialServicesManagerViewerPage: servicesmanagerViewerPage),
      );

  @override
  State<UpdateServicesManagerPage> createState() =>
      _UpdateServicesManagerPageState();
}

class _UpdateServicesManagerPageState extends State<UpdateServicesManagerPage> {
  List<String>? permissions;
  List<RequestUnlockedFieldModel>? unlockedFields;
  ServicesManagerViewerPageEntity? servicesmanagerViewerPage;
  final TextEditingController titleControler = TextEditingController();
  final TextEditingController contentControler = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<String> selectedTopics = [];
  String userId = '';
  List<ServiceField> serviceFields = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialServicesManagerViewerPage != null) {
      servicesmanagerViewerPage = widget.initialServicesManagerViewerPage!;
      selectedTopics = servicesmanagerViewerPage!.servicesmanagersView.topics!;
      titleControler.text =
          servicesmanagerViewerPage!.servicesmanagersView.title!;
      contentControler.text =
          servicesmanagerViewerPage!.servicesmanagersView.content!;
    } else if (widget.requestId != null) {
      _fetchServicesManagerViewerData(widget.requestId!);
    }

    userId = (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;
    Future.microtask(() async {
      // final fetchedUnlockedFields =
      //     await fetchUnlockedFields(servicesmanagerViewerPage?.servicesmanagersView.requestId ?? -1);
      final fetchedPermissions = await fetchUserPermissions(userId);
      final fetchedServiceFields = await fetchFieldsByServiceId(
          ServicesConstants.servicesManagerServiceId);

      final reqId = widget.requestId ??
          widget
              .initialServicesManagerViewerPage?.servicesmanagersView.requestId;
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

  void _fetchServicesManagerViewerData(int requestId) async {
    final FetchServicesManagerPage fetchServicesManagerPage = serviceLocator<
        FetchServicesManagerPage>(); // ✅ Get use case from service locator

    final fetched = await fetchServicesManagerPage.call(
        FetchServicesManagerPageParams(
            requestId: requestId)); // Implement this fetch
    final fetchedUnlockedFields = await fetchUnlockedFields(requestId);

    fetched.fold((failure) {
      return;
    }, (fetch) {
      if (mounted) {
        setState(() {
          servicesmanagerViewerPage = fetch;
          unlockedFields = fetchedUnlockedFields;
          selectedTopics =
              servicesmanagerViewerPage!.servicesmanagersView.topics!;
          titleControler.text =
              servicesmanagerViewerPage!.servicesmanagersView.title!;
          contentControler.text =
              servicesmanagerViewerPage!.servicesmanagersView.content!;
        });
      }
    });
  }

  void _updateServicesManager() {
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (selectedTopics.isEmpty) {
      SmartNotifier.warning(
        context,
        title: AppLocalizations.of(context)!.error,
        message: AppLocalizations.of(context)!.fieldIsRequired,
      );
      return;
    }
    context.read<ServicesManagerBloc>().add(
          ServicesManagerUpdateEvent(
            servicesmanagerViewerPage:
                servicesmanagerViewerPage!.servicesmanagersView.copyWith(
              title: titleControler.text,
              content: contentControler.text,
              topics: selectedTopics,
            ),
            updatedBy: userId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: servicesmanagerViewerPage?.servicesmanagersView.requestId != null
          ? '${AppLocalizations.of(context)!.servicesManagerUpdate} #${servicesmanagerViewerPage!.servicesmanagersView.requestId}'
          : AppLocalizations.of(context)!.servicesManager,
      showDrawer: false,
      body: [
        BlocConsumer<ServicesManagerBloc, ServicesManagerState>(
          listener: (context, state) {
            if (state is ServicesManagerFailure) {
              SmartNotifier.error(context,
                  title: AppLocalizations.of(context)!.error,
                  message: state.error);
            } else if (state is ServicesManagerUpdateSuccess) {
              context.pop(state.servicesmanagerViewerPageEntity);
              SmartNotifier.success(
                context,
                title: AppLocalizations.of(context)!.approvalSuccessful,
              );
            }
          },
          builder: (context, state) {
            if (state is ServicesManagerLoading ||
                servicesmanagerViewerPage == null ||
                !isUserHasPermissionsView(permissions ?? [],
                    PermissionsConstants.updateServicesManager)) {
              return const Loader();
            }
// compute using the data you actually have at build time
            final currentCreatedById =
                servicesmanagerViewerPage?.servicesmanagersView.createdById ??
                    widget.initialServicesManagerViewerPage
                        ?.servicesmanagersView.createdById;

// approver = has update permission (your existing flag)
            final isApprover = isUserHasPermissionsView(
                permissions ?? [], PermissionsConstants.updateServicesManager);

// creator?
            final isCreator = currentCreatedById == userId;

// lock mode: submitter should be locked (except returned fields).
// approver (not creator) can edit regardless; otherwise locked.
            final isLockFieldsWithoutComment = !(isApprover && !isCreator);

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
                        ...ServicesManagerInputSection.build(
                          serviceFields: serviceFields,
                          isLockFieldsWithoutComment:
                              isLockFieldsWithoutComment,
                          setState: setState,
                          selectedTopics: selectedTopics,
                          // onToggleTopic: (topic) {
                          //   setState(() {
                          //     selectedTopics.contains(topic)
                          //         ? selectedTopics.remove(topic)
                          //         : selectedTopics.add(topic);
                          //   });
                          // },
                          titleController: titleControler,
                          contentController: contentControler,
                          isWide: isWide,
                          unlockedFields: unlockedFields,
                        ),
                        const SizedBox(height: 40),
                        Divider(thickness: 1.5, color: AppPallete.greyColor),
                        const SizedBox(height: 24),
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              width: 180,
                              icon: Icons.check_circle,
                              text: AppLocalizations.of(context)!.update,
                              isDisabled: isCreator &&
                                  servicesmanagerViewerPage
                                          ?.servicesmanagersView
                                          .requestStatusId !=
                                      LookupConstants
                                          .requestStatusReturnForCorrection,
                              onPressed: _updateServicesManager,
                            ),
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

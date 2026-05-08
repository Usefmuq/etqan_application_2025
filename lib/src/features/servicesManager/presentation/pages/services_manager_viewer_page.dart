import 'package:etqan_application_2025/init_dependencies.dart';
import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/entities/service_fields.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/utils/approval_sequence_utils.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:etqan_application_2025/src/core/utils/lookups_and_constants.dart';
import 'package:etqan_application_2025/src/core/utils/notifier.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/entities/services_manager_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/servicesManager/domain/usecases/fetch_services_manager_page.dart';
import 'package:etqan_application_2025/src/features/servicesManager/presentation/bloc/services_manager_bloc.dart';
import 'package:etqan_application_2025/src/features/servicesManager/presentation/pages/services_manager_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ServicesManagerViewerPage extends StatefulWidget {
  final ServicesManagerViewerPageEntity? initialServicesManagerViewerPage;
  final int? requestId;
  const ServicesManagerViewerPage(
      {super.key, this.initialServicesManagerViewerPage, this.requestId});

  static route(ServicesManagerViewerPageEntity? servicesmanagerViewerPage) =>
      MaterialPageRoute(
        builder: (context) => ServicesManagerViewerPage(
          initialServicesManagerViewerPage: servicesmanagerViewerPage,
        ),
      );

  @override
  State<ServicesManagerViewerPage> createState() =>
      _ServicesManagerViewerPageState();
}

class _ServicesManagerViewerPageState extends State<ServicesManagerViewerPage> {
  // >>> keep your variables as-is
  ServicesManagerViewerPageEntity? servicesmanagerViewerPage;
  List<String>? permissions;
  ApprovalSequenceViewModel? pendingApproval;
  List<ServiceField> serviceFields = [];
  List<RequestUnlockedFieldModel> requestUnlockedFields = [];
  List<TextEditingController> fieldControllers = [];
  final Map<int, bool> unlockedFieldsReadOnly =
      {}; // index -> true (locked/readOnly), false (unlocked/editable)

  final TextEditingController commentController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  // <<< keep your variables as-is
  @override
  void initState() {
    super.initState();

    if (widget.initialServicesManagerViewerPage != null) {
      servicesmanagerViewerPage = widget.initialServicesManagerViewerPage!;
      _initializeApprovals();
    } else if (widget.requestId != null) {
      _fetchServicesManagerViewerData(widget.requestId!);
    }

    final userState = context.read<AppUserCubit>().state;
    if (userState is! AppUserSignedIn) {
      // Defer until dependencies are ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(
            () {}); // trigger rebuild; didChangeDependencies can pick it up
      });
      return;
    }
    final userId = userState.user.id;

    Future.microtask(() async {
      final fetchedPermissions = await fetchUserPermissions(userId);
      final fetchedServiceFields = await fetchFieldsByServiceId(
          ServicesConstants.servicesManagerServiceId);

      // Optionally compute pendingApproval if we already have servicesmanagerViewerPage
      final fetchPendingApproval = await servicesmanagerViewerPage?.approval!
          .firstWhereOrNullAsync((a) async {
        return a.approvalStatus?.toLowerCase() ==
                LookupConstants.approvalStatusApprovalPending &&
            (a.approverUserId == userId ||
                await isUserHasRole(userId, a.roleId ?? ''));
      });

      if (!mounted) return;
      setState(() {
        permissions = fetchedPermissions;
        pendingApproval = fetchPendingApproval;
        serviceFields = fetchedServiceFields;
      });

      _ensureControllersAndLocksInitialized();
    });
  }

  void _ensureControllersAndLocksInitialized() {
    // make fieldControllers match serviceFields length
    if (fieldControllers.length != serviceFields.length) {
      fieldControllers = List.generate(
        serviceFields.length,
        (_) => TextEditingController(),
      );
    }
    // default all to locked (readOnly == true) unless already set
    if (unlockedFieldsReadOnly.length != serviceFields.length) {
      for (var i = 0; i < serviceFields.length; i++) {
        unlockedFieldsReadOnly[i] = unlockedFieldsReadOnly[i] ?? true;
      }
    }
  }

  void _fetchServicesManagerViewerData(int requestId) async {
    final FetchServicesManagerPage fetchServicesManagerPage =
        serviceLocator<FetchServicesManagerPage>();
    final fetched = await fetchServicesManagerPage
        .call(FetchServicesManagerPageParams(requestId: requestId));

    fetched.fold((failure) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SmartNotifier.error(
          context,
          title: AppLocalizations.of(context)!.error,
          message: failure.message,
        );
      });
    }, (fetch) async {
      if (!mounted) return;
      setState(() {
        servicesmanagerViewerPage = fetch;
      });
      await _initializeApprovals();
      _ensureControllersAndLocksInitialized();
    });
  }

  Future<void> _initializeApprovals() async {
    final userState = context.read<AppUserCubit>().state;
    if (userState is! AppUserSignedIn) {
      // Defer until dependencies are ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(
            () {}); // trigger rebuild; didChangeDependencies can pick it up
      });
      return;
    }
    final userId = userState.user.id;

    final fetchedPermissions = await fetchUserPermissions(userId);

    final fetchPendingApproval = await servicesmanagerViewerPage!.approval!
        .firstWhereOrNullAsync((a) async {
      return a.approvalStatus?.toLowerCase() ==
              LookupConstants.approvalStatusApprovalPending &&
          (a.approverUserId == userId ||
              await isUserHasRole(userId, a.roleId ?? ''));
    });

    if (!mounted) return;
    setState(() {
      permissions = fetchedPermissions;
      pendingApproval = fetchPendingApproval;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: servicesmanagerViewerPage != null
          ? '${AppLocalizations.of(context)!.servicesManager}- ${servicesmanagerViewerPage!.servicesmanagersView.requestId}'
          : AppLocalizations.of(context)!.servicesManager,
      tilteActions: [
        if (isUserHasPermissionsView(
              permissions ?? [],
              PermissionsConstants.updateServicesManager,
            ) &&
            servicesmanagerViewerPage != null &&
            servicesmanagerViewerPage!.servicesmanagersView
                    .toServicesManager() !=
                null)
          IconButton(
            onPressed: _handleEdit,
            icon: const Icon(Icons.edit),
          ),
      ],
      body: [
        BlocConsumer<ServicesManagerBloc, ServicesManagerState>(
          listener: (context, state) {
            if (state is ServicesManagerFailure) {
              SmartNotifier.error(
                context,
                title: AppLocalizations.of(context)!.unexpectedError,
                message: state.error,
              );
            } else if (state is ServicesManagerApproveSuccess ||
                state is ServicesManagerSubmitSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                SmartNotifier.success(
                  context,
                  title: AppLocalizations.of(context)!.approvalSuccessful,
                );
                final reqId = widget.requestId ??
                    widget.initialServicesManagerViewerPage!
                        .servicesmanagersView.requestId!;
                _fetchServicesManagerViewerData(reqId);
              });
            }
          },
          builder: (context, state) {
            if (state is ServicesManagerLoading ||
                servicesmanagerViewerPage == null ||
                !isUserHasPermissionsView(
                  permissions ?? [],
                  PermissionsConstants.viewServicesManager,
                )) {
              return const Loader();
            }
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildDetailsSection(context, servicesmanagerViewerPage),
                      const Divider(),
                      const SizedBox(height: 12),
                      buildApprovalTableSection(
                        context,
                        servicesmanagerViewerPage?.approval,
                      ),
                      const SizedBox(height: 24),
                      if (isUserHasPermissionsView(
                            permissions ?? [],
                            PermissionsConstants.approveServicesManager,
                          ) &&
                          !pendingApproval.isNullOrEmpty)
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              buildReturnForCorrectionUI(
                                context,
                                serviceFields,
                                unlockedFieldsReadOnly,
                                fieldControllers,
                                (idx, wasReadOnly) {
                                  // <-- you get index and current state
                                  setState(() {
                                    unlockedFieldsReadOnly[idx] = !wasReadOnly;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              buildCommentField(
                                context,
                                commentController,
                              ),
                              const SizedBox(height: 20),
                              // _buildActionButtons(),
                              buildActionButtons(
                                context: context,
                                onApprove: () => approveRequest(
                                  context: context,
                                  formKey: formKey,
                                  commentController: commentController,
                                  isApproved: true,
                                  pendingApproval: pendingApproval!,
                                  model: servicesmanagerViewerPage!
                                      .servicesmanagersView,
                                  dispatchEvent: (event) => context
                                      .read<ServicesManagerBloc>()
                                      .add(event),
                                  buildEvent: ({
                                    required approvalSequence,
                                    required model,
                                    requestUnlockedFields,
                                  }) =>
                                      ServicesManagerApproveEvent(
                                    approvalSequence: approvalSequence,
                                    servicesmanagerModel:
                                        servicesmanagerViewerPage!
                                            .servicesmanagersView,
                                    requestUnlockedFields:
                                        requestUnlockedFields,
                                  ),
                                ),
                                onReturnForCorrection: () =>
                                    handleReturnForCorrectionPressed(
                                  fieldControllers: fieldControllers,
                                  serviceFields: serviceFields,
                                  unlockedFieldsReadOnly:
                                      unlockedFieldsReadOnly,
                                  formKey: formKey,
                                  requestUnlockedFields: requestUnlockedFields,
                                  context: context,
                                  requestId: servicesmanagerViewerPage!
                                      .servicesmanagersView.requestId!,
                                  onReturnForCorrection: (unlockedFields) {
                                    approveRequest(
                                      commentController: commentController,
                                      formKey: formKey,
                                      context: context,
                                      isApproved: false,
                                      pendingApproval: pendingApproval!,
                                      model: servicesmanagerViewerPage!
                                          .servicesmanagersView,
                                      requestUnlockedFields: unlockedFields,
                                      dispatchEvent: (event) => context
                                          .read<ServicesManagerBloc>()
                                          .add(event),
                                      buildEvent: ({
                                        required approvalSequence,
                                        requestUnlockedFields,
                                        required model,
                                      }) =>
                                          ServicesManagerApproveEvent(
                                        approvalSequence: approvalSequence,
                                        requestUnlockedFields:
                                            requestUnlockedFields,
                                        servicesmanagerModel: model,
                                      ),
                                    );
                                  },
                                ),
                                onReject: () => approveRequest(
                                  commentController: commentController,
                                  formKey: formKey,
                                  context: context,
                                  isApproved: false,
                                  pendingApproval: pendingApproval!,
                                  model: servicesmanagerViewerPage!
                                      .servicesmanagersView,
                                  dispatchEvent: (event) => context
                                      .read<ServicesManagerBloc>()
                                      .add(event),
                                  buildEvent: ({
                                    required approvalSequence,
                                    requestUnlockedFields,
                                    required model,
                                  }) =>
                                      ServicesManagerApproveEvent(
                                    approvalSequence: approvalSequence,
                                    requestUnlockedFields:
                                        requestUnlockedFields,
                                    servicesmanagerModel: model,
                                  ),
                                ),
                                unlockedFieldsReadOnly: unlockedFieldsReadOnly,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _handleEdit() async {
    final updatedEntity = await context.push<ServicesManagerViewerPageEntity>(
      '/servicesmanager/update/${servicesmanagerViewerPage!.servicesmanagersView.requestId}',
      // extra: servicesmanagerViewerPage!.servicesmanagersView.toServicesManager()!,
    );

    if (updatedEntity != null && mounted) {
      setState(() {
        servicesmanagerViewerPage = updatedEntity;
      });
    }
  }

  @override
  void dispose() {
    for (final c in fieldControllers) {
      c.dispose();
    }
    commentController.dispose();
    super.dispose();
  }
}

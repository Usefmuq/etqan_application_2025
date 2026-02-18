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
import 'package:etqan_application_2025/src/features/vacation/domain/entities/vacation_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/usecases/fetch_vacation_page.dart';
import 'package:etqan_application_2025/src/features/vacation/presentation/bloc/vacation_bloc.dart';
import 'package:etqan_application_2025/src/features/vacation/presentation/pages/vacation_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VacationViewerPage extends StatefulWidget {
  final VacationViewerPageEntity? initialVacationViewerPage;
  final int? requestId;
  const VacationViewerPage(
      {super.key, this.initialVacationViewerPage, this.requestId});

  static route(VacationViewerPageEntity? vacationViewerPage) =>
      MaterialPageRoute(
        builder: (context) => VacationViewerPage(
          initialVacationViewerPage: vacationViewerPage,
        ),
      );

  @override
  State<VacationViewerPage> createState() => _VacationViewerPageState();
}

class _VacationViewerPageState extends State<VacationViewerPage> {
  // >>> keep your variables as-is
  VacationViewerPageEntity? vacationViewerPage;
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

    if (widget.initialVacationViewerPage != null) {
      vacationViewerPage = widget.initialVacationViewerPage!;
      _initializeApprovals();
    } else if (widget.requestId != null) {
      _fetchVacationViewerData(widget.requestId!);
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
      final fetchedServiceFields =
          await fetchFieldsByServiceId(ServicesConstants.vacationServiceId);

      // Optionally compute pendingApproval if we already have vacationViewerPage
      final fetchPendingApproval =
          await vacationViewerPage?.approval!.firstWhereOrNullAsync((a) async {
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

  void _fetchVacationViewerData(int requestId) async {
    final FetchVacationPage fetchVacationPage =
        serviceLocator<FetchVacationPage>();
    final fetched = await fetchVacationPage
        .call(FetchVacationPageParams(requestId: requestId));

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
        vacationViewerPage = fetch;
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

    final fetchPendingApproval =
        await vacationViewerPage!.approval!.firstWhereOrNullAsync((a) async {
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
      title: vacationViewerPage != null
          ? '${AppLocalizations.of(context)!.vacation}- ${vacationViewerPage!.vacationsView.requestId}'
          : AppLocalizations.of(context)!.vacation,
      tilteActions: [
        if (isUserHasPermissionsView(
              permissions ?? [],
              PermissionsConstants.updateVacation,
            ) &&
            vacationViewerPage != null &&
            vacationViewerPage!.vacationsView.toVacation() != null)
          IconButton(
            onPressed: _handleEdit,
            icon: const Icon(Icons.edit),
          ),
      ],
      body: [
        BlocConsumer<VacationBloc, VacationState>(
          listener: (context, state) {
            if (state is VacationFailure) {
              SmartNotifier.error(
                context,
                title: AppLocalizations.of(context)!.unexpectedError,
                message: state.error,
              );
            } else if (state is VacationApproveSuccess ||
                state is VacationSubmitSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                SmartNotifier.success(
                  context,
                  title: AppLocalizations.of(context)!.approvalSuccessful,
                );
                final reqId = widget.requestId ??
                    widget.initialVacationViewerPage!.vacationsView.requestId!;
                _fetchVacationViewerData(reqId);
              });
            }
          },
          builder: (context, state) {
            if (state is VacationLoading ||
                vacationViewerPage == null ||
                !isUserHasPermissionsView(
                  permissions ?? [],
                  PermissionsConstants.viewVacation,
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
                      buildDetailsSection(context, vacationViewerPage),
                      const Divider(),
                      const SizedBox(height: 12),
                      buildApprovalTableSection(
                        context,
                        vacationViewerPage?.approval,
                      ),
                      const SizedBox(height: 24),
                      if (isUserHasPermissionsView(
                            permissions ?? [],
                            PermissionsConstants.approveVacation,
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
                                  model: vacationViewerPage!.vacationsView,
                                  dispatchEvent: (event) =>
                                      context.read<VacationBloc>().add(event),
                                  buildEvent: ({
                                    required approvalSequence,
                                    required model,
                                    requestUnlockedFields,
                                  }) =>
                                      VacationApproveEvent(
                                    approvalSequence: approvalSequence,
                                    vacationModel:
                                        vacationViewerPage!.vacationsView,
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
                                  requestId: vacationViewerPage!
                                      .vacationsView.requestId!,
                                  onReturnForCorrection: (unlockedFields) {
                                    approveRequest(
                                      commentController: commentController,
                                      formKey: formKey,
                                      context: context,
                                      isApproved: false,
                                      pendingApproval: pendingApproval!,
                                      model: vacationViewerPage!.vacationsView,
                                      requestUnlockedFields: unlockedFields,
                                      dispatchEvent: (event) => context
                                          .read<VacationBloc>()
                                          .add(event),
                                      buildEvent: ({
                                        required approvalSequence,
                                        requestUnlockedFields,
                                        required model,
                                      }) =>
                                          VacationApproveEvent(
                                        approvalSequence: approvalSequence,
                                        requestUnlockedFields:
                                            requestUnlockedFields,
                                        vacationModel: model,
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
                                  model: vacationViewerPage!.vacationsView,
                                  dispatchEvent: (event) =>
                                      context.read<VacationBloc>().add(event),
                                  buildEvent: ({
                                    required approvalSequence,
                                    requestUnlockedFields,
                                    required model,
                                  }) =>
                                      VacationApproveEvent(
                                    approvalSequence: approvalSequence,
                                    requestUnlockedFields:
                                        requestUnlockedFields,
                                    vacationModel: model,
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
    final updatedEntity = await context.push<VacationViewerPageEntity>(
      '/vacations/update/${vacationViewerPage!.vacationsView.requestId}',
      // extra: vacationViewerPage!.vacationsView.toVacation()!,
    );

    if (updatedEntity != null && mounted) {
      setState(() {
        vacationViewerPage = updatedEntity;
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

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
import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/reports/domain/usecases/fetch_reports_page.dart';
import 'package:etqan_application_2025/src/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:etqan_application_2025/src/features/reports/presentation/pages/reports_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReportsViewerPage extends StatefulWidget {
  final ReportsViewerPageEntity? initialReportsViewerPage;
  final int? requestId;
  const ReportsViewerPage(
      {super.key, this.initialReportsViewerPage, this.requestId});

  static route(ReportsViewerPageEntity? reportsViewerPage) => MaterialPageRoute(
        builder: (context) => ReportsViewerPage(
          initialReportsViewerPage: reportsViewerPage,
        ),
      );

  @override
  State<ReportsViewerPage> createState() => _ReportsViewerPageState();
}

class _ReportsViewerPageState extends State<ReportsViewerPage> {
  // >>> keep your variables as-is
  ReportsViewerPageEntity? reportsViewerPage;
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

    if (widget.initialReportsViewerPage != null) {
      reportsViewerPage = widget.initialReportsViewerPage!;
      _initializeApprovals();
    } else if (widget.requestId != null) {
      _fetchReportsViewerData(widget.requestId!);
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
          await fetchFieldsByServiceId(ServicesConstants.reportsServiceId);

      // Optionally compute pendingApproval if we already have reportsViewerPage
      final fetchPendingApproval =
          await reportsViewerPage?.approval!.firstWhereOrNullAsync((a) async {
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

  void _fetchReportsViewerData(int requestId) async {
    final FetchReportsPage fetchReportsPage =
        serviceLocator<FetchReportsPage>();
    final fetched = await fetchReportsPage
        .call(FetchReportsPageParams(requestId: requestId));

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
        reportsViewerPage = fetch;
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
        await reportsViewerPage!.approval!.firstWhereOrNullAsync((a) async {
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
      title: reportsViewerPage != null
          ? '${AppLocalizations.of(context)!.report}- ${reportsViewerPage!.reportssView.requestId}'
          : AppLocalizations.of(context)!.report,
      tilteActions: [],
      body: [
        BlocConsumer<ReportsBloc, ReportsState>(
          listener: (context, state) {
            if (state is ReportsFailure) {
              SmartNotifier.error(
                context,
                title: AppLocalizations.of(context)!.unexpectedError,
                message: state.error,
              );
            } else if (state is ReportsApproveSuccess ||
                state is ReportsSubmitSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                SmartNotifier.success(
                  context,
                  title: AppLocalizations.of(context)!.approvalSuccessful,
                );
                final reqId = widget.requestId ??
                    widget.initialReportsViewerPage!.reportssView.requestId!;
                _fetchReportsViewerData(reqId);
              });
            }
          },
          builder: (context, state) {
            if (state is ReportsLoading ||
                reportsViewerPage == null ||
                !isUserHasPermissionsView(
                  permissions ?? [],
                  PermissionsConstants.viewReports,
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
                      buildDetailsSection(context, reportsViewerPage),
                      const Divider(),
                      const SizedBox(height: 12),
                      buildApprovalTableSection(
                        context,
                        reportsViewerPage?.approval,
                      ),
                      const SizedBox(height: 24),
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

  @override
  void dispose() {
    for (final c in fieldControllers) {
      c.dispose();
    }
    commentController.dispose();
    super.dispose();
  }
}

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
import 'package:etqan_application_2025/src/features/vacation/domain/entities/vacation_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/vacation/domain/usecases/fetch_vacation_page.dart';
import 'package:etqan_application_2025/src/features/vacation/presentation/bloc/vacation_bloc.dart';
import 'package:etqan_application_2025/src/features/vacation/presentation/pages/vacation_input_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UpdateVacationPage extends StatefulWidget {
  final VacationViewerPageEntity? initialVacationViewerPage;
  final int? requestId;
  const UpdateVacationPage(
      {super.key, this.initialVacationViewerPage, this.requestId});
  static route(VacationViewerPageEntity vacationViewerPage) =>
      MaterialPageRoute(
        builder: (context) =>
            UpdateVacationPage(initialVacationViewerPage: vacationViewerPage),
      );

  @override
  State<UpdateVacationPage> createState() => _UpdateVacationPageState();
}

class _UpdateVacationPageState extends State<UpdateVacationPage> {
  List<String>? permissions;
  List<RequestUnlockedFieldModel>? unlockedFields;
  VacationViewerPageEntity? vacationViewerPage;
  final TextEditingController reason = TextEditingController();
  String? vacationTypeId;
  DateTime? startDate;
  DateTime? endDate;
  double? daysCount;
  final formKey = GlobalKey<FormState>();
  String userId = '';
  List<ServiceField> serviceFields = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialVacationViewerPage != null) {
      vacationViewerPage = widget.initialVacationViewerPage!;
      vacationTypeId = vacationViewerPage!.vacationsView.vacationTypeId!;
      startDate = vacationViewerPage!.vacationsView.startDate!;
      endDate = vacationViewerPage!.vacationsView.endDate!;
      daysCount = vacationViewerPage!.vacationsView.daysCount!;
      reason.text = vacationViewerPage!.vacationsView.reason!;
    } else if (widget.requestId != null) {
      _fetchVacationViewerData(widget.requestId!);
    }

    userId = (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;
    Future.microtask(() async {
      // final fetchedUnlockedFields =
      //     await fetchUnlockedFields(vacationViewerPage?.vacationsView.requestId ?? -1);
      final fetchedPermissions = await fetchUserPermissions(userId);
      final fetchedServiceFields =
          await fetchFieldsByServiceId(ServicesConstants.vacationServiceId);

      final reqId = widget.requestId ??
          widget.initialVacationViewerPage?.vacationsView.requestId;
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

  void _fetchVacationViewerData(int requestId) async {
    final FetchVacationPage fetchVacationPage = serviceLocator<
        FetchVacationPage>(); // ✅ Get use case from service locator

    final fetched = await fetchVacationPage.call(
        FetchVacationPageParams(requestId: requestId)); // Implement this fetch
    final fetchedUnlockedFields = await fetchUnlockedFields(requestId);

    fetched.fold((failure) {
      return;
    }, (fetch) {
      if (mounted) {
        setState(() {
          vacationViewerPage = fetch;
          unlockedFields = fetchedUnlockedFields;
          vacationTypeId = vacationViewerPage!.vacationsView.vacationTypeId!;
          reason.text = vacationViewerPage!.vacationsView.reason!;
          startDate = vacationViewerPage!.vacationsView.startDate!;
          endDate = vacationViewerPage!.vacationsView.endDate!;
          daysCount = vacationViewerPage!.vacationsView.daysCount!;
        });
      }
    });
  }

  void _updateVacation() {
    if (!(formKey.currentState?.validate() ?? false)) return;

    context.read<VacationBloc>().add(
          VacationUpdateEvent(
            vacationViewerPage: vacationViewerPage!.vacationsView.copyWith(
              vacationTypeId: vacationTypeId,
              reason: reason.text,
              startDate: startDate,
              endDate: endDate,
              daysCount: daysCount,
            ),
            updatedBy: userId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: vacationViewerPage?.vacationsView.requestId != null
          ? '${AppLocalizations.of(context)!.vacationUpdate} #${vacationViewerPage!.vacationsView.requestId}'
          : AppLocalizations.of(context)!.vacation,
      showDrawer: false,
      body: [
        BlocConsumer<VacationBloc, VacationState>(
          listener: (context, state) {
            if (state is VacationFailure) {
              SmartNotifier.error(context,
                  title: AppLocalizations.of(context)!.error,
                  message: state.error);
            } else if (state is VacationUpdateSuccess) {
              context.pop(state.vacationViewerPageEntity);
              SmartNotifier.success(
                context,
                title: AppLocalizations.of(context)!.approvalSuccessful,
              );
            }
          },
          builder: (context, state) {
            if (state is VacationLoading ||
                vacationViewerPage == null ||
                !isUserHasPermissionsView(
                    permissions ?? [], PermissionsConstants.updateVacation)) {
              return const Loader();
            }
// compute using the data you actually have at build time
            final currentCreatedById =
                vacationViewerPage?.vacationsView.createdById ??
                    widget.initialVacationViewerPage?.vacationsView.createdById;

// approver = has update permission (your existing flag)
            final isApprover = isUserHasPermissionsView(
                permissions ?? [], PermissionsConstants.updateVacation);

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
                        ...VacationInputSection.build(
                          serviceFields: serviceFields,
                          isLockFieldsWithoutComment:
                              isLockFieldsWithoutComment,
                          setState: setState,
                          vacationTypeId: vacationTypeId,
                          onVacationTypeChanged: (val) {
                            setState(() {
                              vacationTypeId = val;
                            });
                          },
                          reason: reason,
                          startDate: startDate,
                          onStartDateChanged: (d) =>
                              setState(() => startDate = d),
                          endDate: endDate,
                          onEndDateChanged: (d) => setState(() => endDate = d),
                          daysCount: daysCount,
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
                                  vacationViewerPage
                                          ?.vacationsView.requestStatusId !=
                                      LookupConstants
                                          .requestStatusReturnForCorrection,
                              onPressed: _updateVacation,
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
    reason.dispose();
  }
}

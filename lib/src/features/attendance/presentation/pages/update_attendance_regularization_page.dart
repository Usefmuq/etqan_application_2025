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
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_regularization_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/usecases/fetch_attendance_regularization_page.dart';
import 'package:etqan_application_2025/src/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:etqan_application_2025/src/features/attendance/presentation/pages/attendance_regularization_input_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UpdateAttendanceRegularizationPage extends StatefulWidget {
  final AttendanceRegularizationViewerPageEntity?
      initialAttendanceRegularizationViewerPage;
  final int? requestId;
  const UpdateAttendanceRegularizationPage(
      {super.key,
      this.initialAttendanceRegularizationViewerPage,
      this.requestId});
  static route(
          AttendanceRegularizationViewerPageEntity
              attendanceregularizationViewerPage) =>
      MaterialPageRoute(
        builder: (context) => UpdateAttendanceRegularizationPage(
            initialAttendanceRegularizationViewerPage:
                attendanceregularizationViewerPage),
      );

  @override
  State<UpdateAttendanceRegularizationPage> createState() =>
      _UpdateAttendanceRegularizationPageState();
}

class _UpdateAttendanceRegularizationPageState
    extends State<UpdateAttendanceRegularizationPage> {
  List<String>? permissions;
  List<RequestUnlockedFieldModel>? unlockedFields;
  AttendanceRegularizationViewerPageEntity? attendanceregularizationViewerPage;
  final TextEditingController reasonController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  bool includeWeekends = false;
  String? proposedCheckIn;
  String? proposedCheckOut;
  final formKey = GlobalKey<FormState>();
  String userId = '';
  List<ServiceField> serviceFields = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialAttendanceRegularizationViewerPage != null) {
      attendanceregularizationViewerPage =
          widget.initialAttendanceRegularizationViewerPage!;
      reasonController.text =
          attendanceregularizationViewerPage!.attendancesView.reason;
    } else if (widget.requestId != null) {
      _fetchAttendanceRegularizationViewerData(widget.requestId!);
    }

    userId = (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;
    Future.microtask(() async {
      // final fetchedUnlockedFields =
      //     await fetchUnlockedFields(attendanceregularizationViewerPage?.attendanceregularizationsView.requestId ?? -1);
      final fetchedPermissions = await fetchUserPermissions(userId);
      final fetchedServiceFields = await fetchFieldsByServiceId(
          ServicesConstants.attendanceRegularizationServiceId);

      final reqId = widget.requestId ??
          widget.initialAttendanceRegularizationViewerPage?.attendancesView
              .requestId;
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

  void _fetchAttendanceRegularizationViewerData(int requestId) async {
    final FetchAttendanceRegularizationPage fetchAttendanceRegularizationPage =
        serviceLocator<
            FetchAttendanceRegularizationPage>(); // ✅ Get use case from service locator

    final fetched = await fetchAttendanceRegularizationPage.call(
        FetchAttendanceRegularizationPageParams(
            requestId: requestId)); // Implement this fetch
    final fetchedUnlockedFields = await fetchUnlockedFields(requestId);

    fetched.fold((failure) {
      return;
    }, (fetch) {
      if (mounted) {
        setState(() {
          attendanceregularizationViewerPage = fetch;
          unlockedFields = fetchedUnlockedFields;
          reasonController.text =
              attendanceregularizationViewerPage!.attendancesView.reason;
        });
      }
    });
  }

  void _updateAttendanceRegularization() {
    if (!(formKey.currentState?.validate() ?? false)) return;

    context.read<AttendanceBloc>().add(
          AttendanceRegularizationUpdateEvent(
            attendanceRegularizationViewerPage:
                attendanceregularizationViewerPage!.attendancesView.copyWith(
              startDate: startDate!,
              endDate: endDate!,
              includeWeekends: includeWeekends,
              proposedCheckIn: proposedCheckIn,
              proposedCheckOut: proposedCheckOut,
              reason: reasonController.text,
            ),
            updatedBy: userId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: attendanceregularizationViewerPage?.attendancesView.requestId !=
              null
          ? '${AppLocalizations.of(context)!.attendanceRegularizationUpdate} #${attendanceregularizationViewerPage!.attendancesView.requestId}'
          : AppLocalizations.of(context)!.attendanceRegularization,
      showDrawer: false,
      body: [
        BlocConsumer<AttendanceBloc, AttendanceState>(
          listener: (context, state) {
            if (state is AttendanceFailure) {
              SmartNotifier.error(context,
                  title: AppLocalizations.of(context)!.error,
                  message: state.error);
            } else if (state is AttendanceRegularizationUpdateSuccess) {
              context.pop(state.attendanceRegularizationViewerPageEntity);
              SmartNotifier.success(
                context,
                title: AppLocalizations.of(context)!.approvalSuccessful,
              );
            }
          },
          builder: (context, state) {
            if (state is AttendanceLoading ||
                attendanceregularizationViewerPage == null ||
                !isUserHasPermissionsView(permissions ?? [],
                    PermissionsConstants.updateAttendanceRegularization)) {
              return const Loader();
            }
// compute using the data you actually have at build time
            final currentCreatedById = attendanceregularizationViewerPage
                    ?.attendancesView.createdById ??
                widget.initialAttendanceRegularizationViewerPage
                    ?.attendancesView.createdById;

// approver = has update permission (your existing flag)
            final isApprover = isUserHasPermissionsView(permissions ?? [],
                PermissionsConstants.updateAttendanceRegularization);

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
                        ...AttendanceRegularizationInputSection.build(
                          serviceFields: serviceFields,
                          isLockFieldsWithoutComment:
                              isLockFieldsWithoutComment,
                          setState: setState,
                          reasonController: reasonController,
                          startDate: startDate,
                          onStartDateChanged: (d) => setState(() {
                            startDate = d;
                          }),
                          endDate: endDate,
                          onEndDateChanged: (d) => setState(() {
                            endDate = d;
                          }),
                          includeWeekends: includeWeekends,
                          onChangedIncludeWeekends: (bool newValue) {
                            setState(() {
                              includeWeekends = newValue;
                            });
                          },
                          onProposedCheckInChanged: (String? newValue) {
                            setState(() {
                              proposedCheckIn = newValue;
                            });
                          },
                          onProposedCheckOutChanged: (String? newValue) {
                            setState(() {
                              proposedCheckOut = newValue;
                            });
                          },
                          proposedCheckIn: proposedCheckIn,
                          proposedCheckOut: proposedCheckOut,
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
                                  attendanceregularizationViewerPage
                                          ?.attendancesView.requestStatusId !=
                                      LookupConstants
                                          .requestStatusReturnForCorrection,
                              onPressed: _updateAttendanceRegularization,
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
    reasonController.dispose();
  }
}

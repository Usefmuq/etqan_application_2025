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
import 'package:etqan_application_2025/src/features/attendance/domain/entities/attendance_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/attendance/domain/usecases/fetch_attendance_page.dart';
import 'package:etqan_application_2025/src/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:etqan_application_2025/src/features/attendance/presentation/pages/attendance_input_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UpdateAttendancePage extends StatefulWidget {
  final AttendanceViewerPageEntity? initialAttendanceViewerPage;
  final int? requestId;
  const UpdateAttendancePage(
      {super.key, this.initialAttendanceViewerPage, this.requestId});
  static route(AttendanceViewerPageEntity attendanceViewerPage) =>
      MaterialPageRoute(
        builder: (context) => UpdateAttendancePage(
            initialAttendanceViewerPage: attendanceViewerPage),
      );

  @override
  State<UpdateAttendancePage> createState() => _UpdateAttendancePageState();
}

class _UpdateAttendancePageState extends State<UpdateAttendancePage> {
  List<String>? permissions;
  List<RequestUnlockedFieldModel>? unlockedFields;
  AttendanceViewerPageEntity? attendanceViewerPage;
  final TextEditingController titleControler = TextEditingController();
  final TextEditingController contentControler = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String userId = '';
  List<ServiceField> serviceFields = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialAttendanceViewerPage != null) {
      attendanceViewerPage = widget.initialAttendanceViewerPage!;
      titleControler.text = attendanceViewerPage!.attendancesView.title!;
      contentControler.text = attendanceViewerPage!.attendancesView.content!;
    } else if (widget.requestId != null) {
      _fetchAttendanceViewerData(widget.requestId!);
    }

    userId = (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;
    Future.microtask(() async {
      // final fetchedUnlockedFields =
      //     await fetchUnlockedFields(attendanceViewerPage?.attendancesView.requestId ?? -1);
      final fetchedPermissions = await fetchUserPermissions(userId);
      final fetchedServiceFields =
          await fetchFieldsByServiceId(ServicesConstants.attendanceServiceId);

      final reqId = widget.requestId ??
          widget.initialAttendanceViewerPage?.attendancesView.requestId;
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

  void _fetchAttendanceViewerData(int requestId) async {
    final FetchAttendancePage fetchAttendancePage = serviceLocator<
        FetchAttendancePage>(); // ✅ Get use case from service locator

    final fetched = await fetchAttendancePage.call(FetchAttendancePageParams(
        requestId: requestId)); // Implement this fetch
    final fetchedUnlockedFields = await fetchUnlockedFields(requestId);

    fetched.fold((failure) {
      return;
    }, (fetch) {
      if (mounted) {
        setState(() {
          attendanceViewerPage = fetch;
          unlockedFields = fetchedUnlockedFields;
          titleControler.text = attendanceViewerPage!.attendancesView.title!;
          contentControler.text =
              attendanceViewerPage!.attendancesView.content!;
        });
      }
    });
  }

  void _updateAttendance() {
    if (!(formKey.currentState?.validate() ?? false)) return;

    context.read<AttendanceBloc>().add(
          AttendanceUpdateEvent(
            attendanceViewerPage:
                attendanceViewerPage!.attendancesView.copyWith(
              title: titleControler.text,
              content: contentControler.text,
            ),
            updatedBy: userId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: attendanceViewerPage?.attendancesView.requestId != null
          ? '${AppLocalizations.of(context)!.attendanceUpdate} #${attendanceViewerPage!.attendancesView.requestId}'
          : AppLocalizations.of(context)!.attendance,
      showDrawer: false,
      body: [
        BlocConsumer<AttendanceBloc, AttendanceState>(
          listener: (context, state) {
            if (state is AttendanceFailure) {
              SmartNotifier.error(context,
                  title: AppLocalizations.of(context)!.error,
                  message: state.error);
            } else if (state is AttendanceUpdateSuccess) {
              context.pop(state.attendanceViewerPageEntity);
              SmartNotifier.success(
                context,
                title: AppLocalizations.of(context)!.approvalSuccessful,
              );
            }
          },
          builder: (context, state) {
            if (state is AttendanceLoading ||
                attendanceViewerPage == null ||
                !isUserHasPermissionsView(
                    permissions ?? [], PermissionsConstants.updateAttendance)) {
              return const Loader();
            }
// compute using the data you actually have at build time
            final currentCreatedById = attendanceViewerPage
                    ?.attendancesView.createdById ??
                widget.initialAttendanceViewerPage?.attendancesView.createdById;

// approver = has update permission (your existing flag)
            final isApprover = isUserHasPermissionsView(
                permissions ?? [], PermissionsConstants.updateAttendance);

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
                        ...AttendanceInputSection.build(
                          serviceFields: serviceFields,
                          isLockFieldsWithoutComment:
                              isLockFieldsWithoutComment,
                          setState: setState,
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
                              text: AppLocalizations.of(context)!.update,
                              isDisabled: isCreator &&
                                  attendanceViewerPage
                                          ?.attendancesView.requestStatusId !=
                                      LookupConstants
                                          .requestStatusReturnForCorrection,
                              onPressed: _updateAttendance,
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

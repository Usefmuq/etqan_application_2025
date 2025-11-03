import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/entities/service_fields.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_help_card.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_button.dart';
import 'package:etqan_application_2025/src/core/common/widgets/grids/custom_table_grid.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/constants/settings_constants.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:etqan_application_2025/src/core/utils/calculate_utils.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:etqan_application_2025/src/core/utils/lookups_and_constants.dart';
import 'package:etqan_application_2025/src/core/utils/notifier.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/features/attendance/data/models/attendance_session_model.dart';
import 'package:etqan_application_2025/src/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:etqan_application_2025/src/features/attendance/presentation/pages/attendance_input_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class AddNewAttendancePage extends StatefulWidget {
  const AddNewAttendancePage({super.key});
  static route() => MaterialPageRoute(
        builder: (context) => const AddNewAttendancePage(),
      );
  @override
  State<AddNewAttendancePage> createState() => _AddNewAttendancePageState();
}

class _AddNewAttendancePageState extends State<AddNewAttendancePage> {
  List<String>? permissions;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<ServiceField> serviceFields = [];
  List<AttendanceSessionModel> latestAttendances = [];
  double? _lat;
  double? _lng;
  double? distanceMeters;
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
    final userId = userState.user.id;

    Future.microtask(() async {
      final fetchedPermissions = await fetchUserPermissions(userId);
      final fetchedServiceFields =
          await fetchFieldsByServiceId(ServicesConstants.attendanceServiceId);
      final fetchedLatestAttendances = await fetchLatestAttendances(userId);

      if (mounted) {
        setState(() {
          permissions = fetchedPermissions;
          serviceFields = fetchedServiceFields;
          latestAttendances = fetchedLatestAttendances;
        });
      }
    });
  }

  void _handleLatLng(double lat, double lng) {
    setState(() {
      _lat = lat;
      _lng = lng;
      distanceMeters = distanceMetersNullable(
        lat1: _lat,
        lng1: _lng,
        lat2: SettingsConstants.attendanceSiteLat,
        lng2: SettingsConstants.attendanceSiteLng,
      );
      print("$_lat $lng");
    });
  }

  void _submitAttendance(bool isCheckIn) {
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
      context.read<AttendanceBloc>().add(
            AttendanceSubmitEvent(
                attendance: AttendanceSessionModel(
              id: '',
              userId: createdById,
              sourceKey: 'emp_gps',
              startAt: DateTime.now(),
              startLat: _lat,
              startLng: _lng,
              endAt: !isCheckIn ? DateTime.now() : null,
              endLat: !isCheckIn ? _lat : null,
              endLng: !isCheckIn ? _lng : null,
            )),
          );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: AppLocalizations.of(context)!.attendanceSubmitNew,

      showDrawer: false,
      // tilteActions: [
      //   IconButton(
      //     onPressed: _submitAttendance,
      //     icon: Icon(Icons.done_rounded),
      //   )
      // ],
      body: [
        BlocConsumer<AttendanceBloc, AttendanceState>(
          listener: (context, state) {
            if (state is AttendanceFailure) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                SmartNotifier.error(
                  context,
                  title: AppLocalizations.of(context)!.error,
                  message: state.error,
                );
              });
            } else if (state is AttendanceSubmitSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) context.pushReplacement('/attendance/submit');
              });
            }
          },
          builder: (context, state) {
            final permsReady = permissions != null;
            final canAdd = isUserHasPermissionsView(
              permissions ?? const [],
              PermissionsConstants.addAttendance,
            );

            if (state is AttendanceLoading || !permsReady) {
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
                        ...AttendanceInputSection.build(
                          serviceFields: serviceFields,
                          isLockFieldsWithoutComment: false,
                          setState: setState,
                          // onToggleTopic: (topic) {
                          //   setState(() {
                          //     selectedTopics.contains(topic)
                          //         ? selectedTopics.remove(topic)
                          //         : selectedTopics.add(topic);
                          //   });
                          // },
                          titleController: titleController,
                          contentController: contentController,
                          isWide: isWide,
                          onLatLng: _handleLatLng,
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: [
                              CustomButton(
                                width: 180,
                                icon: Icons.check_circle,
                                isDisabled:
                                    latestAttendances.first.endAt.isNullOrEmpty,
                                text:
                                    "${AppLocalizations.of(context)!.attendanceCheckIn} ${latestAttendances.first.endAt.isNullOrEmpty ? DateFormat.yMMMd(Localizations.localeOf(context).languageCode).add_jm().format(latestAttendances.first.startAt) : ""}",
                                onPressed: () => _submitAttendance(true),
                              ),
                              CustomButton(
                                width: 180,
                                icon: Icons.cancel,
                                text: AppLocalizations.of(context)!
                                    .attendanceCheckOut,
                                // type: ButtonType.outlined,
                                isDisabled: !latestAttendances
                                    .first.endAt.isNullOrEmpty,
                                backgroundColor: AppPallete.errorColor,
                                onPressed: () => _submitAttendance(false),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (distanceMeters.isNullOrEmpty ||
                            distanceMeters! >
                                SettingsConstants.maxSiteDistanceM)
                          CustomHelpCard(
                            type: HelpCardType.warning,
                            title: AppLocalizations.of(context)!
                                .attendanceLocationFar,
                            description: AppLocalizations.of(context)!
                                .attendanceLocationFarDesc,
                          ),
                        const SizedBox(height: 24),
                        Divider(thickness: 1.5, color: AppPallete.greyColor),
                        const SizedBox(height: 32),
                        CustomTableGrid(
                          headers: [
                            AppLocalizations.of(context)!.attendanceCheckIn,
                            AppLocalizations.of(context)!.attendanceCheckOut,
                            AppLocalizations.of(context)!.total,
                          ],
                          rows: latestAttendances
                              .map((u) => u.toTableRow())
                              .toList(),
                        )
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

import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/entities/service_fields.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_button.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:etqan_application_2025/src/core/utils/calculate_utils.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:etqan_application_2025/src/core/utils/lookups_and_constants.dart';
import 'package:etqan_application_2025/src/core/utils/notifier.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/features/vacation/presentation/bloc/vacation_bloc.dart';
import 'package:etqan_application_2025/src/features/vacation/presentation/pages/vacation_input_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddNewVacationPage extends StatefulWidget {
  const AddNewVacationPage({super.key});
  static route() => MaterialPageRoute(
        builder: (context) => const AddNewVacationPage(),
      );
  @override
  State<AddNewVacationPage> createState() => _AddNewVacationPageState();
}

class _AddNewVacationPageState extends State<AddNewVacationPage> {
  List<String>? permissions;
  final TextEditingController reason = TextEditingController();
  String? vacationTypeId;
  DateTime? startDate;
  DateTime? endDate;
  double? daysCount;
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
    final userId = userState.user.id;

    Future.microtask(() async {
      final fetchedPermissions = await fetchUserPermissions(userId);
      final fetchedServiceFields =
          await fetchFieldsByServiceId(ServicesConstants.vacationServiceId);

      if (mounted) {
        setState(() {
          permissions = fetchedPermissions;
          serviceFields = fetchedServiceFields;
        });
      }
    });
  }

  void _submitVacation() {
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
      context.read<VacationBloc>().add(
            VacationSubmitEvent(
              createdById: createdById,
              vacationTypeId: vacationTypeId ?? '',
              reason: reason.text.trim(),
              startDate: startDate!,
              endDate: endDate!,
              daysCount: daysCount!,
            ),
          );
    }
  }

  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: AppLocalizations.of(context)!.vacationSubmitNew,

      showDrawer: false,
      // tilteActions: [
      //   IconButton(
      //     onPressed: _submitVacation,
      //     icon: Icon(Icons.done_rounded),
      //   )
      // ],
      body: [
        BlocConsumer<VacationBloc, VacationState>(
          listener: (context, state) {
            if (state is VacationFailure) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                SmartNotifier.error(
                  context,
                  title: AppLocalizations.of(context)!.error,
                  message: state.error,
                );
              });
            } else if (state is VacationSubmitSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) context.pop();
              });
            }
          },
          builder: (context, state) {
            final permsReady = permissions != null;
            final canAdd = isUserHasPermissionsView(
              permissions ?? const [],
              PermissionsConstants.addVacation,
            );

            if (state is VacationLoading || !permsReady) {
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
                        ...VacationInputSection.build(
                          serviceFields: serviceFields,
                          isLockFieldsWithoutComment: false,
                          setState: setState,
                          vacationTypeId: vacationTypeId,
                          onVacationTypeChanged: (val) {
                            setState(() {
                              vacationTypeId = val;
                            });
                          },
                          startDate: startDate,
                          onStartDateChanged: (d) => setState(() {
                            startDate = d;
                            if (!startDate.isNullOrEmpty &&
                                !endDate.isNullOrEmpty) {
                              daysCount =
                                  calculateBusinessDays(startDate!, endDate!)
                                      .toDouble();
                            }
                          }),
                          reason: reason,
                          endDate: endDate,
                          onEndDateChanged: (d) => setState(() {
                            endDate = d;
                            if (!startDate.isNullOrEmpty &&
                                !endDate.isNullOrEmpty) {
                              daysCount =
                                  calculateBusinessDays(startDate!, endDate!)
                                      .toDouble();
                            }
                          }),
                          daysCount: daysCount,
                          isWide: isWide,
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
                              text: AppLocalizations.of(context)!.submit,
                              onPressed: _submitVacation,
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

// import 'package:etqan_application_2025/init_dependencies.dart';
// import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
// import 'package:etqan_application_2025/src/core/common/entities/service_fields.dart';
// import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_button.dart';
// import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
// import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
// import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
// import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
// import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
// import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
// import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
// import 'package:etqan_application_2025/src/core/utils/approval_sequence_utils.dart';
// import 'package:etqan_application_2025/src/core/utils/lookups_and_constants.dart';
// import 'package:etqan_application_2025/src/core/utils/notifier.dart';
// import 'package:etqan_application_2025/src/core/utils/permission.dart';
// import 'package:etqan_application_2025/src/features/reports/domain/entities/reports_viewer_page_entity.dart';
// import 'package:etqan_application_2025/src/features/reports/domain/usecases/fetch_reports_page.dart';
// import 'package:etqan_application_2025/src/features/reports/presentation/bloc/reports_bloc.dart';
// import 'package:etqan_application_2025/src/features/reports/presentation/pages/reports_input_widgets.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// class UpdateReportsPage extends StatefulWidget {
//   final ReportsViewerPageEntity? initialReportsViewerPage;
//   final int? requestId;
//   const UpdateReportsPage(
//       {super.key, this.initialReportsViewerPage, this.requestId});
//   static route(ReportsViewerPageEntity reportsViewerPage) => MaterialPageRoute(
//         builder: (context) =>
//             UpdateReportsPage(initialReportsViewerPage: reportsViewerPage),
//       );

//   @override
//   State<UpdateReportsPage> createState() => _UpdateReportsPageState();
// }

// class _UpdateReportsPageState extends State<UpdateReportsPage> {
//   List<String>? permissions;
//   List<RequestUnlockedFieldModel>? unlockedFields;
//   ReportsViewerPageEntity? reportsViewerPage;
//   final TextEditingController titleControler = TextEditingController();
//   final TextEditingController contentControler = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//   List<String> selectedTopics = [];
//   String userId = '';
//   List<ServiceField> serviceFields = [];

//   @override
//   void initState() {
//     super.initState();
//     if (widget.initialReportsViewerPage != null) {
//       reportsViewerPage = widget.initialReportsViewerPage!;
//       selectedTopics = reportsViewerPage!.reportssView.topics!;
//       titleControler.text = reportsViewerPage!.reportssView.title!;
//       contentControler.text = reportsViewerPage!.reportssView.content!;
//     } else if (widget.requestId != null) {
//       _fetchReportsViewerData(widget.requestId!);
//     }

//     userId = (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;
//     Future.microtask(() async {
//       // final fetchedUnlockedFields =
//       //     await fetchUnlockedFields(reportsViewerPage?.reportssView.requestId ?? -1);
//       final fetchedPermissions = await fetchUserPermissions(userId);
//       final fetchedServiceFields =
//           await fetchFieldsByServiceId(ServicesConstants.reportsServiceId);

//       final reqId = widget.requestId ??
//           widget.initialReportsViewerPage?.reportssView.requestId;
//       List<RequestUnlockedFieldModel>? fetchedUnlockedFields;
//       if (reqId != null) {
//         fetchedUnlockedFields = await fetchUnlockedFields(reqId);
//       }
//       if (!mounted) return;
//       setState(() {
//         permissions = fetchedPermissions;
//         unlockedFields = fetchedUnlockedFields; // may be null initially
//         serviceFields = fetchedServiceFields;
//       });
//     });
//   }

//   void _fetchReportsViewerData(int requestId) async {
//     final FetchReportsPage fetchReportsPage = serviceLocator<
//         FetchReportsPage>(); // ✅ Get use case from service locator

//     final fetched = await fetchReportsPage.call(
//         FetchReportsPageParams(requestId: requestId)); // Implement this fetch
//     final fetchedUnlockedFields = await fetchUnlockedFields(requestId);

//     fetched.fold((failure) {
//       return;
//     }, (fetch) {
//       if (mounted) {
//         setState(() {
//           reportsViewerPage = fetch;
//           unlockedFields = fetchedUnlockedFields;
//           selectedTopics = reportsViewerPage!.reportssView.topics!;
//           titleControler.text = reportsViewerPage!.reportssView.title!;
//           contentControler.text = reportsViewerPage!.reportssView.content!;
//         });
//       }
//     });
//   }

//   void _updateReports() {
//     if (!(formKey.currentState?.validate() ?? false)) return;

//     if (selectedTopics.isEmpty) {
//       SmartNotifier.warning(
//         context,
//         title: AppLocalizations.of(context)!.error,
//         message: AppLocalizations.of(context)!.fieldIsRequired,
//       );
//       return;
//     }
//     context.read<ReportsBloc>().add(
//           ReportsUpdateEvent(
//             reportsViewerPage: reportsViewerPage!.reportssView.copyWith(
//               title: titleControler.text,
//               content: contentControler.text,
//               topics: selectedTopics,
//             ),
//             updatedBy: userId,
//           ),
//         );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomScaffold(
//       title: reportsViewerPage?.reportssView.requestId != null
//           ? '${AppLocalizations.of(context)!.reportUpdate} #${reportsViewerPage!.reportssView.requestId}'
//           : AppLocalizations.of(context)!.report,
//       showDrawer: false,
//       body: [
//         BlocConsumer<ReportsBloc, ReportsState>(
//           listener: (context, state) {
//             if (state is ReportsFailure) {
//               SmartNotifier.error(context,
//                   title: AppLocalizations.of(context)!.error,
//                   message: state.error);
//             } else if (state is ReportsUpdateSuccess) {
//               context.pop(state.reportsViewerPageEntity);
//               SmartNotifier.success(
//                 context,
//                 title: AppLocalizations.of(context)!.approvalSuccessful,
//               );
//             }
//           },
//           builder: (context, state) {
//             if (state is ReportsLoading ||
//                 reportsViewerPage == null ||
//                 !isUserHasPermissionsView(
//                     permissions ?? [], PermissionsConstants.updateReports)) {
//               return const Loader();
//             }
// // compute using the data you actually have at build time
//             final currentCreatedById =
//                 reportsViewerPage?.reportssView.createdById ??
//                     widget.initialReportsViewerPage?.reportssView.createdById;

// // approver = has update permission (your existing flag)
//             final isApprover = isUserHasPermissionsView(
//                 permissions ?? [], PermissionsConstants.updateReports);

// // creator?
//             final isCreator = currentCreatedById == userId;

// // lock mode: submitter should be locked (except returned fields).
// // approver (not creator) can edit regardless; otherwise locked.
//             final isLockFieldsWithoutComment = !(isApprover && !isCreator);

//             return Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Form(
//                 key: formKey,
//                 child: LayoutBuilder(
//                   builder: (context, constraints) {
//                     final isWide = constraints.maxWidth >= 600;
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         ...ReportsInputSection.build(
//                           serviceFields: serviceFields,
//                           isLockFieldsWithoutComment:
//                               isLockFieldsWithoutComment,
//                           setState: setState,
//                           selectedTopics: selectedTopics,
//                           // onToggleTopic: (topic) {
//                           //   setState(() {
//                           //     selectedTopics.contains(topic)
//                           //         ? selectedTopics.remove(topic)
//                           //         : selectedTopics.add(topic);
//                           //   });
//                           // },
//                           titleController: titleControler,
//                           contentController: contentControler,
//                           isWide: isWide,
//                           unlockedFields: unlockedFields,
//                         ),
//                         const SizedBox(height: 40),
//                         Divider(thickness: 1.5, color: AppPallete.greyColor),
//                         const SizedBox(height: 24),
//                         Wrap(
//                           spacing: 16,
//                           runSpacing: 12,
//                           alignment: WrapAlignment.spaceBetween,
//                           children: [
//                             CustomButton(
//                               width: 180,
//                               icon: Icons.check_circle,
//                               text: AppLocalizations.of(context)!.update,
//                               isDisabled: isCreator &&
//                                   reportsViewerPage
//                                           ?.reportssView.requestStatusId !=
//                                       LookupConstants
//                                           .requestStatusReturnForCorrection,
//                               onPressed: _updateReports,
//                             ),
//                             CustomButton(
//                               width: 180,
//                               icon: Icons.cancel,
//                               text: AppLocalizations.of(context)!.cancel,
//                               backgroundColor: AppPallete.errorColor,
//                               onPressed: context.pop,
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 32),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     titleControler.dispose();
//     contentControler.dispose();
//   }
// }

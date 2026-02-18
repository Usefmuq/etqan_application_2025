// import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
// import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_button.dart';
// import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_text_form_field.dart';
// import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
// import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
// import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
// import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
// import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
// import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
// import 'package:etqan_application_2025/src/core/utils/notifier.dart';
// import 'package:etqan_application_2025/src/core/utils/permission.dart';
// import 'package:etqan_application_2025/src/features/vacation/data/models/vacation_page_view_model.dart';
// import 'package:etqan_application_2025/src/features/vacation/presentation/bloc/vacation_bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// class ApproveVacationPage extends StatefulWidget {
//   final VacationsPageViewModel vacation;
//   final ApprovalSequenceViewModel approvalSequence;
//   const ApproveVacationPage({
//     super.key,
//     required this.vacation,
//     required this.approvalSequence,
//   });
//   static route(
//     VacationsPageViewModel vacation,
//     ApprovalSequenceViewModel approvalSequence,
//   ) =>
//       MaterialPageRoute(
//         builder: (context) => ApproveVacationPage(
//           vacation: vacation,
//           approvalSequence: approvalSequence,
//         ),
//       );

//   @override
//   State<ApproveVacationPage> createState() => _ApproveVacationPageState();
// }

// class _ApproveVacationPageState extends State<ApproveVacationPage> {
//   List<String>? permissions;

//   late VacationsPageViewModel
//       vacation; // Declare a variable to hold the Vacation object
//   late ApprovalSequenceViewModel
//       approvalSequence; // Declare a variable to hold the Vacation object

//   final TextEditingController titleControler = TextEditingController();
//   final TextEditingController contentControler = TextEditingController();
//   final TextEditingController commentController = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//   String vacationTypeId = [];

//   void _approveVacation({required bool isApproved}) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(isApproved ? 'Confirm Approval' : 'Confirm Rejection'),
//         content: Text(isApproved
//             ? 'Are you sure you want to approve this vacation?'
//             : 'Are you sure you want to reject this vacation?'),
//         actions: [
//           TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('Cancel')),
//           TextButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text('Yes')),
//         ],
//       ),
//     );
//     if (!mounted) return; // ✅ Prevent using context if widget is disposed

//     if (confirmed != true) return;

//     if (formKey.currentState!.validate() && selectedTopics.isNotEmpty) {
//       final updatedApproval = widget.approvalSequence.copyWith(
//         approvalStatus: isApproved
//             ? LookupConstants.approvalStatusApprovalApproved
//             : LookupConstants.approvalStatusApprovalRejected,
//         approverComment: commentController.text,
//       );

//       context.read<VacationBloc>().add(
//             VacationApproveEvent(
//               approvalSequence: updatedApproval,
//               vacationModel: vacation,
//             ),
//           );
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     final userId =
//         (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;

//     Future.microtask(() async {
//       final fetchedPermissions = await fetchUserPermissions(userId);

//       if (mounted) {
//         setState(() {
//           permissions = fetchedPermissions;
//         });
//       }
//     });
//     vacation = widget.vacation; // Assign the Vacation object in initState
//   }

//   @override
//   Widget build(BuildContext context) {
//     selectedTopics = vacation.topics ?? [];
//     titleControler.text = vacation.title ?? "";
//     contentControler.text = vacation.content ?? "";

//     return CustomScaffold(
//       title: 'Approve Vacation-${widget.vacation.requestId}',
//       showDrawer: false,
//       tilteActions: [
//         // if (isUserHasPermissionsView(
//         //   permissions ?? [],
//         //   PermissionsConstants.approveVacation,
//         // ))
//         //   IconButton(
//         //     onPressed: _approveVacation,
//         //     icon: const Icon(Icons.done_rounded),
//         //   )
//       ],
//       body: [
//         BlocConsumer<VacationBloc, VacationState>(
//           listener: (context, state) {
//             if (state is VacationFailure) {
//               SmartNotifier.error(context,
//                   title: AppLocalizations.of(context)!.error,
//                   message: state.error);
//             } else if (state is VacationApproveSuccess) {
//               context.pop(
//                   state.vacationViewerPageEntity); // Go back and return data
//             }
//           },
//           builder: (context, state) {
//             if (state is VacationLoading ||
//                 !isUserHasPermissionsView(
//                   permissions ?? [],
//                   PermissionsConstants.approveVacation,
//                 )) {
//               return const Loader();
//             }

//             return Form(
//               key: formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     AppLocalizations.of(context)!.selectedTopics,
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                   const SizedBox(height: 10),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: [
//                       'Option 1',
//                       'Option 2',
//                       'Option 3',
//                       'Option 4',
//                       'Option 5',
//                     ].map((option) {
//                       final selected = selectedTopics.contains(option);
//                       return GestureDetector(
//                         onTap: () {},
//                         child: Chip(
//                           label: Text(option),
//                           backgroundColor: selected
//                               ? AppPallete.gradient1
//                                   .withAlpha((0.1 * 255).toInt())
//                               : null,
//                           labelStyle: TextStyle(
//                             color: selected
//                                 ? AppPallete.gradient1
//                                 : AppPallete.textPrimary,
//                             fontWeight:
//                                 selected ? FontWeight.bold : FontWeight.normal,
//                           ),
//                           side: selected
//                               ? BorderSide(color: AppPallete.gradient1)
//                               : const BorderSide(color: AppPallete.borderColor),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     AppLocalizations.of(context)!.vacationTitle,
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                   const SizedBox(height: 8),
//                   CustomTextFormField(
//                     controller: titleControler,
//                     hintText: AppLocalizations.of(context)!.vacationTitle,
//                     readOnly: true,
//                   ),
//                   const SizedBox(height: 20),
//                   Text(
//                     AppLocalizations.of(context)!.vacationContent,
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                   ),
//                   const SizedBox(height: 8),
//                   CustomTextFormField(
//                     controller: contentControler,
//                     hintText: AppLocalizations.of(context)!.vacationContent,
//                     maxLines: null,
//                     readOnly: true,
//                   ),
//                   const SizedBox(height: 30),
//                   CustomTextFormField(
//                     controller: commentController,
//                     hintText: AppLocalizations.of(context)!.approvalComment,
//                     maxLines: null,
//                     readOnly: false,
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: CustomButton(
//                           text: AppLocalizations.of(context)!.approve,
//                           icon: Icons.check_circle_outline,
//                           onPressed: () {
//                             _approveVacation(isApproved: true);
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: CustomButton(
//                           text: AppLocalizations.of(context)!.reject,
//                           icon: Icons.cancel_outlined,
//                           backgroundColor: AppPallete.errorColor,
//                           onPressed: () {
//                             _approveVacation(isApproved: false);
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
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
//     commentController.dispose();
//   }
// }

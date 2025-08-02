import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:etqan_application_2025/init_dependencies.dart';
import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/entities/service_fields.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_key_value_grid.dart';
import 'package:etqan_application_2025/src/core/common/widgets/cards/custom_section_title.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_button.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_text_form_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/grids/custom_table_grid.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:etqan_application_2025/src/core/utils/extensions.dart';
import 'package:etqan_application_2025/src/core/utils/lookups_and_constants.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/core/utils/show_snackbar.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/blog/domain/usecases/fetch_blog_page.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class BlogViewerPage extends StatefulWidget {
  final BlogViewerPageEntity? initialBlogViewerPage;
  final int? requestId;
  const BlogViewerPage({super.key, this.initialBlogViewerPage, this.requestId});

  static route(BlogViewerPageEntity? blogViewerPage) => MaterialPageRoute(
        builder: (context) => BlogViewerPage(
          initialBlogViewerPage: blogViewerPage,
        ),
      );

  @override
  State<BlogViewerPage> createState() => _BlogViewerPageState();
}

class _BlogViewerPageState extends State<BlogViewerPage> {
  BlogViewerPageEntity? blogViewerPage;
  List<String>? permissions;
  ApprovalSequenceViewModel? pendingApproval;
  List<ServiceField> serviceFields = [];
  List<RequestUnlockedFieldModel> requestUnlockedFields = [];
  Map<RequestUnlockedFieldModel, TextEditingController> fieldControllers = {};
  final TextEditingController commentController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.initialBlogViewerPage != null) {
      blogViewerPage = widget.initialBlogViewerPage!;
      _initializeApprovals();
    } else if (widget.requestId != null) {
      _fetchBlogViewerData(widget.requestId!);
    }
    final userId =
        (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;

    Future.microtask(() async {
      final fetchedPermissions = await fetchUserPermissions(userId);
      final fetcheServiceFields =
          await fetchFieldsByServiceId(ServicesConstants.blogServiceId);

      final fetchPendingApproval =
          await blogViewerPage?.approval!.firstWhereOrNullAsync((a) async {
        return a.approvalStatus?.toLowerCase() ==
                LookupConstants.approvalStatusApprovalPending &&
            (a.approverUserId == userId ||
                await isUserHasRole(userId, a.roleId ?? ''));
      });
      if (mounted) {
        setState(() {
          permissions = fetchedPermissions;
          pendingApproval = fetchPendingApproval;
          serviceFields = fetcheServiceFields;
        });
      }
    });
  }

  void _fetchBlogViewerData(int requestId) async {
    final FetchBlogPage fetchBlogPage =
        serviceLocator<FetchBlogPage>(); // ✅ Get use case from service locator

    final fetched = await fetchBlogPage.call(
        FetchBlogPageParams(requestId: requestId)); // Implement this fetch
    fetched.fold((failure) {
      return;
    }, (fetch) {
      if (mounted) {
        setState(() {
          blogViewerPage = fetch;
        });
        _initializeApprovals();
      }
    });
  }

  void _initializeApprovals() async {
    final userId =
        (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;

    final fetchedPermissions = await fetchUserPermissions(userId);

    final fetchPendingApproval =
        await blogViewerPage!.approval!.firstWhereOrNullAsync((a) async {
      return a.approvalStatus?.toLowerCase() ==
              LookupConstants.approvalStatusApprovalPending &&
          (a.approverUserId == userId ||
              await isUserHasRole(userId, a.roleId ?? ''));
    });

    if (mounted) {
      setState(() {
        permissions = fetchedPermissions;
        pendingApproval = fetchPendingApproval;
      });
    }
  }

  void _handleEdit() async {
    final updatedEntity = await context.push<BlogViewerPageEntity>(
      '/blog/update/${blogViewerPage!.blogsView.blogId}',
      extra: blogViewerPage!.blogsView.toBlog()!,
    );

    if (updatedEntity != null && mounted) {
      setState(() {
        blogViewerPage = updatedEntity;
      });
    }
  }

  void _approveBlog({
    required bool isApproved,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          isApproved
              ? AppLocalizations.of(context)!.confirmApproval
              : (requestUnlockedFields.isNullOrEmpty
                  ? AppLocalizations.of(context)!.confirmRejection
                  : AppLocalizations.of(context)!.confirmReturnForCorrection),
        ),
        content: Text(isApproved
            ? AppLocalizations.of(context)!.confirmApprovalDesc
            : (requestUnlockedFields.isNullOrEmpty
                ? AppLocalizations.of(context)!.confirmRejectionDesc
                : AppLocalizations.of(context)!
                    .confirmReturnForCorrectionDesc)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(AppLocalizations.of(context)!.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(AppLocalizations.of(context)!.yes)),
        ],
      ),
    );
    if (!mounted) return;

    if (!isUserHasPermissionsView(
          permissions ?? [],
          PermissionsConstants.approveBlog,
        ) &&
        pendingApproval.isNullOrEmpty) {
      return;
    }
    if (confirmed != true) return;
    print(isApproved
        ? LookupConstants.approvalStatusApprovalApproved
        : (requestUnlockedFields.isNullOrEmpty
            ? LookupConstants.approvalStatusApprovalRejected
            : LookupConstants.approvalStatusApprovalReturnForCorrection));
    final userId =
        (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;
    if (formKey.currentState!.validate()) {
      final updatedApproval = pendingApproval!.copyWith(
        approvalStatus: isApproved
            ? LookupConstants.approvalStatusApprovalApproved
            : (requestUnlockedFields.isNullOrEmpty
                ? LookupConstants.approvalStatusApprovalRejected
                : LookupConstants.approvalStatusApprovalReturnForCorrection),
        approverComment: commentController.text,
        approvedBy: userId,
      );

      context.read<BlogBloc>().add(
            BlogApproveEvent(
              approvalSequence: updatedApproval,
              requestUnlockedFields: requestUnlockedFields,
              blogModel: blogViewerPage!.blogsView,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: blogViewerPage != null
          ? '${AppLocalizations.of(context)!.blog}- ${blogViewerPage!.blogsView.requestId}'
          : AppLocalizations.of(context)!.blog,
      tilteActions: [
        if (isUserHasPermissionsView(
              permissions ?? [],
              PermissionsConstants.updateBlog,
            ) &&
            blogViewerPage != null &&
            blogViewerPage!.blogsView.toBlog() != null)
          IconButton(
            onPressed: _handleEdit,
            icon: Icon(Icons.edit),
          ),
      ],
      body: [
        BlocConsumer<BlogBloc, BlogState>(
          listener: (context, state) {
            if (state is BlogFailure) {
              showSnackBar(context, state.error);
            }
          },
          builder: (context, state) {
            if (state is BlogLoading ||
                blogViewerPage == null ||
                !isUserHasPermissionsView(
                  permissions ?? [],
                  PermissionsConstants.viewBlog,
                )) {
              return const Loader();
            }

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomSectionTitle(
                      title: AppLocalizations.of(context)!.blogDetails,
                    ),
                    CustomKeyValueGrid(
                      data: {
                        AppLocalizations.of(context)!.title:
                            blogViewerPage!.blogsView.title,
                        AppLocalizations.of(context)!.requestId:
                            "${AppLocalizations.of(context)!.blog}-${blogViewerPage!.blogsView.requestId}",
                        AppLocalizations.of(context)!.status:
                            blogViewerPage!.blogsView.requestStatusId,
                        AppLocalizations.of(context)!.topics:
                            blogViewerPage!.blogsView.topics!.join(', '),
                        AppLocalizations.of(context)!.createdBy:
                            blogViewerPage!.blogsView.fullNameAr,
                        AppLocalizations.of(context)!.priority:
                            blogViewerPage!.blogsView.priorityId,
                        AppLocalizations.of(context)!.requestDetails:
                            blogViewerPage!.blogsView.requestDetails,
                        AppLocalizations.of(context)!.createdAt:
                            DateFormat.yMMMd().add_jm().format(
                                blogViewerPage!.blogsView.requestCreatedAt!),
                        AppLocalizations.of(context)!.updatedAt:
                            blogViewerPage!.blogsView.blogUpdatedAt,
                        AppLocalizations.of(context)!.approvedAt:
                            blogViewerPage!.blogsView.requestApprovedAt != null
                                ? DateFormat.yMMMd().add_jm().format(
                                    blogViewerPage!
                                        .blogsView.requestApprovedAt!)
                                : AppLocalizations.of(context)!.notYet,
                      },
                    ),
                    const Divider(),
                    const SizedBox(height: 12),
                    CustomSectionTitle(
                      title: AppLocalizations.of(context)!.approvalSequence,
                    ),
                    CustomTableGrid(
                      headers: [
                        AppLocalizations.of(context)!.approvalId,
                        AppLocalizations.of(context)!.requestId,
                        AppLocalizations.of(context)!.approvalStatus,
                        AppLocalizations.of(context)!.approverName,
                        AppLocalizations.of(context)!.roleName,
                        AppLocalizations.of(context)!.approvedAt,
                        AppLocalizations.of(context)!.createdAt,
                      ],
                      rows: blogViewerPage!.approval!
                          .map((e) => e.toTableRow())
                          .toList(),
                      useChipsForStatus: true,
                    ),
                    const SizedBox(height: 30),
                    if (isUserHasPermissionsView(
                          permissions ?? [],
                          PermissionsConstants.approveBlog,
                        ) &&
                        !pendingApproval.isNullOrEmpty)
                      Form(
                        key: formKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            const Divider(),
                            CustomTextFormField(
                              controller: commentController,
                              hintText:
                                  AppLocalizations.of(context)!.approvalComment,
                              maxLines: null,
                              readOnly: false,
                            ),
                            const SizedBox(height: 20),
                            ..._returnBtbDialog(),
                            const SizedBox(height: 20),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isSmallScreen = constraints.maxWidth <
                                    800; // adjust breakpoint as needed

                                if (isSmallScreen) {
                                  // 📱 Small screen: stack vertically
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      CustomButton(
                                        text: AppLocalizations.of(context)!
                                            .approve,
                                        icon: Icons.check_circle_outline,
                                        onPressed: () {
                                          _approveBlog(isApproved: true);
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      CustomButton(
                                        text: AppLocalizations.of(context)!
                                            .returnForCorrection,
                                        icon: Icons.cancel_outlined,
                                        backgroundColor:
                                            AppPallete.textSecondary,
                                        isDisabled: fieldControllers.isEmpty,
                                        onPressed: () {
                                          requestUnlockedFields =
                                              fieldControllers.entries
                                                  .map((entry) {
                                            final fieldModel = entry.key;
                                            final controller = entry.value;

                                            return fieldModel.copyWith(
                                              reason: controller
                                                  .text, // 👈 assuming you have `value` field in model
                                            );
                                          }).toList();
                                          _approveBlog(
                                            isApproved: false,
                                            requestUnlockedFields:
                                                requestUnlockedFields,
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      CustomButton(
                                        text: AppLocalizations.of(context)!
                                            .reject,
                                        icon: Icons.cancel_outlined,
                                        backgroundColor: AppPallete.errorColor,
                                        onPressed: () {
                                          _approveBlog(isApproved: false);
                                        },
                                      ),
                                    ],
                                  );
                                } else {
                                  // 💻 Large screen: keep them in a row
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: CustomButton(
                                          text: AppLocalizations.of(context)!
                                              .approve,
                                          icon: Icons.check_circle_outline,
                                          onPressed: () {
                                            _approveBlog(isApproved: true);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: CustomButton(
                                          text: AppLocalizations.of(context)!
                                              .returnForCorrection,
                                          icon: Icons.cancel_outlined,
                                          backgroundColor:
                                              AppPallete.textSecondary,
                                          isDisabled: fieldControllers.isEmpty,
                                          onPressed: () {
                                            requestUnlockedFields =
                                                fieldControllers.entries
                                                    .map((entry) {
                                              final fieldModel = entry.key;
                                              final controller = entry.value;

                                              return fieldModel.copyWith(
                                                reason: controller
                                                    .text, // 👈 assuming you have `value` field in model
                                              );
                                            }).toList();
                                            _approveBlog(
                                              isApproved: false,
                                              requestUnlockedFields:
                                                  requestUnlockedFields,
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: CustomButton(
                                          text: AppLocalizations.of(context)!
                                              .reject,
                                          icon: Icons.cancel_outlined,
                                          backgroundColor:
                                              AppPallete.errorColor,
                                          onPressed: () {
                                            _approveBlog(isApproved: false);
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  List<Widget> _returnBtbDialog() {
    List<String?> list = serviceFields
        .map(
          (e) => e.fieldKey,
        )
        .toList();

    return [
      StatefulBuilder(
        builder: (context, setStateSB) {
          // <- use setStateSB for dialog rebuild
          return SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomDropdown<String>.multiSelect(
                    hintText: 'Choose one or more…',
                    items: (list).map((e) => e ?? '').toList(),
                    decoration: CustomDropdownDecoration(
                      closedFillColor: Colors.white,
                      closedBorderRadius: BorderRadius.circular(6),
                      closedBorder: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      listItemDecoration: ListItemDecoration(
                        selectedColor: Colors.blue.shade50,
                      ),
                    ),
                    onListChanged: (List<String> keys) {
                      setState(() {
                        fieldControllers.clear();
                        for (final key in keys) {
                          // Convert string key to a model
                          final model = RequestUnlockedFieldModel(
                            id: Uuid().v1(), // or look up the ID if you have it
                            fieldKey: key,
                            requestId: blogViewerPage!.blogsView.requestId!,
                            unlockedBy: (context.read<AppUserCubit>().state
                                    as AppUserSignedIn)
                                .user
                                .id,
                            unlockedAt: DateTime.now(),
                            isActive: true,
                          );
                          fieldControllers[model] = TextEditingController();
                        }
                      });
                    },
                  ),
                  if (fieldControllers.isNotEmpty)
                    Column(
                      children: fieldControllers.entries.map((entry) {
                        final fieldModel = entry.key;
                        final controller = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TextFormField(
                            controller: controller,
                            decoration: InputDecoration(
                              labelText:
                                  fieldModel.fieldKey, // or fieldModel.label
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          );
        },
      )
    ];
  }

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }
}

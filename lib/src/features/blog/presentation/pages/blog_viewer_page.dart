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
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/blog/domain/usecases/fetch_blog_page.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/pages/blog_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  // >>> keep your variables as-is
  BlogViewerPageEntity? blogViewerPage;
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

    if (widget.initialBlogViewerPage != null) {
      blogViewerPage = widget.initialBlogViewerPage!;
      _initializeApprovals();
    } else if (widget.requestId != null) {
      _fetchBlogViewerData(widget.requestId!);
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
          await fetchFieldsByServiceId(ServicesConstants.blogServiceId);

      // Optionally compute pendingApproval if we already have blogViewerPage
      final fetchPendingApproval =
          await blogViewerPage?.approval!.firstWhereOrNullAsync((a) async {
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

  void _fetchBlogViewerData(int requestId) async {
    final FetchBlogPage fetchBlogPage = serviceLocator<FetchBlogPage>();
    final fetched =
        await fetchBlogPage.call(FetchBlogPageParams(requestId: requestId));

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
        blogViewerPage = fetch;
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
        await blogViewerPage!.approval!.firstWhereOrNullAsync((a) async {
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
            icon: const Icon(Icons.edit),
          ),
      ],
      body: [
        BlocConsumer<BlogBloc, BlogState>(
          listener: (context, state) {
            if (state is BlogFailure) {
              SmartNotifier.error(
                context,
                title: AppLocalizations.of(context)!.unexpectedError,
                message: state.error,
              );
            } else if (state is BlogApproveSuccess ||
                state is BlogSubmitSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                SmartNotifier.success(
                  context,
                  title: AppLocalizations.of(context)!.approvalSuccessful,
                );
                final reqId = widget.requestId ??
                    widget.initialBlogViewerPage!.blogsView.requestId!;
                _fetchBlogViewerData(reqId);
              });
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildDetailsSection(context, blogViewerPage),
                      const Divider(),
                      const SizedBox(height: 12),
                      buildApprovalTableSection(
                        context,
                        blogViewerPage?.approval,
                      ),
                      const SizedBox(height: 24),
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
                                  model: blogViewerPage!.blogsView,
                                  dispatchEvent: (event) =>
                                      context.read<BlogBloc>().add(event),
                                  buildEvent: ({
                                    required approvalSequence,
                                    required model,
                                    requestUnlockedFields,
                                  }) =>
                                      BlogApproveEvent(
                                    approvalSequence: approvalSequence,
                                    blogModel: blogViewerPage!.blogsView,
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
                                  requestId:
                                      blogViewerPage!.blogsView.requestId!,
                                  onReturnForCorrection: (unlockedFields) {
                                    approveRequest(
                                      commentController: commentController,
                                      formKey: formKey,
                                      context: context,
                                      isApproved: false,
                                      pendingApproval: pendingApproval!,
                                      model: blogViewerPage!.blogsView,
                                      requestUnlockedFields: unlockedFields,
                                      dispatchEvent: (event) =>
                                          context.read<BlogBloc>().add(event),
                                      buildEvent: ({
                                        required approvalSequence,
                                        requestUnlockedFields,
                                        required model,
                                      }) =>
                                          BlogApproveEvent(
                                        approvalSequence: approvalSequence,
                                        requestUnlockedFields:
                                            requestUnlockedFields,
                                        blogModel: model,
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
                                  model: blogViewerPage!.blogsView,
                                  dispatchEvent: (event) =>
                                      context.read<BlogBloc>().add(event),
                                  buildEvent: ({
                                    required approvalSequence,
                                    requestUnlockedFields,
                                    required model,
                                  }) =>
                                      BlogApproveEvent(
                                    approvalSequence: approvalSequence,
                                    requestUnlockedFields:
                                        requestUnlockedFields,
                                    blogModel: model,
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
    final updatedEntity = await context.push<BlogViewerPageEntity>(
      '/blog/update/${blogViewerPage!.blogsView.requestId}',
      // extra: blogViewerPage!.blogsView.toBlog()!,
    );

    if (updatedEntity != null && mounted) {
      setState(() {
        blogViewerPage = updatedEntity;
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

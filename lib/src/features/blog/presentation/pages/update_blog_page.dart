import 'package:etqan_application_2025/init_dependencies.dart';
import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_button.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:etqan_application_2025/src/core/utils/approval_sequence_utils.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/core/utils/show_snackbar.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/blog/domain/usecases/fetch_blog_page.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/pages/blog_input_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UpdateBlogPage extends StatefulWidget {
  final BlogViewerPageEntity? initialBlogViewerPage;
  final int? requestId;
  const UpdateBlogPage({super.key, this.initialBlogViewerPage, this.requestId});
  static route(BlogViewerPageEntity blogViewerPage) => MaterialPageRoute(
        builder: (context) =>
            UpdateBlogPage(initialBlogViewerPage: blogViewerPage),
      );

  @override
  State<UpdateBlogPage> createState() => _UpdateBlogPageState();
}

class _UpdateBlogPageState extends State<UpdateBlogPage> {
  List<String>? permissions;
  List<RequestUnlockedFieldModel>? unlockedFields;
  BlogViewerPageEntity? blogViewerPage;
  final TextEditingController titleControler = TextEditingController();
  final TextEditingController contentControler = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<String> selectedTopics = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialBlogViewerPage != null) {
      blogViewerPage = widget.initialBlogViewerPage!;
    } else if (widget.requestId != null) {
      _fetchBlogViewerData(widget.requestId!);
    }

    final userId =
        (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;
    Future.microtask(() async {
      // final fetchedUnlockedFields =
      //     await fetchUnlockedFields(blogViewerPage?.blogsView.requestId ?? -1);
      final fetchedPermissions = await fetchUserPermissions(userId);
      if (mounted) {
        setState(() {
          permissions = fetchedPermissions;
          // unlockedFields = fetchedUnlockedFields;
        });
      }
    });
  }

  void _fetchBlogViewerData(int requestId) async {
    final FetchBlogPage fetchBlogPage =
        serviceLocator<FetchBlogPage>(); // ✅ Get use case from service locator

    final fetched = await fetchBlogPage.call(
        FetchBlogPageParams(requestId: requestId)); // Implement this fetch
    final fetchedUnlockedFields = await fetchUnlockedFields(requestId);

    fetched.fold((failure) {
      return;
    }, (fetch) {
      if (mounted) {
        setState(() {
          blogViewerPage = fetch;
          unlockedFields = fetchedUnlockedFields;
          selectedTopics = blogViewerPage!.blogsView.topics!;
          titleControler.text = blogViewerPage!.blogsView.title!;
          contentControler.text = blogViewerPage!.blogsView.content!;
        });
      }
    });
  }

  void _updateBlog() {
    if (formKey.currentState!.validate() && selectedTopics.isNotEmpty) {
      context.read<BlogBloc>().add(
            BlogUpdateEvent(
              id: blogViewerPage!.blogsView.blogId!,
              createdById: blogViewerPage!.blogsView.createdById!,
              status: blogViewerPage!.blogsView.status!,
              requestId: blogViewerPage!.blogsView.requestId!,
              isActive: blogViewerPage!.blogsView.isActive!,
              title: titleControler.text.trim(),
              content: contentControler.text.trim(),
              topics: selectedTopics,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Update Blog-${blogViewerPage?.blogsView.requestId}',
      showDrawer: false,
      body: [
        BlocConsumer<BlogBloc, BlogState>(
          listener: (context, state) {
            if (state is BlogFailure) {
              showSnackBar(context, state.error);
            } else if (state is BlogUpdateSuccess) {
              context.pop(state.blogViewerPageEntity);
            }
          },
          builder: (context, state) {
            if (state is BlogLoading ||
                blogViewerPage == null ||
                !isUserHasPermissionsView(
                    permissions ?? [], PermissionsConstants.updateBlog)) {
              return const Loader();
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
                        ...BlogInputSection.build(
                          isUpdate: true,
                          setState: setState,
                          selectedTopics: selectedTopics,
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
                              text: 'Update',
                              onPressed: _updateBlog,
                            ),
                            CustomButton(
                              width: 180,
                              icon: Icons.cancel,
                              text: 'Cancel',
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

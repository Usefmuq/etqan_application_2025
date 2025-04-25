import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_button.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_text_form_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/responsive_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/core/utils/show_snackbar.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UpdateBlogPage extends StatefulWidget {
  final Blog blog;
  const UpdateBlogPage({super.key, required this.blog});
  static route(Blog blog) => MaterialPageRoute(
        builder: (context) => UpdateBlogPage(blog: blog),
      );

  @override
  State<UpdateBlogPage> createState() => _UpdateBlogPageState();
}

class _UpdateBlogPageState extends State<UpdateBlogPage> {
  List<String>? permissions;
  late Blog blog;
  final TextEditingController titleControler = TextEditingController();
  final TextEditingController contentControler = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<String> selectedTopics = [];

  @override
  void initState() {
    super.initState();
    blog = widget.blog;
    final userId =
        (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;
    Future.microtask(() async {
      final fetchedPermissions = await fetchUserPermissions(userId);
      if (mounted) setState(() => permissions = fetchedPermissions);
    });
  }

  void _updateBlog() {
    if (formKey.currentState!.validate() && selectedTopics.isNotEmpty) {
      context.read<BlogBloc>().add(
            BlogUpdateEvent(
              id: blog.id,
              createdById: blog.createdById,
              status: blog.status,
              requestId: blog.requestId,
              isActive: blog.isActive,
              title: titleControler.text.trim(),
              content: contentControler.text.trim(),
              topics: selectedTopics,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    selectedTopics = blog.topics;
    titleControler.text = blog.title;
    contentControler.text = blog.content;

    return CustomScaffold(
      title: 'Update Blog-${widget.blog.requestId}',
      showDrawer: false,
      // tilteActions: [
      //   if (isUserHasPermissionsView(
      //       permissions ?? [], PermissionsConstants.updateBlog))
      //     IconButton(
      //       onPressed: _updateBlog,
      //       icon: const Icon(Icons.done_rounded),
      //     )
      // ],
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
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            'Option 1',
                            'Option 2',
                            'Option 3',
                            'Option 4',
                            'Option 5'
                          ].map((topic) {
                            final isSelected = selectedTopics.contains(topic);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSelected
                                      ? selectedTopics.remove(topic)
                                      : selectedTopics.add(topic);
                                });
                              },
                              child: Chip(
                                label: Text(topic,
                                    style: const TextStyle(fontSize: 15)),
                                color: isSelected
                                    ? const WidgetStatePropertyAll(
                                        AppPallete.gradient1)
                                    : null,
                                side: isSelected
                                    ? null
                                    : const BorderSide(
                                        color: AppPallete.borderColor),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            responsiveField(
                              CustomTextFormField(
                                controller: titleControler,
                                readOnly: false,
                                hintText: 'Blog title',
                              ),
                              isWide,
                            ),
                            responsiveField(
                              CustomTextFormField(
                                controller: contentControler,
                                hintText: 'Blog content',
                                readOnly: false,
                                maxLines: null,
                              ),
                              isWide,
                            ),
                          ],
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

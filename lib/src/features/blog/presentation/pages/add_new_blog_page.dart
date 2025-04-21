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
import 'package:etqan_application_2025/src/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AddNewBlogPage extends StatefulWidget {
  const AddNewBlogPage({super.key});
  static route() => MaterialPageRoute(
        builder: (context) => const AddNewBlogPage(),
      );
  @override
  State<AddNewBlogPage> createState() => _AddNewBlogPageState();
}

class _AddNewBlogPageState extends State<AddNewBlogPage> {
  List<String>? permissions;
  final TextEditingController titleControler = TextEditingController();
  final TextEditingController contentControler = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<String> selectedTopics = [];

  @override
  void initState() {
    super.initState();
    final userId =
        (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;

    Future.microtask(() async {
      final fetchedPermissions = await fetchUserPermissions(userId);

      if (mounted) {
        setState(() {
          permissions = fetchedPermissions;
        });
      }
    });
  }

  void _submitBlog() {
    if (formKey.currentState!.validate() && selectedTopics.isNotEmpty) {
      final createdById =
          (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;
      context.read<BlogBloc>().add(
            BlogSubmitEvent(
              createdById: createdById,
              title: titleControler.text.trim(),
              content: contentControler.text.trim(),
              topics: selectedTopics,
            ),
          );
    }
  }

  @override
  void dispose() {
    super.dispose();
    titleControler.dispose();
    contentControler.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: 'Submit New Blog',
      showDrawer: false,
      tilteActions: [
        IconButton(
          onPressed: _submitBlog,
          icon: Icon(Icons.done_rounded),
        )
      ],
      body: [
        BlocConsumer<BlogBloc, BlogState>(
          listener: (context, state) {
            if (state is BlogFailure) {
              showSnackBar(context, state.error);
            } else if (state is BlogSubmitSuccess) {
              context.pop();
            }
          },
          builder: (context, state) {
            if (state is BlogLoading ||
                !isUserHasPermissionsView(
                  permissions ?? [],
                  PermissionsConstants.addBlog,
                )) {
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
                            'Option 5',
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
                              text: 'Submit',
                              onPressed: _submitBlog,
                            ),
                            CustomButton(
                              width: 180,
                              icon: Icons.cancel,
                              text: 'Cancel',
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

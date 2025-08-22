import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_button.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/common/widgets/pages/custom_scaffold.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:etqan_application_2025/src/core/utils/notifier.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/pages/blog_input_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<String> selectedTopics = [];

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

      if (mounted) {
        setState(() {
          permissions = fetchedPermissions;
        });
      }
    });
  }

  void _submitBlog() {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (selectedTopics.isEmpty) {
      SmartNotifier.warning(
        context,
        title: AppLocalizations.of(context)!.error,
        message: AppLocalizations.of(context)!
            .fieldIsRequired, // or a “select topics” string
      );
      return;
    }

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
      context.read<BlogBloc>().add(
            BlogSubmitEvent(
              createdById: createdById,
              title: titleController.text.trim(),
              content: contentController.text.trim(),
              topics: selectedTopics,
            ),
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
      title: AppLocalizations.of(context)!.blogSubmitNew,

      showDrawer: false,
      // tilteActions: [
      //   IconButton(
      //     onPressed: _submitBlog,
      //     icon: Icon(Icons.done_rounded),
      //   )
      // ],
      body: [
        BlocConsumer<BlogBloc, BlogState>(
          listener: (context, state) {
            if (state is BlogFailure) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                SmartNotifier.error(
                  context,
                  title: AppLocalizations.of(context)!.error,
                  message: state.error,
                );
              });
            } else if (state is BlogSubmitSuccess) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) context.pop();
              });
            }
          },
          builder: (context, state) {
            final permsReady = permissions != null;
            final canAdd = isUserHasPermissionsView(
              permissions ?? const [],
              PermissionsConstants.addBlog,
            );

            if (state is BlogLoading || !permsReady) {
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
                        ...BlogInputSection.build(
                          isLockFieldsWithoutComment: false,
                          setState: setState,
                          selectedTopics: selectedTopics,
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
                              text: AppLocalizations.of(context)!.submit,
                              onPressed: _submitBlog,
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

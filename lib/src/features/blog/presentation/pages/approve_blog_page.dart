import 'package:dotted_border/dotted_border.dart';
import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/entities/approval_sequence.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_text_form_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_model.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/core/utils/show_snackbar.dart';
import 'package:etqan_application_2025/src/features/blog/data/models/blog_model.dart';
import 'package:etqan_application_2025/src/features/blog/data/models/blog_page_view_model.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blogs_page_view.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/pages/blog_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ApproveBlogPage extends StatefulWidget {
  final BlogsPageViewModel blog;
  final ApprovalSequenceViewModel approvalSequence;
  const ApproveBlogPage({
    super.key,
    required this.blog,
    required this.approvalSequence,
  });
  static route(
    BlogsPageViewModel blog,
    ApprovalSequenceViewModel approvalSequence,
  ) =>
      MaterialPageRoute(
        builder: (context) => ApproveBlogPage(
          blog: blog,
          approvalSequence: approvalSequence,
        ),
      );

  @override
  State<ApproveBlogPage> createState() => _ApproveBlogPageState();
}

class _ApproveBlogPageState extends State<ApproveBlogPage> {
  List<String>? permissions;

  late BlogsPageViewModel blog; // Declare a variable to hold the Blog object
  late ApprovalSequenceViewModel
      approvalSequence; // Declare a variable to hold the Blog object

  final TextEditingController titleControler = TextEditingController();
  final TextEditingController contentControler = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<String> selectedTopics = [];

  void _approveBlog() {
    if (formKey.currentState!.validate() && selectedTopics.isNotEmpty) {
      // final createdById =
      //     (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;
      context.read<BlogBloc>().add(
            BlogApproveEvent(
              approvalSequence: approvalSequence,
              blogModel: blog,
            ),
          );
    }
  }

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
    blog = widget.blog; // Assign the Blog object in initState
  }

  @override
  Widget build(BuildContext context) {
    selectedTopics = blog.topics ?? [];
    titleControler.text = blog.title ?? "";
    contentControler.text = blog.content ?? "";
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (isUserHasPermissionsView(
            permissions ?? [],
            PermissionsConstants.approveBlog,
          ))
            IconButton(
              onPressed: () {
                _approveBlog();
              },
              icon: Icon(Icons.done_rounded),
            )
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackBar(context, state.error);
          } else if (state is BlogApproveSuccess) {
            Navigator.pushAndRemoveUntil(
              context,
              BlogPage.route(),
              (route) => false,
            );
          }
        },
        builder: (context, state) {
          if (state is BlogLoading ||
              !isUserHasPermissionsView(
                permissions ?? [],
                PermissionsConstants.approveBlog,
              )) {
            return const Loader();
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'Option 1',
                          'Option 2',
                          'Option 3',
                          'Option 4',
                          'Option 5',
                        ]
                            .map(
                              (_) => Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: GestureDetector(
                                  // onTap: () {
                                  //   if (selectedTopics.contains(_)) {
                                  //     selectedTopics.remove(_);
                                  //   } else {
                                  //     selectedTopics.add(_);
                                  //   }
                                  //   setState(() {});
                                  // },
                                  child: Chip(
                                    label: Text(
                                      _,
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    color: selectedTopics.contains(_)
                                        ? const WidgetStatePropertyAll(
                                            AppPallete.gradient1,
                                          )
                                        : null,
                                    side: selectedTopics.contains(_)
                                        ? null
                                        : const BorderSide(
                                            color: AppPallete.borderColor),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomTextFormField(
                      controller: titleControler,
                      hintText: 'Blog title',
                      readOnly: true,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomTextFormField(
                      controller: contentControler,
                      hintText: 'Blog content',
                      maxLines: null,
                      readOnly: true,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    titleControler.dispose();
    contentControler.dispose();
  }
}

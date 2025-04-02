import 'package:dotted_border/dotted_border.dart';
import 'package:etqan_application_2025/src/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:etqan_application_2025/src/core/common/widgets/forms/custom_text_form_field.dart';
import 'package:etqan_application_2025/src/core/common/widgets/loader.dart';
import 'package:etqan_application_2025/src/core/constants/permissions_constants.dart';
import 'package:etqan_application_2025/src/core/theme/app_pallete.dart';
import 'package:etqan_application_2025/src/core/utils/permission.dart';
import 'package:etqan_application_2025/src/core/utils/show_snackbar.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/pages/blog_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class UpdateBlogPage extends StatefulWidget {
  final Blog blog;
  const UpdateBlogPage({super.key, required this.blog});
  static route(Blog blog) => MaterialPageRoute(
        builder: (context) => UpdateBlogPage(
          blog: blog,
        ),
      );

  @override
  State<UpdateBlogPage> createState() => _UpdateBlogPageState();
}

class _UpdateBlogPageState extends State<UpdateBlogPage> {
  List<String>? permissions;

  late Blog blog; // Declare a variable to hold the Blog object

  final TextEditingController titleControler = TextEditingController();
  final TextEditingController contentControler = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<String> selectedTopics = [];

  void _updateBlog() {
    if (formKey.currentState!.validate() && selectedTopics.isNotEmpty) {
      // final createdById =
      //     (context.read<AppUserCubit>().state as AppUserSignedIn).user.id;
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
    selectedTopics = blog.topics;
    titleControler.text = blog.title;
    contentControler.text = blog.content;
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (isUserHasPermissionsView(
            permissions ?? [],
            PermissionsConstants.updateBlog,
          ))
            IconButton(
              onPressed: () {
                _updateBlog();
              },
              icon: Icon(Icons.done_rounded),
            )
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackBar(context, state.error);
          } else if (state is BlogUpdateSuccess) {
            context.pop(state.blogViewerPageEntity); // Go back and return data
          }
        },
        builder: (context, state) {
          if (state is BlogLoading ||
              !isUserHasPermissionsView(
                permissions ?? [],
                PermissionsConstants.updateBlog,
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
                    DottedBorder(
                      color: AppPallete.borderColor,
                      dashPattern: const [
                        10,
                        4,
                      ],
                      radius: const Radius.circular(10),
                      borderType: BorderType.RRect,
                      strokeCap: StrokeCap.round,
                      child: SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open,
                              size: 40,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              'Select your image',
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
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
                                  onTap: () {
                                    if (selectedTopics.contains(_)) {
                                      selectedTopics.remove(_);
                                    } else {
                                      selectedTopics.add(_);
                                    }
                                    setState(() {});
                                  },
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
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CustomTextFormField(
                      controller: contentControler,
                      hintText: 'Blog content',
                      maxLines: null,
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

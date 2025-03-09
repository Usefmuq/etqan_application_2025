import 'package:etqan_application_2025/src/features/blog/domain/entities/blog.dart';
import 'package:etqan_application_2025/src/features/blog/presentation/pages/update_blog_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BlogViewerPage extends StatelessWidget {
  static route(Blog blog) => MaterialPageRoute(
        builder: (context) => BlogViewerPage(
          blog: blog,
        ),
      );

  final Blog blog;
  const BlogViewerPage({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                UpdateBlogPage.route(blog),
              );
            },
            icon: Icon(
              CupertinoIcons.pencil_circle,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Text(blog.title),
          Text(blog.content),
        ],
      ),
    );
  }
}

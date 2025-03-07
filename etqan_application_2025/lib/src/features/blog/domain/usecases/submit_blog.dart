import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog.dart';
import 'package:etqan_application_2025/src/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class SubmitBlog implements Usecase<Blog, SubmitBlogParams> {
  final BlogRepository blogRepostory;
  SubmitBlog(this.blogRepostory);
  @override
  Future<Either<Failure, Blog>> call(SubmitBlogParams params) async {
    return await blogRepostory.submitBlog(
      createdById: params.createdById,
      title: params.title,
      content: params.content,
      topics: params.topics,
    );
  }
}

class SubmitBlogParams {
  final String createdById;
  final String title;
  final String content;
  final List<String> topics;

  SubmitBlogParams({
    required this.createdById,
    required this.title,
    required this.content,
    required this.topics,
  });
}

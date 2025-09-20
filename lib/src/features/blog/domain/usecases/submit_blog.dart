import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class SubmitBlog implements Usecase<BlogViewerPageEntity, SubmitBlogParams> {
  final BlogRepository blogRepostory;
  SubmitBlog(this.blogRepostory);
  @override
  Future<Either<Failure, BlogViewerPageEntity>> call(
      SubmitBlogParams params) async {
    return await blogRepostory.submitBlog(
      createdById: params.createdById,
      // status: params.status,
      // requestId: params.requestId,
      title: params.title,
      content: params.content,
      topics: params.topics,
    );
  }
}

class SubmitBlogParams {
  final String createdById;
  // final String status;
  // final String requestId;
  final String title;
  final String content;
  final List<String> topics;

  SubmitBlogParams({
    required this.createdById,
    // required this.status,
    // required this.requestId,
    required this.title,
    required this.content,
    required this.topics,
  });
}

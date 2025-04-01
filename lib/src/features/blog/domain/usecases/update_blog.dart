import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateBlog implements Usecase<BlogViewerPageEntity, UpdateBlogParams> {
  final BlogRepository blogRepostory;
  UpdateBlog(this.blogRepostory);
  @override
  Future<Either<Failure, BlogViewerPageEntity>> call(
      UpdateBlogParams params) async {
    return await blogRepostory.updateBlog(
      id: params.id,
      createdById: params.createdById,
      status: params.status,
      requestId: params.requestId,
      isActive: params.isActive,
      title: params.title,
      content: params.content,
      topics: params.topics,
    );
  }
}

class UpdateBlogParams {
  final String id;
  final String createdById;
  final String status;
  final int requestId;
  final bool isActive;
  final String title;
  final String content;
  final List<String> topics;

  UpdateBlogParams({
    required this.id,
    required this.createdById,
    required this.status,
    required this.requestId,
    required this.isActive,
    required this.title,
    required this.content,
    required this.topics,
  });
}

import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/features/blog/data/models/blog_page_view_model.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_page_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class BlogRepository {
  Future<Either<Failure, Blog>> submitBlog({
    required String createdById,
    // required String status,
    // required String requestId,
    required String title,
    required String content,
    required List<String> topics,
  });
  Future<Either<Failure, Blog>> updateBlog({
    required String id,
    required String createdById,
    required String status,
    required int requestId,
    required bool isActive,
    required String title,
    required String content,
    required List<String> topics,
  });
  Future<Either<Failure, Blog>> approveBlog({
    required ApprovalSequenceViewModel approvalSequenceModel,
    required BlogsPageViewModel blogModel,
  });
  Future<Either<Failure, BlogPageEntity>> getAllBlogs();
}

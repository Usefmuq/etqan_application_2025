import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class BlogRepository {
  Future<Either<Failure, Blog>> submitBlog({
    required String createdById,
    required String title,
    required String content,
    required List<String> topics,
  });
  Future<Either<Failure, List<Blog>>> getAllBlogs();
}

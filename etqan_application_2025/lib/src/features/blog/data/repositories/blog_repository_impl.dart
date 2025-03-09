import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/features/blog/data/datasources/blog_remote_data_source.dart';
import 'package:etqan_application_2025/src/features/blog/data/models/blog_model.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog.dart';
import 'package:etqan_application_2025/src/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class BlogRepositoryImpl implements BlogRepository {
  final BlogRemoteDataSource blogRemoteDataSource;
  BlogRepositoryImpl(this.blogRemoteDataSource);
  @override
  Future<Either<Failure, Blog>> submitBlog({
    required String createdById,
    required String title,
    required String content,
    required List<String> topics,
  }) async {
    try {
      BlogModel blogModel = BlogModel(
        id: Uuid().v1(),
        createdById: createdById,
        updatedAt: DateTime.now(),
        title: title,
        content: content,
        topics: topics,
      );
      final insertedBlog = await blogRemoteDataSource.submitBlog(blogModel);
      return right(insertedBlog);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Blog>> updateBlog({
    required String id,
    required String createdById,
    required String title,
    required String content,
    required List<String> topics,
  }) async {
    try {
      BlogModel blogModel = BlogModel(
        id: id,
        createdById: createdById,
        updatedAt: DateTime.now(),
        title: title,
        content: content,
        topics: topics,
      );
      final updatedBlog = await blogRemoteDataSource.updateBlog(blogModel);
      return right(updatedBlog);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Blog>>> getAllBlogs() async {
    try {
      final blogs = await blogRemoteDataSource.getAllBlogs();
      return right(blogs);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}

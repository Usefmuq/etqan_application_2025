import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/datasources/permission_remote_data_source.dart';
import 'package:etqan_application_2025/src/core/data/models/request_master_model.dart';
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
  final PermissionRemoteDataSource permissionRemoteDataSource;
  const BlogRepositoryImpl(
    this.blogRemoteDataSource,
    this.permissionRemoteDataSource,
  );
  @override
  Future<Either<Failure, Blog>> submitBlog({
    required String createdById,
    // required String status,
    // required String requestId,
    required String title,
    required String content,
    required List<String> topics,
  }) async {
    try {
      RequestMasterModel requestMasterModel = RequestMasterModel(
        userId: createdById,
        serviceId: ServicesConstants.blogServiceId,
        status: LookupConstants.requestStatusPending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      BlogModel blogModel = BlogModel(
        id: Uuid().v1(),
        createdById: createdById,
        updatedAt: DateTime.now(),
        status: LookupConstants.requestStatusPending,
        requestId: 1,
        isActive: true,
        title: title,
        content: content,
        topics: topics,
      );
      final insertedBlog =
          await blogRemoteDataSource.submitBlog(blogModel, requestMasterModel);
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
    required String status,
    required int requestId,
    required bool isActive,
    required String title,
    required String content,
    required List<String> topics,
  }) async {
    try {
      BlogModel blogModel = BlogModel(
        id: id,
        createdById: createdById,
        updatedAt: DateTime.now(),
        status: status,
        requestId: requestId,
        isActive: isActive,
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

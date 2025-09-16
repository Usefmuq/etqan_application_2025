import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/constants/lookup_constants.dart';
import 'package:etqan_application_2025/src/core/constants/services_constants.dart';
import 'package:etqan_application_2025/src/core/data/datasources/permission_remote_data_source.dart';
import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_master_model.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:etqan_application_2025/src/core/error/exception.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/features/blog/data/datasources/blog_remote_data_source.dart';
import 'package:etqan_application_2025/src/features/blog/data/models/blog_model.dart';
import 'package:etqan_application_2025/src/features/blog/data/models/blog_page_view_model.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_page_entity.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_viewer_page_entity.dart';
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
        // requestId: 0,
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
        requestId: -1,
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
  Future<Either<Failure, BlogViewerPageEntity>> updateBlog({
    required BlogsPageViewModel blogViewerPage,
    required String updatedBy,
  }) async {
    try {
      final updatedBlog = await blogRemoteDataSource.updateBlog(
        blogViewerPage,
        updatedBy,
      );
      return right(updatedBlog);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlogViewerPageEntity>> approveBlog({
    required ApprovalSequenceViewModel approvalSequenceModel,
    List<RequestUnlockedFieldModel>? requestUnlockedFields,
    required BlogsPageViewModel blogModel,
  }) async {
    try {
      final approvedBlog = await blogRemoteDataSource.approveBlog(
        approvalSequenceModel,
        requestUnlockedFields,
        blogModel,
      );
      return right(approvedBlog);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlogPageEntity>> getAllBlogs({
    required User user,
    String? departmentId,
    required bool isManagerExpanded,
    required bool isDepartmentManagerExpanded,
    required bool isViewAll,
  }) async {
    try {
      final blogsVeiw = await blogRemoteDataSource.getAllBlogsView(
        user.id,
        departmentId,
        isManagerExpanded,
        isDepartmentManagerExpanded,
        isViewAll,
      );
      final approvalsView = await blogRemoteDataSource.getAllApprovalsView();
      return right(BlogPageEntity(
        blogsView: blogsVeiw,
        approvalsView: approvalsView,
      ));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BlogViewerPageEntity>> fetchBlogViewerPage(
      {required int requestId}) async {
    try {
      final blogsVeiw =
          await blogRemoteDataSource.getBlogViewByRequestId(requestId);
      final approvalsView =
          await blogRemoteDataSource.getApprovalViewByRequestId(requestId);
      return right(BlogViewerPageEntity(
        blogsView: blogsVeiw,
        approval: approvalsView,
      ));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}

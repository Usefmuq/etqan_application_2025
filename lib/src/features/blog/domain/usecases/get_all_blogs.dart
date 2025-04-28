import 'package:etqan_application_2025/src/core/common/entities/user.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_page_entity.dart';
import 'package:etqan_application_2025/src/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetAllBlogs implements Usecase<BlogPageEntity, GetAllBlogsParams> {
  final BlogRepository blogRepostory;
  GetAllBlogs(this.blogRepostory);
  @override
  Future<Either<Failure, BlogPageEntity>> call(GetAllBlogsParams params) async {
    return await blogRepostory.getAllBlogs(
      user: params.user,
      departmentId: params.departmentId,
      isManagerExpanded: params.isManagerExpanded,
      isDepartmentManagerExpanded: params.isDepartmentManagerExpanded,
      isViewAll: params.isViewAll,
    );
  }
}

class GetAllBlogsParams {
  final User user;
  final String? departmentId;
  final bool isManagerExpanded;
  final bool isDepartmentManagerExpanded;
  final bool isViewAll;

  GetAllBlogsParams({
    required this.user,
    this.departmentId,
    required this.isManagerExpanded,
    required this.isDepartmentManagerExpanded,
    required this.isViewAll,
  });
}

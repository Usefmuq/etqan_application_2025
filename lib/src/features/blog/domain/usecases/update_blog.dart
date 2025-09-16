import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/blog/data/models/blog_page_view_model.dart';
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
      blogViewerPage: params.blogViewerPage,
      updatedBy: params.updatedBy,
    );
  }
}

class UpdateBlogParams {
  final BlogsPageViewModel blogViewerPage;
  final String updatedBy;

  UpdateBlogParams({
    required this.blogViewerPage,
    required this.updatedBy,
  });
}

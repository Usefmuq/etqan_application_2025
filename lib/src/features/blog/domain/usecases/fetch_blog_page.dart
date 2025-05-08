import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class FetchBlogPage
    implements Usecase<BlogViewerPageEntity, FetchBlogPageParams> {
  final BlogRepository blogRepostory;
  FetchBlogPage(this.blogRepostory);
  @override
  Future<Either<Failure, BlogViewerPageEntity>> call(
      FetchBlogPageParams params) async {
    return await blogRepostory.fetchBlogViewerPage(
      requestId: params.requestId,
    );
  }
}

class FetchBlogPageParams {
  final int requestId;

  FetchBlogPageParams({
    required this.requestId,
  });
}

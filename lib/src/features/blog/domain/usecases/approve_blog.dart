import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/core/error/failure.dart';
import 'package:etqan_application_2025/src/core/usecase/usecase.dart';
import 'package:etqan_application_2025/src/features/blog/data/models/blog_page_view_model.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blog_viewer_page_entity.dart';
import 'package:etqan_application_2025/src/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';

class ApproveBlog implements Usecase<BlogViewerPageEntity, ApproveBlogParams> {
  final BlogRepository blogRepostory;
  ApproveBlog(this.blogRepostory);
  @override
  Future<Either<Failure, BlogViewerPageEntity>> call(
      ApproveBlogParams params) async {
    return await blogRepostory.approveBlog(
      approvalSequenceModel: params.approvalSequenceModel,
      blogModel: params.blogModel,
    );
  }
}

class ApproveBlogParams {
  final ApprovalSequenceViewModel approvalSequenceModel;
  final BlogsPageViewModel blogModel;

  ApproveBlogParams({
    required this.approvalSequenceModel,
    required this.blogModel,
  });
}

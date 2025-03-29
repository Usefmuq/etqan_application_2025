import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blogs_page_view.dart';

class BlogPageEntity {
  final List<BlogsPageView> blogsView;
  final List<ApprovalSequenceViewModel> approvalsView;

  BlogPageEntity({
    required this.blogsView,
    required this.approvalsView,
  });
}

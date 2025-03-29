import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/features/blog/data/models/blog_page_view_model.dart';

class BlogPageEntity {
  final List<BlogsPageViewModel> blogsView;
  final List<ApprovalSequenceViewModel> approvalsView;

  BlogPageEntity({
    required this.blogsView,
    required this.approvalsView,
  });
}

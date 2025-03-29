import 'package:etqan_application_2025/src/core/data/models/approval_sequence_view_model.dart';
import 'package:etqan_application_2025/src/features/blog/data/models/blog_page_view_model.dart';

class BlogViewerPageEntity {
  final BlogsPageViewModel blogsView;

  final List<ApprovalSequenceViewModel>? approval;

  BlogViewerPageEntity({
    required this.blogsView,
    this.approval,
  });
}

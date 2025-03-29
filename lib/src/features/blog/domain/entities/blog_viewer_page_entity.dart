import 'package:etqan_application_2025/src/core/common/entities/approval_sequence.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blogs_page_view.dart';

class BlogViewerPageEntity {
  final BlogsPageView blogsView;

  final List<ApprovalSequence>? approval;

  BlogViewerPageEntity({
    required this.blogsView,
    this.approval,
  });
}

import 'package:etqan_application_2025/src/core/common/entities/approval_sequence.dart';
import 'package:etqan_application_2025/src/features/blog/domain/entities/blogs_page_view.dart';

class BlogPageEntity {
  final List<BlogsPageView> blogsView;
  final List<ApprovalSequence> approvals;

  BlogPageEntity({
    required this.blogsView,
    required this.approvals,
  });
}

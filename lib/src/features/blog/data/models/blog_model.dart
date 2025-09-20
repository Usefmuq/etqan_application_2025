import 'package:etqan_application_2025/src/features/blog/domain/entities/blog.dart';

class BlogModel extends Blog {
  BlogModel({
    required super.id,
    required super.createdById,
    required super.updatedAt,
    required super.status,
    required super.requestId,
    required super.isActive,
    required super.title,
    required super.content,
    required super.topics,
    super.createdByName,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'created_by_id': createdById,
      'updated_at': updatedAt.toIso8601String(),
      'status': status,
      'request_id': requestId,
      'is_active': isActive,
      'title': title,
      'content': content,
      'topics': topics,
    };
  }

  factory BlogModel.fromJson(Map<String, dynamic> map) {
    return BlogModel(
      id: map['id'] as String,
      createdById: map['created_by_id'] as String,
      updatedAt: map['updated_at'] == null
          ? DateTime.now().toUtc().add(Duration(hours: 3))
          : DateTime.parse(map['updated_at']),
      status: map['status'] as String,
      requestId: map['request_id'] as int,
      isActive: map['is_active'] as bool,
      title: map['title'] as String,
      content: map['content'] as String,
      topics: List<String>.from(map['topics'] ?? []),
    );
  }

  BlogModel copyWith({
    String? id,
    String? createdById,
    DateTime? updatedAt,
    String? status,
    int? requestId,
    bool? isActive,
    String? title,
    String? content,
    List<String>? topics,
    String? createdByName,
  }) {
    return BlogModel(
      id: id ?? this.id,
      createdById: createdById ?? this.createdById,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      requestId: requestId ?? this.requestId,
      isActive: isActive ?? this.isActive,
      title: title ?? this.title,
      content: content ?? this.content,
      topics: topics ?? this.topics,
      createdByName: createdByName ?? this.createdByName,
    );
  }
}

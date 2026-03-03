import 'package:etqan_application_2025/src/features/reports/domain/entities/report_columns_meta.dart';

class ReportColumnsMetaModel extends ReportColumnsMeta {
  const ReportColumnsMetaModel({
    required super.id,
    required super.reportId,
    required super.columnKey,
    required super.labelEn,
    required super.labelAr,
    required super.columnType,
    required super.orderIndex,
    required super.isVisible,
  });

  factory ReportColumnsMetaModel.fromJson(Map<String, dynamic> json) {
    return ReportColumnsMetaModel(
      id: json['id'] as String,
      reportId: json['report_id'] as String,
      columnKey: json['column_key'] as String,
      labelEn: json['label_en'] as String,
      labelAr: json['label_ar'] as String,
      columnType: json['column_type'] as String? ?? 'text',
      orderIndex: json['order_index'] as int? ?? 0,
      isVisible: json['is_visible'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_id': reportId,
      'column_key': columnKey,
      'label_en': labelEn,
      'label_ar': labelAr,
      'column_type': columnType,
      'order_index': orderIndex,
      'is_visible': isVisible,
    };
  }

  ReportColumnsMetaModel copyWith({
    String? id,
    String? reportId,
    String? columnKey,
    String? labelEn,
    String? labelAr,
    String? columnType,
    int? orderIndex,
    bool? isVisible,
  }) {
    return ReportColumnsMetaModel(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      columnKey: columnKey ?? this.columnKey,
      labelEn: labelEn ?? this.labelEn,
      labelAr: labelAr ?? this.labelAr,
      columnType: columnType ?? this.columnType,
      orderIndex: orderIndex ?? this.orderIndex,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

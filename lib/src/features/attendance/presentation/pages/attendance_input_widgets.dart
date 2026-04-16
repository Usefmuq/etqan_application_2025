import 'package:etqan_application_2025/src/core/common/entities/service_fields.dart';
import 'package:etqan_application_2025/src/core/common/widgets/embedded/current_location_map.dart';
import 'package:etqan_application_2025/src/core/data/models/request_unlocked_field_model.dart';
import 'package:flutter/material.dart';

class AttendanceInputSection {
  static List<Widget> build({
    required void Function(void Function()) setState,
    required bool isWide,
    required bool isLockFieldsWithoutComment,
    List<RequestUnlockedFieldModel>? unlockedFields,
    List<ServiceField>? serviceFields,
    void Function(double lat, double lng)? onLatLng,
  }) {
    return [
      SizedBox(
        height: 300, // MUST be a fixed/bounded height
        child: CurrentLocationMap(
          followUser: true,
          onLatLng: onLatLng,
        ),
      ),
      const SizedBox(height: 20),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [],
      ),
    ];
  }
}

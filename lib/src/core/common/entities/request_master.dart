class RequestMaster {
  final int? requestId;
  final String userId;
  final int serviceId;
  final String? status; // ✅ Status (Pending, Approved, Rejected)
  final String? priority; // ✅ Priority (Low, Medium, High)
  final String? requestDetails; // ✅ Additional information
  final bool isActive; // ✅ Whether the request is active
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? approvedAt; // ✅ When the request was approved

  RequestMaster({
    this.requestId,
    required this.userId,
    required this.serviceId,
    this.status,
    this.priority,
    this.requestDetails,
    this.isActive = true, // ✅ Default: active
    required this.createdAt,
    required this.updatedAt,
    this.approvedAt,
  });
}

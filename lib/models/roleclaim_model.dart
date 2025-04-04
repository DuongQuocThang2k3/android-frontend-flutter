class RoleClaimModel {
  /// Phần trước dấu chấm, ví dụ: "product", "pet", "user", ...
  final String resource;

  /// Phần sau dấu chấm, ví dụ: "create", "edit", "delete", "view", ...
  final String action;

  RoleClaimModel({
    required this.resource,
    required this.action,
  });

  /// Tạo instance của ClaimModel từ một chuỗi định dạng "resource.action"
  factory RoleClaimModel.fromString(String claim) {
    List<String> parts = claim.split('.');
    return RoleClaimModel(
      resource: parts.isNotEmpty ? parts[0] : '',
      action: parts.length > 1 ? parts[1] : '',
    );
  }

  /// Chuyển model thành Map (nếu cần sử dụng cho JSON hoặc các thao tác khác)
  Map<String, dynamic> toJson() => {
        'resource': resource,
        'action': action,
      };

  @override
  String toString() => '$resource.$action';
}

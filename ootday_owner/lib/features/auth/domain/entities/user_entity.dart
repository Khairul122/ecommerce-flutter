class UserEntity {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;

  /// JSON mentah dari server (termasuk `store` bersarang untuk owner).
  /// Dipertahankan supaya layar yang belum sepenuhnya dirapikan (settings,
  /// store profile) masih bisa membaca field spesifik-owner tanpa memodelkan
  /// ulang semuanya di sini.
  final Map<String, dynamic> raw;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.raw,
  });

  Map<String, dynamic>? get store => raw['store'] as Map<String, dynamic>?;
}

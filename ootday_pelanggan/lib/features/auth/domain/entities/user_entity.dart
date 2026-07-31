class UserEntity {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
  });

  /// Kompatibilitas kasar dengan API lama `firebase_auth.User.displayName`
  /// supaya layar yang menampilkan sapaan nama tidak perlu berubah drastis.
  String? get displayName => name;
}

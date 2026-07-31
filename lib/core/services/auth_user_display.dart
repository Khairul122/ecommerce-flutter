/// Nama & foto untuk tampilan profil, sumbernya sekarang Map user dari
/// `AuthService.currentUser` (hasil GET /me atau login/register), bukan lagi
/// Firebase `User`.
class AuthUserDisplay {
  AuthUserDisplay._();

  static String name(Map<String, dynamic>? user) {
    if (user == null) return 'Tamu';

    final name = (user['name'] as String?)?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    final email = (user['email'] as String?)?.trim();
    if (email != null && email.contains('@')) {
      final local = email.split('@').first.trim();
      if (local.isNotEmpty) {
        return local[0].toUpperCase() + local.substring(1);
      }
    }

    return 'Pengguna';
  }

  static String? email(Map<String, dynamic>? user) {
    final value = (user?['email'] as String?)?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  /// Foto profil owner tidak ada di kontrak API (user tidak punya
  /// photo_url), jadi kita pakai logo toko sebagai gambar tampilan profil.
  static String? storeLogoUrl(Map<String, dynamic>? user) {
    final store = user?['store'] as Map<String, dynamic>?;
    final url = (store?['logo_url'] as String?)?.trim();
    if (url == null || url.isEmpty) return null;
    return url;
  }
}

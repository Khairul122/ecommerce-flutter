class CategoryEntity {
  final int id;
  final String name;

  /// JSON mentah dari server, dipertahankan supaya field tambahan (mis.
  /// store_id, slug) masih bisa diakses tanpa memodelkan ulang semuanya.
  final Map<String, dynamic> raw;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.raw,
  });
}
